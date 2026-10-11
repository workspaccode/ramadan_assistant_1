import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen/bloc/tasbih_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('vibration'),
          (_) async => null,
        );
  });
  test('Rapid taps and reset save one row per session', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final bloc = TasbihBloc(database);
    addTearDown(() async {
      await bloc.close();
      await database.close();
    });
    final targetChanged = bloc.stream.firstWhere((state) => state.target == 2);
    bloc.add(const ChangeTarget(2));
    await targetChanged;
    final reached = bloc.stream.firstWhere((state) => state.count == 4);
    for (var i = 0; i < 4; i++) {
      bloc.add(IncrementCounter());
    }
    await reached;
    final reset = bloc.stream.firstWhere((state) => state.count == 0);
    bloc.add(ResetCounter());
    await reset;
    var sessions = await database.select(database.tasbihSessions).get();
    expect(sessions, hasLength(1));
    expect(sessions.single.count, 4);
    expect(sessions.single.completedAt, isNotNull);
    final second = bloc.stream.firstWhere((state) => state.count == 1);
    bloc.add(IncrementCounter());
    await second;
    final changed = bloc.stream.firstWhere(
      (state) => state.currentDhikr == 'Alhamdulillah',
    );
    bloc.add(const ChangeDhikr('Alhamdulillah', 33));
    await changed;
    sessions = await database.select(database.tasbihSessions).get();
    expect(sessions, hasLength(2));
    expect(sessions.map((s) => s.count), containsAll([4, 1]));
  });
  test('Invalid targets leave the current target unchanged', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final bloc = TasbihBloc(database);
    bloc.add(const ChangeTarget(0));
    bloc.add(const ChangeDhikr('Alhamdulillah', -1));
    await bloc.close();
    expect(bloc.state.target, 33);
    expect(bloc.state.currentDhikr, 'SubhanAllah');
    await database.close();
  });
}
