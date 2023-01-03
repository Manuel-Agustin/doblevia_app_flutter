import 'dart:core';
import 'package:flutter/material.dart';

ValueNotifier<String> languageNotifier = ValueNotifier('ca');

class AppFonts {
  static TextStyle h1 = const TextStyle(fontSize: 36);
  static TextStyle h2 = const TextStyle(fontSize: 30);
  static TextStyle h3 = const TextStyle(fontSize: 24);
  static TextStyle h4 = const TextStyle(fontSize: 18);
  static TextStyle h5 = const TextStyle(fontSize: 16);
  static TextStyle button = const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600);
  static TextStyle p = const TextStyle(fontSize: 14);
}

class AppColors {
  static const Color red = Color(0xffed5565);
  static const Color base = Color.fromRGBO(225, 30, 30, 1);
  static const Color primary = Color(0xff559945); // Color(0xff505065);
  static const Color secondary = Color(0xffFF9933);
  static const Color blue = Color(0xff1c84c6);
}

class Constants {
  static String appCode = 'dv_com';
  static String privateKey = 't6qvqJeC==cxMHvE3H8';
  static String redirectionBase = 'https://inscripcions.doblevia.coop';
  static String apiUrl = '$redirectionBase/api/';
  static String token = 'FCM_TOKEN';
  static String isLoggedIn = 'IS_LOGGED_IN';
  static String username = 'USERNAME';
  static String password = 'PASSWORD';
  static String esProfesor = 'IS_PROFESSOR';
  static String language = 'LANGUAGE';
  static String merchantId = 'MERCHANT_ID';
  static String merchantUrl = '${apiUrl}respuestatransaccion.ashx';
}

class FunctionNames {
  static String userValidate = 'user_validate';
  static String getChildren = 'get_children';
  static String getServices = 'get_services';
  static String getCalendar = 'get_calendar';
  static String bookService = 'book_service';
  static String userSetLanguage = 'user_set_language';
  static String getNotifications = 'get_notifications';
  static String setNotification = 'set_notification';
  static String archiveNotification = 'archive_notification';
  static String getUserData = 'get_user_data';
  static String deleteToken = 'delete_token';
  static String userDisable = 'user_disable';
}