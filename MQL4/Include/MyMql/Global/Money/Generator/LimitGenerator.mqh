#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/Base/BaseObject.mqh>
#include <MyMql/Global/TransactionData.mqh>

class OrderLimit
{
	public:
		int Ticket;
		double VirtualTakeProfit;
		double VirtualStopLoss;
};



class LimitGenerator : public BaseObject
{
	private:
		double StartStep, StopStep, Step, Price, CurrentStepTakeProfit, CurrentStepStopLoss;
		int OrderTypeValue;
		string _symbol;
		
		// Virtual TPs & SLs
		OrderLimit orderLimits[];
		
		
	public:
		LimitGenerator()
		{
			StartStep = 0.0;
			StopStep = 0.0;
			Step = 0.0;
			Price = 0.0;
			OrderTypeValue = 0;
			_symbol = _Symbol;
		}
		
		void GetFirstTransactionData
		(
			LimitData &data,
			string symbol,
			double price,
			int orderType,
			double startStep,
			double stopStep,
			double step
		);
		bool GetNextTransactionData(LimitData &data);
		
		void ValidateAndFixTPandSL(double &TP, double &SL, double price, int orderTypeValue, double spread, bool doesAlert)
		{
			this.Price = price;
			this.OrderTypeValue = orderTypeValue;
			if (TP > 9999999)
        	   SafePrintString(__FUNCSIG__ + " [1] Invalid number TP=" + DoubleToStr(TP), true);
			TP = ValidateTP(TP, spread, doesAlert);
			if (TP > 9999999)
        	   SafePrintString(__FUNCSIG__ + " [2] Invalid number TP=" + DoubleToStr(TP), true);
			
			if (SL > 9999999)
        	   SafePrintString(__FUNCSIG__ + " [1] Invalid number SL=" + DoubleToStr(SL), true);
			SL = ValidateSL(SL, spread, doesAlert);
			if (SL > 9999999)
        	   SafePrintString(__FUNCSIG__ + " [2] Invalid number SL=" + DoubleToStr(SL), true);
		}
		
		double ValidateTP(double TP, double spread, bool doesAlert)
		{
			// to do: add swap too
			// to do: add commission too; we still want profit, duh + expect spread change (if floating spread account)
			if(
#ifdef __MQL4__
			(OrderTypeValue == OP_BUY)
#else
         (OrderTypeValue == ORDER_TYPE_BUY)
#endif
			&& ((TP < Price + spread + Pip()) || (TP == 0.0)))
			{
				if(doesAlert)
					Alert("Invalid TakeProfit " + DoubleToString(TP) + "! [buy: TP < Price]");
				return Price + spread + Pip();
			}
			else if(
#ifdef __MQL4__
			(OrderTypeValue == OP_SELL)
#else
         (OrderTypeValue == ORDER_TYPE_SELL)
#endif
			&& ((TP > Price - spread - Pip()) || (TP == 0.0)))
			{
				if(doesAlert)
					Alert("Invalid TakeProfit " + DoubleToString(TP) + "! [sell: TP > Price]");
				return Price - spread - Pip();
			}
			return TP;
		}
      
