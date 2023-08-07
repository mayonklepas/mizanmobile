import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mizanmobile/activity/utility/list_modal_barang.dart';

import '../../utils.dart';
import 'package:http/http.dart';

import '../utility/list_modal_form.dart';

class InputTransferBarang extends StatefulWidget {
  final String idTransaksi;
  const InputTransferBarang({Key? key, required this.idTransaksi}) : super(key: key);

  @override
  State<InputTransferBarang> createState() => _InputTransferBarangState();
}

class _InputTransferBarangState extends State<InputTransferBarang> {
  TextEditingController dariCtrl = TextEditingController();
  TextEditingController keCtrl = TextEditingController();
  String idGudangDari = "";
  String idGudangKe = "";
  String tanggalTransaksi = Utils.currentDateString();
  String namaGudangDari = "";
  String namaGudangKe = "";
  String idTransaksiGlobal = "";
  String norefGlobal = "";
  String keterangan = "";

  late Container listContainer = Container();

  dynamic globalResultData = {};

  String idDept = Utils.idDept;
  String namaDept = Utils.namaDept;

  Future<dynamic> _getTransferBarang(String idTransaksi) async {
    String urlString = "${Utils.mainUrl}transferbarang/rincian?idgenjur=";
    Uri url = Uri.parse(urlString + idTransaksi);
    Response response = await get(url, headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body)["data"];
    print(jsonData);
    return jsonData;
  }

