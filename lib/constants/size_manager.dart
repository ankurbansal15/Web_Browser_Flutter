import 'package:bromine_browser/constants/size_config.dart';
import 'package:flutter/cupertino.dart';

class SizeManager {
  double _iconSize;
  double _bottomSheetIconSize;
  double _bottomBarHeight;
  SizeManager(BuildContext context) {
    SizeConfig().init(context);
    this._iconSize = 0;
    this._bottomBarHeight = 0;
    this._bottomSheetIconSize = 0;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      _iconSize = (SizeConfig.blockSizeVertical * 3);
      _bottomBarHeight = (SizeConfig.blockSizeVertical * 6);
      _bottomSheetIconSize = (SizeConfig.blockSizeVertical * 4);
    } else {
      _bottomSheetIconSize = (SizeConfig.blockSizeHorizontal * 4);
      _iconSize = (SizeConfig.blockSizeHorizontal * 3);
      _bottomBarHeight = (SizeConfig.blockSizeHorizontal * 6);
    }
  }

  double get bottomSheetIconSize => _bottomSheetIconSize;

  double get bottomBarHeight => _bottomBarHeight;

  double get iconSize => _iconSize;
}
