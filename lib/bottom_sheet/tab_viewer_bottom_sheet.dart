import 'package:bromine_browser/constants/size_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class TabViewerBottomSheet extends StatefulWidget {
  final void Function() addNewTab;
  final void Function() addNewIncognitoTab;
  final void Function() closeAllTabs;

  TabViewerBottomSheet(
      this.addNewTab, this.addNewIncognitoTab, this.closeAllTabs);

  @override
  _TabViewerBottomSheetState createState() => _TabViewerBottomSheetState();
}

class _TabViewerBottomSheetState extends State<TabViewerBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(50), topLeft: Radius.circular(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    widget?.addNewTab();
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      size: SizeManager(context).iconSize * 2,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    widget?.addNewIncognitoTab();
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      size: SizeManager(context).iconSize * 2,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    widget?.closeAllTabs();
                  });
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      size: SizeManager(context).iconSize * 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
