import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../globals.dart';

saveStringSharedPreferences(String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
  debugPrint('saved $value');
}

saveBoolSharedPreferences(String key, bool value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool(key, value);
  debugPrint('saved $value');
}

saveIntSharedPreferences(String key, int value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt(key, value);
  debugPrint('saved $value');
}

deleteAllPreferences() {
  saveIntSharedPreferences(Constants.isLoggedIn, 0);
  saveStringSharedPreferences(Constants.username, '');
  saveStringSharedPreferences(Constants.password, '');
}

Future<bool> isLogged() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var isLoggedIn = prefs.getInt(Constants.isLoggedIn) == 1;
  return isLoggedIn;
}

Future<String?> getMerchantId() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? merchantId = prefs.getString(Constants.merchantId);
  return merchantId;
}

Future<String> getUsername() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var username = prefs.getString(Constants.username);
  return username ?? '';
}

Future<String> getPassword() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var password = prefs.getString(Constants.password);
  return password ?? '';
}

Future<String> getToken() async {
  //final SharedPreferences prefs = await SharedPreferences.getInstance();
  //var password = prefs.getString(Constants.token);
  //return password ?? '';
  String token = await FirebaseMessaging.instance.getToken() ?? '';
  return token;
}

