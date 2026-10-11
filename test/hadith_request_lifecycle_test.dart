import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/data/models/hadith_model.dart';
import 'package:ramadan_assistant/data/repositories/hadith_repository.dart';
import 'package:ramadan_assistant/presentation/cubits/hadith/hadith_cubit.dart';
import 'package:ramadan_assistant/presentation/cubits/hadith/hadith_state.dart';

class _Repository implements HadithRepository {
  final loads = <String, Completer<List<Hadith>>>{};
  final refreshes = <String, Completer<void>>{};
  @override
  Future<List<Hadith>> loadHadiths({String? url}) =>
      (loads[url!] ??= Completer<List<Hadith>>()).future;
  @override
  Future<void> forceRefresh({String? url}) =>
      (refreshes[url!] ??= Completer<void>()).future;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'An older book finishing after a new selection cannot replace it',
    () async {
      final repository = _Repository();
      final cubit = HadithCubit(repository);
      final old = cubit.loadHadiths(url: 'old');
      final current = cubit.loadHadiths(url: 'current');
      final selected = [Hadith(id: 2, textAr: 'current')];
      repository.loads['current']!.complete(selected);
      await current;
      repository.loads['old']!.complete([Hadith(id: 1, textAr: 'old')]);
      await old;
      expect((cubit.state as HadithLoaded).hadiths, selected);
      await cubit.close();
    },
  );
  test('An older failed request cannot clear the selected book', () async {
    final repository = _Repository();
    final cubit = HadithCubit(repository);
    final old = cubit.loadHadiths(url: 'old');
    final current = cubit.loadHadiths(url: 'current');
    repository.loads['current']!.complete([Hadith(id: 2)]);
    await current;
    repository.loads['old']!.completeError(StateError('offline'));
    await old;
    expect(cubit.state, isA<HadithLoaded>());
    await cubit.close();
  });
  test('Requests completing after close do not emit or throw', () async {
    final repository = _Repository();
    final cubit = HadithCubit(repository);
    final loading = cubit.loadHadiths(url: 'late');
    await cubit.close();
    repository.loads['late']!.complete([Hadith(id: 1)]);
    await loading;
    expect(cubit.isClosed, isTrue);
  });
  test('A stale refresh stops before requesting another book load', () async {
    final repository = _Repository();
    final cubit = HadithCubit(repository);
    final refresh = cubit.refreshHadiths(url: 'old');
    final current = cubit.loadHadiths(url: 'current');
    repository.loads['current']!.complete([Hadith(id: 2)]);
    await current;
    repository.refreshes['old']!.complete();
    await refresh;
    expect(repository.loads.containsKey('old'), isFalse);
    expect((cubit.state as HadithLoaded).hadiths.single.id, 2);
    await cubit.close();
  });
}
