import 'package:bromine_browser/bottom_sheet/tab_viewer_bottom_sheet.dart';
import 'package:bromine_browser/constants/size_config.dart';
import 'package:bromine_browser/constants/size_manager.dart';
import 'package:bromine_browser/models/browser_model.dart';
import 'package:bromine_browser/models/webview_model.dart';
import 'package:bromine_browser/pages/settings/main.dart';
import 'package:bromine_browser/webview_tab.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:provider/provider.dart';

class TabViewerBottomBar extends StatefulWidget implements PreferredSizeWidget {
  TabViewerBottomBar({Key key})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  _TabViewerBottomBar createState() => _TabViewerBottomBar();

  @override
  final Size preferredSize;
}

class _TabViewerBottomBar extends State<TabViewerBottomBar> {
  @override
  Widget build(BuildContext context) {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    return Container(
      height: SizeManager(context).bottomBarHeight,
      child: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: SizeConfig.blockSizeHorizontal * 15,
                height: SizeConfig.blockSizeVertical * 5,
                child: GestureDetector(
                  child: Icon(Icons.add_box,
                      color: Color(0xFF4E5357),
                      size: SizeManager(context).iconSize * 1.3),
                  onTap: () {
                    addNewTab();
                  },
                ),
              ),
              Container(
                width: SizeConfig.blockSizeHorizontal * 15,
                height: SizeConfig.blockSizeVertical * 5,
                child: GestureDetector(
                  child: Icon(
                    Icons.settings,
                    color: Color(0xFF4E5357),
                    size: SizeManager(context).iconSize * 1.3,
                  ),
                  onTap: () {
                    goToSettingsPage();
                  },
                ),
              ),
              Container(
                width: SizeConfig.blockSizeHorizontal * 15,
                height: SizeConfig.blockSizeVertical * 5,
                child: GestureDetector(
                  child: Icon(
                    Typicons.menu,
                    color: Color(0xFF4E5357),
                    size: SizeManager(context).iconSize,
                  ),
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (buildContext) {
                          return TabViewerBottomSheet(
                              addNewTab, addNewIncognitoTab, closeAllTabs);
                        });
                  },
                ),
              ),
              Container(
                width: SizeConfig.blockSizeHorizontal * 15,
                height: SizeConfig.blockSizeVertical * 5,
                child: GestureDetector(
                  onTap: () {
                    if (browserModel.webViewTabs.length > 0) {
                      browserModel.showTabScroller =
                          !browserModel.showTabScroller;
                    } else {
                      browserModel.showTabScroller = false;
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
                width: SizeConfig.blockSizeHorizontal * 15,
                height: SizeConfig.blockSizeVertical * 5,
                child: GestureDetector(
                  child: Icon(
                    Elusive.trash,
                    color: Color(0xFF4E5357),
                    size: SizeManager(context).iconSize,
                  ),
                  onTap: () {
                    browserModel.closeTab(browserModel.webViewTabs.length - 1);
                    if (browserModel.webViewTabs.length == 0) {
                      browserModel.showTabScroller = false;
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addNewTab({String url}) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();

    if (url == null) {
      url = settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
          ? settings.customUrlHomePage
          : settings.searchEngine.url;
    }

    browserModel.showTabScroller = false;

    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(url: url),
    ));
  }

  void addNewIncognitoTab({String url}) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();

    if (url == null) {
      url = settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
          ? settings.customUrlHomePage
          : settings.searchEngine.url;
    }

    browserModel.showTabScroller = false;

    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(url: url, isIncognitoMode: true),
    ));
  }

  void closeAllTabs() {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);

    browserModel.showTabScroller = false;

    browserModel.closeAllTabs();
  }

  void goToSettingsPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SettingsPage()));
  }
}
