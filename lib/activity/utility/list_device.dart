import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:mizanmobile/activity/utility/printer_util.dart';
import 'package:mizanmobile/helper/utils.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class ListModalDevice extends StatefulWidget {
  const ListModalDevice({Key? key}) : super(key: key);

  @override
  State<ListModalDevice> createState() => _ListModalDeviceState();
}

class _ListModalDeviceState extends State<ListModalDevice> {
  Future<List<BluetoothDevice>>? _dataDevice;

  Future<List<BluetoothDevice>> _getDataDevice() async {
    BlueThermalPrinter btp = BlueThermalPrinter.instance;
    List<BluetoothDevice> data = await btp.getBondedDevices();
    return data;
  }

  @override
  void initState() {
    _dataDevice = _getDataDevice();
    super.initState();
  }

  Icon customIcon = Icon(Icons.search);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List Device"),
        actions: [
          IconButton(
              onPressed: () {
                _getDataDevice();
              },
              icon: Icon(Icons.search))
        ],
      ),
      body: Container(
        child: setListFutureBuilder(),
      ),
    );
  }

  FutureBuilder<List<BluetoothDevice>> setListFutureBuilder() {
    return FutureBuilder(
        future: _dataDevice,
        builder: ((context, snapshot) {
          List<BluetoothDevice> d = snapshot.data ?? [];
          return ListView.builder(
              itemCount: d.length,
              itemBuilder: (BuildContext ctx, int index) {
                BluetoothDevice device = d[index];
                String? deviceName = device.name;
                String? deviceId = device.address;
                return listTile(deviceName, deviceId);
              });
        }));
  }

  ListTile listTile(deviceName, deviceId) {
    ListTile lstl = ListTile(
        title: Text(deviceName),
        subtitle: Text(deviceId),
        onTap: () {
          Utils.showModalBottom(
              context,
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        BluetoothDevice device = BluetoothDevice(deviceName, deviceId);
                        BlueThermalPrinter btp = BlueThermalPrinter.instance;
                        await btp.connect(device);
                      },
                      icon: Icon(Icons.bluetooth_connected),
                      label: Text("Connect"),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        PrinterUtils().printTestDevice();
                      },
                      icon: Icon(Icons.print),
                      label: Text("Test Print"),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        BlueThermalPrinter btp = BlueThermalPrinter.instance;
                        await btp.disconnect();
                      },
                      icon: Icon(Icons.bluetooth_disabled),
                      label: Text("Disconnect"),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Map result = <String, String>{"id": deviceId, "name": deviceName};
                        Navigator.pop(context);
                        Navigator.pop(context, result);
                      },
                      icon: Icon(Icons.check_circle),
                      label: Text("Set Sebagai Default"),
                    ),
                  )
                ],
              ));
          //Utils.bluetoothId = deviceId;
          //Utils.bluetoothName = deviceName;
          //BluetoothDevice device = PrinterUtils().getDevice(deviceId);
          //PrinterUtils().printWithDevice(_dataDevice![index].device);
        });
    return lstl;
  }
}
