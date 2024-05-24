import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../generated/l10n.dart';
import '../../my_widget/address_picker.dart';
import '../models/user.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart' as geolocator;

class ProfileSettingsDialog extends StatefulWidget {
  final User user;
  final VoidCallback onChanged;

  ProfileSettingsDialog({Key key, this.user, this.onChanged}) : super(key: key);

  @override
  _ProfileSettingsDialogState createState() => _ProfileSettingsDialogState();
}

class _ProfileSettingsDialogState extends State<ProfileSettingsDialog> {
  GlobalKey<FormState> _profileSettingsFormKey = new GlobalKey<FormState>();
  TextEditingController _addressController = TextEditingController();
  LatLng _selectedLocation;
  File _identityFile;

  Future<void> _getCurrentLocation() async {
    geolocator.Position position;

    try {
      position = await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
      );
    } catch (e) {
      print("Error getting current location: $e");
    }

    if (position != null) {
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.user.latitude == null) {
      _getCurrentLocation();
    } else {
      _selectedLocation = LatLng(widget.user.latitude, widget.user.longitude);
    }
    _addressController.text = widget.user.address ?? "";
  }

  @override
  Widget build(BuildContext context) {

    print(widget.user.latitude);
    return MaterialButton(
      elevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              titlePadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              title: Row(
                children: <Widget>[
                  Icon(Icons.person),
                  SizedBox(width: 10),
                  Text(
                    S.of(context).profile_settings,
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                ],
              ),
              children: <Widget>[
                Form(
                  key: _profileSettingsFormKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        new TextFormField(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.text,
                          decoration: getInputDecoration(
                              hintText: S.of(context).john_doe,
                              labelText: "Full Name"),
                          initialValue: widget.user.name,
                          enabled: true,
                          validator: (input) => input.trim().length < 3
                              ? S.of(context).not_a_valid_full_name
                              : null,
                          onSaved: (input) => widget.user.name = input,
                        ),
                        new TextFormField(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.emailAddress,
                          decoration: getInputDecoration(
                              hintText: 'johndo@gmail.com',
                              labelText: S.of(context).email_address),
                          initialValue: widget.user.email,
                          enabled: false,
                          validator: (input) => !input.contains('@')
                              ? S.of(context).not_a_valid_email
                              : null,
                          onSaved: (input) => widget.user.email = input,
                        ),
                        new TextFormField(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.emailAddress,
                          decoration: getInputDecoration(
                              hintText:  S.of(context).phone,
                              labelText:  S.of(context).phone),
                          initialValue: widget.user.phone,
                          enabled: true,
                          validator: (phoneNumber) {
                            if (phoneNumber == "") {
                              return S.of(context).not_a_valid_phone;
                            }
                            return null;
                          },
                          onSaved: (phone) {
                            widget.user.phone = phone;
                          },
                        ),
                        /*IntlPhoneField(
                          style: TextStyle(
                              color: Theme.of(context).hintColor, height: 1.5),
                          keyboardType: TextInputType.phone,
                          decoration: getInputDecoration(
                            hintText: S.of(context).phone,
                          ),
                          dropdownTextStyle: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                          dropdownIcon: Icon(
                            Icons.arrow_drop_down,
                            size: 20.0,
                            color: Theme.of(context).hintColor,
                          ),
                          showDropdownIcon: false,
                          initialValue: widget.user.phone,
                          validator: (phoneNumber) {
                            if (!phoneNumber.isValidNumber()) {
                              return S.of(context).not_a_valid_phone;
                            }
                            return null;
                          },
                          onChanged: (phone) {},
                          onSaved: (phone) {
                            widget.user.phone = phone.completeNumber;
                          },
                        ),*/
                        GestureDetector(
                          onTap: () async {
                            LatLng resultLocation =
                                await _openAddressSelectionMap();
                            if (resultLocation != null) {
                              String selectedAddress =
                                  await _getAddressFromLocation(resultLocation);
                              String selectedCountry =
                                  await _getCountryFromLocation(resultLocation);
                              setState(() {
                                _selectedLocation = resultLocation;

                                widget.user.address = selectedAddress;

                                _addressController.text = selectedAddress;
                                widget.user.latitude = resultLocation.latitude;
                                widget.user.longitude =
                                    resultLocation.longitude;
                                widget.user.country = selectedCountry;
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _addressController,
                              style:
                                  TextStyle(color: Theme.of(context).hintColor),
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: getInputDecoration(
                                hintText: S.of(context).your_address,
                                labelText: S.of(context).address,
                              ),
                              validator: (input) => input.trim().length < 3
                                  ? S.of(context).not_a_valid_address
                                  : null,
                              onSaved: (input) => widget.user.address = input,
                            ),
                          ),
                        ),
                        new TextFormField(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.multiline,
                          decoration: getInputDecoration(
                              hintText: S.of(context).your_biography,
                              labelText: S.of(context).about),
                          initialValue: widget.user.bio,
                          enabled: true,
                          maxLines: null,
                          validator: (input) => input.trim().length < 3
                              ? S.of(context).not_a_valid_biography
                              : null,
                          onSaved: (input) => widget.user.bio = input,
                        ),
                        SizedBox(height: 20),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Identity",
                          ),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: widget.user.image.url != null
                              ? // Display the uploaded image if available
                              Image.network(
                                  widget.user.image.url,
                                  height: 100,
                                  width: 150,
                                  fit: BoxFit.cover,
                                )
                              : // Display the upload button if no image is available
                              DottedBorder(
                                  dashPattern: [8, 4],
                                  strokeWidth: 2,
                                  padding: EdgeInsets.all(8),
                                  child: InkWell(
                                    onTap: () {
                                      _pickImage();
                                    },
                                    child: Container(
                                      height: 100,
                                      color: Colors.grey.withOpacity(0.5),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.upload, size: 30),
                                          Text(
                                              "Please upload Aadhar or Driving \n Licence  for verification"),
                                          _identityFile != null
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .check_circle_outline_outlined,
                                                        color: Colors.green),
                                                    Text("Image is Selected"),
                                                  ],
                                                )
                                              : Container()
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(height: 10),
                        /* _identityFile != null
                            ? Image.file(_identityFile, height: 100)
                            : ElevatedButton(
                                onPressed: _pickImage,
                                child: Text("upload_file"),
                              ),*/
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(S.of(context).cancel),
                    ),
                    MaterialButton(
                      onPressed: submit,
                      child: Text(
                        S.of(context).save,
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.end,
                ),
                SizedBox(height: 10),
              ],
            );
          },
        );
      },
      child: Text(
        S.of(context).edit,
        style: Theme.of(context).textTheme.bodyText2,
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _identityFile = File(pickedFile.path);
        widget.user.identity =
            _identityFile; // Assign the file to the user's identity property
      }
    });
  }

  Future<String> _getAddressFromLocation(LatLng location) async {
    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        return '${placemarks.first.name}, ${placemarks.first.locality}-${placemarks.first.postalCode}, ${placemarks.first.administrativeArea}';
      } else {
        return 'No address found';
      }
    } catch (e) {
      return 'Error getting address';
    }
  }

  Future<String> _getCountryFromLocation(LatLng location) async {
    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        return '${placemarks.first.country}';
      } else {
        return 'No address found';
      }
    } catch (e) {
      return 'Error getting address';
    }
  }

  Future<LatLng> _openAddressSelectionMap() async {
    LatLng resultLocation;
    String resultAddress;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MapScreen(
          initialLocation: _selectedLocation,
          onLocationSelected: (location, address) {
            resultLocation = location;
            resultAddress = address;
          },
        );
      },
    );

    return resultLocation;
  }

  InputDecoration getInputDecoration({String hintText, String labelText}) {
    return new InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: Theme.of(context).textTheme.bodyText2.merge(
            TextStyle(color: Theme.of(context).focusColor),
          ),
      enabledBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).hintColor)),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: Theme.of(context).textTheme.bodyText2.merge(
            TextStyle(color: Theme.of(context).hintColor),
          ),
    );
  }

  void submit() {
    if (_profileSettingsFormKey.currentState.validate()) {
      _profileSettingsFormKey.currentState.save();
      widget.onChanged();
      Navigator.pop(context);
    }
  }
}
