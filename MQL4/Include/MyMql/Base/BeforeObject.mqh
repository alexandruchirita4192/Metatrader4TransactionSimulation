#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <WinUser32.mqh>


// All commented functions from "user32.dll" import are imported in <WinUser32.mqh>
#import "user32.dll"
bool GetAsyncKeyState(int nVirtKey);
//void keybd_event(int bVk, int bScan, int dwFlags, int dwExtrainfo);
bool SetCursorPos(int X, int Y);
int FindWindow(string &lpClassName, string &lpWindowName);
int GetWindowRect(int hWnd, int &rect[]); //rect[4]
bool GetCursorPos(int &lpPoint[]); //&lpPoint[2]
//int SetFocus(int hWnd);
//int SetActiveWindow(int hWnd);

//int SendMessageA(int hWnd, int Msg, int wParam, int lParam);
//int SendMessageW(int hWnd, int Msg, int wParam, int lParam);
//int SendNotifyMessageA(int hWnd, int Msg, int wParam, int lParam);
//int SendNotifyMessageW(int hWnd, int Msg, int wParam, int lParam);
int RegisterWindowMessageA(string MessageName);
int RegisterWindowMessageW(string MessageName);
int PostMessageA(int hwnd, int msg, int wparam, string Name);
int PostMessageW(int hwnd, int msg, int wparam, uchar &Name[]);
//void keybd_event(int VirtualKey, int ScanCode, int Flags, int ExtraInfo);
//void mouse_event(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo);
#import

#import "kernel32.dll"
void OutputDebugStringW(string message);
#import

#import "DotNetTestLibrary.dll"
// X86 DLL created based on https://www.mql5.com/en/articles/249 with "ReplaceString" example (with all references copied near, and so on)

bool LogMessage(string message);
bool CleanFile(string fullPath);
bool AppendLine(string fullPath, string line);
int ReadLine(string fullPath, string &text, int lineNumber);
bool ReadAllText(string fullPath, string& text);
int GetFileLinesCount(string fullPath);
int GetFileMaximumLineLength(string fullPath);

int ReplaceString(string &str,string a,string b);
#import


#ifdef __MQL4__

#else
// To do: add reading functions for MQL5 (if needed) - x64 needed
#endif

//#ifdef __MQL5__
//#include <MyMql\Base\BeforeObjectMQL4.mqh>
//#endif


#define VK_0   48
#define VK_1   49
#define VK_2   50
#define VK_3   51
#define VK_4   52
#define VK_5   53
#define VK_6   54
#define VK_7   55
#define VK_8   56
#define VK_9   57
#define VK_A   65
#define VK_B   66
#define VK_C   67
#define VK_D   68
#define VK_E   69
#define VK_F   70
#define VK_G   71
#define VK_H   72
#define VK_I   73
#define VK_J   74
#define VK_K   75
#define VK_L   76
#define VK_M   77
#define VK_N   78
#define VK_O   79
#define VK_P   80
#define VK_Q   81
#define VK_R   82
#define VK_S   83
#define VK_T   84
#define VK_U   85
#define VK_V   86
#define VK_W   87
#define VK_X   88
#define VK_Y   89
#define VK_Z   90

