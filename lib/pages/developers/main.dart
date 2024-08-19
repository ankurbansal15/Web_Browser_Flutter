import 'package:bromine_browser/pages/developers/javascript_console.dart';
import 'package:bromine_browser/pages/developers/network_info.dart';
import 'package:bromine_browser/pages/developers/storage_manager.dart';
import 'package:flutter/material.dart';

class DevelopersPage extends StatefulWidget {
  DevelopersPage({Key key}) : super(key: key);

  @override
  _DevelopersPageState createState() => _DevelopersPageState();
}

class _DevelopersPageState extends State<DevelopersPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: Color(0xFF4E5357),
            labelColor: Color(0xFF4E5357),
            onTap: (value) {
              FocusScope.of(context).unfocus();
            },
            tabs: [
              Tab(
                icon: Icon(
                  Icons.code,
                  color: Color(0xFF4E5357),
                ),
                text: "JavaScript Console",
              ),
              Tab(
                icon: Icon(
                  Icons.network_check,
                  color: Color(0xFF4E5357),
                ),
                text: "Network Info",
              ),
              Tab(
                icon: Icon(
                  Icons.storage,
                  color: Color(0xFF4E5357),
                ),
                text: "Storage Manager",
              ),
            ],
          ),
          title: Text(
            'Developers',
            style: TextStyle(
              color: Color(0xFF4E5357),
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Color(0xFF4E5357),
            ),
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            JavaScriptConsole(),
            NetworkInfo(),
            StorageManager(),
          ],
        ),
      ),
    );
  }
}
