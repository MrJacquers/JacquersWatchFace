import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Complications;

class WatchDelegate extends WatchFaceDelegate {

  function initialize() {
    WatchFaceDelegate.initialize();
  }

  // Handle long press touch events.
  function onPress(clickEvent) as Boolean {
    // Check if we are showing battery log
    var showBatteryLog = Application.Properties.getValue("ShowBatteryLog") as Boolean;
    if (showBatteryLog) {
      Application.Properties.setValue("ShowBatteryLog", false);
      Application.getApp().method(:refreshWatchUi).invoke(true, true);
      return true;
    }

    var coords = clickEvent.getCoordinates();
    var x = coords[0];
    var y = coords[1];
    Utils.println("onPress x:" + x + ",y:" + y);

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
      Application.getApp().method(:refreshWatchUi).invoke(true, true);
      return true;
    }

    return true;
  }

  // Handle a partial update exceeding the power budget.
  function onPowerBudgetExceeded(powerInfo as WatchUi.WatchFacePowerInfo) as Void {
    Utils.println("onPowerBudgetExceeded: Allowed " + powerInfo.executionTimeLimit + " but avg was " + powerInfo.executionTimeAverage);
  }
}
