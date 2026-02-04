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
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        Application.getApp().method(:refreshWatchUi).invoke(true, false);
    }
}
