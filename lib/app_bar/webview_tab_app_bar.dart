import 'package:bromine_browser/bottom_sheet/speech_to_text_bottom_sheet.dart';
import 'package:bromine_browser/constants/size_config.dart';
import 'package:bromine_browser/dialogs/custom_popup_dialog.dart';
import 'package:bromine_browser/models/browser_model.dart';
import 'package:bromine_browser/models/webview_model.dart';
import 'package:bromine_browser/utility/features.dart';
import 'package:bromine_browser/utility/value_to_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';

class WebViewTabAppBar extends StatefulWidget implements PreferredSizeWidget {
  WebViewTabAppBar({Key key, this.appBarBottom})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);
  final PreferredSizeWidget appBarBottom;
  @override
  _WebViewTabAppBarState createState() => _WebViewTabAppBarState();
  @override
  final Size preferredSize;
}

class _WebViewTabAppBarState extends State<WebViewTabAppBar>
    with SingleTickerProviderStateMixin {
  FocusNode _focusNode;
  TextEditingController _searchController = TextEditingController();
  Duration customPopupDialogTransitionDuration =
      const Duration(milliseconds: 300);
  CustomPopupDialogPageRoute route;
  OutlineInputBorder outlineBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 3.0),
    borderRadius: const BorderRadius.all(
      const Radius.circular(50.0),
    ),
  );
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() async {
      if (!_focusNode.hasFocus && _searchController.text.isEmpty) {
        var browserModel = Provider.of<BrowserModel>(context, listen: true);
        var webViewModel = browserModel.getCurrentTab()?.webViewModel;
        var _webViewController = webViewModel?.webViewController;
        _searchController?.text = await _webViewController?.getUrl();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNode = null;
    _searchController.dispose();
    _searchController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Selector<WebViewModel, String>(
        selector: (context, webViewModel) => webViewModel.url,
        builder: (context, url, child) {
          if (url == null) {
            _searchController?.text = "";
          }
          if (_focusNode != null && !_focusNode.hasFocus) {
            _searchController?.text = url;
          }

          // Widget leading = _buildAppBarHomePageWidget();

          return Selector<WebViewModel, bool>(
              selector: (context, webViewModel) => webViewModel.isIncognitoMode,
              builder: (context, isIncognitoMode, child) {
                return AppBar(
                  bottom: widget.appBarBottom,
                  backgroundColor:
                      isIncognitoMode ? Colors.black87 : Colors.white,
                  titleSpacing: 8.0,
                  title: _buildSearchTextField(),
                );
              });
        });
  }

  // Widget _buildAppBarHomePageWidget() {
  //   var browserModel = Provider.of<BrowserModel>(context, listen: true);
  //   var settings = browserModel.getSettings();
  //   var webViewModel = Provider.of<WebViewModel>(context, listen: true);
  //   var _webViewController = webViewModel?.webViewController;
  //   if (!settings.homePageEnabled) {
  //     return null;
  //   }
  //
  //   return IconButton(
  //     icon: Icon(Icons.home),
  //     onPressed: () {
  //       if (_webViewController != null) {
  //         var url =
  //             settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
  //                 ? settings.customUrlHomePage
  //                 : settings.searchEngine.url;
  //         _webViewController.loadUrl(url: url);
  //       } else {
  //         Features(context).addNewTab();
  //       }
  //     },
  //   );
  // }

  Widget _buildSearchTextField() {
    var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    var _webViewController = webViewModel?.webViewController;
    var _urlController = ValueToUrl();
    String _text = '';
    return Container(
      height: 40,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              TextField(
                onTap: () {
                  _searchController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _searchController.value.text.length);
                },
                onSubmitted: (value) {
                  var url = _urlController.search(value);
                  if (_webViewController != null) {
                    _webViewController?.loadUrl(url: url);
                  } else {
                    Features(context).addNewTab(url: url);
                    webViewModel.url = url;
                  }
                },
                keyboardType: TextInputType.url,
                focusNode: _focusNode,
                autofocus: false,
                controller: _searchController,
                textInputAction: TextInputAction.go,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 45),
                  filled: true,
                  fillColor: Color(0xFFF2F4F5),
                  border: outlineBorder,
                  focusedBorder: outlineBorder,
                  enabledBorder: outlineBorder,
                  hintText: "Search for or type a web address",
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 16.0),
                ),
                style: TextStyle(color: Colors.black, fontSize: 16.0),
              ),
              IconButton(
                icon: Selector<WebViewModel, bool>(
                  selector: (context, webViewModel) => webViewModel.isSecure,
                  builder: (context, isSecure, child) {
                    var icon = Icons.info_outline;
                    if (webViewModel.isIncognitoMode) {
                      icon = FlutterIcons.incognito_mco;
                    } else if (isSecure) {
                      if (webViewModel.url.startsWith("file:///")) {
                        icon = Icons.offline_pin;
                      } else {
                        icon = WebSymbols.lock;
                      }
                    }
                    return Icon(
                      _focusNode.hasFocus ? Icons.search : icon,
                      color: _focusNode.hasFocus
                          ? Color(0xFF4E5357)
                          : (isSecure ? Colors.green : Color(0xFF4E5357)),
                      size: _focusNode.hasFocus ? 25 : 20,
                    );
                  },
                ),
                onPressed: () {
                  if (_focusNode.hasFocus) {
                    print(_searchController.text);
                    if (isURL(_searchController.text)) {
                      print(true);
                    } else {
                      print(false);
                    }
                    _webViewController.loadUrl(url: _searchController.text);
                  } else {
                    Features(context).showUrlInfo();
                  }
                },
              ),
            ],
          ),
          Selector<WebViewModel, double>(
              selector: (context, webViewModel) => webViewModel.progress,
              builder: (context, progress, child) {
                if (progress >= 1.0) {
                  return IconButton(
                    icon: Icon(
                      _focusNode.hasFocus ? Icons.mic : Icons.refresh,
                      color: Color(0xFF4E5357),
                      size: 25,
                    ),
                    onPressed: () async {
                      if (_focusNode.hasFocus) {
                        showModalBottomSheet(
                            context: context,
                            builder: (buildContext) {
                              return SpeechToTextBottomSheet((text) {
                                _text = text;
                              });
                            }).then((value) {
                          if (_text != '') {
                            if (isURL(_text)) {
                              _searchController.text =
                                  _urlController.search(_text);
                              _webViewController.loadUrl(
                                  url: _searchController.text);
                            } else {
                              _searchController.text = _text;
                            }
                          }
                        });
                      } else {
                        _webViewController?.reload();
                      }
                    },
                  );
                }
                return IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Color(0xFF4E5357),
                    size: 25,
                  ),
                  onPressed: () {
                    _webViewController?.stopLoading();
                  },
                );
              }),
        ],
      ),
    );
  }
}