		double ValidateSL(double SL, double spread, bool doesAlert)
		{
			// to do: add swap too
			// to do: add commission too; we still want profit, duh + expect spread change (if floating spread account)
			if(
#ifdef __MQL4__
			(OrderTypeValue == OP_BUY)
#else
         (OrderTypeValue == ORDER_TYPE_BUY)
#endif
			&& ((SL > Price - spread - Pip()) || (SL == 0.0)))
			{
				if(doesAlert)
					Alert("Invalid StopLoss " + DoubleToString(SL) + "! [buy: SL > Price]");
				return Price - spread - Pip();
			}
			else if(
#ifdef __MQL4__
			(OrderTypeValue == OP_SELL)
#else
         (OrderTypeValue == ORDER_TYPE_SELL)
#endif
			&& ((SL < Price + spread + Pip()) || (SL == 0.0)))
			{
				if(doesAlert)
					Alert("Invalid StopLoss " + DoubleToString(SL) + "! [sell: SL < Price]");
				return Price + spread + Pip();
			}
			return SL;
		}
		
		
		virtual void CalculateSL(double &slResult, double slLimitPips, int orderType, double openPrice, string symbol, double spread)
		{
		   spread = Spread(symbol);
			
			double pip = Pip();
			
#ifdef __MQL4__
			if (orderType == OP_BUY)
#else
         if (orderType == ORDER_TYPE_BUY)
#endif
				slResult = openPrice - (slLimitPips*pip) - (spread);
#ifdef __MQL4__
			else if (orderType == OP_SELL)
#else
         else if (orderType == ORDER_TYPE_SELL)
#endif
				slResult = openPrice + (slLimitPips*pip) + (spread);
				
			// to do: validate too, when the validation uses swap/commission, etc
			
			if (slResult > 9999999)
        	   SafePrintString(__FUNCSIG__ + " [1] Invalid number slResult=" + DoubleToStr(slResult), true);
		}
		
		virtual void CalculateTP(double &tpResult, double tpLimitPips, int orderType, double openPrice, string symbol, double spread)
		{
		   spread = Spread(symbol);
			
			double pip = Pip();
			
#ifdef __MQL4__
			if (orderType == OP_BUY)
#else
         if (orderType == ORDER_TYPE_BUY)
#endif
				tpResult = openPrice + (tpLimitPips*pip) + (spread);
#ifdef __MQL4__
			else if (orderType == OP_SELL)
#else
         else if (orderType == ORDER_TYPE_SELL)
#endif
				tpResult = openPrice - (tpLimitPips*pip) - (spread);
			
			if (tpResult > 9999999)
        	   SafePrintString(__FUNCSIG__ + " [1] Invalid number TP=" + DoubleToStr(tpResult), true);
			
			// to do: validate too, when the validation uses swap/commission, etc
		}
		
		virtual void CalculateTP_SL(double &tpResult, double &slResult, double tpLimitPips, double slLimitPips, int orderType, double openPrice, string symbol, double spread)
		{
			if(spread == 0.0)
				spread = Spread(symbol);
			
			double pip = Pip();
			
#ifdef __MQL4__
			if (orderType == OP_BUY)
#else
         if (orderType == ORDER_TYPE_BUY)
#endif
			{
				tpResult = openPrice + (tpLimitPips*pip) + (spread);
				slResult = openPrice - (slLimitPips*pip) - (spread);
			}
#ifdef __MQL4__
			else if (orderType == OP_SELL)
#else
         else if (orderType == ORDER_TYPE_SELL)
#endif
			{
				tpResult = openPrice - (tpLimitPips*pip) - (spread);
				slResult = openPrice + (slLimitPips*pip) + (spread);
			}
			
			if (tpResult > 9999999)
      	   SafePrintString(__FUNCSIG__ + " [1] Invalid number tpResult=" + DoubleToStr(tpResult), true);
      	if (slResult > 9999999)
      	   SafePrintString(__FUNCSIG__ + " [1] Invalid number slResult=" + DoubleToStr(slResult), true);
      	
			// to do: validate too, when the validation uses swap/commission, etc
		}
		
		virtual void DeCalculateTP(double tpResult, double &tpLimitPips, int orderType, double openPrice, string symbol, double spread)
		{
			if(tpResult == 0.0)
			{
				tpLimitPips = 0.0;
				return;
			}
			
			if(spread == 0.0)
				spread = Spread(symbol);
			
			double pip = Pip();
			
#ifdef __MQL4__
			if (orderType == OP_BUY)
#else
         if (orderType == ORDER_TYPE_BUY)
#endif
				tpLimitPips = (tpResult - spread - openPrice) / pip;
#ifdef __MQL4__
			else if (orderType == OP_SELL)
#else
         else if (orderType == ORDER_TYPE_SELL)
#endif
				tpLimitPips = (-tpResult - spread + openPrice) / pip;
				
			if (tpLimitPips > 9999999)
      	   SafePrintString(__FUNCSIG__ + " [1] Invalid number tpLimitPips=" + DoubleToStr(tpLimitPips), true);
		}
		
