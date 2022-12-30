import UIKit
import Flutter
import TPVVInLibrary

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, WebViewPaymentResponseDelegate {
    
    func responsePaymentKO(response: (WebViewPaymentResponseKO)) {
        print("payment NOT OK")
        res("payment NOT OK: " + String(response.value(forKey: "code") as! Int) + ", desc: " + (response.value(forKey: "desc") as! String))
    }
    func responsePaymentOK(response: (WebViewPaymentResponseOK)) {
        print("payment OK")
        //res("payment OK: code: " + String(response.value(forKey: "code") as! Int) + ", desc: " + (response.value(forKey: "desc") as! String))
        let var1 = "{\"amount\":\"" + (response.value(forKey: "Ds_Amount") as! String) + "\""
        let var2 = ", \"currency\":\"" + (response.value(forKey: "Ds_Currency") as! String) + "\""
        let var3 = ", \"order\":\"" + (response.value(forKey: "Ds_Order") as! String) + "\""
        let var4 = ", \"merchantCode\":\"" + (response.value(forKey: "Ds_MerchantCode") as! String) + "\""
        let var5 = ", \"terminal\":\"" + (response.value(forKey: "Ds_Terminal") as! String) + "\""
        let var6 = ", \"responseCode\":\"" + (response.value(forKey: "Ds_Response") as! String) + "\""
        let var7 = ", \"authorisationCode\":\"" + (response.value(forKey: "Ds_AuthorisationCode") as! String) + "\""
        let var8 = ", \"transactionType\":\"" + (response.value(forKey: "Ds_TransactionType") as! String) + "\""
        let var9 = ", \"securePayment\":\"" + (response.value(forKey: "Ds_SecurePayment") as! String) + "\""
        let var10 = ", \"language\":\"" + (response.value(forKey: "Ds_ConsumerLanguage") as! String) + "\""
        let var11 = ", \"cardNumber\":\"" + (response.value(forKey: "Ds_Card_Number") as! String) + "\""
        let var12 = ", \"cardType\":\"" + (response.value(forKey: "Ds_Card_Type") as! String) + "\""
        let var13 = ", \"merchantData\":\"" + (response.value(forKey: "Ds_MerchantData") as! String) + "\""
        let var14 = ", \"cardCountry\":\"" + (response.value(forKey: "Ds_Card_Country") as! String) + "\""
        let var15 = ", \"date\":\"" + (response.value(forKey: "Ds_Date") as! String) + "\""
        let var16 = ", \"hour\":\"" + (response.value(forKey: "Ds_Hour") as! String) + "\""
        let var17 = ", \"identifier\":\"" + (response.value(forKey: "Ds_Merchant_Identifier") as! String) + "\""
        let var18 = ", \"signature\":\"" + (response.value(forKey: "Ds_Signature") as! String) + "\""
        let var19 = ", \"expiryDate\":\"" + (response.value(forKey: "Ds_ExpiryDate") as! String) + "\""
        let var20 = ", \"cardBrand\":\"" + (response.value(forKey: "Ds_Card_Brand") as! String) + "\"" + ", \"extraParams\":{}}"
        
        let v1 = var1 + var2 + var3 + var4
        let v2 = var5 + var6 + var7 + var8
        let v3 = var9 + var10 + var11 + var12
        let v4 = var13 + var14 + var15 + var16
        let v5 = var17 + var18 + var19 + var20
        
        res(v1 + v2 + v3 + v4 + v5)
    }
    
    private var res: FlutterResult!
    
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
          let channel = FlutterMethodChannel(name: "com.doblevia.comunicacions/tpvv",
                                                    binaryMessenger: controller.binaryMessenger)
          channel.setMethodCallHandler({
              [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // This method is invoked on the UI thread.
            // Handle battery messages.
              if call.method == "getBatteryLevel" {
                  self?.receiveBatteryLevel(result: result)
              } else if call.method == "redsys" {
                  if let args = call.arguments as? Dictionary<String, Any>,
                      let license = args["license"] as? String,
                      let fuc = args["fuc"] as? String,
                      let terminal = args["terminal"] as? String,
                      let currency = args["currency"] as? String,
                      let language = args["language"] as? String,
                      let orderCode = args["orderCode"] as? String,
                      let amount = args["amount"] as? Double,
                      let paymentType = args["paymentType"] as? String,
                      let productDescription = args["productDescription"] as? String,
                      let params = args["params"] as? [String:String]? {
                      
                      self?.res = result
                      
                      TPVVConfiguration.shared.appLicense = license
                      TPVVConfiguration.shared.appEnviroment = EnviromentType.Real
                      TPVVConfiguration.shared.appFuc = fuc
                      TPVVConfiguration.shared.appTerminal = terminal
                      TPVVConfiguration.shared.appCurrency = currency
                      TPVVConfiguration.shared.appMerchantConsumerLanguage = language

                      let wpView = WebViewPaymentController(orderNumber: orderCode, amount: amount / 100, productDescription: productDescription, transactionType: TransactionType.normal, identifier: "", extraParams: params)
                      wpView.delegate = self
                      
                      controller.present(wpView, animated: true, completion: nil)
                  } else {
                      result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
                  }
              } else {
                  result(FlutterMethodNotImplemented)
                  return
              }
          })
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func receiveBatteryLevel(result: FlutterResult) {
      let device = UIDevice.current
      device.isBatteryMonitoringEnabled = true
      if device.batteryState == UIDevice.BatteryState.unknown {
        result(FlutterError(code: "UNAVAILABLE",
                            message: "Battery level not available.",
                            details: nil))
      } else {
        result(Int(device.batteryLevel * 100))
      }
    }
}

