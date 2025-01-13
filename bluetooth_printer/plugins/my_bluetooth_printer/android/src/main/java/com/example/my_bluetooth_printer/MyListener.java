package com.example.my_bluetooth_printer;


import android.annotation.SuppressLint;
import android.app.Application;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanResult;
import android.content.Context;
import android.os.Build;
import android.util.Log;

import com.ctaiot.ctprinter.ctpl.CTPL;
import com.ctaiot.ctprinter.ctpl.Device;
import com.ctaiot.ctprinter.ctpl.RespCallback;

import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Consumer;

import com.ctaiot.ctprinter.ctpl.param.PrintMode;

import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;

public class MyListener {
    private final BasicMessageChannel<Object> message_channel;
    private final Map<String, Object> message_map = new HashMap<>();
    private Map<String, Object> arguments;
    private final Map<String, Consumer<String>> action_map = new HashMap<>();
    private List<BluetoothDevice> deviceList = new ArrayList<>();
    private List<String> deviceMessageList = new ArrayList<>();
    private Context applicationContext;
    private BluetoothLeScanner leScanner = BluetoothAdapter.getDefaultAdapter().getBluetoothLeScanner();
    private ScanCallback scanCallback = new ScanCallback() {
        @Override
        public void onScanResult(int callbackType, ScanResult result) {
            super.onScanResult(callbackType, result);
            BluetoothDevice device = result.getDevice();
            if (device.getType() == BluetoothDevice.DEVICE_TYPE_LE ||
                    device.getType() == BluetoothDevice.DEVICE_TYPE_DUAL) {
                if (!deviceList.contains(device) && !device.getName().isEmpty()) {
                    Log.e("deviceAddress", device.getAddress());
                    deviceList.add(device);
                    deviceMessageList.add(device.getName() + "#" + device.getAddress());
                    message_map.clear();
                    message_map.put("bluetooth_list", deviceMessageList);
                    message_channel.send(message_map);    //  将蓝牙设备信息（蓝牙名称和蓝牙MAC地址）发送给flutter端
                }
            }
        }
        @Override
        public void onBatchScanResults(List<ScanResult> results) {
            super.onBatchScanResults(results);
            Log.e("batchScan", results.toString());
        }
        @Override
        public void onScanFailed(int errorCode) {
            super.onScanFailed(errorCode);
            message_map.clear();
            message_map.put("scanMessage", "扫描失败");
            message_channel.send(message_map);
        }
    };
    private RespCallback respCallback = new RespCallback() {
        @Override
        public void onConnectRespsonse(int code_1, int code_2) {
            String responseMessage = "端口:" + code_1 + "#" + "结果:" + code_2;
            Log.e("connectResponse", "连接回传数据<" + code_1 + ">,<" + code_2 + ">");
            message_map.clear();
            message_map.put("connectResponse", responseMessage);
            message_channel.send(message_map);
        }
        
        @Override
        public void onDataResponse(HashMap<String, String> dataMap) {
            String responseMessage = dataMap.toString();
            message_map.clear();
            message_map.put("dataResponse", responseMessage);
            message_channel.send(message_map);
        }
        
        @Override
        public boolean autoSPPBond() {
            return false;
        }
    };
    
