import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:escpos_usb_printer/escpos_usb_printer.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<USBDevice> _devices = [];
  bool _connected = false;

  @override
  initState() {
    super.initState();
    _list();
  }

  _list() async {
    List<USBDevice> devices = await EscposUsbPrinter.getUSBDeviceList();
    setState(() {
      _devices = devices;
    });
  }

  _connect(int vendor, int product) async {
    bool success = await EscposUsbPrinter.connectPrinter(vendorId: vendor, productid: product);
    if (success) {
      setState(() {
        _connected = true;
      });
    }
  }

  _print() async {
    await EscposUsbPrinter.printText("Testing ESC POS printer...");
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('ESC POS'),
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.refresh),
                onPressed: () {
                  _list();
                }),
            _connected == true
                ? new IconButton(
                    icon: new Icon(Icons.print),
                    onPressed: () {
                      _print();
                    })
                : new Container(),
          ],
        ),
        body: _devices.length > 0
            ? new ListView(
                scrollDirection: Axis.vertical,
                children: _buildList(_devices),
              )
            : null,
      ),
    );
  }

  List<Widget> _buildList(List<USBDevice> devices) {
    return devices
        .map((device) => new ListTile(
              onTap: () {
                _connect(device.vendorId, device.productId);
              },
              leading: new Icon(Icons.usb),
              title: new Text(device.manufacturerName + " " + device.productName),
              subtitle:
                  new Text(device.vendorId.toString() + " " + device.productId.toString()),
            ))
        .toList();
  }
}
