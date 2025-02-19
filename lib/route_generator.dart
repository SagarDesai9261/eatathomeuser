import 'package:flutter/material.dart';
import 'package:food_delivery_app/my_widget/calendar_widget_withoutRestId.dart';
import 'package:food_delivery_app/src/elements/track_order_delivery.dart';
import 'package:food_delivery_app/src/pages/checkoutPage.dart';
import 'package:food_delivery_app/src/pages/notifications.dart';
import 'package:food_delivery_app/src/pages/orderStatus.dart';
import 'package:food_delivery_app/src/pages/orders.dart';
import 'package:food_delivery_app/src/pages/pick_address.dart';
import 'package:food_delivery_app/src/pages/tracking_for_dine_in.dart';

import 'src/models/route_argument.dart';
import 'src/pages/cart.dart';
import 'src/pages/category.dart';
import 'src/pages/chat.dart';
import 'src/pages/checkout.dart';
import 'src/pages/debug.dart';
import 'src/pages/deliveryPage.dart';
import 'src/pages/delivery_addresses.dart';
import 'src/pages/delivery_pickup.dart';
import 'src/pages/details.dart';
import 'src/pages/dinein_summary_page.dart';
import 'src/pages/favorites.dart';
import 'src/pages/food.dart';
import 'src/pages/forget_password.dart';
import 'src/pages/help.dart';
import 'src/pages/home.dart';
import 'src/pages/languages.dart';
import 'src/pages/login.dart';
import 'src/pages/map.dart';
import 'src/pages/menu_list.dart';
import 'src/pages/messages.dart';
import 'src/pages/order_success.dart';
import 'src/pages/pages.dart';
import 'src/pages/paymentPage.dart';
import 'src/pages/payment_methods.dart';
import 'src/pages/paypal_payment.dart';
import 'src/pages/profile.dart';
import 'src/pages/razorpay_payment.dart';
import 'src/pages/reviews.dart';
import 'src/pages/settings.dart';
import 'src/pages/signup.dart';
import 'src/pages/splash_screen.dart';
import 'src/pages/tracking.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;
    switch (settings.name) {
      case '/Debug':
        return MaterialPageRoute(builder: (_) => DebugWidget(routeArgument: args as RouteArgument));
      case '/Splash':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/SignUp':
        return MaterialPageRoute(builder: (_) => SignUpWidget());
      case '/MobileVerification':
        return MaterialPageRoute(builder: (_) => SignUpWidget());
      case '/MobileVerification2':
        return MaterialPageRoute(builder: (_) => SignUpWidget());
      case '/Login':
        return MaterialPageRoute(builder: (_) => LoginWidget());
      /*case '/DineInSummay':
        return MaterialPageRoute(builder: (_) => DineInSummaryPage(rest: args as RouteArgument));*/
      case '/Profile':
        return MaterialPageRoute(builder: (_) => ProfileWidget());
      case '/ForgetPassword':
        return MaterialPageRoute(builder: (_) => ForgetPasswordWidget());
      case '/Pages':
        return MaterialPageRoute(builder: (_) => PagesWidget(currentTab: args));
      case '/Home':
        return MaterialPageRoute(builder: (_) => HomeWidget(currentTab: args));
      case '/Favorites':
        return MaterialPageRoute(builder: (_) => FavoritesWidget());
      case '/Chat':
        return MaterialPageRoute(builder: (_) => ChatWidget(routeArgument: args as RouteArgument));
      case '/Details':
        return MaterialPageRoute(builder: (_) => DetailsWidget(currentTab: args));
      case '/Menu':
        return MaterialPageRoute(builder: (_) => MenuWidget(routeArgument: args as RouteArgument));
      case '/Food':
        return MaterialPageRoute(builder: (_) => FoodWidget(routeArgument: args as RouteArgument));
      case '/Category':
        return MaterialPageRoute(builder: (_) => CategoryWidget(routeArgument: args as RouteArgument));
      case '/Cart':
        return MaterialPageRoute(builder: (_) => CartWidget(routeArgument: args as RouteArgument));
      case '/Tracking':
        return MaterialPageRoute(builder: (_) => TrackingWidget(routeArgument: args as RouteArgument));

        case '/TrackingForDinein':
        return MaterialPageRoute(builder: (_) => TrackingWidgetForDinein(routeArgument: args as RouteArgument));

      case '/Reviews':
        return MaterialPageRoute(builder: (_) => ReviewsWidget(routeArgument: args as RouteArgument));
      case '/notificationPage':
        return MaterialPageRoute(builder: (_) => NotificationsWidget());
      case '/PaymentMethod':
        return MaterialPageRoute(builder: (_) => PaymentMethodsWidget());
      case '/DeliveryAddresses':
        return MaterialPageRoute(builder: (_) => DeliveryAddressesWidget());
      case '/DeliveryPickup':
        return MaterialPageRoute(builder: (_) => DeliveryPickupWidget(routeArgument: args as RouteArgument));
      case '/Checkout':
        return MaterialPageRoute(builder: (_) => CheckoutWidget());
      case '/CashOnDelivery':
        return MaterialPageRoute(builder: (_) => OrderSuccessWidget(routeArgument: RouteArgument(param: 'Cash on Delivery')));
      case '/PayOnPickup':
        return MaterialPageRoute(builder: (_) => OrderSuccessWidget(routeArgument: RouteArgument(param: 'Pay on Pickup')));
      case '/PayPal':
        return MaterialPageRoute(builder: (_) => PayPalPaymentWidget(routeArgument: args as RouteArgument));
      case '/RazorPay':
        return MaterialPageRoute(builder: (_) => RazorPayPaymentWidget(routeArgument: args as RouteArgument));
      case '/OrderSuccess':
        return MaterialPageRoute(builder: (_) => orderStatus(routeArgument: args as RouteArgument));
      case '/Languages':
        return MaterialPageRoute(builder: (_) => LanguagesWidget());
      case '/Help':
        return MaterialPageRoute(builder: (_) => HelpWidget());
      case '/Settings':
        return MaterialPageRoute(builder: (_) => SettingsWidget());
      case '/directions':
        return MaterialPageRoute(builder: (_) => MapWidget());
      case '/paymentPage':
        return MaterialPageRoute(builder: (_) => PaymentPage());

      case '/messagePage':
        return MaterialPageRoute(builder: (_) => MessagesWidget());
      case '/deliveryPage':
        return MaterialPageRoute(builder: (_) => DeliveryPage());
      case '/checkoutPage':
        return MaterialPageRoute(builder: (_) => CheckoutPage());

      case '/orderPage':
        return MaterialPageRoute(builder: (_) => OrdersWidget());
      case '/calendar':
        return MaterialPageRoute(builder: (_) => CalendarDialogWithoutRestaurant());


        case '/PickAddress':
        return MaterialPageRoute(builder: (_) => PickAddressWidget());
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return MaterialPageRoute(builder: (_) => Scaffold(body: SafeArea(child: Text('Route Error'))));
    }
  }
}
