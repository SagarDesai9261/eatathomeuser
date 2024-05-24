import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery_app/src/pages/favorites.dart';
import 'package:food_delivery_app/src/pages/home.dart';
import 'package:freshchat_sdk/freshchat_sdk.dart';
import 'package:freshchat_sdk/freshchat_user.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../controllers/profile_controller.dart';
import '../models/coupon.dart';
import '../pages/CouponWidget.dart';
import '../pages/chatscreen.dart';
import '../pages/help_support_form.dart';
import '../provider.dart';
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../repository/user_repository.dart' as userRepo;
void handleFreshchatNotification(Map<String, dynamic> message) async {
  if (await Freshchat.isFreshchatNotification(message)) {
    print("is Freshchat notification");
    Freshchat.handlePushNotification(message);
  }
}

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  print("Inside background handler");

  //NOTE: Freshchat notification - Initialize Firebase for Android only.
  if (Platform.isAndroid) {
    await Firebase.initializeApp();
  }
  handleFreshchatNotification(message.data);
}
class DrawerWidget extends StatefulWidget {
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends StateMVC<DrawerWidget> {
  String apiToken = "";
  String supportTicketId = "";
  String ticketRefId = "";
  _DrawerWidgetState() : super(ProfileController()) {}
  final APPID = "ccd5820a-d45f-4698-8c06-81be62a9b153";
  final APPKEY = "32d74b1d-29ff-40ed-9355-2b97c0b20670";
  final DOMAIN = "msdk.in.freshchat.com";
  FreshchatUser user;
  String firstName = "",
      lastName = "",
      email = "",
      phoneCountryCode = "",
      phoneNumber = "",
      key = "",
      value = "",
      conversationTag = "",
      message = "",
      eventName = "",
      topicName = "",
      topicTags = "",
      jwtToken = "",
      freshchatUserId = "",
      userName = "",
      externalId = "",
      restoreId = "",
      jwtTokenStatus = "",
      obtainedRestoreId = "",
      sdkVersion = "",
      parallelConversationReferenceID1 = "",
      parallelConversationTopicName1 = "",
      parallelConversationReferenceID2 = "",
      parallelConversationTopicName2 = "";
  StreamSubscription restoreStreamSubscription,
      fchatEventStreamSubscription,
      unreadCountSubscription,
      linkOpenerSubscription,
      notificationClickSubscription,
      userInteractionSubscription;
  Map eventProperties = {}, unreadCountStatus = {};
  void registerFcmToken() async {
    if (Platform.isAndroid) {
      String token = await FirebaseMessaging.instance.getToken();
      print("FCM Token is generated $token");
      Freshchat.setPushRegistrationToken(token);
    }
  }
  @override
  void initState() {
    apiToken = userRepo.currentUser.value.apiToken;
    print(apiToken);
    loadData();
    setState(() { });
    Freshchat.init(APPID, APPKEY, DOMAIN);
    Freshchat.linkifyWithPattern("google", "https://google.com");
    Freshchat.setNotificationConfig(
      notificationInterceptionEnabled: true,
      largeIcon: "large_icon",
      smallIcon: "small_icon",
    );

    //NOTE: Freshchat notification - Initialize Firebase for Android only.
    if (Platform.isAndroid) {
      registerFcmToken();

      FirebaseMessaging.instance.onTokenRefresh
          .listen(Freshchat.setPushRegistrationToken);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        var data = message.data;
        handleFreshchatNotification(data);
        print("Notification Content: $data");
      });

      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }

    var restoreStream = Freshchat.onRestoreIdGenerated;
    restoreStreamSubscription = restoreStream.listen((event) async {
      print("Inside Restore stream: Restore Id generated");
      FreshchatUser user = await Freshchat.getUser;
      String restoreId = user.getRestoreId();
      if (restoreId != null) {
        print("Restore Id: $restoreId");
        Clipboard.setData(new ClipboardData(text: restoreId));
      } else {
        restoreId = " ";
      }

/*      ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(content: new Text("Restore ID copied: $restoreId")));*/
    });

