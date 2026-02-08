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
  // Date
  private var _date_x;
  private var _date_y;
  private var _date_align;
  // Sunrise/Sunset
  private var _sunrise_icon_x;
  private var _sunrise_icon_y;
  private var _sunrise_icon_align;
  private var _sunrise_text_x;
  private var _sunrise_text_y;
  private var _sunrise_text_align;
  private var _sunset_text_x;
  private var _sunset_text_y;
  private var _sunset_text_align;
  // Phone
  private var _phone_x;
  private var _phone_y;
  private var _phone_align;
  // Time
  private var _hour_x;
  private var _hour_y;
  private var _hour_align;
  private var _minute_x;
  private var _minute_y;
  private var _minute_align;
  // Seconds
  private var _seconds_x;
  private var _seconds_y;
  private var _seconds_align;
  // Steps
  private var _steps_icon_x;
  private var _steps_icon_y;
  private var _steps_icon_align;
  private var _steps_text_x;
  private var _steps_text_y;
  private var _steps_text_align;
  // Recovery
  private var _recovery_icon_x;
  private var _recovery_icon_y;
  private var _recovery_icon_align;
  private var _recovery_text_x;
  private var _recovery_text_y;
  private var _recovery_text_align;
  // Heart Rate
  private var _hr_icon_x;
  private var _hr_icon_y;
  private var _hr_icon_align;
  private var _hr_text_x;
  private var _hr_text_y;
  private var _hr_text_align;
  // Battery
  private var _batt_icon_x;
  private var _batt_icon_y;
  private var _batt_icon_align;
  private var _batt_text_x;
  private var _batt_text_y;
  private var _batt_text_align;
  // DND mode coordinates
  private var _dnd_phone_x;
  private var _dnd_phone_y;
  private var _dnd_phone_align;
  private var _dnd_date_x;
  private var _dnd_date_y;
  private var _dnd_date_align;
  private var _dnd_hour_x;
  private var _dnd_hour_y;
  private var _dnd_hour_align;
  private var _dnd_minute_x;
  private var _dnd_minute_y;
  private var _dnd_minute_align;
  private var _dnd_batt_icon_x;
  private var _dnd_batt_icon_y;
  private var _dnd_batt_icon_align;
  private var _dnd_batt_text_x;
  private var _dnd_batt_text_y;
  private var _dnd_batt_text_align;
  // Battery history
  private var _history_start_y;
  private var _history_line_height;

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
      // FR965 (454x454)
      _iconFont = WatchUi.loadResource(Rez.Fonts.icons_36);
      _timeFont = WatchUi.loadResource(Rez.Fonts.oxanium_96);
      // Date
      _date_x = _devCenter;
      _date_y = 30;
      // Sunrise/Sunset
      _sunrise_icon_x = _devCenter;
      _sunrise_icon_y = 95;
      _sunrise_text_x = _devCenter - 35;
      _sunrise_text_y = 90;
      _sunset_text_x = _devCenter + 35;
      _sunset_text_y = 90;
      // Phone
      _phone_x = 65;
      _phone_y = 185;
      // Time
      _hour_x = _devCenter - 5;
      _hour_y = 170;
      _minute_x = _devCenter + 5;
      _minute_y = 170;
      // Seconds
      _seconds_x = 350;
      _seconds_y = 195;
      // Steps
      _steps_icon_x = _devCenter - 10;
      _steps_icon_y = 279;
      _steps_text_x = 170;
      _steps_text_y = 271;
      // Recovery
      _recovery_icon_x = _devCenter - 10;
      _recovery_icon_y = 335;
      _recovery_text_x = 170;
      _recovery_text_y = 330;
      // Heart Rate
      _hr_icon_x = _devCenter + 10;
      _hr_icon_y = 279;
      _hr_text_x = _devCenter + 55;
      _hr_text_y = 271;
      // Battery
      _batt_icon_x = _devCenter + 10;
      _batt_icon_y = 335;
      _batt_text_x = _devCenter + 55;
      _batt_text_y = 330;
      // DND mode
      _dnd_phone_x = _devCenter;
      _dnd_phone_y = 55;
      _dnd_date_x = _devCenter;
      _dnd_date_y = 105;
      _dnd_hour_x = _devCenter - 5;
      _dnd_hour_y = _devCenter;
      _dnd_minute_x = _devCenter + 5;
      _dnd_minute_y = _devCenter;
      _dnd_batt_icon_x = _devCenter - 2;
      _dnd_batt_icon_y = 300;
      _dnd_batt_text_x = _devCenter + 2;
      _dnd_batt_text_y = 295;
      // Battery history
      _history_start_y = 50;
      _history_line_height = 40;
    } else if (_devSize == 260) {
      // Smaller device (260x260)
      _iconFont = WatchUi.loadResource(Rez.Fonts.icons_20);
      _timeFont = WatchUi.loadResource(Rez.Fonts.oxanium_54);
      // Date
      _date_x = _devCenter;
      _date_y = 17;
      // Sunrise/Sunset
      _sunrise_icon_x = _devCenter;
      _sunrise_icon_y = 56;
      _sunrise_text_x = _devCenter - 20;
      _sunrise_text_y = 51;
      _sunset_text_x = _devCenter + 20;
      _sunset_text_y = 51;
      // Phone
      _phone_x = 37;
      _phone_y = 106;
      // Time
      _hour_x = _devCenter - 3;
      _hour_y = 97;
      _minute_x = _devCenter + 3;
      _minute_y = 97;
      // Seconds
      _seconds_x = 200;
      _seconds_y = 109;
      // Steps
      _steps_icon_x = _devCenter - 6;
      _steps_icon_y = 160;
      _steps_text_x = 97;
      _steps_text_y = 155;
      // Recovery
      _recovery_icon_x = _devCenter - 6;
      _recovery_icon_y = 194;
      _recovery_text_x = 97;
      _recovery_text_y = 189;
      // Heart Rate
      _hr_icon_x = _devCenter + 6;
      _hr_icon_y = 160;
      _hr_text_x = _devCenter + 31;
      _hr_text_y = 155;
      // Battery
      _batt_icon_x = _devCenter + 6;
      _batt_icon_y = 194;
      _batt_text_x = _devCenter + 31;
      _batt_text_y = 189;
      // DND mode
      _dnd_phone_x = _devCenter;
      _dnd_phone_y = 37;
      _dnd_date_x = _devCenter;
      _dnd_date_y = 60;
      _dnd_hour_x = _devCenter - 3;
      _dnd_hour_y = _devCenter;
      _dnd_minute_x = _devCenter + 3;
      _dnd_minute_y = _devCenter;
      _dnd_batt_icon_x = _devCenter - 2;
      _dnd_batt_icon_y = 173;
      _dnd_batt_text_x = _devCenter + 2;
      _dnd_batt_text_y = 169;
      // Battery history
      _history_start_y = 29;
      _history_line_height = 23;
    }

    _date_align = Graphics.TEXT_JUSTIFY_CENTER;
    _sunrise_icon_align = Graphics.TEXT_JUSTIFY_CENTER;
    _sunrise_text_align = Graphics.TEXT_JUSTIFY_RIGHT;
    _sunset_text_align = Graphics.TEXT_JUSTIFY_LEFT;
    _phone_align = Graphics.TEXT_JUSTIFY_LEFT;
    _hour_align = Graphics.TEXT_JUSTIFY_RIGHT;
    _minute_align = Graphics.TEXT_JUSTIFY_LEFT;
    _seconds_align = Graphics.TEXT_JUSTIFY_LEFT;
    _steps_icon_align = Graphics.TEXT_JUSTIFY_RIGHT;
    _steps_text_align = Graphics.TEXT_JUSTIFY_RIGHT;
    _recovery_icon_align = Graphics.TEXT_JUSTIFY_RIGHT;
    _recovery_text_align = Graphics.TEXT_JUSTIFY_RIGHT;
    _hr_icon_align = Graphics.TEXT_JUSTIFY_LEFT;
    _hr_text_align = Graphics.TEXT_JUSTIFY_LEFT;
    _batt_icon_align = Graphics.TEXT_JUSTIFY_LEFT;
    _batt_text_align = Graphics.TEXT_JUSTIFY_LEFT;
    _dnd_phone_align = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
    _dnd_date_align = Graphics.TEXT_JUSTIFY_CENTER;
    _dnd_hour_align = Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER;
    _dnd_minute_align = Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER;
    _dnd_batt_icon_align = Graphics.TEXT_JUSTIFY_RIGHT;
    _dnd_batt_text_align = Graphics.TEXT_JUSTIFY_LEFT;
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
    dc.drawText(_date_x, _date_y, Graphics.FONT_SMALL, date, _date_align);

    // sunrise and sunset
    dc.drawText(_sunrise_icon_x, _sunrise_icon_y, _iconFont, "S", _sunrise_icon_align);
    dc.drawText(_sunrise_text_x, _sunrise_text_y, Graphics.FONT_SMALL, _dataFields.sunriseText, _sunrise_text_align);
    dc.drawText(_sunset_text_x, _sunset_text_y, Graphics.FONT_SMALL, _dataFields.sunsetText, _sunset_text_align);

    // phone connected
    if (deviceSettings.phoneConnected) {
      dc.drawText(_phone_x, _phone_y, _iconFont, "b", _phone_align);
    }

    // hour
    dc.drawText(_hour_x, _hour_y, _timeFont, dateInfo.hour.format("%02d"), _hour_align);

    // minute
    dc.drawText(_minute_x, _minute_y, _timeFont, dateInfo.min.format("%02d"), _minute_align);

    // seconds
    dc.drawText(_seconds_x, _seconds_y, Graphics.FONT_SMALL, dateInfo.sec.format("%02d"), _seconds_align);

    // steps
    dc.drawText(_steps_icon_x, _steps_icon_y, _iconFont, "s", _steps_icon_align);
    dc.drawText(_steps_text_x, _steps_text_y, Graphics.FONT_SMALL, _steps, _steps_text_align);

    // recovery time
    dc.drawText(_recovery_icon_x, _recovery_icon_y, _iconFont, "r", _recovery_icon_align);
    dc.drawText(_recovery_text_x, _recovery_text_y, Graphics.FONT_SMALL, _recoveryTime, _recovery_text_align);

    // heart rate
    dc.drawText(_hr_icon_x, _hr_icon_y, _iconFont, "h", _hr_icon_align);
    dc.drawText(_hr_text_x, _hr_text_y, Graphics.FONT_SMALL, _dataFields.getHeartRate(), _hr_text_align);

    // battery - may be out of date in the simulator
    dc.drawText(_batt_icon_x, _batt_icon_y, _iconFont, "B", _batt_icon_align);
    dc.drawText(_batt_text_x, _batt_text_y, Graphics.FONT_SMALL, _dataFields.getBattery(), _batt_text_align);

    // lines for positioning
    drawGrid(dc);
  }

  // AOD or MIP screen low power mode display.
  private function drawLowPowerMode(dc as Dc, dateInfo as Gregorian.Info, deviceSettings as DeviceSettings) as Void {
    Utils.println("drawLowPowerMode");

    // phone connected
    if (deviceSettings.phoneConnected) {
      dc.drawText(_dnd_phone_x, _dnd_phone_y, _iconFont, "b", _dnd_phone_align);
    }

    // date
    var date = Lang.format("$1$ $2$ $3$", [dateInfo.day_of_week, dateInfo.day.format("%02d"), dateInfo.month]);
    dc.drawText(_dnd_date_x, _dnd_date_y, Graphics.FONT_SMALL, date, _dnd_date_align);

    // hour
    dc.drawText(_dnd_hour_x, _dnd_hour_y, _timeFont, dateInfo.hour.format("%02d"), _dnd_hour_align);

    // minute
    dc.drawText(_dnd_minute_x, _dnd_minute_y, _timeFont, dateInfo.min.format("%02d"), _dnd_minute_align);

    // battery
    dc.drawText(_dnd_batt_icon_x, _dnd_batt_icon_y, _iconFont, "B", _dnd_batt_icon_align);
    dc.drawText(_dnd_batt_text_x, _dnd_batt_text_y, Graphics.FONT_SMALL, _dataFields.getBattery(), _dnd_batt_text_align);

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

    var y = _history_start_y;
    for (var i = 0; i < entries.size(); i++) {
      dc.drawText(_devCenter, y, Graphics.FONT_TINY, entries[i], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
      y += _history_line_height;
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
}
