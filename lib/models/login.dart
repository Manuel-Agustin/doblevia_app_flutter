import 'dart:convert';

class LoginRequest {
  final String appCode;
  final String f;
  final String username;
  final String password;
  final String sign;
  final String notificationsToken;
  final String? ncPlatform;
  final String? ncPlatformVersion;
  final String? ncAppVersion;

  LoginRequest({
    required this.appCode,
    required this.f,
    required this.username,
    required this.password,
    required this.sign,
    required this.notificationsToken,
    this.ncPlatform,
    this.ncPlatformVersion,
    this.ncAppVersion
  });

  Map<String, dynamic> toJson() => {
    'app_code': appCode,
    'f': f,
    'username': username,
    'password': password,
    'sign': sign,
    'notifications_token': notificationsToken,
    'ncPlatform': ncPlatform,
    'ncPlatformVersion': ncPlatformVersion,
    'ncAppVersion': ncAppVersion,
  };

  String toGetString() => 'app_code=$appCode&f=$f&username=$username&password=$password&sign=$sign&notifications_token=$notificationsToken&ncPlatform=$ncPlatform&ncPlatformVersion=$ncPlatformVersion&ncAppVersion=$ncAppVersion';

  String toGetShortString() => 'app_code=$appCode&f=$f&username=$username&password=$password&sign=$sign&notifications_token=$notificationsToken';
}

class LoginResponse {
  final bool? userValid;
  final String? userLanguage;
  final bool? userEsProfesor;
  final String? errorCode;
  final String? errorMsg;

  LoginResponse({
    this.userValid,
    this.userLanguage,
    this.userEsProfesor,
    this.errorCode,
    this.errorMsg
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    userValid: json['user_valid'] == '1',
    userLanguage: json['user_language'],
    userEsProfesor: json['user_EsProfesor'] == 1,
    errorCode: json['error_code'],
    errorMsg: json['error_msg']
  );
}

class BasicRequest {
  final String appCode;
  final String f;
  final String username;
  final String password;
  final String sign;
  final String? ncAppVersion;

  BasicRequest({
    required this.appCode,
    required this.f,
    required this.username,
    required this.password,
    required this.sign,
    this.ncAppVersion
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'app_code': appCode,
      'f': f,
      'username': username,
      'password': password,
      'sign': sign
    };
    if (ncAppVersion != null) {
      map.addAll({
        'ncAppVersion': ncAppVersion
      });
    }
    return map;
  }

  String toGetString() => 'app_code=$appCode&f=$f&username=$username&password=$password&sign=$sign';
}

class GetNotificationsRequest {
  final String appCode;
  final String f;
  final String username;
  final String password;
  final String sign;
  final String token;
  final String ncAppVersion;
  final String? ncPlatform;
  final String? ncPlatformVersion;

  GetNotificationsRequest({
    required this.appCode,
    required this.f,
    required this.username,
    required this.password,
    required this.sign,
    required this.token,
    required this.ncAppVersion,
    required this.ncPlatform,
    required this.ncPlatformVersion
  });

  Map<String, dynamic> toJson() => {
    'app_code': appCode,
    'f': f,
    'username': username,
    'password': password,
    'sign': sign,
    'notifications_token': token,
    'ncAppVersion': ncAppVersion,
    'ncPlatform': ncPlatform,
    'ncPlatformVersion': ncPlatformVersion,
  };

  String toGetString() => 'app_code=$appCode&f=$f&username=$username&password=$password&sign=$sign&notifications_token=$token&ncAppVersion=$ncAppVersion&ncPlatform=$ncPlatform&ncPlatformVersion=$ncPlatformVersion';
}

class ChildResponse {
  final String errorCode;
  final String errorMsg;
  final List<Child> children;

  ChildResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.children,
  });

  factory ChildResponse.fromJson(List<dynamic> json) => ChildResponse(
      errorCode: json[0]['error_code'] ?? '0',
      errorMsg: json[0]['error_msg'] ?? '0',
      children: (json[0]['error_msg'] ?? '0') != '0' ? [] : List.generate(json.length, (index) => Child.fromJson(json[index]))
  );
}

class Child {
  final String? childCode;
  final String? childName;
  final int? ncCodigoCentro;
  final String? ncCodigoCurso;
  final String? errorCode;
  final String? errorMsg;

  Child({
    this.childCode,
    this.childName,
    this.ncCodigoCentro,
    this.ncCodigoCurso,
    this.errorCode,
    this.errorMsg
  });

