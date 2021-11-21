#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql\Base\BaseObject.mqh>
#include <MyMql\Global\Global.mqh>

class BaseLotManagement : BaseObject
{
	public:
		string GetLotName() { return typename(this); }
		
		double GetLotsStep(string symbol)
		{
			double LotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP); // MarketInfo(symbol,MODE_LOTSTEP);
			
			if(LotStep == 0.0) {
				LotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN); //MarketInfo(symbol, MODE_MINLOT);
				 
				string message = __FUNCTION__ + " LotStep is 0.0 for " + _Symbol + "; using MinLot as LotStep";
				if(IsVerboseMode()) Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
			}
			
			if(LotStep == 0.0)
			{
				string message = __FUNCTION__ + " MinLot is 0.0 too for " + _Symbol + "; bail out";
				if(IsVerboseMode()) Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
			}
			
			return LotStep;
		}
		
		bool IsLotValid(string symbol, double lot)
		{
			double correctLot = ValidateLot(symbol, lot);
			return (correctLot == lot);
		}
		
		double ValidateLot(string symbol, double lot)
		{
			double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN); // MarketInfo(symbol, MODE_MINLOT);
			double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX); // MarketInfo(symbol, MODE_MAXLOT);
			
			if(lot < minLot)
				lot = minLot;
			else if(lot > maxLot)
				lot = maxLot;
			
			double lotStep = GetLotsStep(symbol);
			
			// safety mechanism, even though GetLotsStep should always return != 0.0
			if(lotStep == 0.0)
				lotStep = 0.1;
			
			return NormalizeDouble(lot/lotStep,5) * lotStep;
		}
		
		double GetMarginFromLots(string symbol, double lot)
		{
			double validatedLot = ValidateLot(symbol, lot);
			double oneLotMargin = SymbolInfoDouble(symbol, SYMBOL_MARGIN_INITIAL); //MarketInfo(symbol, MODE_MARGINREQUIRED);
			return validatedLot * oneLotMargin;
		}
		
		double GetMaximumLotsWithAvailableFreeMargin(string symbol)
		{
			double totalFreeBalance = AccountInfoDouble(ACCOUNT_MARGIN_FREE); //AccountFreeMargin();
			double oneLotMargin = SymbolInfoDouble(symbol, SYMBOL_MARGIN_INITIAL); //MarketInfo(symbol,MODE_MARGINREQUIRED);
			double LotStep = GetLotsStep(symbol);
			
			// this is only a way of bypassing an error that stops the simulation (later the lot is validated with ValidateLot)
			if(oneLotMargin == 0)
			{
				string message = __FUNCTION__ + " Error: divide by zero avoidance: oneLotMargin=0.0 and now we return 0. better than values (!= 0) which are crap";
				if(IsVerboseMode()) Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
				return 0;
			}
			
			if (LotStep == 0.0)
			{
				Print(__FUNCTION__ + " " + IntegerToString(__LINE__) + " LotStep got zero! LotStep=0.1 now");
				LotStep = 0.1;
			}
			
			double lots = totalFreeBalance/oneLotMargin;
			
			return NormalizeDouble(lots/LotStep,0) * LotStep;
		}
		
		double GetLotsBasedOnDecision(string symbol, double currentDecision, double maxDecision)
		{
			return SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN); //MarketInfo(symbol, MODE_MINLOT);
		}
		
		virtual bool IsMarginOk(string symbol, double currentLots, double percentOfAccount, bool printMargin = false) // save 40% of account by default
		{
			if(StringIsNullOrEmpty(symbol))
				symbol = _Symbol;
			
			if(percentOfAccount > 0.9) // save maximum 90% (more than this makes no sense)
				percentOfAccount = 0.9;
			else if(percentOfAccount < 0.1) // save minimum 10% (less than this is too risky)
				percentOfAccount = 0.1;
			
			currentLots = ValidateLot(symbol, currentLots);
			
#ifdef __MQL4__
			double buyMargin = AccountFreeMarginCheck(symbol, OP_BUY, currentLots); // margin available after order happens
			double sellMargin = AccountFreeMarginCheck(symbol, OP_SELL, currentLots); // margin available after order happens
			double minMargin = (AccountBalance() + AccountCredit()) * percentOfAccount; // minimum margin needed to be left
#else
         double accountFreeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
         double openPrice = iClose(symbol, _Period, 0);
         double sellMargin, buyMargin;
         bool ok = OrderCalcMargin(ORDER_TYPE_SELL, _Symbol, currentLots, openPrice, sellMargin);
         if(!ok)
            Print("OrderCalcMargin(ORDER_TYPE_SELL, _Symbol, currentLots, openPrice, sellMargin) issue in " + __FUNCSIG__);
         ok = OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, currentLots, openPrice, buyMargin);
         if(!ok)
            Print("OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, currentLots, openPrice, buyMargin) issue in " + __FUNCSIG__);
   	   double minMargin = (AccountInfoDouble(ACCOUNT_BALANCE) + AccountInfoDouble(ACCOUNT_CREDIT)) * percentOfAccount;
#endif
			if(printMargin)
				Print("Minimum margin: for buy=" + DoubleToString(buyMargin,2) + " for sell=" + DoubleToString(sellMargin,2) + " accepted=" + DoubleToString(minMargin,2)); 
			
			return ((buyMargin > minMargin) && // buyMargin,sellMargin = margin left after order
					(sellMargin > minMargin) &&  // minMargin = minimum margin needed left
					(_LastError != 134) &&       // 134 = ERR_NOT_ENOUGH_MONEY
					(buyMargin != 0.0) &&
					(sellMargin != 0.0));
		}
		
		virtual bool TryFixMargin(string symbol, double &currentLots, double percentOfAccount = 0.4)
		{
			if(StringIsNullOrEmpty(symbol))
				symbol = _Symbol;
			
			bool newLotStepOk = false;
			double lotStep = GetLotsStep(symbol);
			
			// no way to fix if minimum lots is not ok
			if(!IsMarginOk(symbol, SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN), percentOfAccount, false))
				return false;
			
			// try to downsize the currentLots
			for(double i=currentLots; i>=lotStep; i-=lotStep)
				if(IsMarginOk(symbol, i, percentOfAccount))
				{
					currentLots = i;
					newLotStepOk = true;
					string message = __FUNCTION__ + " Current lots update: currentLots=" + DoubleToString(currentLots,5) + " to fit margin save";
					if(IsVerboseMode()) Print(message);
					GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
						GlobalContext.Config.GetSessionName(),
						message,
						TimeAsParameter());
					break;
				}
			return newLotStepOk;
		}
};