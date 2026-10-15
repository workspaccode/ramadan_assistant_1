import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/core/di/service_locator.dart';
import 'package:ramadan_assistant/core/services/location_service.dart';
import 'package:ramadan_assistant/core/utils/smart_update_manager.dart';
import 'package:ramadan_assistant/presentation/screens/settings_screen/bloc/settings_screen_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Updates implements SmartUpdateManager {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'restoring settings preserves notification history and one-time flags',
    () async {
      sl.registerSingleton<SmartUpdateManager>(_Updates());
      addTearDown(() => sl.unregister<SmartUpdateManager>());
      SharedPreferences.setMockInitialValues({
        'current_country': 'Saudi Arabia',
        'calculation_method': 'egyptian',
        'notifications_enabled': false,
        'font_size_multiplier': 1.3,
        'update_history': 'saved history',
        'permission_rationale_shown': true,
      });
      final bloc = SettingsScreenBloc(LocationService());
      addTearDown(bloc.close);
      await bloc.stream.firstWhere((state) => state is SettingsScreenLoaded);
      final defaults = bloc.stream.firstWhere(
        (state) =>
            state is SettingsScreenLoaded &&
            state.calculationMethod == 'muslimWorldLeague',
      );
      bloc.add(ResetAllData());
      final result = await defaults as SettingsScreenLoaded;
      expect(result.notificationsEnabled, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('update_history'), 'saved history');
      expect(prefs.getBool('permission_rationale_shown'), isTrue);
    },
  );
}
