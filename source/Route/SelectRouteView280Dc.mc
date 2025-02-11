using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

/// Since there is no way to setup a background color in layout.xml
/// all boiler-plate code for drawing objects need to be done manually.
/// This class dedicated to hide all dirty work around dc
/// 
(:savememory)
class SelectRouteView280Dc
{
	function ClearDc(dc)
	{
    	dc.setColor(Settings.ForegroundColor, Settings.BackgroundColor);
    	dc.clear();
    }

	function PrintLoadingMessage(dc)
	{
		dc.setColor(Settings.ForegroundColor, Settings.BackgroundColor);
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2 - 25, Gfx.FONT_MEDIUM, "Loading Routes...", Gfx.TEXT_JUSTIFY_CENTER);
	}
	
	function PrintErrorMessage(dc, errorCode)
	{
		var message = "";
		if (errorCode == 1)
		{
			message = "Use ConnectIQ app to setup \n user id";
		} 
		else if (errorCode == 404)
		{
			message = "Loading Error:\n server not found";
		}
		else if (errorCode == -400)
		{
			message = "Wrong user id, use \nConnectIQ app to setup \n user id";
		}
		else if (errorCode == -404)
		{
			message = "There is no routes,\n use Telegram NavGarminBot \n to upload route";
		}
		else
		{
			message = "Loading Error\nCode: " + errorCode.toString();
		}
		
		dc.setColor(Settings.ForegroundColor, Settings.BackgroundColor);
		dc.drawText(dc.getWidth()/2, dc.getHeight()/2 - 50, Gfx.FONT_XTINY, message, Gfx.TEXT_JUSTIFY_CENTER);
	}
	
	function PrintSelectedRoute(dc, selectedRouteData, selectedRouteId, routesSize)
	{
		var mid = dc.getWidth() / 2;
		
		dc.setColor(Settings.ForegroundColor, Settings.BackgroundColor);
		dc.clear();

    	dc.drawText(
    		mid, 
			mid / 5, 
			Gfx.FONT_SYSTEM_SMALL, 
			Lang.format("Select Route\n$1$  [ $2$ ]", [selectedRouteId + 1, routesSize]), 
			Gfx.TEXT_JUSTIFY_CENTER
		);
    	dc.setColor(Settings.ForegroundColor, Settings.BackgroundColor);
  		
		var fontHeight = dc.getFontHeight(Gfx.FONT_SYSTEM_XTINY) + 5;
    	dc.drawText(mid, mid, Gfx.FONT_SYSTEM_XTINY, selectedRouteData["RouteName"], Gfx.TEXT_JUSTIFY_CENTER);	
    	dc.drawText(mid, mid + fontHeight, Gfx.FONT_SYSTEM_XTINY, "WayPoints : " + selectedRouteData["WayPoints"].size(), Gfx.TEXT_JUSTIFY_CENTER);	
    	dc.drawText(mid, mid + fontHeight * 2, Gfx.FONT_SYSTEM_XTINY, YACommon.DateJson2Short(selectedRouteData["RouteDate"]), Gfx.TEXT_JUSTIFY_CENTER);
    	
		var buttonYtop = mid - fontHeight;
		var buttonYbottom = mid + fontHeight * 4;
    	if (selectedRouteId > 0)
    	{
    		dc.fillPolygon([[mid, buttonYtop], [mid - 10, buttonYtop + 20], [mid + 10, buttonYtop + 20]]);
    	}
    	
    	if (selectedRouteId < routesSize - 1)
    	{
    		dc.fillPolygon([[mid, buttonYbottom], [mid - 10, buttonYbottom - 20], [mid + 10, buttonYbottom - 20]]);
    	}	    	 
	}
}