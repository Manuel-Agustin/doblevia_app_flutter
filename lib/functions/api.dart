import 'dart:convert';
import 'dart:io';

import 'package:doblevia/functions/preferences.dart';
import 'package:doblevia/models/login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:crypto/crypto.dart';

import '../globals.dart';

String sign(String f, String username) {
  String appCode = Constants.appCode;
  var signInBytes = utf8.encode(appCode + f + username + Constants.privateKey);
  var sign = sha256.convert(signInBytes);

  return sign.toString().toUpperCase();
}

Future<LoginResponse> login(BuildContext context, String username, String password, String token) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String appCode = Constants.appCode;
  String f = FunctionNames.userValidate;
  String ncPlatform = Platform.operatingSystem;
  String ncPlatformVersion = Platform.operatingSystemVersion;
  String ncAppVersion = packageInfo.version;

  LoginRequest request = LoginRequest(
    appCode: appCode,
    f: f,
    username: username,
    password: password,
    sign: sign(f, username),
    notificationsToken: token,
    ncPlatform: ncPlatform,
    ncPlatformVersion: ncPlatformVersion,
    ncAppVersion: ncAppVersion
  );

  if (kDebugMode) print('DVLOG: request: ${json.encode(request.toJson())}');
  if (kDebugMode) print('DVLOG: request url: ${Constants.apiUrl}?${request.toGetString()}');

  /*final response = await http.post(Uri.parse(Constants.apiUrl),
    headers: <String, String>{
      'Content-Type': 'multipart/form-data', //'application/json; charset=UTF-8',
    },
    body: json.encode(request.toJson())
  );*/


  final response = await http.get(Uri.parse('${Constants.apiUrl}?${request.toGetString()}'));

  if (kDebugMode) {
    print('REQUEST: ');
    print(response.request);
    print('RESPONSE: ');
    print(response.statusCode);
    print(response.body.toString());
    print(response.headers.toString());
  }

  if (response.statusCode == 200) {
    LoginResponse r = LoginResponse.fromJson(jsonDecode(response.body)[0]);
    return r;
  } else {
    if (kDebugMode) print('Status code: ${response.statusCode}');
    throw Exception('Failed to login: ${response.statusCode}');
  }
}

Future<ChildResponse> getChildren(BuildContext context) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String appCode = Constants.appCode;
  String f = FunctionNames.getChildren;
  String username = await getUsername();
  String password = await getPassword();
  String ncAppVersion = packageInfo.version;

  BasicRequest request = BasicRequest(
      appCode: appCode,
      f: f,
      username: username,
      password: password,
      sign: sign(f, username),
      //ncAppVersion: ncAppVersion
  );

  if (kDebugMode) print('DVLOG: request: ${json.encode(request.toJson())}');

  /*final response = await http.post(Uri.parse(Constants.apiUrl),
    headers: <String, String>{
      'Content-Type': 'multipart/form-data', //'application/json; charset=UTF-8',
    },
    body: json.encode(request.toJson())
  );*/

  final response = await http.get(Uri.parse('${Constants.apiUrl}?${request.toGetString()}'));

  if (kDebugMode) {
    print('REQUEST: ');
    print(response.request);
    print('RESPONSE: ');
    print(response.statusCode);
    print(response.body.toString());
    print(response.headers.toString());
  }

  if (response.statusCode == 200) {
    return ChildResponse.fromJson(jsonDecode(response.body));
  } else {
    if (kDebugMode) print('Status code: ${response.statusCode}');
    throw Exception('Failed to login: ${response.statusCode}');
  }
}

Future<ServiceResponse> getServices(BuildContext context, String childCode) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String appCode = Constants.appCode;
  String f = FunctionNames.getServices;
  String username = await getUsername();
  String password = await getPassword();
  String ncAppVersion = packageInfo.version;

  ChildCodeRequest request = ChildCodeRequest(
    appCode: appCode,
    f: f,
    username: username,
    password: password,
    sign: sign(f, username),
    childCode: childCode,
    ncAppVersion: ncAppVersion
  );

  if (kDebugMode) print('DVLOG: request: ${json.encode(request.toJson())}');

  /*final response = await http.post(Uri.parse(Constants.apiUrl),
    headers: <String, String>{
      'Content-Type': 'multipart/form-data', //'application/json; charset=UTF-8',
    },
    body: json.encode(request.toJson())
  );*/

  final response = await http.get(Uri.parse('${Constants.apiUrl}?${request.toGetString()}'));

  if (kDebugMode) {
    print('REQUEST: ');
    print(response.request);
    print('RESPONSE: ');
    print(response.statusCode);
    print(response.body.toString());
    //print(response.headers.toString());
  }

  if (response.statusCode == 200) {
    if (response.body.isNotEmpty) {
      return ServiceResponse.fromJson(jsonDecode(response.body));
    } else {
      return ServiceResponse(errorCode: '', errorMsg: '', services: []);
    }
  } else {
    if (kDebugMode) print('Status code: ${response.statusCode}');
    throw Exception('Failed to $f: ${response.statusCode}');
  }
}