  Future<dynamic> _postTranferbarang(Map<String, Object> postBody, urlPath) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}transferbarang/" + urlPath;
    Uri url = Uri.parse(urlString);
    Response response = await post(url, body: jsonEncode(postBody), headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body);
    Navigator.pop(context);
    return jsonData;
  }

  @override
  void initState() {
    // TODO: implement initState
    _setTransfer(idTransaksi: widget.idTransaksi);
    super.initState();
  }

  _setTransfer({String idTransaksi = "", dynamic defaultResult = null}) async {
    dynamic resultData = null;

    if (defaultResult == null) {
      if (idTransaksi == "") {
        listContainer = Container();
        return;
      }
      idTransaksiGlobal = idTransaksi;
      resultData = await _getTransferBarang(idTransaksi);
      globalResultData = await resultData;
    } else {
      resultData = defaultResult;
      globalResultData = await resultData;
    }

    dynamic header = resultData["header"];
    List<dynamic> detail = resultData["detail"];
    setState(() {
      norefGlobal = header["NOREF"];
      namaGudangDari = header["NAMA_GUDANG_DARI"];
      idGudangDari = header["IDGUDANGDARI"];
      namaGudangKe = header["NAMA_GUDANG_TUJUAN"];
      idGudangKe = header["IDGUDANGTUJUAN"];
      tanggalTransaksi = header["TANGGAL"];
      keterangan = header["KETERANGAN"];
      listContainer = Container(
        child: ListView.builder(
            itemCount: detail.length,
            itemBuilder: (BuildContext context, int index) {
              dynamic data = detail[index];
              return Container(
                child: Card(
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext content) {
                            return Container(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              height: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      IconButton(
                                          onPressed: () async {
                                            if (Navigator.canPop(context)) {
                                              Navigator.pop(context);
                                            }
                                            showModalInputDetail(param: data);
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.black54,
                                          )),
                                      Text("Edit")
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                          onPressed: () async {
                                            Map<String, Object> mapData = {
                                              "idgenjur": idTransaksiGlobal,
                                              "noindex": data["NOINDEX"]
                                            };
                                            dynamic result =
                                                await _postTranferbarang(mapData, "deletedetail");
                                            if (result["status"] == 0) {
                                              _setTransfer(defaultResult: result["data"]);
                                            }
                                            if (Navigator.canPop(context)) {
                                              Navigator.pop(context);
                                            }
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.black54,
                                          )),
                                      Text("Delete")
                                    ],
                                  ),
                                ],
                              ),
                            );
                          });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Utils.bagde((index + 1).toString()),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Utils.labelSetter(data["NAMA_BARANG"], bold: true),
                                  Utils.labelSetter(data["KODE_BARANG"]),
                                  Utils.labelSetter(Utils.formatNumber(data["JUMLAH"]) +
                                      " " +
                                      data["KODE_SATUAN"])
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
            }),
      );
    });
  }

  Future<dynamic> showModalInputDetail({dynamic param = null}) {
    TextEditingController kodeBarangCtrl = TextEditingController();
    TextEditingController namaBarangCtrl = TextEditingController();
    TextEditingController satuanCtrl = TextEditingController();
    TextEditingController jumlahCtrl = TextEditingController();
    dynamic popUpResult;
    String idBarang = "";
    String idSatuan = "";
    String idSatuanPengali = "";
    double qtySatuanPengali = 1;
    String noIndex = "";

    if (param != null) {
      noIndex = param["NOINDEX"];
      kodeBarangCtrl.text = param["KODE_BARANG"];
      namaBarangCtrl.text = param["NAMA_BARANG"];
      idBarang = param["IDBARANG"];
      satuanCtrl.text = param["KODE_SATUAN"];
      jumlahCtrl.text = param["JUMLAH"].toString();
      idSatuan = param["IDSATUAN"];
      idSatuanPengali = param["IDSATUANPENGALI"];
      qtySatuanPengali = param["QTYSATUANPENGALI"];
    }
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
                  Utils.labelSetter("Tambah Barang", size: 25, bold: true),
                  Padding(padding: EdgeInsets.all(10)),
                  Text("Kode Barang"),
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                        controller: kodeBarangCtrl,
                        enabled: false,
                      )),
                      Expanded(
                        flex: 0,
                        child: IconButton(
                          onPressed: () async {
                            popUpResult = await Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ListModalBarang();
                              },
                            ));

                            if (popUpResult == null) return;

                            //print(popUpResult);
                            setState(() {
                              kodeBarangCtrl.text = popUpResult["KODE"];
                              namaBarangCtrl.text = popUpResult["NAMA"];
                              idBarang = popUpResult["NOINDEX"];
                              satuanCtrl.text = popUpResult["KODE_SATUAN"];
                              idSatuan = popUpResult["IDSATUAN"];
                              idSatuanPengali = popUpResult["IDSATUAN"];
                              qtySatuanPengali = 1;
                            });
                          },
                          icon: Icon(Icons.search),
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: IconButton(
                          onPressed: () async {
                            String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                                "#ff6666", "Cancel", true, ScanMode.BARCODE);

                            if (barcodeScanRes == "-1") return;

                            List<dynamic> result = await Utils.getDataBarangByCode(barcodeScanRes);

                            if (result.length == 1) {
                              popUpResult = result[0];
                            } else if (result.length > 1) {
                              popUpResult = await Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return ListModalBarang(
                                    keyword: barcodeScanRes,
                                  );
                                },
                              ));
                            } else {
                              Utils.showMessage("Data tidak ditemukan", context);
                              popUpResult = null;
                            }

                            if (popUpResult == null) return;

                            setState(() {
                              kodeBarangCtrl.text = popUpResult["KODE"];
                              namaBarangCtrl.text = popUpResult["NAMA"];
                              idBarang = popUpResult["NOINDEX"];
                              satuanCtrl.text = popUpResult["KODE_SATUAN"];
                              idSatuan = popUpResult["IDSATUAN"];
                              idSatuanPengali = popUpResult["IDSATUAN"];
                              qtySatuanPengali = 1;
                            });
                          },
                          icon: Icon(Icons.qr_code_scanner),
                        ),
                      ),
                    ],
                  ),
                  Utils.labelForm("Nama Barang"),
                  TextField(
                    enabled: false,
                    controller: namaBarangCtrl,
                  ),
                  Utils.labelForm("Satuan"),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: false,
                          controller: satuanCtrl,
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: IconButton(
                          onPressed: () async {
                            popUpResult = await Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ListModalForm(
                                  type: "satuanbarang",
                                  idBarang: idBarang,
                                );
                              },
                            ));

                            if (popUpResult == null) return;
                            satuanCtrl.text = popUpResult["NAMA"];
                            idSatuan = popUpResult["NOINDEX"];
                            qtySatuanPengali = popUpResult["QTYSATUANPENGALI"];
                          },
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  Utils.labelForm("Jumlah"),
                  TextField(
                    controller: jumlahCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            print(globalResultData);

                            if (globalResultData["detail"] != null) {
                              List<dynamic> detail = globalResultData["detail"];
                              for (var d in detail) {
                                if (d["IDBARANG"] == idBarang) {
                                  Utils.showMessage("Barang Sudah ada di daftar", context);
                                  return;
                                }
                              }
                            }

                            if (jumlahCtrl.text == "") {
                              Utils.showMessage("Stok fisik tidak boleh kosong", context);
                              return;
                            }

                            Map<String, Object> mapData = {};
                            dynamic result;
                            if (param != null) {
                              mapData = {
                                "noindex": noIndex,
                                "idgenjur": idTransaksiGlobal,
                                "idgudangdari": idGudangDari,
                                "idgudangtujuan": idGudangKe,
                                "idbarang": idBarang,
                                "jumlah": double.parse(jumlahCtrl.text),
                                "idsatuan": idSatuan,
                                "idsatuanpengali": idSatuanPengali,
                                "qtysatuanpengali": qtySatuanPengali,
                              };
                              result = await _postTranferbarang(mapData, "editdetail");
                            } else {
                              mapData = {
                                "idgenjur": idTransaksiGlobal,
                                "gudangdari": idGudangDari,
                                "gudangtujuan": idGudangKe,
                                "idbarang": idBarang,
                                "jumlah": double.parse(jumlahCtrl.text),
                                "idsatuan": idSatuan,
                                "idsatuanpengali": idSatuanPengali,
                                "qtysatuanpengali": qtySatuanPengali,
                              };
                              result = await _postTranferbarang(mapData, "insertdetail");
                            }
                            Navigator.pop(context);
                            _setTransfer(defaultResult: result["data"]);
                          },
                          child: Text("Simpan")))
                ],
              ),
            ),
          );
        });
  }

  void setTextDateRange(TextEditingController tgl) async {
    DateTime? pickedDate = await Utils.getDatePicker(context);
    if (pickedDate != null) {
      setState(() {
        tgl.text = Utils.formatStdDate(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (idTransaksiGlobal == "") {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Input Informasi Transfer Terlebih Dahulu")));
          } else {
            showModalInputDetail();
          }
        },
        child: Icon(
          Icons.add,
          size: 30,
        ),
      ),
      appBar: AppBar(
        title: Text("Input Transfer Barang"),
        actions: [
          IconButton(
              onPressed: () {
                TextEditingController tanggalCtrl = TextEditingController();
                TextEditingController keteranganCtrl = TextEditingController();
                TextEditingController deptCtrl = TextEditingController();
                deptCtrl.text = namaDept;
                tanggalCtrl.text = tanggalTransaksi;
                keteranganCtrl.text = keterangan;
                dariCtrl.text = namaGudangDari;
                keCtrl.text = namaGudangKe;
                showModalBottomSheet(
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
                              Utils.labelSetter("Input Informasi", size: 25, bold: true),
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
                              Utils.labelForm("Dari Gudang"),
                              Row(
                                children: [
                                  Expanded(
                                      flex: 10,
                                      child: TextField(
                                        controller: dariCtrl,
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

                                        dariCtrl.text = popUpResult["NAMA"];
                                        idGudangDari = popUpResult["NOINDEX"];
                                        namaGudangDari = popUpResult["NAMA"];
                                      },
                                      icon: Icon(Icons.search),
                                    ),
                                  ),
                                ],
                              ),
                              Utils.labelForm("Ke Gudang"),
                              Row(
                                children: [
                                  Expanded(
                                      flex: 10,
                                      child: TextField(
                                        controller: keCtrl,
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

                                        keCtrl.text = popUpResult["NAMA"];
                                        idGudangKe = popUpResult["NOINDEX"];
                                        namaGudangKe = popUpResult["NAMA"];
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
                              SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        Map<String, Object> mapData = {};
                                        dynamic result;
                                        if (idTransaksiGlobal != "") {
                                          mapData = {
                                            "noindex": idTransaksiGlobal,
                                            "noref": norefGlobal,
                                            "iddept": idDept,
                                            "tanggal": tanggalCtrl.text,
                                            "keterangan": keteranganCtrl.text,
                                            "useredit": Utils.idUser,
                                          };
                                          result = await _postTranferbarang(mapData, "editheader");
                                        } else {
                                          mapData = {
                                            "iddept": idDept,
                                            "tanggal": tanggalCtrl.text,
                                            "keterangan": keteranganCtrl.text,
                                            "userinput": Utils.idUser
                                          };
                                          result =
                                              await _postTranferbarang(mapData, "insertheader");
                                        }
                                        print(result);
                                        idTransaksiGlobal = result["data"]["NOINDEX"];
                                        setState(() {
                                          norefGlobal = result["data"]["NOREF"];
                                          namaGudangDari = dariCtrl.text;
                                          namaGudangKe = keCtrl.text;
                                          tanggalTransaksi = result["data"]["TANGGAL"];
                                          keterangan = result["data"]["KETERANGAN"];
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text("Simpan")))
                            ],
                          ),
                        ),
                      );
                    });
              },
              icon: Icon(Icons.note_add_rounded))
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
                flex: 0,
                child: Container(
                  child: Card(
                    elevation: 2,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Utils.labelValueSetter(
                            "No Transaksi",
                            norefGlobal,
                          ),
                          Utils.labelValueSetter(
                              "Tanggal Transaksi", Utils.formatDate(tanggalTransaksi)),
                          Utils.labelValueSetter("Departement", namaDept),
                          Utils.labelValueSetter("Transfer Dari", namaGudangDari),
                          Utils.labelValueSetter("Transfer Ke", namaGudangKe),
                          Utils.labelValueSetter("Keterangan", keterangan)
                        ],
                      ),
                    ),
                  ),
                )),
            Expanded(child: listContainer)
          ],
        ),
      ),
    );
  }
}