#define VK_LBUTTON         1     //Left mouse button
#define VK_RBUTTON         2     //Right mouse button
#define VK_CANCEL          3     //Control-break processing
#define VK_MBUTTON         4     //Middle mouse button (three-button mouse)
#define VK_BACK            8     //BACKSPACE key
#define VK_TAB             9     //TAB key
#define VK_CLEAR           12    //CLEAR key
#define VK_RETURN          13    //ENTER key
#define VK_SHIFT           16    //SHIFT key
#define VK_CONTROL         17    //CTRL key
#define VK_MENU            18    //ALT key
#define VK_PAUSE           19    //PAUSE key
#define VK_CAPITAL         20    //CAPS LOCK key
#define VK_ESCAPE          27    //ESC key
#define VK_SPACE           32    //SPACEBAR
#define VK_PRIOR           33    //PAGE UP key
#define VK_NEXT            34    //PAGE DOWN key
#define VK_END             35    //END key
#define VK_HOME            36    //HOME key
#define VK_LEFT            37    //LEFT ARROW key
#define VK_UP              38    //UP ARROW key
#define VK_RIGHT           39    //RIGHT ARROW key
#define VK_DOWN            40    //DOWN ARROW key
#define VK_PRINT           42    //PRINT key
#define VK_SNAPSHOT        44    //PRINT SCREEN key
#define VK_INSERT          45    //INS key
#define VK_DELETE          46    //DEL key
#define VK_HELP            47    //HELP key
#define VK_LWIN            91    //Left Windows key (Microsoft® Natural® keyboard)
#define VK_RWIN            92    //Right Windows key (Natural keyboard)
#define VK_APPS            93    //Applications key (Natural keyboard)
#define VK_SLEEP           95    //Computer Sleep key
#define VK_NUMPAD0         96    //Numeric keypad 0 key
#define VK_NUMPAD1         97    //Numeric keypad 1 key
#define VK_NUMPAD2         98    //Numeric keypad 2 key
#define VK_NUMPAD3         99    //Numeric keypad 3 key
#define VK_NUMPAD4         100   //Numeric keypad 4 key
#define VK_NUMPAD5         101   //Numeric keypad 5 key
#define VK_NUMPAD6         102   //Numeric keypad 6 key
#define VK_NUMPAD7         103   //Numeric keypad 7 key
#define VK_NUMPAD8         104   //Numeric keypad 8 key
#define VK_NUMPAD9         105   //Numeric keypad 9 key
#define VK_MULTIPLY        106   //Multiply key
#define VK_ADD             107   //Add key
#define VK_SEPARATOR       108   //Separator key
#define VK_SUBTRACT        109   //Subtract key
#define VK_DECIMAL         110   //Decimal key
#define VK_DIVIDE          111   //Divide key
#define VK_F1              112   //F1 key
#define VK_F2              113   //F2 key
#define VK_F3              114   //F3 key
#define VK_F4              115   //F4 key
#define VK_F5              116   //F5 key
#define VK_F6              117   //F6 key
#define VK_F7              118   //F7 key
#define VK_F8              119   //F8 key
#define VK_F9              120   //F9 key
#define VK_F10             121   //F10 key
#define VK_F11             122   //F11 key
#define VK_F12             123   //F12 key
#define VK_F13             124   //F13 key
#define VK_NUMLOCK         144   //NUM LOCK key
#define VK_SCROLL          145   //SCROLL LOCK key
#define VK_LSHIFT          160   //Left SHIFT key
#define VK_RSHIFT          161   //Right SHIFT key
#define VK_LCONTROL        162   //Left CONTROL key
#define VK_RCONTROL        163   //Right CONTROL key
#define VK_LMENU           164   //Left MENU key
#define VK_RMENU           165   //Right MENU key
#define VK_OEM_PERIOD      190   //For any country/region, the '.' key


const int MaxStringLength = 130;

string GetConfigFileValue();

#define LogInfoMessage(s) LogMessage("[" + Symbol() + "][" + TimeFrameToString(IntegerToTimeFrame(Period())) + "][" + GetConfigFileValue() + "]" + __FILE__ + " > " + __FUNCSIG__ + ": " + s)
#define LogInfoMessageIfTrue(value, s) if(value) LogInfoMessage(s);

void SafePrintString(string str, bool extraLog = false) {
	if (str == "")
		return;

	LogInfoMessageIfTrue(extraLog, str);
	
	int firstPos = 0, len = StringLen(str);
	if (len > MaxStringLength)
	{
		for (int i = 0; i < len; i = i + MaxStringLength)
		{
			Print(StringSubstr(str, firstPos, MaxStringLength));
			firstPos = i + MaxStringLength;
		}
	}
	else
		Print(str);
}


string StringFormatNumberNotZero(string format, double number) { if (number != 0.0) return StringFormat(format, number); return ""; }
string ReturnStringOnCondition(string str, bool condition) { if (condition) return str; return ""; }
string ReturnStringOnNumberNotZero(string str, double number) { return ReturnStringOnCondition(str, number != 0.0); }

#ifdef __MQL4__
string OrderTypeToString(int orderType = -1, bool alertUnknownType = false)
{
	if (orderType == -1)
		orderType = (int)OrderType();

	switch (orderType)
	{
	case OP_BUY:
		return "buy";
		break;
	case OP_SELL:
		return "sell";
		break;
	case OP_BUYLIMIT:
		return "buy limit";
		break;
	case OP_SELLLIMIT:
		return "sell limit";
		break;
	case OP_BUYSTOP:
		return "buy stop";
		break;
	case OP_SELLSTOP:
		return "sell stop";
		break;
	case 6:
		return "balance";
		break;
	default:
		if (alertUnknownType)
			Alert("Unknown order type: " + IntegerToString(orderType));
		return "unknown (" + IntegerToString(orderType) + ")";
		break;
	}
}
#else

