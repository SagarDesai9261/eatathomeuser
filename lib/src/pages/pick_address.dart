import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:mvc_pattern/mvc_pattern.dart';

import '../../utils/color.dart';
import '../controllers/delivery_addresses_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../models/address.dart';
import '../repository/settings_repository.dart' as settingsRepo;

class PickAddressWidget extends StatefulWidget {
  const PickAddressWidget({Key? key}) : super(key: key);

  @override
  _PickAddressWidgetState createState() => _PickAddressWidgetState();
}

class _PickAddressWidgetState extends StateMVC<PickAddressWidget> {
  DeliveryAddressesController? _con;

  _PickAddressWidgetState() : super(DeliveryAddressesController()) {
    _con = controller as DeliveryAddressesController?;
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(

    );
  }
}
