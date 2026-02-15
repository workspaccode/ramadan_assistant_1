import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ramadan_assistant/core/services/tts_service.dart';

abstract class IqamaScreenState extends Equatable {
  const IqamaScreenState();

  @override
  List<Object?> get props => [];
}

class IqamaScreenInitial extends IqamaScreenState {}

class IqamaScreenReminder extends IqamaScreenState {
  final String prayerName;

  const IqamaScreenReminder(this.prayerName);

  @override
  List<Object?> get props => [prayerName];
}

class IqamaScreenDismissed extends IqamaScreenState {}

abstract class IqamaScreenEvent extends Equatable {
  const IqamaScreenEvent();

  @override
  List<Object?> get props => [];
}

class ShowIqamaReminder extends IqamaScreenEvent {
  final String prayerName;
  const ShowIqamaReminder(this.prayerName);
}

class DismissIqama extends IqamaScreenEvent {}

class IqamaScreenBloc extends Bloc<IqamaScreenEvent, IqamaScreenState> {
  final TtsService _ttsService = TtsService();
  Timer? _dismissTimer;

  IqamaScreenBloc({required String prayerName}) : super(IqamaScreenInitial()) {
    on<ShowIqamaReminder>(_onShowIqamaReminder);
    on<DismissIqama>(_onDismissIqama);

    add(ShowIqamaReminder(prayerName));
  }

  void _onShowIqamaReminder(
    ShowIqamaReminder event,
    Emitter<IqamaScreenState> emit,
  ) {
    emit(IqamaScreenReminder(event.prayerName));
    _ttsService.announceIqama();

    _dismissTimer?.cancel();
    _dismissTimer = Timer(const Duration(seconds: 30), () {
      add(DismissIqama());
    });
  }

  void _onDismissIqama(DismissIqama event, Emitter<IqamaScreenState> emit) {
    _ttsService.stop();
    _dismissTimer?.cancel();
    emit(IqamaScreenDismissed());
  }

  @override
  Future<void> close() {
    _dismissTimer?.cancel();
    _ttsService.stop();
    return super.close();
  }
}
