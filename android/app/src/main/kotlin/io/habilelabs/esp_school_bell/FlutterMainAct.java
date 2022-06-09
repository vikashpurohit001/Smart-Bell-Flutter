package io.habilelabs.esp_school_bell;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.ConnectivityManager.NetworkCallback;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkRequest;
import android.net.wifi.WifiNetworkSpecifier;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.habilelabs.esp_school_bell.wifiutils.WifiConnectorBuilder;
import io.habilelabs.esp_school_bell.wifiutils.WifiUtils;
import io.habilelabs.esp_school_bell.wifiutils.wifiConnect.ConnectionErrorCode;
import io.habilelabs.esp_school_bell.wifiutils.wifiConnect.ConnectionSuccessListener;

public class FlutterMainAct extends FlutterActivity {

    private final String CHANNEL = "habilelabs.io/ESP_bell";
    Map<String, String> wifiInfo;
    MethodChannel.Result mResult;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                if (call.method.equals("WifiConnect")) {
                    mResult = result;
                    wifiInfo = (Map<String, String>) call.arguments;
                    if (ActivityCompat.checkSelfPermission(FlutterMainAct.this, android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED &&
                            ActivityCompat.checkSelfPermission(FlutterMainAct.this, android.Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                        ActivityCompat.requestPermissions(FlutterMainAct.this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION},
                                555);
                    } else {
                        connectToWifi();
                    }

                    Log.d("Aditi", wifiInfo.toString());

                }
            }
        });
    }

    private void connectToWifi() {
        if (wifiInfo != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {

                    ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
                    NetworkRequest networkRequest = new NetworkRequest.Builder()
                            .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
                            .removeCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                            .setNetworkSpecifier(new WifiNetworkSpecifier.Builder()
                                            .setSsid(wifiInfo.get("ssid"))
                                    .setWpa2Passphrase(wifiInfo.get("password"))
                                            .build()
                            )
                            .build();
                    cm.requestNetwork(networkRequest, new ConnectivityManager.NetworkCallback() {
                        @Override
                        public void onUnavailable() {
                            Log.d("TEST", "Network unavailable");
                            mResult.success(false);
                        }

                        @Override
                        public void onAvailable(Network network) {
                            Log.d("TEST", "Network available");
                            mResult.success(true);
                        }
                    });

            }else {
                WifiUtils.withContext(FlutterMainAct.this)
                        .connectWith(wifiInfo.get("ssid"), wifiInfo.get("password"))
                        .setTimeout(60000)
                        .onConnectionResult(new ConnectionSuccessListener() {
                            @Override
                            public void success() {
                                Log.d("Aditi", "Success");
                                mResult.success(true);
                            }

                            @Override
                            public void failed(@NonNull ConnectionErrorCode errorCode) {
                                Log.d("Aditi", errorCode.name() + errorCode.toString() + "failed");
//                            mResult.error(errorCode.name(), errorCode.toString(), "failed");
                                mResult.success(false);
                            }
                        })
                        .start();
            }


        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions,
                                           int[] grantResults) {
        if (requestCode == 555) {// If request is cancelled, the result arrays are empty.
            if (grantResults.length > 0 &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                connectToWifi();
                // Permission is granted. Continue the action or workflow
                // in your app.
            } else {
//                mResult.error("Permission", "Permission Rejected", "Location Permission Rejected");
                mResult.success(false);
            }
            return;
        }
    }


}
