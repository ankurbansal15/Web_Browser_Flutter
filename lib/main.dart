import 'package:bromine_browser/browser.dart';
import 'package:bromine_browser/models/browser_model.dart';
import 'package:bromine_browser/models/webview_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );

  await Permission.camera.request();
  await Permission.microphone.request();
  await Permission.storage.request();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => WebViewModel(),
        ),
        ChangeNotifierProxyProvider<WebViewModel, BrowserModel>(
          update: (context, webViewModel, browserModel) {
            browserModel.setCurrentWebViewModel(webViewModel);
            return browserModel;
          },
          create: (BuildContext context) => BrowserModel(null),
        ),
      ],
      child: FlutterBrowserApp(),
    ),
  );
}

class FlutterBrowserApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Bromine Browser',
        theme: ThemeData(
          canvasColor: Colors.transparent,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => Browser(),
        });
  }
}