string OrderTypeToString(int orderType = -1, bool alertUnknownType = false)
{
	if (orderType == -1)
		orderType = (int)OrderGetInteger(ORDER_TYPE);

	switch (orderType)
	{
	case ORDER_TYPE_BUY:
		return "buy";
		break;
	case ORDER_TYPE_SELL:
		return "sell";
		break;
	case ORDER_TYPE_BUY_LIMIT:
		return "buy limit";
		break;
	case ORDER_TYPE_SELL_LIMIT:
		return "sell limit";
		break;
	case ORDER_TYPE_BUY_STOP:
		return "buy stop";
		break;
	case ORDER_TYPE_SELL_STOP:
		return "sell stop";
		break;
	case 6:
		return "balance";
		break;
	default:
		if (alertUnknownType)
			Alert("Unknown order type: " + IntegerToString(orderType));
		return "unknown (" + IntegerToString(orderType) + ")";
		break;
	}
}
#endif

bool IsValidBool(string value)
{
	StringToLower(value);
	return value == "true" || value == "false";
}

string BoolToString(bool value)
{
	if (value)
		return "true";
	return "false";
}

bool StringToBool(string value)
{
	//if((value != "true") && (value != "false")
	//	Print(__FUNCTION__ + ": Error: Trying to parse value " + value + " which is not boolean!");
	return value == "true"; // consider everything else false
}

int ExpertValidationsTest(string symbol)
{
	if (symbol == "")
		return (INIT_FAILED);

	if (!AccountInfoInteger(ACCOUNT_TRADE_EXPERT)) // IsExpertEnabled()
	{
		Alert("Expert is not enabled. Nothing to do here. Exiting.");
		return (INIT_FAILED);
	}

#ifdef __MQL5__
	if (!MQLInfoInteger(MQL_TRADE_ALLOWED))
#else
	if (!IsTradeAllowed())
#endif
	{
		Alert("Trade is not allowed. Nothing to do here. Exiting.");
		return (INIT_FAILED);
	}

#ifdef __MQL5__
	if (SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_DISABLED)
#else
	if (MarketInfo(symbol, MODE_TRADEALLOWED) != 1)
#endif
	{
		Alert("Trading on this symbol is not allowed. Market might be closed.");
		return (INIT_FAILED);
	}

	return (INIT_SUCCEEDED);
}

string IndentLevel(bool indent, int level)
{
	if (!indent)
		return "\n";

	string retString = "\n";
	for (int i = 0; i < level; i++)
		retString += "\t";
	return retString;
}

long AutoDetectNumberOfBots()
{
	// windows might be full of experts.. or not :)
#ifdef __MQL5__
	return ChartGetInteger(0, CHART_WINDOWS_TOTAL);
#else
	return (long) WindowsTotal();
#endif
}

void IndicatorBuffer(double &Ind_Buffer[], string symbol, int timeframe)
{
#ifndef __MQL5__
	ArraySetAsSeries(Ind_Buffer, false); // no need for MQL5; always ok to be true
	ArrayResize(Ind_Buffer, iBars(symbol, timeframe)); // iBarsIndicator(symbol, timeframe)
#else
	ArrayResize(Ind_Buffer, iBars(symbol, IntegerToTimeFrame(timeframe)));
#endif
	ArraySetAsSeries(Ind_Buffer, true);
}

int PeriodTotal()
{
	return 22;
}


ENUM_TIMEFRAMES PeriodValue(int periodNumber)
{
	if (periodNumber == 0)
		return PERIOD_H1;
	else if (periodNumber == 1)
		return PERIOD_M1;
	else if (periodNumber == 2)
		return PERIOD_M2;
	else if (periodNumber == 3)
		return PERIOD_M3;
	else if (periodNumber == 4)
		return PERIOD_M4;
	else if (periodNumber == 5)
		return PERIOD_M5;
	else if (periodNumber == 6)
		return PERIOD_M6;
	else if (periodNumber == 7)
		return PERIOD_M10;
	else if (periodNumber == 8)
		return PERIOD_M12;
	else if (periodNumber == 9)
		return PERIOD_M15;
	else if (periodNumber == 10)
		return PERIOD_M20;
	else if (periodNumber == 11)
		return PERIOD_M30;
	else if (periodNumber == 12)
		return PERIOD_H1;
	else if (periodNumber == 13)
		return PERIOD_H2;
	else if (periodNumber == 14)
		return PERIOD_H3;
	else if (periodNumber == 15)
		return PERIOD_H4;
	else if (periodNumber == 16)
		return PERIOD_H6;
	else if (periodNumber == 17)
		return PERIOD_H8;
	else if (periodNumber == 18)
		return PERIOD_H12;
	else if (periodNumber == 19)
		return PERIOD_D1;
	else if (periodNumber == 20)
		return PERIOD_W1;
	else if (periodNumber == 21)
		return PERIOD_MN1;
	return PERIOD_H1;
}


