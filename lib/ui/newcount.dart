import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NewCount extends StatefulWidget {
  NewCount({Key key}) : super(key: key);

  @override
  _NewCountState createState() => _NewCountState();
}

class _NewCountState extends State<NewCount> {
  final databaseReference = Firestore.instance;
  final _cName = TextEditingController();
  final _cPass = TextEditingController();
  final _cCompany = TextEditingController();
  int max = 0;
  String username = "";
  void readServer() async {
    final prefs = await SharedPreferences.getInstance();

// Try reading data from the counter key. If it doesn't exist, return string.
    setState(() {
      username = jsonDecode(prefs.getString('user'))["Data"]["PersonalName"];
    });
  }

  getMaxCount() async {
    final QuerySnapshot result =
        await Firestore.instance.collection('counts').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;

    documents.forEach((data) {
      if (data["id"] > max) {
        max = data["id"];
      }
    });

    print(max);
  }

  addCount() async {
    getMaxCount();
    String uniqueCode = (max + 1).toString();
    DocumentReference reff =
    Firestore.instance.document("counts/" + uniqueCode);
    //Setting Data
    await reff.setData({
      'id': max + 1,
      'name': _cName.text,
      'company': _cCompany.text,
      'owner': username,
      'password': int.parse(_cPass.text),
      'startdate': new DateTime.now(),
      'enddate': new DateTime.now(),
      'status': true
    });
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMaxCount();
    readServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: <Widget>[
          // IconButton(
          //     iconSize: 20,
          //     splashColor: Colors.white,
          //     icon: Icon(
          //       Icons.add,
          //       color: Colors.white,
          //       size: 30,
          //     ),
          //     onPressed: () {
          //       // scan();
          //     })
        ],
        title: Center(
            child: Text("Stok Sayımı Oluştur", style: GoogleFonts.poppins())),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(children: <Widget>[
          TextFormField(
            controller: _cName,
            decoration: const InputDecoration(
              icon: const Icon(FontAwesomeIcons.newspaper),
              hintText: 'Sayıma Bir İsim Veriniz',
              labelText: 'Sayım İsmi',
            ),
            keyboardType: TextInputType.text,
          ),
          TextFormField(
            controller: _cCompany,
            decoration: const InputDecoration(
              icon: const Icon(FontAwesomeIcons.building),
              hintText: 'Firma Adını Giriniz',
              labelText: 'Firma Adı',
            ),
            keyboardType: TextInputType.text,
          ),
          TextFormField(
              controller: _cPass,
              decoration: const InputDecoration(
                icon: const Icon(FontAwesomeIcons.key),
                hintText: 'Sayım Şifresi Giriniz',
                labelText: 'Sayım Şifresi',
              ),
              keyboardType: TextInputType.number),
          SizedBox(
            height: 20,
          ),
          new FlatButton(
            color: Colors.blue,
            textColor: Colors.white,
            disabledColor: Colors.grey,
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Colors.blueAccent,
            onPressed: () {
              addCount();
            },
            child: Text(
              "           Sayımı Başlat           ",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        ]),
      )),
    );
  }
}
