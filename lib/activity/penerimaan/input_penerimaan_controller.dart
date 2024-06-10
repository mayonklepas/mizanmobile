import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mizanmobile/activity/utility/list_modal_barang.dart';
import 'package:mizanmobile/activity/utility/list_modal_form.dart';
import 'package:mizanmobile/database_helper.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

class InputPenerimaanController {
  BuildContext context;
  StateSetter setState;

  FocusNode searchBarFocus = FocusNode();
  TextEditingController gudangCtrl = TextEditingController();
  TextEditingController tanggalCtrl = TextEditingController();
  TextEditingController keteranganCtrl = TextEditingController();
  TextEditingController deptCtrl = TextEditingController();
  String idGudang = Utils.idGudang;
  String namaGudang = Utils.namaGudang;
  String tanggalTransaksi = Utils.currentDateString();
  String noOrder = "";
  String idOrder = "";
  String idTransaksi = "";
  String noref = "";
  String keterangan = "";
  TextEditingController suplierCtrl = TextEditingController();
  String idSuplier = "";
  String idSuplierEdit = "";
  String namaSuplier = "";
  String namaPelangganEdit = "";
  String idGolonganSuplier = Utils.idGolonganSuplier;
  String idGolongan2Suplier = Utils.idGolongan2Suplier;
  String idDept = Utils.idDept;
  String idDeptEdit = "";
  String namaDept = Utils.namaDept;
  String idUserInput = "";
  TextEditingController paymentTypeCtrl = TextEditingController();
  TextEditingController searchBarctrl = TextEditingController();

  List<dynamic> listRincianOrder = [];
  List<dynamic> dataListShow = [];

  InputPenerimaanController(this.context, this.setState, this.idTransaksi) {
    tanggalCtrl.text = tanggalTransaksi;
    keteranganCtrl.text = "Penerimaan";
  }

