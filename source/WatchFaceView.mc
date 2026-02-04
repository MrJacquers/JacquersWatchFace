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
  private var _recoveryTime;
  private var _steps;

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
  private var _pos_dnd_batt_icon_y;
  private var _pos_dnd_batt_text_y;
  // Battery history
  private var _pos_history_start_y;
  private var _pos_history_line_height;

  function initialize() {
    Utils.println("view.initialize");
    WatchFace.initialize();

    _dataFields = new DataFields();
    loadSettings();
  }

  function onLayout(dc as Dc) as Void {
    Utils.println("view.onLayout");
    _devSize = dc.getWidth();
    _devCenter = _devSize / 2;

    if (_devSize == 454) {
      // FR965
      _iconFont = WatchUi.loadResource(Rez.Fonts.icons_36);
      _timeFont = WatchUi.loadResource(Rez.Fonts.oxanium_96);
    } else if (_devSize == 390) {
      // FR165M
      _iconFont = WatchUi.loadResource(Rez.Fonts.icons_30);
      _timeFont = WatchUi.loadResource(Rez.Fonts.oxanium_82);
    } else {
      // FR255M
      _iconFont = WatchUi.loadResource(Rez.Fonts.icons_20);
      _timeFont = WatchUi.loadResource(Rez.Fonts.oxanium_54);
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
    _pos_seconds_y = scale(194);
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
    _pos_dnd_batt_icon_y = scale(300);
    _pos_dnd_batt_text_y = scale(295);

    // Battery history
    _pos_history_start_y = scale(50);
    _pos_history_line_height = scale(40);
  }

  // Called when this View is brought to the foreground.
  // Restore the state of this View and prepare it to be shown.
  // This includes loading resources into memory.
  function onShow() as Void {
    Utils.println("view.onShow");
    _hidden = false;    
    _lowPwrMode = false; // only required in simulator in some cases, like changing display power modes

    // get data that isn't updated frequently
    _steps = _dataFields.getSteps();
    _recoveryTime = _dataFields.getRecoveryTime();
    _dataFields.getSunInfo();
    //_dataFields.subscribeComplications();
  }

  // Called when this View is removed from the screen.
  // Save the state of this View here.
  // This includes freeing resources from memory.
  function onHide() as Void {
    Utils.println("view.onHide");
    _hidden = true;
    //_dataFields.unsubscribeComplications();
  }

  // Low power mode, updates happen once a minute.
  function onEnterSleep() as Void {
    Utils.println("view.onEnterSleep");
    _lowPwrMode = true;
    //_dataFields.unsubscribeComplications();
  }

  // Triggered by gesture / button press.
  function onExitSleep() as Void {
    Utils.println("view.onExitSleep");
    _lowPwrMode = false;

    // get data that isn't updated frequently
    _steps = _dataFields.getSteps();
    _recoveryTime = _dataFields.getRecoveryTime();
    _dataFields.getSunInfo();
    //_dataFields.subscribeComplications();
  }

  // Updates the View:
  // Called once a minute in low power mode.
  // Called every second in high power mode, e.g. after a gesture, for a couple of seconds.
  // It looks like onUpdate isn't called in hidden / low power mode when AOD is off on Amoled devices.
  // https://developer.garmin.com/connect-iq/connect-iq-faq/how-do-i-make-a-watch-face-for-amoled-products/
  function onUpdate(dc as Dc) as Void {
    Utils.println("view.onUpdate");
    clearScreen(dc);

    if (_hidden) {
      Utils.println("hidden");
      return;
    }

    // get device settings
    var deviceSettings = System.getDeviceSettings();

    // get the date info, the strings will be localized.
    var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

    // do not disturb / sleep mode display // TODO: look at night mode as well?
    if (deviceSettings.doNotDisturb) {
      dc.setColor(_settings.textColorSleep, Graphics.COLOR_TRANSPARENT);
      drawLowPowerMode(dc, dateInfo, deviceSettings);
      return;
    }

    // foreground color
    dc.setColor(_dataFields.isDay ? _settings.textColorDay : _settings.textColorNight, Graphics.COLOR_TRANSPARENT);

    // low power mode display
    if (_lowPwrMode) {
      drawLowPowerMode(dc, dateInfo, deviceSettings);
      return;
    }

    // battery log display
    if (_settings.showBatteryLog) {
      drawBatteryHistory(dc);
      return;
    }

    // normal full power mode display

    // date
    var date = Lang.format("$1$ $2$ $3$", [dateInfo.day_of_week, dateInfo.day.format("%02d"), dateInfo.month]);
    dc.drawText(_devCenter, _pos_date_y, Graphics.FONT_SMALL, date, Graphics.TEXT_JUSTIFY_CENTER);

    // sunrise and sunset
    dc.drawText(_devCenter, _pos_sunrise_y, _iconFont, "S", Graphics.TEXT_JUSTIFY_CENTER);
    dc.drawText(_devCenter - _pos_sunrise_offset_x, _pos_sunrise_text_y, Graphics.FONT_SMALL, _dataFields.sunriseText, Graphics.TEXT_JUSTIFY_RIGHT);
    dc.drawText(_devCenter + _pos_sunrise_offset_x, _pos_sunrise_text_y, Graphics.FONT_SMALL, _dataFields.sunsetText, Graphics.TEXT_JUSTIFY_LEFT);

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

    // battery - may be out of date in the simulator
    dc.drawText(_devCenter + _pos_time_center_offset_x, _pos_batt_offset_x, _iconFont, "B", Graphics.TEXT_JUSTIFY_LEFT);
    dc.drawText(_devCenter + _pos_batt_text_offset_x, _pos_recovery_text_y, Graphics.FONT_SMALL, _dataFields.getBattery(), Graphics.TEXT_JUSTIFY_LEFT);

    // lines for positioning
    drawGrid(dc);
  }

  // AOD or MIP screen low power mode display.
  private function drawLowPowerMode(dc as Dc, dateInfo as Gregorian.Info, deviceSettings as DeviceSettings) as Void {
    Utils.println("drawLowPowerMode");

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

    // battery
    dc.drawText(_devCenter - _pos_time_center_offset_x, _pos_dnd_batt_icon_y, _iconFont, "B", Graphics.TEXT_JUSTIFY_RIGHT);
    dc.drawText(_devCenter + _pos_time_center_offset_x, _pos_dnd_batt_text_y, Graphics.FONT_SMALL, _dataFields.getBattery(), Graphics.TEXT_JUSTIFY_LEFT);

    // lines for positioning
    drawGrid(dc);
  }

  function drawBatteryHistory(dc as Dc) as Void {
    if (!_settings.batteryLogEnabled) {
      dc.drawText(_devCenter, _devCenter, Graphics.FONT_SMALL, "Battery Log Disabled", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
      return;
    }

    _dataFields.getBattery();
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
  }

  (:debug)
  private function clearScreen(dc as Dc) {
    dc.setColor(0, _settings.bgColor);
    dc.clear();
  }

  (:release)
  private function clearScreen(dc as Dc) {
    // No operation in release mode, dc.clear() is called automatically.
  }

  // draw lines for layout positioning
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

  // load settings
  function loadSettings() {
    if (_settings == null) {
      _settings = new Settings();
    }

    _settings.loadSettings();
    Utils.println("Loaded settings: " + _settings.toString());

    if (_dataFields != null) {
      _dataFields.batteryLogEnabled = _settings.batteryLogEnabled;
    }
  }

  // Helper function to scale a coordinate value based on device resolution.
  private function scale(value as Number) as Number {
    return (value * _scale).toNumber();
  }
}
