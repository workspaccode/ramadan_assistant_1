import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/data/repositories/hadith_repository.dart';

import 'hadith_state.dart';

class HadithCubit extends Cubit<HadithState> {
  final HadithRepository _repository;
  int _request = 0;

  HadithCubit(this._repository) : super(HadithInitial());

  Future<void> loadHadiths({String? url}) async {
    if (isClosed) {
      return;
    }
    final request = ++_request;
    emit(HadithLoading());
    try {
      final hadiths = await _repository.loadHadiths(url: url);
      if (isClosed || request != _request) {
        return;
      }
      emit(HadithLoaded(hadiths));
    } catch (e) {
      if (isClosed || request != _request) {
        return;
      }
      emit(HadithError(e.toString()));
    }
  }

  Future<void> refreshHadiths({String? url}) async {
    if (isClosed) {
      return;
    }
    final request = ++_request;
    emit(HadithLoading());
    try {
      await _repository.forceRefresh(url: url);
      if (isClosed || request != _request) {
        return;
      }
      final hadiths = await _repository.loadHadiths(url: url);
      if (isClosed || request != _request) {
        return;
      }
      emit(HadithLoaded(hadiths));
    } catch (e) {
      if (isClosed || request != _request) {
        return;
      }
      emit(HadithError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _request++;
    return super.close();
  }
}
