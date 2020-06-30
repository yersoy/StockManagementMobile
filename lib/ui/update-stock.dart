import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:RTMCount/helper/db-helper.dart';
import 'package:intl/intl.dart';

class updateStock extends StatefulWidget {
  final barcodeData;
  updateStock({Key key, @required this.barcodeData}) : super(key: key);

  @override
  _updateStockState createState() => _updateStockState();
}

class _updateStockState extends State<updateStock> {
  TextEditingController _itemCount = TextEditingController();
  TextEditingController _itemName = TextEditingController();
  TextEditingController _itemCode = TextEditingController();
  TextEditingController _itemSale = TextEditingController();
  TextEditingController _itemBuy = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  void showdialog(context) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Ürün Güncellemesi Hafızaya Kaydedildi'),
      action: SnackBarAction(
        textColor: Colors.blue,
        label: 'Geri Al',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    ));
  }

//   getThis(barcode) async {
// //   : [{id: 1, barcode: MK-2EL-EDGETECH01, name: TERMAL KAMERA ÇEKİM HİZMETİ, flcount: 15, date: 2020-06-30 23:02:26.936886, buyprice: 1500, saleprice: 0}]

//     var data = await DbHelper.instance.getBarcode("TMSCC1");
//     print(data[0]);
//     _itemName.text = data[0]["name"];
//     _itemCount.text = data[0]["flcount"].toString();
//     _itemSale.text = NumberFormat.currency(locale: 'eu', decimalDigits: 3).format(123456);
//     _itemBuy.text = data[0]["buyprice"].toString();
//   }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0)),
              child: Container(
                  child: SingleChildScrollView(
                      child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                      child: Text(
                    "#34654 - Ürünün Özellikleri",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ) // Your desired title
                      ),
                  const SizedBox(
                    height: 20,
                  ),
                  DataTable(columns: [
                    DataColumn(
                        label:
                            Text("Özellikler", style: GoogleFonts.poppins())),
                    DataColumn(
                        label: Text("Açıklaması", style: GoogleFonts.poppins()))
                  ], rows: [
                    DataRow(cells: [
                      DataCell(Text('Ram', style: GoogleFonts.poppins())),
                      DataCell(Text('16 GB DDR4', style: GoogleFonts.poppins()))
                    ]),
                    DataRow(cells: [
                      DataCell(
                          Text('Ekran Boyutu', style: GoogleFonts.poppins())),
                      DataCell(Text('17 İnch', style: GoogleFonts.poppins()))
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Ekran Çözünürlüğü',
                          style: GoogleFonts.poppins())),
                      DataCell(Text('1920x1080 Full HD',
                          style: GoogleFonts.poppins()))
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Pil', style: GoogleFonts.poppins())),
                      DataCell(Text('5000 mah 3 hücreli lipo pil',
                          style: GoogleFonts.poppins()))
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Garanti', style: GoogleFonts.poppins())),
                      DataCell(Text('2 Yıl Tam Garanti',
                          style: GoogleFonts.poppins()))
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Ram', style: GoogleFonts.poppins())),
                      DataCell(Text('16 GB DDR4', style: GoogleFonts.poppins()))
                    ]),
                    DataRow(cells: [
                      DataCell(
                          Text('Ekran Boyutu', style: GoogleFonts.poppins())),
                      DataCell(Text('17 İnch', style: GoogleFonts.poppins()))
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Ekran Çözünürlüğü',
                          style: GoogleFonts.poppins())),
                      DataCell(Text('1920x1080 Full HD',
                          style: GoogleFonts.poppins()))
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Pil', style: GoogleFonts.poppins())),
                      DataCell(Text('5000 mah 3 hücreli lipo pil',
                          style: GoogleFonts.poppins()))
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Garanti', style: GoogleFonts.poppins())),
                      DataCell(Text('2 Yıl Tam Garanti',
                          style: GoogleFonts.poppins()))
                    ]),
                  ]),
                ],
              ))));
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _itemName.text = widget.barcodeData["name"].toString();
    _itemCount.text = widget.barcodeData["count"].toString();
    _itemCode.text = widget.barcodeData["barcode"].toString();
    _itemSale.text = widget.barcodeData["saleprice"].toString();
    _itemBuy.text = widget.barcodeData["buyprice"].toString();
  }

  void updateTable() async {
    await DbHelper.instance.update({
      "id": widget.barcodeData["id"],
      "name": _itemName.text,
      "count": int.parse(_itemCount.text),
      "date": DateTime.now().toString(),
      "saleprice": int.parse(_itemSale.text),
      "buyprice": int.parse(_itemBuy.text)
    });
    await showdialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            floating: false,
            pinned: true,
            leading: IconButton(
              padding: EdgeInsets.only(top: 3),
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close, color: Colors.white, size: 28),
            ),
            expandedHeight: 150.0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 55, bottom: 13),
              title: Text('Ürün Detayları',
                  style: GoogleFonts.poppins(fontSize: 18)),
              background: Image.network(
                'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80', // <===   Add your own image to assets or use a .network image instead.
                fit: BoxFit.cover,
              ),
            ),
            actions: <Widget>[
              // IconButton(
              //   icon: Icon(FontAwesomeIcons.info),
              //   onPressed: () {
              //     _settingModalBottomSheet(context);
              //   },
              // ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.save),
                tooltip: 'Add new entry',
                onPressed: () => updateTable(),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                SingleChildScrollView(
                  child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(children: <Widget>[
                        TextField(
                          keyboardType: TextInputType.text,
                          controller: _itemCode,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                backgroundColor: Colors.white, height: 1),
                            border: OutlineInputBorder(),
                            labelText: 'Ürün Kodu',
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          keyboardType: TextInputType.number,
                          controller: _itemCount,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                backgroundColor: Colors.white, height: 1),
                            border: OutlineInputBorder(),
                            labelText: "Sayım Sonucu Stok",
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          keyboardType: TextInputType.text,
                          controller: _itemName,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                backgroundColor: Colors.white, height: 1),
                            border: OutlineInputBorder(),
                            labelText: 'Ürün Adı',
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          keyboardType: TextInputType.text,
                          controller: _itemSale,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                backgroundColor: Colors.white, height: 1),
                            border: OutlineInputBorder(),
                            labelText: 'Alış Fiyatı',
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),

                        TextField(
                          keyboardType: TextInputType.text,
                          controller: _itemBuy,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                backgroundColor: Colors.white, height: 1),
                            border: OutlineInputBorder(),
                            labelText: 'Satış Fiyatı',
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),

                        //  RaisedButton(
                        //   onPressed: () { Navigator.pop(context);},
                        //   textColor: Colors.white,
                        //   padding: const EdgeInsets.all(0.0),
                        //   child: Container(
                        //     width: double.infinity,
                        //     decoration: const BoxDecoration(
                        //       gradient: LinearGradient(
                        //         colors: <Color>[
                        //           Color(0xFF0D47A1),
                        //           Color(0xFF1976D2),
                        //           Color(0xFF42A5F5),
                        //         ],
                        //       ),
                        //     ),
                        //     padding: const EdgeInsets.all(10.0),
                        //     child: const Text(
                        //       'Stok Sayımı Kaydet',
                        //       style: TextStyle(fontSize: 20),
                        //       textAlign: TextAlign.center,
                        //     ),
                        //   ),
                        // ),
                      ])),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