  Future<dynamic> getDataDetailBarang(String idBarang) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString =
        "${Utils.mainUrl}barang/rincian?idgudang=$idGudang&halaman=0&idbarang=$idBarang";
    Uri url = Uri.parse(urlString);
    Response response = await get(url, headers: Utils.setHeader());
    String body = response.body;
    log(body);
    var jsonData = jsonDecode(body)["data"];
    Navigator.pop(context);
    return jsonData;
  }

  Future<dynamic> getRincianOrder(String idRincian) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString =
        "${Utils.mainUrl}orderpembelian/rincian?noindex=$idRincian";
    Uri url = Uri.parse(urlString);
    Response response = await get(url, headers: Utils.setHeader());
    String body = response.body;
    log(body);
    var jsonData = jsonDecode(body)["data"];
    Navigator.pop(context);
    return jsonData;
  }

  Future<dynamic> savePenerimaan(Map<String, Object> postBody, urlPath) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}penjualan/$urlPath";
    Uri url = Uri.parse(urlString);
    Response response =
        await post(url, body: jsonEncode(postBody), headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body);
    Navigator.pop(context);
    return jsonData;
  }

  sendPayment() async {
    Map headerMap = {
      "IDDEPT": idDept,
      "KETERANGAN": keteranganCtrl.text,
      "USERINPUT": Utils.idUser,
      "TANGGAL": tanggalCtrl.text,
      "IDSUPLIER": idSuplier,
      "IDORDER": idOrder,
    };

    List<dynamic> detailList = [];

    for (var dataMap in dataListShow) {
      detailList.add({
        "IDBARANG": dataMap["IDBARANG"],
        "QTYORDER": dataMap["QTY"],
        "QTY": dataMap["HARGA"],
        "IDSATUAN": dataMap["IDSATUAN"],
        "IDGUDANG": idGudang,
        "IDSATUANPENGALI": dataMap["IDSATUANPENGALI"],
        "QTYSATUANPENGALI": dataMap["QTYSATUANPENGALI"]
      });
    }

    Map<String, Object> rootMap = {"header": headerMap, "detail": detailList};
    var result;
    if (idTransaksi == "") {
      result = await savePenerimaan(rootMap, "insert");
    } else {
      headerMap["NOINDEX"] = idTransaksi;
      headerMap["IDSUPLIER"] = idSuplierEdit;
      headerMap["USERINPUT"] = idUserInput;
      headerMap["USEREDIT"] = Utils.idUser;
      result = await savePenerimaan(rootMap, "edit");
    }

    if (result["status"] == 1) {
      Utils.showMessage(result["message"], context);
      return;
    }

    var dataResult = result["data"];

    List<dynamic> detailBarangPost = dataResult["detail_barang"];

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Utils.labelSetter("Transaksi berhasil",
            color: Colors.green, size: 20)));
  }

  Widget setSearchBarView() {
    if (Utils.isPdtMode == "0") {
      return Utils.appBarSearchStatic(() async {
        dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return ListModalBarang(
              isLocal: true,
            );
          },
        ));

        if (popUpResult == null) return;

        String noIndex = popUpResult["NOINDEX"];
        log(noIndex);
      }, focus: false, readOnly: true);
    }

    return Container(
        height: 35,
        child: TextField(
            cursorColor: Colors.blueAccent,
            style: TextStyle(color: Colors.black54),
            decoration: Utils.inputDecoration("Cari"),
            textInputAction: TextInputAction.search,
            autofocus: true,
            focusNode: searchBarFocus,
            controller: searchBarctrl,
            onSubmitted: (keyword) async {
              if (listRincianOrder.isEmpty) {
                Utils.showMessage("Anda belum memilih ", context);
              }
              List<dynamic> listDetailBarang = await DatabaseHelper().readDatabase(
                  "SELECT detail_barang,multi_satuan,multi_harga,harga_tanggal FROM barang_temp WHERE kode =?",
                  params: [keyword]);

              if (listDetailBarang.isEmpty) {
                bool isOpenSearch = await Utils.showConfirmMessage(
                    context, "Data tidak ditemukan, buka pencarian?");
                if (isOpenSearch) {
                  dynamic popUpResult =
                      await Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return ListModalBarang(
                        isLocal: true,
                      );
                    },
                  ));

                  if (popUpResult == null) return;

                  String noIndex = popUpResult["NOINDEX"];

                  bool isFound = false;
                  for (var d in listRincianOrder) {
                    String noindexIn = d["NOINDEX"];
                    if (noindexIn == noIndex) {
                      isFound == true;
                    }
                  }

                  if (isFound == false) {
                    Utils.showMessage(
                        "Barang yang dipilih tidak ada dalam order", context);
                  }

                  List<dynamic> listDetailBarang = await DatabaseHelper()
                      .readDatabase(
                          "SELECT detail_barang,multi_satuan,multi_harga,harga_tanggal FROM barang_temp WHERE idbarang =?",
                          params: [noIndex]);
                  setState(() {
                    searchBarctrl.clear();
                  });
                }

                searchBarFocus.requestFocus();
                return;
              }

              if (listDetailBarang.length > 1) {
                dynamic popUpResult =
                    await Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return ListModalBarang(
                      isLocal: true,
                      keyword: keyword,
                    );
                  },
                ));

                if (popUpResult == null) return;
                String noIndex = popUpResult["NOINDEX"];
                listDetailBarang = await DatabaseHelper().readDatabase(
                    "SELECT detail_barang,multi_satuan,multi_harga,harga_tanggal FROM barang_temp WHERE idbarang =?",
                    params: [noIndex]);
              }
              setState(() {
                searchBarctrl.clear();
              });
              searchBarFocus.requestFocus();
            }));
  }

  void setTextDateRange(TextEditingController tgl) async {
    DateTime? pickedDate = await Utils.getDatePicker(context);
    if (pickedDate != null) {
      setState(() {
        tgl.text = Utils.formatStdDate(pickedDate);
      });
    }
  }

  Future<List<dynamic>> setFuture(List<dynamic> data) async {
    return data;
  }

  void scanBarcode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", true, ScanMode.BARCODE);
    if (barcodeScanRes.isEmpty) {
      Utils.showMessage("Data tidak ditemukan, coba ulangi", context);
      return;
    }
    List<dynamic> listDetailBarang = await DatabaseHelper().readDatabase(
        "SELECT detail_barang,multi_satuan,multi_harga,harga_tanggal FROM barang_temp WHERE kode=?",
        params: [barcodeScanRes]);
  }

  showHeader() {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return modalHeader();
        });
  }

  showEdit(dynamic data, int index) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return modalEdit(data, index);
        });
  }

  SingleChildScrollView modalHeader() {
    deptCtrl.text = namaDept;
    tanggalCtrl.text = tanggalTransaksi;
    gudangCtrl.text = namaGudang;
    suplierCtrl.text = namaSuplier;
    keteranganCtrl.text = keterangan;
    return SingleChildScrollView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Utils.labelSetter("Input Informasi", size: 25),
            Padding(padding: EdgeInsets.all(10)),
            Text("Tanggal"),
            Row(
              children: [
                Expanded(
                    flex: 10,
                    child: TextField(
                      controller: tanggalCtrl,
                      enabled: false,
                    )),
                Expanded(
                  child: IconButton(
                    onPressed: () async {
                      setTextDateRange(tanggalCtrl);
                    },
                    icon: Icon(Icons.date_range),
                  ),
                ),
              ],
            ),
            Utils.labelForm("Departemen"),
            TextField(
              controller: deptCtrl,
              enabled: false,
            ),
            Utils.labelForm("Gudang"),
            Row(
              children: [
                Expanded(
                    flex: 10,
                    child: TextField(
                      controller: gudangCtrl,
                      enabled: false,
                    )),
                Expanded(
                  child: IconButton(
                    onPressed: () async {
                      dynamic popUpResult =
                          await Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return ListModalForm(
                            type: "gudang",
                          );
                        },
                      ));

                      if (popUpResult == null) return;

                      gudangCtrl.text = popUpResult["NAMA"];
                      idGudang = popUpResult["NOINDEX"];
                      namaGudang = popUpResult["NAMA"];
                    },
                    icon: Icon(Icons.search),
                  ),
                ),
              ],
            ),
            Utils.labelForm("Keterangan"),
            TextField(
              controller: keteranganCtrl,
            ),
            Padding(padding: EdgeInsets.all(5)),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView modalEdit(dynamic data, int index) {
    TextEditingController jumlahCtrl = TextEditingController();
    TextEditingController diskonCtrl = TextEditingController();
    TextEditingController satuanCtrl = TextEditingController();
    satuanCtrl.text = data["SATUAN"];
    String idSatuan = data["IDSATUAN"];
    jumlahCtrl.text = Utils.formatNumber(data["QTY"]);
    diskonCtrl.text = Utils.formatNumber(data["DISKON_NOMINAL"]);
    return SingleChildScrollView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Utils.labelSetter("Edit Jumlah", size: 25),
            Padding(padding: EdgeInsets.all(10)),
            Utils.labelForm("Jumlah"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  flex: 5,
                  child: TextField(
                    controller: jumlahCtrl,
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () {
                        String jumlahText = jumlahCtrl.text;
                        if (jumlahText == "") {
                          jumlahCtrl.text = "1";
                        } else {
                          int jumlah =
                              int.parse(Utils.removeDotSeparator(jumlahText));
                          jumlah = jumlah + 1;
                          jumlahCtrl.text = jumlah.toString();
                        }
                      },
                      child: Icon(Icons.add),
                    )),
                SizedBox(width: 10),
                Flexible(
                    flex: 1,
                    child: OutlinedButton(
                        onPressed: () {
                          String jumlahText = jumlahCtrl.text;
                          if (jumlahText == "") {
                            jumlahCtrl.text = "1";
                          } else {
                            int jumlah =
                                int.parse(Utils.removeDotSeparator(jumlahText));
                            if (jumlah > 1) {
                              jumlah = jumlah - 1;
                            }
                            jumlahCtrl.text = jumlah.toString();
                          }
                        },
                        child: Icon(Icons.remove)))
              ],
            ),
            Utils.labelForm("Satuan"),
            Row(
              children: [
                Expanded(
                    flex: 10,
                    child: TextField(
                      controller: satuanCtrl,
                      enabled: false,
                    )),
                Expanded(
                  child: IconButton(
                    onPressed: () async {
                      dynamic popUpResult =
                          await Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return ListModalForm(
                            type: "satuanbarang",
                            idBarang: data["IDBARANG"],
                          );
                        },
                      ));

                      if (popUpResult == null) return;
                      satuanCtrl.text = popUpResult["NAMA"];
                      idSatuan = popUpResult["NOINDEX"];
                    },
                    icon: Icon(Icons.search),
                  ),
                ),
              ],
            ),
            Utils.labelForm("Diskon"),
            TextField(
              controller: diskonCtrl,
            ),
            Padding(padding: EdgeInsets.all(5)),
            Row(
              children: [
                Expanded(
                    flex: 3,
                    child: ElevatedButton(
                        onPressed: () {
                        },
                        child: Text("Simpan"))),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    flex: 1,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        onPressed: () async {
                          bool isDelete = await Utils.showConfirmMessage(
                              context, "Yakin ingin menghapus data ini ?");
                          if (isDelete) {
                            Navigator.pop(context);
                            setState(() {
                              dataListShow.removeAt(index);
                            });
                          }
                        },
                        child: Text("Hapus")))
              ],
            )
          ],
        ),
      ),
    );
  }

  void getSuplier() async {
    dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return ListModalForm(
          type: "suplier",
        );
      },
    ));

    if (popUpResult == null) return;
    log(popUpResult.toString());

    setState(() {
      suplierCtrl.text = popUpResult["NAMA"];
      idSuplier = popUpResult["NOINDEX"];
      namaSuplier = popUpResult["NAMA"];
      idGolonganSuplier = popUpResult["IDGOLONGAN"];
    });
  }

  void getOrder() async {
    dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return ListModalForm(
          type: "orderpembelian",
          idSuplier: idSuplier,
        );
      },
    ));

    if (popUpResult == null) return;

    setState(() {
      noOrder = popUpResult["KODE"];
    });
    idOrder = popUpResult["NOINDEX"];

    Map<String, dynamic> getRincianResult = await getRincianOrder(idOrder);
    listRincianOrder = getRincianResult["detail"];
    log(listRincianOrder.toString());
  }
}
