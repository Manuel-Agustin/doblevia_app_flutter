class RedsysResponse {
  final String amount;
  final String currency;
  final String order;
  final String merchantCode;
  final String terminal;
  final String responseCode;
  final String authorisationCode;
  final String transactionType;
  final String securePayment;
  final String language;
  final String cardNumber;
  final String cardType;
  final String merchantData;
  final String cardCountry;
  final String date;
  final String hour;
  final String identifier;
  final String signature;
  final String expiryDate;
  final String cardBrand;
  final RedsysExtraParams extraParams;

  RedsysResponse({
    required this.amount,
    required this.currency,
    required this.order,
    required this.merchantCode,
    required this.terminal,
    required this.responseCode,
    required this.authorisationCode,
    required this.transactionType,
    required this.securePayment,
    required this.language,
    required this.cardNumber,
    required this.cardType,
    required this.merchantData,
    required this.cardCountry,
    required this.date,
    required this.hour,
    required this.identifier,
    required this.signature,
    required this.expiryDate,
    required this.cardBrand,
    required this.extraParams,
  });

  factory RedsysResponse.fromJson(Map<String, dynamic> json) => RedsysResponse(
    amount: json['amount'],
    currency: json['currency'],
    order: json['order'],
    merchantCode: json['merchantCode'],
    terminal: json['terminal'],
    responseCode: json['responseCode'],
    authorisationCode: json['authorisationCode'],
    transactionType: json['transactionType'],
    securePayment: json['securePayment'],
    language: json['language'],
    cardNumber: json['cardNumber'],
    cardType: json['cardType'],
    merchantData: json['merchantData'],
    cardCountry: json['cardCountry'],
    date: json['date'],
    hour: json['hour'],
    identifier: json['identifier'],
    signature: json['signature'],
    expiryDate: json['expiryDate'],
    cardBrand: json['cardBrand'],
    extraParams: RedsysExtraParams.fromJson(json['extraParams'])
  );
}

class RedsysExtraParams {
  final String? Ds_ProcessedPayMethod;
  final String? Ds_ConsumerLanguage;
  final String? Ds_Control_1659454784075;

  RedsysExtraParams({
    this.Ds_ProcessedPayMethod,
    this.Ds_ConsumerLanguage,
    this.Ds_Control_1659454784075
  });

  factory RedsysExtraParams.fromJson(Map<String, dynamic> json) => RedsysExtraParams(
      Ds_ProcessedPayMethod: json['Ds_ProcessedPayMethod'],
      Ds_ConsumerLanguage: json['Ds_ConsumerLanguage'],
      Ds_Control_1659454784075: json['Ds_Control_1659454784075']
  );
}