//+------------------------------------------------------------------+
//|                                           SimulateTranSystem.mqh |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property strict


#include <Charts\Chart.mqh>

#include <MyMql\System\DiscoveryData.mqh>
#include <MyMql\System\ChartTransactionData.mqh>

// Global context
#include <MyMql\Global\Global.mqh>

// Generator module
#include <MyMql\Global\Money\Generator\LimitGenerator.mqh>

// Money management modules
#include <MyMql\Global\Money\MoneyBetOnDecision.mqh>
#include <MyMql\LotManagement\BaseLotManagement.mqh>

// Decision management modules
#include <MyMql\DecisionMaking\DecisionDoubleBB.mqh>
#include <MyMql\DecisionMaking\Decision3CombinedMA.mqh>
#include <MyMql\DecisionMaking\DecisionRSI.mqh>
#include <MyMql\DecisionMaking\DecisionCandle.mqh>
#include <MyMql\DecisionMaking\DecisionMinMax.mqh>
#include <MyMql\DecisionMaking\DecisionPS2.mqh>


// Transaction management module
#include <MyMql\TransactionManagement\BaseTransactionManagement.mqh>
#include <MyMql\TransactionManagement\SimpleTransactionManagement.mqh>
#include <MyMql\TransactionManagement\ConfirmTransactionManagement.mqh>
#include <MyMql\TransactionManagement\ScalpingTransactionManagement.mqh>


//// UnOwned Transaction management modules commented
//#include <MyMql\UnOwnedTransactionManagement\CrappyTranManagement.mqh>
//#include <MyMql\UnOwnedTransactionManagement\FlowWithTrendTranMan.mqh>


class BaseSimulateTranSystem : public BaseObject
{
	private:
		// Transaction data for each chart
		int posTranData;
		ChartTransactionData InvalidChartTransactionData;
		
		
	public:
		ChartTransactionData chartTranData[];
		virtual bool HasChartTransactionData() { return ArraySize(chartTranData) > 0; }
		
		BaseSimulateTranSystem() { posTranData = -1; InvalidChartTransactionData.SetEmpty(); }
		~BaseSimulateTranSystem() { }
	
		// It is made to return invalid data - it is only a skeleton
		virtual bool IsConfigurationInvalid() { return true; }
		virtual bool IsSetupInvalid() { return true; }
		virtual void SetupTransactionSystem() {} //string symbol = NULL, ENUM_TIMEFRAMES timeFrame = PERIOD_CURRENT) { }
		
		virtual void TestTransactionSystemForCurrentSymbol (
			bool useLogging = true,
			bool simulateTranSystemOnlyTradeAllowedNow = true) { }
		
		virtual void RunTransactionSystemForCurrentSymbol (bool useLogging = true) { }
		
