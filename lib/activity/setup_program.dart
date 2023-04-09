import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mizanmobile/activity/utility/list_modal_form.dart';
import 'package:mizanmobile/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupProgram extends StatefulWidget {
  const SetupProgram({super.key});

  @override
  State<SetupProgram> createState() => _SetupProgramState();
}

class _SetupProgramState extends State<SetupProgram> {
  TextEditingController gudangCtrl = TextEditingController();
  String idGudang = "";
  TextEditingController deptCtrl = TextEditingController();
  String idDept = "";
  TextEditingController akunStokOpnameCtrl = TextEditingController();
  String idAkunStokOpname = "";

  _loadSetupProgram() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      idDept = sp.getString("defaultIdDept").toString();
      deptCtrl.text = sp.getString("defaultNamaDept").toString();
      idAkunStokOpname = sp.getString("defaultIdAkunStokOpname").toString();
      akunStokOpnameCtrl.text = sp.getString("defaultNamaAkunStokOpname").toString();
      idGudang = sp.getString("defaultIdGudang").toString();
      gudangCtrl.text = sp.getString("defaultNamaGudang").toString();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _loadSetupProgram();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Setup Program"),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.labelForm("Department"),
              Row(
                children: [
                  Expanded(
                      flex: 10,
                      child: TextField(
                        controller: deptCtrl,
                        enabled: false,
                      )),
                  Expanded(
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

                        idDept = popUpResult["NOINDEX"].toString();
                        deptCtrl.text = popUpResult["NAMA"];
                      },
                      icon: Icon(Icons.search),
                    ),
                  ),
                ],
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

                        idGudang = popUpResult["NOINDEX"];
                        gudangCtrl.text = popUpResult["NAMA"];
                      },
                      icon: Icon(Icons.search),
                    ),
                  ),
                ],
              ),
              Utils.labelForm("Akun Stok Opname"),
              Row(
                children: [
                  Expanded(
                      flex: 10,
                      child: TextField(
                        controller: akunStokOpnameCtrl,
                        enabled: false,
                      )),
                  Expanded(
                    child: IconButton(
                      onPressed: () async {
                        dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return ListModalForm(
                              type: "akun",
                            );
                          },
                        ));

                        if (popUpResult == null) return;

                        idAkunStokOpname = popUpResult["NOINDEX"];
                        akunStokOpnameCtrl.text = popUpResult["NAMA"];
                      },
                      icon: Icon(Icons.search),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async {
                      SharedPreferences sp = await SharedPreferences.getInstance();
                      sp.setString("defaultIdDept", idDept);
                      sp.setString("defaultNamaDept", deptCtrl.text);
                      sp.setString("defaultIdGudang", idGudang);
                      sp.setString("defaultNamaGudang", gudangCtrl.text);
                      sp.setString("defaultIdAkunStokOpname", idAkunStokOpname);
                      sp.setString("defaultNamaAkunStokOpname", akunStokOpnameCtrl.text);
                      setState(() {
                        Utils.idDept = idDept;
                        Utils.namaDept = deptCtrl.text;
                        Utils.idGudang = idGudang;
                        Utils.namaGudang = gudangCtrl.text;
                        Utils.idAkunStokOpname = idAkunStokOpname;
                        Utils.namaAkunStokOpname = akunStokOpnameCtrl.text;
                      });
                      sp.reload();
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text("Berhasil disimpan")));
                    },
                    child: Text("Simpan")),
              )
            ]),
      ),
    );
  }
}