// Assertions functions - sort of unit testing
string AssertEqualFailed(string a, string b, string message)
{
	return StringFormat("AssertEqual failed: %s != %s; Message: %s", a, b, message);
}

bool AssertEqual(string &ret, string a, string b, string message, bool alert = false, bool print = true)
{
	int resultOk = StringCompare(a, b, true);
	if (resultOk != 0)
	{
		ret = ret + AssertEqualFailed(a, b, message);
		if (print)
			printf(ret);
		if (alert)
			Alert(ret);
	}
	return resultOk == 0;
}

bool AssertEqual(string &ret, bool a, bool b, string message, bool alert = false, bool print = true)
{
	return AssertEqual(ret, BoolToString(a), BoolToString(b), message, alert, print);
}

bool AssertEqual(string &ret, int a, int b, string message, bool alert = false, bool print = true)
{
	return AssertEqual(ret, IntegerToString(a), IntegerToString(b), message, alert, print);
}

bool AssertEqual(string &ret, double a, double b, string message, int digits = 4, bool alert = false, bool print = true)
{
	return AssertEqual(ret, DoubleToString(a, digits), DoubleToString(b, digits), message, alert, print);
}


#ifdef __MQL5__
bool RefreshRates()
{
   MqlTick tick;
   return SymbolInfoTick(_Symbol, tick);
}

bool IsTradeAllowed(string symbol, datetime tested_time)
{
   Print("IsTradeAllowed called in MQL5; tested_time is ignored");
   return SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL;
}
#endif

/** Starts and waits for a download of chart history.
 * In Technical Indicator Functions - MQL4 Documentation][TIF3] it states:
 * > If data (symbol name and/or timeframe differ from the current ones) are
 * > requested from another chart, the situation is possible that the
 * > corresponding chart was not opened in the client terminal and the
 * > necessary data must be requested from the server. In this case, error
 * > `ERR_HISTORY_WILL_UPDATED` (4066 - the requested history data are under
 * > updating) will be placed in the last_error variable, and and there will
 * > be necessary to retry \[the operation] after a certain period of time.
 *
 * The [ArrayCopySeries][ACS] example tests array[0] against server time.
 * [ACS]: https://docs.mql4.com/array/arraycopyseries
 * [TIF3]: https://docs.mql4.com/en/indicators
 *
 * Note: you _only_ get 4066 once. Subsequent calls (\::ArrayCopyRates and
 * apparently \::ArrayCopySeries) silently succeed but the data is bogus
 * until the download completes. These calls should have been synchronous,
 * but then they couldn't be used in indicators.
 */
bool DownloadHistory(
    ENUM_TIMEFRAMES   period = PERIOD_CURRENT,  ///< The standard timeframe.
    string            symbol = ""               /**< The symbol required.*/
) {
	ResetLastError();
	datetime now = iTime(symbol, period, 0);
	if (_LastError == 0)
		return true;

	if (_LastError != 4066) { //ERR_HISTORY_WILL_UPDATED
		Print(StringFormat("%s: iTime(W%d) Failed: %d",
		                   symbol, period, _LastError));
		return false;
	}

	for (int i = 0; i < 15; i++) {
		Sleep(1000); //DownloadHistory Sleep@for
		ResetLastError();
		datetime other = iTime(symbol, period, 0);
		if (now == other)
		   return RefreshRates();
	}

	Print(StringFormat("%s: iTime(%d) Failed: %d (15 secs)",
	                   symbol, period, _LastError));
	return false;
}




string TimeFrameToString(ENUM_TIMEFRAMES timeFrame)
{
	return EnumToString(timeFrame);
}

