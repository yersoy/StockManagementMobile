import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:RTMCount/ui/update-stock.dart';
import 'package:sweetalert/sweetalert.dart';
import 'package:RTMCount/helper/db-helper.dart';

class homePage extends StatefulWidget {
  homePage({Key key}) : super(key: key);

  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> queryRows;
  var barcode;
  int counter = 0;
  int max = 0;
  int maxx = 0;
  int myCounter = 0;
  double counterPercent = 0;
  bool scannable = true;
  bool ch = false;
  String _owner = "";
  String _countName = "";
  String _pName = "";
  Widget icon = Icon(FontAwesomeIcons.checkDouble);
  List data = new List();
  getThis() async {
    final prefs = await SharedPreferences.getInstance();
    var id = await prefs.getString('countid');
    _pName =
        jsonDecode(prefs.getString('user'))["Data"]["PersonalName"].toString();
    await Firestore.instance.document("counts/" + id).get().then((item) {
      setState(() {
        _owner = item["owner"];
        _countName = item["name"];
      });
    });
  }

  getMaxCount() async {
    final prefs = await SharedPreferences.getInstance();
    var id = await prefs.getString('countid');
    final QuerySnapshot result = await Firestore.instance
        .document("counts/" + id)
        .collection("data")
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;

    documents.forEach((data) {
      if (data["id"] > max) {
        max = data["id"];
      }
    });

    print(max);
  }

  getMyCount() async {
    final prefs = await SharedPreferences.getInstance();
    var id = await prefs.getString('countid');
    var uid =
        jsonDecode(await prefs.getString('user'))["Data"]["UserAccountId"];
    print(uid.toString() + " " + id.toString());
    QuerySnapshot result = await Firestore.instance
        .document("counts/" + id)
        .collection("users")
        .where("uid", isEqualTo: uid.toString())
        .limit(1)
        .getDocuments();
    List<DocumentSnapshot> documents = result.documents;

    documents.forEach((data) {
      setState(() {
        myCounter = data["totalcounts"];
      });
    });
  }

  setMyCount(myCount) async {
    final prefs = await SharedPreferences.getInstance();
    var id = await prefs.getString('countid');
    var uid =
        jsonDecode(await prefs.getString('user'))["Data"]["UserAccountId"];
    DocumentReference reff = Firestore.instance
        .document("counts/" + id + "/users/" + uid.toString());
    //Setting Data
    await reff.setData({
      'uid': uid.toString(),
      'totalcounts': myCounter + myCount,
    });
  }

  setHistory(countData) async {
    await getMaxCountHistory();
    final prefs = await SharedPreferences.getInstance();
    await setMyCount(countData);
    String uniqueCode = await prefs.getString('countid');
    DocumentReference reff = Firestore.instance
        .document("counts/" + uniqueCode + "/history/" + (maxx + 1).toString());

    //Setting Data
    await reff.setData({
      "id": maxx + 1,
      "desc": "$countData Adet ürün Güncellendi",
      "date": DateTime.now().toString(),
      "owner": _pName
    });
  }

  getMaxCountHistory() async {
    final prefs = await SharedPreferences.getInstance();
    var id = await prefs.getString('countid');
    final QuerySnapshot result = await Firestore.instance
        .document("counts/" + id)
        .collection("history")
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;

    documents.forEach((data) {
      if (data["id"] > maxx) {
        maxx = data["id"];
      }
    });
  }

