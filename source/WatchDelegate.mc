import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Complications;

class WatchDelegate extends WatchFaceDelegate {

	function initialize() {
		WatchFaceDelegate.initialize();
	}

  function onPress(clickEvent) as Boolean {
    ShowBatteryHistory = false;
    
    var coords = clickEvent.getCoordinates();
    var x = coords[0];
    var y = coords[1];
    //System.println("onPress x:" + x + ",y:" + y);

    // dc.drawRectangle(186, 12, 93, 58);
    if (x >= 186 && y >= 12 && x <= 279 && y <= 70) {
      System.println("onPress: altitude");
      Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_ALTITUDE));
      return true;
    }

    // barometric pressure box click handler
    if (x >= 172 && y >= 360 && x <= 282 && y <= 390) {
      System.println("onPress: sea level pressure");
      Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_SEA_LEVEL_PRESSURE));
      return true;
    }

    // dc.drawRectangle(130, 310, 90, 60);
    if (x >= 130 && y >= 310 && x <= 220 && y <= 370) {
      System.println("onPress: battery");
      ShowBatteryHistory = true;
      return true;
    }

    return true;
  }

  // Handle a partial update exceeding the power budget.
  function onPowerBudgetExceeded(powerInfo as WatchUi.WatchFacePowerInfo) as Void {
    System.println("onPowerBudgetExceeded: Allowed " + powerInfo.executionTimeLimit + " but avg was " + powerInfo.executionTimeAverage);
  }
}
