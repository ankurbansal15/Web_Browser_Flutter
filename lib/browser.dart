import 'dart:async';

import 'package:bromine_browser/app_bar/find_on_page_app_bar.dart';
import 'package:bromine_browser/app_bar/webview_tab_app_bar.dart';
import 'package:bromine_browser/bottom_bar/browser_bottom_bar.dart';
import 'package:bromine_browser/bottom_bar/tab_viewer_bottom_bar.dart';
import 'package:bromine_browser/empty_tab.dart';
import 'package:bromine_browser/models/browser_model.dart';
import 'package:bromine_browser/models/webview_model.dart';
import 'package:bromine_browser/tab_viewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Browser extends StatefulWidget {
  Browser({Key key}) : super(key: key);
  static bool showFindOnPage = false;
  static bool fullScreen = false;
  @override
  _BrowserState createState() => _BrowserState();
}

class _BrowserState extends State<Browser> with SingleTickerProviderStateMixin {
  var _isRestored = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  restore() async {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    browserModel.restore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isRestored) {
      _isRestored = true;
      restore();
    }
    precacheImage(AssetImage("assets/icon/icon.png"), context);
  }

  @override
  Widget build(BuildContext context) {
    return _buildBrowser();
  }

  Widget _buildBrowser() {
    var currentWebViewModel = Provider.of<WebViewModel>(context, listen: true);
    var browserModel = Provider.of<BrowserModel>(context, listen: true);

    browserModel.addListener(() {
      browserModel.save();
    });
    currentWebViewModel?.addListener(() {
      browserModel.save();
    });

    if (browserModel.showTabScroller && browserModel.webViewTabs.isNotEmpty) {
      return _buildWebViewTabsViewer();
    }

    return _buildWebViewTabs();
  }

  Widget _buildWebViewTabs() {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var webViewModel = browserModel.getCurrentTab()?.webViewModel;
    var _webViewController = webViewModel?.webViewController;
    return WillPopScope(
      onWillPop: () async {
        if (_webViewController != null) {
          if (await _webViewController.canGoBack()) {
            _webViewController.goBack();
            return false;
          }
        }

        if (webViewModel != null) {
          setState(() {
            browserModel.closeTab(webViewModel.tabIndex);
          });
          FocusScope.of(context).unfocus();
          return false;
        }

        return browserModel.webViewTabs.length == 0;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: (Browser.fullScreen || (browserModel.webViewTabs.length == 0)
            ? null
            : WebViewTabAppBar(
                appBarBottom: Browser.showFindOnPage
                    ? FindOnPageAppBar(
                        hideFindOnPage: () {
                          setState(() {
                            Browser.showFindOnPage = false;
                            SystemChrome.setEnabledSystemUIOverlays(
                                SystemUiOverlay.values);
                          });
                        },
                      )
                    : null,
              )),
        body: SafeArea(
          child: _buildWebViewTabsContent(),
        ),
        floatingActionButton: ((webViewModel != null &&
                (browserModel.getCurrentTab().webViewModel.isIncognitoMode))
            ? DraggableFab(
                child: FloatingActionButton(
                  backgroundColor: Colors.black,
                  child: new Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    browserModel.closeTab(browserModel.getCurrentTabIndex());
                  },
                ),
              )
            : Browser.fullScreen
                ? DraggableFab(
                    child: FloatingActionButton(
                      backgroundColor: Color(0xFF4E5357),
                      child: Icon(
                        Icons.fullscreen_exit,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          Browser.fullScreen = false;
                          SystemChrome.setEnabledSystemUIOverlays(
                              SystemUiOverlay.values);
                        });
                      },
                    ),
                  )
                : null),
        bottomNavigationBar: (Browser.fullScreen ||
                Browser.showFindOnPage ||
                (browserModel.webViewTabs.length == 0))
            ? null
            : BrowserBottomBar(),
      ),
    );
  }

  Widget _buildWebViewTabsContent() {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);

    if (browserModel.webViewTabs.length == 0) {
      return EmptyTab();
    }
    var stackChildren = <Widget>[
      IndexedStack(
        index: browserModel.getCurrentTabIndex(),
        children: browserModel.webViewTabs.map((webViewTab) {
          var isCurrentTab = webViewTab.webViewModel.tabIndex ==
              browserModel.getCurrentTabIndex();

          if (isCurrentTab) {
            Future.delayed(const Duration(milliseconds: 100), () {
              webViewTab.key.currentState?.onShowTab();
            });
          } else {
            webViewTab.key.currentState?.onHideTab();
          }

          return webViewTab;
        }).toList(),
      ),
      _createProgressIndicator(),
    ];
    return Stack(
      children: stackChildren,
    );
  }

  Widget _createProgressIndicator() {
    return Selector<WebViewModel, double>(
        selector: (context, webViewModel) => webViewModel.progress,
        builder: (context, progress, child) {
          if (progress >= 1.0) {
            return Container();
          }
          return PreferredSize(
              preferredSize: Size(double.infinity, 4.0),
              child: SizedBox(
                  height: 4.0,
                  child: LinearProgressIndicator(
                    value: progress,
                  )));
        });
  }

  Widget _buildWebViewTabsViewer() {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);

    return WillPopScope(
        onWillPop: () async {
          browserModel.showTabScroller = false;
          return false;
        },
        child: Scaffold(
            backgroundColor: Colors.grey,
            bottomNavigationBar: TabViewerBottomBar(),
            body: TabViewer(
              currentIndex: browserModel.getCurrentTabIndex(),
              children: browserModel.webViewTabs.map((webViewTab) {
                var uri = Uri.parse(webViewTab.webViewModel.url);
                var faviconUrl = webViewTab.webViewModel.favicon != null
                    ? webViewTab.webViewModel.favicon.url
                    : (["http", "https"].contains(uri.scheme)
                        ? uri.origin + "/favicon.ico"
                        : "");
                var isCurrentTab = browserModel.getCurrentTabIndex() ==
                    webViewTab.webViewModel.tabIndex;
                return Container(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: webViewTab.webViewModel.isIncognitoMode
                          ? Colors.black
                          : Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      ),
                      border: Border.all(
                        color:
                            (isCurrentTab ? Colors.blue : Colors.transparent),
                        width: 5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: (webViewTab.webViewModel.isIncognitoMode
                                    ? Colors.black
                                    : Color(0xFFF2F4F5)),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(50),
                                ),
                              ),
                              child: Container(
                                child: ListTile(
                                  leading: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            url == "about:blank"
                                                ? Container()
                                                : CircularProgressIndicator(),
                                        imageUrl: faviconUrl,
                                        height: 30,
                                      )
                                    ],
                                  ),
                                  title: Text(
                                      webViewTab.webViewModel.title ??
                                          webViewTab.webViewModel.url,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: webViewTab
                                                .webViewModel.isIncognitoMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          size: 30,
                                          color: webViewTab
                                                  .webViewModel.isIncognitoMode
                                              ? Colors.white
                                              : Color(0xFF4E5357),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            browserModel.closeTab(webViewTab
                                                .webViewModel.tabIndex);
                                            if (browserModel
                                                    .webViewTabs.length ==
                                                0) {
                                              browserModel.showTabScroller =
                                                  false;
                                            }
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 50,
                          ),
                          Expanded(
                              child: IgnorePointer(
                            child: webViewTab,
                          ))
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
              onTap: (index) {
                browserModel.showTabScroller = false;
                browserModel.showTab(index);
              },
            )));
  }
}
