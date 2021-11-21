#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/Global/Global.mqh>
#include <MyMql/Simulation/BaseSimulatedOrder.mqh>

class SimulatedOrder : public BaseSimulatedOrder
{
	protected:
		int Ticket;
		
		// Names of created objects
		string SimulatedOrderObjectName;
		string SimulatedStopLossObjectName;
		string SimulatedTakeProfitObjectName;
		string SimulatedTransactionWhole;
		
	public:
		SimulatedOrder(SimulatedOrder &o) : BaseSimulatedOrder(NULL, 0.0, 0.0, 0, 0.0, 0.0, 0, 0, PERIOD_CURRENT)
		{
		   Ticket = o.GetTicket();
		   
			SimulatedOrderObjectName = o.GetSimulatedOrderObjectName();
			SimulatedStopLossObjectName = o.GetSimulatedStopLossObjectName();
			SimulatedTakeProfitObjectName = o.GetSimulatedTakeProfitObjectName();
			SimulatedTransactionWhole = o.GetSimulatedTransactionWhole();
		}
		
		SimulatedOrder(
			string simulatedOrderObjectName = "SimulatedOrder",
			string simulatedStopLossObjectName = "SimulatedStopLoss",
			string simulatedTakeProfitObjectName = "SimulatedTakeProfit",
			string simulatedTransactionWhole = "SimulatedTransactionWhole") : BaseSimulatedOrder(NULL, 0.0, 0.0, 0, 0.0, 0.0, 0, 0, PERIOD_CURRENT)
		{
		   Ticket = 0;
		   
			SimulatedOrderObjectName = simulatedOrderObjectName;
			SimulatedStopLossObjectName = simulatedStopLossObjectName;
			SimulatedTakeProfitObjectName = simulatedTakeProfitObjectName;
			SimulatedTransactionWhole = simulatedTransactionWhole;
		}
		
		virtual void SetTicket(int ticket) { Ticket = ticket; }
		virtual int GetTicket() { return Ticket; }
		
		virtual void SetSimulatedOrderObjectName(string simulatedOrderObjectName = "SimulatedOrder") { this.SimulatedOrderObjectName = simulatedOrderObjectName; }
		virtual string GetSimulatedOrderObjectName() { return this.SimulatedOrderObjectName; }
		
		virtual void SetSimulatedStopLossObjectName(string simulatedStopLossObjectName = "SimulatedStopLoss") { this.SimulatedStopLossObjectName = simulatedStopLossObjectName; }
		virtual string GetSimulatedStopLossObjectName() { return this.SimulatedStopLossObjectName; }
		
		virtual void SetSimulatedTakeProfitObjectName(string simulatedTakeProfitObjectName = "SimulatedTakeProfit") { this.SimulatedTakeProfitObjectName = simulatedTakeProfitObjectName; }
		virtual string GetSimulatedTakeProfitObjectName() { return this.SimulatedTakeProfitObjectName; }
		
		virtual void SetSimulatedTransactionWhole(string simulatedTransactionWhole = "SimulatedTransactionWhole") { this.SimulatedTransactionWhole = simulatedTransactionWhole; }
		virtual string GetSimulatedTransactionWhole() { return this.SimulatedTransactionWhole; }
		
