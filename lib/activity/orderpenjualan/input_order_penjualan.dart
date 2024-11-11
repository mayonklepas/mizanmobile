import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mizanmobile/activity/pelanggan/pelanggan_view.dart';
import 'package:mizanmobile/activity/utility/list_modal_barang.dart';
import 'package:mizanmobile/activity/utility/printer_util.dart';
import 'package:mizanmobile/helper/database_helper.dart';
import 'package:mizanmobile/helper/utils.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

import '../utility/list_modal_form.dart';

class InputOrderPenjualan extends StatefulWidget {
  final String idTransaksi;

  const InputOrderPenjualan({Key? key, this.idTransaksi = ""}) : super(key: key);

  @override
  State<InputOrderPenjualan> createState() => _InputOrderPenjualanState();
}

class _InputOrderPenjualanState extends State<InputOrderPenjualan> {
  TextEditingController gudangCtrl = TextEditingController();
  TextEditingController tanggalCtrl = TextEditingController();
  TextEditingController keteranganCtrl = TextEditingController();
  TextEditingController deptCtrl = TextEditingController();
  String idGudang = Utils.idGudang;
  String namaGudang = Utils.namaGudang;
  String tanggalTransaksi = Utils.currentDateString();
  String idTransaksi = "";
  String noref = "";
  String keterangan = "Penjualan mobile";
  TextEditingController pelangganCtrl = TextEditingController();
  String idPelanggan = Utils.idPelanggan;
  String kodePelanggan = Utils.kodePelanggan;
  String namaPelanggan = Utils.namaPelanggan;
  String idGolonganPelanggan = Utils.idGolonganPelanggan;
  String idGolongan2Pelanggan = Utils.idGolongan2Pelanggan;
  String idDept = Utils.idDept;
  String idDeptEdit = "";
  String namaDept = Utils.namaDept;
  double totalPenjualan = 0;
  double jumlahBayarEdit = 0;
  String idUserInput = "";
  String namaUserInput = "";
  TextEditingController searchBarctrl = TextEditingController();

  List<dynamic> dataList = [];
  List<dynamic> dataListShow = [];
  List<dynamic> dataPaymentMethod = [];
  double totalBiaya = 0;

  bool disableSimpanButton = false;

  FocusNode searchBarFocus = FocusNode();

  List<DropdownMenuEntry<dynamic>> itemList = [];

  String gambarUrlString = "${Utils.mainUrl}barang/download/";

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

