import 'package:equatable/equatable.dart';

abstract class PrayerTimesEvent extends Equatable {
  const PrayerTimesEvent();

  @override
  List<Object> get props => [];
}

class LoadPrayerTimes extends PrayerTimesEvent {}

class RefreshPrayerTimes extends PrayerTimesEvent {}
