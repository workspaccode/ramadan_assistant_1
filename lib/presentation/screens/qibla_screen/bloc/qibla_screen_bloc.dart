import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';

abstract class QiblaScreenState extends Equatable {
  const QiblaScreenState();

  @override
  List<Object?> get props => [];
}

class QiblaScreenInitial extends QiblaScreenState {}

class QiblaScreenLoading extends QiblaScreenState {}

class QiblaScreenLoaded extends QiblaScreenState {
  final QiblahDirection direction;
  final Position position;

  const QiblaScreenLoaded(this.direction, this.position);

  @override
  List<Object?> get props => [direction, position];
}

class QiblaScreenError extends QiblaScreenState {
  final String message;
  final bool isLocationError;

  const QiblaScreenError(this.message, {this.isLocationError = false});

  @override
  List<Object?> get props => [message, isLocationError];
}

class QiblaLocationRequired extends QiblaScreenState {
  final LocationStatus status;

  const QiblaLocationRequired(this.status);

  @override
  List<Object?> get props => [status];
}

abstract class QiblaScreenEvent extends Equatable {
  const QiblaScreenEvent();

  @override
  List<Object?> get props => [];
}

class StartQiblaUpdates extends QiblaScreenEvent {}

class UpdateQiblaData extends QiblaScreenEvent {
  final QiblahDirection direction;
  final Position position;
  const UpdateQiblaData(this.direction, this.position);

  @override
  List<Object?> get props => [direction, position];
}

class UpdateLocationStatus extends QiblaScreenEvent {
  final LocationStatus status;
  const UpdateLocationStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class QiblaErrorOccurred extends QiblaScreenEvent {
  final String message;
  const QiblaErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}

class QiblaScreenBloc extends Bloc<QiblaScreenEvent, QiblaScreenState> {
  StreamSubscription? _qiblaSubscription;

  QiblaScreenBloc() : super(QiblaScreenInitial()) {
    on<StartQiblaUpdates>(_onStartQiblaUpdates);
    on<UpdateQiblaData>(_onUpdateQiblaData);
    on<UpdateLocationStatus>(_onUpdateLocationStatus);
    on<QiblaErrorOccurred>(_onQiblaErrorOccurred);

    add(StartQiblaUpdates());
  }

  Future<void> _onStartQiblaUpdates(
    StartQiblaUpdates event,
    Emitter<QiblaScreenState> emit,
  ) async {
    emit(QiblaScreenLoading());
    try {
      final status = await FlutterQiblah.checkLocationStatus();
      if (status.enabled &&
          (status.status == LocationPermission.always ||
              status.status == LocationPermission.whileInUse)) {
        await _subscribeToQibla();
      } else {
        emit(QiblaLocationRequired(status));
      }
    } catch (e) {
      emit(QiblaScreenError(e.toString()));
    }
  }

  Future<void> _subscribeToQibla() async {
    _qiblaSubscription?.cancel();

    // Get initial position
    final position = await Geolocator.getCurrentPosition();

    _qiblaSubscription = FlutterQiblah.qiblahStream.listen(
      (data) {
        add(UpdateQiblaData(data, position));
      },
      onError: (error) {
        add(QiblaErrorOccurred(error.toString()));
      },
    );
  }

  void _onUpdateQiblaData(
    UpdateQiblaData event,
    Emitter<QiblaScreenState> emit,
  ) {
    emit(QiblaScreenLoaded(event.direction, event.position));
  }

  void _onUpdateLocationStatus(
    UpdateLocationStatus event,
    Emitter<QiblaScreenState> emit,
  ) {
    if (event.status.enabled &&
        (event.status.status == LocationPermission.always ||
            event.status.status == LocationPermission.whileInUse)) {
      _subscribeToQibla();
    } else {
      emit(QiblaLocationRequired(event.status));
    }
  }

  void _onQiblaErrorOccurred(
    QiblaErrorOccurred event,
    Emitter<QiblaScreenState> emit,
  ) {
    emit(QiblaScreenError(event.message));
  }

  @override
  Future<void> close() {
    _qiblaSubscription?.cancel();
    return super.close();
  }
}
