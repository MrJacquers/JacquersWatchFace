import Toybox.Lang;
import Toybox.Time.Gregorian;
import Toybox.Complications;

class DataFields {
    var batteryLevel = 0.0;
    var batteryLogEnabled = false;

    var isDay = true;
    var sunriseText = "00:00";
    var sunsetText = "00:00";

    //private var _bodyBattery;
    //private var _recoveryTime;
    private var _altitudeId;
    private var _bodyBatteryId;
    private var _recoveryTimeId;
    private var _seaLevelPressureId;
    private var _sunriseId;
    private var _sunsetId;

    function initialize() {
        getComplicationIds();
        batteryLevel = getBatteryFromHistory();
    }

    // https://developer.garmin.com/connect-iq/core-topics/complications/
    // https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications.html
    function getComplicationIds() {
        if (Toybox has :Complications == false) {
            return;
        }

        _altitudeId = new Complications.Id(Complications.COMPLICATION_TYPE_ALTITUDE);
        _bodyBatteryId = new Complications.Id(Complications.COMPLICATION_TYPE_BODY_BATTERY);
        _recoveryTimeId = new Complications.Id(Complications.COMPLICATION_TYPE_RECOVERY_TIME);
        _seaLevelPressureId = new Complications.Id(Complications.COMPLICATION_TYPE_SEA_LEVEL_PRESSURE);
        _sunriseId = new Complications.Id(Complications.COMPLICATION_TYPE_SUNRISE);
        _sunsetId = new Complications.Id(Complications.COMPLICATION_TYPE_SUNSET);
        //Complications.registerComplicationChangeCallback(self.method(:onComplicationChanged));
    }

    // not used, keeping as example
    function subscribeComplications() {
        if (_bodyBatteryId != null) {
            Complications.subscribeToUpdates(_bodyBatteryId);
        }

        if (_recoveryTimeId != null) {
            Complications.subscribeToUpdates(_recoveryTimeId);
        }
    }

    // not used, keeping as example
    function unsubscribeComplications() {
        if (_bodyBatteryId != null) {
            Complications.unsubscribeFromUpdates(_bodyBatteryId);
        }

        if (_recoveryTimeId != null) {
            Complications.unsubscribeFromUpdates(_recoveryTimeId);
        }
    }

    // not used, keeping as example
    function onComplicationChanged(id as Complications.Id) as Void {
        Utils.println("onComplicationChanged");
        var comp = Complications.getComplication(id);

        if (id == _bodyBatteryId) {
            Utils.println("body battery updated: " + comp.value);
            //_bodyBattery = comp.value;
            return;
        }

        if (id == _recoveryTimeId) {
            Utils.println("recovery time updated: " + comp.value);
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
            if (pressure instanceof Number || pressure instanceof Float || pressure instanceof Double) {
                return pressure.format("%.0f");
            }
            return pressure.toString();
        }
        return "--";
    }

    function getBattery() {
        var battery = System.getSystemStats().battery;

        if (batteryLogEnabled && battery != batteryLevel) {
            // update the battery level
            Utils.println("battery changed from " + batteryLevel + " to " + battery);
            batteryLevel = battery;

            // get the battery level history
            var history = Settings.getStorageValue("BatteryHistory", "");
            Utils.println("history: " + history);

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

    // get the last saved battery level
    function getBatteryFromHistory() {
        var batteryHistory = Settings.getStorageValue("BatteryHistory", "");
        var entries = Utils.splitString(batteryHistory, ",");

        if (entries.size() > 0) {
            var last = entries[entries.size() - 1];
            var parts = Utils.splitString(last, " ");
            return parts[parts.size() - 1].toFloat();
        }

        return 0;
    }

    function saveHistory(history as String, storageKey as String) {
        // split the history into entries
        var entries = Utils.splitString(history, ",");
        Utils.println("saveHistory: " + entries.toString());

        // only keep the last x entries
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

    // If the location is not available, use the last known location from storage.
    // Check if it's day or night based on the current time and sunrise/sunset times.
    function getSunInfo() {
        var sunriseComp = Complications.getComplication(_sunriseId);
        var sunsetComp = Complications.getComplication(_sunsetId);
        // value is a non-negative Number representing seconds since midnight local time of the sunrise or null
        if (sunriseComp != null && sunriseComp.value != null && sunsetComp != null && sunsetComp.value != null) {
            var hours = (sunriseComp.value / 3600);
            var minutes = ((sunriseComp.value % 3600) / 60);
            sunriseText = Lang.format("$1$:$2$", [hours.format("%02d"), minutes.format("%02d")]);

            hours = (sunsetComp.value / 3600);
            minutes = ((sunsetComp.value % 3600) / 60);
            sunsetText = Lang.format("$1$:$2$", [hours.format("%02d"), minutes.format("%02d")]);

            var now = Time.now().value();
            var midnight = Time.today().value();
            var sunrise = midnight + sunriseComp.value;
            var sunset = midnight + sunsetComp.value;
            isDay = now > sunrise && now < sunset;
            return;
        }

        var now = Time.now();
        var location = Activity.getActivityInfo().currentLocation;

        if (location == null) {
            // get last known location from storage
            var latitude = Settings.getStorageValue("LastLocationLat", null);
            var longitude = Settings.getStorageValue("LastLocationLon", null);
            if (latitude != null && longitude != null) {
                location = new Position.Location({ :latitude => latitude, :longitude => longitude, :format => :degrees });
            }
        }

        if (location != null) {
            // save in storage
            var locationInfo = location.toDegrees();
            Settings.setStorageValue("LastLocationLat", locationInfo[0]);
            Settings.setStorageValue("LastLocationLon", locationInfo[1]);

            // get sunrise time
            var sunrise = Weather.getSunrise(location, now);
            var sunriseInfo = Gregorian.info(sunrise, Time.FORMAT_MEDIUM);
            sunriseText = sunriseInfo.hour.format("%02d") + ":" + sunriseInfo.min.format("%02d");

            // get sunset time
            var sunset = Weather.getSunset(location, now);
            var sunsetInfo = Gregorian.info(sunset, Time.FORMAT_MEDIUM);
            sunsetText = sunsetInfo.hour.format("%02d") + ":" + sunsetInfo.min.format("%02d");

            // check if it's day or night
            isDay = now.value() > sunrise.value() && now.value() < sunset.value();
            return;
        }

        // no location info, use default values
        var dateInfo = Gregorian.info(now, Time.FORMAT_SHORT);
        isDay = dateInfo.hour > 5 && dateInfo.hour < 18;
    }
}
