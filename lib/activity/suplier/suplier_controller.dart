import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mizanmobile/activity/utility/list_modal_form.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

class SupplierController {
  BuildContext context;
  StateSetter setState;

  SupplierController(this.context, this.setState);

  Future<List<dynamic>>? dataSuplier;

  Future<List<dynamic>> getData({String keyword = ""}) async {
    Uri url = Uri.parse("${Utils.mainUrl}suplier/daftar");
    if (keyword != null && keyword != "") {
      url = Uri.parse("${Utils.mainUrl}suplier/cari?cari=$keyword");
    }
    Response response = await get(url, headers: Utils.setHeader());
    log(url.toString());
    String body = response.body;
    log(body);
    var jsonData = jsonDecode(body)["data"];
    return jsonData;
  }

  Future<dynamic> saveData(Map<String, Object> postBody, urlPath) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}suplier/" + urlPath;
    Uri url = Uri.parse(urlString);
    Response response =
        await post(url, body: jsonEncode(postBody), headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body);
    Navigator.pop(context);
    return jsonData;
  }

  void editData(dynamic dataList) {
    if (Utils.hakAkses["MOBILE_EDITDATAMASTER"] == 0) {
      return Utils.showMessage("Akses ditolak", context);
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    showModalInputSuplier(param: dataList);
  }

  void deleteData(dynamic dataList) async {
    if (Utils.hakAkses["MOBILE_EDITDATAMASTER"] == 0) {
      return Utils.showMessage("Akses ditolak", context);
    }

    bool isConfirm = await Utils.showConfirmMessage(
        context, "Yakin ingin menghapus data ini ?");

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
        dataSuplier = getData();
      });
    }
  }

  Future<dynamic> showModalInputSuplier({dynamic param = null}) {
    TextEditingController kodeCtrl = TextEditingController();
    TextEditingController namaCtrl = TextEditingController();
    TextEditingController golonganCtrl = TextEditingController();
    TextEditingController klasifikasiCtrl = TextEditingController();
    TextEditingController deptCtrl = TextEditingController();
    TextEditingController alamatCtrl = TextEditingController();

    dynamic popUpResult;
    String idKlasifikasi = "";
    String idGolongan = "";
    String idDept = Utils.idDept;
    String namaDept = Utils.namaDept;
    String noIndex = "";
    String textMode = "Tambah Suplier";
    String alamat = "";

    deptCtrl.text = namaDept;

    if (param != null) {
      textMode = "Edit Suplier";
      noIndex = param["NOINDEX"].toString();
      kodeCtrl.text = param["KODE"].toString();
      namaCtrl.text = param["NAMA"].toString();
      klasifikasiCtrl.text = param["NAMA_KLASIFIKASI"].toString();
      deptCtrl.text = param["NAMA_DEPT"].toString();
      idKlasifikasi = param["IDKLASIFIKASI"].toString();
      idDept = param["IDDEPT"].toString();
      idGolongan = param["IDGOLONGAN"].toString();
      golonganCtrl.text = param["NAMA_GOLONGAN"].toString();
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
                  Utils.labelForm("Golongan"),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: false,
                          controller: golonganCtrl,
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: IconButton(
                          onPressed: () async {
                            popUpResult =
                                await Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ListModalForm(type: "golongansuplier");
                              },
                            ));

                            if (popUpResult == null) return;
                            golonganCtrl.text = popUpResult["NAMA"];
                            idGolongan = popUpResult["NOINDEX"];
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
                  Utils.labelForm("Alamat"),
                  TextField(
                    controller: alamatCtrl,
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            if (idGolongan.isEmpty) {
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
                                "idgolongan": idGolongan,
                                "iddept": idDept,
                                "idklasifikasi": idKlasifikasi,
                                "alamat": alamatCtrl.text,
                              };
                              result = await saveData(mapData, "edit");
                            } else {
                              mapData = {
                                "kode": kodeCtrl.text,
                                "nama": namaCtrl.text,
                                "idgolongan": idGolongan,
                                "iddept": idDept,
                                "idklasifikasi": idKlasifikasi,
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
                              dataSuplier = getData();
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
