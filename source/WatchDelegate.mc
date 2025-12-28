import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Complications;

class WatchDelegate extends WatchFaceDelegate {

	function initialize() {
		WatchFaceDelegate.initialize();
	}

  // Handle touch long press events.
  function onPress(clickEvent) as Boolean {
    ShowBatteryHistory = false;
    
    var coords = clickEvent.getCoordinates();
    var x = coords[0];
    var y = coords[1];
    //System.println("onPress x:" + x + ",y:" + y);

    if (x < 227 && y < 227) {
      System.println("onPress: altitude");
      Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_ALTITUDE));
      return true;
    }

    if (x > 227 && y < 227) {
      System.println("onPress: sea level pressure");
      Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_SEA_LEVEL_PRESSURE));
      return true;
    }

    if (y > 227) {
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
