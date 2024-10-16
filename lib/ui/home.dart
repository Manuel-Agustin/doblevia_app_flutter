import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:doblevia/functions/api.dart';
import 'package:doblevia/models/redsys.dart';
import 'package:doblevia/ui/login.dart';
import 'package:doblevia/ui/userdata.dart';
import 'package:doblevia/ui/webview.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';
import 'package:intl/intl.dart';

import '../functions/preferences.dart';
import '../globals.dart';
import '../TPVVConstants.dart';
import '../models/dates.dart';
import '../models/login.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver, TickerProviderStateMixin {
  List<NotificationInfo> _notifications = [];
  List<NotificationInfo> _archived = [];

  static const platform = MethodChannel('com.doblevia.comunicacions/tpvv');

  final List<Child> _children = [];
  int _selectedChild = 0;
  final List<ServiceInfo> _services = [];
  int _selectedService = 0;
  DateTime _singleDate = DateTime.now();
  int _bookedDays = 0;

  bool _showCalendar = false;
  bool _calendarLoading = false;
  final List<DateTime> _selectedDates = [];
  int _monthShowing = DateTime.now().month;
  int _yearShowing = DateTime.now().year;
  final List<CalendarDate> _calendarDates = [];
  DateTime limit = DateTime.now();
  bool _conditionsAccepted = false;

  bool _loading = false;

  String username = '';
  String password = '';

  String? lang;
  bool _showLanguageDialog = false;
  bool _showNotificationDialog = false;
  NotificationInfo? currentNotification;
  final TextEditingController _commentsController = TextEditingController();

  late TabController _tabController;

  late AnimationController _bellController;
  late Animation<Color?> _bellColor;

  bool _rememberCard = false;
  bool _firstTimeRememberingCard = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _getNotifications();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(vsync: this, length: 3);
    _tabController.addListener(() {
      setState(() {});
    });

    changeLocale(context, languageNotifier.value);

    _getMinVersion();

    _firebaseInit();

    _getUserData();
    _getNotifications();
    _getChildren();

    //_tabController.addListener(() => _animateBell());
    _bellController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this
    )..repeat(reverse: true);

    // color tween
    _bellColor = ColorTween(begin: Colors.red, end: null).animate(CurvedAnimation(parent: _bellController, curve: Curves.easeInOutExpo));
  }

  void _showDialog() {
    showDialog(context: context, barrierDismissible: false, builder: (context) {
      return AlertDialog(
        title: Text(translate('main.updateAvailable')),
        content: Text(translate('main.updateBody')),
        actions: [
          TextButton(
              child: Text(translate('main.accept').toUpperCase()),
              onPressed: () {
                final appId = Platform.isAndroid ? 'com.doblevia.comunicacions' : '1636319799';
                final url = Uri.parse(
                  Platform.isAndroid
                      ? "https://play.google.com/store/apps/details?id=$appId"
                      : "https://apps.apple.com/app/id$appId",
                );
                launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                );
              }
          )
        ],
      );
    });
  }

  void _getMinVersion() async {
    WidgetsFlutterBinding.ensureInitialized();
    String minVersion = await getMinVersion(context);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    if (Version.parse(version) < Version.parse(minVersion)) {
      _showDialog();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  void _firebaseInit() async {
    WidgetsFlutterBinding.ensureInitialized();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('Got a message whilst in the foreground! I\'M IN NOTIFS');
        debugPrint('Message data: ${message.data}');
      }
      _getNotifications();
    });
  }

  Future<bool> _getNotifications() async {
    setState(() => _loading = true);
    NotificationResponse response = await getNotifications(context);
    List<NotificationInfo> notifs = response.notifications;
    List<NotificationInfo> a = [];
    List<NotificationInfo> n = [];

    for (var element in notifs) {
      if (element.isArchived) {
        a.add(element);
      } else {
        n.add(element);
      }
    }

    a.sort((a, b) => DateTime.parse(b.datetime).compareTo(DateTime.parse(a.datetime)));
    n.sort((a, b) => DateTime.parse(b.datetime).compareTo(DateTime.parse(a.datetime)));

    _archived = a;
    _notifications = n;
    _loading = false;
    setState(() {});

    //_animateBell();

    return true;
  }

  Future<void> _getUserData() async {
    username = await getUsername();
    password = await getPassword();
  }

  void _showScaffoldMessage(e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Catch: $e'), backgroundColor: Colors.red),
    );
  }

  void _getChildren() async {
    try {
      ChildResponse childResponse = await getChildren(context);
      List<Child> children = childResponse.children;
      if (children.first.childCode != null) {
        _children.clear();
        setState(() => _children.addAll(children));
        _getServices(_children[_selectedChild].childCode ?? '');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error code: ${children.first.errorCode}, error message: ${children.first.errorMsg}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      _showScaffoldMessage(e);
    }

    bool r = await getRememberCard();
    bool ft = await isFirstTimeRememberingCard();
    setState(() {
      _rememberCard = r;
      _firstTimeRememberingCard = ft;
    });
  }

  void _changeMonth() async {
    try {
      setState(() => _calendarLoading = true);

      if (_services[_selectedService].ncTieneFechaUnica) {
        _monthShowing = _singleDate.month;
        _yearShowing = _singleDate.year;
      }

      CalendarResponse response = await getCalendar(context, _children[_selectedChild].childCode!, _services[_selectedService].serviceCode, _monthShowing.toString(), _yearShowing.toString());
      if (response.limitTime != null) {
        List<int> holidays = [];
        response.holidays?.forEach((element) {
          DateTime day = DateTime.parse(element.ncFestivoDesde!);
          DateTime lastDay = DateTime.parse(element.ncFestivoHasta!);
          while (day.isBefore(lastDay.add(const Duration(days: 1)))) {
            if (day.month == _monthShowing) holidays.add(day.day);
            day = day.add(const Duration(days: 1));
          }
        });

        List<int> booked = [];
        response.bookedDays?.forEach((element) {
          booked.add(DateTime.parse(element.ncFechaServicio!).day);
        });
        setState(() => _bookedDays = booked.length);

        DateTime now = DateTime.now();

        _calendarDates.clear();
        _calendarDates.addAll(List.generate(DateTime(_yearShowing, _monthShowing, 1).weekday - 1, (index) =>
            CalendarDate(weekDay: -1, dayNumber: -1, dateTime: now, isPast: true, isHoliday: false, isBooked: false)
        ));

        DateTime l = DateTime(now.year, now.month, now.day);
        if (response.limitTime != null) {
          int addedMinutes = (response.limitTime! * 24 * 60).round();
          limit = l.add(Duration(minutes: addedMinutes));
        } else {
          limit = l;
        }
        if (kDebugMode) debugPrint('DVLOG: limit time: ${limit.toString()}');

        _calendarDates.addAll(List.generate(DateTime(_monthShowing == 12 ? _yearShowing + 1 : _yearShowing, _monthShowing == 12 ? 1 : _monthShowing + 1, 0).day, (index) {
          DateTime dt = DateTime(_yearShowing, _monthShowing, index + 1, now.hour, now.minute, now.second);

          return CalendarDate(
            weekDay: dt.weekday,
            dayNumber: dt.day,
            dateTime: dt,
            isPast: (dt.day == now.day && dt.month == now.month && dt.year == now.year) ? dt.isAfter(limit) : dt.isBefore(limit),
            isHoliday: holidays.contains(dt.day),
            isBooked: booked.contains(dt.day),
          );
        }));

        setState(() => _calendarLoading = false);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error code: ${response.errorCode}, error message: ${response.errorMsg}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Catch: $e');
    }
  }

  void _getServices(String childCode) async {
    debugPrint('dvlog: getting services fot child $childCode');
    try {
      ServiceResponse response = await getServices(context, childCode);
      debugPrint('dvlog: get services response: ${response.toString()}');
      List<ServiceInfo> services = [];
      response.services?.forEach((element) {
        services.addAll(element.services ?? []);
      });
      _services.clear();

      setState(() {
        _services.addAll(services);
      });
      debugPrint('dvlog: services count: ${_services.length}');
      if (services.isNotEmpty) {
        _changeMonth();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Catch: $e');
      _showScaffoldMessage(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> showLogOutDialog() async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(translate('main.logOut')),
            content: Text(translate('main.areYouSureLogOut')),
            actions: <Widget>[
              TextButton(
                onPressed: _loading ? null : () async {
                  Navigator.of(context).pop();
                },
                child: Text(translate('main.cancel')),
              ),
              TextButton(
                onPressed: _loading ? null : () async {
                  setState(() => _loading = true);
                  BasicSuccessResponse response = await deleteToken(context);
                  if (response.success != null && response.success == '1') {
                    await deleteAllPreferences();
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MyLoginPage()),
                            (_) => false
                    );
                  }
                  setState(() => _loading = false);
                },
                child: Text(translate('main.accept')),
              ),
            ],
          );
        },
      );
    }

    void handleClick(String value) async {
      if (value == 'main.changeLanguage') {
        if (kDebugMode) debugPrint('inside handle click change language');
        lang = languageNotifier.value;
        setState(() => _showLanguageDialog = true);
      } else if (value == 'main.logOut') {
        if (kDebugMode) debugPrint('inside handle click log out');
        showLogOutDialog();
      } else if (value == 'main.userData') {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserDataPage())
        );
      } else if (value == 'main.exit') {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      }
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/images/dobleviaescoles_white.png', height: 50),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: translate('main.inscriptions')),
              Tab(text: translate('main.sporadics')),
              Tab(child: Row(children: [
                Text(translate('main.notifications')),
                AnimatedBuilder(
                  animation: _bellColor,
                  builder: (BuildContext _, Widget? __) {
                    return Icon(Icons.notifications, size: _notifications.isEmpty ? 0 : 20, color: _bellColor.value);
                  },
                ),
              ])),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                Set<String> options = {'main.changeLanguage', 'main.userData', 'main.logOut'};
                //if (!Platform.isIOS) options.add('main.exit');
                return options.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) => Text(translate(choice))),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: Stack(children: [
          FutureBuilder(
            future: _webViewPage(),
            initialData: Container(),
            builder: (BuildContext context, AsyncSnapshot<Widget> widget) {
              return Container(child: widget.data);
            }
          ),
          _tabController.index == 0 ? Container()
          : _tabController.index == 1 ? Container(color: Colors.white, child: _bookingPage())
          : Container(color: Colors.white, child: _notificationsPage()),

          _showLanguageDialog ? _customDialog(
              () => setState(() => _showLanguageDialog = false),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 24, bottom: 20),
                    child: Text(translate('main.changeLanguage'), style: const TextStyle(fontSize: 20)),
                  ),

                  ListTile(
                    title: Text(translate('main.catalan')),
                    leading: Radio<String>(
                      value: 'ca',
                      groupValue: lang,
                      onChanged: (String? value) {
                        setState(() => lang = value ?? 'ca');
                        if (kDebugMode) {
                          debugPrint('dvlog: choosing language $value');
                        }
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(translate('main.spanish')),
                    leading: Radio<String>(
                      value: 'es',
                      groupValue: lang,
                      onChanged: (String? value) {
                        setState(() => lang = value ?? 'es');
                        if (kDebugMode) {
                          debugPrint('dvlog: choosing language $value');
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(
                      onPressed: _loading ? null : () async {
                        setState(() => _loading = true);
                        if (lang != null) languageNotifier.value = lang!;
                        try {
                          BasicSuccessResponse response = await userSetLanguage(context, languageNotifier.value);
                          if (response.success == '1') {
                            if (!mounted) return;
                            changeLocale(context, languageNotifier.value);
                            //saveStringSharedPreferences('locale', globals.languageNotifier.value);
                            saveStringSharedPreferences(Constants.language, languageNotifier.value);
                            setState(() {});
                            //_webViewController.reload();
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error code: ${response.errorCode}, error message: ${response.errorMsg}'), backgroundColor: Colors.red),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Catch: $e'), backgroundColor: Colors.red),
                          );
                        }
                        setState(() {
                          _loading = false;
                          _showLanguageDialog = false;
                        });
                      },
                      child: Text(translate('main.accept')),
                    ),
                    const SizedBox(width: 12)
                  ])
                ],
              )
          ) : Container(),

          _showNotificationDialog ? _customDialog(
              () => setState(() => _showNotificationDialog = false),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 24, bottom: 20, right: 24),
                    child: Text(translate('main.areYouSure', args: {'arg1': translate('main.fileLowercase'), 'arg2': currentNotification?.title}), style: const TextStyle(fontSize: 18)),
                  ),

                  const SizedBox(height: 12),

                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(
                      child: Text(translate('main.cancel')),
                      onPressed: () => setState(() => _showNotificationDialog = false),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      child: Text(translate('main.file')),
                      onPressed: () async {
                        setState(() => _loading = true);
                        ArchiveResponse response = await archiveNotification(context, currentNotification?.notificationCode ?? 0, true);
                        if (response.success) {
                          //r = true;
                          if (currentNotification != null) {
                            setState(() {
                              //_archived.add(currentNotification!);
                              //_notifications.remove(currentNotification!);
                              _showNotificationDialog = false;
                            });
                          }
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${currentNotification?.title} ${translate('main.filed')}')
                          ));
                          _getNotifications();
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Error'), backgroundColor: Colors.red),
                          );
                        }
                        setState(() => _loading = false);
                      },
                    ),
                    const SizedBox(width: 12)
                  ])
                ],
              )
          ) : Container(),

          _loading ? Container(
            color: Colors.white.withOpacity(0.6),
            width: double.infinity,
            height: double.infinity,
            child: const Center(child: CircularProgressIndicator())
          ) : Container()
        ]),
      )
    );
  }

  Widget _notificationsPage() {
    void navigateAndListen() async {
      // Navigator.push returns a Future that completes after calling
      // Navigator.pop on the Selection Screen.
      final result = await Navigator.push(
        context,
        // Create the SelectionScreen in the next step.
        MaterialPageRoute(builder: (context) => ArchivePage(archived: _archived, notifications: _notifications)),
      );

      setState(() {
        _archived = result[0];
        _notifications = result[1];
      });
    }

    Widget archivedButton() {
      return GestureDetector(
        onTap: () {
          if (_archived.isNotEmpty) navigateAndListen();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(24))
            ),
            padding: const EdgeInsets.all(12.0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const Icon(Icons.archive_outlined),
              const SizedBox(width: 8),
              Text(translate('main.archived'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Expanded(child: Container()),
              Text('${_archived.length} ', style: const TextStyle(color: AppColors.secondary))
            ]),
          )
        )
      );
    }

    Widget notificationCard(NotificationInfo notification) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(24))
          ),
          clipBehavior: Clip.hardEdge,
          child: Dismissible(
            key: Key(notification.title),
            confirmDismiss: (direction) async {
              //_dismiss(notification);
              setState(() {
                currentNotification = notification;
                _showNotificationDialog = true;
              });

              while (_showNotificationDialog) {
                await Future.delayed(const Duration(seconds: 1));
              }

              return false;
            },
            background: Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.all(Radius.circular(24))
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 18),
              child: const Icon(Icons.archive, color: Colors.white),
            ),
            secondaryBackground: Container(
              decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(24))
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 18),
              child: const Icon(Icons.archive, color: Colors.white),
            ),
            child: _notificationContainer(notification, context),
          )
        )
      );
    }

    return Container(
      color: Colors.black.withOpacity(0.05),
      child: ListView(
        children: [
          _archived.isEmpty ? Container() : archivedButton(),
          _notifications.isEmpty ? _emptyListMessage(false, context) : ListView(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 24),
            children: List.generate(_notifications.length, (index) =>
                notificationCard(_notifications[index])
            ),
          )
        ],
      )
    );
  }

  Future<Widget> _webViewPage() async {
    if (username == '') {
      await _getUserData();
    }

    return InAppWebViewPage(url: '${Constants.redirectionBase}/login?u=$username&p=$password', title: null);
    /*return PopScope(
      canPop: false,
      onPopInvokedWithResult: (b, d) async {
        if (await _webViewController.canGoBack()) {
          _webViewController.goBack();
        } else {
          _loadWebView();
        }
        return;
      },
      child: Stack(alignment: Alignment.center, children: [
        username == '' ? const CircularProgressIndicator() : WebViewWidget(controller: _webViewController),
        _webViewLoading ? Container(color: Colors.white38, child: Center(child: CircularProgressIndicator(value: _webViewProgress * 1.0))) : Container(),
        _downloading ? Container(color: Colors.white38, child: Center(child: CircularProgressIndicator(value: _progress))) : Container(),
      ])
    );*/
  }

  Widget _bookingPage() {
    String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

    String weekDay(int n) {
      switch (n) {
        case 1: return translate('sporadic.monday');
        case 2: return translate('sporadic.tuesday');
        case 3: return translate('sporadic.wednesday');
        case 4: return translate('sporadic.thursday');
        case 5: return translate('sporadic.friday');
        case 6: return translate('sporadic.saturday');
        case 0: default: return translate('sporadic.sunday');
      }
    }

    String month(int n) {
      switch (n) {
        case 1: return translate('sporadic.january');
        case 2: return translate('sporadic.february');
        case 3: return translate('sporadic.march');
        case 4: return translate('sporadic.april');
        case 5: return translate('sporadic.may');
        case 6: return translate('sporadic.june');
        case 7: return translate('sporadic.july');
        case 8: return translate('sporadic.august');
        case 9: return translate('sporadic.september');
        case 10: return translate('sporadic.october');
        case 11: return translate('sporadic.november');
        case 0: default: return translate('sporadic.december');
      }
    }

    String formattedDate(int i) => _selectedDates.isEmpty ? translate('sporadic.selectDate') : '${weekDay(_selectedDates[i].weekday)}, ${_selectedDates[i].day} ${month(_selectedDates[i].month).startsWith(RegExp(r'[aeiou]')) ? 'd\'' : 'de '}${month(_selectedDates[i].month)}';

    Widget dayWidget(int index) {
      CalendarDate cd = _calendarDates[index];
      DateTime dt = cd.dateTime;
      bool isSelectedDate = false;
      for (var element in _selectedDates) {
        if (cd.dayNumber != -1 && element.day == dt.day && element.month == dt.month && element.year == dt.year) isSelectedDate = true;
      }
      bool isWeekend = dt.weekday == 6 || dt.weekday == 7;
      DateTime now = DateTime.now();
      bool isToday = dt.day == now.day && dt.month == now.month && dt.year == now.year;

      double bigTextSize = 24;

      if (cd.dayNumber == -1) {
        return Container();
      } else if (cd.isHoliday || isWeekend) {
        return GestureDetector(
            onTap: () {
              //print('DVLOG: clicking holiday or weekend');
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(translate('sporadic.thisDayHoliday'))),
              );
            },
            child: Container(
              alignment: Alignment.center,
              color: AppColors.secondary.withOpacity(0.5),
              child: MediaQuery.of(context).size.width > 500
                  ? Text('${cd.dayNumber == -1 ? '' : cd.dayNumber}', style: TextStyle(fontSize: bigTextSize))
                  : Text('${cd.dayNumber == -1 ? '' : cd.dayNumber}'),
              //child: Text('${cd.dayNumber == -1 ? '' : cd.dayNumber}'),
            )
        );
      } else if (cd.isPast) {
        return GestureDetector(
            onTap: () {
              //print('DVLOG: clicking past day');
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isToday ? '${translate('sporadic.limitHourIs')} ${limit.hour}:${limit.minute}' : translate('sporadic.cannotChoosePast'))),
              );
            },
            child: Container(
              alignment: Alignment.center,
              margin: cd.isBooked ? const EdgeInsets.all(4) : null,
              decoration: cd.isBooked
                  ? BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                  border: Border.all(color: AppColors.primary, width: 2)
              ) : null,

              child: MediaQuery.of(context).size.width > 500
                  ? Text('${cd.dayNumber == -1 ? '' : cd.dayNumber}', style: TextStyle(fontSize: bigTextSize, color: isSelectedDate ? Colors.white : Colors.grey))
                  : Text('${cd.dayNumber == -1 ? '' : cd.dayNumber}', style: TextStyle(color: isSelectedDate
              ? Colors.white
                  : Colors.grey
              ),),
              /*child: Text(
                '${cd.dayNumber == -1 ? '' : cd.dayNumber}',
                style: TextStyle(color: isSelectedDate
                    ? Colors.white
                    : Colors.grey
                ),
              ),*/
            )
        );
      } else if (cd.isBooked) {
        return GestureDetector(
          onTap: () {
            //print('DVLOG: clicking booked day');
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(translate('sporadic.thisDayIsReserved'))),
            );
          },
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(500)),
              border: Border.all(color: AppColors.primary, width: 2)
            ),
            child: MediaQuery.of(context).size.width > 500
                ? Text('${cd.dayNumber == -1 ? '' : cd.dayNumber}', style: const TextStyle(fontSize: 28))
                : Text('${cd.dayNumber == -1 ? '' : cd.dayNumber}'),
            //child: Text('${cd.dayNumber == -1 ? '' : cd.dayNumber}'),
          )
        );
      } else {
        return GestureDetector(
          onTap: () {
            //print('DVLOG: clicking available day');
            if (isSelectedDate) {
              debugPrint('DVLOG: removing day');
              for (var element in _selectedDates) {
                if (element.day == dt.day && element.month == dt.month && element.year == dt.year) setState(() => _selectedDates.remove(element));
              }
            } else {
              debugPrint('DVLOG: adding day');
              setState(() => _selectedDates.add(dt));
            }
          },
          child: isSelectedDate ? Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(500)),
                  color: AppColors.primary
              ),
              child: MediaQuery.of(context).size.width > 500
                  ? Text('${cd.dayNumber == -1 ? '' : cd.dayNumber}', style: TextStyle(color: Colors.white, fontSize: bigTextSize))
                  : Text('${cd.dayNumber == -1 ? '' : cd.dayNumber}', style: const TextStyle(color: Colors.white)),
          ) : Container(
            alignment: Alignment.center,
            color: Colors.transparent,
            child: MediaQuery.of(context).size.width > 500
                ? Text('${cd.dayNumber == -1 ? '' : cd.dayNumber}', style: TextStyle(fontSize: bigTextSize))
                : Text('${cd.dayNumber == -1 ? '' : cd.dayNumber}'),
          )
        );
      }
    }

    Widget dayTag(String s) {
      return Center(
        child: MediaQuery.of(context).size.width > 500
          ? Text(translate(s), style: const TextStyle(fontSize: 24))
          : Text(translate(s))
      );
    }

    bool formFilled() {
      if (_children.isEmpty) return false;
      if (_services.isEmpty) return false;
      if (_selectedChild == -1) return false;
      if (_selectedService == -1) return false;
      if (_children[_selectedChild].childCode == null) return false;
      if (!_conditionsAccepted) return false;

      if (_services[_selectedService].ncMostrarCalendario) {
        if (_selectedDates.isEmpty) return false;
      }

      return true;
    }

    Future<void> doPlatformSpecificStuff() async {
      setState(() => _loading = true);

      saveBoolSharedPreferences(Constants.rememberCard, _rememberCard);
      if (_rememberCard) {
        saveBoolSharedPreferences(Constants.firstTimeRememberingCard, false);
      }

      NumberFormat formatter = NumberFormat('00');
      List<String> dates = [];
      for (var element in _selectedDates) {
        String date = '"${formatter.format(element.year)}-${formatter.format(element.month)}-${element.day}"';
        dates.add(date);
      }

      try {
        //Licencias de test
        //String license = Platform.isAndroid ? "AVrFZPGeVmBC2UVxZE6" : Platform.isIOS ? "Ewn65cPVMwdorum8XfIz" : "";

        //Licencias de producción
        String license = Platform.isAndroid ? "AqOyI8v0t7NmhVbJAyO" : Platform.isIOS ? "gPhnzyzwlovPkyjbNqFw" : "";

        String childCode = _children[_selectedChild].childCode ?? '000000000';

        String fuc = "356863803";
        String terminal = "001";
        String? merchantId = '';
        if (_rememberCard) {
          merchantId = await getMerchantId();
          debugPrint('DVLOG merchant id 1: $merchantId');
          if ((merchantId == null || merchantId == '' || merchantId == 'null')) {
            merchantId = TPVVConstants.REQUEST_REFERENCE;
          }
        }
        debugPrint('DVLOG merchant id 2: $merchantId');
        //String paymentType = _rememberCard ? TPVVConstants.PAYMENT_TYPE_AUTHENTICATION : TPVVConstants.PAYMENT_TYPE_NORMAL;
        String paymentType = TPVVConstants.PAYMENT_TYPE_NORMAL;
        String orderCode = "${childCode.substring(childCode.length - 4)}${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}";

        ServiceInfo service = _services[_selectedService];
        double totalPrice = service.ncMostrarCalendario ? (service.servicePrice * _selectedDates.length) : service.servicePrice;
        double amount = totalPrice * (Platform.isAndroid ? 100 : 100); //precio en centimos en android, y en euros en ios
        String currency = "978";
        String productDescription = _services[_selectedService].serviceName;
        String language = languageNotifier.value == 'es' ? TPVVConstants.spanish : TPVVConstants.catalan;
        Map<String, String> params = {};

        String f = FunctionNames.bookService;
        MerchantData data = MerchantData(
          appCode: Constants.appCode,
          f: f,
          username: username,
          password: password,
          sign: sign(f, username),
          childCode: childCode,
          serviceCode: _services[_selectedService].serviceCode,
          dates: dates.toString().replaceAll(' ', ''),
          comments: _commentsController.text
        );

        debugPrint('DVLOG MERCHANT URL: ${Constants.merchantUrl}');
        debugPrint('DVLOG MERCHANT DATA: ${json.encode(data.toJson())}');

        final String result = await platform.invokeMethod('redsys', {
          "license": license,
          "fuc": fuc,
          "terminal": terminal,
          "merchantId": merchantId,
          "paymentType": paymentType,
          "orderCode": orderCode,
          "amount": amount,
          "currency": currency,
          "productDescription": productDescription,
          "params": params,
          "language": language,
          "merchantUrl": Constants.merchantUrl,
          "merchantData": json.encode(data.toJson())
        });
        if (!mounted) return;
        if (kDebugMode) debugPrint('DVLOG REDSYS RESPONSE');
        if (kDebugMode) debugPrint('DVLOG $result');
        RedsysResponse redsysResponse;
        /*if (Platform.isIOS) {
          redsysResponse = RedsysResponse.fromJson(jsonDecode('{$result}'));
        } else {*/
        final res = json.decode(result.substring(result.indexOf('{'))) as Map<String, dynamic>;
          redsysResponse = RedsysResponse.fromJson(res);
        //}
        if (kDebugMode) debugPrint('authorisation code: ${redsysResponse.authorisationCode}');
        if (kDebugMode) debugPrint('DVLOG REDSYS RESPONSE Merchant ID: ${redsysResponse.identifier}');
        saveStringSharedPreferences(Constants.merchantId, redsysResponse.identifier);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translate('sporadic.purchaseSuccessful'))),
        );

        _firstTimeRememberingCard = await isFirstTimeRememberingCard();
        setState(() {
          _selectedDates.removeRange(0, _selectedDates.length);
          _monthShowing = DateTime.now().month;
          _commentsController.text = '';
        });
        _changeMonth();
        _tabController.animateTo(0);

        //Ya no se llama a book_service, se usa el merchantUrl para que el banco informe directamente a la plataforma
        /*try {
          BookServiceResponse bookServiceResponse = await bookService(context, childCode, _services[_selectedService].serviceCode, redsysResponse.authorisationCode, dates, _commentsController.text, true);
          if (bookServiceResponse.success == '1') {
            if (!mounted) return;
            setState(() {
              _selectedDates.removeRange(0, _selectedDates.length);
              _monthShowing = DateTime.now().month;
            });
            _changeMonth();
            _tabController.animateTo(0);
            //_webViewController.loadUrl('${Constants.redirectionBase}/albarans');
            setState(() => _loading = false);
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error code: ${bookServiceResponse.errorCode}, error message: ${bookServiceResponse.errorMsg}'), backgroundColor: Colors.red),
            );
          }
        } catch (e) {
          debugPrint('Catch: $e');
        }*/

      } on PlatformException catch (e) {
        if (kDebugMode) debugPrint("Error: '${e.message}'");
      }

      setState(() => _loading = false);
    }

    Future<void> openUrl(String url) async {
      if (!await launchUrl(Uri.parse(url))) {
        throw 'Could not launch $url';
      }
    }

    const TextStyle titleStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

    return Container(
      color: Colors.black.withOpacity(0.05),
      child: Stack(children: [
        ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(translate('sporadic.name'), style: titleStyle),
            DropdownButton<int>(
                value: _selectedChild,
                items: List.generate(_children.length, (index) => DropdownMenuItem(value: index, child: Text(_children[index].childName ?? ''))),
                onChanged: (int? int) {
                  if (_selectedChild != int) {
                    setState(() {
                      _selectedChild = int ?? 0;
                      _selectedDates.removeRange(0, _selectedDates.length);
                      _monthShowing = DateTime.now().month;
                    });
                    _getServices(_children[int ?? 0].childCode ?? '');
                  }
                }
            ),
            const SizedBox(height: 24),

            Text(translate('sporadic.service'), style: titleStyle),
            DropdownButton<int>(
                value: _selectedService,
                items: List.generate(_services.length, (index) => DropdownMenuItem(value: index, child: Text(_services[index].serviceName))),
                onChanged: (int? int) {
                  if (_selectedService != int) {
                    setState(() {
                      _selectedService = int ?? 0;
                      _selectedDates.removeRange(0, _selectedDates.length);
                      _monthShowing = DateTime.now().month;
                    });

                    if (_services[_selectedService].ncTieneFechaUnica) {
                      _singleDate = DateTime.parse(_services[_selectedService].ncFechaUnica!);
                    }
                    setState(() {});

                    _changeMonth();
                  }
                }
            ),
            const SizedBox(height: 24),

            _services.isEmpty || _selectedService == -1 || !_services[_selectedService].ncMostrarCalendario ? Container() : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(translate('sporadic.price'), style: titleStyle),
              _services.isNotEmpty && _selectedService != -1 ? Text(
                '${(_services[_selectedService].servicePrice).toStringAsFixed(2).replaceFirstMapped('.', (match) => ',')}€/${translate('sporadic.day')}',
                style: AppFonts.h4,
              ) : Container(),
              const SizedBox(height: 24),
            ],),

            _services.isEmpty || _selectedService == -1 || !_services[_selectedService].ncMostrarCalendario ? Container() : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(translate(_services.isEmpty ? 'sporadic.date' : _services[_selectedService].ncTieneFechaUnica ? 'sporadic.date' : _selectedDates.length > 1 ? 'sporadic.dates' : 'sporadic.date'), style: titleStyle),
                const SizedBox(width: 8),
                _services.isEmpty ? Container() : (_selectedDates.isEmpty || _services[_selectedService].ncTieneFechaUnica) ? Container() : Container(
                  decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  child: Text('${_selectedDates.length}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                )
              ]),
              const SizedBox(height: 8),
              _services.isEmpty ? Container() : _services[_selectedService].ncTieneFechaUnica ? Text('${weekDay(_singleDate.weekday)}, ${_singleDate.day} ${month(_singleDate.month).startsWith(RegExp(r'[aeiou]')) ? 'd\'' : 'de '}${month(_singleDate.month)}') : GestureDetector(
                  onTap: () => _services.isEmpty ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(translate('sporadic.missingData')))) : setState(() => _showCalendar = true),
                  child: _selectedDates.isEmpty
                      ? Wrap(children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(6)),
                          border: Border.all(color: AppColors.primary, width: 2)
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(translate('sporadic.selectDate')),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today, size: 22, color: AppColors.primary)
                      ]),
                    )
                  ]) : Row( children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: List.generate(_selectedDates.length, (index) => Text(formattedDate(index)))),
                    const SizedBox(width: 32),
                    const Icon(Icons.edit, size: 22, color: AppColors.primary)
                  ])
              ),
              const SizedBox(height: 24),
            ],),

            _services.isEmpty ? Container() : _services[_selectedService].ncTieneFechaUnica ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(translate('sporadic.tickets'), style: titleStyle),
                Text(' (${translate('sporadic.alreadyPurchased')}: $_bookedDays)'),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                IconButton(onPressed: _selectedDates.isNotEmpty ? () => setState(() => _selectedDates.removeLast()) : null, icon: const Icon(Icons.remove)),
                Text('${_selectedDates.length}'),
                IconButton(onPressed: () => setState(() => _selectedDates.add(_singleDate)), icon: const Icon(Icons.add)),
              ]),
              const SizedBox(height: 24),
            ]) : Container(),

            Text(translate('sporadic.import'), style: titleStyle),
            _services.isNotEmpty && _selectedService != -1
                ? Text(
                  _services[_selectedService].ncMostrarCalendario
                      ? '${(_services[_selectedService].servicePrice * _selectedDates.length).toStringAsFixed(2).replaceFirstMapped('.', (match) => ',')}€'
                      : '${(_services[_selectedService].servicePrice).toStringAsFixed(2).replaceFirstMapped('.', (match) => ',')}€',
                  style: AppFonts.h4,
                )
                : Container(),

            const SizedBox(height: 24),

            Text(translate('sporadic.comments'), style: titleStyle),
            TextField(
              controller: _commentsController,
              decoration: InputDecoration(hintText: translate('sporadic.comments')),
              maxLength: 50,
            ),

            const SizedBox(height: 24),

            CheckboxListTile(
              value: _rememberCard,
              onChanged: (bool? newValue) => setState(() => _rememberCard = newValue == true),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.all(0),
              title: Text(
                _firstTimeRememberingCard ? translate('sporadic.rememberCard') : translate('sporadic.usePreviousCard'),
                style: DefaultTextStyle.of(context).style,
              ),
            ),

            CheckboxListTile(
                value: _conditionsAccepted,
                onChanged: (bool? newValue) => setState(() => _conditionsAccepted = newValue == true),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.all(0),
                title: RichText(
                  text: TextSpan(
                    text: translate('sporadic.IAccept'),
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                        text: translate('sporadic.conditions').toLowerCase(),
                        style: const TextStyle(color: AppColors.blue),
                        recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => InAppWebViewPage(url: translate('sporadic.conditionsURL'), title: translate('sporadic.conditions')))
                        ),
                      ),
                      const TextSpan(text: ', '),
                      TextSpan(
                        text: translate('sporadic.privacyPolicy').toLowerCase(),
                        style: const TextStyle(color: AppColors.blue),
                        recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => InAppWebViewPage(url: translate('sporadic.privacyPolicyURL'), title: translate('sporadic.privacyPolicy')))
                        ),
                      ),
                      TextSpan(text: translate('sporadic.and')),
                      TextSpan(
                        text: translate('sporadic.cookiesPolicy').toLowerCase(),
                        style: const TextStyle(color: AppColors.blue),
                        recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => InAppWebViewPage(url: translate('sporadic.cookiesPolicyURL'), title: translate('sporadic.cookiesPolicy')))
                        ),
                      ),
                    ],
                  ),
                )
            ),

            GestureDetector(
              onTap: formFilled() ? null : () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(translate('sporadic.missingData'))),
              ),
              child: ElevatedButton(
                onPressed: formFilled() ? doPlatformSpecificStuff : null,
                style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppColors.secondary)),
                child: Text(translate('sporadic.buy').toUpperCase(), style: const TextStyle(color: Colors.white)),
              ),
            ),

            const SizedBox(height: 24),
            const Text('DOBLE VIA SCCL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const Text('Plaça Aiguallonga s/n', style: TextStyle(fontSize: 12)),
            const Text('08198 Sant Cugat del Vallès, Barcelona', style: TextStyle(fontSize: 12)),
            const Text('NIF: F62011812', style: TextStyle(fontSize: 12)),
            GestureDetector(
              onTap: () => openUrl('tel:935442628'),
              child: const Text('Tel. 935 442 628', style: TextStyle(color: AppColors.blue, fontSize: 12)),
            ),
            GestureDetector(
              onTap: () => openUrl('mailto:doblevia.escoles@doblevia.coop'),
              child: const Text('doblevia.escoles@doblevia.coop', style: TextStyle(color: AppColors.blue, fontSize: 12)),
            ),
          ],
        ),
        _showCalendar ? Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.5),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              child: Text(
                translate('sporadic.selectDate'),
                style: TextStyle(color: Colors.white, fontSize: min(MediaQuery.of(context).size.width * 0.05, 20)),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    GestureDetector(
                      onTap: () {
                        if (_monthShowing == 1) {
                          setState(() {
                            _monthShowing = 12;
                            _yearShowing--;
                          });
                        } else {
                          setState(() => _monthShowing--);
                        }
                        _changeMonth();
                      },
                      child: const Icon(Icons.arrow_back_ios_sharp),
                    ),
                    Text('${capitalize(month(_monthShowing))} $_yearShowing', style: Theme.of(context).textTheme.titleLarge),
                    GestureDetector(
                      onTap: () {
                        if (_monthShowing == 12) {
                          setState(() {
                            _monthShowing = 1;
                            _yearShowing++;
                          });
                        } else {
                          setState(() => _monthShowing++);
                        }
                        _changeMonth();
                      },
                      child: const Icon(Icons.arrow_forward_ios_sharp),
                    ),
                  ]),
                ),
                GridView.count(
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  children: [
                    dayTag('sporadic.mondayShort'),
                    dayTag('sporadic.tuesdayShort'),
                    dayTag('sporadic.wednesdayShort'),
                    dayTag('sporadic.thursdayShort'),
                    dayTag('sporadic.fridayShort'),
                    dayTag('sporadic.saturdayShort'),
                    dayTag('sporadic.sundayShort')
                  ]
                ),
                const SizedBox(width: 12),
                Stack(alignment: Alignment.center, children: [
                  GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    children: List.generate(_calendarDates.length, (index) => dayWidget(index)),
                  ),
                  _calendarLoading ? Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.8),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    )
                  ) : Container(),
                ]),
                Container(
                  padding: const EdgeInsets.only(top: 24),
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => setState(() => _showCalendar = false),
                    child: Padding(padding: const EdgeInsets.only(right: 8), child: Text(translate('main.accept').toUpperCase(), style: AppFonts.h5)),
                  ),
                )
              ])
            )
          ])
        ) : Container()
      ])
    );
  }
}

