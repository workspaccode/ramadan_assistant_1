import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/data/repositories/hadith_repository.dart';

import 'hadith_state.dart';

class HadithCubit extends Cubit<HadithState> {
  final HadithRepository _repository;

  HadithCubit(this._repository) : super(HadithInitial());

  Future<void> loadHadiths({String? url}) async {
    emit(HadithLoading());
    try {
      final hadiths = await _repository.loadHadiths(url: url);
      emit(HadithLoaded(hadiths));
    } catch (e) {
      emit(HadithError(e.toString()));
    }
  }

  Future<void> refreshHadiths({String? url}) async {
    emit(HadithLoading());
    try {
      await _repository.forceRefresh(url: url);
      final hadiths = await _repository.loadHadiths(url: url);
      emit(HadithLoaded(hadiths));
    } catch (e) {
      emit(HadithError(e.toString()));
    }
  }
}
