import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mizanmobile/activity/utility/list_modal_barang.dart';
import 'package:mizanmobile/utils.dart';

class InputPenjualan extends StatefulWidget {
  final String idTransaksi;
  const InputPenjualan({Key? key, this.idTransaksi = ""}) : super(key: key);

  @override
  State<InputPenjualan> createState() => _InputPenjualanState();
}

class _InputPenjualanState extends State<InputPenjualan> {
  List<dynamic> dataList = [];

  dynamic _getDetailPenjualan() {
    dynamic map = <String, Object>{
      "listData": [
        {
          <String, Object>{
            "noindex": "123",
            "nama": "bakso",
            "kode": "12345",
            "satuan": "pcs",
            "jumlah": 1,
            "harga": 120000,
          }
        }
      ]
    };

    return map["listData"];
  }

  @override
  void initState() {
    // TODO: implement initState
    _loadData(idTransaksi: widget.idTransaksi);
    super.initState();
  }

  _loadData({String idTransaksi = ""}) async {
    if (idTransaksi == "") {
    } else {
      dataList = await _getDetailPenjualan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Utils.appBarSearch((keyword) async {
            dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return ListModalBarang(keyword: keyword);
              },
            ));

            if (popUpResult == null) return;

            setState(() {
              dataList.add(<String, Object>{
                "noindex": popUpResult["NOINDEX"],
                "nama": popUpResult["NAMA"],
                "kode": popUpResult["KODE"],
                "satuan": popUpResult["KODE_SATUAN"],
                "jumlah": 1,
                "harga": popUpResult["HARGA_JUAL"],
              });
            });
          }),
          actions: [
            IconButton(
                onPressed: () async {
                  String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                      "#ff6666", "Cancel", true, ScanMode.BARCODE);

                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(barcodeScanRes)));
                },
                icon: Icon(Icons.qr_code_scanner_rounded)),
            IconButton(onPressed: () {}, icon: Icon(Icons.mode_edit_outlined))
          ],
        ),
        body: Column(
          children: [
            Expanded(flex: 0, child: Container()),
            Expanded(
                child: ListView.builder(
                    itemCount: dataList.length,
                    itemBuilder: (BuildContext context, int index) {
                      dynamic data = dataList[index];
                      return Container(
                        child: Card(
                          child: InkWell(
                            onTap: () {
                              TextEditingController jumlahCtrl = TextEditingController();
                              TextEditingController diskonCtrl = TextEditingController();
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return FractionallySizedBox(
                                      heightFactor: 0.6,
                                      child: Container(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Utils.labelSetter("Edit Jumlah", size: 25),
                                            Padding(padding: EdgeInsets.all(10)),
                                            Utils.labelForm("Jumlah"),
                                            TextField(
                                              controller: jumlahCtrl,
                                            ),
                                            Utils.labelForm("Diskon"),
                                            TextField(
                                              controller: diskonCtrl,
                                            ),
                                            Padding(padding: EdgeInsets.all(5)),
                                            SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                    onPressed: () {}, child: Text("Simpan")))
                                          ],
                                        ),
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
                                          Utils.labelSetter(data["nama"], bold: true),
                                          (Utils.labelSetter(data["kode"])),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Utils.labelSetter(Utils.formatRp(data["harga"]),
                                                  bold: true),
                                              Utils.labelSetter("jumlah : " +
                                                  Utils.formatNumber(data["jumlah"]) +
                                                  " " +
                                                  data["satuan"]),
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
                    })),
            Expanded(
                flex: 0,
                child: Container(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text("Simpan"),
                    ),
                  ),
                )),
          ],
        ));
  }
}