  factory Child.fromJson(Map<String, dynamic> json) => Child(
      childCode: json['child_code'],
      childName: json['child_name'],
      ncCodigoCentro: json['ncCodigoCentro'],
      ncCodigoCurso: json['ncCodigoCurso'],
      errorCode: json['error_code'],
      errorMsg: json['error_msg']
  );
}

class ChildCodeRequest {
  final String appCode;
  final String f;
  final String username;
  final String password;
  final String sign;
  final String childCode;
  final String ncAppVersion;

  ChildCodeRequest({
    required this.appCode,
    required this.f,
    required this.username,
    required this.password,
    required this.sign,
    required this.childCode,
    required this.ncAppVersion
  });

  Map<String, dynamic> toJson() => {
    'app_code': appCode,
    'f': f,
    'username': username,
    'password': password,
    'sign': sign,
    'child_code': childCode,
    'ncAppVersion': ncAppVersion
  };

  String toGetString() => 'app_code=$appCode&f=$f&username=$username&password=$password&sign=$sign&child_code=$childCode&ncAppVersion=$ncAppVersion';
  //String toGetString() => 'app_code=$appCode&f=$f&username=$username&password=$password&sign=$sign&child_code=$childCode';
}

class ServiceResponse {
  final String errorCode;
  final String errorMsg;
  final List<Service>? services;

  ServiceResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.services,
  });

  factory ServiceResponse.fromJson(List<dynamic> json) {
    return ServiceResponse(
        errorCode: json[0]['error_code'] ?? '0',
        errorMsg: json[0]['error_msg'] ?? '0',
        services: (json[0]['error_msg'] ?? '0') != '0' ? null : List.generate(json.length, (i) => Service.fromJson(json[i]))
    );
  }
}

class Service {
  final String? familyCode;
  final String? familyName;
  final String? familyImage;
  final List<ServiceInfo>? services;
  final String? errorCode;
  final String? errorMsg;

  Service({
    this.familyCode,
    this.familyName,
    this.familyImage,
    this.services,
    this.errorCode,
    this.errorMsg
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    List<ServiceInfo> services = [];
    if (json['services'] != null) {
      var s = json['services'] as List<dynamic>;
      services = s.map((e) => ServiceInfo.fromJson(e)).toList();
    }

    return Service(
        familyCode: json['familyCode'],
        familyName: json['familyName'],
        familyImage: json['familyImage'],
        services: services,
        errorCode: json['error_code'],
        errorMsg: json['error_msg']
    );
  }
}

class ServiceInfo {
  final String serviceCode;
  final String serviceName;
  final double servicePrice;
  final bool ncTieneFechaUnica;
  final String? ncFechaUnica;
  final bool ncMostrarCalendario;

  ServiceInfo({
    required this.serviceCode,
    required this.serviceName,
    required this.servicePrice,
    required this.ncTieneFechaUnica,
    this.ncFechaUnica,
    required this.ncMostrarCalendario
  });

  factory ServiceInfo.fromJson(Map<String, dynamic> json) => ServiceInfo(
      serviceCode: json['service_code'],
      serviceName: json['service_name'],
      servicePrice: json['service_price'],
      ncTieneFechaUnica: json['ncTieneFechaUnica'] != 0,
      ncFechaUnica: json['ncTieneFechaUnica'] != 0 ? json['ncFechaUnica'] : null,
      ncMostrarCalendario: json['ncMostrarCalendario'] != 0,
  );
}

class CalendarRequest {
  final String appCode;
  final String f;
  final String username;
  final String password;
  final String sign;
  final String childCode;
  final String serviceCode;
  final String month;
  final String year;

  CalendarRequest({
    required this.appCode,
    required this.f,
    required this.username,
    required this.password,
    required this.sign,
    required this.childCode,
    required this.serviceCode,
    required this.month,
    required this.year
  });

  Map<String, dynamic> toJson() => {
    'app_code': appCode,
    'f': f,
    'username': username,
    'password': password,
    'sign': sign,
    'child_code': childCode,
    'service_code': serviceCode,
    'month': month,
    'year': year,
  };

  String toGetString() => 'app_code=$appCode&f=$f&username=$username&password=$password&sign=$sign&child_code=$childCode&service_code=$serviceCode&month=$month&year=$year';
}

class CalendarResponse {
  final String? serviceCode;
  final double? limitTime;
  final List<DateInterval>? holidays;
  final List<BookedDay>? bookedDays;
  final String? errorCode;
  final String? errorMsg;

