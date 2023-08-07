import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mizanmobile/activity/hutang/list_hutang.dart';
import 'package:mizanmobile/activity/utility/list_modal_form.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

class InputBarang extends StatefulWidget {
  final String idBarang;
  const InputBarang({Key? key, required this.idBarang});

  @override
  State<InputBarang> createState() => _InputBarangState();
}

class _InputBarangState extends State<InputBarang> with TickerProviderStateMixin {
  late TabController _tabController;
  int indexTab = 0;
  String idBarangGlobal = "";

  List<dynamic> lsMutisatuan = [];

  TextEditingController _kodeCtrl = TextEditingController();
  TextEditingController _namaCtrl = TextEditingController();
  TextEditingController _kelompokCtrl = TextEditingController();
  String _idKelompok = "";
  TextEditingController _suplierCtrl = TextEditingController();
  String _idSuplier = "";
  TextEditingController _keteranganCtrl = TextEditingController();
  TextEditingController _merkCtrl = TextEditingController();
  String _idMerk = "";
  TextEditingController _satuanCtrl = TextEditingController();
  String _idSatuan = "";
  TextEditingController _gudangCtrl = TextEditingController();
  String _idGudang = Utils.idGudang;
  TextEditingController _lokasiCtrl = TextEditingController();
  String _idLokasi = "";
  TextEditingController _deptCtrl = TextEditingController();
  String _idDept = Utils.idDept;
  String _metodeHpp = "1";
  TextEditingController _stokMinimalCtrl = TextEditingController();
  TextEditingController _hargaBeliTerakhirCtrl = TextEditingController();
  TextEditingController _hargaJualCtrl = TextEditingController();