ENUM_TIMEFRAMES StringToTimeFrame(string timeFrame)
{
	if (timeFrame == "PERIOD_CURRENT")
		return PERIOD_CURRENT;
	else if (timeFrame == "PERIOD_M1")
		return PERIOD_M1;
	else if (timeFrame == "PERIOD_M2")
		return PERIOD_M2;
	else if (timeFrame == "PERIOD_M3")
		return PERIOD_M3;
	else if (timeFrame == "PERIOD_M4")
		return PERIOD_M4;
	else if (timeFrame == "PERIOD_M5")
		return PERIOD_M5;
	else if (timeFrame == "PERIOD_M6")
		return PERIOD_M6;
	else if (timeFrame == "PERIOD_M10")
		return PERIOD_M10;
	else if (timeFrame == "PERIOD_M12")
		return PERIOD_M12;
	else if (timeFrame == "PERIOD_M15")
		return PERIOD_M15;
	else if (timeFrame == "PERIOD_M20")
		return PERIOD_M20;
	else if (timeFrame == "PERIOD_M30")
		return PERIOD_M30;
	else if (timeFrame == "PERIOD_H1")
		return PERIOD_H1;
	else if (timeFrame == "PERIOD_H2")
		return PERIOD_H2;
	else if (timeFrame == "PERIOD_H3")
		return PERIOD_H3;
	else if (timeFrame == "PERIOD_H4")
		return PERIOD_H4;
	else if (timeFrame == "PERIOD_H6")
		return PERIOD_H6;
	else if (timeFrame == "PERIOD_H8")
		return PERIOD_H8;
	else if (timeFrame == "PERIOD_H12")
		return PERIOD_H12;
	else if (timeFrame == "PERIOD_D1")
		return PERIOD_D1;
	else if (timeFrame == "PERIOD_W1")
		return PERIOD_W1;
	else if (timeFrame == "PERIOD_MN1")
		return PERIOD_MN1;
	return PERIOD_H1;
}

bool IntegerToBool(int value)
{
	return value == 1;
}

ENUM_TIMEFRAMES IntegerToTimeFrame(int timeFrame)
{
	if (timeFrame == 0)
		return ChartPeriod(0);
	else if (timeFrame == 1)
		return PERIOD_M1;
	else if (timeFrame == 2)
		return PERIOD_M2;
	else if (timeFrame == 3)
		return PERIOD_M3;
	else if (timeFrame == 4)
		return PERIOD_M4;
	else if (timeFrame == 5)
		return PERIOD_M5;
	else if (timeFrame == 6)
		return PERIOD_M6;
	else if ((timeFrame > 6) && (timeFrame <= 10))
		return PERIOD_M10;
	else if ((timeFrame > 10) && (timeFrame <= 12))
		return PERIOD_M12;
	else if ((timeFrame > 12) && (timeFrame <= 15))
		return PERIOD_M15;
	else if ((timeFrame > 15) && (timeFrame <= 20))
		return PERIOD_M20;
	else if ((timeFrame > 20) && (timeFrame <= 30))
		return PERIOD_M30;
	else if ((timeFrame > 30) && (timeFrame <= 60))
		return PERIOD_H1;
	else if ((timeFrame > 60) && (timeFrame <= 120))
		return PERIOD_H2;
	else if ((timeFrame > 120) && (timeFrame <= 180))
		return PERIOD_H3;
	else if ((timeFrame > 180) && (timeFrame <= 240))
		return PERIOD_H4;
	else if ((timeFrame > 240) && (timeFrame <= 360))
		return PERIOD_H6;
	else if ((timeFrame > 360) && (timeFrame <= 480))
		return PERIOD_H8;
	else if ((timeFrame > 480) && (timeFrame <= 720))
		return PERIOD_H12;
	else if ((timeFrame > 720) && (timeFrame <= 1440))
		return PERIOD_D1;
	else if ((timeFrame > 1440) && (timeFrame <= 10080))
		return PERIOD_W1;
	else if (timeFrame > 10080) // && (timeFrame <= 43200))
		return PERIOD_MN1;
	return PERIOD_H1;
}



// Pip, conversion to or from point
double Pip() { double point = Point(); return ConvertPoint2Pip(point); }
double ConvertPip2Point(double x) { if (Digits() % 2 == 1) { return (x * 10.0); } else {return (x); } }
double ConvertPoint2Pip(double x) { if (Digits() % 2 == 1) { return (x / 10.0); } else {return (x); } }

static string _SpreadSymbol;
static double _MaxSpread = 0.0;
static double _MinSpread = 0.0;


