import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

var BatteryLevel = 0;
var ShowBatteryHistory = false;

class WatchFaceApp extends Application.AppBase {
    private var _faceView = null;

    function initialize() {
        //System.println("app.initialize");
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        //System.println("app.onStart");

        //Settings.setValue("BatteryHistory", "");
        //Settings.setValue("BatteryHistory", "01 10:15 50");
        var dataFields = new DataFields();
        BatteryLevel = dataFields.getBatteryFromHistory();
        //System.println("BatteryLevel: " + BatteryLevel);
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        //System.println("app.onStop");
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        //System.println("getInitialView");
        _faceView = new WatchFaceView();
        return [_faceView, new WatchDelegate()];
    }

    function getSettingsView() {
        //System.println("getSettingsView");
        return [new ODSettingsMenu(), new ODSettingsMenuDelegate()];
    }

    // New app settings have been received, so trigger a UI update.
    // This applies to settings via ConnectIQ, not on-device settings.
    // When using ODS it looks like the app gets restarted, but not in the simulator.
    function onSettingsChanged() as Void {
        //System.println("onSettingsChanged");
        if (_faceView != null) {
            _faceView.loadSettings();
            WatchUi.requestUpdate();
        }
    }
}

function getApp() as WatchFaceApp {
    return Application.getApp() as WatchFaceApp;
}
