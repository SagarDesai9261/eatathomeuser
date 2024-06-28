import 'package:flutter/material.dart';

import '../src/repository/settings_repository.dart' as settingRepo;
const Color kPrimaryColorLiteorange = Color(0xffe49630);
const Color kPrimaryColororange = Color(0xffc73c1b);
const Color kFBBlue = Color(0xff3b5998);
Color mainColor(double opacity) {
  try {
    return Color(int.parse(settingRepo.setting.value.mainColor.replaceAll("#", "0xFF"))).withOpacity(opacity);
  } catch (e) {
    return Color(0xFFCCCCCC).withOpacity(opacity);
  }
}
Color secondColor(double opacity) {
  try {
    return Color(int.parse(settingRepo.setting.value.secondColor.replaceAll("#", "0xFF"))).withOpacity(opacity);
  } catch (e) {
    return Color(0xFFCCCCCC).withOpacity(opacity);
  }
}
Color secondDarkColor(double opacity) {
  try {
    return Color(int.parse(settingRepo.setting.value.secondDarkColor.replaceAll("#", "0xFF"))).withOpacity(opacity);
  } catch (e) {
    return Color(0xFFCCCCCC).withOpacity(opacity);
  }
}