  CalendarResponse({
    this.serviceCode,
    this.limitTime,
    this.holidays,
    this.bookedDays,
    this.errorCode,
    this.errorMsg
  });

  factory CalendarResponse.fromJson(Map<String, dynamic> json) {
    var h = json['holidays'] as List<dynamic>;
    List<DateInterval> holidays = h.map((e) => DateInterval.fromJson(e)).toList();

    var b = json['booked_days'] as List<dynamic>;
    List<BookedDay> bookedDays = b.map((e) => BookedDay.fromJson(e)).toList();

    return CalendarResponse(
        serviceCode: json['service_code'],
        limitTime: json['limit_time'],
        holidays: holidays,
        bookedDays: bookedDays,
        errorCode: json['error_code'],
        errorMsg: json['error_msg']
    );
  }
}

class DateInterval {
  final String? ncFestivoDesde;
  final String? ncFestivoHasta;
  final String? ncNombre;

  DateInterval({
    this.ncFestivoDesde,
    this.ncFestivoHasta,
    this.ncNombre
  });

  factory DateInterval.fromJson(Map<String, dynamic> json) => DateInterval(
      ncFestivoDesde: json['ncFestivoDesde'],
      ncFestivoHasta: json['ncFestivoHasta'],
      ncNombre: json['ncNombre']
  );
}

class BookedDay {
  final String? ncFechaServicio;

  BookedDay({
    this.ncFechaServicio
  });

  factory BookedDay.fromJson(Map<String, dynamic> json) => BookedDay(
      ncFechaServicio: json['ncFechaServicio']
  );
}

class MerchantData {
  final String appCode;
  final String f;
  final String username;
  final String password;
  final String sign;
  final String childCode;
  final String serviceCode;
  final String dates;
  final String comments;

  MerchantData({
    required this.appCode,
    required this.f,
    required this.username,
    required this.password,
    required this.sign,
    required this.childCode,
    required this.serviceCode,
    required this.dates,
    required this.comments,
  });

  Map<String, dynamic> toJson() => {
    'app_code': appCode,
    'f': f,
    'username': username,
    'password': password,
    'sign': sign,
    'child_code': childCode,
    'service_code': serviceCode,
    'dates': dates,
    'comments': comments,
  };

  String toGetString() => 'app_code=$appCode&f=$f&username=$username&password=$password&sign=$sign&child_code=$childCode&service_code=$serviceCode&dates=$dates&comments=$comments'.replaceAll(' ', '%20');
}

class BookServiceRequest {
  final String appCode;
  final String f;
  final String username;
  final String password;
  final String sign;
  final String childCode;
  final String serviceCode;
  final String transactionCode;
  final String dates;
  final String comments;
  final int success;

  BookServiceRequest({
    required this.appCode,
    required this.f,
    required this.username,
    required this.password,
    required this.sign,
    required this.childCode,
    required this.serviceCode,
    required this.transactionCode,
    required this.dates,
    required this.comments,
    required this.success
  });

  Map<String, dynamic> toJson() => {
    'app_code': appCode,
    'f': f,
    'username': username,
    'password': password,
    'sign': sign,
    'child_code': childCode,
    'service_code': serviceCode,
    'transaction_code': transactionCode,
    'dates': dates,
    'comments': 'comments',
    'success': success
  };

  String toGetString() => 'app_code=$appCode&f=$f&username=$username&password=$password&sign=$sign&child_code=$childCode&service_code=$serviceCode&transaction_code=$transactionCode&dates=$dates&comments=$comments&success=$success'.replaceAll(' ', '%20');
}

class BookServiceResponse {
  final String? success;
  final String? albaran;
  final String? errorCode;
  final String? errorMsg;

  BookServiceResponse({
    this.success,
    this.albaran,
    this.errorCode,
    this.errorMsg
  });

  factory BookServiceResponse.fromJson(Map<String, dynamic> json) => BookServiceResponse(
    success: json['success'],
    albaran: json['albaran'],
    errorCode: json['error_code'],
    errorMsg: json['error_msg']
  );
}

class UserSetLanguageRequest {
  final String appCode;
  final String f;
  final String username;
  final String password;
  final String sign;
  final String language;

