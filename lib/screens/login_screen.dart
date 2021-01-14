import 'dart:convert';

import 'package:drinkwater/extension/color_extension.dart';
import 'package:drinkwater/screens/more_info.dart';
import 'package:drinkwater/utils/local_shared_preference.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLogging = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool hasUser = false;
  ScrollController _scrollController = ScrollController();

  String loginText = "SIGN UP";

  var notificationMessageNode = FocusNode();

  @override
  void initState() {
    super.initState();
    notificationMessageNode.addListener(() {
      if (notificationMessageNode.hasFocus) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
        child: _buildLoginScreen(),
      ),
    );
  }

  Widget _buildLoginScreen() {
    return Column(
//      shrinkWrap: true,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: ListView(
            controller: _scrollController,
            shrinkWrap: true,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      !hasUser ? "Please provide the" : "",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      !hasUser ? "following Information" : "",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              hasUser
                  ? Container()
                  : Row(
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
              hasUser
                  ? Container()
                  : _buildFullNameTextField(
                      "Full Name",
                      "John Doe",
                      controller: _nameController,
                    ),
              hasUser
                  ? Container()
                  : _buildFullNameTextField("Phone Number", "+01-23456789",
                      controller: _phoneController, type: TextInputType.phone),
              _buildFullNameTextField("Email Address", "you@example.com",
                  controller: _emailController,
                  type: TextInputType.emailAddress),
              /*_buildFullNameTextField("Password", "password",
                  controller: _passwordController, obscure: true),*/
              _buildPasswordTextField(),
              SizedBox(
                height: 20,
              ),
              _buildLoginButton(context),
              _buildDirectLogin(context),
              _buildForgotPassword(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTextField() {
    return Container(
//      data: Theme.of(context).copyWith(splashColor: Colors.transparent),
      padding: EdgeInsets.only(left: 20.0, top: 20.0, right: 20),
      child: Theme(
        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
        child: TextField(
          obscureText: true,
          controller: _passwordController,
          focusNode: notificationMessageNode,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Password",
            labelText: "Password",
//          labelStyle: TextStyle(color: Colors.[400]),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 0),
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0),

            /* focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(25),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(25),
            ),*/
          ),
        ),
      ),
    );
  }

  Widget _buildFullNameTextField(String labelText, String hintText,
      {TextInputType type = TextInputType.text,
      bool obscure = false,
      @required TextEditingController controller}) {
    return Container(
//      data: Theme.of(context).copyWith(splashColor: Colors.transparent),
      padding: EdgeInsets.only(left: 20.0, top: 20.0, right: 20),
      child: Theme(
        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
        child: TextField(
          obscureText: obscure,
          keyboardType: type,
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hintText,
            labelText: labelText,
//          labelStyle: TextStyle(color: Colors.[400]),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 0),
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0),

            /* focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(25),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(25),
            ),*/
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return _isLogging
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16),
            width: double.infinity,
            alignment: Alignment.center,
            child: MaterialButton(
              padding: EdgeInsets.symmetric(vertical: 12),
              minWidth: double.infinity,
              elevation: 4,
              color: loginButtonColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                _login(context);
              },
              child: Text(
                loginText,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          );
  }

  Widget _buildDirectLogin(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 16, right: 16),
      alignment: Alignment.centerRight,
      child: FlatButton(
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: hasUser ? "" : "Already a user?",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: "  ",
              ),
              TextSpan(
                text: hasUser ? "Sign up" : "Login",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),

        /*child: Text(
          hasUser ? "Sign up" : "Already a user? Login instead",
          style: TextStyle(
              fontSize: 18,
              color:Colors.black54,
              fontStyle: FontStyle.italic,
              decoration: TextDecoration.underline,

              fontWeight: FontWeight.bold),
        ),*/
        onPressed: () {
          this.setState(() {
            hasUser = !hasUser;
            loginText = !hasUser ? "SIGNUP" : "LOGIN";
          });
        },
      ),
    );
  }

  Widget _buildForgotPassword(BuildContext context) {
    return hasUser
        ? Container(
            width: double.infinity,
            padding: EdgeInsets.only(left: 16, right: 16),
            alignment: Alignment.centerRight,
            child: FlatButton(
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    decoration: TextDecoration.underline),
              ),
              onPressed: () {},
            ),
          )
        : Container();
  }

  Future<void> _login(BuildContext context) async {


    bool isValidEmail = validateEmail(_emailController.text);
    if (!isValidEmail) {
      Fluttertoast.showToast(msg: "Please enter valid email address");
      return;
    }
    if (!hasUser) {
      bool validName = validatePassword(_nameController.text);
      if (!validName) {
        Fluttertoast.showToast(msg: "Name too short");
        return;
      }
      bool validPhone = validatePhone(_phoneController.text);
      if (!validPhone) {
        Fluttertoast.showToast(msg: "Phone number not valid");
        return;
      }
    }
    bool validPassword = validatePassword(_passwordController.text);
    if (!validPassword) {
      Fluttertoast.showToast(msg: "Password too short");
      return;
    }

    FirebaseUser user;

    this.setState(() {
      _isLogging = true;
    });
    try {
      user = (await _auth.signInWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text))
          .user;
      if (user == null) {
        AuthResult authResult = await _auth.createUserWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);
        user = authResult.user;
      }
      this.setState(() {
        _isLogging = false;
      });
      print("The firebase user is $user");
      if (user != null) {
        cache.setStringValue(INFORMATION_SCREEN_KEY, INFORMATION_SCREEN_VALUE);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return MoreInfo();
        }));
      } else {
        Fluttertoast.showToast(msg: "There was an error while loggin in");
      }
    } catch (e) {
      print("The exception is $hasUser $e");
      if (!hasUser) {
        AuthResult authResult = await _auth.createUserWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);
        user = authResult.user;
      }
      this.setState(() {
        _isLogging = false;
      });

      print("The firebase user from exception is $user");

      if (user != null) {
        cache.setStringValue(INFORMATION_SCREEN_KEY, INFORMATION_SCREEN_VALUE);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return MoreInfo();
        }));
      } else {
        Fluttertoast.showToast(msg: "There was an error while loggin in");
      }
    }
  }

  bool validateEmail(String text) {
    return text.contains("@") && text.contains(".");
  }

  bool validatePassword(String text) {
    return text.length > 3;
  }

  bool validatePhone(String text) {
    return text.length > 6;
  }
}