		virtual void LogAndClean(BaseDecision *decision, BaseLotManagement *lot, BaseTransactionManagement *transaction, bool isBulk, ChartTransactionData &currentChartData, unsigned long volume, bool keepAllObjects = false)
		{
			string xmlSerializedData =
				"<SerializedData" +
					" AccountCompany=\"" + AccountInfoString(ACCOUNT_COMPANY) + "\"" +
					" AccountServer=\"" + AccountInfoString(ACCOUNT_SERVER) + "\"" +
					" AccountNumber=\"" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "\"" +
					" AccountClientName=\"" + AccountInfoString(ACCOUNT_NAME) + "\"" +
					" AccountCurrency=\"" + AccountInfoString(ACCOUNT_CURRENCY) + "\"" +

					" Symbol=\"" + _Symbol + "\"" +
					" Period=\"" + EnumToString(IntegerToTimeFrame(_Period)) + "\"" +
					" PeriodStartTime=\"" + TimeToString(iTime(_Symbol, _Period, iBars(_Symbol,_Period)-1)) + "\"" +
					" PeriodEndTime=\"" + TimeToString(iTime(_Symbol, _Period, 0)) + "\"" +
					" Bars=\"" + IntegerToString(iBars(_Symbol,_Period)) + "\"" +
					
					" Volume=\"" + IntegerToString(volume) + "\"" + // Medium volume
					
					" Spread=\"" + DoubleToString(Spread(_Symbol), 4) + "\"" +
					" SpreadPips=\"" + DoubleToString(SpreadPips(_Symbol), 4) + "\"" +
					" Volatility=\"" + DoubleToString(Volatility(), 4) + "\"" +
					" VolatilityPips=\"" + DoubleToString(VolatilityPips(), 4) + "\"" +
					
					" DecisionName=\"" + GlobalContext.DatabaseLog.EscapeString(decision.GetDecisionName()) + "\"" +
					" TransactionName=\"" + GlobalContext.DatabaseLog.EscapeString(transaction.GetTransactionName()) + "\"" +
					" LotName=\"" + GlobalContext.DatabaseLog.EscapeString(lot.GetLotName()) + "\"" +
					
					" OrdersCount=\"" + IntegerToString(transaction.GetOrdersCount()) + "\"" +
					" MinLots=\"" + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN), 4) + "\"" +
					" MinLotsMargin=\"" + DoubleToString(lot.GetMarginFromLots(_Symbol, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN)), 4) + "\"" +
					" LastDecisionBar=\"" + IntegerToString(currentChartData.LastDecisionBarShift, 4) + "\"" +
					" LastDecisionTime=\"" + TimeToString(currentChartData.LastDecisionBarDateTime, 4) + "\"" +
					" LastDecisionType=\"" + OrderTypeToString(currentChartData.lastDecision) + "\"" +
					
				"/>";
			string dataName = decision.GetDecisionName() + " on " + _Symbol + " and period " + EnumToString(IntegerToTimeFrame(_Period));
			
			// CallWebServiceProcedure
			GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile(), dataName, xmlSerializedData);
			GlobalContext.DatabaseLog.CallWebServiceProcedure("DataLog");
			
			if(isBulk)
				transaction.BulkLogAllOrdersXml();
			else
				transaction.LogAllOrdersXml();
			
   		// send all debug messages with BulkDebugLog
   		GlobalContext.DatabaseLog.CallBulkWebServiceProcedure("BulkDebugLog", true);
   		
			// clean only on simulation
			transaction.CleanAll(keepAllObjects);
		}
		
		// ChartTransactionData functions
		virtual void CleanTranData()
		{
			ArrayResize(chartTranData,0);
		}
		
		virtual void Clean() { CleanTranData(); }
		
		virtual bool IsInverseDecisionForChartTransactionData(string symbol, ENUM_TIMEFRAMES timeFrame, string decisionName, string lotName, string transactionName)
		{
			if(ArraySize(chartTranData) <= 0)
				return false;
			
			if(StringIsNullOrEmpty(symbol))
				symbol = _Symbol;
			if(timeFrame == PERIOD_CURRENT)
				timeFrame = IntegerToTimeFrame(_Period);
			
			for(int i=0;i<ArraySize(chartTranData);i++)
				if((chartTranData[i].TranSymbol == symbol) &&
				(chartTranData[i].TimeFrame == timeFrame) &&
				(chartTranData[i].DecisionName == decisionName) &&
				(chartTranData[i].LotName == lotName) &&
				(chartTranData[i].TransactionName == transactionName))
					return chartTranData[i].IsInverseDecision;
			
			return false;
		}
		
		virtual bool ExistsChartTransactionDataWithTradeAllowed()
		{
			if(!GlobalContext.Config.IsTradeAllowedOnEA())
				return false;
			
			for(int i=0;i<ArraySize(chartTranData);i++)
				if(GlobalContext.Config.IsTradeAllowedOnEA(chartTranData[i].TranSymbol))
					return true;
			
			return false;
		}
		
		virtual bool ExistsChartTransactionData(ChartTransactionData &chartTranDataLocal)
		{
			if(ArraySize(chartTranData) <= 0)
				return false;
			
			if(StringIsNullOrEmpty(chartTranDataLocal.TranSymbol))
				chartTranDataLocal.TranSymbol = _Symbol;
			if(chartTranDataLocal.TimeFrame == PERIOD_CURRENT)
				chartTranDataLocal.TimeFrame = IntegerToTimeFrame(_Period);
			
			for(int i=0;i<ArraySize(chartTranData);i++)
				if((chartTranData[i].TranSymbol == chartTranDataLocal.TranSymbol) &&
				(chartTranData[i].TimeFrame == chartTranDataLocal.TimeFrame) &&
				(chartTranData[i].DecisionName == chartTranDataLocal.DecisionName) &&
				(chartTranData[i].LotName == chartTranDataLocal.LotName) &&
				(chartTranData[i].TransactionName == chartTranDataLocal.TransactionName))
					return true;
			
			return false;
		}
		
		virtual bool ExistsChartTransactionData(string symbol, ENUM_TIMEFRAMES timeFrame, string decisionName, string lotName, string transactionName)
		{
			ChartTransactionData newChart(symbol, timeFrame, decisionName, lotName, transactionName, false, 0.0, 0.0);
			return ExistsChartTransactionData(newChart);
		}
		
		virtual bool IsValidChartTransactionData(string symbol, ENUM_TIMEFRAMES timeFrame, string decisionName, string lotName, string transactionName, int decisionsLength /*ArraySize(decisions)*/)
		{
			// symbol is inexistent for this broker; wrong broker? whatever. bail out!
			if(!GlobalContext.Library.SymbolDataExists(symbol))
				return false;
			
			// cannot change symbol based on config; bail out!
			if((symbol != _Symbol) &&
			(GlobalContext.Config.IsOnlyOneSymbol()))
				return false;
			
			return true;
		}
		
		virtual void AddChartTransactionDataFromXml(XmlElement *element) /*, BaseDecision &decisionsVector[], BaseTransactionManagement &transactionsVector[]*/
		{
			ChartTransactionData currentTranData(element); /*, decisionsVector, transactionsVector*/ // FillDataFromXmlElement inside
			
			if(!ExistsChartTransactionData(currentTranData.TranSymbol, currentTranData.TimeFrame, currentTranData.DecisionName, currentTranData.LotName,currentTranData.TransactionName))
			{
				int len = ArraySize(chartTranData);
				ArrayResize(chartTranData,len+1);
				chartTranData[len].CopyTransactionData(currentTranData);
			}
		}
		
		virtual void AddChartTransactionData(string symbol, ENUM_TIMEFRAMES timeFrame, string decisionName, string lotName, string transactionName, bool isInverseDecision)
		{
			if(ExistsChartTransactionData(symbol, timeFrame, decisionName, lotName, transactionName))
				return;
			
			int len = ArraySize(chartTranData);
			ArrayResize(chartTranData,len+1);
			ChartTransactionData currentTranData(symbol, timeFrame, decisionName, lotName, transactionName, isInverseDecision, 0.0, 0.0);
			chartTranData[len].CopyTransactionData(currentTranData);
		}
		
		virtual ChartTransactionData FirstPositionTransactionData()
		{
			if(ArraySize(chartTranData) > 0)
				return chartTranData[0];
			return InvalidChartTransactionData;
		}
		
		virtual ChartTransactionData CurrentPositionTransactionData()
		{
			int len = ArraySize(chartTranData);
			if((posTranData >= 0) && (posTranData < len))
				return chartTranData[posTranData];
				
			return InvalidChartTransactionData;
		}
		
		virtual void SetPositionFromCurrentTransactionData(string symbol, ENUM_TIMEFRAMES timeFrame, string decisionName, string lotName, string transactionName)
		{
			posTranData = CurrentTransactionDataPosition(symbol, timeFrame, decisionName, lotName, transactionName);
		}
		
		virtual int CurrentTransactionDataPosition(string symbol, ENUM_TIMEFRAMES timeFrame, string decisionName, string lotName, string transactionName)
		{
			if(ArraySize(chartTranData) <= 0)
			{
				Print(__FUNCTION__ + " No chart transaction data. ArraySize(chartTranData)=" + IntegerToString(ArraySize(chartTranData)));
				return -1;
			}
			
			if(StringIsNullOrEmpty(symbol))
				symbol = _Symbol;
			if(timeFrame == PERIOD_CURRENT)
				timeFrame = IntegerToTimeFrame(_Period);
			
			for(int i=0;i<ArraySize(chartTranData);i++)
				if((chartTranData[i].TranSymbol == symbol) &&
				(chartTranData[i].TimeFrame == timeFrame) &&
				(chartTranData[i].DecisionName == decisionName) &&
				(chartTranData[i].LotName == lotName) &&
				(chartTranData[i].TransactionName == transactionName))
					return i;
			
			for(int i=0;i<ArraySize(chartTranData);i++)
				if((chartTranData[i].TranSymbol == symbol) &&
				(chartTranData[i].DecisionName == decisionName) &&
				(chartTranData[i].LotName == lotName) &&
				(chartTranData[i].TransactionName == transactionName))
			{
					Print(__FUNCTION__ + " TimeFrame " + EnumToString(timeFrame) + " does not exist. Using values for timeFrame " + EnumToString(chartTranData[i].TimeFrame));
					return i;
			}
			
			return -1;
		}
		
		virtual ChartTransactionData CurrentTransactionData(string symbol, ENUM_TIMEFRAMES timeFrame, string decisionName, string lotName, string transactionName)
		{
			if(ArraySize(chartTranData) <= 0)
				return InvalidChartTransactionData;
			
			if(StringIsNullOrEmpty(symbol))
				symbol = _Symbol;
			if(timeFrame == PERIOD_CURRENT)
				timeFrame = IntegerToTimeFrame(_Period);
			
			for(int i=0;i<ArraySize(chartTranData);i++)
				if((chartTranData[i].TranSymbol == symbol) &&
				(chartTranData[i].TimeFrame == timeFrame) &&
				(chartTranData[i].DecisionName == decisionName) &&
				(chartTranData[i].LotName == lotName) &&
				(chartTranData[i].TransactionName == transactionName))
					return chartTranData[i];
			
			return InvalidChartTransactionData;
		}
		
		virtual ChartTransactionData NextPositionTransactionData()	
		{
			if(ArraySize(chartTranData) > posTranData+1)
			{
				posTranData++;
				// to do: check if NextTransactionData can be traded and go to next if it can't (recursively?)
				return chartTranData[posTranData];
			}
			else // make it circular (change charts after each tick)
				return FirstPositionTransactionData();
		}
		
		virtual ChartTransactionData NextTransactionDataWithTradeAllowed()	
		{
			if((posTranData > 0) && (ArraySize(chartTranData) > posTranData+1))
			{
				posTranData++;
				// to do: check if NextTransactionData can be traded and go to next if it can't (recursively?)
				return chartTranData[posTranData];
			}
			else // make it circular (change charts after each tick)
				return FirstPositionTransactionData();
		}
		
		virtual void CopyTransactionData(ChartTransactionData &tranDataArray[])
		{
			int len = ArraySize(chartTranData);
			ArrayResize(tranDataArray, len);
			
			for(int i=0;i<len;i++)
			   tranDataArray[i].CopyTransactionData(chartTranData[i]);
		}
		
		virtual void ReplaceTransactionDataArray(ChartTransactionData &tranDataArray[])
		{
			int len = ArraySize(tranDataArray);
			ArrayResize(chartTranData, len);
			
			for(int i=0;i<len;i++)
			   chartTranData[i].CopyTransactionData(tranDataArray[i]);
		}
		
		virtual void PrintDeInitReason(const int reason)
		{
			if(_LastError != 0)
			{
				string message = __FUNCTION__ + " ErrorDescription(_LastError=" + IntegerToString(_LastError) + "): " + ErrorDescription(_LastError);
				/*if(IsVerboseMode())*/ SafePrintString(message, true);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
			}
			
			Print("UninitDescription(reason=" + IntegerToString(reason) + "): " + UninitDescription(reason));
		}
};
