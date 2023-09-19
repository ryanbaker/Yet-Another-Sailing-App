using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class CruiseView extends Ui.View 
{
    hidden var _gpsWrapper;
	hidden var _timer;
	hidden var _isAvgSpeedDisplay = true;
	hidden var _displayMode = 0;
	hidden var _cruiseViewDc;
    hidden var _duration = null;
    hidden var _accuracy = 0;
    hidden var _moving = 0;
    hidden var _stopped = 0;

    function initialize(gpsWrapper, cruiseViewDc) 
    {
        View.initialize();
        _gpsWrapper = gpsWrapper;
        _cruiseViewDc = cruiseViewDc;
    }

	// SetUp timer on show to update every second
    //
    function onShow() 
    {
    	_timer = new Toybox.Timer.Timer();
    	_timer.start(method(:onTimerUpdate), 1000, true);
    }

    // Stop timer then hide
    //
    function onHide() 
    {
        _timer.stop();
    }
    
    // Refresh view every second
    //
    function onTimerUpdate() as Void
    {
        Ui.requestUpdate();
    }    

    // Update the view
    //
    function onUpdate(dc) 
    {   
    	_cruiseViewDc.ClearDc(dc);
    
    	// Display current time
    	//
        var clockTime = Sys.getClockTime();        
        _cruiseViewDc.PrintTime(dc, clockTime);
        
        // Display speed and bearing if GPS available
        //
        var gpsInfo = _gpsWrapper.GetGpsInfo();
        if (_accuracy < 4 && gpsInfo.Accuracy == 4) {
            // Vibrate the watch when we get a gps lock
			SignalWrapper.Start();
        }
        _accuracy = gpsInfo.Accuracy;

        if (gpsInfo.Accuracy > 0) {
            // Check if we should prompt to start or stop recording
            if (!_gpsWrapper.GetIsRecording()) {
                if (gpsInfo.SpeedKnot > 2.0) {
                    _moving++;
                    // Only prompt at exactly 10. This way you won't be prompted again unless
                    // the speed drops back below the threshold
                    if (_moving == 10) {
                        SignalWrapper.Start();
                        Ui.pushView(new Toybox.WatchUi.Confirmation("Start Recording?"), new ConfirmStartStopDelegate(_gpsWrapper), Ui.SLIDE_RIGHT);
                    }
                } else {
                    _moving = 0;
                }
            } else {
                if (gpsInfo.AvgSpeedKnot < 1.0) {
                    _stopped++;
                    if (_stopped == 60) {
                        SignalWrapper.Start();
                        Ui.pushView(new Toybox.WatchUi.Confirmation("Stop Recording?"), new ConfirmStartStopDelegate(_gpsWrapper), Ui.SLIDE_RIGHT);
                    }
                } else {
                    _stopped = 0;
                }
            }
        }

//        if (gpsInfo.Accuracy > 0)
        {
        	_cruiseViewDc.PrintSpeed(dc, gpsInfo.SpeedKnot);
        	//_cruiseViewDc.PrintBearing(dc, gpsInfo.BearingDegree);
        	_cruiseViewDc.PrintMaxSpeed(dc, gpsInfo.MaxSpeedKnot);	
        	_cruiseViewDc.PrintTotalDistance(dc, gpsInfo.TotalDistance);
        	
        	if (_displayMode == 0)
        	{
                if (gpsInfo.StartTime != null && gpsInfo.IsRecording) {
                    _duration = Time.now().subtract(gpsInfo.StartTime);
                }
               _cruiseViewDc.PrintDuration(dc, _duration);
        	} 
        	else if (_displayMode == 1)
        	{
        		_cruiseViewDc.PrintAvgBearing(dc, gpsInfo.AvgBearingDegree);
        		_cruiseViewDc.PrintAvgSpeed(dc, gpsInfo.AvgSpeedKnot);
        	} 

        	// Display speed gradient. If current speed > avg speed then trend is positive and vice versa.
        	//
        	_cruiseViewDc.DisplaySpeedTrend(dc, gpsInfo.SpeedKnot - gpsInfo.AvgSpeedKnot, gpsInfo.SpeedKnot); 
        }
        
        _cruiseViewDc.DisplayState(dc, gpsInfo.Accuracy, gpsInfo.IsRecording, gpsInfo.LapCount);
        
        _cruiseViewDc.DrawGrid(dc);
    }
    
    function SwitchNextMode()
    {
    	_displayMode += 1;
    	_displayMode = _displayMode % 2;
    }
}