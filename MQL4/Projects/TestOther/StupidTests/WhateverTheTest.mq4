//+------------------------------------------------------------------+
//|                                              WhateverTheTest.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

void RefTest(string &s)
{
   s = "23fds";
}

void OnStart()
{
   string ads = "fff";
   RefTest(ads);
   printf(ads);
   
	printf("%f", AccountFreeMargin());
	AccountFreeMarginCheck(Symbol(),OP_SELL, 0.01);
}
