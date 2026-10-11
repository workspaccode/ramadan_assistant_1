import 'dart:async';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadan_assistant/core/l10n/app_localizations.dart';
import 'package:ramadan_assistant/core/services/location_service.dart';
import 'package:ramadan_assistant/core/services/prayer_service.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_event.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_state.dart';
import 'dart:ui' show Locale;

Position _position()=>Position(latitude:21.42,longitude:39.82,timestamp:DateTime(2026,10,10),accuracy:1,
  altitude:0,altitudeAccuracy:0,heading:0,headingAccuracy:0,speed:0,speedAccuracy:0);
class _Location extends LocationService {
  final requests=<bool>[];
  final pending=<Completer<Position>>[];
  @override Future<Position> getCurrentLocation({bool requestPermission=true}){
    requests.add(requestPermission);final result=Completer<Position>();pending.add(result);return result.future;
  }
}
class _Prayers extends PrayerService {
  @override Future<PrayerData> getCurrentPrayerData(Position position,{String? localeLanguageCode})async=>PrayerData(
    prayerTimes:PrayerTimes(date:DateTime(2026,10,10),coordinates:Coordinates(position.latitude,position.longitude),
      calculationParameters:CalculationMethodParameters.ummAlQura()),
    position:position,locationName:localeLanguageCode??'default',methodId:'ummAlQura',madhabId:'shafi');
}
void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Passive prayer load never requests permission; explicit retry can',()async{
    final location=_Location();final bloc=PrayerTimesBloc(location,_Prayers());
    final first=bloc.stream.firstWhere((state)=>state is PrayerTimesLoading);bloc.add(const LoadPrayerTimes());await first;
    expect(location.requests,[false]);
    final failure=bloc.stream.firstWhere((state)=>state is PrayerTimesError);location.pending[0].completeError(StateError('denied'));await failure;
    final second=bloc.stream.firstWhere((state)=>state is PrayerTimesLoaded);
    bloc.add(const LoadPrayerTimes(requestPermission:true));await Future<void>.delayed(Duration.zero);
    expect(location.requests,[false,true]);location.pending[1].complete(_position());await second;await bloc.close();
  });
  test('Stale GPS result cannot replace latest locale selection',()async{
    final location=_Location();final bloc=PrayerTimesBloc(location,_Prayers());
    bloc.add(const LoadPrayerTimes(locale:'ar'));await Future<void>.delayed(Duration.zero);
    bloc.add(const LoadPrayerTimes(locale:'en'));await Future<void>.delayed(Duration.zero);
    final loaded=bloc.stream.firstWhere((state)=>state is PrayerTimesLoaded);location.pending[1].complete(_position());await loaded;
    location.pending[0].complete(_position());await Future<void>.delayed(Duration.zero);
    expect((bloc.state as PrayerTimesLoaded).locationName,'en');await bloc.close();
  });
  test('Pending GPS failure after close does not emit',()async{
    final location=_Location();final bloc=PrayerTimesBloc(location,_Prayers());
    bloc.add(const LoadPrayerTimes());await Future<void>.delayed(Duration.zero);
    final closing=bloc.close();location.pending.single.completeError(StateError('GPS timeout'));await closing;
    expect(bloc.isClosed,true);
  });
  test('Geocoder timeout still returns calculated prayers with localized fallback',()async{
    SharedPreferences.setMockInitialValues({});
    const channel=MethodChannel('flutter.baseflow.com/geocoding');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel,(call)async{
      if(call.method=='placemarkFromCoordinates')return Completer<Object?>().future;
      return null;
    });
    final service=PrayerService(geocodingTimeout:const Duration(milliseconds:30));
    final data=await service.getCurrentPrayerData(_position(),localeLanguageCode:'ar');
    expect(data.locationName,lookupAppLocalizations(const Locale('ar')).unknown);
    expect(data.prayerTimes.fajr.isBefore(data.prayerTimes.maghrib),true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel,null);
  });
}