  Future<dynamic> _getDataDetailBarang(String idBarang) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString =
        "${Utils.mainUrl}barang/rincian?idgudang=${Utils.idGudang}&halaman=0&idbarang=$idBarang";
    Uri url = Uri.parse(urlString);
    Response response = await get(url, headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body)["data"];
    print(jsonData);
    Navigator.pop(context);
    return jsonData;
  }

  Future<dynamic> _postDetailDataBarang(Map<String, Object> postBody, urlPath) async {
    String postData = jsonEncode(postBody);
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}barang/" + urlPath;
    Uri url = Uri.parse(urlString);
    Response response = await post(
      url,
      body: postData,
      headers: Utils.setHeader(),
    );
    var jsonData = jsonDecode(response.body);
    Navigator.pop(context);
    print(jsonData);
    return jsonData;
  }

  @override
  void initState() {
    super.initState();

    _setDataDetail(widget.idBarang);
    _tabController = TabController(initialIndex: indexTab, length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        indexTab = _tabController.index;
      });
    });
  }

  late Widget tab2 = ListView();
  late Widget tab3 = ListView();

  _setDataDetail(String idBarang) async {
    idBarangGlobal = await idBarang;

    if (idBarang == "") {
      setState(() {
        _deptCtrl.text = Utils.namaDept;
        _gudangCtrl.text = Utils.namaGudang;
        _kelompokCtrl.text = Utils.namaKelompok;
        _idKelompok = Utils.idKelompok;
        _satuanCtrl.text = Utils.satuan;
        _idSatuan = Utils.idSatuan;
        _lokasiCtrl.text = Utils.namaLokasi;
        _idLokasi = Utils.idLokasi;
      });

      return;
    }
    dynamic dataDetail = await _getDataDetailBarang(idBarang);
    List<dynamic> dataDetailList = dataDetail["detail_barang"];
    dynamic dataInfo = dataDetail["detail_barang"][0];
    List<dynamic> dataMultiSatuan = dataDetail["multi_satuan"];
    List<dynamic> dataMultiHarga = dataDetail["multi_harga"];
    lsMutisatuan = dataMultiSatuan;

    setState(() {
      _kodeCtrl.text = dataInfo["KODE"];
      _namaCtrl.text = dataInfo["NAMA"];
      _kelompokCtrl.text = dataInfo["NAMA_KELOMPOK"];
      _idKelompok = dataInfo["IDKELOMPOK"];
      _suplierCtrl.text = dataInfo["NAMA_SUPLIER_UTAMA"].toString();
      _idSuplier = dataInfo["IDSUPLIERUTAMA"].toString();
      _keteranganCtrl.text = dataInfo["KETERANGAN"].toString();
      _merkCtrl.text = dataInfo["NAMA_MEREK"].toString();
      _idMerk = dataInfo["IDMEREK"].toString();
      _satuanCtrl.text = dataInfo["KODE_SATUAN"];
      _idSatuan = dataInfo["IDSATUAN"];
      _gudangCtrl.text = dataInfo["NAMA_GUDANG"];
      _idGudang = dataInfo["IDGUDANG"];
      _lokasiCtrl.text = dataInfo["NAMA_LOKASI"];
      _idLokasi = dataInfo["IDLOKASI"];
      _deptCtrl.text = dataInfo["NAMA_DEPT"];
      _idDept = dataInfo["IDDEPT"].toString();
      _stokMinimalCtrl.text = dataInfo["STOK_MINIMUM"].toString();
      _hargaBeliTerakhirCtrl.text = dataInfo["HARGA_BELI"].toString();
      _hargaJualCtrl.text = dataInfo["HARGA_JUAL"].toString();
      _metodeHpp = dataInfo["METODEHPP"].toString();

      tab2 = ListView(
        children: dataMultiSatuan.map((v) {
          int i = dataMultiSatuan.indexOf(v);
          return Container(
            child: Card(
              child: InkWell(
                onTap: () {
                  showModalPopup("multisatuan", v);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Utils.bagde((i + 1).toString().substring(0, 1)),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Column(
                            children: [
                              Utils.labelValueSetter("Satuan", v["KODE_SATUAN"]),
                              Utils.labelValueSetter("Kode/Barcode", v["BARCODE"]),
                              Utils.labelValueSetter("Satuan Pengali", v["KODE_SATUAN_PENGALI"]),
                              Utils.labelValueSetter(
                                  "Isi Per Satuan", Utils.formatNumber(v["QTYSATUANPENGALI"]))
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
        }).toList(),
      );

      tab3 = ListView(
        children: dataMultiHarga.map((v) {
          int i = dataMultiHarga.indexOf(v);
          return Container(
            child: Card(
              child: InkWell(
                onTap: () {
                  showModalPopup("multiharga", v);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Utils.bagde((i + 1).toString().substring(0, 1)),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Column(
                            children: [
                              Utils.labelValueSetter("GOLONGAN", v["KODE_GOL"]),
                              Utils.labelValueSetter("Dari", Utils.formatNumber(v["DARI"])),
                              Utils.labelValueSetter("Hingga", Utils.formatNumber(v["HINGGA"])),
                              Utils.labelValueSetter("Satuan", v["KODE_SATUAN"]),
                              Utils.labelValueSetter("Harga", Utils.formatNumber(v["HARGA_JUAL"])),
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
        }).toList(),
      );
    });
  }

  Future<dynamic> showModalMultiHarga({dynamic param = null}) {
    TextEditingController golonganCtrl = TextEditingController();
    TextEditingController dariCtrl = TextEditingController();
    TextEditingController hinggaCtrl = TextEditingController();
    TextEditingController satuanCtrl = TextEditingController();
    TextEditingController hargaCtrl = TextEditingController();

    dariCtrl.text = "1";
    hinggaCtrl.text = "9999";

    dynamic popUpResult;
    String idGolongan = "";
    String idSatuan = "";
    String idSatuanPengali = "";
    double qtySatuanPengali = 0;
    String noIndex = "";

    if (param != null) {
      noIndex = param["NOINDEX"];
      golonganCtrl.text = param["KODE_GOL"];
      idGolongan = param["IDGOLONGAN"];
      dariCtrl.text = param["DARI"].toString();
      hinggaCtrl.text = param["HINGGA"].toString();
      satuanCtrl.text = param["KODE_SATUAN"];
      idSatuan = param["IDSATUAN"];
      hargaCtrl.text = param["HARGA_JUAL"].toString();
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
                  Utils.labelSetter("Input Multi Harga", size: 25),
                  Padding(padding: EdgeInsets.all(10)),
                  Text("Golongan"),
                  Row(
                    children: [
                      Expanded(
                          flex: 10,
                          child: TextField(
                            controller: golonganCtrl,
                            enabled: false,
                          )),
                      Expanded(
                        child: IconButton(
                          onPressed: () async {
                            popUpResult = await Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ListModalForm(type: "golonganpelanggan");
                              },
                            ));

                            if (!mounted) return;

                            golonganCtrl.text = popUpResult["NAMA"];
                            idGolongan = popUpResult["NOINDEX"];
                          },
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Utils.labelForm("Dari"),
                        TextField(
                          controller: dariCtrl,
                        ),
                      ]),
                    ),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Utils.labelForm("Hingga"),
                        TextField(
                          controller: hinggaCtrl,
                        ),
                      ]),
                    ),
                  ]),
                  Utils.labelForm("Satuan"),
                  Row(
                    children: [
                      Expanded(
                          flex: 10,
                          child: TextField(
                            enabled: false,
                            controller: satuanCtrl,
                          )),
                      Expanded(
                        child: IconButton(
                          onPressed: () async {
                            popUpResult = await Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ListModalForm(
                                  type: "satuanbarang",
                                  idBarang: idBarangGlobal,
                                );
                              },
                            ));

                            if (popUpResult == null) return;

                            satuanCtrl.text = popUpResult["NAMA"];
                            idSatuan = popUpResult["NOINDEX"];
                            idSatuanPengali = popUpResult["IDSATUANPENGALI"];
                            qtySatuanPengali = popUpResult["QTYSATUANPENGALI"];
                          },
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  Utils.labelForm("Harga"),
                  TextField(
                    controller: hargaCtrl,
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            Map<String, Object> mapData = {};
                            dynamic result;
                            if (param != null) {
                              mapData = {
                                "noindex": noIndex,
                                "idgolongan": idGolongan,
                                "dari": dariCtrl.text,
                                "hingga": hinggaCtrl.text,
                                "harga_jual": hargaCtrl.text,
                                "idsatuan": idSatuan,
                                "idbarang": idBarangGlobal,
                                "persen_harga_jual": 0,
                                "idsatuanpengali": idSatuanPengali,
                                "qtysatuanpengali": qtySatuanPengali,
                              };
                              result = await _postDetailDataBarang(mapData, "multiharga/edit");
                            } else {
                              mapData = {
                                "idgolongan": idGolongan,
                                "dari": dariCtrl.text,
                                "hingga": hinggaCtrl.text,
                                "harga_jual": hargaCtrl.text,
                                "idsatuan": idSatuan,
                                "idbarang": idBarangGlobal,
                                "persen_harga_jual": 0,
                                "idsatuanpengali": idSatuanPengali,
                                "qtysatuanpengali": qtySatuanPengali,
                              };
                              result = await _postDetailDataBarang(mapData, "multiharga/insert");
                            }
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            _setDataDetail(idBarangGlobal);
                          },
                          child: Text("Simpan")))
                ],
              ),
            ),
          );
        });
  }

  Future<dynamic> showModalMultiSatuan({dynamic param = null}) {
    dynamic popUpResult;
    TextEditingController satuanCtrl = TextEditingController();
    TextEditingController barcodeCtrl = TextEditingController();
    TextEditingController isiPengaliCtrl = TextEditingController();
    TextEditingController satuanPengaliCtrl = TextEditingController();
    String idSatuan = "";
    String idSatuanPengali = "";
    String noIndex = "";

    if (param != null) {
      noIndex = param["NOINDEX"];
      barcodeCtrl.text = param["BARCODE"];
      isiPengaliCtrl.text = param["QTYSATUANPENGALI"].toString();
      satuanCtrl.text = param["KODE_SATUAN"];
      idSatuan = param["IDSATUAN"];
      idSatuanPengali = param["IDSATUANPENGALI"];
      satuanPengaliCtrl.text = param["KODE_SATUAN_PENGALI"];
    } else {
      idSatuanPengali = _idSatuan;
      satuanPengaliCtrl.text = _satuanCtrl.text;
    }

    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Utils.labelSetter("Input Multi Satuan", size: 25),
                  Padding(padding: EdgeInsets.all(10)),
                  Text("Satuan"),
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
                            popUpResult = await Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ListModalForm(type: "satuan");
                              },
                            ));

                            if (!mounted) return;

                            satuanCtrl.text = popUpResult["NAMA"];
                            idSatuan = popUpResult["NOINDEX"];
                          },
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  Utils.labelForm("Kode/Barcode"),
                  TextField(
                    controller: barcodeCtrl,
                  ),
                  Utils.labelForm("Isi Persatuan"),
                  TextField(
                    controller: isiPengaliCtrl,
                  ),
                  Utils.labelForm("Satuan Pengali"),
                  TextField(
                    enabled: false,
                    controller: satuanPengaliCtrl,
                  ),
                  Padding(padding: EdgeInsets.all(10)),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            Map<String, Object> mapData = {};
                            dynamic result;
                            if (param != null) {
                              mapData = {
                                "noindex": noIndex,
                                "idbarang": idBarangGlobal,
                                "idsatuan": idSatuan,
                                "idsatuanpengali": idSatuanPengali,
                                "qtysatuanpengali": isiPengaliCtrl.text,
                                "barcode": barcodeCtrl.text,
                              };
                              result = await _postDetailDataBarang(mapData, "multisatuan/edit");
                            } else {
                              Map<String, Object> mapData = {
                                "idbarang": idBarangGlobal,
                                "barcode": barcodeCtrl.text,
                                "idsatuan": idSatuan,
                                "qtysatuanpengali": isiPengaliCtrl.text,
                                "idsatuanpengali": idSatuanPengali,
                              };
                              result = await _postDetailDataBarang(mapData, "multisatuan/insert");
                            }
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            _setDataDetail(idBarangGlobal);
                          },
                          child: Text("Simpan")))
                ],
              ),
            ),
          );
        });
  }

  Future<dynamic> showModalPopup(String type, dynamic param) {
    return showModalBottomSheet(
        context: context,
        builder: ((context) {
          return Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          if (type == "multisatuan") {
                            showModalMultiSatuan(param: param);
                          } else {
                            showModalMultiHarga(param: param);
                          }
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
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }

                          bool isConfirm = await Utils.showConfirmMessage(
                              context, "Yakin ingin menghapus dara ini ?");

                          if (isConfirm) {
                            if (type == "multisatuan") {
                              Map<String, Object> mapData = {"noindex": param["NOINDEX"]};
                              dynamic result =
                                  await _postDetailDataBarang(mapData, "multisatuan/delete");

                              if (result["code"] == 0) {
                                _setDataDetail(idBarangGlobal);
                              } else {
                                Utils.showMessage(result["message"], context);
                              }
                            } else {
                              Map<String, Object> mapData = {"noindex": param["NOINDEX"]};
                              dynamic result =
                                  await _postDetailDataBarang(mapData, "multiharga/delete");

                              if (result["code"] == 0) {
                                _setDataDetail(idBarangGlobal);
                              } else {
                                Utils.showMessage(result["message"], context);
                              }
                            }
                          }
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.black54,
                        )),
                    Text("Delete")
                  ],
                )
              ],
            ),
          );
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: (indexTab == 1)
          ? FloatingActionButton(
              child: Icon(
                Icons.add,
                size: 30,
              ),
              onPressed: () {
                if (idBarangGlobal == "") {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Informasi barang harus diisi lebih dulu")));
                } else {
                  showModalMultiSatuan();
                }
              },
            )
          : (indexTab == 2)
              ? FloatingActionButton(
                  child: Icon(
                    Icons.add,
                    size: 30,
                  ),
                  onPressed: () {
                    if (idBarangGlobal == "") {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Informasi barang harus diisi lebih dulu")));
                    } else {
                      showModalMultiHarga();
                    }
                  })
              : null,
      appBar: AppBar(
        title: Text("Input Data Barang"),
        bottom: TabBar(
          onTap: (index) {
            setState(() {
              indexTab = index;
            });
          },
          controller: _tabController,
          tabs: [
            Utils.labelSetter("Informasi", size: 16, color: Colors.white),
            Utils.labelSetter("Multi Satuan", size: 16, color: Colors.white),
            Utils.labelSetter("Multi Harga", size: 16, color: Colors.white)
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: ListView(
              children: [
                Utils.labelForm("Kode Barang (Kosongkan untuk auto generate)"),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: _kodeCtrl,
                    )),
                    Expanded(
                        flex: 0,
                        child: IconButton(
                            onPressed: () async {
                              String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                                  "#ff6666", "Cancel", true, ScanMode.BARCODE);

                              if (barcodeScanRes == "-1") return;
                              _kodeCtrl.text = barcodeScanRes;
                            },
                            icon: Icon(Icons.qr_code_scanner)))
                  ],
                ),
                Utils.labelForm("Nama Barang"),
                TextField(
                  controller: _namaCtrl,
                ),
                Utils.labelForm("Kelompok"),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: _kelompokCtrl,
                      enabled: false,
                    )),
                    Expanded(
                        flex: 0,
                        child: IconButton(
                            onPressed: () async {
                              dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return ListModalForm(
                                    type: "kelompokbarang",
                                  );
                                },
                              ));

                              if (popUpResult == null) return;
                              _kelompokCtrl.text = popUpResult["NAMA"];
                              _idKelompok = popUpResult["NOINDEX"];
                            },
                            icon: Icon(Icons.search)))
                  ],
                ),
                Utils.labelForm("Suplier"),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: _suplierCtrl,
                      enabled: false,
                    )),
                    Expanded(
                        flex: 0,
                        child: IconButton(
                            onPressed: () async {
                              dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return ListModalForm(
                                    type: "suplier",
                                  );
                                },
                              ));

                              if (popUpResult == null) return;
                              _suplierCtrl.text = popUpResult["NAMA"];
                              _idSuplier = popUpResult["NOINDEX"];
                            },
                            icon: Icon(Icons.search)))
                  ],
                ),
                Utils.labelForm("Keterangan"),
                TextField(
                  controller: _keteranganCtrl,
                ),
                Utils.labelForm("Merk"),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: _merkCtrl,
                      enabled: false,
                    )),
                    Expanded(
                        flex: 0,
                        child: IconButton(
                            onPressed: () async {
                              dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return ListModalForm(
                                    type: "merk",
                                  );
                                },
                              ));

                              if (popUpResult == null) return;
                              _merkCtrl.text = popUpResult["NAMA"];
                              _idMerk = popUpResult["NOINDEX"];
                            },
                            icon: Icon(Icons.search)))
                  ],
                ),
                Utils.labelForm("Satuan"),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: _satuanCtrl,
                      enabled: false,
                    )),
                    Expanded(
                        flex: 0,
                        child: IconButton(
                            onPressed: () async {
                              dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return ListModalForm(
                                    type: "satuan",
                                  );
                                },
                              ));

                              if (popUpResult == null) return;
                              _satuanCtrl.text = popUpResult["NAMA"];
                              _idSatuan = popUpResult["NOINDEX"];
                            },
                            icon: Icon(Icons.search)))
                  ],
                ),
                Utils.labelForm("Gudang"),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: _gudangCtrl,
                      enabled: false,
                    )),
                    Expanded(
                        flex: 0,
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
                              _gudangCtrl.text = popUpResult["NAMA"];
                              _idGudang = popUpResult["NOINDEX"];
                            },
                            icon: Icon(Icons.search)))
                  ],
                ),
                Utils.labelForm("Lokasi"),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: _lokasiCtrl,
                      enabled: false,
                    )),
                    Expanded(
                        flex: 0,
                        child: IconButton(
                            onPressed: () async {
                              dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return ListModalForm(
                                    type: "lokasi",
                                  );
                                },
                              ));

                              if (popUpResult == null) return;
                              _lokasiCtrl.text = popUpResult["NAMA"];
                              _idLokasi = popUpResult["NOINDEX"];
                            },
                            icon: Icon(Icons.search)))
                  ],
                ),
                Utils.labelForm("Department"),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: _deptCtrl,
                      enabled: false,
                    )),
                    Expanded(
                        flex: 0,
                        child: IconButton(
                            onPressed: () async {
                              dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return ListModalForm(
                                    type: "dept",
                                  );
                                },
                              ));

                              if (popUpResult == null) return;
                              _deptCtrl.text = popUpResult["NAMA"];
                              _idDept = popUpResult["NOINDEX"].toString();
                            },
                            icon: Icon(Icons.search)))
                  ],
                ),
                Utils.labelForm("Metode Harga"),
                DropdownButton(
                    value: _metodeHpp,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(
                        child: Text("FIFO"),
                        value: "1",
                      ),
                      DropdownMenuItem(
                        child: Text("LIFO"),
                        value: "2",
                      ),
                      DropdownMenuItem(
                        child: Text("AVERAGE"),
                        value: "3",
                      )
                    ],
                    onChanged: (newvalue) {
                      setState(() {
                        _metodeHpp = newvalue.toString();
                      });
                      
                    }),
                Utils.labelForm("Stok Minimal"),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _stokMinimalCtrl,
                ),
                Utils.labelForm("Harga Beli Terakhir"),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _hargaBeliTerakhirCtrl,
                ),
                Utils.labelForm("Harga Jual"),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _hargaJualCtrl,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_kelompokCtrl.text == "" ||
                        _satuanCtrl.text == "" ||
                        _gudangCtrl.text == "" ||
                        _deptCtrl.text == "" ||
                        _namaCtrl.text == "" ||
                        _hargaJualCtrl.text == "" ||
                        _stokMinimalCtrl.text == "" ||
                        _hargaBeliTerakhirCtrl.text == "") {
                      Utils.showMessage("Pastikan inputan terisi semua", context);
                      return;
                    }

                    Map<String, Object> mapData = {};
                    dynamic result;
                    if (idBarangGlobal == "") {
                      mapData = {
                        "kode": _kodeCtrl.text,
                        "nama": _namaCtrl.text,
                        "idkelompok": _idKelompok,
                        "idsuplierutama": _idSuplier,
                        "keterangan": _keteranganCtrl.text,
                        "idmerek": _idMerk,
                        "idsatuan": _idSatuan,
                        "idgudang": _idGudang,
                        "idlokasi": _idLokasi,
                        "iddept": _idDept,
                        "metodehpp": _metodeHpp,
                        "stok_minimum": _stokMinimalCtrl.text,
                        "harga_beli": _hargaBeliTerakhirCtrl.text,
                        "harga_jual": _hargaJualCtrl.text
                      };
                      result = await _postDetailDataBarang(mapData, "insert");
                      dynamic data = result["data"];
                      idBarangGlobal = data["NOINDEX"];
                    } else {
                      mapData = {
                        "noindex": idBarangGlobal,
                        "kode": _kodeCtrl.text,
                        "nama": _namaCtrl.text,
                        "idkelompok": _idKelompok,
                        "idsuplierutama": _idSuplier,
                        "keterangan": _keteranganCtrl.text,
                        "idmerek": _idMerk,
                        "idsatuan": _idSatuan,
                        "idgudang": _idGudang,
                        "idlokasi": _idLokasi,
                        "iddept": _idDept,
                        "metodehpp": _metodeHpp,
                        "stok_minimum": _stokMinimalCtrl.text,
                        "harga_beli": _hargaBeliTerakhirCtrl.text,
                        "harga_jual": _hargaJualCtrl.text
                      };
                      result = await _postDetailDataBarang(mapData, "edit");
                    }
                    Utils.showMessage(result["message"], context);
                    _setDataDetail(idBarangGlobal);
                  },
                  child: Text("SIMPAN"),
                ),
              ],
            ),
          ),
          Container(child: tab2),
          Container(child: tab3),
        ],
      ),
    );
  }
}
