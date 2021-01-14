import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drinkwater/extension/color_extension.dart';
import 'package:drinkwater/screens/main_screen_painter.dart';
import 'package:drinkwater/utils/local_shared_preference.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final assetsAudioPlayer = AssetsAudioPlayer();

  Map<String, String> ringTones = {
    "Cuckoo Clock": 'cuckoo_clock',
    "Moonless": 'moonless',
    "In a Hurry": 'in_a_hurry',
    "Loving You": 'loving_you',
    "Man Laughing": 'man_laughing',
    "Important Stuff": 'important_stuff',
    "Quest": 'quest',
  };
  bool notificationEnabled = true;
  bool _isLoading = true;
  String _selectedRingTone;

  FocusNode _notificationMessageNode = FocusNode();

//  FocusNode _notificationToneNode = FocusNode();

  ScrollController _scrollController;
  var _searchTextController = TextEditingController();
  int _selectedItem;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String sleepTime = "Sleep Time";
  String wakeupTime = "Wakeup Time";

  var _weightTextController = TextEditingController();
  var _workoutTimeTextController = TextEditingController();
  var _customTargetIntakeTextController = TextEditingController();
  var _notificationMessageTextController = TextEditingController();
  var _customIntakeController = TextEditingController();

  var initialIntake = 0;

  var _loadingValue = 0.0;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String liquidIntakeUnit = "";

  String solidIntakeUnit = "";

  num targetIntake = 0;

  String selectedTimer;

  /// The name associated with the UI isolate's [SendPort].
  String isolateName = 'isolate';

  /// A port used to communicate from a background isolate to the UI isolate.
  final ReceivePort port = ReceivePort();
  static SendPort uiSendPort;

  int selectedLiquidAmount = 0;

  String _customInputText = "Custom";

  @override
  void initState() {
    super.initState();

    AndroidAlarmManager.initialize();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//    setupNotification();
    setupLocalNotification();

    _notificationMessageNode.addListener(() {
      if (_notificationMessageNode.hasFocus) {
        _scrollController.position.animateTo(
            _scrollController.position.maxScrollExtent + 200,
            duration: Duration(milliseconds: 10),
            curve: Curves.linear);
        print("The notification got focus");
      } else {
        _scrollController.position.animateTo(
            _scrollController.position.minScrollExtent,
            duration: Duration(milliseconds: 10),
            curve: Curves.linear);

//        _notificationMessageController.reverse();
      }
    });
    /* _notificationToneNode.addListener(() {
      if (_notificationToneNode.hasFocus) {
        _scrollController.position.animateTo(
            _scrollController.position.maxScrollExtent + 260,
            duration: Duration(milliseconds: 10),
            curve: Curves.linear);
        print(
            "The notification got focus ${_scrollController.position.maxScrollExtent + 260}");
      } else {
        _scrollController.position.animateTo(
            _scrollController.position.minScrollExtent,
            duration: Duration(milliseconds: 10),
            curve: Curves.linear);
      }
    });*/
  }

  @override
  void dispose() {
    _notificationMessageNode.dispose();
//    _notificationToneNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final leftPadding = initialIntake.toString().length * 20;
    print("The size is $size");
    return Container(
      /* decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/main_screen_background.png",),
            fit: BoxFit.cover,
//            repeat: ImageRepeat.repeat
        ),
      ),*/

      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,

        bottomNavigationBar: _createBottomNavigationBar(context),
//            backgroundColor: Theme.of(context).primaryColor,
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : CustomPaint(
                painter: MainScreenPainter(size),
                child: Container(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _buildTitleAndSettingSection(context),
                      _buildSearchSection(context),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Daily Drink Target",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Stack(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "$initialIntake",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          Positioned(
                            left: leftPadding.toDouble(),
                            top: 12,
                            child: Text(
                              "/$targetIntake ${liquidIntakeUnit ?? "ml"}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 10,
                            child: LinearProgressIndicator(
                                value: _loadingValue,
                                semanticsLabel: "Progres",
                                semanticsValue: "100",
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.green[600])),
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 20,
                            child: Container(),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              "100",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                          Expanded(
                            flex: 14,
                            child: Container(),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      _buildWaterTarget(context)
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTitleAndSettingSection(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
//                mainAxisAlignment: MainAxisAlignment.start,

      children: <Widget>[
        Expanded(
          flex: 8,
          child: Text(
            "Daily Hand Wash Target",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        //todo replace with the logo of the app
//            IconButton(icon: Icon(Icons.check_circle),iconSize: 32, color: Theme.of(context).cardColor, onPressed: () {},),
        Expanded(
          flex: 1,
          child: RawMaterialButton(
            constraints: BoxConstraints(),
            padding: EdgeInsets.all(0.0),
            // optional, in order to add additional space around text if needed
            child: Image.asset(
              "assets/icons/tick_icon.png",
              fit: BoxFit.scaleDown,
              width: 32,
              height: 32,
            ),
            onPressed: () {},
          ),
        ),
        Expanded(
          flex: 4,
          child: RawMaterialButton(
            constraints: BoxConstraints(),
            padding: EdgeInsets.only(top: 28.0, left: 4),
            // optional, in order to add additional space around text if needed
            /*child: Image.asset(
              "assets/icons/setting.png",
              fit: BoxFit.scaleDown,
              width: 40,
              height: 40,
            ),*/
            child: Icon(
              Icons.settings,
              size: 40,
              color: Colors.white,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: _showBottomSheet,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(100.0))),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Container(
//      padding: EdgeInsets.all(16),
      padding: EdgeInsets.only(top: 16),
      child: TextField(
        controller: _searchTextController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: "Set Personal Alarm in min or hr/ day",
          labelText: "Personal Alarm",
//          labelStyle: TextStyle(color: Colors.[400]),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 0),
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0),
        ),
      ),
    );
  }

  Widget _buildWaterTarget(BuildContext context) {
    return Card(
      elevation: 15,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _buildCardItem1(context),
              _buildCardItem2(context),
              _buildCardItem3(context),
            ],
          ),
          Row(
            children: <Widget>[
              _buildCardItem4(context),
              _buildCardItem5(context),
              _buildCardItem6(context),
            ],
          ),
        ],
      ),
    );
  }

  updateInitialIntake(int intake) {
    var date = DateTime.now().toIso8601String();
    String dateKey = date.substring(0, 10);
    cache.setStringValue(dateKey, "$intake");
  }

  Widget _buildCardItem1(BuildContext context) {
    final width = MediaQuery.of(context).size.width -40;
    final height = MediaQuery.of(context).size.height - 40;
    print("Widths is ${width / 3} and height is ${height / 5}");
    return InkWell(
      onTap: () {
        this.setState(() {
          _selectedItem = 1;
          selectedLiquidAmount = 50;

          /*initialIntake = initialIntake + 50;
          _loadingValue = initialIntake / targetIntake;*/
        });
//        updateInitialIntake(initialIntake);
      },
      child: Card(
        margin: EdgeInsets.all(0),
        elevation: 50,
        color: Colors.white,
        child: Container(
          height: height / 5,
          width: width / 3,
          decoration: BoxDecoration(
              gradient: _selectedItem == 1
                  ? LinearGradient(
                      colors: <Color>[startColorGradient, Colors.white],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    )
                  : null),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              /*Icon(
                Icons.border_bottom,
                color: Colors.green,
              ),*/
              Image.asset(
                "assets/icons/glass1.png",
                fit: BoxFit.contain,
                width: 40,
                height: 40,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "50 ml",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _showCustomIntakeDialog() async {
    _customIntakeController.text = "";
    await showDialog<String>(
      context: context,
      builder: (BuildContext contxt) {
        return new AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  controller: _customIntakeController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: new InputDecoration(
                      labelText: 'Custom intake', hintText: '30 ml'),
                ),
              )
            ],
          ),
          actions: <Widget>[
            new FlatButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
//                  return int.tryParse(_customIntakeController.text);
                }),
            new FlatButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
//                  return 0;
                })
          ],
        );
      },
    );
  }

  Widget _buildCardItem2(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 40;
    final height = MediaQuery.of(context).size.height - 40;
    print("Widths is ${width / 3} and height is ${height / 5}");
    return InkWell(
      onTap: () {
        this.setState(() {
          _selectedItem = 2;
          selectedLiquidAmount = 100;

          /*initialIntake = initialIntake + 100;
          _loadingValue = initialIntake / targetIntake;*/
        });
//        updateInitialIntake(initialIntake);
      },
      child: Card(
        margin: EdgeInsets.all(0),
        elevation: 50,
        color: Colors.white,
        child: Container(
          height: height / 5,
          width: width / 3,
          decoration: BoxDecoration(
              gradient: _selectedItem == 2
                  ? LinearGradient(
                      colors: <Color>[startColorGradient, Colors.white],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    )
                  : null),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/icons/glass2.png",
                fit: BoxFit.contain,
                width: 48,
                height: 48,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "100 ml",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardItem3(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 40;
    final height = MediaQuery.of(context).size.height - 40;
    print("Widths is ${width / 3} and height is ${height / 5}");
    return InkWell(
      onTap: () {
        this.setState(() {
          selectedLiquidAmount = 150;

          _selectedItem = 3;
          /*initialIntake = initialIntake + 150;
          _loadingValue = initialIntake / targetIntake;*/
        });
//        updateInitialIntake(initialIntake);
      },
      child: Card(
        margin: EdgeInsets.all(0),
        elevation: 50,
        color: Colors.white,
        child: Container(
          height: height / 5,
          width: width / 3,
          decoration: BoxDecoration(
              gradient: _selectedItem == 3
                  ? LinearGradient(
                      colors: <Color>[startColorGradient, Colors.white],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    )
                  : null),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/icons/glass3.png",
                fit: BoxFit.contain,
                width: 56,
                height: 56,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "150 ml",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardItem4(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 40;
    final height = MediaQuery.of(context).size.height - 40;
    print("Widths is ${width / 3} and height is ${height / 5}");
    return InkWell(
      onTap: () {
        this.setState(() {
          _selectedItem = 4;
          selectedLiquidAmount = 200;
          /*initialIntake = initialIntake + 200;
          _loadingValue = initialIntake / targetIntake;*/
        });
//        updateInitialIntake(initialIntake);
      },
      child: Card(
        margin: EdgeInsets.all(0),
        elevation: 50,
        color: Colors.white,
        child: Container(
          height: height / 5,
          width: width / 3,
          decoration: BoxDecoration(
              gradient: _selectedItem == 4
                  ? LinearGradient(
                      colors: <Color>[startColorGradient, Colors.white],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    )
                  : null),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              /* Icon(
                Icons.border_bottom,
                color: Colors.green,
              ),*/
              Image.asset(
                "assets/icons/glass4.png",
                fit: BoxFit.contain,
                width: 64,
                height: 64,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "200 ml",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardItem5(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 40;
    final height = MediaQuery.of(context).size.height - 40;
    print("Widths is ${width / 3} and height is ${height / 5}");
    return InkWell(
      onTap: () {
        this.setState(() {
          _selectedItem = 5;
          selectedLiquidAmount = 250;
          /*  initialIntake = initialIntake + 250;
          _loadingValue = initialIntake / targetIntake;*/
        });
//        updateInitialIntake(initialIntake);
      },
      child: Card(
        margin: EdgeInsets.all(0),
        elevation: 50,
        color: Colors.white,
        child: Container(
          height: height / 5,
          width: width / 3,
          decoration: BoxDecoration(
              gradient: _selectedItem == 5
                  ? LinearGradient(
                      colors: <Color>[startColorGradient, Colors.white],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    )
                  : null),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/icons/glass5.png",
                fit: BoxFit.contain,
                width: 72,
                height: 72,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "250 ml",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardItem6(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 40;
    final height = MediaQuery.of(context).size.height - 40;
    print("Widths is ${width / 3} and height is ${height / 5}");
    return InkWell(
      onTap: () async {
        await _showCustomIntakeDialog();

        int intake = int.tryParse(_customIntakeController.text) ?? 0;
        this.setState(() {
          _selectedItem = 6;
          selectedLiquidAmount = intake;
          _customInputText= "$intake ml";
          /*  initialIntake = initialIntake + intake;
          _loadingValue = initialIntake / targetIntake;*/
        });
//        updateInitialIntake(initialIntake);
      },
      child: Card(
        margin: EdgeInsets.all(0),
        elevation: 50,
        color: Colors.white,
        child: Container(
          height: height / 5,
          width: width / 3,
          decoration: BoxDecoration(
              gradient: _selectedItem == 6
                  ? LinearGradient(
                      colors: <Color>[startColorGradient, Colors.white],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    )
                  : null),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/icons/glass_custom.png",
                fit: BoxFit.contain,
                width: 80,
                height: 80,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                _customInputText,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createBottomNavigationBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FlatButton(
//            color: Theme.of(context).primaryColor,
            child: notificationEnabled
                ? Image.asset(
                    "assets/icons/bell.png",
                    fit: BoxFit.contain,
                    width: 64,
                    height: 64,
                  )
                : Image.asset(
                    "assets/icons/bell_crossed.png",
                    fit: BoxFit.contain,
                    width: 64,
                    height: 64,
                  ),
//            child: Icon(Icons.notifications_none,color: Theme.of(context).primaryColor,size: 48,),
            onPressed: () {
//              Fluttertoast.showToast(msg: "Notification ${notificationEnabled? "Enabled":"Disabled"}",gravity: ToastGravity.TOP);

              this.setState(() {
                notificationEnabled = !notificationEnabled;
              });
              print("The notificationEnabled value is $notificationEnabled");
              if (notificationEnabled) {
                print("All notification are enabled");

                sendNotification();
              } else {
                print("All notification are cancelled");
                flutterLocalNotificationsPlugin.cancelAll();
              }

              cache.setBoolValue(NOTIFICATION_ENABLED, notificationEnabled);
            },
          ),
          FlatButton(
//            color: Theme.of(context).primaryColor,
            child: Image.asset(
              "assets/icons/plus_icon.png",
              fit: BoxFit.contain,
              width: 64,
              height: 64,
            ),
            onPressed: () {
              this.setState(() {
                initialIntake = initialIntake + selectedLiquidAmount;
                _loadingValue = initialIntake / targetIntake;
              });
              updateInitialIntake(initialIntake);
            },
          ),
          FlatButton(
//            color: Theme.of(context).primaryColor,
            child: Image.asset(
              "assets/icons/screen_icon.png",
              fit: BoxFit.contain,
              width: 64,
              height: 64,
            ),
            onPressed: () {
              print("This is called here the monitor button");
              showModalBottomSheet(
                context: context,
                builder: _showBottomSheet,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(100.0))),
              );
//              _showBottomSheet(context);
            },
          ),
        ],
      ),
    );
  }


  Widget _buildWorkoutTimeDropDown(BuildContext context) {
    List<int> list = List.generate(5, (i) => 30 *(i+1));
    list.remove(90);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(left: 20.0, right: 20,),

          child: Text(
            "Your daily workout time",
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.only(left: 20.0, right: 20,top: 16,bottom: 16),
          margin: EdgeInsets.only(left: 20.0, right: 20,),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10)),
          child: StatefulBuilder(
            builder: (BuildContext context, newState) {
              return DropdownButton(
                iconEnabledColor: Theme.of(context).primaryColor,
                isDense: true,
                elevation: 12,
                isExpanded: true,
                focusColor: Colors.white,
                hint: Text("Time"),

                value:  _workoutTimeTextController.text.isEmpty
                    ? null
                    : _workoutTimeTextController.text,
                items: <DropdownMenuItem>[
                  ...list.map((t) {
                    return DropdownMenuItem(

                      value: t.toString(),
                      child: Text("$t minutes"),
                    );
                  })
                ],
                onChanged: (value) {
                  print("The dropdown value is $value");
                  newState(() {
                    _workoutTimeTextController.text = value.toString();
                  });
                },
              );
            },
          ),
        ),
      ],
    );

  }


  Widget _buildWeightDropDown(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(left: 20.0, right: 20,),

          child: Text(
            "Your Weight",
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.only(left: 20.0, right: 20,top: 16,bottom: 16),
          margin: EdgeInsets.only(left: 20.0, right: 20,),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10)),
          child: StatefulBuilder(
            builder: (BuildContext context, newState) {
              return DropdownButton(
                iconEnabledColor: Theme.of(context).primaryColor,
                isDense: true,
                elevation: 12,
                isExpanded: true,
                focusColor: Colors.white,
                hint: Text("Weight"),
                value: _weightTextController.text.isEmpty
                    ? null
                    : _weightTextController.text,
                items: <DropdownMenuItem>[
                  ...List.generate(101, (i) => 50 + i).map((t) {
                    return DropdownMenuItem(

                      value: t.toString(),
                      child: Text("$t k.g"),
                    );
                  })
                ],
                onChanged: (value) {
                  print("The dropdown value is $value");
                  newState(() {
                    _weightTextController.text = value.toString();
                  });
                },
              );
            },
          ),
        ),
      ],
    );

  }




  Widget _showBottomSheet(BuildContext context) {
    _scrollController = ScrollController(initialScrollOffset: 0);

    return ListView(
      controller: _scrollController,
      shrinkWrap: true,
      children: <Widget>[
        Container(
          color: Theme.of(context).primaryColor,
          padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildUpdateButton(context),
              _buildWeightDropDown(context),
              _buildWorkoutTimeDropDown(context),
              /*_buildWeightTextField("Enter your weight in kg", "75 k.g",
                  type: TextInputType.number,
                  controller: _weightTextController),*/
              /*_buildWeightTextField(
                  "Your daily workout time in min/day", "30 minutes",
                  type: TextInputType.number,
                  controller: _workoutTimeTextController),*/
              _buildWakeupTimeSleepTime(context),
              _buildWeightTextField(
                  "Enter your custom target intake in ml", "30 ml",
                  type: TextInputType.number,
                  controller: _customTargetIntakeTextController),
              buildNotificationSettingText(context),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: _buildNotificationMessageTextField(
                        "Notification Message",
                        "Your custom notification message",
                        context,
                        focusNode: _notificationMessageNode,
                        controller: _notificationMessageTextController),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Card(
                      margin: EdgeInsets.only(
                        left: 20.0,
                        top: 10.0,
                        right: 20,
                      ),
                      elevation: 10,
                      child: Container(
                          padding: EdgeInsets.only(
                            left: 20.0,
                            top: 10.0,
                            right: 20,
                          ),
                          alignment: Alignment.topCenter,
                          child: StatefulBuilder(
                            builder: (BuildContext context, newState) {
                              return ListTile(
                                onTap: () {
                                  _onRingToneSelected(context, newState);
                                },
                                contentPadding: EdgeInsets.all(0),
                                title: Text(_selectedRingTone ??
                                    "No ringtone selected"),
                                trailing: Icon(Icons.audiotrack),
                              );
                            },
                          )
                          /* StatefulBuilder(
                          builder: (BuildContext context, newState) {
                            return DropdownButton<String>(
                              isExpanded: true,
                              isDense: false,
                              value: _selectedRingTone,
                              elevation: 12,
                              hint: Text("Select your custom ringtone"),
                              items: ringTones.keys.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String value) {
                                newState(() {
                                  _selectedRingTone = value;
                                });
                                cache.setStringValue(
                                    CUSTOM_NOTIFICATION_TONE_KEY, value);
                              },
                            );
                          },
                        ),*/
                          ),
                    ),
                    /*Flexible(
                    fit: FlexFit.loose,
                    child: _buildNotificationMessageTextField(
                        "Notification Tone",
                        "Your custome notification tone",
                        context,
                        focusNode: _notificationToneNode,
                        controller: _notificationToneTextController),
                  ),*/
                  ),
                  Flexible(
                    child: _showClockSection(context),
                    fit: FlexFit.loose,
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalogClock(
      BuildContext context, String iconPath, String duration) {
    print("The selected timer is $selectedTimer");
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: SizedBox(
        width: 25,
        height: 25,
        child: Image.asset(
          iconPath,
          fit: BoxFit.contain,
          width: 25,
          height: 24,
        ),
      ),
    );
  }

  Widget _showClockSection(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(left: 20.0, top: 20.0, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                cache.setStringValue(
                    CUSTOM_NOTIFICATION_DURATION_MESSAGE_KEY, "60");
                this.setState(() {
                  selectedTimer = "60";
                });
              },
              child: Container(
                color: selectedTimer == "60" ? Colors.blue[200] : Colors.white,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    _buildAnalogClock1(
                        context, "assets/icons/60mins.png", "60"),
                    Text(
                      "60 Mins |",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                cache.setStringValue(
                    CUSTOM_NOTIFICATION_DURATION_MESSAGE_KEY, "120");
                this.setState(() {
                  selectedTimer = "120";
                });
              },
              child: Container(
                color: selectedTimer == "120" ? Colors.blue[200] : Colors.white,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildAnalogClock2(context, "assets/icons/2hrs.png", "120"),
                    Text(
                      "2 Hours |",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                print("The selected timer is $selectedTimer");

                cache.setStringValue(
                    CUSTOM_NOTIFICATION_DURATION_MESSAGE_KEY, "180");
                this.setState(() {
                  selectedTimer = "180";
                });
              },
              child: Container(
                color: selectedTimer == "180" ? Colors.blue[200] : Colors.white,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildAnalogClock(context, "assets/icons/3hrs.png", "180"),
                    Text(
                      "3 Hours",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationMessageTextField(
      String labelText, String hintText, BuildContext context,
      {TextInputType type = TextInputType.text,
      bool obscure = false,
      @required FocusNode focusNode,
      @required TextEditingController controller}) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.0,
        top: 10.0,
        right: 20,
      ),
      child: TextField(
        focusNode: focusNode,
        obscureText: obscure,
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
          labelText: labelText,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 0),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget buildNotificationSettingText(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColor,
      margin: EdgeInsets.only(top: 10, left: 16, right: 16),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0))),
      child: Container(
        width: double.infinity,
        alignment: Alignment.topCenter,
        child: Text(
          "Notification Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        padding: EdgeInsets.all(8),
      ),
    );
  }

  _pickWakeupTime(newState) {
    return DatePicker.showTime12hPicker(context, showTitleActions: true,
        onChanged: (date) {
      print('change $date');
    }, onConfirm: (DateTime date) {
      String stringDate = date.toIso8601String();
      int hour = date.hour;
      String val = hour > 12 ? "PM" : "AM";
      if (hour > 12) hour = hour - 12;
      newState(() {
        wakeupTime =
            "${hour == 0 ? "12" : "$hour"}${stringDate.substring(13, 16)} $val";
      });
      print('confirm $date');
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  Widget _buildWakeupTimeButton(BuildContext context) {
    return StatefulBuilder(builder: (BuildContext context, newState) {
      return Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16),
        width: double.infinity,
        child: MaterialButton(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          minWidth: double.infinity,
          elevation: 4,
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () {
            _pickWakeupTime(newState);
          },
          child: Text(
            wakeupTime,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    });
  }

  Widget _buildWakeupTimeSleepTime(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 4,
          child: _buildWakeupTimeButton(context),
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
        Expanded(
          flex: 4,
          child: _buildSleepTimeButton(context),
        ),
      ],
    );
  }

  Widget _buildSleepTimeButton(BuildContext context) {
    return StatefulBuilder(builder: (BuildContext context, newState) {
      return Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16),
        width: double.infinity,
        alignment: Alignment.center,
        child: MaterialButton(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          minWidth: double.infinity,
          elevation: 4,
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () {
            _pickSleepTime(newState);
          },
          child: Text(
            sleepTime,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    });
  }

  _pickSleepTime(newState) {
    return DatePicker.showTime12hPicker(context, showTitleActions: true,
        onChanged: (date) {
      print('change $date');
    }, onConfirm: (DateTime date) {
      String stringDate = date.toIso8601String();
      int hour = date.hour;
      String val = hour > 12 ? "PM" : "AM";
      if (hour > 12) hour = hour - 12;
      newState(() {
        sleepTime =
            "${hour == 0 ? "12" : "$hour"}${stringDate.substring(13, 16)} $val";
      });

      print('confirm $date');
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  Widget _buildWeightTextField(String labelText, String hintText,
      {TextInputType type = TextInputType.text,
      bool obscure = false,
      @required TextEditingController controller}) {
    return Container(
      padding: EdgeInsets.only(
        left: 20.0,
        top: 10.0,
        right: 20,
      ),

      child: Theme(
        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
        child: TextField(
          autofocus: false,
          obscureText: obscure,
          keyboardType: type,
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hintText,
            labelText: labelText,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 0),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
//      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FlatButton(
          padding: EdgeInsets.zero,
          child: Row(
            children: <Widget>[
              Text(
                "Update ",
                style: TextStyle(color: Colors.white),
              ),
              Image.asset(
                "assets/icons/tick_icon.png",
                fit: BoxFit.scaleDown,
                width: 32,
                height: 32,
              ),
            ],
          ),
          onPressed: () {
            if (!validateInput()) {
              Fluttertoast.showToast(msg: "Please enter the valid terms");
              return;
            }
            setValues();

            if (notificationEnabled) {
              sendNotification();
            } else {
              Fluttertoast.showToast(
                  msg: "Notifications are currently disabled");
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

/*
  void setupNotification() async {
    final String token = await _firebaseMessaging.getToken();
    print("The firebase token is $token");
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showNotification(message);
//       _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        showNotification(message);

//       _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        showNotification(message);

//       _navigateToItemDetail(message);
      },
    );
  }
*/

  void setupLocalNotification() async {
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);

    _initialize();

  }

  Future sendNotification() async {
    await cache.reload();
    String toneKey = await cache.getStringValue(CUSTOM_NOTIFICATION_TONE_KEY);
    print("The ringtone key is  $toneKey");

    String ringTone = ringTones[toneKey];
    print("The ringtone is $ringTone");
    var androidChannel = AndroidNotificationDetails(
        'channel-id', 'channel-name', 'channel-description',
        importance: Importance.Max,
        priority: Priority.Max,
        sound: RawResourceAndroidNotificationSound(ringTone));

    var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(androidChannel, iosChannel);

    flutterLocalNotificationsPlugin.cancelAll();
    int hashcode = 98123871;
    String message = "Let\s' wash our hands";
    String subtext =
        await cache.getStringValue(CUSTOM_NOTIFICATION_MESSAGE_KEY) ??
            "It\s' probably time to wash your hands ";
    String duration =
        await cache.getStringValue(CUSTOM_NOTIFICATION_DURATION_MESSAGE_KEY);

    RepeatInterval interval;
    switch (duration) {
      case "60":
        {
          interval = RepeatInterval.Hourly;
          break;
        }
      case "90":
        {
          interval = RepeatInterval.Every90Minutes;
          break;
        }
      case "120":
        {
          interval = RepeatInterval.Every120Minutes;
          break;
        }
      case "180":
        {
          interval = RepeatInterval.Every180Minutes;
          break;
        }
      default:
        interval = RepeatInterval.Every15Minutes;
    }
    print("The duration for message sending is $interval");

//    interval = RepeatInterval.Every90Seconds;

    flutterLocalNotificationsPlugin.periodicallyShow(
      hashcode,
      message,
      subtext,
      interval,
      platformChannel,
      payload: hashcode.toString(),
    );
    print("The notification should be arrieved by now");
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);
  }

  showNotification(Map<String, dynamic> payload) async {
    print("The notification I get here is $payload");
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'Handwash Reminder',
        'Maybe it\'s time to wash your hand', platformChannelSpecifics,
        payload: 'item x');
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {}

  void _initialize() async {
    notificationEnabled =
        await cache.getBoolValue(NOTIFICATION_ENABLED) ?? true;
    if (notificationEnabled) {
      sendNotification();
    }
    _selectedRingTone =
        await cache.getStringValue(CUSTOM_NOTIFICATION_TONE_KEY);
    print("The notification value enabled ${notificationEnabled}");

    if (_selectedRingTone.isEmpty) {
      _selectedRingTone = null;
    }

    _weightTextController.text = await cache.getStringValue(CUSTOM_WEIGHT_KEY);
    _workoutTimeTextController.text =
        await cache.getStringValue(CUSTOM_WORKOUT_KEY);
    _customTargetIntakeTextController.text =
        await cache.getStringValue(CUSTOM_INTAKE_KEY);
    _notificationMessageTextController.text =
        await cache.getStringValue(CUSTOM_NOTIFICATION_MESSAGE_KEY);
    _searchTextController.text =
        await cache.getStringValue(CUSTOM_NOTIFICATION_MESSAGE_KEY);
    /*_notificationToneTextController.text =
        await cache.getStringValue(CUSTOM_NOTIFICATION_TONE_KEY);*/

    var date = DateTime.now().toIso8601String();
    String dateKey = date.substring(0, 10);
    initialIntake = int.tryParse(await cache.getStringValue(dateKey)) ?? 0;
    liquidIntakeUnit = await cache.getStringValue(LIQUID_UNIT_KEY);
    solidIntakeUnit = await cache.getStringValue(SOLID_UNIT_KEY);
    sleepTime = await cache.getStringValue(SLEEP_TIME_KEY);
    wakeupTime = await cache.getStringValue(WAKEUP_TIME_KEY);
    targetIntake =
        num.tryParse(await cache.getStringValue(CUSTOM_INTAKE_KEY)) ?? 0;
    _isLoading = false;
    selectedTimer =
        await cache.getStringValue(CUSTOM_NOTIFICATION_DURATION_MESSAGE_KEY);
    this.setState(() {});
  }

  bool validateInput() {
    if (_weightTextController.text.isEmpty ||
        _workoutTimeTextController.text.isEmpty ||
        _customTargetIntakeTextController.text.isEmpty ||
        _notificationMessageTextController.text.isEmpty) {
      return false;
    }
    if (sleepTime.isEmpty || wakeupTime.isEmpty) {
      return false;
    }
    return true;
  }

  void setValues() {
    _searchTextController.text= _notificationMessageTextController.text;
    cache.setStringValue(CUSTOM_WEIGHT_KEY, _weightTextController.text);

    cache.setStringValue(CUSTOM_WORKOUT_KEY, _workoutTimeTextController.text);
    cache.setStringValue(
        CUSTOM_INTAKE_KEY, _customTargetIntakeTextController.text);

    cache.setStringValue(CUSTOM_NOTIFICATION_MESSAGE_KEY,
        _notificationMessageTextController.text);

    cache.setStringValue(SLEEP_TIME_KEY, sleepTime);
    cache.setStringValue(WAKEUP_TIME_KEY, wakeupTime);

    this.setState(() {
      targetIntake = int.tryParse(_customTargetIntakeTextController.text) ?? 0;
    });
  }

  Widget _buildAnalogClock1(BuildContext context, String s, String t) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: SizedBox(
        width: 25,
        height: 25,
        child: Image.asset(
          "assets/icons/60mins.png",
          fit: BoxFit.contain,
          width: 25,
          height: 24,
        ),
      ),
    );
  }

  Widget _buildAnalogClock2(BuildContext context, String s, String t) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: SizedBox(
        width: 25,
        height: 25,
        child: Image.asset(
          "assets/icons/60mins.png",
          fit: BoxFit.contain,
          width: 25,
          height: 24,
        ),
      ),
    );
  }


  void _onRingToneSelected(BuildContext context, otherState) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // StatefulBuilder
          builder: (context, newState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              elevation: 10,
              contentPadding: EdgeInsets.all(32),
              title: Text("Your Custom Ringtone"),
              actions: <Widget>[
                Container(
                    width: 300,
                    child: Column(
//                      shrinkWrap: true,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ...ringTones.keys.map((t) {
                          return RadioListTile<String>(
                            title: Text("$t.mp3"),
                            dense: true,
                            activeColor: primaryColor,
                            selected: _selectedRingTone == t,
                            value: t,
                            groupValue: _selectedRingTone,
                            onChanged: (String value) {
                              newState(() {
                                _selectedRingTone = t;
                              });
                              setState(() {
                                _selectedRingTone = t;
                              });
                              otherState(() {
                                _selectedRingTone = t;
                              });
                              playThisAudio(t);

                            },
                          );
                        }).toList(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Material(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              elevation: 5.0,
                              color: primaryColor,
                              child: MaterialButton(
                                padding:
                                    EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                onPressed: () {
                                  cache.setStringValue(
                                      CUSTOM_NOTIFICATION_TONE_KEY, _selectedRingTone);
                                  assetsAudioPlayer.stop();
                                  Navigator.of(context).pop();
                                },
                                child: Text("Done",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    )),
                              ),
                            ),
                          ],
                        )
                      ],
                    ))
              ],
            );
          },
        );
      },
    );
  }

  void playThisAudio(String t) {

    String rawName = ringTones[t];
    String source = "assets/audio/$rawName.mp3";
    print("The audio name $t and raw name $t and source is $source");

    assetsAudioPlayer.open(
      Audio(source),
    );
  }
}
