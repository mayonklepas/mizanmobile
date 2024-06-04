import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:mizanmobile/activity/utility/list_modal_form.dart';

import 'package:mizanmobile/utils.dart';

class PelangganController {
  BuildContext context;
  StateSetter setState;

  PelangganController(this.context, this.setState);

  Future<List<dynamic>>? dataPelanggan;

  Future<List<dynamic>> getData({String keyword = ""}) async {
    Uri url = Uri.parse("${Utils.mainUrl}pelanggan/daftar");
    if (keyword != "") {
      url = Uri.parse("${Utils.mainUrl}pelanggan/cari?cari=$keyword");
    }
    Response response = await get(url, headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body)["data"];
    log(jsonData.toString());
    return jsonData;
  }

  Future<dynamic> saveData(Map<String, Object> postBody, urlPath) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}pelanggan/" + urlPath;
    Uri url = Uri.parse(urlString);
    Response response =
        await post(url, body: jsonEncode(postBody), headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body);
    Navigator.pop(context);
    return jsonData;
  }

  void deleteData(dynamic dataList) async {
    if (Utils.hakAkses["MOBILE_EDITDATAMASTER"] == 0) {
      return Utils.showMessage("Akses ditolak", context);
    }

    bool isConfirm = await Utils.showConfirmMessage(
        context, "Yakin ingin menghapus daa ini ?");

    if (isConfirm) {
      Map<String, Object> mapData = {"noindex": dataList["NOINDEX"].toString()};
      dynamic result = await saveData(mapData, "delete");
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (result["status"] == 1) {
        Utils.showMessage(result["message"], context);
        return;
      }
      setState(() {
        dataPelanggan = getData();
      });
    }
  }

  void editData(dynamic dataList) async {
    if (Utils.hakAkses["MOBILE_EDITDATAMASTER"] == 0) {
      return Utils.showMessage("Akses ditolak", context);
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    showModalInputPelanggan(param: dataList);
  }

  Future<dynamic> showModalInputPelanggan({dynamic param = null}) {
    TextEditingController kodeCtrl = TextEditingController();
    TextEditingController namaCtrl = TextEditingController();
    TextEditingController golongan1Ctrl = TextEditingController();
    TextEditingController golongan2Ctrl = TextEditingController();
    TextEditingController klasifikasiCtrl = TextEditingController();
    TextEditingController deptCtrl = TextEditingController();
    TextEditingController longitudeCtrl = TextEditingController();
    TextEditingController latitudeCtrl = TextEditingController();
    TextEditingController alamatCtrl = TextEditingController();

    dynamic popUpResult;
    String idGolongan1 = "";
    String idGolongan2 = "";
    String idKlasifikasi = "";
    String idDept = Utils.idDept;
    String namaDept = Utils.namaDept;
    String noIndex = "";
    String textMode = "Tambah Pelanggan";
    String alamat = "";

    deptCtrl.text = namaDept;

    if (param != null) {
      textMode = "Edit Pelanggan";
      noIndex = param["NOINDEX"].toString();
      kodeCtrl.text = param["KODE"].toString();
      namaCtrl.text = param["NAMA"].toString();
      golongan1Ctrl.text = param["NAMA_GOLONGAN"].toString();
      golongan2Ctrl.text = param["NAMA_GOLONGAN2"].toString();
      klasifikasiCtrl.text = param["NAMA_KLASIFIKASI"].toString();
      deptCtrl.text = param["NAMA_DEPT"].toString();

      idGolongan1 = param["IDGOLONGAN"].toString();
      idGolongan2 = param["IDGOLONGAN2"].toString();
      idKlasifikasi = param["IDKLASIFIKASI"].toString();
      idDept = param["IDDEPT"].toString();
    }
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding:
                  EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Utils.labelSetter(textMode, size: 25),
                  Padding(padding: EdgeInsets.all(10)),
                  Text("Kode (Kosongkan untuk auto generate)"),
                  TextField(
                    controller: kodeCtrl,
                  ),
                  Utils.labelForm("Nama"),
                  TextField(
                    controller: namaCtrl,
                  ),
                  Utils.labelForm("Golongan 1"),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: false,
                          controller: golongan1Ctrl,
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: IconButton(
                          onPressed: () async {
                            popUpResult =
                                await Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ListModalForm(type: "golonganpelanggan");
                              },
                            ));

                            if (popUpResult == null) return;
                            golongan1Ctrl.text = popUpResult["NAMA"];
                            idGolongan1 = popUpResult["NOINDEX"];
                          },
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  Utils.labelForm("Golongan 2"),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: false,
                          controller: golongan2Ctrl,
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: IconButton(
                          onPressed: () async {
                            popUpResult =
                                await Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ListModalForm(type: "golonganpelanggan");
                              },
                            ));

                            if (popUpResult == null) return;
                            golongan2Ctrl.text = popUpResult["NAMA"];
                            idGolongan2 = popUpResult["NOINDEX"];
                          },
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  Utils.labelForm("Klasifikasi"),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: false,
                          controller: klasifikasiCtrl,
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: IconButton(
                          onPressed: () async {
                            popUpResult =
                                await Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ListModalForm(type: "klasifikasi");
                              },
                            ));

                            if (popUpResult == null) return;
                            klasifikasiCtrl.text = popUpResult["NAMA"];
                            idKlasifikasi = popUpResult["NOINDEX"];
                          },
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  Utils.labelForm("Departement"),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: false,
                          controller: deptCtrl,
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: IconButton(
                          onPressed: () async {
                            popUpResult =
                                await Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ListModalForm(type: "dept");
                              },
                            ));

                            if (popUpResult == null) return;
                            deptCtrl.text = popUpResult["NAMA"];
                            idDept = popUpResult["NOINDEX"].toString();
                          },
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  Utils.labelForm("Longitude"),
                  TextField(
                    controller: longitudeCtrl,
                  ),
                  Utils.labelForm("Latitude"),
                  TextField(
                    controller: latitudeCtrl,
                  ),
                  Utils.labelForm("Alamat"),
                  TextField(
                    controller: alamatCtrl,
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            Position geoPosition =
                                await Geolocator.getCurrentPosition(
                                    desiredAccuracy: LocationAccuracy.medium);

                            double longitude = geoPosition.longitude;
                            double latitude = geoPosition.latitude;

                            log(longitude.toString());

                            longitudeCtrl.text = longitude.toString();
                            latitudeCtrl.text = latitude.toString();
                          },
                          child: Text("Ambil Koordinat"))),
                  Padding(padding: EdgeInsets.all(5)),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            if (idGolongan1.isEmpty) {
                              Utils.showMessage(
                                  "Golongan 1 tidak boleh kosong", context);
                              return;
                            }

                            Map<String, Object> mapData = {};
                            dynamic result;
                            if (param != null) {
                              mapData = {
                                "noindex": noIndex,
                                "kode": kodeCtrl.text,
                                "nama": namaCtrl.text,
                                "iddept": idDept,
                                "idgolongan": idGolongan1,
                                "idgolongan2": idGolongan2,
                                "idklasifikasi": idKlasifikasi,
                                "longitude": longitudeCtrl.text,
                                "latitude": latitudeCtrl.text,
                                "alamat": alamatCtrl.text,
                              };
                              result = await saveData(mapData, "edit");
                            } else {
                              mapData = {
                                "kode": kodeCtrl.text,
                                "nama": namaCtrl.text,
                                "iddept": idDept,
                                "idgolongan": idGolongan1,
                                "idgolongan2": idGolongan2,
                                "idklasifikasi": idKlasifikasi,
                                "longitude": longitudeCtrl.text,
                                "latitude": latitudeCtrl.text,
                                "alamat": alamatCtrl.text,
                              };
                              result = await saveData(mapData, "insert");
                            }
                            Navigator.pop(context);

                            if (result["status"] == 1) {
                              Utils.showMessage(result["message"], context);
                              return;
                            }
                            setState(() {
                              dataPelanggan = getData();
                            });
                          },
                          child: Text("Simpan")))
                ],
              ),
            ),
          );
        });
  }
}
