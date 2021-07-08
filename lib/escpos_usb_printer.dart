import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class USBDevice {
  final int vendorId;
  final int productId;
  final String manufacturerName;
  final String productName;

  const USBDevice(
      {required this.vendorId,
      required this.productId,
      required this.manufacturerName,
      required this.productName});

  Future<bool> print(Uint8ClampedList bytes) async {
    final bool connected = await EscposUsbPrinter.connectPrinter(
        vendorId: this.vendorId, productid: this.productId);

    if (connected) return await EscposUsbPrinter.printBytes(bytes);

    return connected;
  }
}

class EscposUsbPrinter {
  static const MethodChannel _channel =
      const MethodChannel('escpos_usb_printer');

  static Future<List<USBDevice>> getUSBDeviceList() async {
    final List<dynamic> devices = await _channel.invokeMethod('getUSBDeviceList');
    final Iterable<USBDevice> devicesMap = devices
        .map((device) => new USBDevice(
        vendorId: int.parse(device["vendorid"]),
        productId: int.parse(device["productid"]),
        manufacturerName: device["manufacturer"],
        productName: device["product"]));
    return devicesMap.toList();
  }

  static Future<bool> connectPrinter(
      {required int vendorId, required int productid}) async {
    Map<String, int> params = {"vendor": vendorId, "product": productid};
    return await _channel.invokeMethod('connectPrinter', params);
  }

  static Future<bool> closeConn() async {
    return await _channel.invokeMethod('closeConn');
  }

  static Future<bool> printText(String text) async {
    Map<String, dynamic> params = {"text": text};
    return await _channel.invokeMethod('printText', params);
  }

  static Future<bool> printRawData(String text) async {
    Map<String, dynamic> params = {"text": text};
    return await _channel.invokeMethod('printRawData', params);
  }

  static Future<bool> printBytes(List<int> bytes) async {
    Map<String, List<int>> params = {"bytes": bytes};
    return await _channel.invokeMethod('printBytes', params);
  }
}