    //NOTE: Freshchat events
    var userInteractionStream = Freshchat.onUserInteraction;
    userInteractionStream.listen((event) {
      print("User Interacted $event");
    });
    var notificationStream = Freshchat.onNotificationIntercept;
    notificationStream.listen((event) {
      print(" Notification: $event");
    });
    var freshchatEventStream = Freshchat.onFreshchatEvents;
    fchatEventStreamSubscription = freshchatEventStream.listen((event) {
      print("Freshchat Event: $event");
    });
    var unreadCountStream = Freshchat.onMessageCountUpdate;
    unreadCountSubscription = unreadCountStream.listen((event) {
      print("New message generated: " + event.toString());
    });
    var linkOpeningStream = Freshchat.onRegisterForOpeningLink;
    linkOpenerSubscription = linkOpeningStream.listen((event) {
      print("URL clicked: $event");
    });

    getSdkVersion();
    getFreshchatUserId();
    getTokenStatus();
    getUnreadCount();
    getUser();
    super.initState();
  }
  void getUser() async {
    user = await Freshchat.getUser;
  }

  Future<String> getTokenStatus() async {
    JwtTokenStatus jwtStatus = await Freshchat.getUserIdTokenStatus;
    jwtTokenStatus = jwtStatus.toString();
    jwtTokenStatus = jwtTokenStatus.split('.').last;
    return jwtTokenStatus;
  }

  //NOTE: Platform messages are asynchronous, so we initialize in an async method.
  void getSdkVersion() async {
    sdkVersion = await Freshchat.getSdkVersion;
  }

  Future<String> getFreshchatUserId() async {
    freshchatUserId = await Freshchat.getFreshchatUserId;
  //  FlutterClipboard.copy(freshchatUserId);
    return freshchatUserId;
  }

  void getUnreadCount() async {
    unreadCountStatus = await Freshchat.getUnreadCountAsyncForTags(["tags"]);
  }
  loadData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  print("Support id: "+prefs.getString('support_ticket_id').toString());
    supportTicketId = prefs.getString('support_ticket_id').toString() ?? '';
    ticketRefId = prefs.getString('ticket_ref_id') ?? '';

}

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              currentUser.value.apiToken != null
                  ? Navigator.of(context).pushNamed('/Settings')
                  : Navigator.of(context).pushNamed('/Login');
            },
            child: currentUser.value.apiToken != null
                ? Container(
                  height: 100,
                  child: UserAccountsDrawerHeader(

                      decoration: BoxDecoration(
                        color: Theme.of(context).hintColor.withOpacity(0.1),
                      ),
                      accountName: Text(
                        currentUser.value.name,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      accountEmail: Text(
                        currentUser.value.email,
                        style: Theme.of(context).textTheme.caption,
                      ),
                      // currentAccountPicture: Stack(
                      //   children: [
                      //     SizedBox(
                      //       width: 80,
                      //       height: 80,
                      //       child: ClipRRect(
                      //         borderRadius: BorderRadius.all(Radius.circular(80)),
                      //         child: CachedNetworkImage(
                      //           height: 80,
                      //           width: double.infinity,
                      //           fit: BoxFit.cover,
                      //           imageUrl: currentUser.value.image.thumb,
                      //           placeholder: (context, url) => Image.asset(
                      //             'assets/img/loading.gif',
                      //             fit: BoxFit.cover,
                      //             width: double.infinity,
                      //             height: 80,
                      //           ),
                      //           errorWidget: (context, url, error) => Icon(Icons.error_outline),
                      //         ),
                      //       ),
                      //     ),
                      //     Positioned(
                      //       top: 0,
                      //       right: 0,
                      //       child: currentUser.value.verifiedPhone.isNotEmpty
                      //           ? Icon(
                      //               Icons.check_circle,
                      //               color: Theme.of(context).accentColor,
                      //               size: 24,
                      //             )
                      //           : SizedBox(),
                      //     )
                      //   ],
                      // ),
                    ),
                )
                : Container(
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).hintColor.withOpacity(0.1),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.person,
                          size: 32,
                          color: Theme.of(context).accentColor.withOpacity(1),
                        ),
                        SizedBox(width: 30),
                        Text(
                          S.of(context).guest,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ],
                    ),
                  ),
          ),
          ListTile(
            onTap: () {
              /*Navigator.of(context).pushNamed('/Pages', arguments: 2);*/
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HomeWidget(parentScaffoldKey: new GlobalKey(), directedFrom: "forHome",
                        currentTab: 1,)
                ),
              );
            },
            leading: Icon(
              Icons.home,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              S.of(context).home,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        /*  ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/notificationPage', arguments: 0);
            },
            leading: Icon(
              Icons.notifications,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              S.of(context).notifications,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),*/
          /*ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/orderPage', arguments: 3);
            },
            leading: Icon(
              Icons.local_mall,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              S.of(context).my_orders,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),*/
          ListTile(
            onTap: () {
              if (currentUser.value.apiToken != null) {
                Navigator.of(context).pushNamed('/orderPage', arguments: 0);
              } else {
                Navigator.of(context).pushNamed('/Login');
              }

            },
            leading: Icon(
              Icons.local_mall,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              S.of(context).my_orders,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          ListTile(
            onTap: () {
              /*Navigator.of(context).pushNamed('/Favorites');*/
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FavoritesWidget()
                ),
              );
            },
            leading: Icon(
              Icons.favorite,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              S.of(context).favorite_foods,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),

         /* ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CouponWidget()
                ),
              );
            },
            leading: Icon(
              Icons.card_giftcard,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              "Coupons",
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),*/
          ListTile(
            dense: true,
            title: Text(
              S.of(context).application_preferences,
              style: Theme.of(context).textTheme.bodyText2,
            ),
            trailing: Icon(
              Icons.remove,
              color: Theme.of(context).focusColor.withOpacity(0.3),
            ),
          ),
          ListTile(
            onTap: () async{
              //Navigator.of(context).pushNamed('/Help');
              if (currentUser.value.apiToken != null) {
                print("supportTicketId   ::"+supportTicketId.toString());
               /* if(supportTicketId.toString() == "null")
                  {
                    createChat();
                  }
                else
                  {
                     fetchTicketDetails(supportTicketId);
                  }
*/

               // Freshchat.getFreshchatUserId;
                String value = await Freshchat.getFreshchatUserId;
                user.setFirstName(currentUser.value.name);
                user.setEmail(currentUser.value.email);
                user.setPhone("+91", currentUser.value.phone);
               // Freshchat.identifyUser(externalId:currentUser.value.email,restoreId: "a0e01ac6-b7b9-4b4b-a3d1-61c3f4208c0b");
                print("object ==>${value}");
                Freshchat.setUser(user);


                Freshchat.showConversations(filteredViewTitle:"Premium Support",tags:["premium"]);
              }
              else{
                Navigator.of(context).pushNamed('/Login');

              }


            },
            leading: Icon(
              Icons.help,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              S.of(context).help__support,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          ListTile(
            onTap: () {
              if (currentUser.value.apiToken != null) {
                Navigator.of(context).pushNamed('/Settings');
              } else {
                Navigator.of(context).pushNamed('/Login');
              }
            },
            leading: Icon(
              Icons.person,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              S.of(context).profile,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          // ListTile(
          //   onTap: () {
          //     Navigator.of(context).pushNamed('/Languages');
          //   },
          //   leading: Icon(
          //     Icons.translate,
          //     color: Theme.of(context).focusColor.withOpacity(1),
          //   ),
          //   title: Text(
          //     S.of(context).languages,
          //     style: Theme.of(context).textTheme.subtitle1,
          //   ),
          // ),
          // ListTile(
          //   onTap: () {
          //     if (Theme.of(context).brightness == Brightness.dark) {
          //       setBrightness(Brightness.light);
          //       setting.value.brightness.value = Brightness.light;
          //     } else {
          //       setting.value.brightness.value = Brightness.dark;
          //       setBrightness(Brightness.dark);
          //     }
          //     setting.notifyListeners();
          //   },
            // leading: Icon(
            //   Icons.brightness_6,
            //   color: Theme.of(context).focusColor.withOpacity(1),
            // ),
            // title: Text(
            //   Theme.of(context).brightness == Brightness.dark
            //       ? S.of(context).light_mode
            //       : S.of(context).dark_mode,
            //   style: Theme.of(context).textTheme.subtitle1,
            // ),
          // ),
          ListTile(
            onTap: () {

              if (currentUser.value.apiToken != null) {
                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    title: const Text("Are you sure you want to logout?"),
                    // content: const Text("You have raised a Alert Dialog Box"),
                    actions: [
                      TextButton(onPressed: ()async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        Provider.of<OrderProvider>(context,listen: false).closeorder();
                        Provider.of<CartProvider>(context,listen: false).clear_cart();
              //          Freshchat.resetUser();
                        logout().then((value) {
                          prefs.clear();

                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/Pages', (Route<dynamic> route) => false,
                              arguments: 1);
                        });

                      }, child: Text("Yes")),
                      TextButton(onPressed: () {

                        Navigator.pop(context);
                      }, child: Text("No")),

                    ],);
                },);

              } else {
                Navigator.of(context).pushNamed('/Login');
              }
            },
            leading: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              currentUser.value.apiToken != null
                  ? S.of(context).log_out
                  : S.of(context).login,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          currentUser.value.apiToken == null
              ? ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed('/SignUp');
                  },
                  leading: Icon(
                    Icons.person_add,
                    color: Theme.of(context).focusColor.withOpacity(1),
                  ),
                  title: Text(
                    S.of(context).register,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                )
              : SizedBox(height: 0),

        ],
      ),
    );
  }

  Future<void> fetchTicketDetails(String supportTicketId) async {

    print("DS>>> "+supportTicketId);
    final String apiUrl = 'https://comeeathome.com/app/api/support/detail';

    final Map<String, dynamic> requestBody = {
      "support_ticket_id": supportTicketId,
      "custom_name": "testing",
    };
  /*  print('Request URL: $apiUrl');
    print('Request Headers: ${{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiToken',
    }}');*/
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiToken',
      },
      body: jsonEncode(requestBody),
    );

    //print('Request Body:'+ jsonEncode(requestBody));
    if (response.statusCode == 200) {
      print("Response>>> "+response.body.toString());
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['success']) {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => HelpAndSupportForm()
        //   ),
        // );
        final List<dynamic> ticketDataList = responseData['data'];

        if (ticketDataList.isNotEmpty) {
          final Map<String, dynamic> ticketData = ticketDataList[0];

          // Access the data from the response
          print('Ticket ID: ${ticketData['ticket_status']}');
          print('Ticket Reference ID: ${ticketData['ticket_ref_id']}');
          print('Title: ${ticketData['title']}');
          print('Description: ${ticketData['description']}');

          if(ticketData['ticket_status'].toString()=="3"){
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HelpAndSupportForm()
              ),
            );
          }
          if(ticketData['ticket_status'].toString() == "1" ||
              ticketData['ticket_status'].toString() == "2"){
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatScreen()
              ),
            );
          }

          // Add more fields as needed
        } else {
          print('No ticket data found.');
        }
      } else {
        print('API call failed. Message: ${responseData['message']}');
      }
    } else {
      print('Failed to fetch ticket details. Status code: ${response.statusCode}');
      print('Failed to fetch ticket details. response: ${response.body.toString()}');

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatScreen()
        ),
      );
    }
  }

  createChat()
  {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => HelpAndSupportForm()
      ),
    );

  }
}
