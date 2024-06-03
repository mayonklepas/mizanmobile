import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart';

import 'database_helper.dart';

class Utils {
  Utils() {}

  static String connectionName = "";

  static String mainUrl = "";

  static String imageDefaultUrl = "";

  static String idDept = "";

  static String idDeptTemp = "";

  static String namaDept = "";

  static String namaDeptTemp = "";

  static String idGudang = "";

  static String idGudangTemp = "";

  static String namaGudang = "";

  static String namaGudangTemp = "";

  static String idAkunStokOpname = "";

  static String namaAkunStokOpname = "";

  static String idAkunPenjualan = "";

  static String namaAkunPenjualan = "";

  static String idLokasi = "";

  static String namaLokasi = "";

  static String idSatuan = "";

  static String satuan = "";

  static String idKelompok = "";

  static String namaKelompok = "";

  static String idUser = "";

  static String imageUrl = "";

  static String token = "";

  static String namaUser = "";

  static String namaPenggunaTemp = "";

  static String idPenggunaTemp = "";

  static String idPelanggan = "";

  static String namaPelanggan = "";

  static String kodePelanggan = "";

  static String idGolonganPelanggan = "";

  static String idGolongan2Pelanggan = "";

  static String companyCode = "";

  static String idKelompokTransaksi = "";

  static String namaKelompokTransaksi = "";

  static String bluetoothId = "";

  static String bluetoothName = "";

  static String isPdtMode = "0";

  static String isShowStockProgram = "0";

  static String footerStruk = "";

  static String headerStruk = "";

  static Map<String, dynamic> hakAkses = {
    "mobile_dashboard": 0,
    "mobile_setupprogram": 0,
    "mobile_inputdatamaster": 0,
    "mobile_editdatamaster": 0,
    "mobile_editpenjualan": 0,
    "mobile_inputpembayaranpiutang": 0,
    "mobile_editpenerimaanbarang": 0,
    "mobile_editpembelian": 0,
    "mobile_inputpembayaranhutang": 0,
    "mobile_editstokopname": 0,
    "mobile_edittransferbarang": 0
  };

  static getPref(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? result = sp.getString(key);
    return result;
  }

  void setPref(String key, String value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(key, value);
  }

  static String formatNumber(var value,
      {decimalDigit = 0, String symbol = ""}) {
    if (value.isNaN) {
      return "0";
    }
    NumberFormat nf = NumberFormat.currency(
        locale: "id", symbol: symbol, decimalDigits: decimalDigit);

    return nf.format(value);
  }

  static String currentDateString() {
    DateTime dt = DateTime.now();
    String day = dt.day.toString();
    String month = dt.month.toString();
    String year = dt.year.toString();

    if (day.length == 1) {
      day = "0" + day;
    }

    if (month.length == 1) {
      month = "0" + month;
    }

    String formattedDate = year + "-" + month + "-" + day;
    return formattedDate;
  }

  static String fisrtDateOfMonthString() {
    DateTime dt = DateTime.now();
    String month = dt.month.toString();
    String year = dt.year.toString();

    if (month.length == 1) {
      month = "0" + month;
    }

    String formattedDate = year + "-" + month + "-01";
    return formattedDate;
  }

  static String formatDate(String value) {
    DateTime dt;
    if (value == null || value as String == "") {
      dt = DateTime.now();
    } else {
      dt = DateTime.parse(value);
    }

    String day = dt.day.toString();
    String month = dt.month.toString();
    String year = dt.year.toString();

    if (day.length == 1) {
      day = "0" + day;
    }

    if (month.length == 1) {
      month = "0" + month;
    }

    String formattedDate = day + "/" + month + "/" + year;
    return formattedDate;
  }

  static double strToDouble(String value) {
    try {
      double result = double.parse(value);
      return result;
    } catch (e) {
      return 0;
    }
  }

  static int strToInt(String value) {
    try {
      int result = int.parse(value);
      return result;
    } catch (e) {
      return 0;
    }
  }