class ArchivePage extends StatefulWidget {
  final List<NotificationInfo> archived;
  final List<NotificationInfo> notifications;
  const ArchivePage({Key? key, required this.archived, required this.notifications}) : super(key: key);

  @override
  State<ArchivePage> createState() => _ArchivePage();
}

class _ArchivePage extends State<ArchivePage> {
  List<NotificationInfo> _archived = [];
  List<NotificationInfo> _notifications = [];

  bool _loading = false;
  bool _showNotificationDialog = false;
  NotificationInfo? currentNotification;

  void _getNotifications() async {
    NotificationResponse response = await getNotifications(context);
    List<NotificationInfo> notifs = response.notifications;
    List<NotificationInfo> a = [];
    List<NotificationInfo> n = [];

    for (var element in notifs) {
      if (element.isArchived) {
        a.add(element);
      } else {
        n.add(element);
      }
    }

    a.sort((a, b) => DateTime.parse(b.datetime).compareTo(DateTime.parse(a.datetime)));
    n.sort((a, b) => DateTime.parse(b.datetime).compareTo(DateTime.parse(a.datetime)));

    _archived = a;
    _notifications = n;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _archived.addAll(widget.archived);
    _notifications.addAll(widget.notifications);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (b) async {
        Navigator.pop(context, [_archived, _notifications]);
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: TextButton(
            child: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, [_archived, _notifications]);
            },
          ),
          title: Tab(text: translate('main.archivedNotifications')),
        ),
        body: Stack(children: [
          Container(
            color: Colors.black.withOpacity(0.05),
            child: _archived.isEmpty ? _emptyListMessage(true, context) : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: List.generate(_archived.length, (index) =>
                  _notificationCard(_archived[index])),
            )
          ),

          _showNotificationDialog ? _customDialog(
                  () => setState(() => _showNotificationDialog = false),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 24, bottom: 20),
                    child: Text(translate('main.areYouSure', args: {'arg1': translate('main.defileLowercase'), 'arg2': currentNotification?.title}), style: const TextStyle(fontSize: 18)),
                  ),

                  const SizedBox(height: 12),

                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(
                      child: Text(translate('main.cancel')),
                      onPressed: () => setState(() => _showNotificationDialog = false),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      child: Text(translate('main.defile')),
                      onPressed: () async {
                        setState(() => _loading = true);
                        ArchiveResponse response = await archiveNotification(context, currentNotification?.notificationCode ?? 0, false);
                        if (response.success && currentNotification != null) {
                          _removeFromFiled(currentNotification!);
                        } else {
                          _showErrorSnack();
                        }
                        setState(() => _loading = false);
                      },
                    ),
                    const SizedBox(width: 12)
                  ])
                ],
              )
          ) : Container(),

          _loading ? Container(
              color: Colors.white.withOpacity(0.6),
              width: double.infinity,
              height: double.infinity,
              child: const Center(child: CircularProgressIndicator())
          ) : Container()
        ])
      )
    );
  }

  Widget _notificationCard(NotificationInfo notification) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(24))
        ),
        clipBehavior: Clip.hardEdge,
        child: Dismissible(
          key: Key(notification.title),
          confirmDismiss: (direction) async {
            //_dismiss(notification);
            setState(() {
              currentNotification = notification;
              _showNotificationDialog = true;
            });

            while (_showNotificationDialog) {
              await Future.delayed(const Duration(seconds: 1));
              debugPrint('inside while');
            }
            debugPrint('outside while');

            return false;
          },
          onDismissed: (direction) => _getNotifications(),
          secondaryBackground: Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.all(Radius.circular(24))
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 18),
            child: const Icon(Icons.unarchive, color: Colors.white),
          ),
          background: Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.all(Radius.circular(24))
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 18),
            child: const Icon(Icons.unarchive, color: Colors.white),
          ),
          child: _notificationContainer(notification, context),
        )
      )
    );
  }

  void _showErrorSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error'), backgroundColor: Colors.red),
    );
  }

  void _removeFromFiled(NotificationInfo notification) {
    debugPrint('pasa por aqui 1');
    debugPrint('archived length: ${_archived.length}');
    setState(() {
      _archived.remove(notification);
      _notifications.add(notification);
      _showNotificationDialog = false;
    });
    debugPrint('archived final length: ${_archived.length}');
    debugPrint('pasa por aqui 2');
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${notification.title} ${translate('main.defiled')}')
    ));
  }

  /*Future<bool> _dismiss(direction, NotificationResponse notification) async {
    bool r = false;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(translate('main.areYouSure', args: {'arg1': translate('main.defileLowercase'), 'arg2': notification.title})),
            actions: <Widget>[
              TextButton(
                child: Text(translate('main.cancel')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(translate('main.defile')),
                onPressed: () async {
                  ArchiveResponse response = await archiveNotification(context, notification.notificationCode, false);
                  if (response.success) {
                    _removeFromFiled(notification);
                    r = false;
                  } else {
                    _showErrorSnack();
                    r = false;
                  }
                },
              ),
            ],
          );
        }
    );
    return r;
  }*/
}