		virtual void DeCalculateSL(double slResult, double &slLimitPips, int orderType, double openPrice, string symbol, double spread)
		{
			if(slResult == 0.0)
			{
				slLimitPips = 0.0;
				return;
			}
			
			if(spread == 0.0)
				spread = Spread(symbol);
			
			double pip = Pip();
			
#ifdef __MQL4__
			if (orderType == OP_BUY)
#else
         if (orderType == ORDER_TYPE_BUY)
#endif
				slLimitPips = (-slResult - spread + openPrice) / pip;
#ifdef __MQL4__
			else if (orderType == OP_SELL)
#else
         else if (orderType == ORDER_TYPE_SELL)
#endif
				slLimitPips = (slResult - spread - openPrice) / pip;
			
			if (slLimitPips > 9999999)
      	   SafePrintString(__FUNCSIG__ + " [1] Invalid number slLimitPips=" + DoubleToStr(slLimitPips), true);
		}
		
		virtual void DeCalculateTP_SL(double tpResult, double slResult, double &tpLimitPips, double &slLimitPips, int orderType, double openPrice, string symbol, double spread)
		{
			if((tpResult == 0.0) || (slResult == 0.0))
			{
				tpLimitPips = 0.0;
				slLimitPips = 0.0;
				return;
			}
			
			if(spread == 0.0)
				spread = Spread(symbol);
			
			double pip = Pip();
			
#ifdef __MQL4__
			if (orderType == OP_BUY)
#else
         if (orderType == ORDER_TYPE_BUY)
#endif
			{
				tpLimitPips = (tpResult - spread - openPrice) / pip;
				slLimitPips = (-slResult - spread + openPrice) / pip;
			}
#ifdef __MQL4__
			else if (orderType == OP_SELL)
#else
         else if (orderType == ORDER_TYPE_SELL)
#endif
			{
				tpLimitPips = (-tpResult - spread + openPrice) / pip;
				slLimitPips = (slResult - spread - openPrice) / pip;
			}
			
			if (tpLimitPips > 9999999)
      	   SafePrintString(__FUNCSIG__ + " [1] Invalid number tpLimitPips=" + DoubleToStr(tpLimitPips), true);
			if (slLimitPips > 9999999)
      	   SafePrintString(__FUNCSIG__ + " [1] Invalid number slLimitPips=" + DoubleToStr(slLimitPips), true);
		}
		
		virtual OrderLimit* operator[](int i) { if(ArraySize(orderLimits) < i) ArrayResize(orderLimits,i+1); return &orderLimits[i]; /* to do: do this everywhere with the same situation? + Debug? :) */ }
		
		virtual bool ExistsOrderLimit(OrderLimit &limit) {
			for(int i=0;i<ArraySize(orderLimits);i++)
				if((orderLimits[i].Ticket == limit.Ticket) &&
				(orderLimits[i].VirtualStopLoss == limit.VirtualStopLoss) &&
				(orderLimits[i].VirtualTakeProfit == limit.VirtualTakeProfit))
					return true;
			return false;
		}
		
