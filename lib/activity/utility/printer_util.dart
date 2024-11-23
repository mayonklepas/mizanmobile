import 'dart:developer';
import 'dart:typed_data';

import 'package:mizanmobile/activity/utility/print_enum.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:http/http.dart' as http;

import '../../helper/utils.dart';

class PrinterUtils {
  Future<Map<String, String>> printReceipt(List<dynamic> data, dynamic additionalInfo) async {
    //var response = await http.get(Uri.parse(Utils.imageUrl + "logo.png"));
    //Uint8List bytesNetwork = response.bodyBytes;
    //Uint8List imageBytesFromNetwork =
    //bytesNetwork.buffer.asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes);

    try {
      BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
      bool? isConnected = await bluetooth.isConnected;
      if (isConnected == false) {
        try {
          BluetoothDevice device = BluetoothDevice(Utils.bluetoothName, Utils.bluetoothId);
          await bluetooth.connect(device);
        } catch (e) {
          return {"status": "error", "message": e.toString()};
        }
      }

      //bluetooth.printImageBytes(imageBytesFromNetwork);
      //bluetooth.printNewLine();

      List<String> formatList = Utils.strukListFormat.split(",");
      String fmtList = "%${formatList[0]}s %${formatList[1]}s %${formatList[2]}s %n";
      String toko = Utils.connectionName;
      String tanggal = additionalInfo["tanggal"];
      String tanggalPrint = Utils.currentDateTimeString();
      String kasir = additionalInfo["kasir"];
      String header = Utils.headerStruk;
      String kodePelanggan = additionalInfo["kodePelanggan"];
      String namaPelanggan = additionalInfo["namaPelanggan"];
      double jumlahUang = additionalInfo["jumlahUang"] ?? 0.0;
      String strukTipe = additionalInfo["strukTipe"] ?? "";

      int fontMedium = Size.medium.val;
      int fontMediumBold = Size.boldMedium.val;
      int alignLeft = Align.left.val;
      int alignCenter = Align.center.val;

      try {
        if (strukTipe == "orderPenjualan") {
          bluetooth.printCustom("ORDER PENJUALAN", fontMediumBold, alignLeft);
          bluetooth.printNewLine();
        }

        bluetooth.printCustom(toko, fontMediumBold, alignCenter);
        bluetooth.printCustom(header, fontMedium, alignCenter);

        bluetooth.printCustom(tanggal, fontMedium, alignLeft);
        bluetooth.printCustom("No. ${additionalInfo["noref"]}", fontMedium, alignLeft);
        bluetooth.printCustom("(${kodePelanggan} - ${namaPelanggan})", fontMedium, alignLeft);
        bluetooth.printCustom("Kasir : $kasir", fontMedium, alignLeft);

        bluetooth.printNewLine();
        double result = 0.0;
        int counter = 1;
        for (var d in data) {
          String nama = d["NAMA"];
          double harga = d["HARGA"];
          double qty = d["QTY"] ?? d["QTYORDER"];
          double diskon = d["DISKONNOMINAL"];
          double total = (harga * qty) - (diskon * qty);
          String keterangan = d["KETERANGAN"];
          result = result + total;

          String fmtCounter = Utils.formatNumber(counter);
          String fmtHarga = Utils.formatNumber(harga);
          String fmtQty = Utils.formatNumber(qty);
          String fmtDiskon = Utils.formatNumber(diskon);
          String fmtTotal = Utils.formatNumber(total);

          bluetooth.printCustom("$fmtCounter. $nama", fontMedium, alignLeft);
          bluetooth.print3Column(
              "  " + fmtHarga + " x " + fmtQty, "DISC:" + fmtDiskon, fmtTotal, fontMedium,
              format: fmtList);

          if (keterangan.isNotEmpty) {
            bluetooth.printCustom("  *Ket : $keterangan", fontMedium, alignLeft);
          }

          counter++;
        }
        String fmtResult = Utils.formatNumber(result);
        String fmtJumlahUang = Utils.formatNumber(jumlahUang);
        double kembalian = jumlahUang - result;
        String fmtKembalian = Utils.formatNumber(kembalian);

        bluetooth.printNewLine();
        bluetooth.printLeftRight("Total", fmtResult, Size.bold.val);

        if (strukTipe == "") {
          bluetooth.printLeftRight("Jumlah uang", fmtJumlahUang, Size.bold.val);
          bluetooth.printLeftRight("Kembalian", fmtKembalian, Size.bold.val);
        }

        bluetooth.printNewLine();
        bluetooth.printCustom(Utils.footerStruk, fontMedium, alignCenter);
        bluetooth.printNewLine();
        bluetooth.printCustom(tanggalPrint, fontMedium, alignCenter);
        bluetooth.paperCut();
        return {"status": "success", "message": "printing success"};
      } catch (e) {
        return {"status": "error", "message": e.toString()};
      }
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
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

  printTestDevice2() async {
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
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.medium.val);
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.bold.val);
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.bold.val,
            format: "%-15s %15s %n"); //15 is number off character from left or right
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        //bluetooth.paperCut(); //some printer not supported (sometime making image not centered)
        //bluetooth.drawerPin2(); // or you can use bluetooth.drawerPin5();
      }
    });
  }
}