  Future<dynamic> postOrderPenjualan(Map<String, Object> postBody, urlPath) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}orderpenjualan/$urlPath";
    Uri url = Uri.parse(urlString);
    Response response = await post(url, body: jsonEncode(postBody), headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body);
    Navigator.pop(context);
    return jsonData;
  }

  Future getDetailOrderPenjualanDetail() async {
    //Future.delayed(Duration.zero, () => Utils.showProgress(context));
    dynamic headerData = {};
    dynamic jsonData = {};
    if (Utils.isOffline) {
      DatabaseHelper db = DatabaseHelper();
      List<dynamic> resultList = await db.readDatabase(
          "SELECT * FROM data_penjualan_temp WHERE id = ?",
          params: [widget.idTransaksi]);
      if (resultList.isEmpty) {
        return;
      }
      dynamic resulMap = resultList[0];
      jsonData = jsonDecode(resulMap["data"]);
      headerData = jsonData["header"];
      headerData["KODEPELANGGAN"] = "";
      headerData["NAMAPELANGGAN"] = resulMap["nama_pelanggan"];
      headerData["NOREF"] = "";
      headerData["NOINDEX"] = widget.idTransaksi;
    } else {
      String urlString = "${Utils.mainUrl}orderpenjualan/rincian?noindex=${widget.idTransaksi}";
      Uri url = Uri.parse(urlString);
      Response response = await get(url, headers: Utils.setHeader());
      String body = response.body;
      jsonData = jsonDecode(body)["data"];
      headerData = jsonData["header"][0];
    }

    setState(() {
      idPelanggan = headerData["IDPELANGGAN"];
      kodePelanggan = headerData["KODEPELANGGAN"];
      namaPelanggan = headerData["NAMAPELANGGAN"];
      jumlahBayarEdit = headerData["JUMLAHBAYAR"] ?? 0.0;
      idUserInput = headerData["USERINPUT"];
      idTransaksi = headerData["NOINDEX"];
      noref = headerData["NOREF"];
      keterangan = headerData["KETERANGAN"];
      tanggalTransaksi = headerData["TANGGAL"];
    });

    List<dynamic> detailBarang = jsonData["detail"];

    for (var d in detailBarang) {
      String idBarang = d["IDBARANG"].toString();
      List<dynamic> listDetailBarang = await DatabaseHelper().readDatabase(
          "SELECT detail_barang,multi_satuan,multi_harga,harga_tanggal FROM barang_temp WHERE idbarang =? ",
          params: [idBarang]);

      dynamic detailBarang = listDetailBarang[0];
      dynamic resultDataDetail = {
        "detail_barang": jsonDecode(detailBarang["detail_barang"]),
        "multi_satuan": jsonDecode(detailBarang["multi_satuan"]),
        "multi_harga": jsonDecode(detailBarang["multi_harga"]),
        "harga_tanggal": jsonDecode(detailBarang["harga_tanggal"]),
      };

      dynamic detailInfoBarang = jsonDecode(detailBarang["detail_barang"]);

      setState(() {
        dataList.add(resultDataDetail);
        dataListShow.add({
          "IDBARANG": d["IDBARANG"].toString(),
          "KODE": detailInfoBarang["KODE"],
          "NAMA": detailInfoBarang["NAMA"],
          "IDSATUAN": d["IDSATUAN"],
          "SATUAN": detailInfoBarang["KODE_SATUAN"],
          "QTY": d["QTY"],
          "HARGA": d["HARGA"],
          "DISKONNOMINAL": d["DISKONNOMINAL"],
          "IDGUDANG": idGudang,
          "IDSATUANPENGALI": d["IDSATUANPENGALI"],
          "QTYSATUANPENGALI": d["QTYSATUANPENGALI"],
          "KETERANGAN": d["KETERANGAN"]
        });

        totalPenjualan = setTotalJual();
      });
    }

    //Navigator.pop(context);
  }

  selectBarang() async {
    dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return ListModalBarang(
          isLocal: true,
        );
      },
    ));

    if (popUpResult == null) return;

    String noIndex = popUpResult["NOINDEX"];

    List<dynamic> listDetailBarang = await DatabaseHelper().readDatabase(
        "SELECT detail_barang,multi_satuan,multi_harga,harga_tanggal FROM barang_temp WHERE idbarang =?",
        params: [noIndex]);

    if (listDetailBarang.isEmpty) {
      dynamic result = await getDataDetailBarang(noIndex);
      result["detail_barang"] = jsonEncode(result["detail_barang"][0]);
      result["multi_harga"] = jsonEncode(result["multi_harga"]);
      result["multi_satuan"] = jsonEncode(result["multi_satuan"]);
      result["harga_tanggal"] = jsonEncode(result["harga_tanggal"]);

      listDetailBarang = [result];
    }

    listValueSetter(listDetailBarang);
  }

  listValueSetter(List<dynamic> listDetailBarang) {
    dynamic detailBarang = listDetailBarang[0];
    dynamic resultDataDetail = {
      "detail_barang": jsonDecode(detailBarang["detail_barang"]),
      "multi_satuan": jsonDecode(detailBarang["multi_satuan"]),
      "multi_harga": jsonDecode(detailBarang["multi_harga"]),
      "harga_tanggal": jsonDecode(detailBarang["harga_tanggal"]),
    };

    var data = resultDataDetail;
    var db = data["detail_barang"];
    db = data["detail_barang"];
    if (!isBarangExists(db["NOINDEX"].toString())) {
      dynamic hargaUpdate = getHargaJual(data, db["IDSATUAN"], 1);
      setState(() {
        dataListShow.add({
          "IDBARANG": db["NOINDEX"].toString(),
          "KODE": db["KODE"],
          "NAMA": db["NAMA"],
          "IDSATUAN": db["IDSATUAN"],
          "SATUAN": db["KODE_SATUAN"],
          "QTY": 1.0,
          "HARGA": hargaUpdate["HARGA"],
          "DISKONNOMINAL": 0.0,
          "IDGUDANG": idGudang,
          "IDSATUANPENGALI": hargaUpdate["IDSATUANPENGALI"],
          "QTYSATUANPENGALI": hargaUpdate["QTYSATUANPENGALI"],
          "KETERANGAN": ""
        });
        dataList.add(data);
        totalPenjualan = setTotalJual();
      });
    } else {
      int index = getIndexBarang(db["NOINDEX"].toString());
      double qty = dataListShow[index]["QTY"] + 1;
      String idSatuan = db["IDSATUAN"];
      dynamic hargaUpdate = getHargaJual(data, idSatuan, qty);

      setState(() {
        dataListShow[index]["IDSATUANPENGALI"] = hargaUpdate["IDSATUANPENGALI"];
        dataListShow[index]["QTY"] = qty;
        dataListShow[index]["QTYSATUANPENGALI"] = hargaUpdate["QTYSATUANPENGALI"];
        dataListShow[index]["HARGA"] = hargaUpdate["HARGA"];
        totalPenjualan = setTotalJual();
      });
    }
  }

  dynamic getHargaJual(dynamic data, idSatuan, double qty) {
    List<dynamic> hargaTanggal = data["harga_tanggal"];
    List<dynamic> multiHarga = data["multi_harga"];
    List<dynamic> multiSatuan = data["multi_satuan"];
    dynamic detailBarang = data["detail_barang"];

    dynamic tempResult;
    dynamic result;

    if (hargaTanggal.isNotEmpty) {
      result = null;
    }

    if (result == null) {
      if (multiHarga.isNotEmpty) {
        for (var d in multiHarga) {
          double qtyDari = d["DARI"];
          double qtyHingga = d["HINGGA"];
          if (d["IDSATUAN"] == idSatuan && d["IDGOLONGAN"] == idGolonganPelanggan) {
            if (qty >= qtyDari && qty <= qtyHingga) {
              tempResult = d;
            }
          }
        }

        if (tempResult == null) {
          for (var d in multiHarga) {
            double qtyDari = d["DARI"];
            double qtyHingga = d["HINGGA"];
            if (d["IDSATUAN"] == idSatuan && d["IDGOLONGAN"] == idGolongan2Pelanggan) {
              if (qty >= qtyDari && qty <= qtyHingga) {
                tempResult = d;
              }
            }
          }
        }

        if (tempResult != null) {
          String idSatuanPengali = tempResult["IDSATUANPENGALI"] ?? idSatuan;
          double qtySatuanPengali = tempResult["QTYSATUANPENGALI"];
          double hargaJual = tempResult["HARGA_JUAL"];

          if (multiSatuan.isNotEmpty) {
            for (var mh in multiSatuan) {
              String idSatuanMh = mh["IDSATUAN"].toString();
              String idSatuanPengaliMh = mh["IDSATUANPENGALI"];
              double qtySatuanPengaliMh = mh["QTYSATUANPENGALI"];
              if (idSatuanMh == idSatuan) {
                idSatuanPengali = idSatuanPengaliMh;
                qtySatuanPengali = qtySatuanPengaliMh;
              }
            }
          }
          result = {
            "HARGA": hargaJual,
            "IDSATUANPENGALI": idSatuanPengali,
            "QTYSATUANPENGALI": qtySatuanPengali,
          };
        } else {
          result = null;
        }
      }
    }

    result ??= {
      "HARGA": detailBarang["HARGA_JUAL"],
      "IDSATUANPENGALI": detailBarang["IDSATUAN"],
      "QTYSATUANPENGALI": 1.0,
    };

    return result;
  }

  double setTotalJual() {
    double result = 0;
    for (var d in dataListShow) {
      log(d.toString());
      double harga = d["HARGA"];
      double qty = d["QTY"];
      double diskon = d["DISKONNOMINAL"];
      double total = (harga * qty) - (diskon * qty);
      result = result + total;
    }
    return result;
  }

  bool isBarangExists(String idBarang) {
    bool result = false;
    for (var d in dataListShow) {
      if (d["IDBARANG"] == idBarang) {
        result = true;
        break;
      }
    }
    return result;
  }

  int getIndexBarang(String idBarang) {
    int result = 0;
    for (var i = 0; i < dataListShow.length; i++) {
      if (dataListShow[i]["IDBARANG"] == idBarang) {
        result = i;
        break;
      }
    }
    return result;
  }

  Expanded cetakUlangButton() {
    if (widget.idTransaksi == "") {
      return Expanded(
        child: Padding(padding: EdgeInsets.all(0)),
      );
    }
    return Expanded(
      flex: 0,
      child: Container(
        width: double.maxFinite,
        child: ElevatedButton(
          onPressed: () async {
            List<dynamic> dataListPrint = dataListShow;
            dynamic additionalInfo = {
              "tanggal": tanggalCtrl.text,
              "kodePelanggan": kodePelanggan,
              "namaPelanggan": namaPelanggan,
              "jumlahUang": jumlahBayarEdit
            };

            Map<String, String> printResult =
                await PrinterUtils().printReceipt(dataListPrint, additionalInfo);
            if (printResult["status"] == "error") {
              log(printResult["message"].toString());
              //Utils.showMessage(printResult["message"]!, context);
            }
          },
          child: Text("CETAK ULANG STRUK"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
              topRight: Radius.circular(0.0),
              topLeft: Radius.circular(0.0),
            )),
          ),
        ),
      ),
    );
  }

  recalculateListOrderPenjualan() {
    for (var i = 0; i < dataList.length; i++) {
      dynamic d = dataList[i];
      dynamic dShow = dataListShow[i];
      double qty = dShow["QTY"];
      dynamic hargaUpdate = getHargaJual(d, dShow["IDSATUAN"], qty);
      dataListShow[i]["HARGA"] = hargaUpdate["HARGA"];
      dataListShow[i]["IDSATUANPENGALI"] = hargaUpdate["IDSATUANPENGALI"];
      dataListShow[i]["QTYSATUANPENGALI"] = hargaUpdate["QTYSATUANPENGALI"];
    }
    totalPenjualan = setTotalJual();
  }

  sendPayment() async {
    Map headerMap = {
      "IDDEPT": idDept,
      "KETERANGAN": keteranganCtrl.text,
      "USERINPUT": Utils.idUser,
      "TANGGAL": tanggalCtrl.text,
      "IDPELANGGAN": idPelanggan,
      "DISKONNOMINAL": 0,
      "TOTALBIAYA": totalBiaya
    };

    List<dynamic> detailList = [];

    for (var dataMap in dataListShow) {
      detailList.add({
        "IDBARANG": dataMap["IDBARANG"],
        "QTYORDER": dataMap["QTYORDER"],
        "HARGA": dataMap["HARGA"],
        "IDSATUAN": dataMap["IDSATUAN"],
        "DISKONNOMINAL": dataMap["DISKONNOMINAL"],
        "IDGUDANG": idGudang,
        "IDSATUANPENGALI": dataMap["IDSATUANPENGALI"],
        "QTYSATUANPENGALI": dataMap["QTYSATUANPENGALI"],
        "KETERANGAN": dataMap["KETERANGAN"] ?? ""
      });
    }

    Map<String, Object> rootMap = {
      "header": headerMap,
      "detail": detailList,
    };

    var result;
    if (widget.idTransaksi == "") {
      result = await postOrderPenjualan(rootMap, "insert");
    } else {
      headerMap["NOINDEX"] = widget.idTransaksi;
      headerMap["IDPELANGGAN"] = idPelanggan;
      headerMap["NOREF"] = noref;
      headerMap["USERINPUT"] = idUserInput;
      headerMap["USEREDIT"] = Utils.idUser;
      result = await postOrderPenjualan(rootMap, "edit");
    }

    if (result["status"] == 1) {
      Utils.showMessage(result["message"], context);
      return;
    }

    var dataResult = result["data"];

    List<dynamic> detailBarangPost = dataResult["detail_barang"];

    DatabaseHelper dbh = DatabaseHelper();
    for (var d in detailBarangPost) {
      String idBarang = d["IDBARANG"];
      double stoktambahan = d["STOK"];

      List<dynamic> lsLocalUpdate = await dbh.readDatabase(
          "SELECT detail_barang FROM barang_temp WHERE idbarang =? ",
          params: [idBarang]);

      dynamic detailBarang = jsonDecode(lsLocalUpdate[0]["detail_barang"]);
      detailBarang["STOK"] = stoktambahan;
      String detailBarangStr = jsonEncode(detailBarang);

      await dbh.writeDatabase("UPDATE barang_temp SET detail_barang=? WHERE idbarang=?",
          params: [detailBarangStr, idBarang]);

      List<dynamic> lsLocalUpdateEnd = await dbh.readDatabase(
          "SELECT detail_barang FROM barang_temp WHERE idbarang =? ",
          params: [idBarang]);

      //log(lsLocalUpdateEnd[0]["detail_barang"]);
    }
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Utils.labelSetter("Transaksi berhasil", color: Colors.green, size: 20)));
    List<dynamic> dataListPrint = dataListShow;
    dynamic additionalInfo = {
      "tanggal": dataResult["TANGGAL"],
      "kodePelanggan": kodePelanggan,
      "namaPelanggan": namaPelanggan,
      "kasir": Utils.namaUser,
      "noref": dataResult["NOREF"].toString(),
    };

    Map<String, String> printResult =
        await PrinterUtils().printReceipt(dataListPrint, additionalInfo);
    if (printResult["status"] == "error") {
      log(printResult["message"].toString());
    }

    if (widget.idTransaksi != "") {
      Navigator.pop(context);
      Navigator.pop(context);
      return;
    }

    if (Utils.isShowDialogAfterSavePenjualan == "0") {
      setState(() {
        dataList.clear();
        dataListShow.clear();
        totalPenjualan = setTotalJual();
        keterangan = "Penjualan mobile";
        keteranganCtrl.text = keterangan;
        idPelanggan = Utils.idPelanggan;
        kodePelanggan = Utils.kodePelanggan;
        namaPelanggan = Utils.namaPelanggan;
        totalBiaya = 0;
      });
      return;
    }

    setState(() {
      disableSimpanButton = true;
    });
    Utils.showMessageAction(
        "Data telah tersimpan, anda bisa memilih print untuk mencetak ulang struk atau membuat transaksi baru",
        context, [
      ElevatedButton(
          onPressed: () async {
            Map<String, String> printResult =
                await PrinterUtils().printReceipt(dataListPrint, additionalInfo);
            if (printResult["status"] == "error") {
              log(printResult["message"].toString());
            }
          },
          child: Text("Cetak Struk")),
      ElevatedButton(
          onPressed: () {
            setState(() {
              dataList.clear();
              dataListShow.clear();
              totalPenjualan = setTotalJual();
              keterangan = "Penjualan mobile";
              keteranganCtrl.text = keterangan;
              idPelanggan = Utils.idPelanggan;
              kodePelanggan = Utils.kodePelanggan;
              namaPelanggan = Utils.namaPelanggan;
              totalBiaya = 0;
            });
            Navigator.pop(context);
          },
          child: Text("Transaksi Baru"))
    ]);
  }

