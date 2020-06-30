import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:RTMCount/helper/db-helper.dart';
import 'package:RTMCount/ui/secondpage.dart';
import 'history.dart';
import 'homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';
class ContainerPae extends StatefulWidget {
  ContainerPae({Key key}) : super(key: key);

  @override
  _ContainerPaeState createState() => _ContainerPaeState();
}

class _ContainerPaeState extends State<ContainerPae>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  TabController _controller;
  int idx;
   List<Map<String, dynamic>> queryRows;
  _handleTabChange() {
    // if a button was tapped, change the current index
    setState(() {
      // change the index
      _currentIndex = _controller.index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


 void deleteAll() async {
    queryRows = await DbHelper.instance.queryAll();
    for (var item in queryRows) {
      await DbHelper.instance.delete(item["id"]);
    }
  }
  logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    await deleteAll();
    Navigator.pushReplacementNamed(context, '/');
  }

  PageController _pageController;
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _controller = new TabController(length: 4, vsync: this);
    idx = 0;
    _controller.addListener(_handleTabChange);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
            _controller.index = index;
          });
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
              textAlign: TextAlign.center,
              title: Text('Stok'),
              activeColor: Colors.blue,
              inactiveColor: Colors.grey[800],
              icon: Icon(FontAwesomeIcons.barcode)),
          BottomNavyBarItem(
              textAlign: TextAlign.center,
              activeColor: Colors.blue,
              inactiveColor: Colors.grey[800],
              title: Text('Sorgula'),
              icon: Icon(FontAwesomeIcons.liraSign)),
          BottomNavyBarItem(
              textAlign: TextAlign.center,
              activeColor: Colors.blue,
              inactiveColor: Colors.grey[800],
              title: Text('Geçmiş'),
              icon: Icon(Icons.history)),
          BottomNavyBarItem(
              textAlign: TextAlign.center,
              activeColor: Colors.blue,
              inactiveColor: Colors.grey[800],
              title: Text('Ayarlar'),
              icon: Icon(FontAwesomeIcons.cog)),
        ],
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          new homePage(),
          new secondWidget(),
          new HistoryPage(),
          new Settings(),
        ],
      ),
    );
  }
}
