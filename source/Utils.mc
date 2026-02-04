import Toybox.Lang;
import Toybox.System;

public class Utils {
  (:debug)
  static function println(message as String) {
    System.println(message);
  }

  (:release)
  static function println(message as String) {
    // No operation in release mode
  }

  static function splitString(string, separator) as Array<String> {
    var tokens = [];
    var found = string.find(separator);

    while (found != null) {
      var token = string.substring(0, found);
      tokens.add(token);
      string = string.substring(found + separator.length(), string.length());
      found = string.find(separator);
    }

    if (string.length() > 0) {
      tokens.add(string);
    }

    return tokens;
  }
}
