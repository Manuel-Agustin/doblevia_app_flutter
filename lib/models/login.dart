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

  GetNotificationsRequest({
    required this.appCode,
    required this.f,
    required this.username,
    required this.password,
    required this.sign,
    required this.token,
    required this.ncAppVersion
  });

  Map<String, dynamic> toJson() => {
    'app_code': appCode,
    'f': f,
    'username': username,
    'password': password,
    'sign': sign,
    'notifications_token': token,
    'ncAppVersion': ncAppVersion
  };

  String toGetString() => 'app_code=$appCode&f=$f&username=$username&password=$password&sign=$sign&notifications_token=$token&ncAppVersion=$ncAppVersion';
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

class  ServiceResponse {
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