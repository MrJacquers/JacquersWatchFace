import Toybox.Lang;
import Toybox.WatchUi;

// On-device settings menu.
// Shown when selecting 'Customize' when selecting a watch face.
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
        Menu2.addItem(new WatchUi.ToggleMenuItem("Random Text Color", "Random Text Color", "RandomTextColor", settings.randomTextColor, null));
        Menu2.addItem(new WatchUi.ToggleMenuItem("Grid", "Show Grid Lines", "ShowGrid", settings.showGrid, null));
    }
}