    MyListener(String channelName, Context applicationContext, BinaryMessenger binaryMessenger) {
        message_channel = new BasicMessageChannel<>(   //  实例化通信通道对象
                binaryMessenger,
                channelName,
                StandardMessageCodec.INSTANCE
        );
        Log.e("listener_channel_name", channelName);
        this.applicationContext = applicationContext;
        
        action_map.put("startConnect", this:: startConnect);
        action_map.put("startSend", this:: startSend);
        action_map.put("startScan", this::startScan);
        action_map.put("stopScan", this::stopScan);
        action_map.put("closeConnect", this::closeConnect);
        CTPL.getInstance().init((Application) applicationContext, respCallback);
        message_channel.setMessageHandler((message, reply) -> {
            arguments = castMap(message, String.class, Object.class);
            String key = getCurrentKey();
            Log.e("key", key);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                Objects.requireNonNull(action_map.get(key)).accept(key);
            }
        });
    }
    private String getCurrentKey() {
        String key = null;
        if (arguments.containsKey("startConnect"))      key = "startConnect";
        else if (arguments.containsKey("startSend"))   key = "startSend";
        else if (arguments.containsKey("startScan"))    key = "startScan";
        else if (arguments.containsKey("stopScan"))     key = "stopScan";
        else if (arguments.containsKey("closeConnect")) key = "closeConnect";
        return key;
    }
    @SuppressLint("MissingPermission")
    private void startScan(String key) {
        Object value = arguments.get(key);
        if (value == null) return;
        if (!(boolean) value) return;
        Log.e("startScan", value.toString());
        leScanner.startScan(scanCallback);
    }
    @SuppressLint("MissingPermission")
    private void stopScan(String key) {
        Object value = arguments.get(key);
        if (value == null) return;
        if (!(boolean) value) return;
        leScanner.stopScan(scanCallback);
    }
    @SuppressLint("MissingPermission")
    private void startConnect(String key){
        Object value = arguments.get(key);
        if (value == null) return;
        String deviceAddress = (String) value;
        Log.e("startConnect", "开始连接");
        BluetoothDevice bluetoothDevice = null;
        for (BluetoothDevice device: deviceList) {
            if (device.getAddress().equals(deviceAddress)) {
                bluetoothDevice = device;
            }
        }
        if (bluetoothDevice == null) {
            message_map.clear();
            message_map.put("connectMessage", "连接失败");
            message_channel.send(message_map);
            return;
        }
        String bluetoothType = bluetoothDevice.getType() == BluetoothDevice.DEVICE_TYPE_DUAL ?
                "SPP" : "BLE";
        CTPL.Port port = "SPP".equals(bluetoothType) ? CTPL.Port.SPP : CTPL.Port.BLE;
        Device device = new Device();
        device.setPort(port);
        device.setBluetoothMacAddr(deviceAddress);
        if (port == CTPL.Port.BLE) {
            device.setBleServiceUUID("49535343-fe7d-4ae5-8fa9-9fafd205e455");
        }
        CTPL.getInstance().connect(device);
        if (CTPL.getInstance().isConnected()) {
            message_map.clear();
            message_map.put("connectMessage", "连接成功");
            message_channel.send(message_map);
        } else {
            message_map.clear();
            message_map.put("connectMessage", "连接失败");
            message_channel.send(message_map);
        }
    }
    private void startSend(String key) {
        Object value = arguments.get(key);
        if (value == null) return;
        String printData = (String) value;
        if (!CTPL.getInstance().isConnected()) {
            Log.e("sendData", "设备未连接");
            message_map.clear();
            message_map.put("connectMessage", "设备未连接");
            message_channel.send(message_map);
            return;
        }
        Log.e("startSend", printData);
        CTPL.getInstance().clean();
        CTPL.getInstance().setPrintMode(PrintMode.Label_Divide).execute();
        CTPL.getInstance().execute();
        CTPL.getInstance().clean();
        CTPL.getInstance().append(new byte[]{
                27, 64,
                27, 97, 1,//0居左,1居中,2居右
        });
        CTPL.getInstance().append(printData.getBytes(Charset.forName("gb2312")));
        // CTPL.getInstance().append(new byte[]{0X0D, 0X0A});
        CTPL.getInstance().execute();
    }
    private void closeConnect(String key) {
        Object value = arguments.get(key);
        if (value == null) return;
        if (!(boolean) value) return;
        CTPL.getInstance().disconnect();
    }
    public static <K, V> Map<K, V> castMap(Object obj, Class<K> key, Class<V> value) {
        /*
        对于对象转换为Map类型作出检查
        */
        Map<K, V> map = new HashMap<>();
        if (obj instanceof Map<?, ?>) {
            for (Map.Entry<?, ?> entry : ((Map<?, ?>) obj).entrySet()) {
                map.put(key.cast(entry.getKey()), value.cast(entry.getValue()));
            }
            return map;
        }
        return null;
    }
    
}
