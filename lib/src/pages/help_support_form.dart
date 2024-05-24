import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/color.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../repository/user_repository.dart' as userRepo;
import 'chatscreen.dart';
import 'home.dart';

class HelpAndSupportForm extends StatefulWidget {
  @override
  _ChatFormState createState() => _ChatFormState();
}

class _ChatFormState extends State<HelpAndSupportForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  String apiToken = "";

  @override
  void initState() {
    apiToken = userRepo.currentUser.value.apiToken;
    // print(apiToken);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
       /* Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) =>
            HomeWidget(parentScaffoldKey: new GlobalKey(), directedFrom: "forHome",
              currentTab: 2,)
        ));*/
Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Help & Support'),
          backgroundColor: kPrimaryColororange,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title',
                    //border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColororange),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColororange),
                    ),
                    labelStyle:  TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name',
                    //border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColororange),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColororange),
                    ),
                    labelStyle:  TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone',
                    //border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColororange),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColororange),
                    ),
                    labelStyle:  TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email',
                    //border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColororange),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColororange),
                    ),
                    labelStyle:  TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: messageController,
                  decoration: InputDecoration(labelText: 'Message Box',
                    //border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColororange),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColororange),
                    ),
                    labelStyle:  TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Implement your chat initiation logic here
                    // You can access user inputs using controllers like nameController.text
                    // For simplicity, let's just print the values
                    // print('Name: ${nameController.text}');
                    // print('Title: ${titleController.text}');
                    // print('Phone: ${phoneController.text}');
                    // print('Email: ${emailController.text}');
                    // print('Message: ${messageController.text}');

                    submitTicket(titleController.text.toString(), messageController.text.toString(),
                        nameController.text.toString(), emailController.text.toString(),
                        phoneController.text.toString(), apiToken);
                  },
                  child: Text('Start Chat'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(kPrimaryColororange), // background (button) color
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      minimumSize: MaterialStateProperty.all(Size(50, 40)),
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> submitTicket(title, description, name, email, phone, token) async {
    final String apiUrl = 'https://comeeathome.com/app/api/support/create';

    final Map<String, dynamic> requestBody = {
      "title": title,
      "description": description,
      "name": name,
      "email": email,
      "phone": phone,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      // Access the data from the response
      // print('Ticket ID: ${responseData['data']['id']}');
      // print('Ticket Reference ID: ${responseData['data']['ticket_ref_id']}');
      // Add more fields as needed

      setTicketValue('${responseData['data']['id']}', '${responseData['data']['ticket_ref_id']}');

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatScreen()
        ),
      );
    } else {
      // print('Failed to submit ticket. Status code: ${response.statusCode}');
    }
  }

  void setTicketValue(support_ticket_id, ticket_ref_id) async {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('support_ticket_id', support_ticket_id);
      await prefs.setString('ticket_ref_id', ticket_ref_id);

  }
}