// MODAL

  Future<dynamic> modalEdit(dynamic data, int index) {
    TextEditingController jumlahCtrl = TextEditingController();
    TextEditingController diskonCtrl = TextEditingController();
    TextEditingController satuanCtrl = TextEditingController();
    TextEditingController keteranganCtrl = TextEditingController();
    satuanCtrl.text = data["SATUAN"];
    String idSatuan = data["IDSATUAN"];
    jumlahCtrl.text = Utils.formatNumber(data["QTY"]);
    diskonCtrl.text = Utils.formatNumber(data["DISKONNOMINAL"]);
    keteranganCtrl.text = data["KETERANGAN"] ?? "";
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                                int jumlah = int.parse(Utils.decimalisasi(jumlahText));
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
                                  int jumlah = int.parse(Utils.decimalisasi(jumlahText));
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
                            dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
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
                    keyboardType: TextInputType.number,
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  Utils.labelForm("Keterangan"),
                  TextField(
                    controller: keteranganCtrl,
                    keyboardType: TextInputType.text,
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: ElevatedButton(
                              onPressed: () {
                                double qty = double.parse(Utils.decimalisasi(jumlahCtrl.text));
                                dynamic hargaUpdate = getHargaJual(dataList[index], idSatuan, qty);
                                setState(() {
                                  dataListShow[index]["IDSATUANPENGALI"] =
                                      hargaUpdate["IDSATUANPENGALI"];
                                  dataListShow[index]["QTY"] = qty;
                                  dataListShow[index]["QTYSATUANPENGALI"] =
                                      hargaUpdate["QTYSATUANPENGALI"];
                                  dataListShow[index]["HARGA"] = hargaUpdate["HARGA"];
                                  dataListShow[index]["IDSATUAN"] = idSatuan;
                                  dataListShow[index]["SATUAN"] = satuanCtrl.text;
                                  dataListShow[index]["DISKONNOMINAL"] =
                                      double.parse(Utils.decimalisasi(diskonCtrl.text));
                                  dataListShow[index]["KETERANGAN"] = keteranganCtrl.text;
                                  totalPenjualan = setTotalJual();
                                  Navigator.pop(context);
                                });
                              },
                              child: Text("Simpan"))),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          flex: 1,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                              onPressed: () async {
                                bool isDelete = await Utils.showConfirmMessage(
                                    context, "Yakin ingin menghapus data ini ?");
                                if (isDelete) {
                                  Navigator.pop(context);
                                  setState(() {
                                    dataList.removeAt(index);
                                    dataListShow.removeAt(index);
                                    recalculateListOrderPenjualan();
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
        });
  }

  Future<dynamic> modalHeader() {
    deptCtrl.text = namaDept;
    tanggalCtrl.text = tanggalTransaksi;
    gudangCtrl.text = namaGudang;
    pelangganCtrl.text = namaPelanggan;
    keteranganCtrl.text = keterangan;

    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                          onPressed: () => Utils.setTextDateRange(context, tanggalCtrl, setState),
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
                            dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
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
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          tanggalTransaksi = tanggalCtrl.text;
                          keterangan = keteranganCtrl.text;
                          Navigator.pop(context);
                        },
                        child: Text("Oke")),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    keteranganCtrl.text = keterangan;
    tanggalCtrl.text = tanggalTransaksi;
    if (widget.idTransaksi != "") {
      getDetailOrderPenjualanDetail();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Utils.widgetSetter(() {
            if (Utils.isPdtMode == "0") {
              return Utils.appBarSearchStatic(() => selectBarang(), focus: false, readOnly: true);
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
                      List<dynamic> listDetailBarang = [];
                      List<dynamic> listDbBarang = await DatabaseHelper().readDatabase(
                          "SELECT detail_barang,multi_satuan,multi_harga,harga_tanggal FROM barang_temp WHERE kode =?",
                          params: [keyword]);
                      listDetailBarang.addAll(listDbBarang);

                      if (listDetailBarang.isEmpty) {
                        List<dynamic> listDetailBarangFilterLike = await DatabaseHelper().readDatabase(
                            "SELECT detail_barang,multi_satuan,multi_harga,harga_tanggal FROM barang_temp WHERE multi_satuan LIKE ?",
                            params: ['%$keyword%']);

                        for (var d in listDetailBarangFilterLike) {
                          String multisatuanString = d["multi_satuan"];
                          List<dynamic> multiSatuan = jsonDecode(multisatuanString);
                          for (var din in multiSatuan) {
                            String barcode = din["BARCODE"];
                            if (barcode.contains(keyword)) {
                              listDetailBarang.add(d);
                            }
                          }
                        }
                      }

                      if (listDetailBarang.isEmpty) {
                        bool isOpenSearch = await Utils.showConfirmMessage(
                            context, "Data tidak ditemukan, buka pencarian?");
                        if (isOpenSearch) {
                          await selectBarang();
                        }

                        searchBarFocus.requestFocus();
                        return;
                      }

                      if (listDetailBarang.length > 1) {
                        dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
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

                      listValueSetter(listDetailBarang);
                      setState(() {
                        searchBarctrl.clear();
                      });
                      searchBarFocus.requestFocus();
                    }));
          }),
          actions: [
            Utils.widgetSetter(() {
              if (Utils.isPdtMode == "0") {
                return IconButton(
                    onPressed: () async {
                      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                          "#ff6666", "Cancel", true, ScanMode.BARCODE);

                      if (barcodeScanRes.isEmpty) {
                        Utils.showMessage("Data tidak ditemukan, coba ulangi", context);
                        return;
                      }
                      List<dynamic> listDetailBarang = [];

                      List<dynamic> listDetailBarangValue = await DatabaseHelper().readDatabase(
                          "SELECT detail_barang,multi_satuan,multi_harga,harga_tanggal FROM barang_temp WHERE kode=?",
                          params: [barcodeScanRes]);

                      listDetailBarang.addAll(listDetailBarangValue);

                      if (listDetailBarang.isEmpty) {
                        List<dynamic> listDetailBarangFilterLike = await DatabaseHelper().readDatabase(
                            "SELECT detail_barang,multi_satuan,multi_harga,harga_tanggal FROM barang_temp WHERE multi_satuan LIKE ?",
                            params: ['%$barcodeScanRes%']);

                        for (var d in listDetailBarangFilterLike) {
                          String multisatuanString = d["multi_satuan"];
                          List<dynamic> multiSatuan = jsonDecode(multisatuanString);
                          for (var din in multiSatuan) {
                            String barcode = din["BARCODE"];
                            if (barcode.contains(barcodeScanRes)) {
                              listDetailBarang.add(d);
                            }
                          }
                        }
                      }

                      if (listDetailBarang.length > 1) {
                        selectBarang();
                        searchBarFocus.requestFocus();
                        return;
                      }

                      listValueSetter(listDetailBarang);
                    },
                    icon: Icon(Icons.qr_code_scanner_rounded));
              }
              return IconButton(onPressed: () => selectBarang(), icon: Icon(Icons.list_alt_sharp));
            }),
            IconButton(
                onPressed: () async {
                  await modalHeader();
                },
                icon: Icon(Icons.note_add_rounded))
          ],
        ),
        body: Column(
          children: [
            Expanded(
              flex: 0,
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                  color: Colors.black,
                  width: 0.10,
                ))),
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 1, child: Text("Pelanggan")),
                        Expanded(
                            flex: 1,
                            child: Text(
                              namaPelanggan,
                              textAlign: TextAlign.end,
                            )),
                        Expanded(
                            flex: 0,
                            child: IconButton(
                                alignment: Alignment.centerRight,
                                onPressed: () async {
                                  dynamic popUpResult =
                                      await Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return ListModalForm(
                                        type: "pelanggan",
                                      );
                                    },
                                  ));

                                  if (popUpResult == null) return;

                                  setState(() {
                                    pelangganCtrl.text = popUpResult["NAMA"];
                                    idPelanggan = popUpResult["NOINDEX"];
                                    kodePelanggan = popUpResult["KODE"];
                                    namaPelanggan = popUpResult["NAMA"];
                                    idGolonganPelanggan = popUpResult["IDGOLONGAN"];
                                    idGolongan2Pelanggan = popUpResult["IDGOLONGAN2"];
                                    recalculateListOrderPenjualan();
                                  });
                                },
                                icon: Icon(Icons.search))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: ListView.builder(
                    itemCount: dataListShow.length,
                    itemBuilder: (BuildContext context, int index) {
                      dynamic data = dataListShow[index];
                      String kode = data["KODE"];
                      String nama = data["NAMA"];
                      String harga = Utils.formatNumber(data["HARGA"]);
                      String diskon = Utils.formatNumber(data["DISKONNOMINAL"]);
                      String qty = Utils.formatNumber(data["QTY"]);
                      String satuan = data["SATUAN"];
                      String keterangan = data["KETERANGAN"];
                      return Container(
                        child: Card(
                          child: InkWell(
                            onTap: () async {
                              await modalEdit(data, index);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    gambarUrlString + "thumbnail/" + data["IDBARANG"],
                                    headers: {
                                      'Authorization': 'Bearer ' + Utils.token,
                                      'company-code': Utils.companyCode
                                    },
                                    height: 100,
                                    width: 120,
                                    fit: BoxFit.contain,
                                  ),
                                  //Utils.bagde((index + 1).toString()),
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Utils.labelSetter(nama, bold: true),
                                          Utils.labelSetter(kode),
                                          Utils.labelSetter(harga, bold: true),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Utils.labelSetter("Disc :  $diskon", bold: false),
                                              Utils.labelSetter("Qty : $qty $satuan "),
                                            ],
                                          ),
                                          Utils.widgetSetter(() {
                                            if (keterangan == "") {
                                              return Container();
                                            }
                                            return Column(children: [
                                              SizedBox(height: 10),
                                              Utils.labelSetter(keterangan)
                                            ]);
                                          }),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    })),
            Expanded(
                flex: 0,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                    color: Colors.black,
                    width: 0.15,
                  ))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 5),
                        child: Utils.labelValueSetter("Total", Utils.formatNumber(totalPenjualan),
                            sizeLabel: 18, sizeValue: 18, boldValue: true),
                      ),
                      Container(
                        width: double.maxFinite,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () async {
                            await sendPayment();
                          },
                          child: Utils.labelSetter("SIMPAN", color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ));
  }

/*Future<dynamic> _getBarang(String keyword) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString =
        "${Utils.mainUrl}barang/caribarangjual?idgudang=${Utils.idGudang}&cari=" + keyword;
    Uri url = Uri.parse(urlString);
    Response response = await get(url, headers: Utils.setHeader());
    log(urlString);
    String body = response.body;
    log(body);
    var jsonData = jsonDecode(body)["data"];
    Navigator.pop(context);

    return jsonData;
  }*/
}
