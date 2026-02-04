import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// https://developer.garmin.com/connect-iq/api-docs/Toybox/Application/AppBase.html
class WatchFaceApp extends Application.AppBase {
    private var _faceView = null;

    function initialize() {
        Utils.println("app.initialize");
        AppBase.initialize();
    }

    // Called on application start up.
    function onStart(state as Dictionary?) as Void {
        Utils.println("app.onStart");
    }

    // Called when your application is exiting.
    function onStop(state as Dictionary?) as Void {
        Utils.println("app.onStop");
    }

    // Return the initial view of your application here.
    function getInitialView() as [Views] or [Views, InputDelegates] {
        Utils.println("app.getInitialView");
        _faceView = new WatchFaceView();
        return [_faceView, new WatchDelegate()];
    }

    // Return the settings view of your application here.
    function getSettingsView() {
        Utils.println("app.getSettingsView");
        return [new ODSettingsMenu(), new ODSettingsMenuDelegate()];
    }

    // Called when settings have changed via the ConnectIQ phone app.
    function onSettingsChanged() as Void {
        Utils.println("app.onSettingsChanged");
        refreshWatchUi(true, true);
    }

    // Refresh the watch face UI.
    function refreshWatchUi(loadSettings as Boolean, requestUpdate as Boolean) as Void {
        if (_faceView == null) {
            return;
        }

        if (loadSettings) {
            _faceView.loadSettings();
        }

        if (requestUpdate) {
            WatchUi.requestUpdate();
        }
    }
}

function getApp() as WatchFaceApp {
    return Application.getApp() as WatchFaceApp;
}
