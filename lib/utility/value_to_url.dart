import 'package:bromine_browser/models/browser_model.dart';
import 'package:validators/validators.dart';

class ValueToUrl {
  String search(String value) {
    String trimValue = value.trim();
    if (isURL(trimValue)) {
      if (trimValue.startsWith('http')) {
        return trimValue;
      } else {
        return 'http://' + trimValue;
      }
    }
    return BrowserSettings().searchEngine.searchUrl + value;
  }
}
