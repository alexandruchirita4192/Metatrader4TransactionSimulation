#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict



//#ifndef OP_BUY
//#define OP_BUY 0           //Buy
//#define OP_SELL 1          //Sell 
//#define OP_BUYLIMIT 2      //Pending order of BUY LIMIT type 
//#define OP_SELLLIMIT 3     //Pending order of SELL LIMIT type 
//#define OP_BUYSTOP 4       //Pending order of BUY STOP type 
//#define OP_SELLSTOP 5      //Pending order of SELL STOP type 
//#define OP_BALANCE 6       //Balance - add/remove money from account

#ifdef __MQL4__
#ifndef MODE_LOW
#define MODE_LOW 1
#define MODE_HIGH 2
#define MODE_TIME 5
#define MODE_BID 9
#define MODE_ASK 10
#define MODE_POINT 11
#define MODE_DIGITS 12
#define MODE_SPREAD 13
#define MODE_STOPLEVEL 14
#define MODE_LOTSIZE 15
#define MODE_TICKVALUE 16
#define MODE_TICKSIZE 17
#define MODE_SWAPLONG 18
#define MODE_SWAPSHORT 19
#define MODE_STARTING 20
#define MODE_EXPIRATION 21
#define MODE_TRADEALLOWED 22
#define MODE_MINLOT 23
#define MODE_LOTSTEP 24
#define MODE_MAXLOT 25
#define MODE_SWAPTYPE 26
#define MODE_PROFITCALCMODE 27
#define MODE_MARGINCALCMODE 28
#define MODE_MARGININIT 29
#define MODE_MARGINMAINTENANCE 30
#define MODE_MARGINHEDGED 31
#define MODE_MARGINREQUIRED 32
#define MODE_FREEZELEVEL 33
#endif
#endif


#ifdef __MQL5__


//long OrderType()
//{
//	return OrderGetInteger(ORDER_TYPE);
//}

int iBarsIndicator(string symbol, ENUM_TIMEFRAMES timeframe)
{
	return Bars(symbol,timeframe);
}

//double MarketInfoMQL4(string symbol, int type)
//{
//	MqlTick last_tick;
//	switch(type)
//	{
//		case MODE_LOW:
//			return(SymbolInfoDouble(symbol,SYMBOL_LASTLOW));
//		case MODE_HIGH:
//			return(SymbolInfoDouble(symbol,SYMBOL_LASTHIGH));
//		case MODE_TIME:
//			return((double)SymbolInfoInteger(symbol,SYMBOL_TIME));
//		case MODE_BID:
//			SymbolInfoTick(_Symbol,last_tick);
//			return (last_tick.bid); //(Bid);
//		case MODE_ASK:
//			SymbolInfoTick(_Symbol,last_tick);
//			return (last_tick.ask); //(Ask);
//		case MODE_POINT:
//			return(SymbolInfoDouble(symbol,SYMBOL_POINT));
//		case MODE_DIGITS:
//			return((double)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
//		case MODE_SPREAD:
//			return((double)SymbolInfoInteger(symbol,SYMBOL_SPREAD));
//		case MODE_STOPLEVEL:
//			return((double)SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL));
//		case MODE_LOTSIZE:
//			return(SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE));
//		case MODE_TICKVALUE:
//			return(SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE));
//		case MODE_TICKSIZE:
//			return(SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE));
//		case MODE_SWAPLONG:
//			return(SymbolInfoDouble(symbol,SYMBOL_SWAP_LONG));
//		case MODE_SWAPSHORT:
//			return(SymbolInfoDouble(symbol,SYMBOL_SWAP_SHORT));
//		case MODE_STARTING:
//			return(0);
//		case MODE_EXPIRATION:
//			return(0);
//		case MODE_TRADEALLOWED:
//			return ((double)(MQLInfoInteger(MQL_TRADE_ALLOWED) && TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)));
//		case MODE_MINLOT:
//			return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN));
//		case MODE_LOTSTEP:
//			return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP));
//		case MODE_MAXLOT:
//			return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX));
//		case MODE_SWAPTYPE:
//			return((double)SymbolInfoInteger(symbol,SYMBOL_SWAP_MODE));
//		case MODE_PROFITCALCMODE:
//			return((double)SymbolInfoInteger(symbol,SYMBOL_TRADE_CALC_MODE));
//		case MODE_MARGINCALCMODE:
//			return(0);
//		case MODE_MARGININIT:
//			return(0);
//		case MODE_MARGINMAINTENANCE:
//			return(0);
//		case MODE_MARGINHEDGED:
//			return(0);
//		case MODE_MARGINREQUIRED:
//			return(0);
//		case MODE_FREEZELEVEL:
//			return((double)SymbolInfoInteger(symbol,SYMBOL_TRADE_FREEZE_LEVEL));
//		
//		default:
//			return(0);
//	}
//	return(0);
//}

double iCloseIndicator(string symbol,int tf,int index)
{
	if(index < 0)
		return(-1);
	
	double Arr[];
	ENUM_TIMEFRAMES timeframe=IntegerToTimeFrame(tf);
	
	if(CopyClose(symbol,timeframe, index, 1, Arr)>0) 
		return(Arr[0]);
	else
		return(-1);
}

double iOpenIndicator(string symbol,int tf,int index)
{   
	if(index < 0)
		return(-1);
	
	double Arr[];
	ENUM_TIMEFRAMES timeframe=IntegerToTimeFrame(tf);
	if(CopyOpen(symbol,timeframe, index, 1, Arr)>0) 
		return(Arr[0]);
	else
		return(-1);
}

datetime iTimeIndicator(string symbol,int tf,int index)
{
	if(index < 0)
		return(-1);
	
	ENUM_TIMEFRAMES timeframe=IntegerToTimeFrame(tf);
	datetime Arr[];
	if(CopyTime(symbol, timeframe, index, 1, Arr)>0)
		return(Arr[0]);
	else
		return(-1);
}

double iLowIndicator(string symbol,int tf,int index)
{
	if(index < 0)
		return(-1);
	
	double Arr[];
	ENUM_TIMEFRAMES timeframe=IntegerToTimeFrame(tf);
	if(CopyLow(symbol,timeframe, index, 1, Arr)>0)
		return(Arr[0]);
	else
		return(-1);
}

double iHighIndicator(string symbol,int tf,int index)
{
	if(index < 0) return(-1);
	double Arr[];
	ENUM_TIMEFRAMES timeframe=IntegerToTimeFrame(tf);
	if(CopyHigh(symbol,timeframe, index, 1, Arr)>0) 
		return(Arr[0]);
	else
		return(-1);
}

//string OrderSymbol()
//{
//   return OrderGetString(ORDER_SYMBOL);
//}
//
//double OrderLots()
//{
//   return OrderGetDouble(ORDER_VOLUME_CURRENT);
//}
//
//double  OrderOpenPrice()
//{
//   return OrderGetDouble(ORDER_PRICE_OPEN);
//}

#endif
