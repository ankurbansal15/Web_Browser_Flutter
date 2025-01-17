import 'dart:io';

import 'package:bromine_browser/animations/animated_flutter_browser_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ProjectInfoPopup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProjectInfoPopupState();
}

class _ProjectInfoPopupState extends State<ProjectInfoPopup> {
  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      RichText(
        text: TextSpan(children: [
          TextSpan(
            text: "Do you like this project? Give a ",
            style: TextStyle(color: Colors.black),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(
              Icons.star,
              size: 25,
              color: Colors.yellow,
            ),
          ),
          TextSpan(text: " to", style: TextStyle(color: Colors.black))
        ]),
      ),
      TextButton.icon(
        icon: Icon(
          FlutterIcons.github_box_mco,
          size: 40.0,
        ),
        label: RichText(
          text: TextSpan(children: [
            TextSpan(text: "Github: ", style: TextStyle(color: Colors.black)),
            TextSpan(
                text: "pichillilorenzo/flutter_inappwebview",
                style: TextStyle(color: Colors.blue))
          ]),
        ),
        onPressed: () {
          InAppBrowser.openWithSystemBrowser(
              url: "https://github.com/pichillilorenzo/flutter_inappwebview");
        },
      ),
      RichText(
        text: TextSpan(children: [
          TextSpan(text: "and to", style: TextStyle(color: Colors.black)),
        ]),
      ),
      TextButton.icon(
        icon: Icon(
          FlutterIcons.github_box_mco,
          size: 40.0,
        ),
        label: RichText(
          text: TextSpan(children: [
            TextSpan(text: "Github: ", style: TextStyle(color: Colors.black)),
            TextSpan(
                text: "pichillilorenzo/flutter_browser_app",
                style: TextStyle(color: Colors.blue))
          ]),
        ),
        onPressed: () {
          InAppBrowser.openWithSystemBrowser(
              url: "https://github.com/pichillilorenzo/flutter_browser_app");
        },
      ),
      SizedBox(
        height: 20.0,
      ),
      Container(
        width: 250.0,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(children: [
            TextSpan(
              text:
                  "Also, if you want, you can support these projects with a donation. Thanks!",
              style: TextStyle(color: Colors.black),
            ),
          ]),
        ),
      ),
    ];

    if (Platform.isIOS) {
      children.addAll(<Widget>[
        SizedBox(
          height: 20.0,
        ),
        TextButton.icon(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 30.0,
          ),
          label: Text(
            "Go Back",
            style: TextStyle(fontSize: 20.0),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ]);
    }

    return Scaffold(
      body: Center(
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (Orientation.landscape == orientation) {
              var rowChildren = <Widget>[
                AnimatedFlutterBrowserLogo(),
                SizedBox(
                  width: 80.0,
                ),
              ];
              rowChildren.add(Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              ));

              return Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: rowChildren,
              );
            }

            var columnChildren = <Widget>[
              AnimatedFlutterBrowserLogo(),
              SizedBox(
                height: 80.0,
              ),
            ];
            columnChildren.addAll(children);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: columnChildren,
            );
          },
        ),
      ),
    );
  }
}