  UserSetLanguageRequest({
    required this.appCode,
    required this.f,
    required this.username,
    required this.password,
    required this.sign,
    required this.language
  });

  Map<String, dynamic> toJson() => {
    'app_code': appCode,
    'f': f,
    'username': username,
    'password': password,
    'sign': sign,
    'language': language
  };

  String toGetString() => 'app_code=$appCode&f=$f&username=$username&password=$password&sign=$sign&language=$language';
}

class BasicSuccessResponse {
  final String? success;
  final String? errorCode;
  final String? errorMsg;

  BasicSuccessResponse({
    this.success,
    this.errorCode,
    this.errorMsg
  });

  factory BasicSuccessResponse.fromJson(Map<String, dynamic> json) => BasicSuccessResponse(
      success: json['success'],
      errorCode: json['error_code'],
      errorMsg: json['error_msg']
  );
}

class NotificationResponse {
  final String errorCode;
  final String errorMsg;
  final List<NotificationInfo> notifications;

  NotificationResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.notifications,
  });

  factory NotificationResponse.fromJson(List<dynamic> json) => NotificationResponse(
    errorCode: json[0]['error_code'] ?? '0',
    errorMsg: json[0]['error_msg'] ?? '0',
    notifications: (json[0]['error_msg'] ?? '0') != '0' ? [] : List.generate(json.length, (index) => NotificationInfo.fromJson(json[index]))
  );
}

class NotificationInfo {
  final int notificationCode;
  final String title;
  final String body;
  final String datetime;
  final String linkUrl;
  final String linkText;
  final bool isArchived;

  NotificationInfo({
    required this.notificationCode,
    required this.title,
    required this.body,
    required this.datetime,
    required this.linkUrl,
    required this.linkText,
    required this.isArchived
  });

  factory NotificationInfo.fromJson(Map<String, dynamic> json) => NotificationInfo(
      notificationCode: json['notification_code'],
      title: json['title'],
      body: json['body'],
      datetime: json['datetime'],
      linkUrl: json['link_url'],
      linkText: json['link_text'],
      isArchived: json['is_archived']
  );
}

class ArchiveRequest {
  final String appCode;
  final String f;
  final String username;
  final String password;
  final String sign;
  final String notificationCode;
  final String isArchived;

  ArchiveRequest({
    required this.appCode,
    required this.f,
    required this.username,
    required this.password,
    required this.sign,
    required this.notificationCode,
    required this.isArchived
  });

  Map<String, dynamic> toJson() => {
    'app_code': appCode,
    'f': f,
    'username': username,
    'password': password,
    'sign': sign,
    'notification_code': notificationCode,
    'is_archived': isArchived
  };

  String toGetString() => 'app_code=$appCode&f=$f&username=$username&password=$password&sign=$sign&notification_code=$notificationCode&is_archived=$isArchived';
}

class ArchiveResponse {
  final bool success;
  final bool? isArchived;
  final int? notificationCode;

  ArchiveResponse({
    required this.success,
    this.isArchived,
    this.notificationCode
  });

  factory ArchiveResponse.fromJson(Map<String, dynamic> json) => ArchiveResponse(
    success: json['success'] == '1',
    isArchived: json['is_archived'] == 1,
    notificationCode: json['notification_code']
  );
}

class GetUserDataResponse {
  final String userNombre;
  //final int userEsProfesor;
  final List<UserChild> userChildren;

  GetUserDataResponse({
    required this.userNombre,
    //required this.userEsProfesor,
    required this.userChildren
  });

  factory GetUserDataResponse.fromJson(Map<String, dynamic> json) {
    var c = json['user_children'] as List<dynamic>;
    List<UserChild> children = c.map((e) => UserChild.fromJson(e)).toList();

    return GetUserDataResponse(
        userNombre: json['user_nombre'],
        //userEsProfesor: json['user_EsProfesor'],
        userChildren: children
    );
  }
}

class UserChild {
  final String childCode;
  final String childName;
  final String childCentro;
  final String childCurso;
  final int ncEsHijo;
  final int ncEsProfesor;
  final int ncEsAdulto;

  UserChild({
    required this.childCode,
    required this.childName,
    required this.childCentro,
    required this.childCurso,
    required this.ncEsHijo,
    required this.ncEsProfesor,
    required this.ncEsAdulto
  });

