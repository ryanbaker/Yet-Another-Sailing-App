using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.Time as Time;

/// Since there is no way to setup a background color in layout.xml
/// all boiler-plate code for drawing objects need to be done manually.
/// This class dedicated to hide all dirty work around dc
/// 
class CruiseView416Dc
{
	hidden var _gpsColorsArray = [Gfx.COLOR_RED, Gfx.COLOR_RED, Gfx.COLOR_ORANGE, Gfx.COLOR_YELLOW, Gfx.COLOR_GREEN];

	function ClearDc(dc)
	{
    	dc.setColor(Settings.ForegroundColor, Settings.BackgroundColor);
    	dc.clear();
    }

	function PrintTime(dc, time)
	{
        var center = dc.getWidth() / 2;
        var hour = time.hour;
        hour = hour % 12;
        hour = (hour == 0) ? 12 : hour;
        var timeString = Lang.format("$1$:$2$",
            [hour.format("%d"), time.min.format("%02d")]);
		dc.setColor(Settings.ForegroundColor, Settings.BackgroundColor);
        dc.drawText(center, 32, Gfx.FONT_MEDIUM, timeString, Gfx.TEXT_JUSTIFY_CENTER);
	}

    function PrintDuration(dc, duration)
    {
        var hour = 0;
        var min = 0;
        var sec = 0;

        if (duration != null) {
            hour = duration.value() / 60 / 60;
            min = duration.value() / 60 % 60;
            sec = duration.value() % 60;
        }

        var timerString = Lang.format("$1$:$2$:$3$",
            [hour.format("%02d"), min.format("%02d"), sec.format("%02d")]);
        dc.setColor(Settings.ForegroundColor, Settings.BackgroundColor);
        dc.drawText(208, 302, Gfx.FONT_LARGE, timerString, Gfx.TEXT_JUSTIFY_CENTER);
    }
	
    function PrintSpeed(dc, speed)
    {
        var speedString = speed.format("%2.1f");
    	dc.setColor(Settings.ForegroundColor, Settings.BackgroundColor);
        dc.drawText(200, 130, Gfx.FONT_NUMBER_HOT, speedString, Gfx.TEXT_JUSTIFY_RIGHT);
        dc.setColor(Settings.DimColor, Settings.BackgroundColor);
        dc.drawText(197, 255, Gfx.FONT_TINY, "SOG", Gfx.TEXT_JUSTIFY_RIGHT);
    }
    
    function PrintBearing(dc, bearing)
    {
        var bearingString = bearing.format("%003d");
    	dc.setColor(Settings.ForegroundColor, Settings.BackgroundColor);
        dc.drawText(216, 130, Gfx.FONT_NUMBER_HOT, bearingString, Gfx.TEXT_JUSTIFY_LEFT);
        dc.setColor(Settings.DimColor, Settings.BackgroundColor);
        dc.drawText(385, 255, Gfx.FONT_TINY, "COG", Gfx.TEXT_JUSTIFY_RIGHT);    
    }
    
    function PrintMaxSpeed(dc, maxSpeed)
    {
        var maxSpeedString = maxSpeed.format("%2.1f");
    	dc.setColor(Settings.ForegroundColor, Settings.BackgroundColor);
        dc.drawText(95, 243, Gfx.FONT_MEDIUM, maxSpeedString, Gfx.TEXT_JUSTIFY_RIGHT);
    }
    
    function PrintAvgSpeed(dc, avgSpeed)
    {
        var avgSpeedString = avgSpeed.format("%2.1f");
		dc.setColor(Settings.ForegroundColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(192, 302, Gfx.FONT_LARGE, avgSpeedString, Gfx.TEXT_JUSTIFY_RIGHT);

		dc.setColor(Settings.DimColor, Settings.BackgroundColor);
        dc.drawText(198, 352, Gfx.FONT_XTINY, "avg", Gfx.TEXT_JUSTIFY_RIGHT);
    }

    function PrintAvgBearing(dc, avgBearing)
    {
        var avgBearingString = avgBearing.format("%003d");
    	dc.setColor(Settings.ForegroundColor, Gfx.COLOR_TRANSPARENT);
		dc.drawText(218, 302, Gfx.FONT_LARGE, avgBearingString, Gfx.TEXT_JUSTIFY_LEFT);

    	dc.setColor(Settings.DimColor, Settings.BackgroundColor);
        dc.drawText(218, 352, Gfx.FONT_XTINY, "avg", Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(223 + dc.getTextWidthInPixels(avgBearingString, Gfx.FONT_LARGE), 295, Gfx.FONT_XTINY, "o", Gfx.TEXT_JUSTIFY_LEFT);
    }

    function PrintTotalDistance(dc, totalDistance)
    {
        var distanceString = totalDistance.format("%2.1f");
        if (totalDistance >= 10) {
            distanceString = totalDistance.format("%2d");
        }
		dc.setColor(Settings.ForegroundColor, Settings.BackgroundColor);
        dc.drawText(216, 130, Gfx.FONT_NUMBER_HOT, distanceString, Gfx.TEXT_JUSTIFY_LEFT);
        dc.setColor(Settings.DimColor, Settings.BackgroundColor);
        dc.drawText(366, 255, Gfx.FONT_TINY, "NM", Gfx.TEXT_JUSTIFY_RIGHT);
     }
    
    function DrawGrid(dc)
    {
    	dc.setColor(Settings.ForegroundColor, Settings.BackgroundColor);
        dc.drawLine(0, 125, 416, 125);
		dc.drawLine(0, 300, 416, 300);
		dc.drawLine(208, 125, 208, 300);
    }
    
    function DisplayState(dc, gpsStatus, recordingStatus, lapCount)
    {
    	dc.setColor(Settings.DimColor, Settings.BackgroundColor);
		dc.drawText(140, 90, Gfx.FONT_XTINY, "gps:", Gfx.TEXT_JUSTIFY_RIGHT);
		dc.drawText(285, 90, Gfx.FONT_XTINY, "rec:", Gfx.TEXT_JUSTIFY_RIGHT);
    	
    	dc.setColor(_gpsColorsArray[gpsStatus], Gfx.COLOR_TRANSPARENT);
        dc.fillCircle(155, 108, 8);
        
        dc.setColor(recordingStatus ? Gfx.COLOR_GREEN : Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        dc.fillCircle(300, 108, 8);
    }
    
    // Display speed gradient. If current speed > avg speed then trend is positive and vice versa.
    //
    function DisplaySpeedTrend(dc, speedDiff, speed)
    {
    	if (speedDiff > 0)
        {
        	dc.setColor(Gfx.COLOR_GREEN, Settings.BackgroundColor);
        	dc.fillPolygon([[133, 135], [127, 165], [139, 165]]);
        }
        
        if (speedDiff < 0)
        {
        	dc.setColor(Gfx.COLOR_RED, Settings.BackgroundColor);
        	dc.fillPolygon([[127, 135], [133, 165], [139, 135]]);
        }
    }
}