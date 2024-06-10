import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mizanmobile/activity/penerimaan/input_penerimaan_view.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

import '../component/bottom_modal_filter.dart';

class listPenerimaanController {
  BuildContext context;
  StateSetter setState;

  listPenerimaanController(this.context, this.setState);

  Future<List<dynamic>>? dataPenerimaan;
  TextEditingController tanggalDariCtrl = TextEditingController();
  TextEditingController tanggalHinggaCtrl = TextEditingController();

  Future<List<dynamic>> getDataPenerimaan(
      {String keyword = "", String tglDari = "", String tglHingga = "", String idDept = ""}) async {
    if (tglDari == "") {
      tglDari = Utils.formatStdDate(DateTime.now());
    }

    if (tglHingga == "") {
      tglHingga = Utils.formatStdDate(DateTime.now());
    }

    if (idDept == "") {
      idDept = Utils.idDept;
    }

    Uri url = Uri.parse(
        "${Utils.mainUrl}penerimaanbarang/daftar?iddept=$idDept&tgldari=$tglDari&tglhingga=$tglHingga");
    if (keyword != null && keyword != "") {
      url = Uri.parse(
          "${Utils.mainUrl}penerimaanbarang/cari?iddept=$idDept&tgldari=2023-01-01&tglhingga=2023-01-31&cari=$keyword");
    }
    Response response = await get(url, headers: Utils.setHeader());
    if (response.statusCode != 200) {
      Utils.showMessage("error request ${response.statusCode}", context);
      return [];
    }
    log(url.toString());
    String body = response.body;
    log(body);
    var jsonData = jsonDecode(body)["data"];
    return jsonData;
  }

  showInput() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return InputPenerimaanView();
      },
    ));
  }

  dateBottomModal(BuildContext context) async {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return BottomModalFilter(
              tanggalDariCtrl: tanggalDariCtrl,
              tanggalHinggaCtrl: tanggalHinggaCtrl,
              action: () {
                Navigator.pop(context);
                Future.delayed(Duration(seconds: 2));
                setState(() {
                  dataPenerimaan = getDataPenerimaan(
                      tglDari: tanggalDariCtrl.text, tglHingga: tanggalHinggaCtrl.text);
                });
              });
        });
  }
}
