import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings>
    with SingleTickerProviderStateMixin {
  FocusNode _notificationMessageNode = FocusNode();
  FocusNode _notificationToneNode = FocusNode();

  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _notificationMessageNode.addListener(() {
      if (_notificationMessageNode.hasFocus) {
        _scrollController.position.animateTo(
            _scrollController.position.maxScrollExtent,
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
    _notificationToneNode.addListener(() {
      if (_notificationToneNode.hasFocus) {
        _scrollController.position.animateTo(
            _scrollController.position.maxScrollExtent+20,
            duration: Duration(milliseconds: 10),
            curve: Curves.linear);
        print("The notification got focus");
      } else {
        _scrollController.position.animateTo(
            _scrollController.position.minScrollExtent,
            duration: Duration(milliseconds: 10),
            curve: Curves.linear);
      }
    });
  }

  @override
  void dispose() {
    _notificationMessageNode.dispose();
    _notificationToneNode.dispose();
    super.dispose();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var _weightTextController = TextEditingController();

  var _workoutTimeTextController = TextEditingController();

  String sleepTime = "Sleep Time";
  String wakeupTime = "Wakeup Time";

  var _customTargetIntakeTextController = TextEditingController();

  var _notificationMessageTextController = TextEditingController();

  var _notificationToneTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: true,
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Settings"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.slideshow),
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
          ],
        ),
        body: Center(
          child: Text(
           "60 MINS",

          ),
        ));
  }

  Widget _showBottomSheet(BuildContext context) {
    _scrollController = ScrollController(initialScrollOffset: 0);

    return ListView(
      controller: _scrollController,
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
              _buildWeightTextField("Enter your weight in kgs", "75 k.g",
                  type: TextInputType.number,
                  controller: _weightTextController),
              _buildWeightTextField(
                  "Your daily workout time in min/day", "30 minutes",
                  type: TextInputType.number,
                  controller: _workoutTimeTextController),
              _buildWakeupTimeSleepTime(context),
              _buildWeightTextField(
                  "Enter your custom target intake in ml", "30 ml",
                  type: TextInputType.number,
                  controller: _customTargetIntakeTextController),
              buildNotificationSettingText(context),
              _buildNotificationMessageTextField("Notification Message",
                  "Your custom notification message", context,
                  focusNode: _notificationMessageNode,
                  controller: _notificationMessageTextController),
              _buildNotificationMessageTextField( "Notification Tone", "Your custome notification tone", context,
                  focusNode: _notificationToneNode,
                  controller: _notificationToneTextController),

              _showClockSection(context)
            ],
          ),
        ),
      ],
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
              Icon(
                Icons.check_circle,
                color: Colors.white,
              )
            ],
          ),
          onPressed: () {
          },
        ),
      ],
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

  Widget _buildWeightTextField(String labelText, String hintText,
      {TextInputType type = TextInputType.text,
      bool obscure = false,
      @required TextEditingController controller}) {
    return Container(
      padding: EdgeInsets.only(
        left: 20.0, top: 10.0, right: 20,
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

  Widget _buildWakeupTimeSleepTime(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: _buildWakeupTimeButton(context),
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
        Expanded(
          flex: 3,
          child: _buildSleepTimeButton(context),
        ),
      ],
    );
  }

  Widget _buildSleepTimeButton(BuildContext context) {
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
          _pickSleepTime();
        },
        child: Text(
          sleepTime,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildWakeupTimeButton(BuildContext context) {
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
          _pickWakeupTime();
        },
        child: Text(
          wakeupTime,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  _pickWakeupTime() {
    return DatePicker.showTime12hPicker(context, showTitleActions: true,
        onChanged: (date) {
      print('change $date');
    }, onConfirm: (DateTime date) {
      String stringDate = date.toIso8601String();
      int hour = date.hour;
      String val = hour > 12 ? "PM" : "AM";
      if (hour > 12) hour = hour - 12;
      this.setState(() {
        wakeupTime =
            "${hour == 0 ? "12" : "$hour"}${stringDate.substring(13, 16)} $val";
      });
      print('confirm $date');
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  _pickSleepTime() {
    return DatePicker.showTime12hPicker(context, showTitleActions: true,
        onChanged: (date) {
      print('change $date');
    }, onConfirm: (DateTime date) {
      String stringDate = date.toIso8601String();
      int hour = date.hour;
      String val = hour > 12 ? "PM" : "AM";
      if (hour > 12) hour = hour - 12;
      this.setState(() {
        sleepTime =
            "${hour == 0 ? "12" : "$hour"}${stringDate.substring(13, 16)} $val";
      });

      print('confirm $date');
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  Widget _showClockSection(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(left: 20.0, top: 20.0, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _buildAnalogClock(context, "60"),
          Text(
            "60 Mins |",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          _buildAnalogClock(context, "2 hrs"),
          Text(
            "2 Hours |",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          _buildAnalogClock(context, "3 hrs"),
          Text(
            "3 Hours",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalogClock(BuildContext context, String s) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: SizedBox(
        width: 25,
        height: 25,
        child: Text( s,
        ),
      ),
    );
  }
}
