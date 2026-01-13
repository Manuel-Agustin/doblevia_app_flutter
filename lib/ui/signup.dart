import 'dart:io';

import 'package:doblevia/functions/api.dart';
import 'package:doblevia/models/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../functions/login.dart';
import '../functions/preferences.dart';
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

  int _page = 0;
  bool _loading = false;
  bool _passwordsVisible = false;
  bool _repeatPasswordsVisible = false;
  bool _acceptMain = false;
  bool _acceptData = false;
  bool _acceptResponsibility = false;
  bool _acceptInfo = false;

  final List<String> _documentTypes = [
    'DNI/NIF',
    'NIE',
    translate('signup.passport')
  ];
  List<Province> _provinces = [];
  List<Municipio> _municipios = [];
  List<Centro> _centers = [];

  String? _selectedDocumentType;
  String? _selectedProvincia;
  String? _selectedMunicipio;
  int? _selectedCentro;
  String? _selectedCentroName;

  bool _typeDocumentError = false;
  bool _documentError = false;
  bool _passwordEmptyError = false;
  bool _passwordMatchError = false;
  bool _passwordWeakError = false;
  bool _nameError = false;
  bool _surnameError = false;
  bool _addressError = false;
  bool _postalError = false;
  bool _provinceError = false;
  bool _cityError = false;
  bool _emailError = false;
  bool _phoneError = false;
  bool _centerError = false;

  bool _mainCheckError = false;
  bool _dataCheckError = false;
  bool _responsibilityCheckError = false;

  @override
  void initState() {
    _passwordController.addListener(_updateIcon);
    _loadProvinces();
    _loadCentros('', '');
    super.initState();
  }

  void _loadProvinces() async {
    ProvincesResponse provincesResponse = await getProvincias(context);
    if (provincesResponse.errorMsg != '0') {
      _showSnack(provincesResponse.errorMsg);
    } else {
      _provinces = provincesResponse.provinces!;
    }
    setState(() => {});
  }

  void _loadMunicipios(provinciaCode, nationCode) async {
    MunicipiosResponse municipiosResponse = await getMunicipios(context, provinciaCode, nationCode);
    if (municipiosResponse.errorMsg != '0') {
      _showSnack(municipiosResponse.errorMsg);
    } else {
      setState(() {
        _selectedProvincia = provinciaCode;
        _selectedCentro = null;
        _selectedMunicipio = null;
        _municipios = municipiosResponse.municipios!;
      });
    }
  }

  void _loadCentros(provinciaCode, municipioCode) async {
    CentrosResponse centrosResponse = await getCentros(context, provinciaCode, municipioCode);
    if (centrosResponse.errorMsg != '0') {
      _showSnack(centrosResponse.errorMsg);
    } else {
      _selectedCentro = null;
      _centers = centrosResponse.centros!;
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
      Image.asset('assets/images/menjasa-logo.png', height: 60),
      const SizedBox(height: 16),
      Text(translate('signup.accessData'), style: AppFonts.h4),
      const SizedBox(height: 12),
      DropdownButton<String>(
        value: _selectedDocumentType, // Valor actual
        items: _documentTypes.map((String value) {
          return DropdownMenuItem<String>(
            value: value, // Asignar el valor único
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedDocumentType = newValue;
          });
        },
        hint: Text(translate('signup.documentType')), // Opcional: texto cuando no hay selección
      ),
      _typeDocumentError ? Text(translate('signup.requiredField'), style: AppFonts.error) : Container(),

      TextField(controller: _nifController, decoration: InputDecoration(hintText: translate('signup.document'))),
      _documentError ? Text(translate('signup.requiredField'), style: AppFonts.error) : Container(),

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
      _passwordEmptyError ? Text(translate('signup.requiredField'), style: AppFonts.error) : Container(),
      _passwordWeakError ? Text(translate('signup.weakPassword'), style: AppFonts.error) : Container(),
      const SizedBox(height: 12),
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
      _passwordMatchError ? Text(translate('signup.passwordUnmatch'), style: AppFonts.error) : Container(),

      const SizedBox(height: 36),
      Text(translate('signup.contactData'), style: AppFonts.h4),

      TextField(controller: _nameController, decoration: InputDecoration(hintText: translate('signup.name')), keyboardType: TextInputType.name),
      _nameError ? Text(translate('signup.requiredField'), style: AppFonts.error) : Container(),
      TextField(controller: _surnameController, decoration: InputDecoration(hintText: translate('signup.surname'))),
      _surnameError ? Text(translate('signup.requiredField'), style: AppFonts.error) : Container(),
      TextField(controller: _addressController, decoration: InputDecoration(hintText: translate('signup.address')), keyboardType: TextInputType.streetAddress),
      _addressError ? Text(translate('signup.requiredField'), style: AppFonts.error) : Container(),
      TextField(controller: _postalCodeController, decoration: InputDecoration(hintText: translate('signup.postalCode')), keyboardType: TextInputType.number),
      _postalError ? Text(translate('signup.requiredField'), style: AppFonts.error) : Container(),
      DropdownButton<String>(
        value: _selectedProvincia, // Valor actual
        items: _provinces.map((Province value) {
          return DropdownMenuItem<String>(
            value: value.codigoProvincia, // Asignar el valor único
            child: Text('${value.provincia}'),
          );
        }).toList(),
        onChanged: (String? newValue) {
          _loadMunicipios(newValue, '108');
        },
        hint: Text(translate('signup.province')), // Opcional: texto cuando no hay selección
      ),
      _provinceError ? Text(translate('signup.requiredField'), style: AppFonts.error) : Container(),
      DropdownButton<String>(
        value: _selectedMunicipio,
        hint: Text(translate('signup.city'), overflow: TextOverflow.ellipsis),
        isExpanded: true,
        items: _municipios.map((Municipio value) {
          return DropdownMenuItem<String>(
            value: value.codigoMunicipio,
            child: Text('${value.municipio}'),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedMunicipio = newValue;
          });
        },
      ),
      _cityError ? Text(translate('signup.requiredField'), style: AppFonts.error) : Container(),
      TextField(controller: _email1Controller, decoration: InputDecoration(hintText: translate('signup.email1')), keyboardType: TextInputType.emailAddress),
      _emailError ? Text(translate('signup.requiredField'), style: AppFonts.error) : Container(),
      TextField(controller: _email2Controller, decoration: InputDecoration(hintText: translate('signup.email2')), keyboardType: TextInputType.emailAddress),
      TextField(controller: _phone1Controller, decoration: InputDecoration(hintText: translate('signup.phone')), keyboardType: TextInputType.phone),
      _phoneError ? Text(translate('signup.requiredField'), style: AppFonts.error) : Container(),
      TextField(controller: _phone2Controller, decoration: InputDecoration(hintText: translate('signup.phone2')), keyboardType: TextInputType.phone),
      DropdownButton<int>(
        value: _selectedCentro, // Valor actual
        items: _centers.map((Centro value) {
          return DropdownMenuItem<int>(
            value: value.ncCodigoCentro, // Asignar el valor único
            child: Text('${value.ncNombre}'),
          );
        }).toList(),
        onChanged: (int? newValue) {
          setState(() {
            _selectedCentro = newValue;
            _selectedCentroName = _centers.firstWhere((Centro c) => c.ncCodigoCentro == newValue).ncNombre!;
          });
        },
        hint: Text(translate('signup.center')), // Opcional: texto cuando no hay selección
      ),
      _centerError ? Text(translate('signup.requiredField'), style: AppFonts.error) : Container(),

      const SizedBox(height: 32),
      Row(children: [
        GestureDetector(
            onTap: () => Navigator.pop(context),
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
            onTap: () {
              bool errors = _validateForm1();
              if (!errors) setState(() => _page = 1);
            },
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

  List<Widget> _page2() {
    return [
      Image.asset('assets/images/dobleviaescoles.png', height: 60),
      const SizedBox(height: 16),
      Text(translate('signup.rgpd'), style: AppFonts.h4),
      const SizedBox(height: 12),

      Text.rich(
        TextSpan(
          text: translate('signup.policy'),
          children: <InlineSpan>[
            TextSpan(
              text: translate('signup.policyLinkText'),
              style: const TextStyle(
                  fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 16),
      CheckboxListTile(
        value: _acceptMain,
        onChanged: (bool? value) {
          setState(() {
            _acceptMain = value!;
          });
        },
        title: Text(translate('signup.acceptPolicy')),
        subtitle: _mainCheckError ? Text(translate('signup.acceptMainCheck'), style: AppFonts.error) : Container(),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      ),
      const SizedBox(height: 12),
      CheckboxListTile(
        value: _acceptData,
        onChanged: (bool? value) {
          setState(() {
            _acceptData = value!;
          });
        },
        title: Text(translate('signup.dataTreatment')),
        subtitle: _dataCheckError ? Text(translate('signup.acceptDataCheck'), style: AppFonts.error) : Container(),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      ),
      const SizedBox(height: 12),
      CheckboxListTile(
        value: _acceptResponsibility,
        onChanged: (bool? value) {
          setState(() {
            _acceptResponsibility = value!;
          });
        },
        title: Text(translate('signup.resposabilityReal')),
        subtitle: _responsibilityCheckError ? Text(translate('signup.acceptResponsabilityCheck'), style: AppFonts.error) : Container(),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      ),

      const SizedBox(height: 12),
      CheckboxListTile(
        value: _acceptInfo,
        onChanged: (bool? value) {
          setState(() {
            _acceptInfo = value!;
          });
        },
        title: Text(translate('signup.receibeInfo')),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      ),
      const SizedBox(height: 12),

      const SizedBox(height: 32),
      Row(children: [
        GestureDetector(
            onTap: () => setState(() => _page = 0),
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
                  child: Text(translate('signup.finish'), style: AppFonts.button)
              ),
            )
        ),
      ]),
    ];
  }

  List<List<Widget>> _body() {
    return [
      _page1(),
      _page2()
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: _body()[_page]),
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

  void _signup() {
    debugPrint('flag 1');
    setState(() => _loading = true);
    debugPrint('flag 2');
    sleep(const Duration(seconds: 5));
    debugPrint('flag 3');
    bool errors = _validateForm2();
    debugPrint('flag 4');
    if (!errors) _callApi();
    debugPrint('flag 5');
    setState(() => _loading = false);
  }

  bool _validateForm2() {
    setState(() {
      _mainCheckError = !_acceptMain;
      _dataCheckError = !_acceptData;
      _responsibilityCheckError = !_acceptResponsibility;
    });

    if (!_acceptMain || !_acceptData || !_acceptResponsibility) return true;
    return false;
  }

  bool _validateForm1() {
    setState(() {
      _typeDocumentError = (_selectedDocumentType == null);
      _documentError
          = _selectedDocumentType == _documentTypes[0] ? _isNIFValid()
          : _selectedDocumentType == _documentTypes[1] ? _isNIEValid()
          : _isPassportValid();
      _passwordEmptyError = (_passwordController.text == "");
      _passwordMatchError = (_passwordController.text != _repeatPasswordController.text);
      _passwordWeakError = !RegExp(r'[a-z]').hasMatch(_passwordController.text)
          || !RegExp(r'[A-Z]').hasMatch(_passwordController.text)
          || !RegExp(r'[0-9]').hasMatch(_passwordController.text)
          || _passwordController.text.length < 8;
      _nameError = (_nameController.text == "");
      _surnameError = (_surnameController.text == "");
      _addressError = (_addressController.text == "");
      _postalError = (_postalCodeController.text == "");
      _provinceError = (_selectedProvincia == null);
      _cityError = (_selectedMunicipio == null);
      _emailError = (_email1Controller.text == "" || !_email1Controller.text.contains('@') || !_email1Controller.text.contains('.'));
      _phoneError = (_phone1Controller.text == "");
      _centerError = (_selectedCentro == null);
    });

    if (_typeDocumentError || _documentError || _passwordEmptyError || _passwordMatchError || _passwordWeakError || _nameError || _surnameError || _addressError || _postalError
        || _provinceError || _cityError || _emailError || _phoneError || _centerError) {
      return true;
    }
    return false;
  }

  bool _isNIFValid() {
    String nif = _nifController.text;

    if (nif.length != 9) return false;

    final numero = nif.substring(0, 8);
    final letra = nif.substring(8).toUpperCase();

    if (int.tryParse(numero) == null || !RegExp(r'^[0-9]+$').hasMatch(numero)) {
      return false;
    }

    const letrasNIF = 'TRWAGMYFPDXBNJZSQVHLCKE';
    final resto = int.parse(numero) % 23;
    final letraCalculada = letrasNIF[resto];

    return letra == letraCalculada;
  }

  bool _isNIEValid() {
    String nie = _nifController.text;

    if (nie.length != 9) return false;

    final letraInicial = nie.substring(0, 1).toUpperCase();
    final numero = nie.substring(1, 8);
    final letra = nie.substring(8).toUpperCase();

    if (!['X', 'Y', 'Z'].contains(letraInicial) || int.tryParse(numero) == null) {
      return false;
    }

    const letrasNIF = 'TRWAGMYFPDXBNJZSQVHLCKE';
    final numeroCompleto = (letraInicial == 'X' ? '0' : letraInicial == 'Y' ? '1' : '2') + numero;
    final resto = int.parse(numeroCompleto) % 23;
    final letraCalculada = letrasNIF[resto];

    return letra == letraCalculada;
  }

  bool _isPassportValid() {
    String p = _nifController.text;

    if (p.length < 3 || p.length > 20) return false;

    return true;
  }


  void _callApi() async {
    debugPrint('DVLOG: flag 1');
    try {
      Usuario user = Usuario(
          nif: _nifController.text.toUpperCase(),
          password: _passwordController.text,
          nom: _nameController.text.toUpperCase(),
          cognoms: _surnameController.text.toUpperCase(),
          domicilio: _addressController.text.toUpperCase(),
          codigopostal: _postalCodeController.text,
          codigoprovincia: _selectedProvincia!,
          codigomunicipio: _selectedMunicipio!,
          email: _email1Controller.text.toUpperCase(),
          email2: _email2Controller.text.toUpperCase(),
          telefono: _phone1Controller.text,
          telefono2: _phone2Controller.text,
          ncokpoliticaprivacidad: _acceptMain ? 1 : 0,
          ncokgestionservicio: _acceptData ? 1 : 0,
          ncokrecibirpublicidad: _acceptInfo ? 1 : 0,
          ncautorizawhatsapp: 0,
          codigocentro: _selectedCentro!,
          nombrecentro: _selectedCentroName!,
          siglanacion: 'ES',
          tipodoc: _selectedDocumentType!
      );
      debugPrint('DVLOG: flag 2');

      SetUsuarioResponse response = await setUsario(context, user);

      debugPrint('DVLOG: signup response: ${response.toString()}');
      if (response.success != null) {
        if (!mounted) return;
        callApiLogin(context, _nifController.text, _passwordController.text, await getToken());
      } else if (response.errorCode != '' || response.errorMsg != '') {
        if (!mounted) return;
        String error = '${response.errorCode}: ${response.errorMsg}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translate('login.tryLater')), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint('DVLOG: $e');
    }
  }
}