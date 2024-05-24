import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../../utils/color.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../repository/user_repository.dart' as userRepo;

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends StateMVC<LoginWidget> {
  UserController _con;

  _LoginWidgetState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    if (userRepo.currentUser.value.apiToken != null) {
      Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
    }
  }
  int index = 0 ;

  // WillPopScope(
  // onWillPop: Helper.of(context).onWillPop,
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // key: _con.scaffoldKey,
      //resizeToAvoidBottomPadding: false,
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
            //top: config.App(context).appHeight(37) - -90,
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
                  horizontal: 16,
                ),
                padding:
                    EdgeInsets.only(top: 50, right: 25, left: 25, bottom: 20),
                width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
                child: Form(
                  key: _con.loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (input) => _con.user.email = input,
                        validator: (input) => !input.contains('@')
                            ? S.of(context).should_be_a_valid_email
                            : null,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: EdgeInsets.all(16),
                          hintText: 'Email ID',
                          hintStyle: TextStyle(color: Colors.grey
                              //    color: Theme.of(context).focusColor.withOpacity(0.7),
                              ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
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
                        keyboardType: TextInputType.text,
                        onSaved: (input) => _con.user.password = input,
                        validator: (input) => input.length < 3
                            ? S.of(context).should_be_more_than_3_characters
                            : null,
                        obscureText: _con.hidePassword,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          /*labelText: S.of(context).password,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.normal,

                            // color: Theme.of(context).accentColor,
                            color: Colors.black,
                          ),*/
                          contentPadding: EdgeInsets.all(16),
                          hintText: 'Password',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          // prefixIcon: Icon(Icons.lock_outline,
                          //     color: Theme.of(context).accentColor),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _con.hidePassword = !_con.hidePassword;
                              });
                            },
                            color: Theme.of(context).focusColor,
                            icon: Icon(_con.hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24.0,
                            width: 24.0,
                            child: Checkbox(
                              value: index == 1 ? true : false,
                              onChanged: (value) {
                                setState(() {
                                  if(index == 1){
                                    index = 0;
                                  }
                                  else if(index == 0){
                                    index =1;
                                  }
                                });
                              },
                              side: BorderSide(
                                  color: index == 1? Colors.black : Colors.white,
                                  width: 2
                              ),
                              activeColor: Colors.white,
                              checkColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Remember me",
                            style: TextStyle(color: Colors.white),
                          ),
                          Spacer(),
                          InkWell(
                            onTap: (){
                              Navigator.of(context).pushNamed('/ForgetPassword');
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width / 2.75,
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
                              onPressed: () {
                                //todo
                                _con.login(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width / 2.75,
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
                              onPressed: () {
                                Navigator.of(context).pushNamed('/SignUp');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (Excep) {}
  }*/

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        throw Exception('Google sign-in canceled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Retrieve user details
      final User user = userCredential.user;
      final String userEmail = user?.email;

      if (userEmail != null) {
        // You can now access the user's email and other details
        ///DS Integrating a social signin is remaining here.
        ///dishashukla@360incemail.com
        ///DeniseStrats@2891
        // print('User Email: $userEmail');
        Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
      } else {
        // Handle the case where user email is not available
        throw Exception('User email not available');
      }

      return userCredential;
    } catch (e) {
      // Handle any exceptions that occur during the sign-in process
      // print('Error signing in with Google: $e');
      rethrow; // Re-throw the exception for further handling, if needed
    }
  }
/*  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: (){
                              signInWithGoogle();
                            },
                            child: Container(
                              width: 135,
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24)),
                                child: Row(
                                  children: [
                                    Image.asset("assets/img/google.png",
                                        height: 23, width: 20),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Text(
                                      "SignIn with Google",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          GestureDetector(
                            onTap: () async {
                              FacebookAuth.instance.login(
                                  permissions: ["public_profile", "email"]).then((value) {
                                FacebookAuth.instance.getUserData().then((userData) async {

                                  setState(() {
                                    // print("DS>>> FB: "+userData["name"]);
                                    // print("DS>>> FB: "+userData["email"]);
                                    */
/*_isLoggedIn = true;
                                    _userObj = userData;*/
/*
                                  });
                                });
                              });
                            },
                            child: Container(
                              width: 135,
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    color: kFBBlue,
                                    borderRadius: BorderRadius.circular(24)),
                                child: Row(
                                  children: [
                                    Image.asset("assets/img/facebook.png",
                                        height: 25, width: 17),
                                    Text(
                                      "SignIn with Facebook",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // ElevatedButton.icon(
                          //   // <-- ElevatedButton
                          //   onPressed: () {},
                          //   style: ElevatedButton.styleFrom(
                          //     shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(25)),
                          //   ),
                          //   icon: Image.asset("assets/img/facebook.png",height: 19,width: 19,),
                          //
                          //   label: Text(
                          //     'Sign in with Facebook',
                          //     style: TextStyle(
                          //       fontWeight: FontWeight.normal,
                          //     ),
                          //   ),
                          // ),
                        ],
                      )*/
}
