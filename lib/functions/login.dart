import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../models/login.dart';
import '../ui/home.dart';
import 'api.dart';
import 'preferences.dart';
import 'package:doblevia/globals.dart';

void callApiLogin(BuildContext context, String nif, String pass, String token) async {
  try {
    LoginResponse response = await login(context, nif, pass, token);

    if (response.userValid == true) {
      await saveStringSharedPreferences(Constants.username, nif);
      await saveStringSharedPreferences(Constants.password, pass);
      await saveBoolSharedPreferences(Constants.esProfesor, response.userEsProfesor == true);
      await saveStringSharedPreferences(Constants.language, response.userLanguage ?? '');
      await saveIntSharedPreferences(Constants.isLoggedIn, 1);

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Material(child: MyHomePage())),
              (_) => false
      );
    } else if (response.errorCode != '' || response.errorMsg != '') {
      String error = response.errorCode == '00005' ? translate('login.wrongData') : '${response.errorCode}: ${response.errorMsg}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate('login.tryLater')), backgroundColor: Colors.red),
      );
    }
  } catch (e) {
    debugPrint('DVLOG: $e');
  }
}