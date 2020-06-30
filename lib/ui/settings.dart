import 'dart:convert';

import 'package:RTMCount/helper/db-helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _noCatalog = true;
  String idT = "";
  int servercountid;
  List<dynamic> fakeData = List<dynamic>();
  String password = "";
  bool trans = false;
  bool upload = false;

  List<Map<String, dynamic>> queryRows;
  getCountData() async {
    final prefs = await SharedPreferences.getInstance();
    var id = await prefs.getString('countid');
    await Firestore.instance
        .collection('counts')
        .document(id)
        .get()
        .then((DocumentSnapshot ds) {
      print(ds.data);
      idT = ds.data["id"].toString();
      password = ds.data["password"].toString();
      servercountid = ds.data["servercountid"];
    });
    setState(() {
      id;
      password;
    });
  }

//  "StProductCode": "MK-2EL-EDGETECH01",
//                 "StManufacturerCode": "üretici kodu",
//                 "StProductname": "TERMAL KAMERA ÇEKİM HİZMETİ",
//                 "FlSalePrice": 0,
//                 "StSaleCurrencySymbol": "TL",
//                 "FlStockQuantity": 15,
//                 "FlBuyPrice": 1500,
//(id INTEGER primary key autoincrement, barcode  String , name String, count INTEGER,date String,expln String,buyprice INTEGER , saleprice INTEGER)
  downloadData() async {
    final prefs = await SharedPreferences.getInstance();
    String server = await prefs.getString('server');
    setState(() {
      trans = true;
    });

    await http.get('$server/api/MStock/MStockCatalog').then((value) {
      fakeData = json.decode(value.body)["Data"]["LastProductList"];
    });
    Database db = await DbHelper.instance.database;
    var batch = await db.batch();
    fakeData.forEach((element) async {
      Map<String, dynamic> dynamicData = {
        "barcode": element["StProductCode"].toString(),
        "name": element["StProductname"].toString(),
        "flcount": element["FlStockQuantity"],
        "date": DateTime.now().toString(),
        "buyprice": element["FlBuyPrice"],
        "saleprice": element["FlSalePrice"]
      };
      await batch.insert("catalog", dynamicData);
    });
    await batch.commit(noResult: true);

    Scaffold.of(context).showSnackBar(SnackBar(
        content:
            Text("Katalog Datası Başarıyla İndirildi ve Cihaza Kaydedildi")));
    setState(() {
      trans = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCountData();
  }

  closeCount() async {
    setState(() {
      upload = true;
    });
    final prefs = await SharedPreferences.getInstance();
    var id = await prefs.getString('countid');
    String server = await prefs.getString('server');
    var dataS = jsonDecode(await prefs.getString('user'));
    await Firestore.instance
        .collection('counts/' + id + '/data')
        .getDocuments()
        .then((data) {
      var kData = data.documents.toList();
      kData.forEach((element) async {
        await http
            .post(
              '$server/api/MStock/MAddProduct',
              headers: <String, String>{
                'Content-Type': 'application/json',
              },
              body: jsonEncode(<String, dynamic>{
                "UserAccountId": dataS["Data"]["UserAccountId"],
                "UserGroupId": dataS["Data"]["UserGroupId"],
                "PersonalId": dataS["Data"]["PersonalId"],
                "Email": dataS["Data"]["Email"],
                "PersonalName": dataS["Data"]["PersonalName"],
                "SearchText": "",
                "hdnStockId": 0,
                "aStockProduct": {
                  "InStockActivityId": 0,
                  "InStockId": servercountid,
                  "InCustomerId": 11873,
                  "InProductId": 0,
                  "StProductName": element.data["name"],
                  "StProductCode": element.data["barcode"],
                  "FlQuantity": element.data["count"],
                  "StStockPrice": element.data["buyprice"],
                  "FlTaxRate": 18,
                  "InWarehouseId": 1,
                  "BoTaxIncluded": false,
                  "InStockMoneyType": 0,
                  "InStockActivityType": 1,
                  "StOrderProductUniqID": 0
                }
              }),
            )
            .then((value) => print(value.body));
      });
      print("Başarılı");
    });
    setState(() {
      upload = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Center(child: Text("Ayarlar")),
      ),
      body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(0),
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: SettingsList(
                  sections: [
                    SettingsSection(
                      title: 'Ürün Katalog Ayarları',
                      tiles: [
                        SettingsTile(
                          title: 'Örnek Katalog İndir',
                          subtitle: 'Yüklenecek Katalog Dosyasının Örneği',
                          leading: Icon(FontAwesomeIcons.file),
                          onTap: () {},
                        ),
                        SettingsTile(
                          title: 'Katalog Excel Yükle',
                          subtitle:
                              'Excel Dosyası Yükleyerek Ürünlerinizi Kaydedin',
                          leading: Icon(FontAwesomeIcons.fileExcel),
                          onTap: () {},
                        ),
                        SettingsTile(
                          title: 'Katalog Datasını Sunucudan İndir',
                          leading: trans == false
                              ? Icon(FontAwesomeIcons.download)
                              : CircularProgressIndicator(),
                          onTap: () {
                            downloadData();
                          },
                        ),
                        SettingsTile.switchTile(
                          title: 'Katalog Datası Kullanma',
                          leading: Icon(FontAwesomeIcons.book),
                          switchValue: _noCatalog,
                          onToggle: (bool value) {
                            setState(() {
                              _noCatalog = value;
                            });
                          },
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: 'Sayım ID ve Şifresi',
                      tiles: [
                        SettingsTile(
                          title: idT,
                          leading: Icon(FontAwesomeIcons.hashtag),
                          onTap: () {},
                        ),
                        SettingsTile(
                          title: password,
                          leading: Icon(FontAwesomeIcons.lock),
                          onTap: () {},
                        ),
                        SettingsTile(
                          title: 'Sayımı Bitir',
                          leading: upload == false
                              ? Icon(FontAwesomeIcons.signOutAlt)
                              : CircularProgressIndicator(),
                          onTap: () {
                            closeCount();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ))),
    );
  }
}
