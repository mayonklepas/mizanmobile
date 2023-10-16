import 'dart:convert';

import 'package:esc_pos_utils_plus/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mizanmobile/activity/barang/input_barang.dart';
import 'package:mizanmobile/activity/utility/printer_util.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

import '../../database_helper.dart';

class ListModalDevice extends StatefulWidget {
  const ListModalDevice({Key? key}) : super(key: key);

  @override
  State<ListModalDevice> createState() => _ListModalDeviceState();
}

class _ListModalDeviceState extends State<ListModalDevice> {
  List<ScanResult> _dataDevice = [];

  void _getDataDevice() {
    FlutterBluePlus.scanResults.listen((lsResult) {
      setState(() {
        _dataDevice.addAll(lsResult);
      });
    });
    FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
    // _dataDevice = ls as Future<List<String>>?;
    FlutterBluePlus.stopScan();
  }

  @override
  void initState() {
    _getDataDevice();
    super.initState();
  }

  Icon customIcon = Icon(Icons.search);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List Device"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.sync(() {
            setState(() {});
          });
        },
        child: Container(child: ListView.builder(itemBuilder: (context, index) {
          if (_dataDevice.isEmpty) {
            return ListTile();
          }
          ListTile lstl = ListTile(
              title: Text(_dataDevice[index].device.platformName),
              subtitle: Text(_dataDevice[index].device.remoteId.str),
              onTap: () {
                BluetoothDevice device = _dataDevice[index].device;
                PrinterUtils(device).printWithDevice();
              });
          return lstl;
        })),
      ),
    );
  }
}
