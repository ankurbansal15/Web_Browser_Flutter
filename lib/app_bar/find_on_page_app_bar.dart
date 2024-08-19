import 'package:bromine_browser/models/browser_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FindOnPageAppBar extends StatefulWidget implements PreferredSizeWidget {
  final void Function() hideFindOnPage;
  FindOnPageAppBar({
    Key key,
    this.hideFindOnPage,
  })  : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);
  @override
  _FindOnPageAppBarState createState() => _FindOnPageAppBarState();
  @override
  final Size preferredSize;
}

class _FindOnPageAppBarState extends State<FindOnPageAppBar> {
  TextEditingController _finOnPageController = TextEditingController();

  OutlineInputBorder outlineBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    borderRadius: const BorderRadius.all(
      const Radius.circular(50.0),
    ),
  );

  @override
  void dispose() {
    _finOnPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var webViewModel = browserModel.getCurrentTab()?.webViewModel;
    var _webViewController = webViewModel?.webViewController;

    return AppBar(
      backgroundColor: Colors.white,
      titleSpacing: 10.0,
      title: Container(
          height: 40.0,
          child: TextField(
            onSubmitted: (value) {
              _webViewController?.findAllAsync(find: value);
            },
            controller: _finOnPageController,
            textInputAction: TextInputAction.go,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10.0),
              filled: true,
              fillColor: Color(0xFFF2F4F5),
              border: outlineBorder,
              focusedBorder: outlineBorder,
              enabledBorder: outlineBorder,
              hintText: "Find on page ...",
              hintStyle: TextStyle(color: Color(0xFF4E5357), fontSize: 16.0),
            ),
            style: TextStyle(color: Color(0xFF4E5357), fontSize: 16.0),
          )),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.keyboard_arrow_up,
            color: Color(0xFF4E5357),
          ),
          onPressed: () {
            _webViewController?.findNext(forward: false);
          },
        ),
        IconButton(
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF4E5357),
          ),
          onPressed: () {
            _webViewController?.findNext(forward: true);
          },
        ),
        IconButton(
          icon: Icon(Icons.close, color: Color(0xFF4E5357)),
          onPressed: () {
            setState(() {
              _webViewController?.clearMatches();
              _finOnPageController.text = "";
              widget?.hideFindOnPage();
            });
          },
        ),
      ],
    );
  }
}
