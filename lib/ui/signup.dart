import 'package:doblevia/functions/api.dart';
import 'package:doblevia/models/login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../globals.dart';

class MySignupPage extends StatefulWidget {
  const MySignupPage({super.key});

  @override
  State<MySignupPage> createState() => _MySignupPage();
}

class _MySignupPage extends State<MySignupPage> {
  final TextEditingController _nifController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _email1Controller = TextEditingController();
  final TextEditingController _email2Controller = TextEditingController();
  final TextEditingController _phone1Controller = TextEditingController();
  final TextEditingController _phone2Controller = TextEditingController();

  bool _loading = false;
  bool _passwordsVisible = false;
  bool _repeatPasswordsVisible = false;

  final List<String> _documentTypes = [translate('signup.documentType')];
  List<Province> _provinces = [];
  List<Municipio> _municipios = [];
  List<Centro> _centers = [];

  String _selectedProvincia = '-1';
  String _selectedMunicipio = '-1';
  String _selectedCentro = '-1';

  @override
  void initState() {
    _passwordController.addListener(_updateIcon);
    _loadProvinces();
    super.initState();
  }

  void _loadProvinces() async {
    ProvincesResponse provincesResponse = await getProvincias(context);
    if (provincesResponse.errorMsg != '0') {
      _showSnack(provincesResponse.errorMsg);
    } else {
      _provinces = [Province(codigoProvincia: '-1', provincia: translate('signup.province'))];
      _provinces.addAll(provincesResponse.provinces!);
    }
    setState(() => {});
  }

  void _loadMunicipios(provinciaCode, nationCode) async {
    MunicipiosResponse municipiosResponse = await getMunicipios(context, provinciaCode, nationCode);
    if (municipiosResponse.errorMsg != '0') {
      _showSnack(municipiosResponse.errorMsg);
    } else {
      _municipios = [Municipio(codigoMunicipio: '-1', municipio: translate('signup.city'))];
      _municipios.addAll(municipiosResponse.municipios!);
    }
    setState(() => {});
  }

  void _loadCentros(provinciaCode, municipioCode) async {
    CentrosResponse centrosResponse = await getCentros(context, provinciaCode, municipioCode);
    if (centrosResponse.errorMsg != '0') {
      _showSnack(centrosResponse.errorMsg);
    } else {
      _centers = [Centro(ncCodigoCentro: '-1', ncNombre: translate('signup.center'))];
      _centers.addAll(centrosResponse.centros!);
    }
    setState(() => {});
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _nifController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _email1Controller.dispose();
    _email2Controller.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    super.dispose();
  }

  void _updateIcon() {
    setState(() {});
  }

