import 'dart:io';

import 'package:bromine_browser/dialogs/custom_popup_menu_item.dart';
import 'package:bromine_browser/models/browser_model.dart';
import 'package:bromine_browser/models/webview_model.dart';
import 'package:bromine_browser/pages/settings/cross_platform_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import 'android_settings.dart';
import 'ios_settings.dart';

class PopupSettingsMenuActions {
  static const String RESET_BROWSER_SETTINGS = "Reset Browser Settings";
  static const String RESET_WEBVIEW_SETTINGS = "Reset WebView Settings";

  static const List<String> choices = <String>[
    RESET_BROWSER_SETTINGS,
    RESET_WEBVIEW_SETTINGS,
  ];
}

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                color: Color(0xFF4E5357),
              ),
            ),
            bottom: TabBar(
                labelColor: Color(0xFF4E5357),
                indicatorColor: Color(0xFF4E5357),
                onTap: (value) {
                  FocusScope.of(context).unfocus();
                },
                tabs: [
                  Tab(
                    text: 'Common Settings',
                  ),
                  Tab(
                    text: 'Advanced Settings',
                  ),
                ]),
            title: const Text(
              "Settings",
              style: TextStyle(
                color: Color(0xFF4E5357),
              ),
            ),
            actions: <Widget>[
              PopupMenuButton<String>(
                color: Colors.white,
                icon: Icon(
                  Icons.more_vert,
                  color: Color(0xFF4E5357),
                ),
                onSelected: _popupMenuChoiceAction,
                itemBuilder: (context) {
                  var items = [
                    CustomPopupMenuItem<String>(
                      enabled: true,
                      value: PopupSettingsMenuActions.RESET_BROWSER_SETTINGS,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(PopupSettingsMenuActions
                                .RESET_BROWSER_SETTINGS),
                            Icon(
                              FlutterIcons.web_fou,
                              color: Colors.black,
                            )
                          ]),
                    ),
                    CustomPopupMenuItem<String>(
                      enabled: true,
                      value: PopupSettingsMenuActions.RESET_WEBVIEW_SETTINGS,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(PopupSettingsMenuActions
                                .RESET_WEBVIEW_SETTINGS),
                            Icon(
                              FlutterIcons.web_mdi,
                              color: Colors.black,
                            )
                          ]),
                    )
                  ];

                  return items;
                },
              )
            ],
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              CrossPlatformSettings(),
              (Platform.isAndroid
                  ? AndroidSettings()
                  : (Platform.isIOS ? IOSSettings() : null)),
            ],
          ),
        ));
  }

  void _popupMenuChoiceAction(String choice) async {
    switch (choice) {
      case PopupSettingsMenuActions.RESET_BROWSER_SETTINGS:
        var browserModel = Provider.of<BrowserModel>(context, listen: false);
        setState(() {
          browserModel.updateSettings(BrowserSettings());
          browserModel.save();
        });
        break;
      case PopupSettingsMenuActions.RESET_WEBVIEW_SETTINGS:
        var browserModel = Provider.of<BrowserModel>(context, listen: false);
        var settings = browserModel.getSettings();
        var currentWebViewModel =
            Provider.of<WebViewModel>(context, listen: false);
        var _webViewController = currentWebViewModel?.webViewController;
        await _webViewController.setOptions(
            options: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    debuggingEnabled: settings.debuggingEnabled,
                    incognito: currentWebViewModel.isIncognitoMode,
                    useOnDownloadStart: true,
                    useOnLoadResource: true),
                android: AndroidInAppWebViewOptions(safeBrowsingEnabled: true),
                ios: IOSInAppWebViewOptions(
                    allowsLinkPreview: false,
                    isFraudulentWebsiteWarningEnabled: true)));
        currentWebViewModel.options = await _webViewController.getOptions();
        browserModel.save();
        setState(() {});
        break;
    }
  }
}