  static String formatStdDate(DateTime value) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(value);
    return formattedDate;
  }

  static InputDecoration inputDecoration(String hint) {
    InputDecoration decor = InputDecoration(
        fillColor: Colors.white,
        filled: true,
        contentPadding: EdgeInsets.only(),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1.2)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1.3)),
        hintText: hint,
        prefixIcon: Icon(Icons.search),
        hintStyle: TextStyle(color: Colors.black54));
    return decor;
  }

  static Widget appBarSearch(void Function(String keyword) search,
      {String hint = "Cari", bool focus = true}) {
    return Container(
        height: 35,
        child: TextField(
          cursorColor: Colors.blueAccent,
          style: TextStyle(color: Colors.black54),
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.only(),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.2)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.3)),
              hintText: hint,
              prefixIcon: Icon(Icons.search),
              hintStyle: TextStyle(color: Colors.black54)),
          textInputAction: TextInputAction.search,
          autofocus: focus,
          onSubmitted: search,
        ));
  }

  static Widget appBarSearchDynamic(void Function(String keyword) search,
      {String hint = "Cari", bool focus = true, String mode = "onChange"}) {
    InputDecoration decor = InputDecoration(
        fillColor: Colors.white,
        filled: true,
        contentPadding: EdgeInsets.only(),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1.2)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1.3)),
        hintText: hint,
        prefixIcon: Icon(Icons.search),
        hintStyle: TextStyle(color: Colors.black54));
    if (mode == "onChange") {
      return Container(
          height: 35,
          child: TextField(
              cursorColor: Colors.blueAccent,
              style: TextStyle(color: Colors.black54),
              decoration: decor,
              textInputAction: TextInputAction.search,
              autofocus: focus,
              onChanged: search));
    }

    return Container(
        height: 35,
        child: TextField(
          cursorColor: Colors.blueAccent,
          style: TextStyle(color: Colors.black54),
          decoration: decor,
          textInputAction: TextInputAction.search,
          autofocus: focus,
          onSubmitted: search,
        ));
  }

  static Widget appBarSearchStatic(void Function() search,
      {String hint = "Cari", bool focus = false, bool readOnly = false}) {
    return Container(
        height: 35,
        child: TextField(
          readOnly: readOnly,
          showCursor: !readOnly,
          cursorColor: Colors.blueAccent,
          style: TextStyle(color: Colors.black54),
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.only(),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.2)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.3)),
              hintText: hint,
              prefixIcon: Icon(Icons.search),
              hintStyle: TextStyle(color: Colors.black54)),
          textInputAction: TextInputAction.search,
          autofocus: focus,
          onTap: search,
        ));
  }

  static String limitText(String text, {int limit = 50}) {
    if (text.length < limit) {
      return text;
    } else {
      return text.substring(0, limit) + "...";
    }
  }

  static Future<Position> getPosisition() async {
    Position _position;
    LocationPermission _permission = await Geolocator.checkPermission();
    if (_permission == LocationPermission.denied) {
      _permission = await Geolocator.requestPermission();
    }

    _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);

    return _position;
  }

  static Future<void> goToUrl(String url) async {
    if (!await launch(url)) {
      throw 'Could not launch $url';
    } else {
      await launch(url);
      await closeWebView();
    }
  }

  static String nullSafety(dynamic param) {
    if (param == null) {
      return "N/A";
    }
    return param;
  }

  static Container labelSetter(String text,
      {double size = 14,
      bool bold = false,
      Color color = Colors.black,
      TextAlign align = TextAlign.left,
      double top = 2,
      double bottom = 2}) {
    FontWeight isWeight = FontWeight.normal;
    if (bold) {
      isWeight = FontWeight.bold;
    }
    return Container(
      padding: EdgeInsets.only(top: top, bottom: bottom),
      child: Text(text,
          textAlign: align,
          style: TextStyle(
            fontSize: size,
            fontWeight: isWeight,
            color: color,
          )),
    );
  }

  static Container labelValueSetter(String label, String value,
      {double sizeLabel = 14,
      double sizeValue = 14,
      bool boldLabel = false,
      bool boldValue = false,
      Color colorLabel = Colors.black,
      Color colorValue = Colors.black,
      TextAlign alignLabel = TextAlign.left,
      TextAlign alignValue = TextAlign.right,
      int flexLabel = 1,
      int flexValue = 1,
      String separator = "",
      double top = 2,
      double bottom = 2}) {
    FontWeight isWeightLabel = FontWeight.normal;
    FontWeight isWeightValue = FontWeight.normal;

    if (boldLabel) {
      isWeightLabel = FontWeight.bold;
    }

    if (boldValue) {
      isWeightValue = FontWeight.bold;
    }

    return Container(
      padding: EdgeInsets.only(top: top, bottom: bottom),
      child: Row(
        children: [
          Expanded(
            flex: flexLabel,
            child: Text(label,
                textAlign: alignLabel,
                style: TextStyle(
                    fontSize: sizeLabel,
                    fontWeight: isWeightLabel,
                    color: colorLabel)),
          ),
          Expanded(
            flex: flexValue,
            child: Text(value,
                textAlign: alignValue,
                style: TextStyle(
                    fontSize: sizeLabel,
                    fontWeight: isWeightValue,
                    color: colorValue)),
          ),
        ],
      ),
    );
  }

  static SizedBox bagde(String text) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        color: Colors.blue,
        child: Container(
          child: Center(
            child: Utils.labelSetter(text,
                bold: true, size: 30, color: Colors.white),
          ),
        ),
      ),
    );
  }

  static Future<DateTime?> getDatePicker(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2500));
    return pickedDate;
  }

  static Container labelForm(String label,
      {double top = 10, double bottom = 0, double left = 0, double right = 0}) {
    return Container(
      margin:
          EdgeInsets.only(top: top, bottom: bottom, left: left, right: right),
      child: Text(label),
    );
  }

  static showProgress(BuildContext context,
      {String message = "Memuat Data..."}) {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 0,
                      child: Container(child: CircularProgressIndicator())),
                  Expanded(
                    child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(message)),
                  )
                ],
              ),
            ),
          );
        });
  }

  static showProgressCustom(BuildContext context, String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 0,
                      child: Container(child: CircularProgressIndicator())),
                  Expanded(
                    child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(message)),
                  )
                ],
              ),
            ),
          );
        });
  }

  static showMessage(String message, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Informasi"),
            content: Container(
              child: Text(message),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Tutup"))
            ],
          );
        });
  }

  static showMessageAction(
      String message, BuildContext context, ElevatedButton button) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Informasi"),
            content: Container(
              child: Text(message),
            ),
            actions: [button],
          );
        });
  }

  static showListDialog(String title, List<Widget> items, BuildContext context,
      {double size = 300}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: size,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 0,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: labelSetter(title, size: 19),
                    ),
                  ),
                  Expanded(
                      child: ListView(
                    children: items,
                  ))
                ],
              ),
            ),
          );
        });
  }

  static Future<List<dynamic>> getDataBarangByCode(String barcode) async {
    String urlString =
        "${Utils.mainUrl}datapopup/daftarbarang?idgudang=${Utils.idGudang}&cari=$barcode";
    Uri url = Uri.parse(urlString);
    Response response = await get(url, headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body)["data"];
    return jsonData;
  }

  static Future<dynamic> getHttpData(String path, String param) async {
    String urlString = "${Utils.mainUrl}$path?$param";
    Uri url = Uri.parse(urlString);
    Response response = await get(url);
    var jsonData = jsonDecode(response.body);
    return jsonData;
  }

  static Future<dynamic> postHttpData(
      BuildContext context, Map<String, Object> postBody, urlPath) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}$urlPath";
    Uri url = Uri.parse(urlString);
    Response response = await post(
      url,
      body: jsonEncode(postBody),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    var jsonData = jsonDecode(response.body);
    Navigator.pop(context);
    return jsonData;
  }

  static showModalBottom(BuildContext context, Column content) async {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
                padding:
                    EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
                child: content),
          );
        });
  }

  static Future<bool> showConfirmMessage(
      BuildContext context, String message) async {
    bool result = false;

    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("KONFIRMASI"),
            content: Container(
              child: Text(message),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    result = true;
                    Navigator.pop(context);
                  },
                  child: Text("Ya")),
              ElevatedButton(
                  onPressed: () {
                    result = false;
                    Navigator.pop(context);
                  },
                  child: Text("Batal")),
            ],
          );
        });

    return result;
  }

  static Map<String, String> setHeader() {
    Map<String, String> header = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + Utils.token,
      'company-code': Utils.companyCode
    };
    return header;
  }

  static Map<String, String> setHeaderMultiPart() {
    Map<String, String> header = <String, String>{
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ' + Utils.token,
      'company-code': Utils.companyCode
    };
    return header;
  }

  static String koooosong(String param) {
    if (param == "" || param == null) {
      return "0";
    }
    return param;
  }

  static void initAppParam() {
    Utils.idPenggunaTemp = "-1";
    Utils.namaPenggunaTemp = "SEMUA";
    Utils.idDeptTemp = Utils.idDept;
    Utils.namaDeptTemp = Utils.namaDept;
    Utils.idGudangTemp = Utils.idGudang;
    Utils.namaGudangTemp = Utils.namaGudang;
    Utils.idKelompokTransaksi = "-1";
    Utils.namaKelompokTransaksi = "SEMUA";
  }

  static Future<void> initHakAkses() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    Utils.hakAkses = jsonDecode(sp.getString("hakakses")!);
  }

  static String removeDotSeparator(String src) {
    return src.replaceAll(".", "");
  }

  static void setAllPref() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    Utils.connectionName = sp.getString("defaultConnectionName").toString();
    Utils.mainUrl = sp.getString("defaultConnection").toString();
    Utils.imageUrl = sp.getString("defaultImageUrl").toString();
    //Utils.idUser = sp.getString("defaultIdUser").toString();
    //Utils.token = sp.getString("token").toString();
    //Utils.namaUser = sp.getString("namauser").toString();
    //Utils.hakAkses = jsonDecode(sp.getString("hakakses").toString()) ?? {};

    Utils.companyCode = sp.getString("defaultCompanyCode").toString();

    dynamic mapSetup =
        jsonDecode(sp.getString(Utils.connectionName).toString());
    if (mapSetup != null) {
      Utils.idDept = mapSetup["defaultIdDept"].toString();
      Utils.namaDept = mapSetup["defaultNamaDept"].toString();
      Utils.idAkunStokOpname = mapSetup["defaultIdAkunStokOpname"].toString();
      Utils.namaAkunStokOpname =
          mapSetup["defaultNamaAkunStokOpname"].toString();
      Utils.idGudang = mapSetup["defaultIdGudang"].toString();
      Utils.namaGudang = mapSetup["defaultNamaGudang"].toString();
      Utils.idPelanggan = mapSetup["defaultIdPelanggan"].toString();
      Utils.namaPelanggan = mapSetup["defaultNamaPelanggan"].toString();
      Utils.idGolonganPelanggan =
          mapSetup["defaultIdGolonganPelanggan"].toString();

      Utils.idSatuan = mapSetup["defaultIdSatuan"].toString();
      Utils.satuan = mapSetup["defaultSatuan"].toString();
      Utils.idLokasi = mapSetup["defaultIdLokasi"].toString();
      Utils.namaLokasi = mapSetup["defaultNamaLokasi"].toString();
      Utils.idKelompok = mapSetup["defaultIdKelompok"].toString();
      Utils.namaKelompok = mapSetup["defaultNamaKelompok"].toString();
      Utils.bluetoothId = mapSetup["defaultIdBluetoothDevice"].toString();
      Utils.bluetoothName = mapSetup["defaultBluetoothDevice"].toString();
      Utils.isPdtMode = mapSetup["defaultIsPdtMode"] ?? "0";
      Utils.isShowStockProgram = mapSetup["defaultIsShowStockProgram"] ?? "0";

      Utils.footerStruk = mapSetup["defaultFooterStruk"] ?? "";
      Utils.headerStruk = mapSetup["defaultHeaderStruk"] ?? "";
    }
  }

  static String currentDateTimeString() {
    DateTime dt = DateTime.now();
    String day = dt.day.toString();
    String month = dt.month.toString();
    String year = dt.year.toString();
    String hour = dt.hour.toString();
    String minute = dt.minute.toString();
    String second = dt.second.toString();

    if (day.length == 1) {
      day = "0$day";
    }

    if (month.length == 1) {
      month = "0$month";
    }

    if (hour.length == 1) {
      hour = "0$hour";
    }

    if (minute.length == 1) {
      minute = "0$minute";
    }

    if (second.length == 1) {
      second = "0$second";
    }

    String formattedDateTime = "$year-$month-$day $hour:$minute:$second";
    return formattedDateTime;
  }

  static Future<void> syncLocalData({bool isDebug = false}) async {
    try {
      var db = DatabaseHelper();
      List<dynamic> lsSyncInfo =
          await db.readDatabase("SELECT * FROM sync_info LIMIT 1");
      String lastUpdate = lsSyncInfo[0]["last_updated"];
      String urlString =
          "${Utils.mainUrl}barang/syncbarang?tglupdate=$lastUpdate&idgudang=${idGudang}";
      if (isDebug == true) {
        urlString =
            "http://103.250.11.167:8081/api/barang/syncbarang?tglupdate=$lastUpdate&idgudang=1-1";
      }
      log(urlString);
      Response response =
          await get(Uri.parse(urlString), headers: Utils.setHeader());
      String responseBody = response.body;
      log(responseBody);
      dynamic responseParsed = jsonDecode(responseBody);
      List<dynamic> dataBarang = responseParsed["data"];
      List<dynamic> lsbarangTemp =
          await db.readDatabase("SELECT * FROM barang_temp LIMIT 10");
      List<String> lsQueryDelete = [];
      if (lsbarangTemp.isNotEmpty) {
        for (var d in dataBarang) {
          String idbarang = d["detail_barang"]["NOINDEX"].toString();
          String query = "DELETE FROM barang_temp WHERE idbarang = '$idbarang'";
          lsQueryDelete.add(query);
        }
        log("Deleting ${Utils.formatNumber(lsQueryDelete.length)} duplicate data");
        await db.writeBatchDatabase(lsQueryDelete);
      }

      List<String> lsQueryInsert = [];
      for (var d in dataBarang) {
        String idbarang = d["detail_barang"]["NOINDEX"].toString();
        String kode = d["detail_barang"]["KODE"].toString();
        String nama = d["detail_barang"]["NAMA"].toString();
        String detail = jsonEncode(d["detail_barang"]);
        String multiSatuan = jsonEncode(d["multi_satuan"]);
        String multiHarga = jsonEncode(d["multi_harga"]);
        String hargaTanggal = jsonEncode(d["harga_tanggal"]);
        String query =
            "INSERT INTO barang_temp(idbarang,kode,nama,detail_barang,multi_satuan,multi_harga,harga_tanggal,date_created) VALUES ('$idbarang','$kode','$nama','$detail','$multiSatuan','$multiHarga','$hargaTanggal','${Utils.currentDateTimeString()}')";
        lsQueryInsert.add(query);
      }

      log("Inserting ${Utils.formatNumber(lsQueryInsert.length)} new data");
      await db.writeBatchDatabase(lsQueryInsert);

      log("Updating sync info");
      await db.writeDatabase("UPDATE sync_info SET last_updated = ?",
          params: [Utils.currentDateTimeString()]);
    } catch (e, stacktrace) {
      log(e.toString());
      log(stacktrace.toString());
    }
  }

  static Widget widgetSetter(Widget Function() setter) {
    return setter();
  }
}
