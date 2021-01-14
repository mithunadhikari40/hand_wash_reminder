import 'package:shared_preferences/shared_preferences.dart';

class _LocalCache {
  SharedPreferences _preferences;

  _LocalCache() {
    _init();
  }
  Future<void> reload() async {
    if (_preferences == null) {
      await _init();
    }
   await _preferences.reload();

  }

  Future _init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future setStringValue(String key, String value) async {
    if (_preferences == null) {
      await _init();
    }
    _preferences.setString(key, value);
  }

  Future setBoolValue(String key, bool value) async {
    if (_preferences == null) {
      await _init();
    }
    _preferences.setBool(key, value);
  }

  Future<bool> getBoolValue(String key) async {
    if (_preferences == null) {
      await _init();
    }
    return _preferences.getBool(key) ?? false;
  }

  Future<String> getStringValue(String key) async {
    if (_preferences == null) {
      await _init();
    }
    return _preferences.getString(key)?? "";
  }

  Future<void> clearAllCache() async {
    if (_preferences == null) {
      await _init();
    }
    await _preferences.clear();

  }
}

final cache = _LocalCache();
const LOGIN_SCREEN_KEY ="LOGIN_SCREEN_KEY";
const LOGIN_SCREEN_VALUE ="LOGIN_SCREEN_VALUE";
const INFORMATION_SCREEN_KEY ="INFORMATION_SCREEN_KEY";
const INFORMATION_SCREEN_VALUE ="INFORMATION_SCREEN_VALUE";
const HOME_SCREEN_KEY ="HOME_SCREEN_KEY";
const HOME_SCREEN_VALUE ="HOME_SCREEN_VALUE";


const LIQUID_UNIT_KEY ="LIQUID_UNIT_KEY";
const SOLID_UNIT_KEY ="SOLID_UNIT_KEY";
const SLEEP_TIME_KEY ="SLEEP_TIME_KEY";
const WAKEUP_TIME_KEY ="WAKEUP_TIME_KEY";

const CUSTOM_NOTIFICATION_MESSAGE_KEY ="CUSTOM_NOTIFICATION_MESSAGE_KEY";
const CUSTOM_NOTIFICATION_DURATION_MESSAGE_KEY ="CUSTOM_NOTIFICATION_DURATION_MESSAGE_KEY";
const CUSTOM_NOTIFICATION_TONE_KEY ="CUSTOM_NOTIFICATION_TONE_KEY";
const CUSTOM_WEIGHT_KEY ="CUSTOM_WEIGHT_KEY";
const CUSTOM_INTAKE_KEY ="CUSTOM_INTAKE_KEY";
const CUSTOM_WORKOUT_KEY ="CUSTOM_WORKOUT_KEY";

const NOTIFICATION_ENABLED ="NOTIFICATION_ENABLED";