		virtual void AddOrderLimit(OrderLimit &limit) {
			if(ExistsOrderLimit(limit))
				return;
			
			int len = ArraySize(orderLimits);
			ArrayResize(orderLimits, len+1);
			orderLimits[len].Ticket = limit.Ticket;
			orderLimits[len].VirtualStopLoss = limit.VirtualStopLoss;
			orderLimits[len].VirtualTakeProfit = limit.VirtualTakeProfit;
		}
		
		
		virtual void FillLimitDataStructure(LimitData &ld, string symbol, ENUM_TIMEFRAMES timeFrame, int cmd, datetime openTime, double openPrice, double inverseOpenPrice, double spread)
		{
			// Default if data is zero/null; This is crazy work; Hope it won't need to be used
			if(StringIsNullOrEmpty(symbol))
				symbol = _Symbol;
			if(timeFrame == PERIOD_CURRENT)
				timeFrame = IntegerToTimeFrame(_Period);
			if(spread == 0.0)
				spread = Spread(symbol);
			if(openPrice == 0.0)
				openPrice = GetOrderOpenPrice(symbol, timeFrame, cmd, iBarShift(symbol, timeFrame, openTime));
			if(inverseOpenPrice == 0.0)
				inverseOpenPrice = GetOrderOpenPrice(symbol, timeFrame, InverseOrderType(cmd), iBarShift(symbol, timeFrame, openTime));
			
			// Calculate stuff or initialize
			if((ld.TakeProfit == 0.0) && (ld.TakeProfitPips != 0.0))
			{
				CalculateTP(ld.TakeProfit, ld.TakeProfitPips, cmd, openPrice, symbol, spread);
         	if (ld.TakeProfit > 9999999)
         	   SafePrintString(__FUNCSIG__ + " [1] Invalid number ld.TakeProfit=" + DoubleToStr(ld.TakeProfit), true);
		   }
			if((ld.StopLoss == 0.0) && (ld.StopLossPips != 0.0))
			{
				CalculateSL(ld.StopLoss, ld.StopLossPips, cmd, openPrice, symbol, spread);
          	if (ld.StopLoss > 9999999)
         	   SafePrintString(__FUNCSIG__ + " [1] Invalid number ld.StopLoss=" + DoubleToStr(ld.StopLoss), true);
			}
			if((ld.StopLossPips == 0.0) && (ld.StopLoss != 0.0))
			{
				DeCalculateSL(ld.StopLoss, ld.StopLossPips, cmd, openPrice, symbol, spread);
          	if (ld.StopLossPips > 9999999)
         	   SafePrintString(__FUNCSIG__ + " [1] Invalid number ld.StopLossPips=" + DoubleToStr(ld.StopLossPips), true);
			}
			if((ld.TakeProfitPips == 0.0) && (ld.TakeProfit != 0.0))
			{
				DeCalculateTP(ld.TakeProfit, ld.TakeProfitPips, cmd, openPrice, symbol, spread);
				if (ld.TakeProfitPips > 9999999)
         	   SafePrintString(__FUNCSIG__ + " [1] Invalid number ld.TakeProfitPips=" + DoubleToStr(ld.TakeProfitPips), true);
         }
			if((ld.InverseTakeProfit == 0.0) && (ld.TakeProfitPips != 0.0))
			{
				CalculateTP(ld.InverseTakeProfit, ld.TakeProfitPips, InverseOrderType(cmd), openPrice, symbol, spread);
				if (ld.InverseTakeProfit > 9999999)
         	   SafePrintString(__FUNCSIG__ + " [1] Invalid number ld.InverseTakeProfit=" + DoubleToStr(ld.InverseTakeProfit), true);
         }
			if((ld.InverseStopLoss == 0.0) && (ld.StopLossPips != 0.0))
			{
				CalculateSL(ld.InverseStopLoss, ld.StopLossPips, InverseOrderType(cmd), openPrice, symbol, spread);
				if (ld.InverseStopLoss > 9999999)
         	   SafePrintString(__FUNCSIG__ + " [1] Invalid number ld.InverseStopLoss=" + DoubleToStr(ld.InverseStopLoss), true);
         }
		}
		
		virtual string ToString();
};


