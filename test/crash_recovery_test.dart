import 'package:drift/native.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ramadan_assistant/core/services/location_service.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_event.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_state.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen/bloc/tasbih_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Failed haptic plugin does not interrupt tasbih counting', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('vibration'), (_) async {
          throw PlatformException(code: 'unavailable');
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('vibration'), null);
    });
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final bloc = TasbihBloc(database);
    final incremented = bloc.stream.firstWhere((state) => state.count == 1);
    bloc.add(IncrementCounter());
    await incremented;
    await bloc.close();
    await database.close();
    expect(bloc.state.count, 1);
  });

  test('Umrah reset completes before subsequent counter update', () async {
    SharedPreferences.setMockInitialValues({'umrah_tawaf_circuits': 6});
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final bloc = UmrahGuideBloc(database);
    addTearDown(() async {
      await bloc.close();
      await database.close();
    });
    final loaded = bloc.stream.firstWhere((state) => state is UmrahGuideLoaded);
    bloc.add(LoadUmrahProgress());
    await loaded;
    final restarted = bloc.stream.firstWhere(
      (state) => state is UmrahGuideLoaded && state.tawafCircuits == 1,
    );
    bloc
      ..add(ResetUmrahProgress())
      ..add(const UpdateTawafCircuits(1));
    await restarted.timeout(const Duration(seconds: 5));
    // Closing drains the queue, including the last persisted counter write.
    await bloc.close();
    final prefs = await SharedPreferences.getInstance();
    expect(
      (jsonDecode(prefs.getString('umrah_counter_snapshot_v1')!)
          as Map)['tawaf'],
      1,
    );
    expect((bloc.state as UmrahGuideLoaded).tawafCircuits, 1);
    final rows = await database.select(database.umrahProgress).get();
    expect(rows, hasLength(5));
    expect(rows.every((row) => !row.completed), isTrue);
  });

  test(
    'Tasbih save failure preserves the session on reset and dhikr change',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      await database.customStatement(
        'CREATE TRIGGER fail_tasbih_save BEFORE INSERT ON tasbih_sessions '
        "BEGIN SELECT RAISE(ABORT, 'simulated write failure'); END;",
      );
      final bloc = TasbihBloc(database);
      final changed = bloc.stream.firstWhere((state) => state.target == 1);
      bloc.add(const ChangeTarget(1));
      await changed;
      final failed = bloc.stream.firstWhere(
        (state) => state is TasbihSaveFailed,
      );
      bloc.add(IncrementCounter());
      await failed.timeout(const Duration(seconds: 5));
      bloc
        ..add(ResetCounter())
        ..add(const ChangeDhikr('Alhamdulillah', 33))
        ..add(RetryTasbihSave());
      await bloc.close();
      expect(bloc.state, isA<TasbihSaveFailed>());
      expect(bloc.state.count, 1);
      expect(bloc.state.currentDhikr, 'SubhanAllah');
      await database.close();
    },
  );

  test('Invalid cached coordinates and timestamps are not restored', () async {
    for (final values in <Map<String, Object>>[
      {'cached_location_lat': 91.0, 'cached_location_lng': 39.0},
      {'cached_location_lat': 21.0, 'cached_location_lng': double.nan},
      {
        'cached_location_lat': 21.0,
        'cached_location_lng': 39.0,
        'cached_location_timestamp': -1,
      },
    ]) {
      SharedPreferences.setMockInitialValues(values);
      expect(await LocationService().getCachedPosition(), isNull);
    }
  });

  test(
    'Tasbih save retry persists once and restores completed state',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      await database.customStatement(
        'CREATE TRIGGER fail_tasbih_save BEFORE INSERT ON tasbih_sessions '
        "BEGIN SELECT RAISE(ABORT, 'simulated write failure'); END;",
      );
      final bloc = TasbihBloc(database);
      final changed = bloc.stream.firstWhere((state) => state.target == 1);
      bloc.add(const ChangeTarget(1));
      await changed;
      final failed = bloc.stream.firstWhere(
        (state) => state is TasbihSaveFailed,
      );
      bloc.add(IncrementCounter());
      await failed.timeout(const Duration(seconds: 5));
      expect((bloc.state as TasbihSaveFailed).isCompleted, isTrue);
      await database.customStatement('DROP TRIGGER fail_tasbih_save');
      final recovered = bloc.stream.firstWhere(
        (state) => state is TasbihCompleted,
      );
      bloc.add(RetryTasbihSave());
      await recovered.timeout(const Duration(seconds: 5));
      await bloc.close();
      final sessions = await database.select(database.tasbihSessions).get();
      expect(sessions, hasLength(1));
      expect(sessions.single.count, 1);
      expect(sessions.single.completedAt, isNotNull);
      await database.close();
    },
  );

  test('Valid cached coordinates remain available offline', () async {
    SharedPreferences.setMockInitialValues({
      'cached_location_lat': 21.4,
      'cached_location_lng': 39.8,
      'cached_location_timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    final position = await LocationService().getCachedPosition();
    expect(position?.latitude, 21.4);
    expect(position?.longitude, 39.8);
  });

  test('Passive location load does not request denied permission', () async {
    final previousPlatform = GeolocatorPlatform.instance;
    final platform = _DeniedLocationPlatform();
    GeolocatorPlatform.instance = platform;
    addTearDown(() => GeolocatorPlatform.instance = previousPlatform);
    await expectLater(
      LocationService().getCurrentLocation(requestPermission: false),
      throwsA('Location permissions are denied'),
    );
    expect(platform.permissionRequests, 0);
    await expectLater(
      LocationService().getCurrentLocation(),
      throwsA('Location permissions are denied'),
    );
    expect(platform.permissionRequests, 1);
  });
}

class _DeniedLocationPlatform extends GeolocatorPlatform {
  int permissionRequests = 0;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.denied;

  @override
  Future<LocationPermission> requestPermission() async {
    permissionRequests++;
    return LocationPermission.denied;
  }
}
