import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class WatchFaceView extends WatchUi.WatchFace {
  private var _devSize;
  private var _devCenter;
  private var _iconFont;
  private var _timeFont;
  private var _hidden;
  private var _lowPwrMode;
  private var _settings;
  private var _dataFields;
  private var _isDay = true;
  private var _sunriseText = "00:00";
  private var _sunsetText = "00:00";
  private var _recoveryTime;
  private var _steps;
  private var _battery;
  
  // Cached scaled coordinates
  private var _scale;
  private var _pos_date_y;
  private var _pos_sunrise_y;
  private var _pos_sunrise_offset_x;
  private var _pos_sunrise_text_y;
  private var _pos_phone_x;
  private var _pos_phone_y;
  private var _pos_time_y;
  private var _pos_time_offset_x;
  private var _pos_time_center_offset_x;
  private var _pos_seconds_x;
  private var _pos_seconds_y;
  private var _pos_steps_icon_y;
  private var _pos_steps_text_x;
  private var _pos_steps_text_y;
  private var _pos_recovery_icon_y;
  private var _pos_recovery_text_x;
  private var _pos_recovery_text_y;
  private var _pos_hr_offset_x;
  private var _pos_hr_text_offset_x;
  private var _pos_batt_offset_x;
  private var _pos_batt_text_offset_x;
  // DND mode coordinates
  private var _pos_dnd_phone_y;
  private var _pos_dnd_date_y;
  private var _pos_dnd_hr_icon_y;
  private var _pos_dnd_hr_text_offset_x;
  private var _pos_dnd_hr_text_y;
  private var _pos_dnd_batt_icon_y;
  private var _pos_dnd_batt_text_offset_x;
  private var _pos_dnd_batt_text_y;
  // Battery history
  private var _pos_history_start_y;
  private var _pos_history_line_height;

  function initialize() {
    //System.println("view.initialize");
    WatchFace.initialize();

    loadSettings();
    
    _dataFields = new DataFields();
    _dataFields.registerComplications();
    _dataFields.battLogEnabled = _settings.battLogEnabled;
  }

  function loadSettings() {
    if (_settings == null) {
      _settings = new Settings();
    }
    
    _settings.loadSettings();
  }

  function onLayout(dc as Dc) as Void {
    //System.println("onLayout");
    _devSize = dc.getWidth();
    _devCenter = _devSize / 2;

    if (_devSize == 454) {
      _iconFont = WatchUi.loadResource(Rez.Fonts.icons_36);
      _timeFont = WatchUi.loadResource(Rez.Fonts.oxanium_96);
    } else {
      _iconFont = WatchUi.loadResource(Rez.Fonts.icons_30);
      _timeFont = WatchUi.loadResource(Rez.Fonts.oxanium_82);
    }

    // Calculate scale factor based on device resolution (FR965 is 454x454, FR165 is 390x390)
    _scale = _devSize / 454.0;
    
    // Pre-calculate all scaled coordinates
    _pos_date_y = scale(30);
    _pos_sunrise_y = scale(95);
    _pos_sunrise_offset_x = scale(35);
    _pos_sunrise_text_y = scale(90);
    _pos_phone_x = scale(65);
    _pos_phone_y = scale(185);
    _pos_time_y = scale(170);
    _pos_seconds_x = scale(350);
    _pos_seconds_y = scale(196);
    _pos_steps_icon_y = scale(279);
    _pos_steps_text_x = scale(170);
    _pos_steps_text_y = scale(271);
    _pos_recovery_icon_y = scale(335);
    _pos_recovery_text_x = scale(170);
    _pos_recovery_text_y = scale(330);
    _pos_hr_offset_x = scale(279);
    _pos_hr_text_offset_x = scale(55);
    _pos_batt_offset_x = scale(335);
    _pos_batt_text_offset_x = scale(55);
    
    // Time offset coordinates
    _pos_time_offset_x = scale(5);
    _pos_time_center_offset_x = scale(10);
    
    // DND mode coordinates
    _pos_dnd_phone_y = scale(55);
    _pos_dnd_date_y = scale(105);
    _pos_dnd_hr_icon_y = scale(302);
    _pos_dnd_hr_text_offset_x = scale(60);
    _pos_dnd_hr_text_y = scale(295);
    _pos_dnd_batt_icon_y = scale(300);
    _pos_dnd_batt_text_offset_x = scale(50);
    _pos_dnd_batt_text_y = scale(295);
    
    // Battery history
    _pos_history_start_y = scale(50);
    _pos_history_line_height = scale(40);
  }

  // Called when this View is brought to the foreground.
  // Restore the state of this View and prepare it to be shown.
  // This includes loading resources into memory.
  function onShow() as Void {
    //System.println("onShow");
    _hidden = false;
    _lowPwrMode = false;

    // get data that isn't updated frequently
    _steps = _dataFields.getSteps();
    _battery = _dataFields.getBattery();
    _recoveryTime = _dataFields.getRecoveryTime();
    getSunInfo();

    //_dataFields.subscribeComplications();
  }

  // Called when this View is removed from the screen. Save the state of this View here.
  // This includes freeing resources from memory.
  function onHide() as Void {
    //System.println("onHide");
    _hidden = true;
    //_dataFields.unsubscribeComplications();
  }

  // Terminate any active timers and prepare for slow updates (once a minute).
  function onEnterSleep() as Void {
    //System.println("onEnterSleep");
    _lowPwrMode = true;
    //_dataFields.unsubscribeComplications();
    //WatchUi.requestUpdate(); // not really required, onUpdate will be called anyway.
  }

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() as Void {
    //System.println("onExitSleep");
    _lowPwrMode = false;

    // get data that isn't updated frequently
    _steps = _dataFields.getSteps();
    _battery = _dataFields.getBattery();
    _recoveryTime = _dataFields.getRecoveryTime();
    getSunInfo();

    //_dataFields.subscribeComplications();
    //WatchUi.requestUpdate(); // not really required, onUpdate will be called anyway.
  }

  // Updates the View:
  // Called once a minute in low power mode.
  // Called every second in high power mode, e.g. after a gesture, for a couple of seconds.
  function onUpdate(dc as Dc) as Void {
    //System.println("onUpdate");
    clearScreen(dc);

    if (_hidden || _lowPwrMode) {
      //System.println("low power mode");
      // it looks like onUpdate isn't called in hidden / low power mode when AOD is off, so this isn't needed.
      // if (_settings.battLogEnabled) {
      //   _dataFields.getBattery();
      // }
      return;
    }

    if (ShowBatteryHistory) {
      dc.setColor(_isDay ? _settings.textColorDay : _settings.textColorNight, _settings.bgColor);
      
      if (!_settings.battLogEnabled) {
        dc.drawText(_devCenter, _devCenter, Graphics.FONT_SMALL, "Battery Log Disabled", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        return;
      }

      var history = Settings.getStorageValue("BatteryHistory", "");
      var entries = Utils.splitString(history, ",");

      if (entries.size() == 0) {
        dc.drawText(_devCenter, _devCenter, Graphics.FONT_SMALL, "No Battery History", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        return;
      }
      
      var y = _pos_history_start_y;
      for (var i = 0; i < entries.size(); i++) {
        dc.drawText(_devCenter, y, Graphics.FONT_TINY, entries[i], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        y += _pos_history_line_height;
      }
      
      return;
    }

    // get the device settings
    var deviceSettings = System.getDeviceSettings();

    // Get the date info, the strings will be localized.
    var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

    // do not disturb / sleep mode display
    if (deviceSettings.doNotDisturb) {
      dc.setColor(_settings.textColorSleep, _settings.bgColor);

      // phone connected
      if (deviceSettings.phoneConnected) {
        dc.drawText(_devCenter, _pos_dnd_phone_y, _iconFont, "b", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
      }
      
      // date
      var date = Lang.format("$1$ $2$ $3$", [dateInfo.day_of_week, dateInfo.day.format("%02d"), dateInfo.month]);
      dc.drawText(_devCenter, _pos_dnd_date_y, Graphics.FONT_SMALL, date, Graphics.TEXT_JUSTIFY_CENTER);
      
      // hour
      dc.drawText(_devCenter - _pos_time_offset_x, _devCenter, _timeFont, dateInfo.hour.format("%02d"), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
      
      // minute
      dc.drawText(_devCenter + _pos_time_offset_x, _devCenter, _timeFont, dateInfo.min.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

      // heart rate
      dc.drawText(_devCenter - _pos_time_center_offset_x, _pos_dnd_hr_icon_y, _iconFont, "h", Graphics.TEXT_JUSTIFY_RIGHT);
      dc.drawText(_devCenter - _pos_dnd_hr_text_offset_x, _pos_dnd_hr_text_y, Graphics.FONT_SMALL, _dataFields.getHeartRate(), Graphics.TEXT_JUSTIFY_RIGHT);
      
      // battery
      dc.drawText(_devCenter + _pos_time_center_offset_x, _pos_dnd_batt_icon_y, _iconFont, "B", Graphics.TEXT_JUSTIFY_LEFT);
      dc.drawText(_devCenter + _pos_dnd_batt_text_offset_x, _pos_dnd_batt_text_y, Graphics.FONT_SMALL, _battery, Graphics.TEXT_JUSTIFY_LEFT);

      // lines for positioning   
      drawGrid(dc);
      return;
    }

    // foreground color
    dc.setColor(_isDay ? _settings.textColorDay : _settings.textColorNight, _settings.bgColor);
    
    // date
    var date = Lang.format("$1$ $2$ $3$", [dateInfo.day_of_week, dateInfo.day.format("%02d"), dateInfo.month]);
    dc.drawText(_devCenter, _pos_date_y, Graphics.FONT_SMALL, date, Graphics.TEXT_JUSTIFY_CENTER);

    // sunrise and sunset
    dc.drawText(_devCenter, _pos_sunrise_y, _iconFont, "S", Graphics.TEXT_JUSTIFY_CENTER);
    dc.drawText(_devCenter - _pos_sunrise_offset_x, _pos_sunrise_text_y, Graphics.FONT_SMALL, _sunriseText, Graphics.TEXT_JUSTIFY_RIGHT);
    dc.drawText(_devCenter + _pos_sunrise_offset_x, _pos_sunrise_text_y, Graphics.FONT_SMALL, _sunsetText, Graphics.TEXT_JUSTIFY_LEFT);

    // phone connected
    if (deviceSettings.phoneConnected) {
      dc.drawText(_pos_phone_x, _pos_phone_y, _iconFont, "b", Graphics.TEXT_JUSTIFY_LEFT);
    }

    // hour
    dc.drawText(_devCenter - _pos_time_offset_x, _pos_time_y, _timeFont, dateInfo.hour.format("%02d"), Graphics.TEXT_JUSTIFY_RIGHT);
      
    // minute
    dc.drawText(_devCenter + _pos_time_offset_x, _pos_time_y, _timeFont, dateInfo.min.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT);

    // seconds
    dc.drawText(_pos_seconds_x, _pos_seconds_y, Graphics.FONT_SMALL, dateInfo.sec.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT);

    // steps
    dc.drawText(_devCenter - _pos_time_center_offset_x, _pos_steps_icon_y, _iconFont, "s", Graphics.TEXT_JUSTIFY_RIGHT);
    dc.drawText(_pos_steps_text_x, _pos_steps_text_y, Graphics.FONT_SMALL, _steps, Graphics.TEXT_JUSTIFY_RIGHT);

    // recovery time
    dc.drawText(_devCenter - _pos_time_center_offset_x, _pos_recovery_icon_y, _iconFont, "r", Graphics.TEXT_JUSTIFY_RIGHT);
    dc.drawText(_pos_recovery_text_x, _pos_recovery_text_y, Graphics.FONT_SMALL, _recoveryTime, Graphics.TEXT_JUSTIFY_RIGHT);

    // heart rate
    dc.drawText(_devCenter + _pos_time_center_offset_x, _pos_hr_offset_x, _iconFont, "h", Graphics.TEXT_JUSTIFY_LEFT);
    dc.drawText(_devCenter + _pos_hr_text_offset_x, _pos_steps_text_y, Graphics.FONT_SMALL, _dataFields.getHeartRate(), Graphics.TEXT_JUSTIFY_LEFT);
    
    // battery
    dc.drawText(_devCenter + _pos_time_center_offset_x, _pos_batt_offset_x, _iconFont, "B", Graphics.TEXT_JUSTIFY_LEFT);
    dc.drawText(_devCenter + _pos_batt_text_offset_x, _pos_recovery_text_y, Graphics.FONT_SMALL, _battery, Graphics.TEXT_JUSTIFY_LEFT);

    // lines for positioning
    drawGrid(dc);
  }

  // Helper function to scale a coordinate value based on device resolution.
  private function scale(value as Number) as Number {
    return (value * _scale).toNumber();
  }

  // If the location is not available, use the last known location from storage.
  // Also check if it's day or night based on the current time and sunrise/sunset times.  
  private function getSunInfo() {
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
      _sunriseText = sunriseInfo.hour.format("%02d") + ":" + sunriseInfo.min.format("%02d");
      
      // get sunset time
      var sunset = Weather.getSunset(location, now);
      var sunsetInfo = Gregorian.info(sunset, Time.FORMAT_MEDIUM);
      _sunsetText = sunsetInfo.hour.format("%02d") + ":" + sunsetInfo.min.format("%02d");

      // check if it's day or night
      _isDay = now.value() >= sunrise.value() && now.value() <= sunset.value();
      return;
    }
    
    // no location info, use default values
    var dateInfo = Gregorian.info(now, Time.FORMAT_SHORT);
    _isDay = dateInfo.hour > 5 && dateInfo.hour < 18;
  }
  
  (:debug)
  private function clearScreen(dc as Dc) {
    dc.setColor(0, _settings.bgColor);
    dc.clear();
  }

  (:release)
  private function clearScreen(dc as Dc) {
    // no need for this on actual device
  }

  // lines for layout positioning
  private function drawGrid(dc as Dc) {
    if (!_settings.showGrid) {
      return;
    }

    var i = 0;
    var gapSize = _devSize / 16.0;

    dc.setColor(Graphics.COLOR_DK_GRAY, -1);
    do {
      i += gapSize;
      dc.drawLine(0, i, _devSize, i); // horizontal line
      dc.drawLine(i, 0, i, _devSize); // vertical line
      //dc.drawCircle(_devCenter,_devCenter,i);  // x,y,r
    } while (i < _devSize);

    i = _devCenter;
    dc.setColor(Graphics.COLOR_LT_GRAY, -1);
    dc.drawLine(0, i, _devSize, i); // horizontal line
    dc.drawLine(i, 0, i, _devSize); // vertical line
  }
}