Future<CalendarResponse> getCalendar(BuildContext context, String childCode, String serviceCode, String month, String year) async {
  String appCode = Constants.appCode;
  String f = FunctionNames.getCalendar;
  String username = await getUsername();
  String password = await getPassword();

  CalendarRequest request = CalendarRequest(
    appCode: appCode,
    f: f,
    username: username,
    password: password,
    sign: sign(f, username),
    childCode: childCode,
    serviceCode: serviceCode,
    month: month,
    year: year
  );

  if (kDebugMode) print('DVLOG: request: ${json.encode(request.toJson())}');

  /*final response = await http.post(Uri.parse(Constants.apiUrl),
    headers: <String, String>{
      'Content-Type': 'multipart/form-data', //'application/json; charset=UTF-8',
    },
    body: json.encode(request.toJson())
  );*/

  final response = await http.get(Uri.parse('${Constants.apiUrl}?${request.toGetString()}'));

  if (kDebugMode) {
    print('REQUEST: ');
    print(response.request);
    print('RESPONSE: ');
    print(response.statusCode);
    print(response.body.toString());
    //print(response.headers.toString());
  }

  if (response.statusCode == 200) {
    CalendarResponse r = CalendarResponse.fromJson(jsonDecode(response.body)[0]);
    return r;
  } else {
    if (kDebugMode) print('Status code: ${response.statusCode}');
    throw Exception('Failed to login: ${response.statusCode}');
  }
}

Future<BookServiceResponse> bookService(BuildContext context, String childCode, String serviceCode, String transactionCode, List<String> dates, String comments, bool success) async {
  String appCode = Constants.appCode;
  String f = FunctionNames.bookService;
  String username = await getUsername();
  String password = await getPassword();

  BookServiceRequest request = BookServiceRequest(
      appCode: appCode,
      f: f,
      username: username,
      password: password,
      sign: sign(f, username),
      childCode: childCode,
      serviceCode: serviceCode,
      transactionCode: transactionCode,
      dates: dates.toString().replaceAll(' ', ''),
      comments: comments,
      success: success ? 1 : 0
  );

  if (kDebugMode) print('DVLOG: request: ${json.encode(request.toJson())}');

  /*final response = await http.post(Uri.parse(Constants.apiUrl),
    headers: <String, String>{
      'Content-Type': 'multipart/form-data', //'application/json; charset=UTF-8',
    },
    body: json.encode(request.toJson())
  );*/

  final response = await http.get(Uri.parse('${Constants.apiUrl}?${request.toGetString()}'));

  if (kDebugMode) {
    print('REQUEST: ');
    print(response.request);
    print('RESPONSE: ');
    print(response.statusCode);
    print(response.body.toString());
  }

  if (response.statusCode == 200) {
    BookServiceResponse r = BookServiceResponse.fromJson(jsonDecode(response.body)[0]);
    return r;
  } else {
    if (kDebugMode) print('Status code: ${response.statusCode}');
    throw Exception('Failed to book service: ${response.statusCode}');
  }
}

Future<BasicSuccessResponse> userSetLanguage(BuildContext context, String language) async {
  String appCode = Constants.appCode;
  String f = FunctionNames.userSetLanguage;
  String username = await getUsername();
  String password = await getPassword();

  UserSetLanguageRequest request = UserSetLanguageRequest(
      appCode: appCode,
      f: f,
      username: username,
      password: password,
      sign: sign(f, username),
      language: language
  );

  if (kDebugMode) print('DVLOG: request: ${json.encode(request.toJson())}');

  /*final response = await http.post(Uri.parse(Constants.apiUrl),
    headers: <String, String>{
      'Content-Type': 'multipart/form-data', //'application/json; charset=UTF-8',
    },
    body: json.encode(request.toJson())
  );*/

  final response = await http.get(Uri.parse('${Constants.apiUrl}?${request.toGetString()}'));

  if (kDebugMode) {
    print('REQUEST: ');
    print(response.request);
    print('RESPONSE: ');
    print(response.statusCode);
    print(response.body.toString());
    //print(response.headers.toString());
  }

  if (response.statusCode == 200) {
    BasicSuccessResponse r = BasicSuccessResponse.fromJson(jsonDecode(response.body)[0]);
    return r;
  } else {
    if (kDebugMode) print('Status code: ${response.statusCode}');
    throw Exception('Failed to login: ${response.statusCode}');
  }
}

