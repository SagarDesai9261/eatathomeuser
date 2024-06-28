import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../../utils/color.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';

class ForgetPasswordWidget extends StatefulWidget {
  @override
  _ForgetPasswordWidgetState createState() => _ForgetPasswordWidgetState();
}

class _ForgetPasswordWidgetState extends StateMVC<ForgetPasswordWidget> {
  UserController? _con;

  _ForgetPasswordWidgetState() : super(UserController()) {
    _con = controller as UserController?;
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con!.scaffoldKey,
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
         /* Positioned(
            top: 0,
            child: Container(
              width: config.App(context).appWidth(100),
              height: config.App(context).appHeight(37),
              decoration: BoxDecoration(color: Theme.of(context).accentColor),
            ),
          ),*/
        /*  Positioned(
            top: config.App(context).appHeight(37) - 120,
            child: Center(
              child: Container(

                child: Text(
                  S.of(context).email_to_reset_password,
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      .merge(TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ),
            ),
          ),*/
          Positioned(
          //  top: config.App(context).appHeight(37) - 50,
            bottom: 30,
            child: SingleChildScrollView(
              child: Container(
               /* decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
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
                padding: EdgeInsets.symmetric(vertical: 50, horizontal: 27),*/
                width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
                child: Form(
                  key: _con!.loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Container(

                          child: Text(
                            S.of(context).email_to_reset_password,
                            style: Theme.of(context)
                                .textTheme
                                .headline2
                                !.merge(TextStyle(color: Theme.of(context).primaryColor)),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (input) => _con!.user.email = input!,
                        validator: (input) => !input!.contains('@')
                            ? S.of(context).should_be_a_valid_email
                            : null,
                        decoration: InputDecoration(

                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: EdgeInsets.all(12),
                          hintText: 'Email Id',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          prefixIcon: Icon(Icons.email,
                              color: Theme.of(context).hintColor),
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
                      SizedBox(height: 20),
                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width / 1.3,
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
                            _con!.resetPassword();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            S.of(context).send_password_reset_link,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                   /*   BlockButtonWidget(
                        text: Text(
                          S.of(context).send_password_reset_link,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          _con!.resetPassword();
                        },
                      ),*/
                      Column(
                        children: <Widget>[
                          MaterialButton(
                            elevation: 0,
                            focusElevation: 0,
                            highlightElevation: 0,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            textColor: Colors.white,
                            child: Text(
                                S.of(context).i_remember_my_password_return_to_login),
                          ),
                          MaterialButton(
                            elevation: 0,
                            focusElevation: 0,
                            highlightElevation: 0,
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed('/SignUp');
                            },
                            textColor: Colors.white,
                            child: Text(S.of(context).i_dont_have_an_account),
                          ),
                        ],
                      )
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
}
