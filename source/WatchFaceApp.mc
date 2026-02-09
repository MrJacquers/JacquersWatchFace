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

    // Return the on-device settings view of your application here.
    function getSettingsView() {
        Utils.println("app.getSettingsView");
        return [new ODSettingsMenu(), new ODSettingsMenuDelegate()];
    }

    // Called when settings have changed via the ConnectIQ app.
    function onSettingsChanged() as Void {
        Utils.println("app.onSettingsChanged");
        loadSettings(true);
    }

    // Load the settings.
    function loadSettings(requestUpdate as Boolean) as Void {
        Utils.println("app.loadSettings: requestUpdate=" + requestUpdate);

        if (_faceView == null) {
            Utils.println("app.loadSettings: _faceView is null");
            return;
        }
        
        _faceView.loadSettings();

        if (!requestUpdate) {
            return;
        }

        if (WatchUi == null) {
            Utils.println("app.loadSettings: WatchUi is null");
            return;
        }

        WatchUi.requestUpdate();
    }
}

function getApp() as WatchFaceApp {
    return Application.getApp() as WatchFaceApp;
}
