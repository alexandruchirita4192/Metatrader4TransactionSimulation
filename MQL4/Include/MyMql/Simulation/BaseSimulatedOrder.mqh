#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/Global/Global.mqh>
#include <MyMql/Base/BaseObject.mqh>

class BaseSimulatedOrder : public BaseObject {
	private:
		ENUM_TIMEFRAMES TimePeriod;
		
		// each profit, TPs & SLs data
		TransactionData data[];
		
	public:
		
		// Symbol
		string OrderSymbolValue;
		
		// Prices & Lots
		double OpenPrice, InverseOpenPrice, Lots;
		
		// Open Time
		datetime OpenTime;
		
		// Expiration; TODO: mostly unused
		datetime OrderExpirationTime;
		bool OrderExpirationIsNull;
		
		// Commissions and Swaps
		double CurrentOrderSwap, InverseCurrentOrderSwap, // CurrentOrderSwap/InverseCurrentOrderSwap do not contain the real/calculated swap, but contains the swap cost instead
		   // CalculateProfitFor should calculate the proper swap as good as possible
		   CurrentOrderComission;
		
		// Command / Order Type
		int OrderTypeValue; // OP_SELL, OP_BUY
		
		BaseSimulatedOrder(string orderSymbolValue, double openPrice, double lots, int orderTypeValue, double orderTP, double orderSL, datetime orderTime, datetime orderExpirationTime, ENUM_TIMEFRAMES timePeriod)
		{
		   CurrentOrderSwap = 0.0;
		   CurrentOrderComission = 0.0;
			BaseSimulatedOrderInitialize(orderSymbolValue, openPrice, lots, orderTypeValue, orderTP, orderSL, orderTime, orderExpirationTime, timePeriod);
		}
		
