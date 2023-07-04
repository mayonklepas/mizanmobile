import 'dart:convert';
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

  String mainUrlString = "${Utils.mainUrl}barang/daftar?idgudang=1-1&halaman=0";
  String cariUrlString = "${Utils.mainUrl}barang/cari?idgudang=1-1&cari=";
  String gambarUrlString = "${Utils.mainUrl}barang/download/";
  String imagePreview = "";
  String buttonText = "Ganti Gambar";

  Future<List<dynamic>> _getDataBarang({String keyword = ""}) async {
    Uri url = Uri.parse(mainUrlString);
    if (keyword != null && keyword != "") {
      url = Uri.parse(cariUrlString + keyword);
    }
    http.Response response = await http.get(url, headers: Utils.setHeader());
    print(jsonDecode(response.body));
    var jsonData = jsonDecode(response.body)["data"];
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

  @override
  void initState() {
    _dataBarang = _getDataBarang();
    super.initState();
  }

  Image _imageSetter() {
    if (imagePreview.contains("http")) {
      return Image.network(
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
                                            onPressed: () {},
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
                                    Utils.labelSetter(dataList["NAMA"], bold: true),
                                    (Utils.labelSetter(dataList["KODE"])),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Utils.labelSetter(Utils.formatRp(dataList["HARGA_JUAL"]),
                                            bold: true),
                                        Utils.labelSetter("Stok : " +
                                            Utils.formatNumber(dataList["STOK"]) +
                                            " " +
                                            dataList["KODE_SATUAN"]),
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
      floatingActionButton: FloatingActionButton(
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
      ),
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
              icon: Icon(Icons.qr_code_scanner))
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
