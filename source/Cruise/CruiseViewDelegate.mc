using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class CruiseViewDelegate extends Ui.BehaviorDelegate 
{
    hidden var _cruiseView;
    hidden var _gpsWrapper;
    
    function initialize(cruiseView, gpsWrapper) 
    {
        BehaviorDelegate.initialize();
        _cruiseView = cruiseView;
        _gpsWrapper = gpsWrapper;
    }    
    
    function onSelect()
    {
        // if recording available, make sound
        //
        if (_gpsWrapper.GetIsRecording()) {
            Ui.pushView(new Toybox.WatchUi.Confirmation("Stop Recording?"), new ConfirmStopDelegate(_gpsWrapper), Ui.SLIDE_RIGHT);
        } else if (_gpsWrapper.StartStopRecording())
        {
            SignalWrapper.PressButton();
        }
    	return true;
    }

    function onMenu() 
    {
        Ui.popView(Ui.SLIDE_RIGHT);
        return true;
    }
    
    function onBack()
    {
        if (_gpsWrapper.GetIsRecording()) {
            // Don't allow access to the save menu if we're still recording
            return true;
        }

        Ui.pushView(new Toybox.WatchUi.Confirmation("Save & Exit?"), new ConfirmSaveDelegate(_gpsWrapper), Ui.SLIDE_RIGHT);
        
        // if lap successfully added, make sound
        //
        //if (_gpsWrapper.AddLap())
        //{
        //    SignalWrapper.PressButton();
        //}
        return true;
    }
    
    function onNextPage()
    {
    	_cruiseView.SwitchNextMode();
        return true;
    }
}

class ConfirmSaveDelegate extends Ui.ConfirmationDelegate
{
	var _gpsWrapper;
	
	function initialize(gpsWrapper)
    {
        ConfirmationDelegate.initialize();
        _gpsWrapper = gpsWrapper;
    }
    
    function onResponse(value)
    {
        if( value == CONFIRM_YES )
        {
            _gpsWrapper.SaveRecord();
            Sys.exit();
        }
        return true;
    }
}

class ConfirmStopDelegate extends Ui.ConfirmationDelegate
{
	var _gpsWrapper;
	
	function initialize(gpsWrapper)
    {
        ConfirmationDelegate.initialize();
        _gpsWrapper = gpsWrapper;
    }
    
    function onResponse(value)
    {
        if( value == CONFIRM_YES )
        {
            if (_gpsWrapper.StartStopRecording())
            {
                SignalWrapper.PressButton();
            }
        }
        return true;
    }
}