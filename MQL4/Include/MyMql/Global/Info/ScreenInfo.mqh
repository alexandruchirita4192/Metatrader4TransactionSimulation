#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql\Base\BaseObject.mqh>

class ScreenInfo : public BaseObject
{
	public:
		ScreenInfo() {}
		
		virtual void DeleteAllObjectsTextAndLabel(int subWindow = 0) { 
#ifdef __MQL4__
		ObjectsDeleteAll(subWindow, OBJ_TEXT); ObjectsDeleteAll(subWindow, OBJ_LABEL);
#else
      ObjectsDeleteAll(ChartID(), subWindow, OBJ_TEXT); ObjectsDeleteAll(ChartID(), subWindow, OBJ_LABEL);
#endif
		}
		virtual void DeleteAllObjects(long chartId = 0) { ObjectsDeleteAll(chartId); }
		
		virtual void ShowTextValue (
			string objectName,
			string value,
			color textColor = clrNONE,
			int x = 20,
			int y = 20,
			int corner = 1,
			int size = 14,
			string font = "Tahoma"
		);
		
		virtual string NewObjectName(string prefix, int magicNumber = 0);
		virtual string ReplaceObjectName(string prefix, int magicNumber = 0);
		virtual string LastObjectName(string prefix);
		virtual int CountObjectName(string prefix);
		
		virtual bool ShowSimulatedOrderAsLine(string simulatedOrderObjectName, int cmd, datetime time, double price, int magic = 0);
		virtual bool ShowSimulatedOrderAsArrow(string simulatedOrderObjectName, int cmd, datetime time, double price, int magic = 0);
		virtual bool ShowSimulatedOrder(int type, string simulatedOrderObjectName, int cmd, datetime time, double price, int magic = 0);
		virtual bool ShowTransactionWhole(string objectName, datetime timeFirst, double closeFirst, datetime timeLast, double closeLast, color objectColor, int objectsLimit = 2000);
		
		virtual void PrintCurrentValue(double value = 0.0, string comment = "", string objectName = "CurrentValue", color textColor = clrNONE, int x = 20, int y = 20, int corner = 1);
		virtual void CleanCurrentValue(string objectName = "CurrentValue");
		virtual void CleanAllObjects();
};

bool ScreenInfo::ShowSimulatedOrder(int type, string simulatedOrderObjectName, int cmd, datetime time, double price, int magic = 0)
{
	if(type == 0)
		return ShowSimulatedOrderAsLine(simulatedOrderObjectName, cmd, time, price, magic);
	return ShowSimulatedOrderAsArrow(simulatedOrderObjectName, cmd, time, price, magic);
}

bool ScreenInfo::ShowSimulatedOrderAsArrow(string simulatedOrderObjectName, int cmd, datetime time, double price, int magic = 0)
{
	string objectName = NewObjectName(simulatedOrderObjectName, magic);
	
	ENUM_OBJECT objectType =
#ifdef __MQL4__
	   cmd == OP_BUY
#else
      cmd == ORDER_TYPE_BUY
#endif
	   ? OBJ_ARROW_BUY : (
#ifdef __MQL4__
	   cmd == OP_SELL 
#else
      cmd == ORDER_TYPE_SELL
#endif
	   ? OBJ_ARROW_SELL : OBJ_ARROW);
	   
	color currentOrderColor = 
#ifdef __MQL4__
	   cmd == OP_BUY
#else
      cmd == ORDER_TYPE_BUY
#endif
   ? Blue : (
#ifdef __MQL4__
	   cmd == OP_SELL 
#else
      cmd == ORDER_TYPE_SELL
#endif
   ? Orange : Gray);
   
	bool statusOk = ObjectCreate(ChartID(), objectName, objectType, 0, time, price);
#ifdef __MQL4__
	statusOk = statusOk & ObjectSet(objectName, OBJPROP_COLOR, currentOrderColor);
#else 
	statusOk = statusOk & ObjectSetInteger(ChartID(), objectName, OBJPROP_COLOR, currentOrderColor);
#endif

	return statusOk;
}

bool ScreenInfo::ShowSimulatedOrderAsLine(string simulatedOrderObjectName, int cmd, datetime time, double price, int magic = 0)
{
	string objectName = NewObjectName(simulatedOrderObjectName, magic);
	
	color currentOrderColor = 
#ifdef __MQL4__
	   cmd == OP_BUY
#else
      cmd == ORDER_TYPE_BUY
#endif
	   ? Blue : (
#ifdef __MQL4__
	   cmd == OP_SELL 
#else
      cmd == ORDER_TYPE_SELL
#endif
	   ? Orange : Gray);
	   
	bool statusOk = ObjectCreate(ChartID(), objectName, OBJ_VLINE, 0, time, price);
	statusOk = statusOk & ObjectSetInteger(ChartID(), objectName, OBJPROP_COLOR, currentOrderColor);
   statusOk = statusOk & ObjectSetInteger(ChartID(), objectName, OBJPROP_WIDTH, 3);
	return statusOk;
}

