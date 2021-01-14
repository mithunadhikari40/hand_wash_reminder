import 'dart:isolate';
import 'dart:ui';

import 'package:drinkwater/extension/color_extension.dart';
import 'package:drinkwater/screens/splash_screen.dart';
import 'package:drinkwater/utils/local_shared_preference.dart';
import 'package:flutter/material.dart';

/// The [SharedPreferences] key to access the alarm fire count.
const String countKey = 'count';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );
  String login = await cache.getStringValue(LOGIN_SCREEN_KEY);
  String info = await cache.getStringValue(INFORMATION_SCREEN_KEY);
  String home = await cache.getStringValue(HOME_SCREEN_KEY);
  runApp(MyApp(login:login,info:info,home:home));
}

class MyApp extends StatelessWidget {
  final String login,info,home;

  const MyApp({@required this.login, @required this.info, @required this.home});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.green[500],
      title: "Handwash Reminder",
      theme: ThemeData(primaryColor: primaryColor,
          fontFamily: 'Schyler',
          bottomAppBarColor: Colors.white
      ),
      home: SplashScreen(login:login,info:info,home:home),
    );
  }



}
