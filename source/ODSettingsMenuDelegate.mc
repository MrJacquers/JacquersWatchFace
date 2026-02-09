import Toybox.Lang;
import Toybox.WatchUi;

// https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/Menu2InputDelegate.html
class ODSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        if (item instanceof ToggleMenuItem) {
            Application.Properties.setValue(item.getId().toString(), item.isEnabled());
            Utils.println("ODSettingsMenuDelegate.onSelect: " + item.getId().toString() + " = " + item.isEnabled());
        }
    }

    function onBack() {
        Utils.println("ODSettingsMenuDelegate.onBack");
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        Application.getApp().loadSettings(false);
    }
}