Widget _notificationContainer(NotificationInfo notification, context) {
  DateTime dateTime = DateTime.parse(notification.datetime);
  DateTime now = DateTime.now();

  String time () {
    NumberFormat formatter = NumberFormat('00');
    if (dateTime.day == now.day && dateTime.month == now.month && dateTime.year == now.year) {
      return '${formatter.format(dateTime.hour)}:${formatter.format(dateTime.minute)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  return Container(
    padding: const EdgeInsets.all(12.0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(notification.isArchived ? Icons.notifications_outlined : Icons.notifications_active, color: AppColors.secondary),
        const SizedBox(width: 8),
        Expanded(child: Text(notification.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        const SizedBox(width: 8),
        Text(time(), style: const TextStyle(fontSize: 12))
      ]),
      const SizedBox(height: 8),
      Text(notification.body),
      notification.linkUrl == '' ? Container() : GestureDetector(
        onTap: () async {
          String url = notification.linkUrl;
          Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            throw "Could not launch $url";
          }

          /*Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyWebViewPage(url: notification.linkUrl, isOnline: true, title: notification.linkText == '' ? notification.linkUrl : notification.linkText))
          );*/
        },
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            //border: Border.all(color: AppColors.grey, width: 2)
            color: AppColors.secondary
          ),
          padding: const EdgeInsets.all(6),
          margin: const EdgeInsets.only(top: 12),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(notification.linkText, style: const TextStyle(color: Colors.white)),
            SizedBox(width: notification.linkText == '' ? 0 : 8),
            const Icon(Icons.arrow_forward_outlined, color: Colors.white)
          ]),
        ),
      )
    ]),
  );
}

Widget _emptyListMessage(bool isArchived, BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(24.0),
    alignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: isArchived ? 0 : MediaQuery.of(context).size.height * 0.25),
        Icon(isArchived ? Icons.notifications_outlined : Icons.notifications_active, color: AppColors.primary.withOpacity(0.2), size: 64),
        const SizedBox(height: 16),
        Text(
          translate(isArchived ? 'main.noFiledNotifications' : 'main.noNotifications'),
          style: TextStyle(fontSize: 18, color: AppColors.primary.withOpacity(0.5)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32)
      ]
    )
  );
}

Widget _customDialog(void Function() close, Widget content) {
  return GestureDetector(
      onTap: close,
      child: Container(
          color: Colors.black.withOpacity(0.6),
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(58),
          child: Center(
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4))
                ),
                child: content,
              )
          )
      )
  );
}

