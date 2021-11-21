//+------------------------------------------------------------------+
//|                                                   ConfigTest.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//#include <MyMql\Global\Config\ConfigInfo.mqh> // not used because of errors - missing other needed files (caused by circular include/reference)
#include <MyMql\Global\Global.mqh>

int OnInit()
{
	ConfigInfo info;
	info.WriteConfig();
	
	return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{


}

void OnTick()
{

}