  factory UserChild.fromJson(Map<String, dynamic> json) => UserChild(
      childCode: json['child_code'],
      childName: json['child_name'],
      childCentro: json['child_centro'],
      childCurso: json['child_curso'],
      ncEsHijo: json['ncEsHijo'],
      ncEsProfesor: json['ncEsProfesor'],
      ncEsAdulto: json['ncEsAdulto'],
  );
}

class NationsResponse {
  final String errorCode;
  final String errorMsg;
  final List<Nation>? nations;

  NationsResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.nations,
  });

  factory NationsResponse.fromJson(List<dynamic> json) {
    return NationsResponse(
        errorCode: json[0]['error_code'] ?? '0',
        errorMsg: json[0]['error_msg'] ?? '0',
        nations: (json[0]['error_msg'] ?? '0') != '0' ? null : List.generate(json.length, (i) => Nation.fromJson(json[i]))
    );
  }
}

class Nation {
  final String? siglaNacion;
  final String? nacion;

  Nation({
    this.siglaNacion,
    this.nacion
  });

  factory Nation.fromJson(Map<String, dynamic> json) {
    return Nation(
        siglaNacion: json['SiglaNacion'],
        nacion: json['Nacion'],
    );
  }
}

class ProvincesResponse {
  final String errorCode;
  final String errorMsg;
  final List<Province>? provinces;

  ProvincesResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.provinces,
  });

  factory ProvincesResponse.fromJson(List<dynamic> json) {
    return ProvincesResponse(
        errorCode: json[0]['error_code'] ?? '0',
        errorMsg: json[0]['error_msg'] ?? '0',
        provinces: (json[0]['error_msg'] ?? '0') != '0' ? null : List.generate(json.length, (i) => Province.fromJson(json[i]))
    );
  }
}

class Province {
  final String? codigoProvincia;
  final String? provincia;

  Province({
    this.codigoProvincia,
    this.provincia
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      codigoProvincia: json['CodigoProvincia'],
      provincia: json['Provincia'],
    );
  }
}

class MunicipiosRequest {
  final String appCode;
  final String f;
  final String username;
  final String password;
  final String sign;
  final String codigoProvincia;
  final String codigoNacion;

  MunicipiosRequest({
    required this.appCode,
    required this.f,
    required this.username,
    required this.password,
    required this.sign,
    required this.codigoProvincia,
    required this.codigoNacion
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'app_code': appCode,
      'f': f,
      'username': username,
      'password': password,
      'sign': sign,
      'CodigoProvincia': codigoProvincia,
      'CodigoNacion': codigoNacion
    };
    return map;
  }

  String toGetString() => 'app_code=$appCode&f=$f&username=$username&password=$password&sign=$sign&CodigoProvincia=$codigoProvincia&CodigoNacion=$codigoNacion';
}

class MunicipiosResponse {
  final String errorCode;
  final String errorMsg;
  final List<Municipio>? municipios;

  MunicipiosResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.municipios,
  });

  factory MunicipiosResponse.fromJson(List<dynamic> json) {
    return MunicipiosResponse(
        errorCode: json[0]['error_code'] ?? '0',
        errorMsg: json[0]['error_msg'] ?? '0',
        municipios: (json[0]['error_msg'] ?? '0') != '0' ? null : List.generate(json.length, (i) => Municipio.fromJson(json[i]))
    );
  }
}

class Municipio {
  final String? codigoMunicipio;
  final String? municipio;

  Municipio({
    this.codigoMunicipio,
    this.municipio
  });

  factory Municipio.fromJson(Map<String, dynamic> json) {
    return Municipio(
      codigoMunicipio: json['CodigoMunicipio'],
      municipio: json['Municipio'],
    );
  }
}

class CentrosRequest {
  final String appCode;
  final String f;
  final String username;
  final String password;
  final String sign;
  final String codigoProvincia;
  final String codigoMunicipio;

  CentrosRequest({
    required this.appCode,
    required this.f,
    required this.username,
    required this.password,
    required this.sign,
    required this.codigoProvincia,
    required this.codigoMunicipio
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'app_code': appCode,
      'f': f,
      'username': username,
      'password': password,
      'sign': sign,
      'CodigoProvincia': codigoProvincia,
      'CodigoMunicipio': codigoMunicipio
    };
    return map;
  }

  String toGetString() => 'app_code=$appCode&f=$f&username=$username&password=$password&sign=$sign&CodigoProvincia=$codigoProvincia&CodigoMunicipio=$codigoMunicipio';
}