		void BaseSimulatedOrderInitialize(string orderSymbolValue, double openPrice, double lots, int orderTypeValue, double orderTP, double orderSL, datetime openTime, datetime orderExpirationTime, ENUM_TIMEFRAMES timePeriod)
		{
		   // OrderSymbolValue
			if(StringIsNullOrEmpty(orderSymbolValue))
				orderSymbolValue = _Symbol;
			OrderSymbolValue = orderSymbolValue;
			
			Lots = lots;
			OrderTypeValue = orderTypeValue;
			
			int lenData = ArraySize(data);
			if (lenData == 0) {
				ArrayResize(data, 1);
				lenData++;
			}
			
			// get openPrice (and InverseOpenPrice) or calculate them
			OpenPrice = openPrice;
			int openTimeShift = iBarShift(orderSymbolValue, timePeriod, openTime);
			if(OpenPrice == 0.0)
				OpenPrice = GetOrderOpenPrice(orderSymbolValue, timePeriod, orderTypeValue, openTimeShift);
			InverseOpenPrice = GetOrderOpenPrice(orderSymbolValue, timePeriod, InverseOrderType(orderTypeValue), openTimeShift);
			
			double spread = Spread(orderSymbolValue); // used by FillLimitDataStructure
			
			for(int i=0;i<lenData;i++)
			{
			   // Cleanup and initialization
				data[i].SetEmpty();
				
				// Limits initialization
				data[i].limits.TakeProfit = orderTP;
				data[i].limits.StopLoss = orderSL;
				
				GlobalContext.Limit.FillLimitDataStructure(data[i].limits, orderSymbolValue, timePeriod, orderTypeValue, openTime, OpenPrice, InverseOpenPrice, spread);
			}
			
			this.OpenTime = ((openTime != 0) ? openTime : TimeCurrent());
			
			OrderExpirationTime = orderExpirationTime;
			OrderExpirationIsNull = orderExpirationTime == 0;
			
			// CurrentOrderSwap, InverseCurrentOrderSwap
#ifdef __MQL4__
	      if (orderTypeValue == OP_BUY)
#else
         if(orderTypeValue == ORDER_TYPE_BUY)
#endif
         {
		      CurrentOrderSwap = SwapLong(orderSymbolValue);
		      InverseCurrentOrderSwap = SwapShort(orderSymbolValue);
		   }
#ifdef __MQL4__
	      else if (orderTypeValue == OP_SELL)
#else
         else if(orderTypeValue == ORDER_TYPE_SELL)
#endif
         {
            CurrentOrderSwap = SwapShort(orderSymbolValue);
            InverseCurrentOrderSwap = SwapLong(orderSymbolValue);
	      }
	      
	      // exclude crappy values if not implemented properly; TODO: Cleanup in some functions??
	      if (CurrentOrderSwap <= -999999.0 || CurrentOrderSwap > 999999999.0)
	      {
	         SafePrintString(__FUNCSIG__ + " CurrentOrderSwap value is invalid " + DoubleToStr(CurrentOrderSwap) + " so it is reset to 0.0", true);
	         CurrentOrderSwap = 0.0;
	      }
	      if (CurrentOrderSwap > 0.0) // most of the time is positive, so no message is logged
		      CurrentOrderSwap = -CurrentOrderSwap;
	      
	      // exclude crappy values if not implemented properly; TODO: Cleanup in some functions??
	      if (InverseCurrentOrderSwap <= -999999.0 || InverseCurrentOrderSwap > 999999999.0)
	      {
	         SafePrintString(__FUNCSIG__ + " InverseCurrentOrderSwap value is invalid " + DoubleToStr(InverseCurrentOrderSwap) + " so it is reset to 0.0", true);
	         InverseCurrentOrderSwap = 0.0;
	      }
	      if (InverseCurrentOrderSwap > 0.0) // most of the time is positive, so no message is logged
		      InverseCurrentOrderSwap = -InverseCurrentOrderSwap;
		    
		   
	      // CurrentOrderComission
	      CurrentOrderComission = OrderCommission();
	      
	      // exclude crappy values if not implemented properly; TODO: Cleanup in some functions??
	      if (CurrentOrderComission <= -999999.0 || CurrentOrderComission > 999999999.0)
	      {
	         SafePrintString(__FUNCSIG__ + " CurrentOrderComission value is invalid " + DoubleToStr(CurrentOrderComission) + " so it is reset to 0.0", true);
	         CurrentOrderComission = 0.0;
	      }
		   if (CurrentOrderComission > 0.0)
		   {
		      CurrentOrderComission = -CurrentOrderComission;
		      SafePrintString("CurrentOrderComission was positive; set it as negative instead: " + DoubleToStr(CurrentOrderComission), true);
		   }
		   
			TimePeriod = timePeriod;
		}
		
		virtual double GetTakeProfit(int i) { if(i < ArraySize(data)) return data[i].limits.TakeProfit; return data[0].limits.TakeProfit; /* TODO: this might need fixes; why return data[0]? at least debug print something!! */ }
		virtual void SetTakeProfit(double TP, int i) {
			if(i >= ArraySize(data))
			{
				string message = __FUNCTION__ +" error! i(=" + IntegerToString(i) + ") >= length(=" + IntegerToString(ArraySize(data)) + ")";
				if(IsVerboseMode()) Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
				return;
			}
				
			if(data[i].OrderIsClosed && data[i].InverseOrderIsClosed)
				return;
			data[i].limits.TakeProfit = TP;
			
			// calculate TP in pips
			GlobalContext.Limit.DeCalculateTP(data[i].limits.TakeProfit, data[i].limits.TakeProfitPips, OrderTypeValue, OpenPrice, this.OrderSymbolValue, Spread(this.OrderSymbolValue));
		}
		
		
		virtual double GetStopLoss(int i) {
			if(i >= ArraySize(data)) {
				string message = __FUNCTION__ +" error! i(=" + IntegerToString(i) + ") >= length(=" + IntegerToString(ArraySize(data)) + "); returned invalid or inexistent data (with pos=0)";
				if(IsVerboseMode()) Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
				return data[0].limits.StopLoss;
			}
			return data[i].limits.StopLoss; /* to do: this might need fixes; why return data[0]? at least debug print something!! */
		}
		
