//+------------------------------------------------------------------+
//|                                       TestNamedPipeIndicator.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window



#include "..\..\..\Include\MyMql\Global\CNamedPipe.mqh"

CNamedPipe cnp;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
   Print(5);
   cnp.Open();
   Print(6);
   cnp.WriteANSI("test 1");
   Print(2.1);
   Sleep(10000);
   Print(6.5);
   Print(cnp.ReadANSI());
   Print(6.9);
//---
   return(INIT_SUCCEEDED);
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


void OnDeinit(const int reason)
  {
   
   cnp.Disconnect();
   Print(7);
   cnp.Close();
   Print(8);
  }