Future<NotificationResponse> getNotifications(BuildContext context) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String appCode = Constants.appCode;
  String f = FunctionNames.getNotifications;
  String username = await getUsername();
  String password = await getPassword();
  String token = await getToken();
  String ncAppVersion = packageInfo.version;
  debugPrint("NCLOG TOKEN: $token");

  GetNotificationsRequest request = GetNotificationsRequest(
    appCode: appCode,
    f: f,
    username: username,
    password: password,
    sign: sign(f, username),
    token: token,
    ncAppVersion: ncAppVersion
  );

  if (kDebugMode) print('DVLOG: get_notifications request: ${json.encode(request.toGetString())}');

  /*final response = await http.get(
    Uri.parse(Constants.apiUrl),
    headers: <String, String>{
      //'content-type': 'application/json; charset=UTF-8',
      //HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.acceptHeader: '*',
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    },
    body: json.encode(request.toJson())
  );*/

  //final response = await http.post(Uri.parse('${Constants.apiUrl}?${request.toGetString()}'), body: json.encode(request.toJson()));
  final response = await http.get(Uri.parse('${Constants.apiUrl}?${request.toGetString()}'));

  if (kDebugMode) {
    print('REQUEST: ');
    print(response.request);

    print('RESPONSE: ');
    print(response.statusCode);
    print(response.body.toString());
  }

  if (response.statusCode == 200) {
    return NotificationResponse.fromJson(jsonDecode(response.body));
  } else {
    if (kDebugMode) print('Status code: ${response.statusCode}');
    throw Exception('Failed to login: ${response.statusCode}');
  }
}

Future<ArchiveResponse> archiveNotification(BuildContext context, int notificationCode, bool file) async {
  String appCode = Constants.appCode;
  String f = FunctionNames.archiveNotification;
  String username = await getUsername();
  String password = await getPassword();

  ArchiveRequest request = ArchiveRequest(
      appCode: appCode,
      f: f,
      username: username,
      password: password,
      sign: sign(f, username),
      notificationCode: '$notificationCode',
      isArchived: file ? '1' : '0'
  );

  if (kDebugMode) print('DVLOG: request: ${json.encode(request.toJson())}');

  /*final response = await http.post(Uri.parse(Constants.apiUrl),
    headers: <String, String>{
      'Content-Type': 'multipart/form-data', //'application/json; charset=UTF-8',
    },
    body: json.encode(request.toJson())
  );*/

  final response = await http.get(Uri.parse('${Constants.apiUrl}?${request.toGetString()}'));

  if (kDebugMode) {
    print('REQUEST: ');
    print(response.request);
    print('RESPONSE: ');
    print(response.statusCode);
    print(response.body.toString());
    //print(response.headers.toString());
  }

  if (response.statusCode == 200) {
    ArchiveResponse r = ArchiveResponse.fromJson(jsonDecode(response.body)[0]);
    return r;
  } else {
    if (kDebugMode) print('Status code: ${response.statusCode}');
    throw Exception('Failed to login: ${response.statusCode}');
  }
}

Future<GetUserDataResponse> getUserData(BuildContext context) async {
  String appCode = Constants.appCode;
  String f = FunctionNames.getUserData;
  String username = await getUsername();
  String password = await getPassword();

  BasicRequest request = BasicRequest(
    appCode: appCode,
    f: f,
    username: username,
    password: password,
    sign: sign(f, username)
  );

  if (kDebugMode) print('DVLOG: request: ${json.encode(request.toJson())}');

  /*final response = await http.post(Uri.parse(Constants.apiUrl),
    headers: <String, String>{
      'Content-Type': 'multipart/form-data', //'application/json; charset=UTF-8',
    },
    body: json.encode(request.toJson())
  );*/

  final response = await http.get(Uri.parse('${Constants.apiUrl}?${request.toGetString()}'));

  if (kDebugMode) {
    print('REQUEST: ');
    print(response.request);
    print('RESPONSE: ');
    print(response.statusCode);
    print(response.body.toString());
    //print(response.headers.toString());
  }

  if (response.statusCode == 200) {
    GetUserDataResponse r = GetUserDataResponse.fromJson(jsonDecode(response.body)[0]);
    return r;
  } else {
    if (kDebugMode) print('Status code: ${response.statusCode}');
    throw Exception('Failed to login: ${response.statusCode}');
  }
}

