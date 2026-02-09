import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Complications;

class WatchDelegate extends WatchFaceDelegate {

  function initialize() {
    WatchFaceDelegate.initialize();
  }

  // Handle long press touch events.
  function onPress(clickEvent) as Boolean {
    var coords = clickEvent.getCoordinates();
    var x = coords[0];
    var y = coords[1];
    Utils.println("onPress x:" + x + ",y:" + y);

    // Check if the battery log is being displayed
    if (Application.Properties.getValue("ShowBatteryLog")) {
      Application.Properties.setValue("ShowBatteryLog", false);
      Application.getApp().loadSettings(false);
      return true;
    }

    if (x < 227 && y < 227) {
      Utils.println("onPress: altitude");
      //Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_ALTITUDE));
      return true;
    }

    if (x > 227 && y < 227) {
      Utils.println("onPress: sea level pressure");
      //Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_SEA_LEVEL_PRESSURE));
      return true;
    }

    if (y > 227) {
      Utils.println("onPress: battery");
      Application.Properties.setValue("ShowBatteryLog", true);
      Application.getApp().loadSettings(false);
      return true;
    }

    return true;
  }

  // Handle a partial update exceeding the power budget.
  function onPowerBudgetExceeded(powerInfo as WatchUi.WatchFacePowerInfo) as Void {
    Utils.println("onPowerBudgetExceeded: Allowed " + powerInfo.executionTimeLimit + " but avg was " + powerInfo.executionTimeAverage);
  }
}
