import 'package:drinkwater/extension/color_extension.dart';
import 'package:drinkwater/screens/home_screen.dart';
import 'package:drinkwater/utils/local_shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MoreInfo extends StatefulWidget {
  @override
  _MoreInfoState createState() => _MoreInfoState();
}

/*enum UNIT_LIQUID { fl, ml }
enum UNIT_SOLID { lbs, kg }*/

class _MoreInfoState extends State<MoreInfo> {
  String liquidUnit;
  String solidUnit;
  String sleepTime = "Sleep Time";
  String wakeupTime = "Wakeup Time";

  var _weightTextFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        padding: EdgeInsets.all(16),
        child: _buildMoreInfoScreen(),
      ),
    );
  }

  Widget _buildMoreInfoScreen() {
    return ListView(
      shrinkWrap: true,
//    mainAxisSize: MainAxisSize.min,
//      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildContinueButton(context),
        SizedBox(
          height: 20,
        ),
        Text(
          "Can you please provide these information to help customize the experience for you?",
          textAlign: TextAlign.start,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Divider(
                height: 5,
                thickness: 6,
                color: Colors.white,
              ),
            ),
            Expanded(
              flex: 10,
              child: Container(),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          width: double.infinity,
          child: Text(
            "Choose unit",
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: _buildUnitFlButton(context),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 2,
              child: _buildUnitMlButton(context),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: _buildUnitPoundsButton(context),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 2,
              child: _buildUnitKgButton(context),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          width: double.infinity,
          child: Text(
            "Weight",
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        _buildWeightTextField(context),
        SizedBox(
          height: 20,
        ),
        Container(
          width: double.infinity,
          child: Text(
            "Wake up and sleep time",
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        Row(
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
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget _buildUnitMlButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      width: double.infinity,
      alignment: Alignment.center,
      child: MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        minWidth: double.infinity,
        elevation: 4,
        color: liquidUnit == "ml"
            ? loginButtonColor
            : Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onPressed: () {
          this.setState(() {
            liquidUnit = "ml";
          });
        },
        child: Text(
          "ml",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildUnitFlButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      width: double.infinity,
      alignment: Alignment.center,
      child: MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        minWidth: double.infinity,
        elevation: 4,
        color: liquidUnit == "fl"
            ? loginButtonColor
            : Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onPressed: () {
          this.setState(() {
            liquidUnit = "fl";
          });
        },
        child: Text(
          "fl oz",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildUnitPoundsButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      width: double.infinity,
      alignment: Alignment.center,
      child: MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        minWidth: double.infinity,
        elevation: 4,
        color: solidUnit == "lbs"
            ? loginButtonColor
            : Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onPressed: () {
          this.setState(() {
            solidUnit = "lbs";
          });
        },
        child: Text(
          "lbs",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildUnitKgButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      width: double.infinity,
      alignment: Alignment.center,
      child: MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        minWidth: double.infinity,
        elevation: 4,
        color: solidUnit == "kg"
            ? loginButtonColor
            : Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onPressed: () {
          this.setState(() {
            solidUnit = "kg";
          });
        },
        child: Text(
          "kg",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildWeightTextField(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20.0, right: 20,top: 16,bottom: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10)),
      child: StatefulBuilder(

        builder: (BuildContext context, newState) {
          return DropdownButton(

//icon: Container(),
          iconEnabledColor: Theme.of(context).primaryColor,
            isDense: true,
//        style: TextStyle(color: Colors.white,fontSize: 18),
            elevation: 12,
            isExpanded: true,
            focusColor: Colors.white,

            hint: Text("Weight"),
            value: _weightTextFieldController.text.isEmpty
                ? null
                : _weightTextFieldController.text,
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
                _weightTextFieldController.text = value.toString();
              });
            },
          );
        },
      ),
    );

    return Container(
      padding: EdgeInsets.only(left: 20.0, right: 20),
      child: Theme(
        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
        child: Stack(
          children: <Widget>[
            TextField(
              controller: _weightTextFieldController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "90",
                labelText: "Weight",
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      style: BorderStyle.solid, color: Colors.red, width: 10),
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0),
              ),
            ),
            Positioned(
                top: 12,
                right: 20,
                child: Text(
                  solidUnit == "kg" ? "kg" : solidUnit == "lbs" ? "lbs" : "",
                  style: TextStyle(fontSize: 18),
                ))
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 8, top: 16, bottom: 8),
//      width: double.infinity,
//      alignment: Alignment.bottomRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          MaterialButton(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            elevation: 4,
            color: Theme.of(context).primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(

//              side: BorderSide(width: 4,color: Colors.white),
                borderRadius: BorderRadius.all(Radius.circular(25))),
            onPressed: () async {
              if (!validateData()) {
                Fluttertoast.showToast(
                    msg: "Please enter all the details before continuing");
                return;
              }
              await setValues();
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return HomeScreen();
              }));
            },
            child: Row(
              children: <Widget>[
                Text(
                  "Continue",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                )
              ],
            ),
          ),
        ],
      ),
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
        color: sleepTime == "Sleep Time"
            ? Theme.of(context).primaryColor
            : loginButtonColor,
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
        color: wakeupTime == "Wakeup Time"
            ? Theme.of(context).primaryColor
            : loginButtonColor,
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

  bool validateData() {
    /*
     UNIT_LIQUID liquidUnit;
  UNIT_SOLID solidUnit;
  String sleepTime = "Sleep Time";
  String wakeupTime = "Wakeup Time";
     */
    return liquidUnit != null &&
        solidUnit != null &&
        sleepTime != "Sleep Time" &&
        wakeupTime != "Wakeup Time" &&
        _weightTextFieldController.text.isNotEmpty;
  }

  Future setValues() async {
    cache.setStringValue(HOME_SCREEN_KEY, HOME_SCREEN_VALUE);
    cache.setStringValue(LIQUID_UNIT_KEY, liquidUnit);
    cache.setStringValue(SOLID_UNIT_KEY, solidUnit);
    cache.setStringValue(SLEEP_TIME_KEY, sleepTime);
    cache.setStringValue(WAKEUP_TIME_KEY, wakeupTime);
    cache.setStringValue(CUSTOM_WEIGHT_KEY, _weightTextFieldController.text);
    cache.setBoolValue(NOTIFICATION_ENABLED, true);

  }
}
