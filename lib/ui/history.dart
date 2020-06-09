import 'package:google_fonts/google_fonts.dart';
import 'package:timeline/timeline.dart';
import 'package:flutter/material.dart';
import 'package:timeline/model/timeline_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({Key key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<TimelineModel> list = [
  
  ];
  getMaxCount() async {
    final prefs = await SharedPreferences.getInstance();
    var id = await prefs.getString('countid');
    final QuerySnapshot result = await Firestore.instance
        .document("counts/" + id)
        .collection("history")
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;

    documents.forEach((data) {
      setState(() {
        list.add(TimelineModel(
            id: data["id"].toString(),
            description:data["desc"].toString(),
            title:data["owner"].toString()));
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMaxCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Center(
            child: Text(
          "Stok Hareketleri",
          style: GoogleFonts.poppins(),
        )),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SizedBox(
            height: 15,
          ),
          Flexible(
            child: TimelineComponent(
              timelineList: list,
              lineColor:
                  Colors.blue, // Defaults to accent color if not provided
              backgroundColor:
                  Colors.white, // Defaults to white if not provided
              headingColor: Colors.black, // Defaults to black if not provided
              descriptionColor: Colors.grey, // Defaults to grey if not provided
            ),
          )
        ],
      ),
    );
  }
}
