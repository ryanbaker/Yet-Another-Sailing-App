using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

// main menu handler
//
class MainMenuDelegate extends Ui.MenuInputDelegate 
{
    hidden var _cruiseView;
    hidden var _gpsWrapper;
    hidden var _raceTimerView;
    hidden var _lapView;
    hidden var _waypointView;
    hidden var _selectRouteView;
    
    hidden var _routeCustomMenuView;
    
    function initialize(cruiseView, raceTimerView, lapView, waypointView, selectRouteView, routeCustomMenuView, gpsWrapper) 
    {
        MenuInputDelegate.initialize();
        
        _cruiseView = cruiseView;
        _raceTimerView = raceTimerView;
        _lapView = lapView;
        _waypointView = waypointView;
        _gpsWrapper = gpsWrapper;
        _selectRouteView = selectRouteView;
        _routeCustomMenuView = routeCustomMenuView;
    }

    function onMenuItem(item) 
    {
    	if (item == :raceTimer)
    	{
    		Ui.pushView(_raceTimerView, new RaceTimerViewDelegate(_raceTimerView), Ui.SLIDE_RIGHT);
    	}
        else if (item == :cruiseView)
        {
            Ui.pushView(_cruiseView, new CruiseViewDelegate(_cruiseView, _gpsWrapper), Ui.SLIDE_RIGHT);
        }
        else if (item == :routeMenu)
        {
        	Ui.pushView(_routeCustomMenuView, new RouteCustomMenuDelegate(_routeCustomMenuView), Ui.SLIDE_RIGHT);
        }
        else if (item == :lapView)
        {
            Ui.pushView(_lapView, new LapViewDelegate(_lapView), Ui.SLIDE_RIGHT);
        }         
        else if (item == :setting)
        {
            Ui.pushView(new Rez.Menus.SettingMenu(), new SettingMenuDelegate(_raceTimerView), Ui.SLIDE_LEFT);
        }
        //else if (item == :exitSave) 
        //{
        //    _gpsWrapper.SaveRecord();
        //    Sys.exit();
        //} 
        else if (item == :exitDiscard) 
        {
            if(_gpsWrapper.GetIsRecording()) {
                Ui.showToast("Stop Recording before Discarding", null);
            } else {
                Ui.pushView(new Toybox.WatchUi.Confirmation("Discard & Exit?"), new ConfirmDiscardDelegate(_gpsWrapper), Ui.SLIDE_RIGHT);
            }
        }   
    }
}

class ConfirmDiscardDelegate extends Ui.ConfirmationDelegate
{
	var _gpsWrapper;
    var timer = null;
	
	function initialize(gpsWrapper)
    {
        ConfirmationDelegate.initialize();
        _gpsWrapper = gpsWrapper;
    }
    
    function onResponse(value)
    {
        if( value == CONFIRM_YES )
        {
            if (_gpsWrapper.GetHasRecorded()) {
              _gpsWrapper.DiscardRecord();
              Sys.exit();
            } else {
              // If no session has been recorded, we need to start recording before
              // we can discard, otherwise there will be a weird battery drain issue.
              if (_gpsWrapper.StartRecording())
              {
                  SignalWrapper.PressButton();
                  // Need to let the recording start for a short period before
                  // discarding, otherwise there is another weird bug where the
                  // system discard menu will show up afterwards.
                  timer = new Timer.Timer();
                  timer.start(self.method(:finishDiscard), 1000, false);
              } else {
                  Ui.showToast("Discard hack failed!", null);
              }
            }
        }
        return true;
    }

    function finishDiscard() as Void
    {
        timer.stop();
        timer = null;
        _gpsWrapper.DiscardRecord();
        Sys.exit();
    }
}

