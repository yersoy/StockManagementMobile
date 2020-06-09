import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
class secondWidget extends StatefulWidget {
  secondWidget({Key key}) : super(key: key);

  @override
  _secondWidgetState createState() => _secondWidgetState();
}

class _secondWidgetState extends State<secondWidget> {
  String barcode = "";
  bool show = false;
  Future scan() async {
    try {
      barcode = await BarcodeScanner.scan();
      setState(() {
        show = true;
      });
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
          title: Center(child: Text("Ürün Sorgula",style: GoogleFonts.poppins())),
        ),
        body: Container(
            padding: EdgeInsets.all(7),
            child: show == false
                ? new GestureDetector(
                    onTap: () {
                      scan();
                    },
                    child: Center(
                        child: Icon(
                      FontAwesomeIcons.search,
                      size: 150,
                    )))
                : Column(children: <Widget>[
                    Card(
                      color: Colors.blueAccent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const ListTile(
                            leading: Icon(
                              FontAwesomeIcons.barcode,
                              size: 50,
                              color: Colors.white,
                            ),
                            title: Text(
                              'Cam Temizleyici Sprey 1000 ml',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              '#45436',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      color: Colors.blueGrey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const ListTile(
                            leading: Icon(
                              FontAwesomeIcons.boxes,
                              size: 40,
                              color: Colors.white,
                            ),
                            title: Text(
                              'Toplam 56 Adet Depoda Var',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              'Güncel Stok Bilgisi',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      color: Colors.blueGrey[300],
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const ListTile(
                            leading: Icon(
                              FontAwesomeIcons.moneyBillAlt,
                              size: 35,
                              color: Colors.white,
                            ),
                            title: Text(
                              'Alış Fiyatı : 18.00 ₺',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900),
                            ),
                            // subtitle: Text('Toplam 56 Adet Depoda Var',style: TextStyle(color: Colors.white),),
                          ),
                        ],
                      ),
                    ),
                      Card(
                      color: Colors.blueGrey[300],
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const ListTile(
                            leading: Icon(
                              FontAwesomeIcons.checkCircle,
                              size: 40,
                              color: Colors.white,
                            ),
                            title: Text(
                              'Satış Fiyatı : 18.00 ₺',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900),
                            ),
                            // subtitle: Text('Toplam 56 Adet Depoda Var',style: TextStyle(color: Colors.white),),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const ListTile(
                            leading:
                                Icon(FontAwesomeIcons.angleRight, size: 35),
                            title: Text(
                              '1. Fiyat : 24.96 ₺',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const ListTile(
                            leading:
                                Icon(FontAwesomeIcons.angleRight, size: 35),
                            title: Text(
                              '2. Fiyat : 22.00 ₺',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const ListTile(
                            leading:
                                Icon(FontAwesomeIcons.angleRight, size: 35),
                            title: Text(
                              '3. Fiyat : 20.00 ₺',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ])));
  }
}
