import 'dart:developer';
import 'dart:typed_data';

import 'package:mizanmobile/activity/utility/print_enum.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:http/http.dart' as http;

import '../../utils.dart';

class PrinterUtils {
  printReceipt(List<dynamic> data, dynamic additionalInfo) async {
    BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
    //var response = await http.get(Uri.parse(Utils.imageUrl + "logo.png"));
    //Uint8List bytesNetwork = response.bodyBytes;
    //Uint8List imageBytesFromNetwork =
    //bytesNetwork.buffer.asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes);

    bool? isConnected = await bluetooth.isConnected;
    if (isConnected == false) {
      try {
        BluetoothDevice device = BluetoothDevice(Utils.bluetoothName, Utils.bluetoothId);
        await bluetooth.connect(device);
      } catch (e) {
        log(e.toString());
        return;
      }
    }

    //bluetooth.printImageBytes(imageBytesFromNetwork);
    //bluetooth.printNewLine();
    bluetooth.printCustom(Utils.connectionName, Size.boldMedium.val, Align.center.val);
    bluetooth.printLeftRight("Kasir", Utils.namaUser, Size.medium.val, format: "%-20s %20s %n");
    bluetooth.printLeftRight("Tanggal", Utils.currentDateTimeString(), Size.medium.val,
        format: "%-20s %20s %n");
    bluetooth.printLeftRight("Pelanggan", additionalInfo["namaPelanggan"], Size.medium.val,
        format: "%-20s %20s %n");
    bluetooth.printNewLine();
    double result = 0.0;
    int counter = 1;
    for (var d in data) {
      String nama = d["NAMA"];
      double harga = d["HARGA"];
      int qty = d["QTY"];
      double diskon = d["DISKON_NOMINAL"];
      double total = (harga * qty) - (diskon * qty);
      result = result + total;
      bluetooth.printCustom(
          "${Utils.formatNumber(counter)}. $nama", Size.medium.val, Align.left.val);
      bluetooth.print3Column(Utils.formatNumber(harga) + "x" + Utils.formatNumber(qty),
          "disc:" + Utils.formatNumber(diskon), Utils.formatNumber(total), Size.medium.val,
          format: "%-13s %10s %13s %n");
      counter++;
    }
    bluetooth.printNewLine();
    bluetooth.printLeftRight("Total", Utils.formatNumber(result), Size.bold.val);
    double jumlahUang = additionalInfo["jumlahUang"];
    double kembalian = jumlahUang - result;
    bluetooth.printLeftRight("Jumlah uang", Utils.formatNumber(jumlahUang), Size.bold.val);
    bluetooth.printLeftRight("Kembalian", Utils.formatNumber(kembalian), Size.bold.val);
    bluetooth.printNewLine();
    bluetooth.printCustom("--Terima kasih--", Size.medium.val, Align.center.val);
    bluetooth.paperCut();
  }

  printTestDevice() async {
    BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
    var response = await http.get(Uri.parse(Utils.imageUrl + "logo.png"));
    Uint8List bytesNetwork = response.bodyBytes;
    Uint8List imageBytesFromNetwork =
        bytesNetwork.buffer.asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes);

    bool? isConnected = await bluetooth.isConnected;

    if (isConnected == false) {
      BluetoothDevice device = BluetoothDevice(Utils.bluetoothName, Utils.bluetoothId);
      await bluetooth.connect(device);
    }

    bluetooth.isConnected.then((isConnected) {
      if (isConnected == true) {
        bluetooth.printNewLine();
        bluetooth.printCustom("HEADER", Size.boldMedium.val, Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printImageBytes(imageBytesFromNetwork);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.medium.val);
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.bold.val);
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.bold.val,
            format: "%-15s %15s %n"); //15 is number off character from left or right
        bluetooth.printNewLine();
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.boldMedium.val);
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.boldLarge.val);
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.extraLarge.val);
        bluetooth.printNewLine();
        bluetooth.print3Column("Col1", "Col2", "Col3", Size.bold.val);
        bluetooth.print3Column("Col1", "Col2", "Col3", Size.bold.val,
            format: "%-10s %10s %10s %n"); //10 is number off character from left center and right
        bluetooth.printNewLine();
        bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", Size.bold.val);
        bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", Size.bold.val,
            format: "%-8s %7s %7s %7s %n");
        bluetooth.printNewLine();
        bluetooth.printCustom("čĆžŽšŠ-H-ščđ", Size.bold.val, Align.center.val,
            charset: "windows-1250");
        bluetooth.printLeftRight("Številka:", "18000001", Size.bold.val, charset: "windows-1250");
        bluetooth.printCustom("Body left", Size.bold.val, Align.left.val);
        bluetooth.printCustom("Body right", Size.medium.val, Align.right.val);
        bluetooth.printNewLine();
        bluetooth.printCustom("Thank You", Size.bold.val, Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printQRcode("Insert Your Own Text to Generate", 200, 200, Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        //bluetooth.paperCut(); //some printer not supported (sometime making image not centered)
        //bluetooth.drawerPin2(); // or you can use bluetooth.drawerPin5();
      }
    });
  }
}
