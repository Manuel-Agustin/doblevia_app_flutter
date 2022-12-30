import 'package:doblevia/functions/api.dart';
import 'package:doblevia/functions/preferences.dart';
import 'package:doblevia/globals.dart';
import 'package:doblevia/models/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'login.dart';

class UserDataPage extends StatefulWidget {
  const UserDataPage({Key? key}) : super(key: key);

  @override
  State<UserDataPage> createState() => _UserDataPage();
}

class _UserDataPage extends State<UserDataPage> {
  String _username = '';
  String _version = '';
  GetUserDataResponse? userDataResponse;

  bool _loading = true;
  bool _showDialog = false;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    userDataResponse = await getUserData(context);
    _username = await getUsername();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;

    _loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget dataRow(String tag, String? value) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tag, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value ?? ''),
        const SizedBox(height: 12),
      ]);
    }

    Widget childRow(UserChild child) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(child.childName, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('${child.ncEsProfesor == -1 ? '${translate('main.teacher')} ' : ''}${child.ncEsHijo == -1 ? '${translate('main.child')} ' : ''}${child.ncEsAdulto == -1 ? '${translate('main.adult')} ' : ''}'),
        Text(child.childCode),
        Text('${translate('login.center')}: ${child.childCentro}'),
        Text('${translate('login.grade')}: ${child.childCurso}'),
        const SizedBox(height: 12),
      ]);
    }

    Widget customDialog() {
      return GestureDetector(
        onTap: () => setState(() => _showDialog = false),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                    child: Text(translate('main.areYouSureDeleteAccount'), style: const TextStyle(fontSize: 18)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(translate('main.deleteAccountMgs'), style: const TextStyle()),
                  ),

                  const SizedBox(height: 12),

                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(
                      child: Text(translate('main.cancel')),
                      onPressed: () => setState(() => _showDialog = false),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      child: Text(translate('main.accept')),
                      onPressed: () async {
                        setState(() => _loading = true);
                        int response = await userDisable(context);
                        if (response == 200) {
                          await deleteAllPreferences();
                          if (!mounted) return;
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const MyLoginPage()),
                                  (_) => false
                          );
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(translate('login.tryLater')), backgroundColor: Colors.red),
                          );
                        }
                        setState(() => _loading = false);
                      },
                    ),
                    const SizedBox(width: 12)
                  ])
                ],
              ),
            )
          )
        )
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(translate('main.userData')),
      ),
      body: Stack(children: [
        ListView(padding: const EdgeInsets.all(24), children: [
          dataRow(translate('login.name'), userDataResponse?.userNombre),
          dataRow(translate('login.NIF'), _username),

          const SizedBox(height: 12),
          Text(translate('main.people'), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: List.generate(userDataResponse?.userChildren.length ?? 0, (index) => childRow(userDataResponse!.userChildren[index]))),

          const SizedBox(height: 24),
          Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            TextButton(
              onPressed: () => setState(() => _showDialog = true),
              child: Text(translate('main.deleteAccount'), style: const TextStyle(color: AppColors.red))
            ),
            Text('v. $_version', style: const TextStyle(color: AppColors.primary))
          ])
        ]),

        _showDialog ? customDialog() : Container(),

        _loading ? Container(
          color: Colors.white.withAlpha(100),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ) : Container()
      ])
    );
  }
}