bool ScreenInfo::ShowTransactionWhole(string simulatedOrderObjectName, datetime timeFirst, double closeFirst, datetime timeLast, double closeLast, color objectColor, int objectsLimit = 2000)
{
	// we should limit the shit we're doing on the chart, really now XD
	if((objectsLimit != 0) && (ObjectsTotal(ChartID()) > objectsLimit))
	{
		//Print("There are more than 2000 objects. Stoped showing simulated order objects.");
		return false;
	}
	
	datetime auxTime; double auxPrice;
	if(timeFirst < timeLast)
	{
		auxTime = timeFirst; timeFirst = timeLast; timeLast = auxTime;
		auxPrice = closeFirst; closeFirst = closeLast; closeLast = auxPrice;
	}
	double angle = 0.0;
	
	if(closeFirst != closeLast)
		angle = (timeFirst - timeLast) / (closeFirst - closeLast);
	bool selection = false;
	long chartId = ChartID();
	string objectName = NewObjectName(simulatedOrderObjectName);
	bool statusOk = ObjectCreate(chartId, objectName, OBJ_GANNLINE, 0, timeLast, closeLast, timeFirst, closeFirst);
	statusOk = statusOk & ObjectSetInteger(chartId, objectName, OBJPROP_COLOR, objectColor);
	statusOk = statusOk & ObjectSetInteger(chartId, objectName, OBJPROP_WIDTH, 3);
	statusOk = statusOk & ObjectSetInteger(chartId, objectName, OBJPROP_RAY_RIGHT, false);
	statusOk = statusOk & ObjectSetInteger(chartId, objectName, OBJPROP_SELECTABLE, selection); 
	statusOk = statusOk & ObjectSetInteger(chartId, objectName, OBJPROP_SELECTED, selection);
	statusOk = statusOk & ObjectSetDouble(chartId, objectName, OBJPROP_ANGLE, angle);
	return statusOk;
}

void ScreenInfo::ShowTextValue
(
	string objectName,
	string value,
	color textColor = clrNONE,
	int x = 20,
	int y = 20,
	int corner = 1,
	int size = 14,
	string font = "Tahoma"
)
{
#ifdef __MQL4__
	ObjectCreate(objectName, OBJ_LABEL, 0, 0, 0);
	ObjectSet(objectName, OBJPROP_CORNER, corner);
	ObjectSet(objectName, OBJPROP_XDISTANCE, x);
	ObjectSet(objectName, OBJPROP_YDISTANCE, y);
	ObjectSetText(objectName, value, size, font, textColor); //The function changes the object description.
#else
	ObjectCreate(ChartID(), objectName, OBJ_LABEL, 0, 0, 0);
	ObjectSetInteger(ChartID(), objectName, OBJPROP_CORNER, corner);
	ObjectSetInteger(ChartID(), objectName, OBJPROP_XDISTANCE, x);
	ObjectSetInteger(ChartID(), objectName, OBJPROP_YDISTANCE, y);
	ObjectSetString(ChartID(), objectName, OBJPROP_TEXT, value);
	ObjectSetString(ChartID(), objectName, OBJPROP_FONT, font);
	ObjectSetInteger(ChartID(), objectName, OBJPROP_COLOR, textColor);
	ObjectSetInteger(ChartID(), objectName, OBJPROP_FONTSIZE, size);
#endif
}

string ScreenInfo::NewObjectName(string prefix, int magicNumber = 0)
{
	int nr = magicNumber;
	string name = prefix + IntegerToString(nr);
	while(ObjectFind(ChartID(), name) >= 0)
	{
		nr++;
		name = prefix + IntegerToString(nr);
	}
	return name;
}

string ScreenInfo::ReplaceObjectName(string prefix, int magicNumber = 0)
{
	int nr = magicNumber;
	string name = prefix + IntegerToString(nr);
	while(ObjectFind(ChartID(), name) < 0)
	{
		nr++;
		name = prefix + IntegerToString(nr);
	}
	ObjectDelete(ChartID(),name);
	
	return name;
}

string ScreenInfo::LastObjectName(string prefix)
{
	int nr = 0;
	string name = prefix + IntegerToString(nr);
	while(ObjectFind(ChartID(), name) >= 0)
	{
		nr++;
		name = prefix + IntegerToString(nr);
	}
	return name;
}

int ScreenInfo::CountObjectName(string prefix)
{
	int nr = 0;
	string name = prefix + IntegerToString(nr);
	while(ObjectFind(ChartID(), name) >= 0)
	{
		nr++;
		name = prefix + IntegerToString(nr);
	}
	return nr;
}

void ScreenInfo::PrintCurrentValue(double value = 0.0, string comment = "",  string objectName = "CurrentValue", color textColor = clrNONE, int x = 20, int y = 20, int corner = 1)
{
	if(textColor == clrNONE)
	{
		if (value < 0.00)
			textColor = Red;
		else if (value == 0.0)
			textColor = Gray;
		else
			textColor = Lime;
	}
	
	if(ObjectFind(ChartID(),objectName) >= 0)
		ObjectDelete(ChartID(),objectName);
	if(!StringIsNullOrEmpty(comment))
		ShowTextValue(objectName, objectName + ": " + DoubleToString(value,2) + " [" + comment + "]", textColor, x, y, corner);
	else
		ShowTextValue(objectName, objectName + ": " + DoubleToString(value,2), textColor, x, y, corner);
}

void ScreenInfo::CleanCurrentValue(string objectName = "CurrentValue")
{
	ObjectDelete(ChartID(), objectName);
}

void ScreenInfo::CleanAllObjects()
{
	ObjectsDeleteAll(ChartID());
}