		virtual int SimulateOrderSend( 
			string   symbol,              // symbol 
			int      cmd,                 // operation 
			double   volume,              // volume 
			double   price,               // price 
			int      slippage,            // slippage 
			double   stoploss,            // stop loss 
			double   takeprofit,          // take profit 
			string   comment=NULL,        // comment 
			int      magic=0,             // magic number 
			datetime expiration=0,        // pending order expiration 
			color    arrow_color=clrNONE, // color 
			int shift = 0,
			int ticket = 0                // real order ticket
		)
		{
			BaseSimulatedOrderInitialize(symbol, price, volume, cmd, takeprofit, stoploss, 0, 0, PERIOD_CURRENT);
			
			// Open Price setting
			OpenPrice = GetOrderOpenPrice(symbol,PERIOD_CURRENT,cmd,shift);
			InverseOpenPrice = GetOrderOpenPrice(symbol,PERIOD_CURRENT,InverseOrderType(cmd),shift);
			bool priceIsValid = IsValidOpenAndInverseOpenPrice(OpenPrice, InverseOpenPrice, Spread(symbol));
			
			if(!priceIsValid)
			{
				string message = __FUNCTION__ + " priceIsValid=false even after recalculation for symbol \"" + symbol + "\" in file " + __FILE__;
				/*if(IsVerboseMode())*/ Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
				
				if(IsDebugMode())
					DebugBreak();
			}
			
			// Set internal data:
			OrderSymbolValue = symbol; //SetOrderSymbol(_Symbol);
			OpenTime = iTime(symbol, _Period, shift); //SetOpenTime(Time[shift]);
			OrderTypeValue = cmd; //SetOrderType(cmd);
			Ticket = ticket;
			
			if((shift == 0) && (GlobalContext.Config.IsTradeAllowedOnEA()))
			{
				// a little fashion
				if(arrow_color == clrNONE)
					arrow_color = cmd == OP_BUY ? Blue : (cmd == OP_SELL ? Orange : Gray);
				
				if(GlobalContext.Config.VirtualLimits())
				{
					OrderLimit currentLimit;
					
					currentLimit.VirtualTakeProfit = takeprofit;
					currentLimit.VirtualStopLoss = stoploss;

#ifdef __MQL4__
					currentLimit.Ticket = ticket = OrderSend(symbol, cmd, volume, price, slippage, /*stoploss*/ 0.0, /*takeprofit*/ 0.0, comment, magic, expiration, arrow_color);
#else
               MqlTradeRequest request = {0}; 
               request.action = TRADE_ACTION_DEAL;
               request.magic = magic;
               request.symbol = symbol;
               request.volume = volume;
               request.sl = 0.0;
               request.tp = 0.0;
               request.deviation = slippage;
               request.comment = comment;
               request.expiration = expiration;
               request.price = (cmd == OP_BUY ? SymbolInfoDouble(symbol, SYMBOL_ASK) : SymbolInfoDouble(symbol, SYMBOL_BID));
               request.type = (cmd == OP_BUY ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
               
               MqlTradeResult result = {0};
               bool ok = OrderSend(request, result);
               Print(__FUNCTION__, ":", result.comment, " ok=", ok);
               
               if(result.retcode == 10016)
                  Print(result.bid, result.ask, result.price);
                  
               // to do: arrow_color ignored!! make new object??
#endif					
					GlobalContext.Limit.AddOrderLimit(currentLimit);
				}
				else
				{
#ifdef __MQL4__
					ticket = OrderSend(symbol, cmd, volume, price, slippage, stoploss, takeprofit, comment, magic, expiration, arrow_color);
#else
               MqlTradeRequest request = {0}; 
               request.action = TRADE_ACTION_DEAL;
               request.magic = magic;
               request.symbol = symbol;
               request.volume = volume;
               request.sl = stoploss;
               request.tp = takeprofit;
               request.deviation = slippage;
               request.comment = comment;
               request.expiration = expiration;
               request.price = (cmd == OP_BUY ? SymbolInfoDouble(symbol, SYMBOL_ASK) : SymbolInfoDouble(symbol, SYMBOL_BID));
               request.type = (cmd == OP_BUY ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
               
               MqlTradeResult result = {0};
               bool ok = OrderSend(request, result);
               Print(__FUNCTION__, ":", result.comment, " ok=", ok);
               
               if(result.retcode == 10016)
                  Print(result.bid, result.ask, result.price);
                  
               // to do: arrow_color ignored!! make new object??
#endif
            }
			}
			
			if(expiration != 0)
				OrderExpirationTime = expiration; //SetOrderExpirationTime(expiration);
			if(volume != 0.0)
				Lots = volume; //SetOrderLots(volume);			
			if(takeprofit != 0.0)
				SetTakeProfit(takeprofit, 0);
			if(stoploss != 0.0)
				SetStopLoss(stoploss, 0);
			
			//GlobalContext.Screen.ShowSimulatedOrder(0, SimulatedStopLossObjectName, cmd, Time[shift], price, magic);
			GlobalContext.Screen.ShowSimulatedOrder(1, SimulatedOrderObjectName, cmd, iTime(_Symbol, _Period, shift), price, magic);
			
			if(IsVerboseMode()) {
				printf("%s: price = %f; time = %s", SimulatedOrderObjectName, price, iTime(_Symbol, _Period, shift)); 
			
				if(stoploss != 0) {
					//statusOk = statusOk & GlobalContext.Screen.ShowSimulatedOrder(0, SimulatedStopLossObjectName, cmd, Time[shift], price, magic);
					printf("%s: SL = %f; time = %s", SimulatedOrderObjectName, stoploss, iTime(_Symbol, _Period, shift));
				}
				
				if(takeprofit != 0) {
					//statusOk = statusOk & GlobalContext.Screen.ShowSimulatedOrder(0, SimulatedTakeProfitObjectName, cmd, Time[shift], price, magic);
					printf("%s: SL = %f; time = %s", SimulatedOrderObjectName, takeprofit, iTime(_Symbol, _Period, shift)); 
				}
			}
			
			return ticket;
		}
		
		virtual int GetOrderTichet() { return Ticket; }
		
		virtual bool SimulateOrderModify(
			int        ticket,      // ticket 
			double     price,       // price 
			double     stoploss,    // stop loss 
			double     takeprofit,  // take profit 
			datetime   expiration,  // expiration 
			color      arrow_color, // color 
			int shift = 0
		)
		{
			// Set internal data:
			// you can't change the open price, symbol and open time of an already made order
			if((OrderTypeValue != OP_BUY) && (OrderTypeValue != OP_SELL)) //if((GetOrderType() != OP_BUY) && (GetOrderType() != OP_SELL))
			{
				OpenPrice = price; // SetOrderOpenPrice(price);
				OrderSymbolValue = _Symbol; // SetOrderSymbol(_Symbol);
				OpenTime = iTime(_Symbol, _Period, shift); // SetOpenTime(Time[shift]);
			}
			
			SetTakeProfit(takeprofit, 0);
			SetStopLoss(stoploss, 0);
			SetOrderExpirationTime(expiration); // stores OrderExpirationIsNull too
			
			bool statusOk = true;
			//statusOk = statusOk & GlobalContext.Screen.ShowSimulatedOrder(0, SimulatedOrderObjectName, cmd, Time[shift], price, magic);
			
			if(IsVerboseMode()) {
				printf("%s: price = %f; time = %s", SimulatedOrderObjectName, price, TimeToString(iTime(_Symbol, _Period, shift)));
			
				if(stoploss != 0.0) {
					//statusOk = statusOk & GlobalContext.Screen.ShowSimulatedOrder(0, SimulatedStopLossObjectName, cmd, Time[shift], price, magic);
					printf("%s: SL = %f; time = %s", SimulatedStopLossObjectName, stoploss, TimeToString(iTime(_Symbol, _Period, shift))); 
				}
				
				if(takeprofit != 0.0) {
					//statusOk = statusOk & GlobalContext.Screen.ShowSimulatedOrder(0, SimulatedTakeProfitObjectName, cmd, Time[shift], price, magic);
					printf("%s: SL = %f; time = %s", SimulatedTakeProfitObjectName, takeprofit, TimeToString(iTime(_Symbol, _Period, shift))); 
				}
			}
			
			return statusOk;
		}
		
		
		virtual int SimulatedOrdersTotal(string simulatedOrderObjectName = "")
		{
			if(simulatedOrderObjectName == "")
				simulatedOrderObjectName = this.SimulatedOrderObjectName;
			
			int objectsTotal = ObjectsTotal(ChartID());
			int ordersTotal = 0;
			
			for(int i=0; i<objectsTotal; i++)
				if(StringFind(ObjectName(ChartID(), i), simulatedOrderObjectName) == 0) // starts with "SimulatedOrder"
					ordersTotal++;
			return ordersTotal;
		}
		
		
		virtual double SimulatedOrderStopLoss(int i, string simulatedStopLossObjectName = "")
		{
			if(simulatedStopLossObjectName == "")
				simulatedStopLossObjectName = this.SimulatedStopLossObjectName;
			
			return GetStopLoss(i);
			//return ObjectGetDouble(ChartID(), simulatedStopLossObjectName + IntegerToString(SimulatedOrderSelected), OBJPROP_PRICE);
		}
		
		
		virtual double SimulatedOrderTakeProfit(int i, string simulatedTakeProfitObjectName = "")
		{
			if(simulatedTakeProfitObjectName == "")
				simulatedTakeProfitObjectName = this.SimulatedTakeProfitObjectName;
			
			return GetTakeProfit(i);
			//return ObjectGetDouble(ChartID(), simulatedTakeProfitObjectName + IntegerToString(SimulatedOrderSelected), OBJPROP_PRICE);
		}
		
		virtual void AfterTransactionClose(int cmd, datetime startTime, double openPrice, datetime closeTime, double closePrice) override
		{
			color transactionColor = clrNONE;
			if(cmd == OP_BUY)
			{
				if(openPrice <= closePrice)
					transactionColor = Green;
				else
					transactionColor = Red;
			}
			else if(cmd == OP_SELL)
			{
				if(openPrice >= closePrice)
					transactionColor = Green;
				else
					transactionColor = Red;
			}
			else // do not show objects for unknown/weird transactions
				return;
			
			GlobalContext.Screen.ShowTransactionWhole(SimulatedTransactionWhole, startTime, openPrice, closeTime, closePrice, transactionColor, GlobalContext.Config.GetIntegerValue("ObjectsLimit"));
		}
		
		virtual string ToString()
		{
			string retString = typename(this) + " { ";
			
			retString += "SimulatedOrderObjectName:" + SimulatedOrderObjectName + " ";
			retString += "SimulatedStopLossObjectName:" + SimulatedStopLossObjectName + " ";
			retString += "SimulatedTakeProfitObjectName:" + SimulatedTakeProfitObjectName + " ";
			retString += "SimulatedTransactionWhole:" + SimulatedTransactionWhole + " ";
			retString += "screen:" + GlobalContext.Screen.ToString() + " ";
			
			retString += "} ";
			return retString;
		}
		
		virtual string ToStringOrderMinimalNeededData(bool indent = false, int indentLevel = 0)
		{
			string retString = IndentLevel(indent, indentLevel) + typename(this) + " { ";
			indentLevel++;
			
			retString += this.ToStringMinimalTransactionData(indent, indentLevel);
			
			indentLevel--;
			retString += IndentLevel(indent, indentLevel) + "} ";
			
			return retString;
		}
		
		virtual string ToStringOrderMinimalNeededDataXml(int nr = -1)
		{
			string attr = "";
			
			if(nr >= 0)
			{
				attr = 
					" OrderNumber=\"" + IntegerToString(nr) + "\"" +
					" OpenPrice=\"" + DoubleToString(this.OpenPrice,4) + "\"" +
					" InverseOpenPrice=\"" + DoubleToString(this.InverseOpenPrice,4) + "\"" +
					" OrderStartTime=\"" + TimeToString(this.OpenTime) + "\"" +
					" Lots=\"" + DoubleToString(this.Lots,2) + "\"" +
					" OrderTypeValue=\"" + IntegerToString(this.OrderTypeValue) + "\"" + // OP_SELL, OP_BUY
					"";

				if(this.OrderExpirationIsNull == false)
					attr += " OrderExpirationTime=\"" + TimeToString(this.OrderExpirationTime) + "\"";
					
			}
			string retString = "<" + typename(this) + attr + ">";
			retString += this.ToStringMinimalTransactionDataXml();
			return retString + "</" + typename(this) + ">";
		}
};