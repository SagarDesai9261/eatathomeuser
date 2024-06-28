import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:food_delivery_app/src/models/user.dart';
import 'package:food_delivery_app/utils/color.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../elements/MobileVerificationBottomSheetWidget.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../repository/firebase_api.dart';

class SignUpWidget extends StatefulWidget {
  String msg = "";


  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends StateMVC<SignUpWidget> {
  UserController? _con;
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FirebaseMessaging? _firebaseMessaging;
  _SignUpWidgetState() : super(UserController()) {
    _con = controller as UserController?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con!.scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: <Widget>[
          Image.asset(
            "assets/img/banner.jpg",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double screenHeight = constraints.maxHeight;
              double logoTopMargin =
                  screenHeight * 0.1; // Adjust the margin as needed

              return Container(
                margin: EdgeInsets.only(top: logoTopMargin),
                child: SvgPicture.asset(
                  'assets/img/ic_launcher.svg',
                  width: 200,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          Positioned(
            top:50,

            child: Image.asset(
              'assets/img/HOME-FOOD-LOGO2.png',
              width: 300,
              height: 130,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            //top: config.App(context).appHeight(29.5) - 50,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 50,
                        color: Theme.of(context).hintColor.withOpacity(0.2),
                      )
                    ]),
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding: EdgeInsets.symmetric(vertical: 50, horizontal: 27),
                width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
                child: Form(
                  key: _con!.registerFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        controller: _fullNameController,
                        keyboardType: TextInputType.text,
                        onSaved: (input) => _con!.user.name = input!,
                        validator: (input) => input!.length < 3
                            ? S.of(context).should_be_more_than_3_letters
                            : null,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                        /*  labelText: S.of(context).full_name,
                          labelStyle: TextStyle(color: Colors.black),*/
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                          hintText: "Name",
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          prefixIcon: Icon(Icons.person_outline,
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .focusColor
                                    .withOpacity(0.2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (input) => _con!.user.email = input!,
                        validator: (input) => !input!.contains('@')
                            ? S.of(context).should_be_a_valid_email
                            : null,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                        /*  labelText: S.of(context).email,
                          labelStyle: TextStyle(color: Colors.black),*/
                          contentPadding: EdgeInsets.all(12),
                          hintText: 'Email Id',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          prefixIcon: Icon(Icons.alternate_email,
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: phone,
                        keyboardType: TextInputType.phone,
                        onSaved: (input) => _con!.user.phone = input!,
                        validator: (input) => input!.isEmpty
                            ? "Mobile is required"
                            : input!.length != 10 ? "Mobile should be 10 digits" : null,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          /*  labelText: S.of(context).email,
                          labelStyle: TextStyle(color: Colors.black),*/
                          contentPadding: EdgeInsets.all(12),
                          hintText: 'Mobile Number',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          prefixIcon: Icon(Icons.phone_android,
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _con!.hidePassword,
                        onSaved: (input) => _con!.user.password = input,
                        validator: (input) => input!.length < 6
                            ? S.of(context).should_be_more_than_6_letters
                            : null,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                         /* labelText: S.of(context).password,
                          labelStyle: TextStyle(color: Colors.black),*/
                          contentPadding: EdgeInsets.all(12),
                          hintText: 'Password',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _con!.hidePassword = !_con!.hidePassword;
                              });
                            },
                            color: Theme.of(context).focusColor,
                            icon: Icon(_con!.hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                          ),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        obscureText: _con!.hidePassword1,
                        onSaved: (input) => _con!.user.password = input,
                        validator: (input) => input!.length < 6
                            ? S.of(context).should_be_more_than_6_letters
                            : null,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                         /* labelText: "Confirm Password",
                          labelStyle: TextStyle(color: Colors.black),*/
                         contentPadding: EdgeInsets.all(0),
                          hintText: 'Confirm Password',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7),fontSize: 14),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _con!.hidePassword1 = !_con!.hidePassword1;
                              });
                            },
                            color: Theme.of(context).focusColor,
                            icon: Icon(_con!.hidePassword1
                                ? Icons.visibility
                                : Icons.visibility_off),
                          ),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 12),

                      Container(
                        height: 50,

                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              end: Alignment.topLeft,
                              begin: Alignment.topRight,
                              colors: [
                                kPrimaryColorLiteorange,
                                kPrimaryColororange
                              ],
                            )),
                        child: ElevatedButton(
                          onPressed: ()async {
                            String token;
                            User registeruser = User();

                           token = await FirebaseApi().getDeviceToken();
                            registeruser.name = _fullNameController.text.toString();
                            registeruser.email = _emailController.text.toString();
                            registeruser.phone = phone.text.toString();
                            registeruser.password = _passwordController.text.toString();
                            registeruser.deviceToken = token;
                            _con!.register(context, registeruser,_emailController.text);

                            /*if (_con.loginFormKey.currentState.validate()) {
                              _con.loginFormKey.currentState.save();
                              var bottomSheetController =
                              _con.scaffoldKey.currentState.showBottomSheet(
                                    (context) =>
                                    MobileVerificationBottomSheetWidget(
                                            (String sms) {
                                          if (sms == "1234") {
                                            // print("123456....$sms");
                                            _con.register(context);
                                          }
                                        },
                                        scaffoldKey: _con.scaffoldKey,
                                        user: _con.user),
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10)),
                                ),
                              );
                              if (widget.msg.isNotEmpty) {
                                bottomSheetController.closed.then((value) {
                                  _con.register(context);
                                  // print("not close");
                                });
                              }
                            }*/
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            S.of(context).register,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                     /* BlockButtonWidget(
                        text: Text(
                          S.of(context).register,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor),
                        ),
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          if (_con.loginFormKey.currentState.validate()) {
                            _con.loginFormKey.currentState.save();
                            var bottomSheetController =
                                _con.scaffoldKey.currentState.showBottomSheet(
                              (context) =>
                                  MobileVerificationBottomSheetWidget(
                                      (String sms) {
                                if (sms == "1234") {
                                  // print("123456....$sms");
                                  _con.register(context);
                                }
                              },
                                      scaffoldKey: _con.scaffoldKey,
                                      user: _con.user),
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                              ),
                            );
                            if (widget.msg.isNotEmpty) {
                              bottomSheetController.closed.then((value) {
                                _con.register(context);
                                // print("not close");
                              });
                            }
                          }
                        },
                      ),*/

//                      MaterialButton(
//      elevation: 0,
//      focusElevation: 0,
//      highlightElevation: 0,
//                        onPressed: () {
//                          Navigator.of(context).pushNamed('/MobileVerification');
//                        },
//                        padding: EdgeInsets.symmetric(vertical: 14),
//                        color: Theme.of(context).accentColor.withOpacity(0.1),
//                        shape: StadiumBorder(),
//                        child: Text(
//                          'Register with Google',
//                          textAlign: TextAlign.start,
//                          style: TextStyle(
//                            color: Theme.of(context).accentColor,
//                          ),
//                        ),
//                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            child: MaterialButton(
              elevation: 0,
              focusElevation: 0,
              highlightElevation: 0,
              onPressed: () {
                Navigator.of(context).pushNamed('/Login');
              },
              textColor: Colors.white,
              child: Text(S.of(context).i_have_account_back_to_login),
            ),
          )
        ],
      ),
    );
  }
}