// to do: make a nice spread array, spread symbol, and so on => spread for each symbol ever called + volatility for every symbol ever called
double Spread(string symbol = NULL)
{
	if (StringIsNullOrEmpty(symbol))
		symbol = _Symbol;

	double currentSpread = SpreadFromSymbol(symbol);

	if ((_SpreadSymbol != symbol) ||
	        (_MaxSpread == 0) ||
	        (_MinSpread == 0) ||
	        (StringIsNullOrEmpty(_SpreadSymbol))) {
		_MaxSpread = _MinSpread = currentSpread;
		_SpreadSymbol = symbol;
	}
	else {
		if (_MaxSpread < currentSpread)
			_MaxSpread = currentSpread;
		if (_MinSpread > currentSpread)
			_MinSpread = currentSpread;
	}

	return _MaxSpread;
}

double SpreadPips(string symbol = NULL)
{
	return Spread(symbol) / Pip();
}

double Volatility(string symbol = NULL)
{
	if (StringIsNullOrEmpty(symbol))
		symbol = _Symbol;

	if ((_MaxSpread == 0) ||
	        (_MinSpread == 0) ||
	        (StringIsNullOrEmpty(_SpreadSymbol)) ||
	        (symbol != _SpreadSymbol))
		return 0.0; // nothing to show; to do: debug warning; + to do?: debug warning if _Symbol/OrderSymbol() != _SpreadSymbol???

	return _MaxSpread - _MinSpread;
}

double VolatilityPips(string symbol = NULL)
{
	return Volatility(symbol) / Pip();
}

double SpreadFromSymbol(string sym)
{
#ifdef __MQL5__
	return SymbolInfoDouble(sym, SYMBOL_ASK) - SymbolInfoDouble(sym, SYMBOL_BID);
#else
	return MarketInfo(sym, MODE_ASK) - MarketInfo(sym, MODE_BID);
#endif
}

int MaxPossibleMinLots(string sym)
{
   double minLot = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   
#ifdef __MQL5__
   double accountFreeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double openPrice = iClose(sym, _Period, 0);
   double sellMargin, buyMargin;
   bool ok = OrderCalcMargin(ORDER_TYPE_SELL, sym, minLot, openPrice, sellMargin);
   if(!ok)
      Print("OrderCalcMargin(ORDER_TYPE_BUY, sym, minLot, openPrice, buyMargin); issue in " + __FUNCSIG__);
   ok = OrderCalcMargin(ORDER_TYPE_BUY, sym, minLot, openPrice, buyMargin);
   if(!ok)
      Print("OrderCalcMargin(ORDER_TYPE_BUY, sym, minLot, openPrice, buyMargin); issue in " + __FUNCSIG__);
   double avgMarginLeft = ((accountFreeMargin - sellMargin) + (accountFreeMargin - buyMargin)) / 2.0;
#else
   double avgMarginLeft = (AccountFreeMarginCheck(sym, OP_BUY, minLot) + AccountFreeMarginCheck(sym, OP_SELL, minLot)) / 2.0;
#endif

	double marginAfterMarginLeftSubstraction = (AccountInfoDouble(ACCOUNT_MARGIN_FREE) - avgMarginLeft);

	if (marginAfterMarginLeftSubstraction == 0)
		return 0;

	double marginRequired = AccountInfoDouble(ACCOUNT_MARGIN_FREE) / marginAfterMarginLeftSubstraction;
	return ((int)NormalizeDouble(marginRequired, 0));
}

double SwapLong(string sym)
{
   return SymbolInfoDouble(sym, SYMBOL_SWAP_LONG);
}

double SwapShort(string sym)
{
   return SymbolInfoDouble(sym, SYMBOL_SWAP_SHORT);
}


bool StringIsNullOrEmpty(string str)
{
	return ((StringLen(str) == 0) || (str == NULL) || (str == ""));
}

bool StringIsEmptyLine(string str)
{
	StringReplace(str, " ", "");
	StringReplace(str, "\t", "");
	StringReplace(str, "\r", "");
	StringReplace(str, "\n", "");
	return (StringIsNullOrEmpty(str));
}

