import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/elements/chat_bubble.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/color.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chathistory_response_model.dart';
import '../repository/user_repository.dart' as userRepo;
import 'help_support_form.dart';

class ChatScreen extends StatefulWidget {


  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final _chatController = TextEditingController();
  DateTime? previousDate;
  PlatformFile? file;
  String uploadPath = "";
  bool hasFile = false;
  String filePath = "";
  bool toShow = false;

  String apiToken = "";
  String supportTicketId = "";
  List<Message> _messages = [];

  @override
  void initState() {
    apiToken = userRepo.currentUser.value.apiToken;
    print(apiToken);
    loadData();
    setState(() { });
    super.initState();
  }

  loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print("Support id: "+prefs.getString('support_ticket_id').toString());
    supportTicketId = prefs.getString('support_ticket_id').toString() ?? '';

    GetChatHistory().then((chatHistoryData) {
      setState(() {
        _messages.clear();
        _messages = chatHistoryData.messages.reversed.toList();
        // Access baseUrl if needed
        uploadPath = chatHistoryData.baseUrl;
        //_messages.reversed.toList()[index]
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
        backgroundColor: kPrimaryColororange,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              displacement: 300,


              onRefresh: ()  async{
                setState(() async{
                  await loadData();

                });
              },
              child: Expanded(
                child: /*SizedBox(),*/ListView.builder(
                  reverse: true,
                  itemCount: _messages.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final messageDate = DateTime.parse(_messages[index].createdAt);
                    final shouldShowDateLabel = previousDate == null || messageDate.day != previousDate!.day;
                    previousDate = messageDate;

                    if(_messages[index].messageType == "2"){
                      //print("DS>>> hasfile "+_messages[index].message+" "+_messages[index].file.toString());
                      hasFile = true;
                      filePath = uploadPath+_messages[index].messageFile.toString();
                      print("DS>> file path"+ filePath);
                    }
                    else{
                      hasFile = false;
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (shouldShowDateLabel)
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            margin: EdgeInsets.symmetric(horizontal: 120),
                            //color: Colors.grey[300],
                            child: Text(
                              DateFormat.yMMMMd().format(messageDate),
                              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w700),
                            ),
                          ),
                        hasFile ? MessageBubble(
                          message: _messages[index].message,
                          isMe: _messages[index].isMe == "1" ? true : false,
                          sendTime: DateFormat('hh:mm a')
                              .format(DateTime.parse(_messages[index].createdAt)),
                          senderName: _messages[index].fromUserId,
                          fileMessage: hasFile ? uploadPath+_messages[index].messageFile.toString(): "",
                          fileName: _messages[index].file.toString(),
                          hasFile: hasFile,
                        ) :  MessageBubble(
                          message:_messages[index].message,
                          isMe: _messages[index].isMe == "1" ? true : false,
                          /*sendTime: DateFormat('hh:mm a')
                              .format(DateTime.parse("03/11/2023")),*/
                          sendTime:  DateFormat('hh:mm a')
                              .format(DateTime.parse(_messages[index].createdAt)),
                          senderName: _messages[index].fromUserId,
                          hasFile: hasFile, fileMessage: '', fileName: '',
                        ),
                      ],
                    );

                    /*ListTile(
                      title: Text(_messages[index].message),
                    );*/
                  },
                ),
              ),
            ),
          ),
          Divider(),
          Container(
            child: TextButton(
              child: Text("Close chat"),
              onPressed: () async{
                SharedPreferences prefs = await SharedPreferences.getInstance();



                  // Replace <API_URL> with the URL of the API you want to call
                  final Map<String, dynamic> requestBody = {

                      "support_ticket_id": prefs.getString('support_ticket_id'),
                      "status": 3
                  };
                  final response = await http.post(Uri.parse("https://comeeathome.com/app/api/support/update-status"),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $apiToken',
                    },
                    body:jsonEncode(requestBody),);

                setState(() {
                  prefs.clear();
                  supportTicketId = "";

                });
                if(supportTicketId.toString() == "null")
                {
                  Navigator.of(context).push(MaterialPageRoute(builder:  (context) {
                    return HelpAndSupportForm();
                  },));
                }

                  if (response.statusCode == 200) {
                    // Parse the response body as needed
                    final data = jsonDecode(response.body.toString());
                    return data;
                  }
                  else {
                    // Handle error status codes as needed
                    throw Exception('Failed to fetch data');
                  }



              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                    ),
                  ),
                ),
                GestureDetector(
                    onTap: () async {
                      FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                      if (result != null) {
                        file = result.files.first;
                        setState(() {
                          file = result.files.first;
                          toShow = true;
                          print("DS>>"+file!.name.toString());

                        });
                      } else {
                        // User canceled the file selection
                      }
                    },
                    child: Icon(Icons.attach_file)),
                SizedBox(width: 10),
                Visibility(
                  visible: toShow,
                  child: Container(
                    child: file != null
                        ? Column(
                      children: [
                        if (file!.extension == 'jpg' ||
                            file!.extension == 'png' ||
                            file!.extension == 'jpeg')
                          Image.file(
                            File(file!.path!),
                            width: 100,
                            height: 100,
                          ),
                        if (file!.extension == 'pdf')
                          Icon(Icons.picture_as_pdf, size: 100),
                        SizedBox(height: 5),
                        Text(
                          file!.name.toString().length > 8
                              ? '${file!.name.toString().substring(0, 8)}...' // Truncate the string after 10 characters
                              : file!.name.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    )
                        : Container(),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async{
                    if (_chatController.text.isNotEmpty) {

                      String messageToSend = _chatController.text;
                      String response = "";
                     print(messageToSend);

                      if (file != null) {
                        response = await sendMessageWithFile();
                      } else {



                      response = await sendMessage(messageToSend);

                      }
                      if(response.toString().isNotEmpty){
                        //GetChatHistory();
                        toShow = false;
                        GetChatHistory().then((messages) {
                          setState(() {
                            _messages.clear();
                            _messages = messages.messages.reversed.toList();
                            _chatController.clear();
                            uploadPath = messages.baseUrl;
                          });
                        });
                      }
                      print("--->"+response.toString());
                      //_addMessage(_controller.text);
                    }
                    else
                      {
                        if (file != null) {
                          String response = "";

                          response = await sendMessageWithFile();
                          if(response.toString().isNotEmpty){
                            //GetChatHistory();
                            toShow = false;
                            GetChatHistory().then((messages) {
                              setState(() {
                                _messages.clear();
                                _messages = messages.messages.reversed.toList();
                                _chatController.clear();
                                uploadPath = messages.baseUrl;
                              });
                            });
                          }
                          print("--->"+response.toString());
                        }
                      }
                  },
                  child: Text('Send'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColororange, // background (button) color
                    foregroundColor: Colors.white, // foreground (text) color
                  ),
                  //color: Theme.of(context).accentColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Create a list of ChatMessage objects

  Future<ChatHistoryMessages> GetChatHistory() async {

    final Map<String, dynamic> requestBody = {
      "support_ticket_id": supportTicketId,
    };
    final response = await http.post(Uri.parse("https://comeeathome.com/app/api/chat/history"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiToken',
        },
        body:jsonEncode(requestBody),);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = json.decode(response.body);
      final ChatHistoryMessages chatHistory =
      ChatHistoryMessages.fromJson(responseJson['data']);

      return ChatHistoryMessages(
        messages: chatHistory.messages,
        baseUrl: chatHistory.baseUrl,
      );
    } else {
      throw Exception('Failed to load chat messages');
    }
  }

  Future<String> sendMessage(String text) async {
    // Replace <API_URL> with the URL of the API you want to call
    final Map<String, dynamic> requestBody = {
      "message" : text,
      "message_type":"1",
      "support_ticket_id": supportTicketId,
    };
    final response = await http.post(Uri.parse("https://comeeathome.com/app/api/chat/send"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiToken',
        },
      body:jsonEncode(requestBody),);


    if (response.statusCode == 200) {
      // Parse the response body as needed
      final data = jsonDecode(response.body.toString());
      return data.toString();
    }
    else {
      // Handle error status codes as needed
      throw Exception('Failed to fetch data');
    }
  }

  Future<String> sendMessageWithFile() async {
    print("tap");
    // Replace <API_URL> with the URL of the API you want to call
    //print("message"+text);
    final request = http.MultipartRequest(
        'POST', Uri.parse("https://comeeathome.com/app/api/chat/send"));
    request.fields['support_ticket_id'] = supportTicketId;
    request.fields['message_type'] = "2";

    // Add your custom header here
    request.headers['Authorization'] = 'Bearer $apiToken';
    request.headers['Content-Type'] = 'application/json';

    if (file != null) {
      request.files.add(
        http.MultipartFile(
          'message_file',
          File(file!.path.toString()).readAsBytes().asStream(),
          file!.size,
          filename: file!.name,
        ),
      );
    }
    print("DS>>>"+request.toString());
    var response = await request.send();
    file = null;
    //print("DS>>>"+response.stream.bytesToString().toString());
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      return data.toString();
    } else {
      // Handle error status codes as needed
      throw Exception('Failed to fetch data');
    }
  }
}