class CentrosResponse {
  final String errorCode;
  final String errorMsg;
  final List<Centro>? centros;

  CentrosResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.centros,
  });

  factory CentrosResponse.fromJson(List<dynamic> json) {
    return CentrosResponse(
        errorCode: json[0]['error_code'] ?? '0',
        errorMsg: json[0]['error_msg'] ?? '0',
        centros: (json[0]['error_msg'] ?? '0') != '0' ? null : List.generate(json.length, (i) => Centro.fromJson(json[i]))
    );
  }
}

class Centro {
  final int ncCodigoCentro;
  final String? ncNombre;
  final int ncMostrarFamiliaNumerosa;
  final int ncMostrarPicnic;
  final List<Menu>? menus;

  Centro({
    required this.ncCodigoCentro,
    this.ncNombre,
    required this.ncMostrarFamiliaNumerosa,
    required this.ncMostrarPicnic,
    this.menus
  });

  factory Centro.fromJson(Map<String, dynamic> json) {
    return Centro(
        ncCodigoCentro: json['ncCodigoCentro'],
        ncNombre: json['ncNombre'],
        ncMostrarFamiliaNumerosa: json['ncMostrarFamiliaNumerosa'],
        ncMostrarPicnic: json['ncMostrarPicnic'],
        menus: json['menus'] == null ? null : List.generate(json['menus'].length, (i) => Menu.fromJson(json['menus'][i]))
    );
  }
}

class Menu {
  final int ncCodigoTipoMenu;
  final String? ncTipoMenuCas;
  final String? ncTipoMenuCat;

  Menu({
    required this.ncCodigoTipoMenu,
    this.ncTipoMenuCas,
    this.ncTipoMenuCat
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
        ncCodigoTipoMenu: json['ncCodigoTipoMenu'],
        ncTipoMenuCas: json['ncTipoMenu_cas'],
        ncTipoMenuCat: json['ncTipoMenu_cat']
    );
  }
}

class CursosRequest {
  final String appCode;
  final String f;
  final String username;
  final String password;
  final String sign;
  final String codigoCentro;
  final String tipoUsuario;

  CursosRequest({
    required this.appCode,
    required this.f,
    required this.username,
    required this.password,
    required this.sign,
    required this.codigoCentro,
    required this.tipoUsuario
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'app_code': appCode,
      'f': f,
      'username': username,
      'password': password,
      'sign': sign,
      'CodigoCentro': codigoCentro,
      'tipoUsuario': tipoUsuario
    };
    return map;
  }

  String toGetString() => 'app_code=$appCode&f=$f&username=$username&password=$password&sign=$sign&CodigoCentro=$codigoCentro&tipoUsuario=$tipoUsuario';
}

class CursosResponse {
  final String errorCode;
  final String errorMsg;
  final List<Curso>? cursos;

  CursosResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.cursos,
  });

  factory CursosResponse.fromJson(List<dynamic> json) {
    return CursosResponse(
        errorCode: json[0]['error_code'] ?? '0',
        errorMsg: json[0]['error_msg'] ?? '0',
        cursos: (json[0]['error_msg'] ?? '0') != '0' ? null : List.generate(json.length, (i) => Curso.fromJson(json[i]))
    );
  }
}

class Curso {
  final String? ncCodigoCurso;
  final String? ncCursoCas;
  final String? ncCursoCat;

  Curso({
    this.ncCodigoCurso,
    this.ncCursoCas,
    this.ncCursoCat
  });

  factory Curso.fromJson(Map<String, dynamic> json) {
    return Curso(
      ncCodigoCurso: json['ncCodigoCurso'],
      ncCursoCas: json['ncCurso_cas'],
      ncCursoCat: json['ncCurso_cat']
    );
  }
}

class TiposUsuarioResponse {
  final String errorCode;
  final String errorMsg;
  final List<UserType>? userTypes;

  TiposUsuarioResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.userTypes,
  });

  factory TiposUsuarioResponse.fromJson(Map<String, dynamic> json) {
    final userTypes = <UserType>[];
    json.forEach((key, value) {
      if (value is List) {
        for (var item in value) {
          userTypes.add(UserType.fromJson(key, item));
        }
      }
    });

    return TiposUsuarioResponse(
        errorCode: json[0]['error_code'] ?? '0',
        errorMsg: json[0]['error_msg'] ?? '0',
        userTypes: (json[0]['error_msg'] ?? '0') != '0' ? null : userTypes
    );
  }
}