string UninitDescription(int reasonCode)
{
	string text = "";
	switch (reasonCode)
	{
	case REASON_PROGRAM:
		text = "Expert Advisor terminated its operation by calling the ExpertRemove() function"; break;
	case REASON_ACCOUNT:
		text = "Account was changed"; break;
	case REASON_CHARTCHANGE:
		text = "Symbol or timeframe was changed"; break;
	case REASON_CHARTCLOSE:
		text = "Chart was closed"; break;
	case REASON_PARAMETERS:
		text = "Input-parameter was changed"; break;
	case REASON_RECOMPILE:
		text = "Program " + __FILE__ + " was recompiled"; break;
	case REASON_REMOVE:
		text = "Program " + __FILE__ + " was removed from chart"; break;
	case REASON_TEMPLATE:
		text = "New template was applied to chart"; break;
	case REASON_INITFAILED:
		text = "OnInit() did not return zero/ok"; break;
	case REASON_CLOSE:
		text = "Terminal has been closed"; break;
	default:
		text = "Another reason";
	}
	return text;
}

void SendOneKey(int key)
{
	switch (key)
	{
	case '.':
		key = VK_OEM_PERIOD;
		break;
	case '\n':
		key = VK_RETURN;
		break;
	default:
		break;
	}
	keybd_event(key, 0, 0, 0);
	Sleep(10);
	keybd_event(key, 0, KEYEVENTF_KEYUP, 0);
}

void SendKey(int key, int key2)
{
	if (key2 != 0)
		keybd_event(key2, 0, 0, 0);

	keybd_event(key, 0, 0, 0);
	Sleep(1);
	keybd_event(key, 0, KEYEVENTF_KEYUP, 0);

	if (key2 != 0)
		keybd_event(VK_MENU, 0, KEYEVENTF_KEYUP, 0);
}

void SendWord(string word)
{
	for (int i = 0; i < StringLen(word); i++)
		SendOneKey(word[i]);
}

void ChartChange(string symbolOrPeriod)
{
	int r[4], p[2];
	GetCursorPos(p);
	
#ifdef __MQL4__
	int handle = WindowHandle(_Symbol, _Period);
#else
   int handle = (int) ChartGetInteger(0, CHART_WINDOW_HANDLE);
   handle = GetParent(GetParent(handle));
#endif

	GetWindowRect(handle, r);
	int windowX = r[2], windowY = r[3], cursorX = p[0], cursorY = p[1];
	SetCursorPos(windowX / 2, windowY / 2);

	SendOneKey(VK_LBUTTON);
	Sleep(100);
	SendOneKey(VK_RETURN);
	SendWord(symbolOrPeriod);
	SendOneKey(VK_RETURN);
	Sleep(100);
	SendOneKey(VK_RETURN);
	Sleep(100);
	SendOneKey(VK_RETURN);
	Sleep(100);
	SendOneKey(VK_LBUTTON);

	SetCursorPos(cursorX, cursorY);
}

#ifdef __MQL4__
int InverseOrderType(int cmd)
{
	if (cmd == OP_BUY)
		cmd = OP_SELL;
	else if (cmd == OP_SELL)
		cmd = OP_BUY;

	// not sure about the following; not use yet anyway
	else if (cmd == OP_BUYLIMIT)
		cmd = OP_SELLLIMIT;
	else if (cmd == OP_SELLLIMIT)
		cmd = OP_BUYLIMIT;
	else if (cmd == OP_BUYSTOP)
		cmd = OP_SELLSTOP;
	else if (cmd == OP_SELLSTOP)
		cmd = OP_BUYSTOP;
	else
	{
		SafePrintString("Weird cmd=" + IntegerToString(cmd) + " received in " + __FUNCTION__ + " at line " + IntegerToString(__LINE__) + ". Defaulting to OP_BUY.",true);
		cmd = OP_BUY; // clean the crap?
	}

	return cmd;
}
#else
int InverseOrderType(int cmd)
{
   if(cmd == ORDER_TYPE_BUY)
      cmd = ORDER_TYPE_SELL;
   else if(cmd == ORDER_TYPE_SELL)
      cmd = ORDER_TYPE_BUY;
   // not sure about the following; not use yet anyway
	else if (cmd == ORDER_TYPE_BUY_LIMIT)
		cmd = ORDER_TYPE_SELL_LIMIT;
	else if (cmd == ORDER_TYPE_SELL_LIMIT)
		cmd = ORDER_TYPE_BUY_LIMIT;
	else if (cmd == ORDER_TYPE_BUY_STOP)
		cmd = ORDER_TYPE_SELL_STOP;
	else if (cmd == ORDER_TYPE_SELL_STOP)
		cmd = ORDER_TYPE_BUY_STOP;
	else
	{
		SafePrintString("Weird cmd=" + IntegerToString(cmd) + " received in " + __FUNCTION__ + " at line " + IntegerToString(__LINE__) + ". Defaulting to ORDER_TYPE_BUY.",true);
		cmd = ORDER_TYPE_BUY; // clean the crap?
	}
   return cmd;
}
#endif


