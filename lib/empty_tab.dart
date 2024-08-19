import 'package:barcode_scan/barcode_scan.dart';
import 'package:bromine_browser/bottom_sheet/speech_to_text_bottom_sheet.dart';
import 'package:bromine_browser/constants/size_config.dart';
import 'package:bromine_browser/constants/size_manager.dart';
import 'package:bromine_browser/models/browser_model.dart';
import 'package:bromine_browser/models/favorite_model.dart';
import 'package:bromine_browser/models/webview_model.dart';
import 'package:bromine_browser/utility/features.dart';
import 'package:bromine_browser/utility/value_to_url.dart';
import 'package:bromine_browser/webview_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class EmptyTab extends StatefulWidget {
  EmptyTab({Key key}) : super(key: key);

  @override
  _EmptyTabState createState() => _EmptyTabState();
}

class _EmptyTabState extends State<EmptyTab> {
  var _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();
    OutlineInputBorder outlineBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent, width: 3.0),
      borderRadius: const BorderRadius.all(
        const Radius.circular(50.0),
      ),
    );
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                width: SizeConfig.blockSizeHorizontal * 60,
                child:
                    Image(image: AssetImage(settings.searchEngine.assetIcon))),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 40,
              child: TextField(
                keyboardType: TextInputType.url,
                autofocus: false,
                controller: _controller,
                textInputAction: TextInputAction.go,
                onSubmitted: (value) {
                  openNewTab(value);
                },
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
            ),
            StatefulBuilder(builder: (statefulContext, setState) {
              var browserModel =
                  Provider.of<BrowserModel>(statefulContext, listen: true);
              var webViewModel =
                  Provider.of<WebViewModel>(statefulContext, listen: true);
              var _webViewController = webViewModel?.webViewController;
              String _text = '';
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
                          child: Column(
                            children: [
                              FloatingActionButton(
                                backgroundColor: Color(0xFFF2F4F5),
                                onPressed: () {
                                  Features(context).addNewTab();
                                },
                                child: Icon(
                                  Icons.add_box,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                              ),
                              Text(
                                'New Tab',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFF4E5357),
                                    fontSize: SizeConfig.blockSizeVertical * 2),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              FloatingActionButton(
                                backgroundColor: Color(0xFFF2F4F5),
                                onPressed: () {
                                  Features(context).addNewIncognitoTab();
                                },
                                child: Icon(
                                  FlutterIcons.incognito_mco,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                              ),
                              Text(
                                'New Incognito Tab',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFF4E5357),
                                    fontSize: SizeConfig.blockSizeVertical * 2),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              FloatingActionButton(
                                backgroundColor: Color(0xFFF2F4F5),
                                onPressed: () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (buildContext) {
                                        return SpeechToTextBottomSheet((text) {
                                          _text = text;
                                        });
                                      }).then((value) {
                                    if (_text != '') {
                                      Features(context).addNewTab(
                                          url: ValueToUrl().search(_text));
                                    }
                                  });
                                },
                                child: Icon(
                                  Icons.mic,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                              ),
                              Text(
                                'Voice Search',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFF4E5357),
                                    fontSize: SizeConfig.blockSizeVertical * 2),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              FloatingActionButton(
                                backgroundColor: Color(0xFFF2F4F5),
                                onPressed: () {
                                  Features(context).showWebArchives();
                                },
                                child: Icon(
                                  FlutterIcons.offline_pin_mdi,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                              ),
                              Text(
                                'Web Archives',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFF4E5357),
                                    fontSize: SizeConfig.blockSizeVertical * 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              FloatingActionButton(
                                backgroundColor: Color(0xFFF2F4F5),
                                onPressed: () async {
                                  var result = await BarcodeScanner.scan();
                                  if (result.rawContent.isNotEmpty) {
                                    if (result.rawContent
                                            .contains('https://') ||
                                        result.rawContent.contains('http://')) {
                                      Features(context)
                                          .addNewTab(url: result.rawContent);
                                    } else {
                                      Features(context).addNewTab(
                                          url:
                                              'https://www.google.com/search?q=${result.rawContent}');
                                    }
                                  }
                                },
                                child: Icon(
                                  FlutterIcons.qrcode_scan_mco,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                              ),
                              Text(
                                'Scanner',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFF4E5357),
                                    fontSize: SizeConfig.blockSizeVertical * 2),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              FloatingActionButton(
                                backgroundColor: Color(0xFFF2F4F5),
                                onPressed: () {
                                  Features(context).showFavorites();
                                },
                                child: Icon(
                                  Icons.star,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                              ),
                              Text(
                                'Favorites',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFF4E5357),
                                    fontSize: SizeConfig.blockSizeVertical * 2),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              FloatingActionButton(
                                backgroundColor: Color(0xFFF2F4F5),
                                onPressed: () {
                                  Features(context).showHistory();
                                },
                                child: Icon(
                                  Icons.history,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                              ),
                              Text(
                                'History',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFF4E5357),
                                    fontSize: SizeConfig.blockSizeVertical * 2),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              FloatingActionButton(
                                backgroundColor: Color(0xFFF2F4F5),
                                onPressed: () {
                                  Share.share(
                                      'https://play.google.com/store/apps/details?id=com.bansalstream.brominebrowser&hl=en_IN',
                                      subject: 'Bromine Browser');
                                },
                                child: Icon(
                                  Icons.share,
                                  color: Color(0xFF4E5357),
                                  size:
                                      SizeManager(context).bottomSheetIconSize,
                                ),
                              ),
                              Text(
                                'Share',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFF4E5357),
                                    fontSize: SizeConfig.blockSizeVertical * 2),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void openNewTab(value) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();

    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(
          url: value.startsWith("http")
              ? value
              : settings.searchEngine.searchUrl + value),
    ));
  }
}
