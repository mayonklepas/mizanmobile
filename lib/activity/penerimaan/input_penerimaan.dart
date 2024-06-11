import 'package:flutter/material.dart';
import 'package:mizanmobile/activity/utility/list_modal_form.dart';
import 'package:mizanmobile/database_helper.dart';
import 'package:mizanmobile/utils.dart';

class InputPenerimaan extends StatefulWidget {
  final String idTransaksi;
  const InputPenerimaan({super.key, this.idTransaksi = ""});

  @override
  State<InputPenerimaan> createState() => _InputPenerimaanState();
}

class _InputPenerimaanState extends State<InputPenerimaan> {
  List<dynamic> dataListview = [];

  FocusNode searchBarFocus = FocusNode();
  TextEditingController searchBarctrl = TextEditingController();

  //global var setter
  Map<String, String> suplierData = {"id": "", "code": "", "name": ""};
  Map<String, String> orderData = {"id": "", "code": "", "name": ""};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Utils.widgetSetter(() {
          if (Utils.isPdtMode == "0") {
            return Utils.appBarSearchStatic(() async {},
                focus: false, readOnly: true);
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
                  onSubmitted: (keyword) async {}));
        }),
        actions: [
          IconButton(
              onPressed: () async {},
              icon: Icon(Icons.qr_code_scanner_rounded)),
          IconButton(onPressed: () {}, icon: Icon(Icons.note_add_rounded))
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
                      Expanded(flex: 1, child: Text("Suplier")),
                      Expanded(
                          flex: 1,
                          child: Text(
                            suplierData["name"]??"",
                            textAlign: TextAlign.end,
                          )),
                      Expanded(
                          flex: 0,
                          child: IconButton(
                              alignment: Alignment.centerRight,
                              onPressed: () async {
                                dynamic popUpResult = await Navigator.push(
                                    context, MaterialPageRoute(
                                  builder: (context) {
                                    return ListModalForm(
                                      type: "suplier",
                                    );
                                  },
                                ));

                                if (popUpResult == null) return;

                                setState(() {
                                  suplierData["id"] = popUpResult["NOINDEX"];
                                  suplierData["code"] = popUpResult["KODE"];
                                  suplierData["name"] = popUpResult["NAMA"];
                                });

                              },
                              icon: Icon(Icons.search)))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 1, child: Text("No Order")),
                      Expanded(
                          flex: 1,
                          child: Text(
                            orderData["name"]??"",
                            textAlign: TextAlign.end,
                          )),
                      Expanded(
                          flex: 0,
                          child: IconButton(
                              alignment: Alignment.centerRight,
                              onPressed: () async {
                                 dynamic popUpResult = await Navigator.push(
                                    context, MaterialPageRoute(
                                  builder: (context) {
                                    return ListModalForm(
                                      type: "penerimaanbarang",
                                      idSuplier: suplierData["id"]!,
                                    );
                                  },
                                ));

                                if (popUpResult == null) return;

                                setState(() {
                                  orderData["id"] = popUpResult["NOINDEX"];
                                  orderData["code"] = popUpResult["KODE"];
                                  orderData["name"] = popUpResult["NAMA"];
                                });
                              },
                              icon: Icon(Icons.search)))
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
              flex: 1,
              child: ListView.builder(
                  itemCount: dataListview.length,
                  itemBuilder: (BuildContext context, int index) {
                    dynamic data = dataListview[index];
                    return Container(
                      child: Card(
                        child: InkWell(
                          onTap: () {},
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Utils.labelSetter(data["NAMA"],
                                            bold: true),
                                        Utils.labelSetter(data["KODE"]),
                                        Utils.labelSetter(
                                            Utils.formatNumber(data["HARGA"]),
                                            bold: true),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Utils.labelSetter("Jumlah : " +
                                                Utils.formatNumber(
                                                    data["QTY"]) +
                                                " " +
                                                data["SATUAN"]),
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
                      width: double.maxFinite,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () async {},
                        child: Utils.labelSetter("SIMPAN", color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
