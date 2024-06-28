import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery_app/my_widget/calendar_widget_withoutRestId.dart';
import 'package:food_delivery_app/src/controllers/home_controller.dart';
import 'package:food_delivery_app/src/pages/KitchenListDelivery.dart';
import 'package:food_delivery_app/src/pages/cart.dart';
import 'package:food_delivery_app/src/pages/home.dart';
import 'package:food_delivery_app/src/repository/translation_widget.dart';
import 'package:food_delivery_app/utils/color.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/l10n.dart';
import '../controllers/homr_test.dart';
import '../controllers/settings_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DrawerWidget.dart';
import '../elements/MobileVerificationBottomSheetWidget.dart';
import '../elements/PaymentSettingsDialog.dart';
import '../elements/ProfileSettingsDialog.dart';
import '../helpers/helper.dart';
import '../repository/user_repository.dart';
import 'orders.dart';

import '../repository/settings_repository.dart' as settingRepo;

class SettingsWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;
  final Function(int)? updateCurrentTab;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  dynamic currentTab;
  HomeController _con = HomeController();

  SettingsWidget({Key? key, this.parentScaffoldKey, this.updateCurrentTab})
      : super(key: key);

  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends StateMVC<SettingsWidget> {
  SettingsController? _con;
  String defaultLanguage = "";

  _SettingsWidgetState() : super(SettingsController()) {
    _con = controller as SettingsController?;
  }
  @override
  void initState() {
    super.initState();
    getCurrentDefaultLanguage();
  }

  getCurrentDefaultLanguage() async {
    settingRepo.getDefaultLanguageName().then((_langCode){
     // print("DS>> DefaultLanguageret "+_langCode);
      setState(() {
        defaultLanguage = _langCode;
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con!.scaffoldKey,
      drawer: DrawerWidget(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Builder(builder: (context) {
          return new IconButton(
              icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
              onPressed: () => Scaffold.of(context).openDrawer());
        }),
        title: Text(
          S.of(context).profile,
          style: Theme.of(context)
              .textTheme
              .headline6
              !.merge(TextStyle(letterSpacing: 1.3)),
        )
        /*TranslationWidget(
          message:  S.of(context).profile,
          fromLanguage: "English",
          toLanguage: defaultLanguage,
          builder: (translatedMessage) => Text(
            translatedMessage,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
          ),
        )*/,
      ),
      body: currentUser.value.id == null
          ? CircularLoadingWidget(height: 500)
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 7),
              child: Column(
                children: <Widget>[
                  /*  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SearchBarWidget(),
                    ),*/
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: [
                                  Text(
                                    currentUser.value.name,
                                    textAlign: TextAlign.left,
                                    style: Theme.of(context).textTheme.headline3,
                                  ),
                                  SizedBox(width: 5,),
                              currentUser.value.is_verified == "1"?    Image.asset("assets/img/profile_verified.png",height: 30,width: 30,) :SizedBox()
                                ],
                              )
                              /*TranslationWidget(
                                message: currentUser.value.name,
                                fromLanguage: "English",
                                toLanguage: defaultLanguage,
                                builder: (translatedMessage) => Text(
                                  translatedMessage,
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                              )*/,
                              Text(
                                currentUser.value.email,
                                style: Theme.of(context).textTheme.caption,
                              )
                              /*TranslationWidget(
                                message: currentUser.value.email,
                                fromLanguage: "English",
                                toLanguage: defaultLanguage,
                                builder: (translatedMessage) => Text(
                                  translatedMessage,
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              )*/,
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    height: 35,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        gradient: LinearGradient(
                                          colors: [
                                            kPrimaryColororange,
                                            kPrimaryColorLiteorange
                                          ],
                                        ),
                                      ),
                                      child: MaterialButton(
                                        onPressed: () {},
                                        disabledColor: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.5),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 1),
                                        child: Text(
                                          "User",
                                          textAlign: TextAlign.start,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              !.merge(TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor)),
                                        )
                                       /* TranslationWidget(
                                          message:  "Pro User",
                                          fromLanguage: "English",
                                          toLanguage: defaultLanguage,
                                          builder: (translatedMessage) => Text(
                                            translatedMessage,
                                            textAlign: TextAlign.start,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .merge(TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                          ),
                                        )*/,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    height: 35,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: Colors.grey),
                                      child: MaterialButton(
                                        onPressed: () {
                                          // Navigator.of(context).pushNamed('/orderPage', arguments: widget.parentScaffoldKey,);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrdersWidget(

                                              ),
                                            ),
                                          );
                                        },
                                        disabledColor: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.5),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 1),
                                        child: Text(
                                          "My Orders",
                                          textAlign: TextAlign.start,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              !.merge(TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor)),
                                        )
                                        /*TranslationWidget(
                                          message:   "My Orders",
                                          fromLanguage: "English",
                                          toLanguage: defaultLanguage,
                                          builder: (translatedMessage) => Text(
                                            translatedMessage,
                                            textAlign: TextAlign.start,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .merge(TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                          ),
                                        )*/,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                        ),
                        // SizedBox(
                        //     width: 55,
                        //     height: 55,
                        //     child: InkWell(
                        //       borderRadius: BorderRadius.circular(300),
                        //       onTap: () {
                        //         Navigator.of(context).pushNamed('/Profile');
                        //       },
                        //       child: CircleAvatar(
                        //         backgroundImage:
                        //             NetworkImage(currentUser.value.image.thumb),
                        //       ),
                        //     )),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                            color:
                                Theme.of(context).hintColor.withOpacity(0.15),
                            offset: Offset(0, 3),
                            blurRadius: 10)
                      ],
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      primary: false,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text(
                            S.of(context).profile_settings,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          trailing: ButtonTheme(
                            padding: EdgeInsets.all(0),
                            minWidth: 50.0,
                            height: 25.0,
                            child: ProfileSettingsDialog(
                              user: currentUser.value,
                              onChanged: (){
                                _con!.update(currentUser.value);
                              }
                            ),
                          ),
                        ),
                        ListTile(
                          onTap: () {},
                          dense: true,
                          title: Text(
                          "Full Name",
                            style: Theme.of(context).textTheme.bodyText2,
                          )
                          /*TranslationWidget(
                            message:  S.of(context).full_name,
                            fromLanguage: "English",
                            toLanguage: defaultLanguage,
                            builder: (translatedMessage) => Text(
                              translatedMessage,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          )*/,
                          trailing: Text(
                            currentUser.value.name,
                            style:
                                TextStyle(color: Theme.of(context).focusColor),
                          )
                          /*TranslationWidget(
                            message:  currentUser.value.name,
                            fromLanguage: "English",
                            toLanguage: defaultLanguage,
                            builder: (translatedMessage) => Text(
                              translatedMessage,
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          )*/,
                        ),
                        ListTile(
                          onTap: () {},
                          dense: true,
                          title: Text(
                            S.of(context).email,
                            style: Theme.of(context).textTheme.bodyText2,
                          )
                          /*TranslationWidget(
                            message:   S.of(context).email,
                            fromLanguage: "English",
                            toLanguage: defaultLanguage,
                            builder: (translatedMessage) => Text(
                              translatedMessage,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          )*/,
                          trailing: Text(
                            currentUser.value.email,
                            style:
                                TextStyle(color: Theme.of(context).focusColor),
                          )
                          /*TranslationWidget(
                            message:   currentUser.value.email,
                            fromLanguage: "English",
                            toLanguage: defaultLanguage,
                            builder: (translatedMessage) => Text(
                              translatedMessage,
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          )*/,
                        ),
                        ListTile(
                          onTap: () {},
                          dense: true,
                          title: Wrap(
                            spacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                S.of(context).phone,
                                style: Theme.of(context).textTheme.bodyText2,
                              )
                             /* TranslationWidget(
                                message:   S.of(context).phone,
                                fromLanguage: "English",
                                toLanguage: defaultLanguage,
                                builder: (translatedMessage) => Text(
                                  translatedMessage,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              )*/,
                              /*if (currentUser.value.phone.isNotEmpty)
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Theme.of(context).accentColor,
                                  size: 22,
                                )*/
                            ],
                          ),
                          trailing: Text(
                            currentUser.value.phone ?? "",
                            style:
                                TextStyle(color: Theme.of(context).focusColor),
                          )
                          /*TranslationWidget(
                            message:  currentUser.value.phone,
                            fromLanguage: "English",
                            toLanguage: defaultLanguage,
                            builder: (translatedMessage) => Text(
                              translatedMessage,
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          )*/,
                        ),
                        ListTile(
                          onTap: () {},
                          dense: true,
                          title: Text(
                            S.of(context).address,
                            style: Theme.of(context).textTheme.bodyText2,
                          )
                          /*TranslationWidget(
                            message: S.of(context).address,
                            fromLanguage: "English",
                            toLanguage: defaultLanguage,
                            builder: (translatedMessage) => Text(
                              translatedMessage,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          )*/,
                          trailing: Text(
                            Helper.limitString(currentUser.value.address ??
                                S.of(context).unknown),
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style:
                                TextStyle(color: Theme.of(context).focusColor),
                          )
                          /*TranslationWidget(
                            message: Helper.limitString(currentUser.value.address ??
                                S.of(context).unknown),
                            fromLanguage: "English",
                            toLanguage: defaultLanguage,
                            builder: (translatedMessage) => Text(
                              translatedMessage,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style:
                              TextStyle(color: Theme.of(context).focusColor),
                            ),
                          )*/,
                        ),
                        ListTile(
                          onTap: () {},
                          dense: true,
                          title: Text(
                            S.of(context).about,
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          trailing: Text(
                            currentUser.value.bio != null && currentUser.value.bio.length > 30
                                ? '${currentUser.value.bio.substring(0, 30)}...'
                                : currentUser.value.bio ?? "",
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyle(color: Theme.of(context).focusColor),
                          ),
                        )
                      ],
                    ),
                  ),
                  // Container(
                  //   margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  //   decoration: BoxDecoration(
                  //     color: Theme.of(context).primaryColor,
                  //     borderRadius: BorderRadius.circular(6),
                  //     boxShadow: [
                  //       BoxShadow(
                  //           color:
                  //               Theme.of(context).hintColor.withOpacity(0.15),
                  //           offset: Offset(0, 3),
                  //           blurRadius: 10)
                  //     ],
                  //   ),
                  //   child: ListView(
                  //     shrinkWrap: true,
                  //     primary: false,
                  //     children: <Widget>[
                  //       ListTile(
                  //         leading: Icon(Icons.credit_card),
                  //         title: Text(
                  //           S.of(context).payments_settings,
                  //           style: Theme.of(context).textTheme.bodyText1,
                  //         )
                  //         /*TranslationWidget(
                  //           message: S.of(context).payments_settings,
                  //           fromLanguage: "English",
                  //           toLanguage: defaultLanguage,
                  //           builder: (translatedMessage) => Text(
                  //             translatedMessage,
                  //             style: Theme.of(context).textTheme.bodyText1,
                  //           ),
                  //         )*/,
                  //         trailing: ButtonTheme(
                  //           padding: EdgeInsets.all(0),
                  //           minWidth: 50.0,
                  //           height: 25.0,
                  //           child: PaymentSettingsDialog(
                  //             creditCard: _con.creditCard,
                  //             onChanged: () {
                  //               _con.updateCreditCard(_con.creditCard);
                  //               //setState(() {});
                  //             },
                  //           ),
                  //         ),
                  //       ),
                  //       ListTile(
                  //         dense: true,
                  //         title: Text(
                  //           S.of(context).default_credit_card,
                  //           style: Theme.of(context).textTheme.bodyText2,
                  //         )
                  //         /*TranslationWidget(
                  //           message: S.of(context).default_credit_card,
                  //           fromLanguage: "English",
                  //           toLanguage: defaultLanguage,
                  //           builder: (translatedMessage) => Text(
                  //             translatedMessage,
                  //             style: Theme.of(context).textTheme.bodyText2,
                  //           ),
                  //         )*/,
                  //         trailing: Text(
                  //           _con.creditCard.number.isNotEmpty
                  //               ? _con.creditCard.number.replaceRange(
                  //                   0, _con.creditCard.number.length - 4, '...')
                  //               : '',
                  //           style:
                  //               TextStyle(color: Theme.of(context).focusColor),
                  //         )
                  //        /* TranslationWidget(
                  //           message: _con.creditCard.number.isNotEmpty
                  //               ? _con.creditCard.number.replaceRange(
                  //               0, _con.creditCard.number.length - 4, '...')
                  //               : '',
                  //           fromLanguage: "English",
                  //           toLanguage: defaultLanguage,
                  //           builder: (translatedMessage) => Text(
                  //             translatedMessage,
                  //             style:
                  //             TextStyle(color: Theme.of(context).focusColor),
                  //           ),
                  //         )*/,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                /*  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                            color:
                                Theme.of(context).hintColor.withOpacity(0.15),
                            offset: Offset(0, 3),
                            blurRadius: 10)
                      ],
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      primary: false,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.settings),
                          title: Text(
                            S.of(context).app_settings,
                            style: Theme.of(context).textTheme.bodyText1,
                          )
                          *//*TranslationWidget(
                            message:S.of(context).app_settings,
                            fromLanguage: "English",
                            toLanguage: defaultLanguage,
                            builder: (translatedMessage) => Text(
                              translatedMessage,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          )*//*,
                        ),
                       *//* ListTile(
                          onTap: () {
                            Navigator.of(context).pushNamed('/Languages');
                          },
                          dense: true,
                          title: Row(
                            children: <Widget>[
                              Icon(
                                Icons.translate,
                                size: 22,
                                color: Theme.of(context).focusColor,
                              ),
                              SizedBox(width: 10),
                              Text(
                                S.of(context).languages,
                                style: Theme.of(context).textTheme.bodyText2,
                              )
                             *//**//* TranslationWidget(
                                message: S.of(context).languages,
                                fromLanguage: "English",
                                toLanguage: defaultLanguage,
                                builder: (translatedMessage) => Text(
                                  translatedMessage,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              )*//**//*,
                            ],
                          ),
                          trailing: Text(
                            S.of(context).english,
                            style:
                                TextStyle(color: Theme.of(context).focusColor),
                          )
                          *//**//*TranslationWidget(
                            message: S.of(context).english,
                            fromLanguage: "English",
                            toLanguage: defaultLanguage,
                            builder: (translatedMessage) => Text(
                              translatedMessage,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          )*//**//*,
                        ),*//*
                       *//* ListTile(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed('/DeliveryAddresses');
                          },
                          dense: true,
                          title: Row(
                            children: <Widget>[
                              Icon(
                                Icons.place,
                                size: 22,
                                color: Theme.of(context).focusColor,
                              ),
                              SizedBox(width: 10),
                              *//**//*Text(
                                S.of(context).delivery_addresses,
                                style: Theme.of(context).textTheme.bodyText2,
                              )*//**//*
                              TranslationWidget(
                                message: S.of(context).delivery_addresses,
                                fromLanguage: "English",
                                toLanguage: defaultLanguage,
                                builder: (translatedMessage) => Text(
                                  translatedMessage,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ),
                            ],
                          ),
                        ),*//*
                        ListTile(
                          onTap: () {
                            Navigator.of(context).pushNamed('/Help');
                          },
                          dense: true,
                          title: Row(
                            children: <Widget>[
                              Icon(
                                Icons.help,
                                size: 22,
                                color: Theme.of(context).focusColor,
                              ),
                              SizedBox(width: 10),
                              *//*Text(
                                S.of(context).help_support,
                                style: Theme.of(context).textTheme.bodyText2,
                              )*//*
                              TranslationWidget(
                                message: S.of(context).help_support,
                                fromLanguage: "English",
                                toLanguage: defaultLanguage,
                                builder: (translatedMessage) => Text(
                                  translatedMessage,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),*/
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:   FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                  parentScaffoldKey: widget.parentScaffoldKey!,
                  currentTab: 1,
                  directedFrom: "forHome",
                )),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 56.0,
          height: 56.0,
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:Colors.white,

          ),
          child: Image.asset("assets/img/logo_bottom.png"),
        ),
      ),


      bottomNavigationBar:

      BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 5.0,
        height: 65,
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 70),
                child: IconButton(
                  icon: const Icon(
                    Icons.assignment,
                    size: 30,
                  ),
                  onPressed: () {
                    if (currentUser.value.apiToken != "") {
                      Navigator.of(context).pushNamed('/orderPage', arguments: 0);
                    } else {
                      Navigator.of(context).pushNamed('/Login');
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 30,
                ),
                onPressed: () {
                  if(currentUser.value.apiToken != ""){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartWidget(
                          parentScaffoldKey: widget.parentScaffoldKey,
                        ),
                      ),
                    );}
                  else{
                    Navigator.of(context).pushNamed('/Login');
                  }
                },
              ),
            ],
          ),
        ),
      )
      ,
    );
  }

  void _selectTab(int tabItem) {
    setState(() {
    //  print("DS>> am i here?? " + tabItem.toString());
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          if (currentUser.value.apiToken != "") {
            Navigator.of(context).pushNamed('/orderPage', arguments: 0);
          } else {
            Navigator.of(context).pushNamed('/Login');
          }


          break;
        case 4:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CalendarDialogWithoutRestaurant()
            ),
          );
          break;
        case 1:
         /* Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomeWidget(
                      parentScaffoldKey: widget.scaffoldKey,
                      currentTab: tabItem,
                      directedFrom: "forHome",
                    )),
          );*/

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(parentScaffoldKey: new GlobalKey(), directedFrom: "forHome",
                      currentTab: 1,)
            ),
          );
          break;
        case 3:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => KitchenListDeliveryWidget(
                      restaurantsList: widget._con.AllRestaurantsDelivery,
                      heroTag: "KitchenListDelivery",
                    )),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CartWidget(
                parentScaffoldKey: widget.scaffoldKey,
              ),
            ),
          );
          break;
      }
    });
  }
}
