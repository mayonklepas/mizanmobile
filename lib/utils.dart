import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart';

class Utils {
  Utils() {}

  static String mainUrl = "";

  static String idDept = "";

  static String namaDept = "";

  static String idGudang = "";

  static String namaGudang = "";

  static String idAkunStokOpname = "";

  static String namaAkunStokOpname = "";

  static String idUser = "";

  static String imageUrl = "";

  static String token = "";

  static String namaUser = "";

  static getPref(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? result = sp.getString(key);
    return result;
  }

  void setPref(String key, String value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(key, value);
  }

  static String formatRp(var value) {
    NumberFormat nf = NumberFormat.currency(locale: "id", symbol: "Rp ", decimalDigits: 0);

    return nf.format(value);
  }

  static String formatNumber(var value) {
    NumberFormat nf = NumberFormat.compact(locale: "id");
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

  static String formatStdDate(DateTime value) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(value);
    return formattedDate;
  }

  static Widget appBarSearch(void Function(String keyword) search, {String hint = "Cari"}) {
    return Container(
        height: 35,
        child: TextField(
            cursorColor: Colors.blueAccent,
            style: TextStyle(color: Colors.black54),
            decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.only(),
                enabledBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1.2)),
                focusedBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1.3)),
                hintText: hint,
                prefixIcon: Icon(Icons.search),
                hintStyle: TextStyle(color: Colors.black54)),
            textInputAction: TextInputAction.search,
            onSubmitted: search));
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

    _position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);

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

  static TableRow labelDuoSetter(String text1, String text2,
      {double size = 14,
      bool bold = false,
      Color color = Colors.black,
      TextAlign align = TextAlign.left,
      bool isRight = false}) {
    FontWeight isWeight = FontWeight.normal;
    if (bold) {
      isWeight = FontWeight.bold;
    }

    TextAlign secondAlign = TextAlign.left;
    if (isRight) {
      secondAlign = TextAlign.right;
    }
    return TableRow(
      children: [
        Text(text1,
            textAlign: align, style: TextStyle(fontSize: size, fontWeight: isWeight, color: color)),
        Text(text2,
            textAlign: secondAlign,
            style: TextStyle(fontSize: size, fontWeight: isWeight, color: color)),
      ],
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
            child: Utils.labelSetter(text, bold: true, size: 30, color: Colors.white),
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
      margin: EdgeInsets.only(top: top, bottom: bottom, left: left, right: right),
      child: Text(label),
    );
  }

  static showProgress(BuildContext context) {
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
                  Expanded(flex: 0, child: Container(child: CircularProgressIndicator())),
                  Expanded(
                    child:
                        Container(margin: EdgeInsets.only(left: 10), child: Text("Memuat Data...")),
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

  static showMessageAction(String message, BuildContext context, ElevatedButton button) {
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
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
                padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 50), child: content),
          );
        });
  }

  static Future<bool> showConfirmMessage(BuildContext context, String message) async {
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
    };
    return header;
  }

  static Map<String, String> setHeaderMultiPart() {
    Map<String, String> header = <String, String>{
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ' + Utils.token,
    };
    return header;
  }

  static String koooosong(String param) {
    if (param == "" || param == null) {
      return "0";
    }
    return param;
  }
}
