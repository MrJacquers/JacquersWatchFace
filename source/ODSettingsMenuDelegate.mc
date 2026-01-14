import Toybox.Lang;
import Toybox.WatchUi;

// https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/Menu2InputDelegate.html
class ODSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var id = item.getId();

        if (item instanceof ToggleMenuItem) {
            if (id.equals("ShowBattLog")) {
                ShowBatteryHistory = item.isEnabled();
                return;
            }

            var settings = new Settings();
            settings.setStorageValue(id, item.isEnabled());
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
