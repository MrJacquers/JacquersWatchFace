import Toybox.Lang;
import Toybox.WatchUi;

// https://developer.garmin.com/connect-iq/core-topics/native-controls/
class ODSettingsMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize(null);
        Menu2.setTitle("Settings");

        // get the settings
        var settings = new Settings();
        settings.loadSettings();

        // label, subtitle, id, initialValue, options
        // https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/ToggleMenuItem.html
        Menu2.addItem(new WatchUi.ToggleMenuItem("Battery Log", "Log Battery Level", "BatteryLogEnabled", settings.batteryLogEnabled, null));
        Menu2.addItem(new WatchUi.ToggleMenuItem("Show Battery Log", "Show Battery Log", "ShowBatteryLog", settings.showBatteryLog, null));
        Menu2.addItem(new WatchUi.ToggleMenuItem("Grid", "Show Grid Lines", "ShowGrid", settings.showGrid, null));
    }
}