  List<Widget> _page1() {
    return [
      Image.asset('assets/images/dobleviaescoles.png', height: 60),
      const SizedBox(height: 16),
      Text(translate('signup.accessData'), style: AppFonts.h4),
      const SizedBox(height: 12),
      DropdownButton(
        items: List.generate(_documentTypes.length, (int i) => DropdownMenuItem(child: Text(_documentTypes[i]))),
        onChanged: null
      ),

      TextField(controller: _nifController, decoration: InputDecoration(hintText: translate('signup.document'))),

      const SizedBox(height: 12),
      TextField(
        controller: _passwordController,
        obscureText: !_passwordsVisible,
        decoration: InputDecoration(
            hintText: translate('signup.password'),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _passwordsVisible = !_passwordsVisible),
              child: Icon(_passwordsVisible ? Icons.visibility : Icons.visibility_off),
            )
        )
      ),
      Text(translate('signup.passwordCriteria'), style: AppFonts.p),
      Row(children: [
        Icon(RegExp(r'[a-z]').hasMatch(_passwordController.text) ? Icons.check : Icons.cancel),
        Text.rich(
          TextSpan(
            text: translate('signup.atLeast'),
            children: <InlineSpan>[
              TextSpan(
                text: translate('signup.passwordCriteria1'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
      ]),
      Row(children: [
        Icon(RegExp(r'[A-Z]').hasMatch(_passwordController.text) ? Icons.check : Icons.cancel),
        Text.rich(
          TextSpan(
            text: translate('signup.atLeast'),
            children: <InlineSpan>[
              TextSpan(
                text: translate('signup.passwordCriteria2'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
      ]),
      Row(children: [
        Icon(RegExp(r'[0-9]').hasMatch(_passwordController.text) ? Icons.check : Icons.cancel),
        Text.rich(
          TextSpan(
            text: translate('signup.atLeast'),
            children: <InlineSpan>[
              TextSpan(
                text: translate('signup.passwordCriteria3'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
      ]),
      Row(children: [
        Icon(_passwordController.text.length > 7 ? Icons.check : Icons.cancel),
        Text.rich(
          TextSpan(
            text: translate('signup.passwordCriteria4'),
            children: <InlineSpan>[
              TextSpan(
                text: translate('signup.passwordCriteria4bold'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
      ]),

      TextField(
          controller: _repeatPasswordController,
          obscureText: !_repeatPasswordsVisible,
          decoration: InputDecoration(
              hintText: translate('signup.repeatPassword'),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _repeatPasswordsVisible = !_repeatPasswordsVisible),
                child: Icon(_repeatPasswordsVisible ? Icons.visibility : Icons.visibility_off),
              )
          )
      ),

      const SizedBox(height: 16),
      Text(translate('signup.contactData'), style: AppFonts.h4),
      const SizedBox(height: 12),
      TextField(controller: _nameController, decoration: InputDecoration(hintText: translate('signup.name'))),
      TextField(controller: _surnameController, decoration: InputDecoration(hintText: translate('signup.surname'))),
      TextField(controller: _addressController, decoration: InputDecoration(hintText: translate('signup.address'))),
      TextField(controller: _postalCodeController, decoration: InputDecoration(hintText: translate('signup.postalCode'))),
      DropdownButton(
        items: List.generate(_provinces.length, (int i) => DropdownMenuItem(value: _provinces[i].codigoProvincia, child: Text(_provinces[i].provincia!))),
        onChanged: (String? p) {
          _loadMunicipios(p, '108');
          setState(() => _selectedProvincia = p!);
        }
      ),
      DropdownButton(
        items: List.generate(_municipios.length, (int i) => DropdownMenuItem(value: _municipios[i].codigoMunicipio, child: Text(_municipios[i].municipio!))),
        onChanged: (String? m) {
          _loadCentros(_selectedProvincia, m);
          setState(() => _selectedMunicipio = m!);
        }),
      TextField(controller: _email1Controller, decoration: InputDecoration(hintText: translate('signup.email1'))),
      TextField(controller: _email2Controller, decoration: InputDecoration(hintText: translate('signup.email2'))),
      TextField(controller: _phone1Controller, decoration: InputDecoration(hintText: translate('signup.phone'))),
      TextField(controller: _phone2Controller, decoration: InputDecoration(hintText: translate('signup.phone2'))),
      DropdownButton(
        items: List.generate(_centers.length, (int i) => DropdownMenuItem(value: _centers[i].ncCodigoCentro, child: Text(_centers[i].ncNombre!))),
        onChanged: (String? c) => setState(() => _selectedCentro = c!)
      ),

      const SizedBox(height: 32),
      Row(children: [
        GestureDetector(
            onTap: _loading ? null : _signup,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.secondary, width: 1),
                  borderRadius: const BorderRadius.all(Radius.circular(6))
              ),
              alignment: Alignment.center,
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(translate('signup.previous'), style: AppFonts.button.copyWith(color: AppColors.secondary))
              ),
            )
        ),
        const SizedBox(width: 12),
        GestureDetector(
            onTap: _loading ? null : _signup,
            child: Container(
              decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.all(Radius.circular(6))
              ),
              alignment: Alignment.center,
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(translate('signup.next'), style: AppFonts.button)
              ),
            )
        ),
      ]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        ListView(
          padding: const EdgeInsets.all(24),
          children: [ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: _page1()),
            )
          )]
        ),
        _loading ? Container(
          color: Colors.white.withAlpha(100),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ) : Container()
      ])
    );
  }

  void _signup() async {
    setState(() => _loading = true);
    _callApi();
    setState(() => _loading = false);
  }

  void _callApi() async {
    try {
      /*LoginResponse response = await login(context, _nifController.text, _passwordController.text, token);

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
      }*/
    } catch (e) {
      if (kDebugMode) debugPrint('DVLOG: $e');
    }
  }
}