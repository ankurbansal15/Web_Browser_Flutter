import 'package:bromine_browser/bottom_sheet/browser_bottom_sheet.dart';
import 'package:bromine_browser/constants/size_config.dart';
import 'package:bromine_browser/constants/size_manager.dart';
import 'package:bromine_browser/models/browser_model.dart';
import 'package:bromine_browser/models/webview_model.dart';
import 'package:bromine_browser/utility/features.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:provider/provider.dart';

class BrowserBottomBar extends StatefulWidget {
  BrowserBottomBar({Key key}) : super(key: key);
  @override
  _BrowserBottomBarState createState() => _BrowserBottomBarState();
}

class _BrowserBottomBarState extends State<BrowserBottomBar> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    var settings = browserModel.getSettings();
    var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    var _webViewController = webViewModel?.webViewController;
    return Container(
      height: SizeManager(context).bottomBarHeight,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: SizeConfig.blockSizeVertical * 5,
                width: SizeConfig.blockSizeHorizontal * 15,
                child: GestureDetector(
                  child: Icon(
                    MfgLabs.left_bold,
                    color: Color(0xFF4E5357),
                    size: SizeManager(context).iconSize,
                  ),
                  onTap: () {
                    _webViewController?.goBack();
                  },
                ),
              ),
              Container(
                height: SizeConfig.blockSizeVertical * 5,
                width: SizeConfig.blockSizeHorizontal * 15,
                child: GestureDetector(
                  child: Icon(
                    MfgLabs.home,
                    color: Color(0xFF4E5357),
                    size: SizeManager(context).iconSize,
                  ),
                  onTap: () {
                    if (_webViewController != null) {
                      var url = settings.homePageEnabled &&
                              settings.customUrlHomePage.isNotEmpty
                          ? settings.customUrlHomePage
                          : settings.searchEngine.url;
                      _webViewController.loadUrl(url: url);
                    } else {
                      Features(context).addNewTab();
                    }
                  },
                ),
              ),
              Container(
                height: SizeConfig.blockSizeVertical * 5,
                width: SizeConfig.blockSizeHorizontal * 15,
                child: GestureDetector(
                  child: Icon(
                    Typicons.th,
                    color: Color(0xFF4E5357),
                    size: SizeManager(context).iconSize,
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (contextBuilder) {
                        return BrowserBottomSheet();
                      },
                    );
                  },
                ),
              ),
              Container(
                height: SizeConfig.blockSizeVertical * 5,
                width: SizeConfig.blockSizeHorizontal * 15,
                child: GestureDetector(
                  onLongPress: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (buildContext) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(50),
                                  topLeft: Radius.circular(50)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Features(context).addNewTab();
                                        Navigator.pop(context);
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'New Tab',
                                            style: TextStyle(
                                              color: Color(0xFF4E5357),
                                              fontSize: 20,
                                            ),
                                          ),
                                          Icon(
                                            Icons.add,
                                            color: Color(0xFF4E5357),
                                            size:
                                                SizeManager(context).iconSize *
                                                    2,
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
                                        Features(context).addNewIncognitoTab();
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'New Incognito Tab',
                                            style: TextStyle(
                                              color: Color(0xFF4E5357),
                                              fontSize: 20,
                                            ),
                                          ),
                                          Icon(
                                            FlutterIcons.incognito_mco,
                                            color: Color(0xFF4E5357),
                                            size:
                                                SizeManager(context).iconSize *
                                                    2,
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
                                        browserModel.closeAllTabs();
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Close All Tab',
                                            style: TextStyle(
                                              color: Color(0xFF4E5357),
                                              fontSize: 20,
                                            ),
                                          ),
                                          Icon(
                                            Icons.close,
                                            color: Color(0xFF4E5357),
                                            size:
                                                SizeManager(context).iconSize *
                                                    2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  onTap: () {
                    if (browserModel.webViewTabs.length > 0) {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      browserModel.showTabScroller = true;
                    }
                  },
                  child: Container(
                    height: SizeManager(context).iconSize,
                    width: SizeManager(context).iconSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5.0),
                      color: Color(0xFF4E5357),
                    ),
                    child: Center(
                        child: Text(
                      browserModel.webViewTabs.length.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: SizeManager(context).iconSize - 4),
                    )),
                  ),
                ),
              ),
              Container(
                height: SizeConfig.blockSizeVertical * 5,
                width: SizeConfig.blockSizeHorizontal * 15,
                child: GestureDetector(
                  child: Icon(
                    MfgLabs.right_bold,
                    color: Color(0xFF4E5357),
                    size: SizeManager(context).iconSize,
                  ),
                  onTap: () {
                    _webViewController?.goForward();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
