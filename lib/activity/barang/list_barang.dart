import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mizanmobile/activity/barang/input_barang.dart';
import 'package:mizanmobile/activity/mutasi/list_mutasi.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart' as http;

class ListBarang extends StatefulWidget {
  const ListBarang({Key? key}) : super(key: key);

  @override
  State<ListBarang> createState() => _ListBarangState();
}

class _ListBarangState extends State<ListBarang> {
  Future<List<dynamic>>? _dataBarang;

  String mainUrlString = "${Utils.mainUrl}barang/daftar?idgudang=${Utils.idGudang}&halaman=0";
  String cariUrlString = "${Utils.mainUrl}barang/cari?idgudang=${Utils.idGudang}&cari=";
  String gambarUrlString = "${Utils.mainUrl}barang/download/";
  String imagePreview = "";
  String buttonText = "Ganti Gambar";

  Future<List<dynamic>> _getDataBarang({String keyword = "", String sort = ""}) async {
    Uri url = Uri.parse(mainUrlString);
    log(url.toString());
    if (keyword != "") {
      url = Uri.parse(cariUrlString + keyword);
    }

    if (sort != "") {
      url = Uri.parse(mainUrlString + "&sort=" + sort);
    }

    http.Response response = await http.get(url, headers: Utils.setHeader());
    String body = response.body;
    log(body);
    var jsonData = jsonDecode(body)["data"];
    return jsonData;
  }