class UserType {
  final String userTypeCode; // Nuevo campo para el código numérico
  final String ca;
  final String es;

  UserType({
    required this.userTypeCode,
    required this.ca,
    required this.es,
  });

  factory UserType.fromJson(String code, Map<String, dynamic> json) {
    return UserType(
      userTypeCode: code,
      ca: json['ca'],
      es: json['es'],
    );
  }
}

class SetUsuarioRequest {
  final String appCode;
  final String f;
  final String username;
  final String password;
  final String sign;
  final String lang;
  final Usuario usuario;

  SetUsuarioRequest({
    required this.appCode,
    required this.f,
    required this.username,
    required this.password,
    required this.sign,
    required this.lang,
    required this.usuario
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'app_code': appCode,
      'f': f,
      'username': username,
      'password': password,
      'sign': sign,
      'lang': lang,
      'usuario': usuario
    };
    return map;
  }

  String toGetString() => 'app_code=$appCode&f=$f&username=$username&password=$password&sign=$sign&lang=$lang&usuario=${json.encode(usuario.toJson())}';
}

class Usuario {
  final String nif;
  final String password;
  final String nom;
  final String cognoms;
  final String domicilio;
  final String codigopostal;
  final String codigoprovincia;
  final String codigomunicipio;
  final String email;
  final String email2;
  final String telefono;
  final String telefono2;
  final int ncokpoliticaprivacidad;
  final int ncokgestionservicio;
  final int ncokrecibirpublicidad;
  final int ncautorizawhatsapp;
  final int codigocentro;
  final String nombrecentro;
  final String siglanacion;
  final String tipodoc;

  Usuario({
    required this.nif,
    required this.password,
    required this.nom,
    required this.cognoms,
    required this.domicilio,
    required this.codigopostal,
    required this.codigoprovincia,
    required this.codigomunicipio,
    required this.email,
    required this.email2,
    required this.telefono,
    required this.telefono2,
    required this.ncokpoliticaprivacidad,
    required this.ncokgestionservicio,
    required this.ncokrecibirpublicidad,
    required this.ncautorizawhatsapp,
    required this.codigocentro,
    required this.nombrecentro,
    required this.siglanacion,
    required this.tipodoc,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'nif': nif,
      'password': password,
      'nom': nom,
      'cognoms': cognoms,
      'domicilio': domicilio,
      'codigopostal': codigopostal,
      'codigoprovincia': codigoprovincia,
      'codigomunicipio': codigomunicipio,
      'email1': email,
      'email2': email2,
      'telefono': telefono,
      'telefono2': telefono2,
      'ncokpoliticaprivacidad': ncokpoliticaprivacidad,
      'ncokgestionservicio': ncokgestionservicio,
      'ncokrecibirpublicidad': ncokrecibirpublicidad,
      'ncautorizawhatsapp': ncautorizawhatsapp,
      'codigocentro': codigocentro,
      'nombrecentro': nombrecentro,
      'siglanacion': siglanacion,
      'tipodoc': tipodoc,
    };
    return map;
  }

  String toGetString() => 'nif=$nif&password=$password&nom=$nom&cognoms=$cognoms&domicilio=$domicilio&codigopostal=$codigopostal&codigoprovincia=$codigoprovincia&codigomunicipio=$codigomunicipio&email=$email&email2=$email2&telefono=$telefono&telefono2=$telefono2&ncokpoliticaprivacidad=$ncokpoliticaprivacidad&ncokgestionservicio=$ncokgestionservicio&ncokrecibirpublicidad=$ncokrecibirpublicidad&ncautorizawhatsapp=$ncautorizawhatsapp&codigocentro=$codigocentro&nombrecentro=$nombrecentro&siglanacion=$siglanacion&tipodoc=$tipodoc';
}

class SetUsuarioResponse {
  final String errorCode;
  final String errorMsg;
  final String? success;
  final String? codigocliente;

  SetUsuarioResponse({
    required this.errorCode,
    required this.errorMsg,
    this.success,
    this.codigocliente
  });

  factory SetUsuarioResponse.fromJson(List<dynamic> json) {
    return SetUsuarioResponse(
        errorCode: json[0]['error_code'] ?? '0',
        errorMsg: json[0]['error_msg'] ?? '0',
        success: json[0]['success'],
        codigocliente: json[0]['codigocliente']
    );
  }
}
