package com.example.my_pda_scanner;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * MyPdaScannerPlugin
 */
public class MyPdaScannerPlugin implements FlutterPlugin {

    private EventChannel eventChannel;
    private MethodChannel flutterChannel;
    private Context applicationContext;

    private static String ACTION_DATA_CODE_RECEIVED = "";
    private static String DATA = "";

    private static final String CHARGING_CHANNEL = "my_pda_channel";
    private static final String FLUTTER_TO_ANDROID_CHANNEL = "flutter_to_android";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        flutterChannel = new MethodChannel(
                flutterPluginBinding.getBinaryMessenger(), FLUTTER_TO_ANDROID_CHANNEL);
        flutterChannel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall call, Result result) {
                if (call.method.equals("sendMessage")) {
                    String pda_action = call.argument("pda_action");
                    String data_tag = call.argument("data_tag");
                    ACTION_DATA_CODE_RECEIVED = pda_action;
                    DATA = data_tag;
                    result.success(null); 
                    } else {
                    result.notImplemented();
                }
            }
        });

        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), CHARGING_CHANNEL);
        eventChannel.setStreamHandler(new EventChannel.StreamHandler() {

            private BroadcastReceiver chargingStateChangeReceiver;

            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                chargingStateChangeReceiver = createChargingStateChangeReceiver(events);
                IntentFilter filter = new IntentFilter();
                filter.addAction(ACTION_DATA_CODE_RECEIVED);
                applicationContext.registerReceiver(
                        chargingStateChangeReceiver, filter);
            }

            @Override
            public void onCancel(Object arguments) {
                applicationContext.unregisterReceiver(chargingStateChangeReceiver);
                chargingStateChangeReceiver = null;
            }
        });

        applicationContext = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        eventChannel.setStreamHandler(null);
    }


    private BroadcastReceiver createChargingStateChangeReceiver(final EventChannel.EventSink events) {
        return new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                String code = intent.getStringExtra(DATA);
                if (code != null) {
                    events.success(code);
                }
            }
        };
    }

}
