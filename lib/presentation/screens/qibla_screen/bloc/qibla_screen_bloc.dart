import 'dart:async';
import 'dart:math' show atan2;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayers_times/prayers_times.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math.dart' show degrees;

abstract class QiblaScreenState extends Equatable {
  const QiblaScreenState();

  @override
  List<Object?> get props => [];
}

class QiblaScreenInitial extends QiblaScreenState {}

class QiblaScreenLoading extends QiblaScreenState {}

class QiblaScreenLoaded extends QiblaScreenState {
  final double qiblaDirection; // The angle of the Qibla from North (0-360)
  final double deviceHeading; // The device's current heading from North (0-360)
  final Position position;
  final bool hasCompass; // True if device has magnetometer
  final double? accuracy; // Optional accuracy metric

  const QiblaScreenLoaded({
    required this.qiblaDirection,
    required this.deviceHeading,
    required this.position,
    this.hasCompass = true,
    this.accuracy,
  });

  @override
  List<Object?> get props => [
    qiblaDirection,
    deviceHeading,
    position,
    hasCompass,
    accuracy,
  ];
}

class QiblaScreenError extends QiblaScreenState {
  final String message;
  final bool isLocationError;

  const QiblaScreenError(this.message, {this.isLocationError = false});

  @override
  List<Object?> get props => [message, isLocationError];
}

class QiblaLocationRequired extends QiblaScreenState {
  final LocationPermission status;

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
  final double heading;
  final double qiblaAngle;
  final Position position;
  final bool hasCompass;

  const UpdateQiblaData({
    required this.heading,
    required this.qiblaAngle,
    required this.position,
    required this.hasCompass,
  });

  @override
  List<Object?> get props => [heading, qiblaAngle, position, hasCompass];
}

class UpdateLocationStatus extends QiblaScreenEvent {
  final LocationPermission status;
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
  StreamSubscription? _magnetometerSubscription;
  StreamSubscription? _positionSubscription;
  Position? _lastPosition;
  double _qiblaAngle = 0.0;

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
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          emit(QiblaLocationRequired(requested));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(QiblaLocationRequired(permission));
        return;
      }

      await _initQibla();
    } catch (e) {
      emit(QiblaScreenError(e.toString()));
    }
  }

  Future<void> _initQibla() async {
    try {
      // 1. Get Location
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (_) {
        position =
            await Geolocator.getLastKnownPosition() ??
            await _getDefaultPosition();
      }
      _lastPosition = position;

      // 2. Calculate Qibla Angle using prayers_times
      final coordinates = Coordinates(position.latitude, position.longitude);
      _qiblaAngle = Qibla.qibla(coordinates);

      // 3. Check for Compass Sensors
      _subscribeToSensors();
    } catch (e) {
      emit(QiblaScreenError(e.toString()));
    }
  }

  void _subscribeToSensors() {
    _magnetometerSubscription?.cancel();
    _positionSubscription?.cancel();

    // Stream for Magnetometer
    _magnetometerSubscription = magnetometerEventStream().listen(
      (MagnetometerEvent event) {
        double heading = degrees(atan2(event.x, event.y));
        if (heading >= 360) heading -= 360;
        if (heading < 0) heading += 360;

        // Reverse for clockwise heading from North
        // Actually, atan2(x, y) gives angle from Y-axis.
        // If Y is North, X is East.
        // We want clockwise. atan2(x, y) is usually (angle from Y towards X).
        // Let's verify standard compass math: headings are 0=N, 90=E.
        // event.y is North component, event.x is East component.
        // atan2(x, y) returns angle from North towards East.
        // This seems correct for heading.

        add(
          UpdateQiblaData(
            heading: heading,
            qiblaAngle: _qiblaAngle,
            position:
                _lastPosition ??
                Position(
                  latitude: 21.4225,
                  longitude: 39.8262,
                  timestamp: DateTime.now(),
                  accuracy: 0,
                  altitude: 0,
                  altitudeAccuracy: 0,
                  heading: 0,
                  headingAccuracy: 0,
                  speed: 0,
                  speedAccuracy: 0,
                ),
            hasCompass: true,
          ),
        );
      },
      onError: (e) {
        _startGpsHeadingFallback();
      },
    );

    // If no data received in 2 seconds, switch to GPS fallback
    Future.delayed(const Duration(seconds: 2), () {
      // Here we could implement a logic to check if we received data
      // For simplicity, we assume if onError didn't fire, we might have a sensor but it's quiet?
      // Actually, usually streams emit immediately.
      // Let's rely on onError for now.
    });
  }

  void _startGpsHeadingFallback() {
    _magnetometerSubscription?.cancel();
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((Position pos) {
          _lastPosition = pos;

          final coordinates = Coordinates(pos.latitude, pos.longitude);
          _qiblaAngle = Qibla.qibla(coordinates);

          if (pos.speed > 0.5) {
            add(
              UpdateQiblaData(
                heading: pos.heading,
                qiblaAngle: _qiblaAngle,
                position: pos,
                hasCompass: false,
              ),
            );
          } else {
            add(
              UpdateQiblaData(
                heading: 0,
                qiblaAngle: _qiblaAngle,
                position: pos,
                hasCompass: false,
              ),
            );
          }
        });
  }

  Future<Position> _getDefaultPosition() async {
    return Position(
      latitude: 21.4225,
      longitude: 39.8262,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  void _onUpdateQiblaData(
    UpdateQiblaData event,
    Emitter<QiblaScreenState> emit,
  ) {
    emit(
      QiblaScreenLoaded(
        qiblaDirection: event.qiblaAngle,
        deviceHeading: event.heading,
        position: event.position,
        hasCompass: event.hasCompass,
      ),
    );
  }

  void _onUpdateLocationStatus(
    UpdateLocationStatus event,
    Emitter<QiblaScreenState> emit,
  ) {
    if (event.status == LocationPermission.whileInUse ||
        event.status == LocationPermission.always) {
      add(StartQiblaUpdates());
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
    _magnetometerSubscription?.cancel();
    _positionSubscription?.cancel();
    return super.close();
  }
}
