import Toybox.Lang;
import Toybox.Application.Storage;

class Settings {
    //var layoutType;
    var bgColor;
    var textColorDay;
    var textColorNight;
    var textColorSleep;
    //var timeFont;
    //var dateColor;
    //var hrColor;
    //var connectColor;
    //var hourColor;
    //var minuteColor;
    //var secColor;
    //var bodyBattColor;
    //var altitudeColor;
    //var stepsColor;
    //var recoveryColor;
    //var battColor;
    var showGrid;
    var batteryLevel = 0;
    var batteryLogEnabled = false;
    var showBatteryLog = false;

    function loadSettings() {
        // https://developer.garmin.com/connect-iq/core-topics/properties-and-app-settings/
        // https://forums.garmin.com/developer/connect-iq/w/wiki/4/new-developer-faq#settings-crash
        if (Toybox.Application has :Properties) {
            //layoutType = Application.Properties.getValue("LayoutType");
            bgColor = Application.Properties.getValue("BGColor");
            textColorDay = Application.Properties.getValue("TextColorDay").toNumberWithBase(16);
            textColorNight = Application.Properties.getValue("TextColorNight").toNumberWithBase(16);
            textColorSleep = Application.Properties.getValue("TextColorSleep").toNumberWithBase(16);
            //timeFont = Application.Properties.getValue("TimeFont");
            //dateColor = Application.Properties.getValue("DateColor");
            //hrColor = Application.Properties.getValue("HRColor");
            //connectColor = Application.Properties.getValue("ConnectColor");
            //hourColor = Application.Properties.getValue("HourColor");
            //minuteColor = Application.Properties.getValue("MinuteColor");
            //secColor = Application.Properties.getValue("SecColor");
            //bodyBattColor = Application.Properties.getValue("BodyBattColor");
            //altitudeColor = Application.Properties.getValue("AltitudeColor");
            //stepsColor = Application.Properties.getValue("StepsColor");
            //recoveryColor = Application.Properties.getValue("RecoveryColor");
            //battColor = Application.Properties.getValue("BattColor");

            // On-device settings: accessible via select watch face -> customize
            showGrid = Application.Properties.getValue("ShowGrid");
            batteryLogEnabled = Application.Properties.getValue("BatteryLogEnabled");
            showBatteryLog = Application.Properties.getValue("ShowBatteryLog");
        }

        // Load persisted values
        if (Toybox.Application has :Storage) {
            batteryLevel = Settings.getStorageValue("BatteryLevel", 0);
        }
    }

    // Using storage to persist data between app sessions, e.g. battery level, history and position for sun info.
    static function getStorageValue(name, defaultValue) {
        var value = Storage.getValue(name);
        if (value == null || value.equals("") || value.equals("null")) {
            return defaultValue;
        }        
        return value;
    }

    static function setStorageValue(key, value) {
        if (Toybox.Application has :Storage) {
            Storage.setValue(key, value);
        }
    }
}
