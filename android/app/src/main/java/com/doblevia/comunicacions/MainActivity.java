package com.doblevia.comunicacions;

import androidx.annotation.NonNull;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.BatteryManager;
import android.provider.OpenableColumns;

import com.redsys.tpvvinapplibrary.*;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Objects;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.doblevia.comunicacions/tpvv";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
            (call, result) -> {
                // This method is invoked on the main thread.
                switch (call.method) {
                    case "getBatteryLevel":
                        int batteryLevel = getBatteryLevel();

                        if (batteryLevel != -1) {
                            result.success(batteryLevel);
                        } else {
                            result.error("UNAVAILABLE", "Battery level not available.", null);
                        }
                        break;
                    case "redsys":
                        final String license = call.argument("license");

                        //String environment = TPVVConstants.ENVIRONMENT_REAL;
                        String environment = TPVVConstants.ENVIRONMENT_TEST; //TODO cambiar a producción antes de subir versión

                        final String fuc = call.argument("fuc");
                        final String terminal = call.argument("terminal");
                        final String currency = call.argument("currency");
                        final String language = call.argument("language");
                        final String orderCode = call.argument("orderCode");
                        final double amount = Objects.requireNonNull(call.argument("amount"));
                        final String paymentType = Objects.requireNonNull(call.argument("paymentType"));
                        final String merchantId = Objects.requireNonNull(call.argument("merchantId"));
                        final String merchantUrl = Objects.requireNonNull(call.argument("merchantUrl"));
                        final String merchantData = Objects.requireNonNull(call.argument("merchantData"));
                        final String productDescription = call.argument("productDescription");
                        final HashMap<String, String> extraParams = call.argument("params");

                        Log.i("DVLOG", "RETRIEVED DATA:");
                        Log.i("DVLOG", "license: " + license);
                        Log.i("DVLOG", "environment: " + environment);
                        Log.i("DVLOG", "fuc: " + fuc);
                        Log.i("DVLOG", "terminal: " + terminal);
                        Log.i("DVLOG", "currency: " + currency);
                        Log.i("DVLOG", "language: " + language);
                        Log.i("DVLOG", "orderCode: " + orderCode);
                        Log.i("DVLOG", "amount: " + amount);
                        Log.i("DVLOG", "paymentType: " + paymentType);
                        Log.i("DVLOG", "merchantId: " + merchantId);
                        Log.i("DVLOG", "productDescription: " + productDescription);
                        Log.i("DVLOG", "extraParams: " + (extraParams != null ? extraParams.toString() : null));

                        TPVVConfiguration.setLicense(license);
                        TPVVConfiguration.setEnvironment(environment);
                        TPVVConfiguration.setFuc(fuc);
                        TPVVConfiguration.setTerminal(terminal);
                        TPVVConfiguration.setCurrency(currency);
                        TPVVConfiguration.setLanguage(language);
                        TPVVConfiguration.setMerchantUrl(merchantUrl);
                        TPVVConfiguration.setMerchantData(merchantData);

                        Log.i("DVLOG", "opening direct payment");

                        //para guardar datos de la tarjeta enviar el merchant ID
                        TPVV.doWebViewPayment(getApplicationContext(), orderCode, amount, paymentType, null, productDescription, null, new IPaymentResult() {
                            @Override
                            public void paymentResultOK(ResultResponse response) {
                                Log.i("DVLOG", "RESPONSE: " + response.toString());

                                String var1;
                                if (response.getExtraParams() == null) {
                                    var1 = "{\"amount\":\"" + response.getAmount() + '\"' + ", \"currency\":\"" + response.getCurrency() + '\"' + ", \"order\":\"" + response.getOrder() + '\"' + ", \"merchantCode\":\"" + response.getMerchantCode() + '\"' + ", \"terminal\":\"" + response.getTerminal() + '\"' + ", \"responseCode\":\"" + response.getResponseCode() + '\"' + ", \"authorisationCode\":\"" + response.getAuthorisationCode() + '\"' + ", \"transactionType\":\"" + response.getTransactionType() + '\"' + ", \"securePayment\":\"" + response.getSecurePayment() + '\"' + ", \"language\":\"" + response.getLanguage() + '\"' + ", \"cardNumber\":\"" + response.getCardNumber() + '\"' + ", \"cardType\":\"" + response.getCardType() + '\"' + ", \"merchantData\":\"" + response.getMerchantData() + '\"' + ", \"cardCountry\":\"" + response.getCardCountry() + '\"' + ", \"date\":\"" + response.getDate() + '\"' + ", \"hour\":\"" + response.getHour() + '\"' + ", \"identifier\":\"" + response.getIdentifier() + '\"' + ", \"signature\":\"" + response.getSignature() + '\"' + ", \"expiryDate\":\"" + response.getExpiryDate() + '\"' + ", \"cardBrand\":\"" + response.getCardBrand() + '\"' + '}';
                                } else {
                                    var1 = "{\"amount\":\"" + response.getAmount() + '\"' + ", \"currency\":\"" + response.getCurrency() + '\"' + ", \"order\":\"" + response.getOrder() + '\"' + ", \"merchantCode\":\"" + response.getMerchantCode() + '\"' + ", \"terminal\":\"" + response.getTerminal() + '\"' + ", \"responseCode\":\"" + response.getResponseCode() + '\"' + ", \"authorisationCode\":\"" + response.getAuthorisationCode() + '\"' + ", \"transactionType\":\"" + response.getTransactionType() + '\"' + ", \"securePayment\":\"" + response.getSecurePayment() + '\"' + ", \"language\":\"" + response.getLanguage() + '\"' + ", \"cardNumber\":\"" + response.getCardNumber() + '\"' + ", \"cardType\":\"" + response.getCardType() + '\"' + ", \"merchantData\":\"" + response.getMerchantData() + '\"' + ", \"cardCountry\":\"" + response.getCardCountry() + '\"' + ", \"date\":\"" + response.getDate() + '\"' + ", \"hour\":\"" + response.getHour() + '\"' + ", \"identifier\":\"" + response.getIdentifier() + '\"' + ", \"signature\":\"" + response.getSignature() + '\"' + ", \"expiryDate\":\"" + response.getExpiryDate() + '\"' + ", \"cardBrand\":\"" + response.getCardBrand() + '\"' + ", \"extraParams\":" + response.getExtraParams() + '}';
                                }

                                result.success(var1);
                            }

                            @Override
                            public void paymentResultKO(ErrorResponse error) {
                                Log.i("DVLOG", "ERROR: " + error.toString());
                                result.error(error.getCode(), error.getDesc(), error.toString());
                            }
                        });
                        break;
                    case "download":
                        final String path = call.argument("path");
                        String name = call.argument("name");
                        assert path != null;
                        Uri uri = Uri.fromFile(new File(path));
                        if (name == null) name = "doblevia_download.pdf";
                        String file = copyFileToInternalStorage(uri, name);
                        result.success(file);

                        break;
                    default:
                        result.notImplemented();
                        break;
                }
            }
        );
    }

    private String copyFileToInternalStorage(Uri uri, String newDirName) {
        Context mContext = getApplicationContext();
        Cursor returnCursor = mContext.getContentResolver().query(uri, new String[]{
                OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE
        }, null, null, null);


        /*
         * Get the column indexes of the data in the Cursor,
         *     * move to the first row in the Cursor, get the data,
         *     * and display it.
         * */
        int nameIndex = returnCursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
        int sizeIndex = returnCursor.getColumnIndex(OpenableColumns.SIZE);
        returnCursor.moveToFirst();
        String name = (returnCursor.getString(nameIndex));
        String size = (Long.toString(returnCursor.getLong(sizeIndex)));

        File output;
        if (!newDirName.equals("")) {
            File dir = new File(mContext.getFilesDir() + "/" + newDirName);
            if (!dir.exists()) {
                dir.mkdir();
            }
            output = new File(mContext.getFilesDir() + "/" + newDirName + "/" + name);
        } else {
            output = new File(mContext.getFilesDir() + "/" + name);
        }
        try {
            InputStream inputStream = mContext.getContentResolver().openInputStream(uri);
            FileOutputStream outputStream = new FileOutputStream(output);
            int read = 0;
            int bufferSize = 1024;
            final byte[] buffers = new byte[bufferSize];
            while ((read = inputStream.read(buffers)) != -1) {
                outputStream.write(buffers, 0, read);
            }

            inputStream.close();
            outputStream.close();

        } catch (Exception e) {

            Log.e("Exception", Objects.requireNonNull(e.getMessage()));
        }

        return output.getPath();
    }

    private int getBatteryLevel() {
        int batteryLevel;
        BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
        batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);

        return batteryLevel;
    }
}