		virtual void SetStopLoss(double SL, int i) {
			if(i >= ArraySize(data))
			{
				string message = __FUNCTION__ +" error! i(=" + IntegerToString(i) + ") >= length(=" + IntegerToString(ArraySize(data)) + ")";
				if(IsVerboseMode()) Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
				return;
			}
				
			if(data[i].OrderIsClosed && data[i].InverseOrderIsClosed)
				return;
			
			data[i].limits.StopLoss = SL;
			
			// calculate SL in pips
			GlobalContext.Limit.DeCalculateSL(data[i].limits.StopLoss, data[i].limits.StopLossPips, OrderTypeValue, OpenPrice, this.OrderSymbolValue, Spread(this.OrderSymbolValue));
		}
		
		virtual void SetLimits(double SL, double TP, int i)
		{
		   if (TP > 9999999)
		      SafePrintString(__FUNCSIG__ + " The TP price is invalid " + DoubleToStr(TP), true);
		   if (SL > 9999999)
		      SafePrintString(__FUNCSIG__ + " The SL price is invalid " + DoubleToStr(SL), true);
		   
			SetTakeProfit(TP, i);
			SetStopLoss(SL, i);
		}
		
		virtual double GetOrderProfit(int i) { if(i < ArraySize(data)) return data[i].Profit; return data[0].Profit; /* to do: this might need fixes; why return data[0]? at least debug print something!! */ }
		virtual void SetOrderProfit(int i, datetime closeTime, datetime inverseCloseTime, double closePrice, double inverseClosePrice) {
			if(i >= ArraySize(data))
			{
				string message = __FUNCTION__ +" error! i(=" + IntegerToString(i) + ") >= length(=" + IntegerToString(ArraySize(data)) + ")";
				if(IsVerboseMode()) Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
				return;
			}
			
			// Calculate profit only if order closed already
			if(data[i].OrderIsClosed && closePrice != 0.0)
				data[i].Profit = SimulatedOrderProfitForNonZeroValues(closeTime, closePrice);
				
			if(data[i].InverseOrderIsClosed && inverseClosePrice != 0.0)
				data[i].InverseProfit = SimulatedOrderInverseProfitForNonZeroValues(inverseCloseTime, inverseClosePrice);
		}
		
		virtual void SetOrderExpirationTime(datetime orderExpirationTime) { if(orderExpirationTime == 0) this.OrderExpirationIsNull = true; else { this.OrderExpirationTime = orderExpirationTime; this.OrderExpirationIsNull = false; } }
      virtual void AfterTransactionClose(int cmd, datetime startTime, double openPrice, datetime closeTime, double closePrice) {}
      