#ifdef __MQL4__
int GetOrderTypeBasedOnDecision(double decision)
{
	if (decision > 0.0)
		return OP_BUY;
	if (decision < 0.0)
		return OP_SELL;

	Print("Incertitude decision in " + __FUNCTION__ + " at line " + IntegerToString(__LINE__));

	return -2;
}
#else
int GetOrderTypeBasedOnDecision(double decision)
{
	if (decision > 0.0)
		return ORDER_TYPE_BUY;
	if (decision < 0.0)
		return ORDER_TYPE_SELL;

	Print("Incertitude decision in " + __FUNCTION__ + " at line " + IntegerToString(__LINE__));

	return -2;
}
#endif


double GetOrderOpenPrice(string symbol, ENUM_TIMEFRAMES timeFrame, int cmd, int timeShift)
{
	double price = 0.0;

#ifdef __MQL4__
	if ((cmd != OP_BUY) && (cmd != OP_SELL))
#else
   if((cmd != ORDER_TYPE_BUY) && (cmd != ORDER_TYPE_SELL))
#endif
	{
		Print("Not defined cmd=" + IntegerToString(cmd));
		return price;
	}

	// to do: widely check timeShift
	if (timeShift >= iBars(symbol, timeFrame))
		timeShift = iBars(symbol, timeFrame) - 1;
	if (timeShift < 0)
		timeShift = 0;

	if (StringIsNullOrEmpty(symbol))
		symbol = _Symbol;
	if (timeFrame == PERIOD_CURRENT)
		timeFrame = IntegerToTimeFrame(_Period);

#ifdef __MQL4__
	if (cmd == OP_BUY)
#else
	if (cmd == ORDER_TYPE_BUY)
#endif
	{
		if ((timeShift != 0) && (timeShift < iBars(symbol, timeFrame)) && (timeShift >= 0))
			price = iClose(symbol, timeFrame, timeShift) + Spread(symbol); // computed Ask - incomplete simulation (takes into consideration only Close)
		else if (timeShift == 0.0)
			price = SymbolInfoDouble(symbol, SYMBOL_ASK);
	}
#ifdef __MQL4__
	else if (cmd == OP_SELL)
#else
	else if (cmd == ORDER_TYPE_SELL)
#endif
	{
		if ((timeShift != 0) && (timeShift < iBars(symbol, timeFrame)) && (timeShift >= 0))
			price = iClose(symbol, timeFrame, timeShift); // computed Bid - incomplete simulation (takes into consideration only Close)
		else if (timeShift == 0.0)
			price = SymbolInfoDouble(symbol, SYMBOL_BID);
	}

	return price;
}

bool IsTakeProfitTouched(double takeProfit, double price, double orderType)
{
#ifdef __MQL4__
	return (((orderType == OP_BUY) && (takeProfit <= price)) ||
	        ((orderType == OP_SELL) && (takeProfit >= price)));
#else
	return (((orderType == ORDER_TYPE_BUY) && (takeProfit <= price)) ||
	        ((orderType == ORDER_TYPE_SELL) && (takeProfit >= price)));
#endif
}

bool IsStopLossTouched(double stopLoss, double price, double orderType)
{
#ifdef __MQL4__
	return (((orderType == OP_BUY) && (stopLoss >= price)) ||
	        ((orderType == OP_SELL) && (stopLoss <= price)));
#else
	return (((orderType == ORDER_TYPE_BUY) && (stopLoss >= price)) ||
	        ((orderType == ORDER_TYPE_SELL) && (stopLoss <= price)));
#endif
}

double Normalize(double number, string info)
{
   if (number > 9999999999999.00)
   {
      SafePrintString("Number [" + info + "]=" + DoubleToString(number) + " greater than it should. Changed to -1.", true);
      return -1.00;
   }
   return NormalizeDouble(number, 8);
}

int NormalizeInt(int number, string info)
{
   if (number > 99999999)
   {
      SafePrintString("Number [" + info + "]=" + IntegerToString(number) + " greater than it should. Changed to -1.", true);
      return -1;
   }
   return number;
}
