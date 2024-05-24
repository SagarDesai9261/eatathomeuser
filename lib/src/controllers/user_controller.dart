import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../elements/email_verification.dart';
import '../helpers/helper.dart';
import '../models/user.dart' as model;
import '../pages/mobile_verification_2.dart';
import '../repository/firebase_api.dart';
import '../repository/user_repository.dart' as repository;

class UserController extends ControllerMVC {
  model.User user = new model.User();
  bool hidePassword = true;
  bool hidePassword1 = true;
  bool loading = false;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<FormState> registerFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  FirebaseMessaging _firebaseMessaging;
  OverlayEntry loader;

  UserController() {
    loginFormKey = new GlobalKey<FormState>();
    registerFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    FirebaseApi().getDeviceToken().then((value) {
      user.deviceToken = value;
    });
  }



  Future<void> verifyPhone(model.User user) async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      repository.currentUser.value.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResent]) {
      repository.currentUser.value.verificationId = verId;
      Navigator.push(
        scaffoldKey.currentContext,
        MaterialPageRoute(
            builder: (context) => MobileVerification2(
                  onVerified: (v) {
                    Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 1);
                  },
                )),
      );
    };
    final PhoneVerificationCompleted _verifiedSuccess = (AuthCredential auth) {};
    final PhoneVerificationFailed _verifyFailed = (FirebaseAuthException e) {
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(e.message),
      ));
      // print(e.toString());
    };
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: user.phone,
      timeout: const Duration(seconds: 5),
      verificationCompleted: _verifiedSuccess,
      verificationFailed: _verifyFailed,
      codeSent: smsCodeSent,
      codeAutoRetrievalTimeout: autoRetrieve,
    );
  }
  void login(BuildContext context) async {
    loader = Helper.overlayLoader(state.context);
    FocusScope.of(state.context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(state.context).insert(loader);
      repository.login(user,context).then((value) {
        print(value.deviceToken);
        // print("DS>>>"+value.apiToken+" "+scaffoldKey.currentContext.toString());

        if (value != null ) {
          //todo
           print("DS>>>"+value.name);
          Navigator.of(context).pushReplacementNamed('/Pages', arguments: 1);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(S.of(state.context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        print(e);
        loader.remove();

      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void register(context, registeruser,email) async {
    print(registeruser);
    loader = Helper.overlayLoader(state.context);
    FocusScope.of(state.context).unfocus();
    if (registerFormKey.currentState.validate()){
      registerFormKey.currentState.save();
      Overlay.of(state.context).insert(loader);
      repository.register(registeruser).then((value) {
       //  print("DS>>>" + value.apiToken);
        if (value =="Register") {
         Navigator.of(context).push(MaterialPageRoute(builder: (context)=>VerificationScreen2(email: email,)));
          // Navigator.of(context).pushReplacementNamed('/Pages', arguments: 1);
        } else {
          ScaffoldMessenger.of(scaffoldKey?.currentContext)
              .showSnackBar(SnackBar(
            content: Text(value),
          ));
        }
      }).catchError((e) {
     //   print(e);
        ScaffoldMessenger.of(scaffoldKey?.currentContext)
            .showSnackBar(SnackBar(
          content: Text("Email is already register.."),
        ));
        loader.remove();
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }
  void verify_otps(context, registeruser,email) async {
    print(registeruser);
    repository.verifyOtp(context,registeruser,email).then((value) {
      //  print("DS>>>" + value.apiToken);
      if (value == "Verify") {
        //  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>VerificationScreen2(email: email,)));
        Navigator.of(context).pushReplacementNamed('/Pages', arguments: 1);
      } else {
        ScaffoldMessenger.of(scaffoldKey?.currentContext)
            .showSnackBar(SnackBar(
          content: Text("Invalid OTP"),
        ));
      }
    }).catchError((e) {
      //   print(e);
      /*ScaffoldMessenger.of(scaffoldKey?.currentContext)
            .showSnackBar(SnackBar(
          content: Text("Email is already register.."),
        ));*/
      loader.remove();
    }).whenComplete(() {
      Helper.hideLoader(loader);
    });
    // loader = Helper.overlayLoader(state.context);
    //FocusScope.of(state.context).unfocus();

  }
  void resetPassword() {
    loader = Helper.overlayLoader(state.context);
    FocusScope.of(state.context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(state.context).insert(loader);
      repository.resetPassword(user).then((value) {
        if (value != null && value == true) {
          ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
            content: Text(S.of(state.context).your_reset_link_has_been_sent_to_your_email),
            action: SnackBarAction(
              label: S.of(state.context).login,
              onPressed: () {
                Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Login');
              },
            ),
            duration: Duration(seconds: 10),
          ));
        } else {
          loader.remove();
          ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
            content: Text(S.of(state.context).error_verify_email_settings),
          ));
        }
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }
}