		virtual bool AutoCloseByStopLossOrTakeProfit(int i, datetime closeTime, datetime inverseCloseTime, double closePrice, double inverseClosePrice)
		{
			if(i >= ArraySize(data))
			{
				string message = __FUNCTION__ +" error! i(=" + IntegerToString(i) + ") >= length(=" + IntegerToString(ArraySize(data)) + ")";
				if(IsVerboseMode()) Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
				return true; // this is considered closed; anyway, nothing to do there. to do: debug better
			}
			
			if(data[i].OrderIsClosed && data[i].InverseOrderIsClosed)
				return true;
				
			if((data[i].limits.TakeProfit <= 0.0) || (data[i].limits.StopLoss <= 0.0) || (data[i].limits.InverseTakeProfit <= 0.0) || (data[i].limits.InverseStopLoss <= 0.0))
				return true; // this is considered invalid / close; nothing to do here anyway too
			
			if((closePrice == 0.0) || (inverseClosePrice == 0.0))
			{
				int shift = iBarShift(OrderSymbolValue, 0, closeTime);
				closePrice = iClose(OrderSymbolValue, 0, shift); // ClosePrice for Buy is Bid (Close/Open/Low/High)
				
				if(this.OrderTypeValue == OP_SELL)
				{
					inverseClosePrice = closePrice;
					closePrice += Spread(this.OrderSymbolValue); // ClosePrice for Sell is Ask (Close/Open/Low/High + Spread)
				}
				else
					inverseClosePrice = closePrice + Spread(this.OrderSymbolValue);
			}
			
			if(!data[i].OrderIsClosed)
			{
				bool closing = false;
				if(IsTakeProfitTouched(data[i].limits.TakeProfit, closePrice, OrderTypeValue))
				{
					data[i].OrderClosedByTakeProfit = true;
					closing = true;
				}
				
				if(IsStopLossTouched(data[i].limits.StopLoss, closePrice, OrderTypeValue))
				{
					data[i].OrderClosedByStopLoss = true;
					closing = true;
				}
				
				if(closing)
				{	
					data[i].ClosePrice = closePrice;
					data[i].CloseTime = closeTime;
					data[i].OrderIsClosed = true;
					SetOrderProfit(i, closeTime, inverseCloseTime, closePrice, 0.0);
					AfterTransactionClose(OrderTypeValue, OpenTime, OpenPrice, data[i].CloseTime, data[i].ClosePrice);
				}
			}
			
			if(!data[i].InverseOrderIsClosed)
			{
				bool closing = false;
				if(IsTakeProfitTouched(data[i].limits.InverseTakeProfit, inverseClosePrice, InverseOrderType(OrderTypeValue)))
				{
					data[i].InverseOrderClosedByTakeProfit = true;
					closing = true;
				}
				
				if(IsStopLossTouched(data[i].limits.InverseStopLoss, inverseClosePrice, InverseOrderType(OrderTypeValue)))
				{
					data[i].InverseOrderClosedByStopLoss = true;
					closing = true;
				}
				
				if(closing)
				{
					data[i].InverseClosePrice = inverseClosePrice;
					data[i].InverseCloseTime = closeTime;
					data[i].InverseOrderIsClosed = true;
					SetOrderProfit(i, closeTime, inverseCloseTime, 0.0, inverseClosePrice);
					AfterTransactionClose(OrderTypeValue, OpenTime, InverseOpenPrice, data[i].InverseCloseTime, data[i].InverseClosePrice);
				}
			}
			
			return data[i].OrderIsClosed && data[i].InverseOrderIsClosed;
		}
		
		virtual double SimulatedOrderInverseProfit(datetime closeTime, double inverseClosePrice, bool includeUntestedComissionAndSwap = true)
		{
			int orderTypeValue = InverseOrderType(OrderTypeValue);
			return CalculateProfitFor(InverseOpenPrice, closeTime, inverseClosePrice, orderTypeValue, includeUntestedComissionAndSwap, true);
		}

		virtual double SimulatedOrderProfit(datetime closeTime, double closePrice, bool includeUntestedComissionAndSwap = true)
		{
			return CalculateProfitFor(OpenPrice, closeTime, closePrice, OrderTypeValue, includeUntestedComissionAndSwap, false);
		}
		
