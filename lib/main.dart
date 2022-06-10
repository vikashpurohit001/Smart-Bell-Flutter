import 'dart:async';
import 'dart:io';

import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:smart_bell/util/SessionManager.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // await Firebase.initializeApp();
    // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    // RestServerApi().getTenantAuthToken();
    // final _isAuthenticated = await new SessionManager().isUserLogin();
    final Map<String, dynamic> recentDevice =
        await SessionManager().getRecentDeviceInfo();
    if (Platform.isIOS) {
      DartPingIOS.register();
    }
    runApp(MyApplication(recentDevice));
  }, (error, stackTrace) {
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}
