import 'package:doblevia/functions/preferences.dart';
import 'package:doblevia/globals.dart';
import 'package:doblevia/ui/home.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'ui/login.dart';
import 'package:doblevia/globals.dart' as globals;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  if (kDebugMode) debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  var delegate = await LocalizationDelegate.create(
      fallbackLocale: 'ca',
      supportedLocales: ['ca', 'es']);

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final String? fcmToken = await FirebaseMessaging.instance.getToken();
  if (kDebugMode) debugPrint('DVLOG: fcmToken = $fcmToken');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('Got a message whilst in the foreground! HELLO');
      debugPrint('Message data: ${message.data}');
    }

    if (App.materialKey.currentContext != null && message.notification != null) {
      ScaffoldMessenger.of(App.materialKey.currentContext!).showSnackBar(
        SnackBar(content: Text('${message.notification!.title}: ${message.notification!.body}')),
      );
    }

    if (message.notification != null) {
      if (kDebugMode) debugPrint('Message also contained a notification: ${message.notification}');
    }
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  saveStringSharedPreferences(Constants.token, fcmToken ?? '');

  bool isLoggedIn = await isLogged();

  final prefs = await SharedPreferences.getInstance();

  final String l = prefs.getString(Constants.language) ?? 'ca';
  debugPrint('shared prefs lang: $l');
  globals.languageNotifier.value = l;
  debugPrint('globals notifier lang: ${globals.languageNotifier.value}');

  if (kDebugMode) {
    debugPrint('DVLOG: is logged? ${isLoggedIn ? 'yes' : 'no'}');
  }

  runApp(LocalizedApp(delegate, MyApp(isLoggedIn: isLoggedIn)));
}

class App {
  static GlobalKey<NavigatorState> materialKey = GlobalKey();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);
  final bool isLoggedIn;

  static const Color base = AppColors.secondary;

  static Map<int, Color> color = {
    50: base.withOpacity(0.1),
    100: base.withOpacity(0.2),
    200: base.withOpacity(0.3),
    300: base.withOpacity(0.4),
    400: base.withOpacity(0.5),
    500: base.withOpacity(0.6),
    600: base.withOpacity(0.7),
    700: base.withOpacity(0.8),
    800: base.withOpacity(0.9),
    900: base.withOpacity(1.0),
  };

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doble Via',
      //locale: const Locale('ca'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorKey: App.materialKey, // GlobalKey()
      supportedLocales: const [
        Locale('es'),
        Locale('ca')
      ],
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: MaterialColor(0xff559945, color),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: Material(child: isLoggedIn ? const MyHomePage() : const MyLoginPage()),
    );
  }
}
