import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../repository/user_repository.dart' as repository;
import '../controllers/user_controller.dart';

class VerificationScreen2 extends StatefulWidget {
  String email;
  VerificationScreen2({
    this.email
});
  @override
  _VerificationScreen2State createState() => _VerificationScreen2State();
}

class _VerificationScreen2State extends StateMVC<VerificationScreen2> {
  List<TextStyle> otpTextStyles;
  UserController _con;
  _VerificationScreen2State() : super(UserController()) {
    _con = controller;
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        title: Text("EMAIL VERIFICATION", style: TextStyle(
            fontSize: 14,
            overflow: TextOverflow.ellipsis,
            fontFamily: 'Poppins',
            color: Color(0xFFC7491B),
            fontWeight: FontWeight.bold),

        ),
        leading: IconButton(icon: Icon(Icons.arrow_back),onPressed: (){
          Navigator.of(context).pop();
        },),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 80,
            ),
            Center(
              child: Text(
                "We Sent You a Code to Verify \n Your Email Id",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline4,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            //Text("Please enter it below", style: theme.textTheme.headline6),
            //Spacer(flex: 1),
            Center(
              child: Text("Enter your OTP code here", style: Theme.of(context)
                  .textTheme
                  .headline6),
            ),
            SizedBox(
              height: 30,
            ),
            OtpTextField(
              numberOfFields: 4,
              focusedBorderColor: Colors.deepOrange,
              cursorColor: Colors.black,
              fieldWidth: 60.0, // Adjust width to ensure circular shape
              borderRadius: BorderRadius.circular(30.0),
              borderColor: Colors.deepOrange,
              borderWidth: 2.0,
              textStyle: TextStyle(
                  fontSize: 25,
                  color: Colors.black
              ),

              //  style: TextStyle(fontSize: 20.0),
              showFieldAsBox: true,
              onCodeChanged: (String code) {},
              onSubmit: (String verificationCode) {
                repository.verifyOtp(widget.email,verificationCode,"Registration").then((value) {
                  //  print("DS>>>" + value.apiToken);
                  if (value == "Verify") {
                    //  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>VerificationScreen2(email: email,)));
                    Navigator.of(context).pushReplacementNamed('/Pages', arguments: 1);
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(
                      content: Text("Invalid OTP"),
                    ));
                  }
                });
                //_con.verify_otps(widget.email,verificationCode,"Registration");
              },
              keyboardType: TextInputType.number,
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              mainAxisAlignment: MainAxisAlignment.center,
            ),

            //Spacer(),
            SizedBox(
              height: 50,
            ),
            Center(
              child: Text(
                "I didn't receive a code",

              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                "Resend Code",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontFamily: "Poppins"
                ),
              ),
            ),

            /*Spacer(flex: 3),
            CustomButton(
              onPressed: () {},
              title: "Confirm",
              color: primaryColor,
              textStyle: theme.textTheme.subtitle1?.copyWith(
                color: Colors.white,
              ),
            ),
            Spacer(flex: 2),*/
          ],
        ),
      ),
    );
  }

  TextStyle createStyle(Color color) {
    ThemeData theme = Theme.of(context);
    return theme.textTheme.headline3?.copyWith(color: color);
  }
}
