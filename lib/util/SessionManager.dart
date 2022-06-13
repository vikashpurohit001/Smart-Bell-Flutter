import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const PREFIX = "io.habilelabs.esp.pref";
  static const String PREF_IS_APP_LAUNCH = '$PREFIX.PREF_IS_APP_LAUNCH';
  static const String PREF_KEY_USERNAME = '$PREFIX.PREF_KEY_USERNAME';
  static const String PREF_KEY_USER_ID = '$PREFIX.PREF_KEY_USER_ID';
  static const String PREF_KEY_LOGIN_TOKEN = '$PREFIX.PREF_KEY_LOGIN_TOKEN';
  static const String PREF_KEY_REFRESH_TOKEN = '$PREFIX.PREF_KEY_REFRESH_TOKEN';
  static const String PREF_KEY_ENTITY_TYPE = '$PREFIX.PREF_KEY_ENTITY_TYPE';
  static const String PREF_KEY_TENANT_ID = '$PREFIX.PREF_KEY_TENANT_ID';
  static const String PREF_KEY_CUSTOMER_ID = '$PREFIX.PREF_KEY_CUSTOMER_ID';
  static const String PREF_KEY_AUTHORITY = '$PREFIX.PREF_KEY_AUTHORITY';
  static const String PREF_KEY_FIRST_NAME = '$PREFIX.PREF_KEY_FIRST_NAME';
  static const String PREF_KEY_LAST_NAME = '$PREFIX.PREF_KEY_LAST_NAME';
  static const String PREF_KEY_TENANT_TOKEN = '$PREFIX.PREF_KEY_TENANT_TOKEN';
  static const String PREF_KEY_REFRESH_TENANT_TOKEN =
      '$PREFIX.PREF_KEY_REFRESH_TENANT_TOKEN';
  static const String PREF_KEY_DEFAULT_PROFILE_ID =
      '$PREFIX.PREF_KEY_DEFAULT_PROFILE_ID';
  static const String RECENT_PREF_KEY_DEVICE_ID =
      '$PREFIX.RECENT.PREF_KEY_DEVICE_ID';
  static const String RECENT_PREF_KEY_DEVICE_TOKEN =
      '$PREFIX.RECENT.PREF_KEY_DEVICE_TOKEN';
  static const String RECENT_PREF_KEY_DEVICE_NAME =
      '$PREFIX.RECENT.PREF_KEY_DEVICE_NAME';
  static const String RECENT_PREF_KEY_USERNAME =
      '$PREFIX.RECENT.PREF_KEY_USERNAME';

  static const String WIFI_PREF_KEY_WIFI_INFO =
      '$PREFIX.WIFI.PREF_KEY_WIFI_INFO';
  static const String WIFI_PREF_KEY_SSID = '$PREFIX.WIFI.PREF_KEY_SSID';
  static const String WIFI_PREF_KEY_PASS = '$PREFIX.WIFI.PREF_KEY_PASS';

  static final SessionManager _singleton = new SessionManager._internal();

  Future<SharedPreferences> _mPref;

  factory SessionManager() {
    return _singleton;
  }

  SessionManager._internal() {
    _initPref();
  }

  _initPref() {
    _mPref = SharedPreferences.getInstance();
  }

  Future<bool> setStringData(String key, String value) async {
    final SharedPreferences _prefs = await _mPref;
    return _prefs.setString(key, value);
  }

  Future<String> getStringData(String key) async {
    final SharedPreferences _prefs = await _mPref;
    return _prefs.getString(key);
  }

  Future<bool> isAppLaunch() async {
    final SharedPreferences _prefs = await _mPref;
    bool val = _prefs.getBool(PREF_IS_APP_LAUNCH);
    return val == null ? true : false;
  }

  Future<bool> setIsAppLaunch(bool isAppLaunch) async {
    final SharedPreferences _prefs = await _mPref;
    return _prefs.setBool(PREF_IS_APP_LAUNCH, isAppLaunch);
  }

  Future<bool> isUserLogin() async {
    return await getLoginUserId() != null;
  }

  Future<bool> setLoginUserEmail(String email) async {
    return setStringData(PREF_KEY_USERNAME, email);
  }

  Future<bool> setLoginUserId(String userId) async {
    return setStringData(PREF_KEY_USER_ID, userId);
  }

  Future<String> getLoginUserEmail() async {
    return getStringData(PREF_KEY_USERNAME);
  }

  Future<String> getLoginUserId() async {
    return getStringData(PREF_KEY_USER_ID);
  }

  Future<bool> logOutUser() async {
    bool isAppLaunchVar = await isAppLaunch();
    final SharedPreferences _prefs = await _mPref;
    _prefs.clear();
    return setIsAppLaunch(isAppLaunchVar);
  }

  Future<bool> setLoginToken(String loginToken) async {
    return setStringData(PREF_KEY_LOGIN_TOKEN, loginToken);
  }

  Future<String> getLoginToken() async {
    return getStringData(PREF_KEY_LOGIN_TOKEN);
  }

  Future<bool> setRefreshToken(String lastName) async {
    return setStringData(PREF_KEY_REFRESH_TOKEN, lastName);
  }

  Future<String> getRefreshToken() async {
    return getStringData(PREF_KEY_REFRESH_TOKEN);
  }

  Future<bool> setEntityType(String entityType) async {
    return setStringData(PREF_KEY_ENTITY_TYPE, entityType);
  }

  Future<String> getEntityType() async {
    return getStringData(PREF_KEY_ENTITY_TYPE);
  }

  Future<bool> setTenantId(String tenantId) async {
    return setStringData(PREF_KEY_TENANT_ID, tenantId);
  }

  Future<String> getTenantId() async {
    return getStringData(PREF_KEY_TENANT_ID);
  }

  Future<bool> setCustomerId(String customerId) async {
    return setStringData(PREF_KEY_CUSTOMER_ID, customerId);
  }

  Future<String> getCustomerId() async {
    return getStringData(PREF_KEY_CUSTOMER_ID);
  }

  Future<bool> setAuthority(String authority) async {
    return setStringData(PREF_KEY_AUTHORITY, authority);
  }

  Future<String> getAuthority() async {
    return getStringData(PREF_KEY_AUTHORITY);
  }

  Future<bool> setFirstName(String firstName) async {
    return setStringData(PREF_KEY_FIRST_NAME, firstName);
  }

  Future<String> getFirstName() async {
    return getStringData(PREF_KEY_FIRST_NAME);
  }

  Future<bool> setLastName(String lastName) async {
    return setStringData(PREF_KEY_LAST_NAME, lastName);
  }

  Future<String> getLastName() async {
    return getStringData(PREF_KEY_LAST_NAME);
  }

  Future<bool> setTenantToken(String lastName) async {
    return setStringData(PREF_KEY_TENANT_TOKEN, lastName);
  }

  Future<String> getTenantToken() async {
    return getStringData(PREF_KEY_TENANT_TOKEN);
  }

  Future<bool> setRefreshTenantToken(String lastName) async {
    return setStringData(PREF_KEY_REFRESH_TENANT_TOKEN, lastName);
  }

  Future<String> getRefreshTenantToken() async {
    return getStringData(PREF_KEY_REFRESH_TENANT_TOKEN);
  }

  Future<bool> setDefaultProfileId(String profileId) async {
    return setStringData(PREF_KEY_DEFAULT_PROFILE_ID, profileId);
  }

  Future<String> getDefaultProfileId() async {
    return getStringData(PREF_KEY_DEFAULT_PROFILE_ID);
  }

  Future<bool> saveRecentDeviceInfo(Username) async {
    final SharedPreferences _prefs = await _mPref;
    _prefs.setString(RECENT_PREF_KEY_USERNAME, Username);
    // _prefs.setString(RECENT_PREF_KEY_DEVICE_TOKEN, deviceToken);
    // _prefs.setString(RECENT_PREF_KEY_DEVICE_NAME, deviceName);
    return true;
  }

  Future<Map<String, String>> getRecentDeviceInfo() async {
    final SharedPreferences _prefs = await _mPref;
    String deviceId = _prefs.getString(RECENT_PREF_KEY_DEVICE_ID);
    String deviceToken = _prefs.getString(RECENT_PREF_KEY_DEVICE_TOKEN);
    String deviceName = _prefs.getString(RECENT_PREF_KEY_DEVICE_NAME);
    if (deviceName != null && deviceName.isNotEmpty) {
      return {
        "deviceId": deviceId,
        "deviceToken": deviceToken,
        "deviceName": deviceName
      };
    }
    return null;
  }

  Future<bool> saveWifiDetails(Map<String, dynamic> wifiInfo) async {
    final SharedPreferences _prefs = await _mPref;
    _prefs.setString(WIFI_PREF_KEY_WIFI_INFO, json.encode(wifiInfo));
    return true;
  }

  Future<Map<String, dynamic>> getWifiDetails() async {
    final SharedPreferences _prefs = await _mPref;
    String wifiPref = _prefs.getString(WIFI_PREF_KEY_WIFI_INFO);
    print(wifiPref);
    if (wifiPref != null) {
      Map<String, dynamic> wifi = json.decode(wifiPref);
      return wifi;
    }
    return null;
  }
}
