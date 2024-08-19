import 'dart:io';

import 'package:bromine_browser/dialogs/custom_popup_dialog.dart';
import 'package:bromine_browser/dialogs/project_info_popup.dart';
import 'package:bromine_browser/dialogs/url_info_popup.dart';
import 'package:bromine_browser/models/browser_model.dart';
import 'package:bromine_browser/models/webview_model.dart';
import 'package:bromine_browser/pages/developers/main.dart';
import 'package:bromine_browser/pages/settings/main.dart';
import 'package:bromine_browser/webview_tab.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:share_extend/share_extend.dart';

class Features {
  BuildContext context;
  Features(this.context);

  Duration customPopupDialogTransitionDuration =
      const Duration(milliseconds: 300);
  CustomPopupDialogPageRoute route;

  void addNewTab({String url}) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();

    if (url == null) {
      url = settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
          ? settings.customUrlHomePage
          : settings.searchEngine.url;
    }

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

    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(url: url, isIncognitoMode: true),
    ));
  }

  void toggleDesktopMode() async {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var webViewModel = browserModel.getCurrentTab()?.webViewModel;
    var _webViewController = webViewModel?.webViewController;

    var currentWebViewModel = Provider.of<WebViewModel>(context, listen: false);

    if (_webViewController != null) {
      webViewModel.isDesktopMode = !webViewModel.isDesktopMode;
      currentWebViewModel.isDesktopMode = webViewModel.isDesktopMode;

      await _webViewController.setOptions(
          options: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                  preferredContentMode: webViewModel.isDesktopMode
                      ? UserPreferredContentMode.DESKTOP
                      : UserPreferredContentMode.RECOMMENDED)));
      await _webViewController.reload();
    }
  }

  void showUrlInfo() {
    var webViewModel = Provider.of<WebViewModel>(context, listen: false);

    if (webViewModel == null ||
        webViewModel.url == null ||
        webViewModel.url.isEmpty) {
      return;
    }

    route = CustomPopupDialog.show(
      context: context,
      transitionDuration: customPopupDialogTransitionDuration,
      builder: (context) {
        return UrlInfoPopup(
          route: route,
          transitionDuration: customPopupDialogTransitionDuration,
          onWebViewTabSettingsClicked: () {
            goToSettingsPage();
          },
        );
      },
    );
  }

  void goToSettingsPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SettingsPage()));
  }

  void takeScreenshotAndShow() async {
    var webViewModel = Provider.of<WebViewModel>(context, listen: false);
    var screenshot = await webViewModel.webViewController?.takeScreenshot();

    if (screenshot != null) {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/" +
          "screenshot_" +
          DateTime.now().microsecondsSinceEpoch.toString() +
          ".png");
      await file.writeAsBytes(screenshot);

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Image.memory(screenshot),
            actions: <Widget>[
              TextButton(
                child: Text("Share"),
                onPressed: () async {
                  await ShareExtend.share(file.path, "image");
                },
              )
            ],
          );
        },
      );

      file.delete();
    }
  }

  void showFavorites() {
    showDialog(
        context: context,
        builder: (context) {
          var browserModel = Provider.of<BrowserModel>(context, listen: true);
          return AlertDialog(
              contentPadding: EdgeInsets.all(0.0),
              content: Container(
                  width: double.maxFinite,
                  child: StatefulBuilder(builder: (context, setState) {
                    return ListView(
                      children: browserModel.favorites.map((favorite) {
                        var uri = Uri.parse(favorite.url);
                        var faviconUrl = favorite.favicon != null
                            ? favorite.favicon.url
                            : uri.origin + "/favicon.ico";

                        return ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CachedNetworkImage(
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                imageUrl: faviconUrl,
                                height: 30,
                              )
                            ],
                          ),
                          title: Text(favorite.title ?? favorite.url,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Text(favorite.url,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          isThreeLine: true,
                          onTap: () {
                            setState(() {
                              addNewTab(url: favorite.url);
                              Navigator.pop(context);
                            });
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.close, size: 20.0),
                                onPressed: () {
                                  setState(() {
                                    browserModel.removeFavorite(favorite);
                                    if (browserModel.favorites.length == 0) {
                                      Navigator.pop(context);
                                    }
                                  });
                                },
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  })));
        });
  }

  void showHistory() {
    showDialog(
        context: context,
        builder: (context) {
          var webViewModel = Provider.of<WebViewModel>(context, listen: true);

          return AlertDialog(
              contentPadding: EdgeInsets.all(0.0),
              content: FutureBuilder(
                future:
                    webViewModel?.webViewController?.getCopyBackForwardList(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  WebHistory history = snapshot.data;
                  return Container(
                      width: double.maxFinite,
                      child: ListView(
                        children: history.list.reversed.map((historyItem) {
                          var uri = Uri.parse(historyItem.url);

                          return ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CachedNetworkImage(
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  imageUrl: uri.origin + "/favicon.ico",
                                  height: 30,
                                )
                              ],
                            ),
                            title: Text(historyItem.title ?? historyItem.url,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            subtitle: Text(historyItem.url,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            isThreeLine: true,
                            onTap: () {
                              webViewModel?.webViewController
                                  ?.goTo(historyItem: historyItem);
                              Navigator.pop(context);
                            },
                          );
                        })?.toList(),
                      ));
                },
              ));
        });
  }

  void showWebArchives() async {
    showDialog(
        context: context,
        builder: (context) {
          var browserModel = Provider.of<BrowserModel>(context, listen: true);
          var webArchives = browserModel.webArchives;

          var listViewChildren = <Widget>[];
          webArchives.forEach((key, webArchive) {
            var path = webArchive.path;
            // String fileName = path.substring(path.lastIndexOf('/') + 1);

            var url = webArchive.url;
            Uri uri = Uri.parse(url);

            listViewChildren.add(StatefulBuilder(builder: (context, setState) {
              return ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CachedNetworkImage(
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      imageUrl: uri.origin + "/favicon.ico",
                      height: 30,
                    )
                  ],
                ),
                title: Text(webArchive.title ?? webArchive.url,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(webArchive.url,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    setState(() {
                      browserModel.removeWebArchive(webArchive);
                      browserModel.save();
                    });
                  },
                ),
                isThreeLine: true,
                onTap: () {
                  var browserModel =
                      Provider.of<BrowserModel>(context, listen: false);
                  browserModel.addTab(WebViewTab(
                    key: GlobalKey(),
                    webViewModel: WebViewModel(url: "file://" + path),
                  ));
                  Navigator.pop(context);
                },
              );
            }));
          });

          return AlertDialog(
              contentPadding: EdgeInsets.all(0.0),
              content: Builder(
                builder: (context) {
                  return Container(
                      width: double.maxFinite,
                      child: ListView(
                        children: listViewChildren,
                      ));
                },
              ));
        });
  }

  void share() {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var webViewModel = browserModel.getCurrentTab()?.webViewModel;

    if (webViewModel != null) {
      Share.share(webViewModel.url, subject: webViewModel.title);
    }
  }

  void goToDevelopersPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => DevelopersPage()));
  }

  void openProjectPopup() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return ProjectInfoPopup();
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  void closeAllTabs() {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);

    browserModel.showTabScroller = false;

    browserModel.closeAllTabs();
  }
}
