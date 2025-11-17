import Toybox.Lang;
import Toybox.Time.Gregorian;
import Toybox.Complications;

class DataFields {
    var battLogEnabled = false;
    //private var _bodyBattery;
    //private var _recoveryTime;
    private var _altitudeId;
    private var _bodyBatteryId;
    private var _recoveryTimeId;
    private var _seaLevelPressureId;

    // https://developer.garmin.com/connect-iq/core-topics/complications/
    // https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications.html
    function registerComplications() {
        if (Toybox has :Complications == false) {
            return;
        }

        _altitudeId = new Complications.Id(Complications.COMPLICATION_TYPE_ALTITUDE);
        _bodyBatteryId = new Complications.Id(Complications.COMPLICATION_TYPE_BODY_BATTERY);
        _recoveryTimeId = new Complications.Id(Complications.COMPLICATION_TYPE_RECOVERY_TIME);
        _seaLevelPressureId = new Complications.Id(Complications.COMPLICATION_TYPE_SEA_LEVEL_PRESSURE);
        //Complications.registerComplicationChangeCallback(self.method(:onComplicationChanged));
    }

    // not used, keeping as example
    function subscribeComplications() {
        //_bodyBattery = null;
        //_recoveryTime = null;

        if (_bodyBatteryId != null) {
            Complications.subscribeToUpdates(_bodyBatteryId);
        }

        if (_recoveryTimeId != null) {
            Complications.subscribeToUpdates(_recoveryTimeId);
        }
    }

    // not used, keeping as example
    function unsubscribeComplications() {
        //_bodyBattery = null;
        //_recoveryTime = null;

        if (_bodyBatteryId != null) {
            Complications.unsubscribeFromUpdates(_bodyBatteryId);
        }

        if (_recoveryTimeId != null) {
            Complications.unsubscribeFromUpdates(_recoveryTimeId);
        }
    }

    // not used, keeping as example
    function onComplicationChanged(id as Complications.Id) as Void {
        //System.println("onComplicationChanged");
        //var comp = Complications.getComplication(id);

        if (id == _bodyBatteryId) {
            //System.println("body battery updated: " + comp.value);
            //_bodyBattery = comp.value;
            return;
        }

        if (id == _recoveryTimeId) {
            //System.println("recovery time updated: " + comp.value);
            //_recoveryTime = comp.value;
            return;
        }
    }

    function getHeartRate() {
        var hr = Activity.getActivityInfo().currentHeartRate;
        if (hr != null && hr != 0 && hr != 255) {
            return hr;
        }
        return "--";
    }

    function getBodyBattery() {
        var comp = Complications.getComplication(_bodyBatteryId);
        if (comp.value != null) {
            return comp.value;
        }
        return "--";
    }

    function getSteps() {
        return ActivityMonitor.getInfo().steps;
    }

    function getRecoveryTime() {
        var comp = Complications.getComplication(_recoveryTimeId);
        if (comp.value != null) {
            return (comp.value / 60.0).format("%.1f");
        }
        return "--";
    }

    function getAltitude() {
        var comp = Complications.getComplication(_altitudeId);
        if (comp.value != null) {
            return comp.value;
        }
        return "--";
    }

    function getBarometricPressure() {
        var comp = Complications.getComplication(_seaLevelPressureId);
        if (comp.value != null) {
            var pressure = comp.value;
            // Format as integer with no decimals
            if (pressure instanceof Number || pressure instanceof Float || pressure instanceof Double) {
                return pressure.format("%.0f");
            }
            return pressure.toString();
        }
        return "--";
    }

    function getBattery() {
        //System.println("getBattery");
        var battery = System.getSystemStats().battery;

        if (battLogEnabled && battery != BatteryLevel) {
            // update the global battery level
            BatteryLevel = battery;

            // get the battery level history
            var history = Settings.getStorageValue("BatteryHistory", "");
            //System.println("history: " + history);

            // add the battery level to the history
            var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
            history += Lang.format("$1$ $2$:$3$ $4$,", [
                dateInfo.day.format("%02d"),
                dateInfo.hour.format("%02d"),
                dateInfo.min.format("%02d"),
                battery.format("%02d"),
            ]);

            // save the battery level history
            saveHistory(history, "BatteryHistory");
        }

        return Lang.format("$1$%", [battery.format("%d")]);
    }

    function getBatteryFromHistory() {
        var batteryHistory = Settings.getStorageValue("BatteryHistory", "");
        var entries = Utils.splitString(batteryHistory, ",");
        if (entries.size() == 0) {
            return 0;
        }
        var last = entries[entries.size() - 1];
        var parts = Utils.splitString(last, " ");
        return parts[parts.size() - 1].toNumber();
    }

    function saveHistory(history as String, storageKey as String) {
        // split the history into entries
        var entries = Utils.splitString(history, ",");
        //System.println("entries: " + entries.toString());

        var maxToKeep = 10;
        if (entries.size() > maxToKeep) {
            history = "";
            for (var i = entries.size() - maxToKeep; i < entries.size(); i++) {
                history += entries[i] + ",";
            }
        }

        // save the history
        Settings.setStorageValue(storageKey, history);
    }
}
