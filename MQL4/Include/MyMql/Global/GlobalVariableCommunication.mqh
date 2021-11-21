//+------------------------------------------------------------------+
//|                                  GlobalVariableCommunication.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

// Communicate between Indicators and Expert using Global Variables


// Global variables:
// - Send (from indicator to expert); only indicator changes 1st variable
// - Receive a "character received" (indicator receives from expert)
// - Current Symbol of indicator

const string CurrentSymbolGlobalVariable = "CurrentSymbolGlobalVariable";
const string CurrentPeriodGlobalVariable = "CurrentPeriodGlobalVariable";

// Timer to send & receive characters

const string SendGlobalVariable = "SendGlobalVariable";
const string SendReadyGlobalVariable = "SendReadyGlobalVariable";

class GlobalVariableCommunication
{
private:
   bool DoReceiveData, InitTimer;
   int TimerDuration;
   datetime LastUsed;
   string buffer;
   
public:
   GlobalVariableCommunication(bool doReceiveData, bool initTimer)
   {
      Initialize(doReceiveData, initTimer);
   }
   
   void Initialize(bool doReceiveData, bool initTimer)
   {
      DoReceiveData = doReceiveData;
      InitTimer = initTimer;
      
      if (InitTimer)
      {
         TimerDuration = 100; // the correct value depends on CPU
         
         if (!EventSetMillisecondTimer(TimerDuration))
            Print("Timer initialization failed.");
      }
      LastUsed = GlobalVariableSet(SendGlobalVariable, 0);
      GlobalVariableSet(SendReadyGlobalVariable, 0);
      
      // Initialize Symbol and Period
      //GlobalVariableSet(GetGlobalVariableSymbol(), (double)GlobalContext.Library.GetSymbolPositionFromName(_Symbol));
      GlobalVariableSet(GetGlobalVariablePeriod(), (double)_Period);
   }
   
	void CleanBuffers()
	{
	   // clean string buffer with data/words
	   //Print(__FUNCSIG__ + ": Buffer " + buffer + " cleaned");
	   buffer = "";
	}
	void RemoveTimers()
	{
	   // remove timers used to read from global variables
	   EventKillTimer();
	   //Print(__FUNCSIG__ + " called");
	}
	
	string OnTimerGetWord() // This should be called on timer for this to work!
	{
	   // do the timer work
	   if (!DoReceiveData && GlobalVariableGet(SendReadyGlobalVariable) == 0.0 && !StringIsNullOrEmpty(buffer))
	   {
	      Print(__FUNCSIG__ + ": Sending character " + StringSubstr(buffer, 0, 1) + " from buffer " + buffer);
	      GlobalVariableSet(SendGlobalVariable, CharToDouble(buffer, 0));
	      buffer = StringSubstr(buffer, 1); // remove sent character
	      GlobalVariableSet(SendReadyGlobalVariable, 1);
	      Print(__FUNCSIG__ + ": Buffer " + buffer + " remaining");
	   }
	   else if (DoReceiveData && GlobalVariableGet(SendReadyGlobalVariable) == 1.0)
	   {
	      Print(__FUNCSIG__ + ": Received character " + DoubleToChar(GlobalVariableGet(SendGlobalVariable)) + " to buffer " + buffer);
	      buffer = StringConcatenate(buffer, DoubleToChar(GlobalVariableGet(SendGlobalVariable)));
	      GlobalVariableSet(SendReadyGlobalVariable, 0);
	      Print(__FUNCSIG__ + ": Buffer updated " + buffer);
	   }
	   
	   // get 1st word using timer
	   if (DoReceiveData)
	   {
   	   int len = StringFind(buffer,"|");
   	   if (len > 0)
   	      return StringSubstr(buffer, 0, len);
	   }
	   
	   return "";
	}
	
	void RemoveFirstWord()
	{
	   // remove 1st word from buffer
	   
	   int len = StringFind(buffer,"|");
	   if (len < 0)
	      len = 0;
	   buffer = StringSubstr(buffer, len + 1); // remove "|" also
	}
	
	void SendText(string message)
	{
	   // send text using timers (delimited with | ???)
	   buffer = StringConcatenate(buffer, message, "|");
	}
};

string GetGlobalVariableSymbol()
{
   // TODO: check code that calls this because this code is fishy!
   return CurrentSymbolGlobalVariable; // return 3rd global variable symbol??
}

string GetGlobalVariablePeriod()
{
   return CurrentPeriodGlobalVariable;
}

double CharToDouble(string str, int position)
{
   return (double)StringGetChar(str,position);
}

string DoubleToChar(double charCode)
{
   string str = "_";
   return StringSetChar(str, 0, (char)charCode);
}
