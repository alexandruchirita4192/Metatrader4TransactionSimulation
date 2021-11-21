//+------------------------------------------------------------------+
//|                                                  TestXML.mq4.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\Global\Log\Xml\XmlAttribute.mqh>

int OnInit()
{
	XmlAttribute attr;
	attr.name = "someAttr";
	attr.value = "123.0";
	attr.DecodeValueType();
	Print(attr.value);
	Print(EnumToString(attr.type));
	Print(attr.GetDateTimeValue());
	Print(attr.GetIntegerValue());
	Print(attr.GetDoubleValue());
	Print(attr.GetColorValue());
	return(INIT_SUCCEEDED);
}

//void OnDeinit(const int reason) {}
//void OnTick() {}
