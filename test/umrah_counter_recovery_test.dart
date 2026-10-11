import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_event.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'out of bounds values are clamped and a complete Tawaf is not gated by optional reminders',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final bloc = UmrahGuideBloc(db);
      addTearDown(() async {
        await bloc.close();
        await db.close();
      });
      final loaded = bloc.stream.firstWhere((s) => s is UmrahGuideLoaded);
      bloc.add(LoadUmrahProgress());
      await loaded;
      final seven = bloc.stream.firstWhere(
        (s) => s is UmrahGuideLoaded && s.tawafCircuits == 7,
      );
      bloc.add(const UpdateTawafCircuits(100));
      final state = await seven as UmrahGuideLoaded;
      expect(state.canComplete('step_tawaf'), isTrue);
      expect(state.isPrayedAtMaqam, isFalse);
      expect(state.isDrunkZamzam, isFalse);
      bloc.add(const UpdateSaiLaps(-10));
      await bloc.close();
      final encoded = (await SharedPreferences.getInstance()).getString(
        'umrah_counter_snapshot_v1',
      )!;
      expect((jsonDecode(encoded) as Map)['sai'], 0);
      final resumed = UmrahGuideBloc(db);
      final restored = resumed.stream.firstWhere((s) => s is UmrahGuideLoaded);
      resumed.add(LoadUmrahProgress());
      expect((await restored as UmrahGuideLoaded).tawafCircuits, 7);
      await resumed.close();
    },
  );

  test(
    'failed write keeps counts visible, blocks completion and supports retry',
    () async {
      var fail = true;
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final bloc = UmrahGuideBloc(
        db,
        persistCounterSnapshot: (encoded) async {
          if (fail) return false;
          return (await SharedPreferences.getInstance()).setString(
            'umrah_counter_snapshot_v1',
            encoded,
          );
        },
      );
      addTearDown(() async {
        await bloc.close();
        await db.close();
      });
      final initial = bloc.stream.firstWhere((s) => s is UmrahGuideLoaded);
      bloc.add(LoadUmrahProgress());
      await initial;
      final failed = bloc.stream.firstWhere(
        (s) => s is UmrahGuideLoaded && s.persistenceFailed,
      );
      bloc.add(const UpdateTawafCircuits(7));
      final kept = await failed as UmrahGuideLoaded;
      expect(kept.tawafCircuits, 7);
      expect(kept.canComplete('step_tawaf'), isFalse);
      final id = kept.progress
          .firstWhere((step) => step.step == 'step_tawaf')
          .id;
      bloc.add(CompleteUmrahStep(id));
      fail = false;
      final recovered = bloc.stream.firstWhere(
        (s) => s is UmrahGuideLoaded && !s.persistenceFailed,
      );
      bloc.add(RetryUmrahCounterSave());
      expect(
        (await recovered as UmrahGuideLoaded).canComplete('step_tawaf'),
        isTrue,
      );
      await bloc.close();
      expect(
        (await db.select(db.umrahProgress).get())
            .firstWhere((step) => step.id == id)
            .completed,
        isFalse,
      );
      expect(
        (jsonDecode(
              (await SharedPreferences.getInstance()).getString(
                'umrah_counter_snapshot_v1',
              )!,
            )
            as Map)['tawaf'],
        7,
      );
    },
  );
}
