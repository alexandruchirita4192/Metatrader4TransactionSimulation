//+------------------------------------------------------------------+
//|                                         TesterForChangeChart.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <MyMql\Global\Global.mqh>


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   EventSetMillisecondTimer(1000);
//---
   return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int reason)
       {
        EventKillTimer();
       }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   int currentPosition = (int)GlobalVariableGet(GetGlobalVariableSymbol());
	string symbol = GlobalContext.Library.GetSymbolNameFromPosition((int)GlobalVariableGet(GetGlobalVariableSymbol()));
	Print("Current symbol: " + symbol);
	
	currentPosition++;
	GlobalVariableSet(GetGlobalVariableSymbol(), currentPosition);
	symbol = GlobalContext.Library.GetSymbolNameFromPosition(currentPosition);
	Print("New symbol: " + symbol);
  }
//+------------------------------------------------------------------+
