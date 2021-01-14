import 'dart:async';

 import 'package:drinkwater/screens/home_screen.dart';
import 'package:drinkwater/screens/login_screen.dart';
import 'package:drinkwater/screens/more_info.dart';
import 'package:drinkwater/utils/local_shared_preference.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final String login,info,home;

  const SplashScreen({@required this.login, @required this.info, @required this.home});


  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body:Image.asset("assets/splash_screen.png",fit: BoxFit.cover,width:width ,),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2),(){
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
        return getRoute(login:widget.login,info:widget.info,home:widget.home);
        return LoginScreen();
      }));
    });
  }

  Widget getRoute({String login, String info, String home}) {
//    return MoreInfo();
    if(home== HOME_SCREEN_VALUE){
      return HomeScreen();
    } if(info==INFORMATION_SCREEN_VALUE){
      return MoreInfo();
    }
    return LoginScreen();

  }
}
