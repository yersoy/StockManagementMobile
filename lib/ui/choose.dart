import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sweetalert/sweetalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/services.dart';

class ChoosePage extends StatefulWidget {
  ChoosePage({Key key}) : super(key: key);

  @override
  _ChoosePageState createState() => _ChoosePageState();
}

class _ChoosePageState extends State<ChoosePage> {
  String username = " ";
  bool bb = false;
  final _countid = TextEditingController();
  void readServer() async {
    final prefs = await SharedPreferences.getInstance();

// Try reading data from the counter key. If it doesn't exist, return string.
    setState(() {
      username = jsonDecode(prefs.getString('user'))["Data"]["PersonalName"];
    });
  }

  setid(id) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('countid', id);
    if (id != null && id != "") {
      // SweetAlert.show(context,
      //     title: doc["name"] + ' Bağlanıldı',
      //     subtitle: " İsimli  Sayıma Başarıyla Bağlandınız.",
      //     style: SweetAlertStyle.success, onPress: (bool isConfirm) {
      //   Navigator.pushReplacementNamed(context, '/home');
      // }, showCancelButton: true);
      print("başarılı setid");
      Navigator.pushReplacementNamed(context, '/home');
    }
    setState(() {
      bb = true;
    });
  }

  setCount() async {
    try {
      // await Firestore.instance
      //     .collection('counts')
      //     .where("id", isEqualTo: int.parse(_countid.text))
      //     .where("password", isEqualTo: int.parse(_countpass.text))
      //     .limit(1)
      //     .snapshots()
      //     .listen((data) => data.documents.forEach((doc) {
      //           print(doc.documentID);
      //           setid(doc.documentID);
      //         }));
      Firestore.instance
          .collection('counts')
          .document(_countid.text)
          .get()
          .then((DocumentSnapshot ds) {
        print(ds.documentID);
        if (ds.data["password"] == int.parse(_countpass.text)) {
          print(ds.documentID);
          setid(ds.documentID);
        } else {
          SweetAlert.show(context,
              title: "Sayım Bulunamadı",
              subtitle: "Lütfen Tekrar Deneyiniz",
              style: SweetAlertStyle.error);
        }
      }).catchError((onError) {
        SweetAlert.show(context,
            title: onError.toString(),
            subtitle: "Lütfen Tekrar Deneyiniz",
            style: SweetAlertStyle.error);
      });
    } on Exception catch (e) {
      SweetAlert.show(context,
          title: "Bir Hata Oluştu",
          subtitle: "Lütfen Tekrar Deneyiniz",
          style: SweetAlertStyle.error);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readServer();
  }

  final _countpass = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 100,
              ),
              Text("Hoşgeldiniz\n" + username,
                  style: GoogleFonts.poppins(
                      fontSize: 55, fontWeight: FontWeight.w600)),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.only(left: 30, right: 30),
                height: MediaQuery.of(context).size.height,
                child: ListView(
                  children: <Widget>[
                    Container(
                      child: Column(children: <Widget>[
                        TextField(
                          keyboardType: TextInputType.number,
                          controller: _countid,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Sayım #ID'si",
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          keyboardType: TextInputType.number,
                          controller: _countpass,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Şifresi",
                          ),
                        )
                      ]),
                    ),
                    ListTile(
                      leading: Icon(FontAwesomeIcons.chevronRight),
                      title: Text('Sayıma Katıl', style: GoogleFonts.poppins()),
                      onTap: () {
                        setCount();
                      },
                    ),
                    ListTile(
                      leading: Icon(FontAwesomeIcons.plus),
                      title:
                          Text('Sayım Oluştur', style: GoogleFonts.poppins()),
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/newcount');
                      },
                    ),
                  ],
                ),
              )
            ]),
      ),
    ));
  }
}

// Navigator.pushReplacementNamed(context, '/home');
void _settingModalBottomSheet(context) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: new Wrap(
            children: <Widget>[
              new ListTile(
                  leading: Icon(FontAwesomeIcons.square),
                  title: Text("Sayım ID'si Giriniz"),
                  onTap: () => {}),
            ],
          ),
        );
      });
}
