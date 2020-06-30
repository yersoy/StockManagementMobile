
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui/login_page.dart';
import 'ui/container.dart';
import 'ui/choose.dart';
import 'ui/newcount.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RTM Stock App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        brightness: Brightness.light,
        primaryColor: Colors.grey[900],
        accentColor: Colors.black,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => ContainerPae(),
        '/choose':(context) => ChoosePage(),
        '/newcount': (context) => NewCount(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
 {




  @override
  Widget build(BuildContext context) {
  }
}