		virtual double CalculateProfitFor(double openPrice, datetime closeTime, double closePrice, int orderTypeValue, bool includeUntestedComissionAndSwap = true, bool isInverse = false)
		{
			int shift = iBarShift(OrderSymbolValue, 0, closeTime);
			if(closePrice == 0.0)
				closePrice = iClose(OrderSymbolValue, 0, shift);
			
			double orderLots = Lots * SymbolInfoDouble(OrderSymbolValue, SYMBOL_TRADE_CONTRACT_SIZE);
			double changeRate = GlobalContext.Money.CalculateCurrencyRateForSymbol(OrderSymbolValue, closeTime, PERIOD_CURRENT, shift);
			double extraValue = 0.0;
			
			if((changeRate == 0.0) || (orderLots == 0.0))
			{
				string message = __FUNCTION__ + " Weird calculation with changeRate=" + DoubleToString(changeRate) + " and orderLots=" + DoubleToString(orderLots) + " for symbol=" + OrderSymbolValue + " in file " + __FILE__ + " resulting 0 profit";
				if(IsVerboseMode()) Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
				return 0.0;
			}
			
			// here is the real formula for profit calculation
			if(includeUntestedComissionAndSwap)
			{
			   double days = ((closeTime-OpenTime)/3600.0)/24.0;
			   int daysInt = (int)days;
			   // extraValue is negative because CurrentOrderComission is negative and CurrentOrderSwap/InverseCurrentOrderSwap are negative
			   extraValue = CurrentOrderComission + (!isInverse ? CurrentOrderSwap : InverseCurrentOrderSwap)*daysInt;
			}
			
			if(orderTypeValue == OP_SELL)
				return (openPrice - closePrice) * orderLots * changeRate + extraValue; // extraValue = CurrentOrderComission+CurrentOrderSwap;
			else if(orderTypeValue == OP_BUY)
				return (closePrice - openPrice) * orderLots * changeRate + extraValue; // extraValue = CurrentOrderComission+CurrentOrderSwap;
			
			string message = __FUNCTION__ + " Weird calculation with orderTypeValue=" + IntegerToString(orderTypeValue) + " (not OP_SELL or OP_BUY) in file " + __FILE__ + " resulting 0 profit";
			if(IsVerboseMode()) Print(message);
			GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
				GlobalContext.Config.GetSessionName(),
				message,
				TimeAsParameter());
			return 0.0;
		}
		
		virtual double SimulatedOrderProfitForNonZeroValues(datetime closeTime, double closePrice) {
			if((closeTime == 0) || (closePrice == 0.0))
				return 0.0;
			return SimulatedOrderProfit(closeTime, closePrice);
		}
		
		virtual double SimulatedOrderInverseProfitForNonZeroValues(datetime closeTime, double closePrice) {
			if((closeTime == 0) || (closePrice == 0.0))
				return 0.0;
			return SimulatedOrderInverseProfit(closeTime, closePrice);
		}
		
		virtual bool SimulatedOrderProfitInternalUpdate(int i, datetime closeTime = 0, double closePrice = 0.0, double inverseClosePrice = 0.0) {
			if(i >= ArraySize(data)) {
				string message = __FUNCTION__ +" error! i(=" + IntegerToString(i) + ") >= length(=" + IntegerToString(ArraySize(data)) + ")";
				if(IsVerboseMode()) Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
				return true; // weird way to consider it closed, but duh.. whatever goes; to do: debug better!
			}
			
			if(data[i].OrderIsClosed && data[i].InverseOrderIsClosed)
				return true;
			
			return AutoCloseByStopLossOrTakeProfit(i, closeTime, closeTime, closePrice, inverseClosePrice);
		}
		
		virtual bool SimulatedOrderProfitInternalUpdateAll(datetime closeTime, double closePrice, double inverseClosePrice)
		{
			bool allTransactionDataAreClosed = true;
			for(int i=0;i<ArraySize(data);i++)
				allTransactionDataAreClosed = allTransactionDataAreClosed && SimulatedOrderProfitInternalUpdate(i, closeTime, closePrice, inverseClosePrice);
			return allTransactionDataAreClosed;
		}
		
		virtual void SimulatedOrderCloseUpdateAll(datetime closeTime, int orderTypeValue, double closePrice, double inverseClosePrice)
		{
			for(int i=0;i<ArraySize(data);i++)
				CloseSimulatedOrder(i, closeTime, orderTypeValue, closePrice, inverseClosePrice);
		}
		
		virtual void CloseSimulatedOrder(int i, datetime closeTime, int orderTypeValue, double closePrice, double inverseClosePrice)
		{
			if(i >= ArraySize(data)) {
				string message = __FUNCTION__ +" error! i(=" + IntegerToString(i) + ") >= length(=" + IntegerToString(ArraySize(data)) + ")";
				if(IsVerboseMode()) Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
				return;
			}
			
			if(data[i].OrderIsClosed && data[i].InverseOrderIsClosed)
				return;
			
			if(orderTypeValue != OrderTypeValue) // if OP_SELL instead of OP_BUY or the other way around, interchange close prices
			{
				double aux = closePrice;
				closePrice = inverseClosePrice;
				inverseClosePrice = aux;
			}
			
			if((closePrice == 0.0) || (inverseClosePrice == 0.0))
			{
				int shift = iBarShift(OrderSymbolValue, 0, closeTime);
				closePrice = iClose(OrderSymbolValue, 0, shift); // ClosePrice for Buy is Bid (Close/Open/Low/High)
				
				if(this.OrderTypeValue == OP_SELL) // ClosePrice for Sell is Ask (Close/Open/Low/High + Spread)
				{
					inverseClosePrice = closePrice; // Bid = Close
					closePrice += Spread(this.OrderSymbolValue); // Ask = Close + Spread
				} else {
					// Bid = Close (closePrice is ok)
					inverseClosePrice = closePrice + Spread(this.OrderSymbolValue); // Ask = Close + Spread
				}
			}
			
			// TPs and SLs work first; closing after
			AutoCloseByStopLossOrTakeProfit(i,closeTime,closeTime,closePrice,inverseClosePrice);
			
			if(data[i].OrderIsClosed && data[i].InverseOrderIsClosed)
				return;
			
			data[i].Profit = SimulatedOrderProfit(closeTime, closePrice);
			data[i].InverseProfit = SimulatedOrderInverseProfit(closeTime, inverseClosePrice);
			data[i].ClosePrice = closePrice;
			data[i].InverseClosePrice = inverseClosePrice;
			data[i].CloseTime = closeTime;
			data[i].InverseCloseTime = closeTime;
			data[i].OrderIsClosed = true;
			data[i].InverseOrderIsClosed = true;
			
			AfterTransactionClose(OrderTypeValue, OpenTime, OpenPrice, data[i].CloseTime, data[i].ClosePrice);
			AfterTransactionClose(OrderTypeValue, OpenTime, InverseOpenPrice, data[i].CloseTime, data[i].InverseClosePrice);
			//GlobalContext.Screen.ShowTransactionFromOpenToClose("SimulatedTransaction", OpenTime, OpenPrice, closeTime, data[i].ClosePrice, data[i].Profit > 0 ? Green : Red);
		}
		
		virtual void CloseSimulatedOrderAll(datetime closeTime, int orderTypeValue, double closePrice, double inverseClosePrice)
		{
			for(int i=0;i<ArraySize(data);i++)
				CloseSimulatedOrder(i, closeTime, orderTypeValue, closePrice, inverseClosePrice);
		}
		
		
		virtual int GetTransactionDataSize() { return ArraySize(data); }
		
		// obsolete!! use TransactionDataExists(LimitData) instead + to do: debugging warning if this is called
		virtual bool TransactionDataExists(double takeProfitPips, double stopLossPips)
		{
			int len = ArraySize(data);
			for(int i=0;i<len;i++)
				if((data[i].limits.TakeProfitPips == takeProfitPips) && (data[i].limits.StopLossPips == stopLossPips))
					return true;
			return false;
		}
		
		virtual bool TransactionDataExists(LimitData &limits)
		{
			int len = ArraySize(data);
			for(int i=0;i<len;i++)
				if(data[i].limits == limits)
					return true;
			return false;
		}
		
		virtual void AddTransactionData(LimitData &limits)
		{
			int len = ArraySize(data);
			
			if((len == 1) && (data[0].limits.IsEmpty()))
				len = 0;
			else if(!TransactionDataExists(limits))
				ArrayResize(data, len+1);
			else // some weird case when it will go kaboom!! data exists and nothing should be rewritten
				return;
			
			// TPs and SLs copy (same as
			data[len].limits.CopyData(limits);
		}
		
		virtual TransactionData GetTransactionData(int i) {
			if(i >= ArraySize(data)) {
				string message = __FUNCTION__ +" error! i(=" + IntegerToString(i) + ") >= length(=" + IntegerToString(ArraySize(data)) + "); returned invalid or inexistent data (with pos=0)";
				if(IsVerboseMode()) Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
				return data[0];
			}
			return data[i];
		}
		virtual TransactionData operator[](int i) { return GetTransactionData(i); }
		
		virtual LimitData GetLimitData(int i) {
			if(i >= ArraySize(data))
			{
				string message = __FUNCTION__ +" error! i(=" + IntegerToString(i) + ") >= length(=" + IntegerToString(ArraySize(data)) + "); returned invalid or inexistent data (with pos=0)";
				if(IsVerboseMode()) Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
				return data[0].limits;
			}
			return data[i].limits;
		}
		
		//// to do: improve this! IsProfitCalculatedFromTransactionData & SetInitializedProfit might be weird. Refactor needed.
		//virtual void AutoCalculateProfitFromTransactionData()
		//{
		//	if(!IsProfitCalculatedFromTransactionData()) {
		//		CalculateProfitFromTransactionData();
		//		SetInitializedProfit();
		//	}
		//}
		
		//virtual bool IsProfitCalculatedFromTransactionData()
		//{
		//	int lenData = ArraySize(data);
		//	for(int i=0; i<lenData; i++)
		//		if(data[i].Profit == 0.0)
		//			return false;
		//	return true;
		//}
		
