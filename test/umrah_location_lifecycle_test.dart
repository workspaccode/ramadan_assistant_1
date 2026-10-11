import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ramadan_assistant/core/di/service_locator.dart';
import 'package:ramadan_assistant/core/services/dua_service.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/l10n/app_localizations.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_event.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_state.dart';
import 'package:ramadan_assistant/presentation/screens/umrah_guide_screen/widgets/umrah_guide_content.dart';

class _Positions extends GeolocatorPlatform {
  _Positions(this.positions);
  final Stream<Position> positions;

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) =>
      positions;
}

class _TrackedUmrah extends Cubit<UmrahGuideState> implements UmrahGuideBloc {
  _TrackedUmrah()
    : super(
        const UmrahGuideLoaded(
          isAutoTracking: true,
          progress: [
            UmrahProgressData(id: 1, step: 'step_tawaf', completed: false),
          ],
        ),
      );
  final events = <UmrahGuideEvent>[];

  @override
  void add(UmrahGuideEvent event) {
    events.add(event);
    if (event is UpdateAutoTracking) {
      emit((state as UmrahGuideLoaded).copyWith(isAutoTracking: event.enabled));
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Position _position(double latitude, double longitude) => Position(
  latitude: latitude,
  longitude: longitude,
  timestamp: DateTime.now(),
  accuracy: 5,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

void main() {
  setUpAll(() async {
    final service = DuaService();
    await service.init();
    sl.registerSingleton<DuaService>(service);
  });
  tearDownAll(sl.reset);
  testWidgets(
    'Restored tracking ignores invalid GPS and survives missing map and plugin failures',
    (tester) async {
      var cancellations = 0;
      final positions = StreamController<Position>(
        onCancel: () async {
          cancellations++;
          throw StateError('Location plugin cancellation failed');
        },
      );
      final originalPlatform = GeolocatorPlatform.instance;
      GeolocatorPlatform.instance = _Positions(positions.stream);
      addTearDown(() => GeolocatorPlatform.instance = originalPlatform);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('vibration'), (
            _,
          ) async {
            throw PlatformException(code: 'unavailable');
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(const MethodChannel('vibration'), null),
      );
      final bloc = _TrackedUmrah();
      addTearDown(bloc.close);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.getLightTheme(const Locale('en')),
          home: Builder(
            builder: (context) {
              AppLocalizationsLookup.init(context);
              return BlocProvider<UmrahGuideBloc>.value(
                value: bloc,
                child: const UmrahGuideView(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      positions.add(_position(double.nan, 39.827650));
      positions.add(_position(91, 39.827650));
      positions.add(_position(21.425950, double.infinity));
      await tester.pumpAndSettle();
      expect(bloc.events.whereType<UpdateSaiLaps>(), isEmpty);
      // GPS can arrive while the map is absent, such as after changing steps.
      positions.add(_position(21.425950, 39.827650));
      await tester.pumpAndSettle();
      expect(bloc.events.whereType<UpdateSaiLaps>().single.laps, 1);
      bloc.add(const UpdateAutoTracking(false));
      await tester.pumpAndSettle();
      expect(cancellations, 1);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
