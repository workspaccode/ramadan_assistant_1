import 'package:adhan_dart/adhan_dart.dart';
import 'package:equatable/equatable.dart';

abstract class PrayerTimesState extends Equatable {
  const PrayerTimesState();

  @override
  List<Object?> get props => [];
}

class PrayerTimesInitial extends PrayerTimesState {}

class PrayerTimesLoading extends PrayerTimesState {}

class PrayerTimesLoaded extends PrayerTimesState {
  final PrayerTimes prayerTimes;
  final String locationName;

  const PrayerTimesLoaded({
    required this.prayerTimes,
    required this.locationName,
  });

  @override
  List<Object?> get props => [prayerTimes, locationName];
}

class PrayerTimesError extends PrayerTimesState {
  final String message;

  const PrayerTimesError(this.message);

  @override
  List<Object?> get props => [message];
}
