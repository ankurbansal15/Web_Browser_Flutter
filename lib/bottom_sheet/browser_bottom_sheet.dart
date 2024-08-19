import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:bromine_browser/constants/size_config.dart';
import 'package:bromine_browser/constants/size_manager.dart';
import 'package:bromine_browser/dialogs/custom_popup_dialog.dart';
import 'package:bromine_browser/models/browser_model.dart';
import 'package:bromine_browser/models/favorite_model.dart';
import 'package:bromine_browser/models/web_archive_model.dart';
import 'package:bromine_browser/models/webview_model.dart';
import 'package:bromine_browser/pages/developers/main.dart';
import 'package:bromine_browser/pages/settings/main.dart';
import 'package:bromine_browser/utility/features.dart';
import 'package:bromine_browser/utility/value_to_url.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../browser.dart';

class BrowserBottomSheet extends StatefulWidget {
  @override
  _BrowserBottomSheetState createState() => _BrowserBottomSheetState();
}

class _BrowserBottomSheetState extends State<BrowserBottomSheet> {
  @override
  Widget build(BuildContext context) {
    CustomPopupDialogPageRoute route;
    return Container(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50), topRight: Radius.circular(50)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatefulBuilder(builder: (statefulContext, setState) {
              var browserModel =
                  Provider.of<BrowserModel>(statefulContext, listen: true);
              var webViewModel =
                  Provider.of<WebViewModel>(statefulContext, listen: true);
              var _webViewController = webViewModel?.webViewController;
              // var settings = browserModel.getSettings();
              var isFavorite = false;
              FavoriteModel favorite;

              if (webViewModel != null &&
                  webViewModel.url != null &&
                  webViewModel.url.isNotEmpty) {
                favorite = FavoriteModel(
                    url: webViewModel.url,
                    title: webViewModel.title,
                    favicon: webViewModel.favicon);
                isFavorite = browserModel.containsFavorite(favorite);
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  children: [
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                              Features(context).addNewTab();
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.add_box,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                                Text(
                                  'New Tab',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF4E5357),
                                      fontSize:
                                          SizeConfig.blockSizeVertical * 2),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Features(context).addNewIncognitoTab();
                            },
                            child: Column(
                              children: [
                                Icon(
                                  FlutterIcons.incognito_mco,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                                Text(
                                  'New Incognito Tab',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF4E5357),
                                      fontSize:
                                          SizeConfig.blockSizeVertical * 2),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Features(context).toggleDesktopMode();
                              Navigator.pop(context);
                            },
                            child: Column(
                              children: [
                                Icon(
                                  webViewModel.isDesktopMode
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                                Text(
                                  'Desktop Mod',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF4E5357),
                                      fontSize:
                                          SizeConfig.blockSizeVertical * 2),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                              setState(() {
                                Browser.showFindOnPage = (true);
                                SystemChrome.setEnabledSystemUIOverlays([]);
                              });
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                                Text(
                                  'Find On Page',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF4E5357),
                                      fontSize:
                                          SizeConfig.blockSizeVertical * 2),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                              var result = await BarcodeScanner.scan();
                              if (result.rawContent.isNotEmpty) {
                                if (_webViewController != null) {
                                  _webViewController.loadUrl(
                                      url: ValueToUrl()
                                          .search(result.rawContent));
                                } else {
                                  Features(context).addNewTab(
                                      url: ValueToUrl()
                                          .search(result.rawContent));
                                }
                              }
                            },
                            child: Column(
                              children: [
                                Icon(
                                  FlutterIcons.qrcode_scan_mco,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                                Text(
                                  'Scanner',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF4E5357),
                                      fontSize:
                                          SizeConfig.blockSizeVertical * 2),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Features(context).showFavorites();
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                                Text(
                                  'Favorites',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF4E5357),
                                      fontSize:
                                          SizeConfig.blockSizeVertical * 2),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Features(context).showHistory();
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.history,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                                Text(
                                  'History',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF4E5357),
                                      fontSize:
                                          SizeConfig.blockSizeVertical * 2),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                Browser.fullScreen = true;
                                SystemChrome.setEnabledSystemUIOverlays([]);
                              });
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.fullscreen,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                                Text(
                                  'Full',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF4E5357),
                                      fontSize:
                                          SizeConfig.blockSizeVertical * 2),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Features(context).showWebArchives();
                            },
                            child: Column(
                              children: [
                                Icon(
                                  FlutterIcons.offline_pin_mdi,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                                Text(
                                  'Web Archives',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF4E5357),
                                      fontSize:
                                          SizeConfig.blockSizeVertical * 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Features(context).share();
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.share,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                                Text(
                                  'Share',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF4E5357),
                                      fontSize:
                                          SizeConfig.blockSizeVertical * 2),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SettingsPage()));
                              });
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.settings,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                                Text(
                                  'Settings',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF4E5357),
                                      fontSize:
                                          SizeConfig.blockSizeVertical * 2),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DevelopersPage()));
                              });
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.developer_mode,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                                Text(
                                  'Developers',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF4E5357),
                                      fontSize:
                                          SizeConfig.blockSizeVertical * 2),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(children: [
                      FloatingActionButton(
                          backgroundColor: Color(0xFFF2F4F5),
                          child: Icon(
                            isFavorite ? Icons.star : Icons.star_border,
                            color: Color(0xFF4E5357),
                            size: SizeManager(context).bottomSheetIconSize,
                          ),
                          onPressed: () {
                            setState(() {
                              if (webViewModel != null && favorite != null) {
                                if (!browserModel.containsFavorite(favorite)) {
                                  browserModel.addFavorite(favorite);
                                } else if (browserModel
                                    .containsFavorite(favorite)) {
                                  browserModel.removeFavorite(favorite);
                                }
                              }
                            });
                          }),
                      FloatingActionButton(
                          backgroundColor: Color(0xFFF2F4F5),
                          child: Icon(
                            Icons.file_download,
                            color: Color(0xFF4E5357),
                            size: SizeManager(context).bottomSheetIconSize,
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            if (webViewModel?.url != null &&
                                webViewModel.url.startsWith("http")) {
                              if (Platform.isAndroid) {
                                var uri = Uri.parse(webViewModel.url);
                                var webArchiveDirectoryPath =
                                    (await getApplicationSupportDirectory())
                                        .path;
                                var webArchivePath = webArchiveDirectoryPath +
                                    Platform.pathSeparator +
                                    uri.scheme +
                                    "-" +
                                    uri.host +
                                    uri.path.replaceAll("/", "-") +
                                    uri.query +
                                    ".mht";
                                webArchivePath = (await _webViewController
                                    ?.android
                                    ?.saveWebArchive(
                                        basename: webArchivePath,
                                        autoname: false));

                                var webArchiveModel = WebArchiveModel(
                                    url: webViewModel.url,
                                    path: webArchivePath,
                                    title: webViewModel.title,
                                    favicon: webViewModel.favicon,
                                    timestamp: DateTime.now());

                                if (webArchivePath != null) {
                                  browserModel.addWebArchive(
                                      webViewModel.url, webArchiveModel);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        "${webViewModel.url} saved offline!"),
                                  ));
                                  browserModel.save();
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text("Unable to save!"),
                                  ));
                                }
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content:
                                      Text("Not supported for this platform!"),
                                ));
                              }
                            }
                          }),
                      FloatingActionButton(
                          backgroundColor: Color(0xFFF2F4F5),
                          child: Icon(
                            Icons.info_outline,
                            color: Color(0xFF4E5357),
                            size: SizeManager(context).bottomSheetIconSize,
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            await route?.completed;
                            Features(context).showUrlInfo();
                          }),
                      FloatingActionButton(
                          backgroundColor: Color(0xFFF2F4F5),
                          child: Icon(
                            FlutterIcons.cellphone_screenshot_mco,
                            color: Color(0xFF4E5357),
                            size: SizeManager(context).bottomSheetIconSize,
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            await route?.completed;
                            Features(context).takeScreenshotAndShow();
                          }),
                    ]),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