//		virtual void CalculateProfitFromTransactionData()
//		{
//			int lenData = ArraySize(data);
//			this.MinimumProfit = this.MaximumProfit = data[0].Profit;
//			
//			for(int i=0; i<lenData; i++) {
//				if(!data[i].OrderIsClosed)
//					continue;
//				
//				if((data[i].Profit < this.MinimumProfit) && (data[i].Profit != 0.0) && (data[i].OrderIsClosed))
//				{
//					this.MinimumProfit = data[i].Profit;
//					this.WorstStopLoss = data[i].StopLossPips;
//					this.WorstTakeProfit = data[i].TakeProfitPips;
//					this.MinimumProfitIsInverseDecision = false;
//				}
//				
//				if((data[i].Profit > this.MaximumProfit) && (data[i].Profit != 0.0) && (data[i].OrderIsClosed))
//				{
//					this.MaximumProfit = data[i].Profit;
//					this.BestStopLoss = data[i].StopLossPips;
//					this.BestTakeProfit = data[i].TakeProfitPips;
//					this.MaximumProfitIsInverseDecision = false;
//				}
//				
//				if((data[i].InverseProfit < this.MinimumProfit) && (data[i].InverseProfit != 0.0) && (data[i].OrderIsClosed))
//				{
//					this.MinimumProfit = data[i].InverseProfit;
//					this.WorstStopLoss = data[i].StopLossPips;
//					this.WorstTakeProfit = data[i].TakeProfitPips;
//					this.MinimumProfitIsInverseDecision = true;
//				}
//				
//				if((data[i].InverseProfit > this.MaximumProfit) && (data[i].InverseProfit != 0.0) && (data[i].OrderIsClosed))
//				{
//					this.MaximumProfit = data[i].InverseProfit;
//					this.BestStopLoss = data[i].StopLossPips;
//					this.BestTakeProfit = data[i].TakeProfitPips;
//					this.MaximumProfitIsInverseDecision = true;
//				}
//			}
//			this.MediumProfit = (MinimumProfit + MaximumProfit)/2.0;
//		}
		
		virtual string ToString()
		{
			string retString = typename(this) + " { ";
			
			
			retString += "OpenPrice:" + DoubleToString(Normalize(OpenPrice, "OpenPrice")) + " ";
			retString += "InverseOpenPrice:" + DoubleToString(Normalize(InverseOpenPrice, "InverseOpenPrice")) + " ";
			retString += "Lots:" + DoubleToString(Normalize(Lots, "Lots")) + " ";
			retString += "OpenTime:" + TimeToString(OpenTime) + " ";
			retString += "OrderExpirationTime:" + TimeToString(OrderExpirationTime) + " ";
			retString += "OrderExpirationIsNull:" + BoolToString(OrderExpirationIsNull) + " ";
			retString += "OrderSymbolValue:" + OrderSymbolValue + " ";
			retString += "TimePeriod:" + EnumToString(TimePeriod) + " ";
			retString += "OrderTypeValue:" + OrderTypeToString(OrderTypeValue) + " ";
			retString += "data:[" + IntegerToString(ArraySize(data)) + "] ";
			//retString += "money:" + GlobalContext.Money.ToString() + " ";
			//retString += "MaximumProfit:" + DoubleToStr(MaximumProfit) + " ";
			//retString += "MediumProfit:" + DoubleToStr(MediumProfit) + " ";
			//retString += "MinimumProfit:" + DoubleToStr(MinimumProfit) + " ";
			//retString += "BestTakeProfit:" + DoubleToStr(BestTakeProfit) + " ";
			//retString += "BestStopLoss:" + DoubleToStr(BestStopLoss) + " ";
			//retString += "WorstTakeProfit:" + DoubleToStr(WorstTakeProfit) + " ";
			//retString += "WorstStopLoss:" + DoubleToStr(WorstStopLoss) + " ";
			
			retString += "} ";
			return retString;
		}
		
		
		virtual string ToStringMinimalTransactionData(bool indent = false, int indentLevel = 0)
		{
			int lenData = ArraySize(data);
			
			if(lenData == 0)
				return "";
				
			string retString = IndentLevel(indent, indentLevel) + typename(this) + " { ";
			indentLevel++;
			
			retString += IndentLevel(indent, indentLevel) + "data<" + typename(data) + ">:" + IntegerToString(ArraySize(data)) + "{ ";
		
			for(int i=0;i<lenData-1;i++)
				retString += data[i].ToString(indent, indentLevel) + ", ";
		
			if(lenData - 1 > 0) {
				retString += data[lenData-1].ToString(indent, indentLevel);
				indentLevel--;
				retString += IndentLevel(indent, indentLevel) + " } ";
			}
			
			//retString += IndentLevel(indent, indentLevel) + "MaximumProfit:" + DoubleToStr(MaximumProfit, 2) + " ";
			
			indentLevel--;
			retString += IndentLevel(indent, indentLevel) + "} ";
			return retString;
		}
		
		
		virtual bool IsValidOpenAndInverseOpenPrice(double openPrice, double inverseOpenPrice, double spread)
		{
			return (MathAbs(openPrice - inverseOpenPrice) < 2 * spread) || (spread == 0.0); // spread might be approximative, if variable
		}
		
		virtual string ToStringMinimalTransactionDataXml()
		{
			int lenData = ArraySize(data);
			
			if(lenData == 0)
				return "";
				
			string retString = "<" + typename(this) +
				" Lots=\"" + DoubleToString(Normalize(Lots, "Lots")) + "\"" +
				
				" OpenPrice=\"" + DoubleToString(Normalize(OpenPrice, "OpenPrice"), 4) + "\"" +
				" InverseOpenPrice=\"" + DoubleToString(Normalize(InverseOpenPrice, "InverseOpenPrice"), 4) + "\"" +
				
				">";
			
			for(int i=0;i<lenData;i++)
				retString += data[i].ToStringXml() + "\n";
			
			retString += "</" + typename(this) + ">";
			return retString;
		}
};