Future<BasicSuccessResponse> deleteToken(BuildContext context) async {
  String appCode = Constants.appCode;
  String f = FunctionNames.deleteToken;
  String username = await getUsername();
  String password = await getPassword();
  String token = await getToken();

  LoginRequest request = LoginRequest(
      appCode: appCode,
      f: f,
      username: username,
      password: password,
      sign: sign(f, username),
      notificationsToken: token
  );

  if (kDebugMode) print('DVLOG: request: ${json.encode(request.toJson())}');

  /*final response = await http.post(Uri.parse(Constants.apiUrl),
    headers: <String, String>{
      'Content-Type': 'multipart/form-data', //'application/json; charset=UTF-8',
    },
    body: json.encode(request.toJson())
  );*/

  final response = await http.get(Uri.parse('${Constants.apiUrl}?${request.toGetShortString()}'));

  if (kDebugMode) {
    print('REQUEST: ');
    print(response.request);
    print('RESPONSE: ');
    print(response.statusCode);
    print(response.body.toString());
    //print(response.headers.toString());
  }

  if (response.statusCode == 200) {
    BasicSuccessResponse r = BasicSuccessResponse.fromJson(jsonDecode(response.body)[0]);
    return r;
  } else {
    if (kDebugMode) print('Status code: ${response.statusCode}');
    throw Exception('Failed to login: ${response.statusCode}');
  }
}

Future<int> userDisable(BuildContext context) async {
  String appCode = Constants.appCode;
  String f = FunctionNames.userDisable;
  String username = await getUsername();
  String password = await getPassword();
  String token = await getToken();

  LoginRequest request = LoginRequest(
      appCode: appCode,
      f: f,
      username: username,
      password: password,
      sign: sign(f, username),
      notificationsToken: token
  );

  if (kDebugMode) print('DVLOG: request: ${json.encode(request.toJson())}');

  /*final response = await http.post(Uri.parse(Constants.apiUrl),
    headers: <String, String>{
      'Content-Type': 'multipart/form-data', //'application/json; charset=UTF-8',
    },
    body: json.encode(request.toJson())
  );*/

  final response = await http.get(Uri.parse('${Constants.apiUrl}?${request.toGetShortString()}'));

  if (kDebugMode) {
    print('REQUEST: ');
    print(response.request);
    print('RESPONSE: ');
    print(response.statusCode);
    print(response.body.toString());
    //print(response.headers.toString());
  }

  if (response.statusCode == 200) {
    return 200;
  } else {
    if (kDebugMode) print('Status code: ${response.statusCode}');
    throw Exception('Failed to login: ${response.statusCode}');
  }
}

Future<String> getMinVersion(BuildContext context) async {
  String appCode = Constants.appCode;
  String f = FunctionNames.getMinVersion;
  String username = await getUsername();
  String password = await getPassword();

  BasicRequest request = BasicRequest(
      appCode: appCode,
      f: f,
      username: username,
      password: password,
      sign: sign(f, username)
  );

  if (kDebugMode) print('DVLOG: request: ${json.encode(request.toJson())}');

  final response = await http.get(Uri.parse('${Constants.apiUrl}?${request.toGetString()}'));

  if (kDebugMode) {
    print('REQUEST: ');
    print(response.request);
    print('RESPONSE: ');
    print(response.statusCode);
    print(response.body.toString());
    //print(response.headers.toString());
  }

  if (response.statusCode == 200) {
    return jsonDecode(response.body)[0]['ncVersionMinima'];
  } else {
    if (kDebugMode) print('Status code: ${response.statusCode}');
    throw Exception('Failed to login: ${response.statusCode}');
  }
}



// NO USAR
Future<CalendarResponse> setNotification(BuildContext context, String childCode, String serviceCode, String month, String year) async {
  String appCode = Constants.appCode;
  String f = FunctionNames.getCalendar;
  String username = await getUsername();
  String password = await getPassword();

  CalendarRequest request = CalendarRequest(
      appCode: appCode,
      f: f,
      username: username,
      password: password,
      sign: sign(f, username),
      childCode: childCode,
      serviceCode: serviceCode,
      month: month,
      year: year
  );

  if (kDebugMode) print('DVLOG: request: ${json.encode(request.toJson())}');

  /*final response = await http.post(Uri.parse(Constants.apiUrl),
    headers: <String, String>{
      'Content-Type': 'multipart/form-data', //'application/json; charset=UTF-8',
    },
    body: json.encode(request.toJson())
  );*/

  final response = await http.get(Uri.parse('${Constants.apiUrl}?${request.toGetString()}'));

  if (kDebugMode) {
    print('REQUEST: ');
    print(response.request);
    print('RESPONSE: ');
    print(response.statusCode);
    print(response.body.toString());
    //print(response.headers.toString());
  }

  if (response.statusCode == 200) {
    CalendarResponse r = CalendarResponse.fromJson(jsonDecode(response.body)[0]);
    return r;
  } else {
    if (kDebugMode) print('Status code: ${response.statusCode}');
    throw Exception('Failed to login: ${response.statusCode}');
  }
}
