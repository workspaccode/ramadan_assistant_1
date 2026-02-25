import 'package:equatable/equatable.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';

abstract class UmrahGuideState extends Equatable {
  const UmrahGuideState();

  @override
  List<Object> get props => [];
}

class UmrahGuideInitial extends UmrahGuideState {}

class UmrahGuideLoading extends UmrahGuideState {}

class UmrahGuideLoaded extends UmrahGuideState {
  final List<UmrahProgressData> progress;
  final int tawafCircuits;
  final int saiLaps;
  final bool isPrayedAtMaqam;
  final bool isDrunkZamzam;
  final bool isAutoTracking;

  const UmrahGuideLoaded({
    required this.progress,
    this.tawafCircuits = 0,
    this.saiLaps = 0,
    this.isPrayedAtMaqam = false,
    this.isDrunkZamzam = false,
    this.isAutoTracking = false,
  });

  UmrahGuideLoaded copyWith({
    List<UmrahProgressData>? progress,
    int? tawafCircuits,
    int? saiLaps,
    bool? isPrayedAtMaqam,
    bool? isDrunkZamzam,
    bool? isAutoTracking,
  }) {
    return UmrahGuideLoaded(
      progress: progress ?? this.progress,
      tawafCircuits: tawafCircuits ?? this.tawafCircuits,
      saiLaps: saiLaps ?? this.saiLaps,
      isPrayedAtMaqam: isPrayedAtMaqam ?? this.isPrayedAtMaqam,
      isDrunkZamzam: isDrunkZamzam ?? this.isDrunkZamzam,
      isAutoTracking: isAutoTracking ?? this.isAutoTracking,
    );
  }

  @override
  List<Object> get props => [
    progress,
    tawafCircuits,
    saiLaps,
    isPrayedAtMaqam,
    isDrunkZamzam,
    isAutoTracking,
  ];
}

class UmrahGuideError extends UmrahGuideState {
  final String message;

  const UmrahGuideError(this.message);

  @override
  List<Object> get props => [message];
}
