import Toybox.Lang;
import Toybox.System;

public class Utils {
  (:debug)
  static function println(message as String) {
    var time = System.getClockTime();
    System.println("[" + time.hour.format("%02d") + ":" + time.min.format("%02d") + ":" + time.sec.format("%02d") + "] " + message);
  }

  (:release)
  static function println(message as String) {
    // No operation in release mode
  }

  // Split a string by a separator and return an array of items.
  static function splitString(string, separator) as Array<String> {
    var items = [];
    var found = string.find(separator);

    while (found != null) {
      var item = string.substring(0, found);
      items.add(item);
      string = string.substring(found + separator.length(), string.length());
      found = string.find(separator);
    }

    if (string.length() > 0) {
      items.add(string);
    }

    return items;
  }
}
