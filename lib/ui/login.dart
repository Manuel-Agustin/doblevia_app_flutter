import 'dart:ui';

import 'package:doblevia/functions/api.dart';
import 'package:doblevia/functions/preferences.dart';
import 'package:doblevia/models/login.dart';
import 'package:doblevia/ui/webview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../globals.dart';
import 'home.dart';

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({Key? key}) : super(key: key);

  @override
  State<MyLoginPage> createState() => _MyLoginPage();
}

class _MyLoginPage extends State<MyLoginPage> {
  final TextEditingController _nifController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  bool _passwordsVisible = false;

  String token = '';

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  void _loadToken() async {
    String t = await getToken();
    setState(() => token = t);
    print('DVLOG: token: $token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Image.asset('assets/images/login_register.png', width: double.infinity, height: double.infinity, fit: BoxFit.fitHeight),
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.white.withOpacity(0.8),
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Image.asset('assets/images/dobleviaescoles.png', height: 60),
                  const SizedBox(height: 16),
                  Text(translate('login.title'), style: AppFonts.h2),
                  const SizedBox(height: 12),
                  //Text(translate('login.user'), style: AppFonts.p),
                  TextField(controller: _nifController, decoration: InputDecoration(hintText: translate('login.userHint'))),
                  const SizedBox(height: 12),
                  //Text(translate('login.password'), style: AppFonts.p),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_passwordsVisible,
                    decoration: InputDecoration(
                      hintText: translate('login.passwordHint'),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _passwordsVisible = !_passwordsVisible),
                        child: Icon(_passwordsVisible ? Icons.visibility : Icons.visibility_off),
                      )
                    )
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: _loading ? null : _login,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.all(Radius.circular(6))
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(translate('login.login'), style: AppFonts.button)
                      ),
                    )
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => InAppWebViewPage(url: '${Constants.redirectionBase}/login?p=1', title: translate('login.recoverPassword')))
                      );
                    },
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.lock, color: AppColors.secondary, size: 14),
                      const SizedBox(width: 4),
                      Text(translate('login.forgotPassword'), style: const TextStyle(color: AppColors.secondary, fontSize: 14))
                    ])
                  ),
                  const SizedBox(height: 12),
                  Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: Wrap(alignment: WrapAlignment.center, children: [
                      Text(translate('login.notRegistered'), style: AppFonts.p),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => InAppWebViewPage(url: '${Constants.redirectionBase}/registre', title: translate('login.register')))
                          );
                        },
                        child: Text(translate('login.register'), style: const TextStyle(color: AppColors.secondary, fontSize: 14))
                      )
                    ]),
                  )
                ]),
              )
            )
          )
        ),
        _loading ? Container(
          color: Colors.white.withAlpha(100),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ) : Container()
      ])
    );
  }

  void _login() async {
    setState(() => _loading = true);

    int i = 0;
    while (token == '' && i < 20) {
      await Future.delayed(const Duration(milliseconds: 500));
      i++;
    }
    if (token == '') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate('login.tryLater')), backgroundColor: Colors.red),
      );
    } else {
      _callApi();
    }

    setState(() => _loading = false);
  }

  void _callApi() async {
    try {
      LoginResponse response = await login(context, _nifController.text, _passwordController.text, token);

      if (response.userValid == true) {
        await saveStringSharedPreferences(Constants.username, _nifController.text);
        await saveStringSharedPreferences(Constants.password, _passwordController.text);
        await saveBoolSharedPreferences(Constants.esProfesor, response.userEsProfesor == true);
        await saveStringSharedPreferences(Constants.language, response.userLanguage ?? '');
        await saveIntSharedPreferences(Constants.isLoggedIn, 1);

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Material(child: MyHomePage())),
                (_) => false
        );
      } else if (response.errorCode != '' || response.errorMsg != '') {
        if (!mounted) return;
        String error = response.errorCode == '00005' ? translate('login.wrongData') : '${response.errorCode}: ${response.errorMsg}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error: $error'), backgroundColor: Colors.red),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('DVLOG: $e');
    }
  }
}