  Future<dynamic> _postImage(String filePath, String id) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse("${Utils.mainUrl}barang/upload?idbarang=" + id));
    request.headers.addAll(Utils.setHeaderMultiPart());
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    http.StreamedResponse response = await request.send();
    Navigator.pop(context);
    return response.statusCode;
  }

  Future<dynamic> _postBarang(Map<String, Object> postBody, urlPath) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}barang/" + urlPath;
    Uri url = Uri.parse(urlString);
    http.Response response =
        await http.post(url, body: jsonEncode(postBody), headers: Utils.setHeader());
    String body = response.body;
    log(body);
    var jsonData = jsonDecode(body);
    Navigator.pop(context);
    return jsonData;
  }

  @override
  void initState() {
    _dataBarang = _getDataBarang();
    super.initState();
  }

  Image _imageSetter() {
    if (imagePreview.contains("http")) {
      return Image.network(
        headers: <String, String>{
          'Authorization': 'Bearer ' + Utils.token,
          'company-code': Utils.companyCode
        },
        imagePreview,
        height: 200,
      );
    }
    return Image.file(
      File(imagePreview),
      height: 200,
    );
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataBarang,
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext contex, int index) {
                dynamic dataList = snapshot.data![index];
                return Container(
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext content) {
                              buttonText = "Ganti Gambar";
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
                                              if (Utils.hakAkses["mobile_editdatamaster"] == 0) {
                                                return Utils.showMessage("Akses ditolak", context);
                                              }

                                              if (Navigator.canPop(context)) {
                                                Navigator.pop(context);
                                              }
                                              Navigator.push(context, MaterialPageRoute(
                                                builder: (context) {
                                                  return InputBarang(
                                                    idBarang: dataList["NOINDEX"],
                                                  );
                                                },
                                              ));
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
                                              if (Utils.hakAkses["mobile_editdatamaster"] == 0) {
                                                return Utils.showMessage("Akses ditolak", context);
                                              }

                                              bool isConfirm = await Utils.showConfirmMessage(
                                                  context, "Yakin ingin menghapus data ini ?");

                                              if (isConfirm) {
                                                Map<String, Object> mapData = {
                                                  "noindex": dataList["NOINDEX"].toString()
                                                };
                                                dynamic result =
                                                    await _postBarang(mapData, "delete");
                                                log(result.toString());
                                                setState(() {
                                                  _dataBarang = _getDataBarang();
                                                });
                                                if (Navigator.canPop(context)) {
                                                  Navigator.pop(context);
                                                }
                                              }
                                            },
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.black54,
                                            )),
                                        Text("Delete")
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              if (Navigator.canPop(context)) {
                                                Navigator.pop(context);
                                              }
                                              Navigator.push(context, MaterialPageRoute(
                                                builder: (context) {
                                                  return ListMutasi(
                                                    idBarang: dataList["NOINDEX"],
                                                  );
                                                },
                                              ));
                                            },
                                            icon: Icon(
                                              Icons.autorenew,
                                              color: Colors.black54,
                                            )),
                                        Text("Mutasi")
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              showModalBottomSheet(
                                                  context: context,
                                                  builder: (BuildContext content) {
                                                    imagePreview =
                                                        gambarUrlString + dataList["NOINDEX"];
                                                    return StatefulBuilder(
                                                        builder: (context, StateSetter setState) {
                                                      return Container(
                                                        padding: EdgeInsets.all(10),
                                                        height: 300,
                                                        child: Column(
                                                          children: [
                                                            _imageSetter(),
                                                            ElevatedButton.icon(
                                                                onPressed: () async {
                                                                  if (buttonText ==
                                                                      "Upload Gambar") {
                                                                    var result = await _postImage(
                                                                        imagePreview,
                                                                        dataList["NOINDEX"]);

                                                                    if (result == 200) {
                                                                      Utils.showMessage(
                                                                          "Upload Sukses", context);
                                                                    }
                                                                    return;
                                                                  }

                                                                  final image = await ImagePicker()
                                                                      .pickImage(
                                                                          source:
                                                                              ImageSource.gallery);

                                                                  if (image == null) {
                                                                    return;
                                                                  }
                                                                  setState(() {
                                                                    buttonText = "Upload Gambar";
                                                                    imagePreview = image.path;
                                                                  });
                                                                },
                                                                icon: Icon(Icons.image),
                                                                label: Text(buttonText))
                                                          ],
                                                        ),
                                                      );
                                                    });
                                                  });
                                            },
                                            icon: Icon(
                                              Icons.image,
                                              color: Colors.black54,
                                            )),
                                        Text("Gambar")
                                      ],
                                    )
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
                            //Utils.bagde(dataList["NAMA"].toString().substring(0, 1)),
                            Image.network(
                              gambarUrlString + "thumbnail/" + dataList["NOINDEX"],
                              headers: {
                                'Authorization': 'Bearer ' + Utils.token,
                                'company-code': Utils.companyCode
                              },
                              height: 70,
                              width: 80,
                              fit: BoxFit.contain,
                            ),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Utils.widgetSetter(() {
                                      double stokminimum = dataList["STOK_MINIMUM"];
                                      double stok = dataList["STOK"];
                                      if (stok <= stokminimum) {
                                        return Utils.labelSetter(dataList["NAMA"],
                                            bold: true, color: Colors.red);
                                      }
                                      return Utils.labelSetter(dataList["NAMA"], bold: true);
                                    }),
                                    (Utils.labelSetter(dataList["KODE"])),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Utils.labelSetter(
                                            Utils.formatNumber(dataList["HARGA_JUAL"]),
                                            bold: true),
                                        Utils.widgetSetter(() {
                                          if (Utils.isShowStockProgram == "0") {
                                            return Container();
                                          }
                                          return Utils.labelSetter("Stok : " +
                                              Utils.formatNumber(dataList["STOK"]) +
                                              " " +
                                              dataList["KODE_SATUAN"]);
                                        }),
                                      ],
                                    )
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
              });
        }
      }),
    );
  }

  Icon customIcon = Icon(Icons.search);
  Widget customSearchBar = Text("Data Barang");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Utils.widgetSetter(() {
        if (Utils.hakAkses["mobile_inputdatamaster"] == 0) {
          return Container();
        }
        return FloatingActionButton(
          child: Icon(
            Icons.add,
            size: 30,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return InputBarang(
                  idBarang: "",
                );
              },
            ));
          },
        );
      }),
      appBar: AppBar(
        title: customSearchBar,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  if (customIcon.icon == Icons.search) {
                    customIcon = Icon(Icons.clear);
                    customSearchBar = Utils.appBarSearch((keyword) {
                      setState(() {
                        _dataBarang = _getDataBarang(keyword: keyword);
                      });
                    }, hint: "Cari Barang");
                  } else {
                    customIcon = Icon(Icons.search);
                    customSearchBar = Text("Data Barang");
                  }
                });
              },
              icon: customIcon),
          IconButton(
              onPressed: () async {
                String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                    "#ff6666", "Cancel", true, ScanMode.BARCODE);

                if (barcodeScanRes == "-1") return;
                setState(() {
                  _dataBarang = _getDataBarang(keyword: barcodeScanRes);
                });
              },
              icon: Icon(Icons.qr_code_scanner)),
          IconButton(
              onPressed: () async {
                List<Map<String, String>> itemsValue = [
                  {"label": "Nama", "value": "nama"},
                  {"label": "Modal", "value": "modal"},
                  {"label": "Stok Minimum", "value": "stokminimum"},
                ];

                List<Widget> items = [];

                for (var d in itemsValue) {
                  Widget item = Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _dataBarang = _getDataBarang(sort: d["value"]!);
                          });
                          Navigator.pop(context);
                        },
                        child: ListTile(
                          leading: Icon(Icons.sort),
                          title: Utils.labelSetter(d["label"]!, size: 17),
                        ),
                      ),
                      Divider()
                    ],
                  );
                  items.add(item);
                }
                Utils.showListDialog("Urut Berdasarkan", items, context);
              },
              icon: Icon(Icons.sort_sharp))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.sync(() {
            setState(() {
              customIcon = Icon(Icons.search);
              customSearchBar = Text("Daftar Barang");
              _dataBarang = _getDataBarang();
            });
          });
        },
        child: Container(
          child: setListFutureBuilder(),
        ),
      ),
    );
  }
}