  sendThem() async {
    if (queryRows.length > 0 && queryRows != null)
      for (var item in queryRows) {
        await addCount(item);
      }
    await setHistory(counter);
    await deleteAll();
    setState(() {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Row(
        children: <Widget>[
          Icon(FontAwesomeIcons.checkCircle),
          SizedBox(
            width: 30,
          ),
          Text("Stok Güncelleme İşlemi Başarılı !")
        ],
      )));
      icon = Icon(FontAwesomeIcons.checkDouble);
      counter = 0;
      counterPercent = 0;
    });
  }

  addCount(item) async {
    await getMaxCount();
    final prefs = await SharedPreferences.getInstance();

    String uniqueCode = await prefs.getString('countid');
    DocumentReference reff = Firestore.instance
        .document("counts/" + uniqueCode + "/data/" + (max + 1).toString());

    //Setting Data
    await reff.setData({
      "id": max + 1,
      "barcode": item["barcode"],
      "name": item["name"],
      "count": item["count"],
      "date": DateTime.now().toString(),
      "buyprice": item["buyprice"],
      "saleprice": item["saleprice"],
    });

    // Navigator.pushReplacementNamed(context, '/home');
  }

  Future scan() async {
    if (scannable) {
      try {
        String barcode = await BarcodeScanner.scan();
        var data = await DbHelper.instance.getBarcode(barcode);

        await DbHelper.instance.insert({
          "barcode": barcode,
          "name": data[0]["name"],
          "count": data[0]["flcount"],
          "date": DateTime.now().toString(),
          "buyprice": data[0]["buyprice"],
          "saleprice": data[0]["saleprice"],
        }).then((value) => loadTable());
        dynamic _data = await DbHelper.instance.getFiltered(barcode);

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => updateStock(
                    barcodeData: _data[0],
                  ),
              fullscreenDialog: true),
        ).then((value) => loadTable());
      } on PlatformException catch (e) {
        if (e.code == BarcodeScanner.CameraAccessDenied) {
          setState(() {
            this.barcode = 'The user did not grant the camera permission!';
          });
        } else {
          setState(() => this.barcode = 'Unknown error: $e');
        }
      } on FormatException {
        setState(() => this.barcode =
            'null (User returned using the "back"-button before scanning anything. Result)');
      } catch (e) {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } else {
      loadTable();
    }
  }

  void loadTable() async {
    queryRows = await DbHelper.instance.queryAll();
    print(queryRows);
    if (queryRows.length >= 10) {
      setState(() {
        scannable = false;
      });
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Stok Kalemlerinizi Sunucuya Aktarmanız Gerekiyor")));
    } else {
      setState(() {
        scannable = true;
      });
    }
    counter = queryRows.length;
    counterPercent = counter * 10.0;
    setState(() {
      queryRows;
    });
    await getMyCount();
  }

  void deleteAll() async {
    for (var item in queryRows) {
      await DbHelper.instance.delete(item["id"]);
    }
    await loadTable();
  }

  void delete(item) async {
    // queryRows.removeAt(int.parse(item["id"]));
    await DbHelper.instance.delete(item["id"]);

    Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(item['barcode'].toString() + " Başarıyla Silindi")));
    await loadTable();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadTable();
    getThis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              iconSize: 20,
              splashColor: Colors.white,
              icon: Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                scan();
              }),
        ],
        title: Center(
            child: Text(
          _countName,
          style: GoogleFonts.poppins(),
        )),
      ),
      floatingActionButton: FloatingActionButton(
        child: icon,
        onPressed: () {
          if (queryRows.length > 0) {
            if (ch == false) {
              setState(() {
                icon = CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
                );
                sendThem();
              });
            } else {
              setState(() {
                icon = Icon(FontAwesomeIcons.checkDouble);
                ch = false;
              });
            }
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Row(
              children: <Widget>[
                Icon(FontAwesomeIcons.times),
                SizedBox(
                  width: 30,
                ),
                Text("Sayım Listenizde Ürün & Hizmet Bulunamadı!")
              ],
            )));
          }
        },
      ),
      body: Column(children: <Widget>[
        if (ch == false)
          Container(
            width: MediaQuery.of(context).size.width,
            height: 140,
            padding: EdgeInsets.only(left: 6, bottom: 0, right: 6, top: 6),
            child: Card(
                color: Colors.blue[300],
                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 15),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "BEKLEYEN",
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            "AKTARILAN",
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            counter.toString(),
                            style: const TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            myCounter.toString(),
                            style: const TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 22,
                        child: RoundedProgressBar(
                            height: 10,
                            milliseconds: 1000,
                            percent: counterPercent,
                            theme: RoundedProgressBarTheme.yellow,
                            borderRadius: BorderRadius.circular(24)),
                      )
                    ],
                  ),
                )),
          ),
        if (queryRows != null)
          if (queryRows.length <= 0 && _countName != "")
            Container(
              padding: EdgeInsets.all(10),
              child: Card(
                child: ListTile(
                  leading: Icon(FontAwesomeIcons.boxOpen),
                  title: Text('Sayıma Devam $_pName'),
                  subtitle: Text('$_countName'),
                ),
              ),
            ),
        if (ch == false)
          Flexible(
            child: ListView(children: <Widget>[
              if (queryRows != null)
                for (var item in queryRows)
                  Dismissible(
                    // Show a red background as the item is swiped away.
                    background: Container(color: Colors.red),
                    key: Key(item["id"].toString()),
                    onDismissed: (direction) {
                      delete(item);
                    },
                    child: ListTile(
                      onTap: () {
                        Future.delayed(
                            const Duration(milliseconds: 200),
                            () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => updateStock(
                                              barcodeData: {
                                                "id": item["id"],
                                                "name": item["name"],
                                                "barcode": item["barcode"],
                                                "count": item["count"],
                                                "date": item["date"],
                                                "buyprice": item["buyprice"],
                                                "saleprice": item["saleprice"],
                                              },
                                            ),
                                        fullscreenDialog: true),
                                  ).then((value) => loadTable())
                                });
                      },
                      contentPadding:
                          EdgeInsets.only(left: 10, top: 3, right: 10),
                      leading: Text(
                        item["count"].toString(),
                        style: const TextStyle(
                            color: Colors.blueGrey, fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                      title: Text(item["barcode"].toString()),
                      subtitle: Text(item["name"].toString()),
                      trailing: Icon(FontAwesomeIcons.angleRight),
                    ),
                  ),
            ]),
          )
      ]),
    );
  }
}