void LimitGenerator::GetFirstTransactionData(
	LimitData &data,
	string symbol,
	double price,
	int orderType,
	double startStep,
	double stopStep,
	double step
)
{
	this.StartStep = startStep;
	this.StopStep = stopStep;
	this.Step = step;
	this.Price = price;
	this.OrderTypeValue = orderType;
	this._symbol = symbol;
	this.CurrentStepTakeProfit = StartStep;
	this.CurrentStepStopLoss = StartStep;
	
	
	if (data.TakeProfit > 9999999)
	   SafePrintString(__FUNCSIG__ + " [1] Invalid number TP=" + DoubleToStr(data.TakeProfit), true);
	if (data.StopLoss > 9999999)
	   SafePrintString(__FUNCSIG__ + " [1] Invalid number StopLoss=" + DoubleToStr(data.StopLoss), true);
	   
	CalculateTP_SL(data.TakeProfit, data.StopLoss, this.CurrentStepTakeProfit, this.CurrentStepStopLoss, this.OrderTypeValue, this.Price, _symbol, 0.0);
	
	if (data.TakeProfit > 9999999)
	   SafePrintString(__FUNCSIG__ + " [2] Invalid number TakeProfit=" + DoubleToStr(data.TakeProfit), true);
	if (data.StopLoss > 9999999)
	   SafePrintString(__FUNCSIG__ + " [2] Invalid number StopLoss=" + DoubleToStr(data.StopLoss), true);
}

bool LimitGenerator::GetNextTransactionData(LimitData &data)
{
	if((StartStep == 0.0) && (StopStep == 0.0) && (Step == 0.0))
		return false;
	
	bool run = true;
	if(CurrentStepTakeProfit >= StopStep)
	{
		CurrentStepTakeProfit = StartStep;
		CurrentStepStopLoss += Step;
	}
	else
		CurrentStepTakeProfit += Step;
	
	if(CurrentStepStopLoss >= StopStep)
	{
		CurrentStepStopLoss = StartStep;
		run = false;
	}
	
	if (data.TakeProfit > 9999999)
	   SafePrintString(__FUNCSIG__ + " [1] Invalid number TP=" + DoubleToStr(data.TakeProfit), true);
	if (data.StopLoss > 9999999)
	   SafePrintString(__FUNCSIG__ + " [1] Invalid number StopLoss=" + DoubleToStr(data.StopLoss), true);
	
	CalculateTP_SL(data.TakeProfit, data.StopLoss, this.CurrentStepTakeProfit, this.CurrentStepStopLoss, this.OrderTypeValue, this.Price, _symbol, 0.0);
	
	if (data.TakeProfit > 9999999)
	   SafePrintString(__FUNCSIG__ + " [2] Invalid number TakeProfit=" + DoubleToStr(data.TakeProfit), true);
	if (data.StopLoss > 9999999)
	   SafePrintString(__FUNCSIG__ + " [2] Invalid number StopLoss=" + DoubleToStr(data.StopLoss), true);
	
	return run;
}

string LimitGenerator::ToString()
{
	string retString = typename(this) + " { ";
	
	retString += "StartStep:" + DoubleToString(StartStep) + " ";
	retString += "StopStep:" + DoubleToString(StopStep) + " ";
	retString += "Step:" + DoubleToString(Step) + " ";
	retString += "Price:" + DoubleToString(Price) + " ";
	retString += "CurrentStepTakeProfit:" + DoubleToString(CurrentStepTakeProfit) + " ";
	retString += "CurrentStepStopLoss:" + DoubleToString(CurrentStepStopLoss) + " ";
	retString += "OrderTypeValue:" + OrderTypeToString(OrderTypeValue) + " ";
	retString += "CurrentStepStopLoss:" + DoubleToString(CurrentStepStopLoss) + " ";
	//retString += GlobalContext.Money.ToString() + " ";
	retString += "_symbol:" + _symbol + " ";
	
	retString += "} ";
	return retString;
}
