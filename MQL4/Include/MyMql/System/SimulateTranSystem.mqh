#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


//Base system stuff
#include <MyMql\System\BaseSimulateTranSystem.mqh>
#include <MyMql\System\GeneratorConfig.mqh>
#include <MyMql\System\DiscoveryData.mqh>

// Global context
#include <MyMql\Global\Global.mqh>



enum ENUM_DECISION_TYPE
{
	DECISION_TYPE_AUTO = 0,
	DECISION_TYPE_ALL  = 1,
	DECISION_TYPE_NONE = 2,
	
	DECISION_TYPE_MA = 3,
	DECISION_TYPE_3MA = 4,
	DECISION_TYPE_BB = 5,
	DECISION_TYPE_2BB = 6,
	DECISION_TYPE_RSI = 7,
	DECISION_TYPE_3RSI = 8,
	DECISION_TYPE_CANDLE = 9,
	DECISION_TYPE_MIN_MAX = 10,
	DECISION_TYPE_PS2 = 11
	
};

enum ENUM_LOT_MANAGEMENT_TYPE
{
	LOT_MANAGEMENT_AUTO = 0,
	LOT_MANAGEMENT_ALL  = 1,
	LOT_MANAGEMENT_NONE = 2,
	LOT_MANAGEMENT_BASE = 3
};

enum ENUM_TRANSACTION_MANAGEMENT_TYPE
{
	TRANSACTION_MANAGEMENT_AUTO = 0,
	TRANSACTION_MANAGEMENT_ALL  = 1,
	TRANSACTION_MANAGEMENT_NONE = 2,
	TRANSACTION_MANAGEMENT_BASE = 3,
	TRANSACTION_MANAGEMENT_SIMPLE = 4,
	TRANSACTION_MANAGEMENT_SCALPING = 5,
	TRANSACTION_MANAGEMENT_CONFIRM = 6
};



class SimulateTranSystem : public BaseSimulateTranSystem
{
	private:
		// Allowed configurations
		ENUM_DECISION_TYPE AllowedDecisionsConfig;
		ENUM_LOT_MANAGEMENT_TYPE AllowedLotManagementConfig;
		ENUM_TRANSACTION_MANAGEMENT_TYPE AllowedTransactionManagementConfig;
		
		// Arrays of decisions, lot managements, transaction management
		BaseDecision *decisions[];
		BaseLotManagement *lots[];
		BaseTransactionManagement *transactions[];
		
		DiscoveryData discoveryData[];
		
		virtual bool SetupOrConfigFailed(bool printMessages)
		{
			if(IsConfigurationInvalid())
			{
				if(printMessages)
					Print(__FUNCTION__ + " Invalid configuration. Contructor with initialization, Initialize or InitializeFromFirstChartTranData were not called!");
				
				//Initialize();
				
				//if(IsConfigurationInvalid())
				//{
					//Print("Configuration still invalid. Returning.");
					return true;
				//}
			}
			
			// if NONE input, then NONE output 2
			if(IsSetupInvalid())
			{
				if(printMessages)
					Print(__FUNCTION__ + " Invalid setup. SetupTransactionSystem wasn't called! Calling it to fix.");
				
				SetupTransactionSystem();
				
				if(IsSetupInvalid())
				{
					Print("Setup still invalid. Returning. ArraySize(decisions)=" + IntegerToString(ArraySize(decisions)) +
						" ArraySize(lots)=" + IntegerToString(ArraySize(lots)) +
						" ArraySize(transactions)=" + IntegerToString(ArraySize(transactions)));
					return true;
				}
			}
			return false;
		}
		
		virtual void InternalSystemRunForCurrentSymbol(
			bool useLogging,
			bool simulateTranSystem,
			bool simulateTranSystemOnlyTradeAllowedNow,
			bool printMessages = false,
			bool isLightSystem = false,
			bool keepAllObjects = false)
		{
			// if NONE input, then NONE output
			if(SetupOrConfigFailed(printMessages))
				return;
			
			// length of each part
			int lenDecisions = ArraySize(decisions),
				lenLots = ArraySize(lots),
				lenTransactions = ArraySize(transactions);
			unsigned long volume = 0, nrOfTimeSheetBars = 0;
			
			if(isLightSystem)
			{
				// skip transactions; use base instead
				ArrayResize(transactions,1);
				lenTransactions = 1;
				transactions[0] = new BaseTransactionManagement();
				AllowedTransactionManagementConfig = TRANSACTION_MANAGEMENT_BASE;
				
				// skip lots; use base instead
				ArrayResize(lots,1);
				lenLots = 1;
				lots[0] = new BaseLotManagement();
				AllowedLotManagementConfig = LOT_MANAGEMENT_BASE;
			}
			
			// iterate transactions
			for(int transactionIndex=0; transactionIndex<lenTransactions; transactionIndex++)
			{
			   if(transactions[transactionIndex] == NULL)
			      continue;
			   
				GlobalContext.Screen.PrintCurrentValue(transactionIndex, transactions[transactionIndex].GetTransactionName(), "TransactionIndex", clrNONE, 20, 20, 1);
				
				bool validateAndFixLimits = transactions[transactionIndex].ValidateAndFixLimits();
						
				// iterate decisions
				for(int decisionIndex=0; decisionIndex<lenDecisions; decisionIndex++)
				{
				   if(decisions[decisionIndex] == NULL)
				      continue;
				   
					GlobalContext.Screen.PrintCurrentValue(decisionIndex, decisions[decisionIndex].GetDecisionName(), "DecisionIndex", clrNONE, 20, 20, 2);
					
					// iterate lots (management)
					for(int lotIndex=0; lotIndex<lenLots; lotIndex++)
					{
					   if(lots[lotIndex] == NULL)
					      continue;
					   
						bool OrdersAreClosed = true;
						unsigned long decisionsCount = 0;
						
						// ignore symbols which cannot be traded (both in simulation with simulateTranSystemOnlyTradeAllowedNow=true and for EA)
						if(!ValidateTradeAllowedNow(_Symbol, simulateTranSystem, simulateTranSystemOnlyTradeAllowedNow))
							continue;
						
						// Get chart transaction data (or add chart transaction data in simulation)
						int currentChartTransactionDataPosition = CurrentTransactionDataPosition(_Symbol, IntegerToTimeFrame(_Period), decisions[decisionIndex].GetDecisionName(), lots[lotIndex].GetLotName(), transactions[transactionIndex].GetTransactionName());
						if(!ValidateChartTransactionData(simulateTranSystem, currentChartTransactionDataPosition, decisionIndex, lotIndex, transactionIndex))
							continue;
						
						// Parse all history only for simulateTranSystem; else check decision only for current bar
						int timeShift = (((simulateTranSystem) || (chartTranData[currentChartTransactionDataPosition].LastBarDateTime == MinDateTime)) ? iBars(_Symbol,_Period) - 1 : iBarShift(_Symbol,IntegerToTimeFrame(_Period), chartTranData[currentChartTransactionDataPosition].LastBarDateTime));
						GlobalContext.Screen.PrintCurrentValue(timeShift, NULL, "TimeShift", clrNONE, 20, 20, 3); // TimeToString(iTime(_Symbol, PERIOD_CURRENT, timeShift))
						
						if((transactionIndex == 0) && (decisionIndex == 0) && (lotIndex == 0))
						{
							volume = 0;
							nrOfTimeSheetBars = timeShift;
						}
						
						// avoid "divide by zero"
						if(nrOfTimeSheetBars == 0)
							nrOfTimeSheetBars = 1;
						
						for(; timeShift>=0; timeShift--)
						{
							if((transactionIndex == 0) && (decisionIndex == 0) && (lotIndex == 0))
								volume += iVolume(_Symbol, _Period, timeShift);
							
							unsigned long currentDecisionType = 0;
							double currentDecision = decisions[decisionIndex].GetDecision(timeShift, currentDecisionType);
							
							if(currentDecision == IncertitudeDecision)
								continue;
							
							decisionsCount++;
							double TP = decisions[decisionIndex].GetTP();
							double SL = decisions[decisionIndex].GetSL();
							
							if(timeShift % 7 == 0 || timeShift == 0)
								GlobalContext.Screen.PrintCurrentValue(timeShift, NULL, "TimeShift", clrNONE, 20, 20, 3); // TimeToString(iTime(_Symbol, PERIOD_CURRENT, timeShift))
							
							double currentLots = lots[lotIndex].GetLotsBasedOnDecision(_Symbol, currentDecision, decisions[decisionIndex].GetMaxDecision());
							
							// Check margin both ways for EA; ignore decision for safety reasons ~ save some margin (by default 40%)
							if(!ValidateMargin(_Symbol, lots[lotIndex], 0.4, currentLots, simulateTranSystem))
								continue;
							
							// Make decision inverse if needed by chartTranData (and change TP & SL too)
							ChangeLimitsAndDecisionForInverseDecision(chartTranData[currentChartTransactionDataPosition], simulateTranSystem, currentDecision, TP, SL);
							
							// Some transactions might not use TPs & SLs
							if(!isLightSystem)
							{
								transactions[transactionIndex].ReplaceLimits(TP, SL);
							
								// Transaction validation							}
								if(!transactions[transactionIndex].ValidateTransactionBeforeRunning(chartTranData[currentChartTransactionDataPosition], currentDecision))
									continue;
							}
							
							if(!simulateTranSystem)
							   Print("Decision name: " + decisions[decisionIndex].GetDecisionName() + " DecisionType: " + DoubleToString(currentDecision,2) + " DecisionsCount: " + IntegerToString(decisionsCount) + " TP: " + DoubleToString(TP,5) + " SL:" + DoubleToString(SL,5));
							
							// Send order
							transactions[transactionIndex].FullSimulateOrderSend(_Symbol, PERIOD_CURRENT, timeShift, currentDecision, currentLots, TP, SL, validateAndFixLimits);
							OrdersAreClosed = false;
							
							// Generator if is configured, only the first time, only for decisions without irregular limits (no need for new limits)
							if((generatorConfig.UseGenerator) &&
							(timeShift == iBars(_Symbol,_Period)-1) &&
							(ArraySize(generatorData) == 0) &&
							(!decisions[decisionIndex].DecisionWithIrregularLimits()))
								AddGeneratorData();
								
							// Irregular decisions
							else
							{
								if((timeShift == iBars(_Symbol,_Period)-1) && (!decisions[decisionIndex].DecisionWithIrregularLimits()))
									transactions[transactionIndex].AutoAddTransactionData(SpreadPips());
							}
							
							// Update chart transaction data last decision information
							UpdateChartTranDataLastDecisionInfo(_Symbol, chartTranData[currentChartTransactionDataPosition], currentDecision, currentLots, timeShift, TP, SL);
							
							if(!isLightSystem)
							{
								// Make changes
								transactions[transactionIndex].MakeChangesBasedOnTrend(chartTranData[currentChartTransactionDataPosition]);
								
								// Calculate close time & close price for orders (only in simulations)
								if((simulateTranSystem) && (!OrdersAreClosed))
									OrdersAreClosed = transactions[transactionIndex].CalculateData(timeShift);
							}
						}
						
						GlobalContext.Screen.CleanAllObjects();

						chartTranData[currentChartTransactionDataPosition].LastBarDateTime = iTime(_Symbol, IntegerToTimeFrame(_Period), 0);
						
						// Log & Clean System @ LOOP
						if(simulateTranSystem)
						{
							Print("DecisionsCount=" + IntegerToString(decisionsCount) + 
								" DecisionName:\"" + decisions[decisionIndex].GetDecisionName() +
								"\" TransactionName:\"" + transactions[transactionIndex].GetTransactionName() + 
								"\" LastDecision:\"" + OrderTypeToString(chartTranData[currentChartTransactionDataPosition].lastDecision) + "\"");
							
							if(GlobalContext.Config.GetBoolValue("GetBestTPandSL"))
							{
								double TP, SL, Profit, InverseProfit;
								int count, countNegative, countPositive, countInverseNegative, countInversePositive;
								bool IsInverseDecision;
								
								transactions[transactionIndex].GetBestTPandSL(TP, SL, Profit, InverseProfit, count, countNegative, countPositive, countInverseNegative, countInversePositive, IsInverseDecision);
								
								if(GlobalContext.Config.GetBoolValue("GetBestTPandSLWithTPandSL"))
									SafePrintString(
										"DecisionName:\"" + decisions[decisionIndex].GetDecisionName() +
										"\" TP=" + DoubleToString(TP,4) +
										" SL=" + DoubleToString(SL,4), true);
								
								SafePrintString(
									"DecisionName:\"" + decisions[decisionIndex].GetDecisionName() +
									"\" Profit=" + DoubleToString(Profit,2) +
									" InvProfit=" + DoubleToString(InverseProfit,2) +
									" IsInverse=" + BoolToString(IsInverseDecision) +
									" cnt=" + IntegerToString(count) +
									" cntPos=" + IntegerToString(countPositive) +
									" cntInvPos=" + IntegerToString(countInversePositive), true);
							}
						
							if(!isLightSystem)
								LogAndClean(decisions[decisionIndex], lots[lotIndex], transactions[transactionIndex], true, chartTranData[currentChartTransactionDataPosition], volume / nrOfTimeSheetBars, keepAllObjects);
							else
								transactions[transactionIndex].LightSystemCalculation();
							
							CleanTranData();
						}
						else
						{
							int lastDecisionBarShift = chartTranData[currentChartTransactionDataPosition].LastDecisionBarShift; // or iBarShift(_Symbol, IntegerToTimeFrame(_Period), chartTranData[currentChartTransactionDataPosition].LastDecisionBarDateTime);
							Print("Last decision time was " + TimeToString(chartTranData[currentChartTransactionDataPosition].LastDecisionBarDateTime) + " or " + IntegerToString(lastDecisionBarShift) + " bars");
							
							// Send order from old decision if transaction management allowes it
							if(transactions[transactionIndex].RunTransactionFromOldDecision(lastDecisionBarShift))
							{
								transactions[transactionIndex].FullSimulateOrderSend(
									_Symbol,
									PERIOD_CURRENT,
									0,
									chartTranData[currentChartTransactionDataPosition].lastDecision,
									chartTranData[currentChartTransactionDataPosition].lastDecisionLots,
									//decisions[decisionIndex].GetOrderTypeBasedOnDecision(chartTranData[currentChartTransactionDataPosition].lastDecision),
									chartTranData[currentChartTransactionDataPosition].lastDecisionTakeProfit,
									chartTranData[currentChartTransactionDataPosition].lastDecisionStopLoss,
									validateAndFixLimits
									);
								OrdersAreClosed = false;
							}
						}
					}
				}

				GlobalContext.Screen.CleanCurrentValue("TransactionIndex");
				GlobalContext.Screen.CleanCurrentValue("DecisionIndex");
				GlobalContext.Screen.CleanCurrentValue("TimeShift");
			}


		}

	public:
		SimulateTranSystem(
			ENUM_DECISION_TYPE allowedDecisionsConfig = DECISION_TYPE_NONE,
			ENUM_LOT_MANAGEMENT_TYPE allowedMoneyManagementConfig = LOT_MANAGEMENT_NONE,
			ENUM_TRANSACTION_MANAGEMENT_TYPE allowedTransactionManagementConfig = TRANSACTION_MANAGEMENT_NONE)
		{
			Initialize(allowedDecisionsConfig, allowedMoneyManagementConfig, allowedTransactionManagementConfig);
			
		   LogInfoMessage("SimulateTranSystem initialized [" + EnumToString(allowedDecisionsConfig) + "," + EnumToString(allowedMoneyManagementConfig) + "," + EnumToString(allowedTransactionManagementConfig) + "]");
		}
		
		void SimulateTranSystemDeInitialize()
		{
			Clean();
		}
		
		virtual void Initialize(
			ENUM_DECISION_TYPE allowedDecisionsConfig = DECISION_TYPE_NONE,
			ENUM_LOT_MANAGEMENT_TYPE allowedMoneyManagementConfig = LOT_MANAGEMENT_NONE,
			ENUM_TRANSACTION_MANAGEMENT_TYPE allowedTransactionManagementConfig = TRANSACTION_MANAGEMENT_NONE)
		{
			this.AllowedDecisionsConfig = allowedDecisionsConfig;
			this.AllowedLotManagementConfig = allowedMoneyManagementConfig;
			this.AllowedTransactionManagementConfig = allowedTransactionManagementConfig;
		}
		
		// Generator initializer variables
		GeneratorConfig generatorConfig;
		
		// Generator data
		LimitData generatorData[];

		
		virtual void PrintFirstChartTranData()
		{
			Print("DecisionName:" + chartTranData[0].DecisionName + " Inverse:" + BoolToString(chartTranData[0].IsInverseDecision));
			Print("TransactionName:" + chartTranData[0].TransactionName);
			Print("LotName:" + chartTranData[0].LotName);
		}
		
		virtual void InitializeFromFirstChartTranData(bool allIfEmpty = false)
		{
			if(ArraySize(chartTranData) == 0)
				ArrayResize(chartTranData,1);
			
			if(chartTranData[0].DecisionName == typename(DecisionCombinedMA))
				this.AllowedDecisionsConfig = DECISION_TYPE_MA;
			else if(chartTranData[0].DecisionName == typename(Decision3CombinedMA))
				this.AllowedDecisionsConfig = DECISION_TYPE_3MA;
			else if(chartTranData[0].DecisionName == typename(DecisionDoubleBB))
				this.AllowedDecisionsConfig = DECISION_TYPE_2BB;
			else if(chartTranData[0].DecisionName == typename(DecisionRSI))
				this.AllowedDecisionsConfig = DECISION_TYPE_3RSI;
			else if(chartTranData[0].DecisionName == typename(DecisionCandle))
				this.AllowedDecisionsConfig = DECISION_TYPE_CANDLE;
			else if(allIfEmpty)
				this.AllowedDecisionsConfig = DECISION_TYPE_ALL;
			
			if(chartTranData[0].TransactionName == typename(BaseTransactionManagement))
				this.AllowedTransactionManagementConfig = TRANSACTION_MANAGEMENT_BASE;
			else if(chartTranData[0].TransactionName == typename(SimpleTransactionManagement))
				this.AllowedTransactionManagementConfig = TRANSACTION_MANAGEMENT_SIMPLE;
			else if(chartTranData[0].TransactionName == typename(ConfirmTransactionManagement))
				this.AllowedTransactionManagementConfig = TRANSACTION_MANAGEMENT_CONFIRM;
			else if(chartTranData[0].TransactionName == typename(ScalpingTransactionManagement))
				this.AllowedTransactionManagementConfig = TRANSACTION_MANAGEMENT_SCALPING;
			else if(allIfEmpty)
				this.AllowedTransactionManagementConfig = TRANSACTION_MANAGEMENT_ALL;
			
			if(chartTranData[0].LotName == typename(BaseLotManagement))
				this.AllowedLotManagementConfig = LOT_MANAGEMENT_BASE;
			else if(allIfEmpty)
				this.AllowedLotManagementConfig = LOT_MANAGEMENT_ALL;
		}
		
		virtual bool IsConfigurationInvalid() {
			return ((this.AllowedDecisionsConfig == DECISION_TYPE_NONE) ||
				(this.AllowedLotManagementConfig == LOT_MANAGEMENT_NONE) ||
				(this.AllowedTransactionManagementConfig == TRANSACTION_MANAGEMENT_NONE));
		}
		
		virtual bool IsSetupInvalid() {
			return ((ArraySize(decisions) <= 0) ||
				(ArraySize(lots) <= 0) ||
				(ArraySize(transactions) <= 0));
		}
		
		virtual void SetTransactionSystem(string symbol = NULL, ENUM_TIMEFRAMES timeFrame = PERIOD_CURRENT)
		{
			if(StringIsNullOrEmpty(symbol))
				symbol = _Symbol;
		}
		
		virtual void SetupTransactionSystem()
		{
			// if NONE input, then NONE output
			if(IsConfigurationInvalid())
				return;
			
			if(ArraySize(decisions) != 0)
			{
				string message = __FUNCTION__ + " \"decisions\" array already initialized in " + __FILE__;
				if(IsVerboseMode()) Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
				return;
			}

			// Decisions management array fill
			if((this.AllowedDecisionsConfig == DECISION_TYPE_AUTO) || (this.AllowedDecisionsConfig == DECISION_TYPE_ALL)) {
				ArrayResize(decisions, 4);
				decisions[0] = new DecisionDoubleBB(1, 0);
				decisions[1] = new DecisionCombinedMA(1, 0);
				decisions[2] = new Decision3CombinedMA(1, 0);
				decisions[3] = new DecisionRSI(1, 0);
				//decisions[4] = new DecisionCandle();
				//decisions[5] = new DecisionMinMax(PERIOD_CURRENT, 5.0 * Pip());
				//decisions[6] = new DecisionPS2();
			} else if(this.AllowedDecisionsConfig == DECISION_TYPE_2BB) {
				ArrayResize(decisions, 1);
				decisions[0] = new DecisionDoubleBB(1, 0);
			} else if(this.AllowedDecisionsConfig == DECISION_TYPE_MA) {
				ArrayResize(decisions, 1);
				decisions[0] = new DecisionCombinedMA(PERIOD_CURRENT, 1, 0);
			} else if(this.AllowedDecisionsConfig == DECISION_TYPE_3MA) {
				ArrayResize(decisions, 1);
				decisions[0] = new Decision3CombinedMA(1, 0);
			} else if(this.AllowedDecisionsConfig == DECISION_TYPE_3RSI) {
				ArrayResize(decisions, 1);
				decisions[0] = new DecisionRSI(1, 0);
			} else if(this.AllowedDecisionsConfig == DECISION_TYPE_CANDLE) {
				ArrayResize(decisions, 1);
				decisions[0] = new DecisionCandle();
			}
			
			if(ArraySize(lots) != 0)
			{
				string message = __FUNCTION__ + " \"lot\" array already initialized in " + __FILE__;
				if(IsVerboseMode()) Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
				return;
			}

			// Lot management array fill
			if((this.AllowedLotManagementConfig == LOT_MANAGEMENT_AUTO) || (this.AllowedLotManagementConfig == LOT_MANAGEMENT_ALL) ||
				(this.AllowedLotManagementConfig == LOT_MANAGEMENT_BASE)) {
				ArrayResize(lots,1);
				lots[0] = new BaseLotManagement();
			}
			
			if(ArraySize(transactions) != 0)
			{
				string message = __FUNCTION__ + " \"transactions\" array already initialized in " + __FILE__;
				if(IsVerboseMode()) Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
				return;
			}
			
			// Transaction management array fill
			if((this.AllowedTransactionManagementConfig == TRANSACTION_MANAGEMENT_AUTO) || (this.AllowedTransactionManagementConfig == TRANSACTION_MANAGEMENT_ALL)) {
				ArrayResize(transactions, 4);
				transactions[0] = new BaseTransactionManagement();
				transactions[1] = new SimpleTransactionManagement();
				transactions[2] = new ConfirmTransactionManagement();
				transactions[3] = new ScalpingTransactionManagement();
			} else if(this.AllowedTransactionManagementConfig == TRANSACTION_MANAGEMENT_BASE) {
				ArrayResize(transactions,1);
				transactions[0] = new BaseTransactionManagement();
			} else if(this.AllowedTransactionManagementConfig == TRANSACTION_MANAGEMENT_SIMPLE) {
				ArrayResize(transactions,1);
				transactions[0] = new SimpleTransactionManagement();
			} else if(this.AllowedTransactionManagementConfig == TRANSACTION_MANAGEMENT_CONFIRM) {
				ArrayResize(transactions,1);
				transactions[0] = new ConfirmTransactionManagement();
			} else if(this.AllowedTransactionManagementConfig == TRANSACTION_MANAGEMENT_SCALPING) {
				ArrayResize(transactions,1);
				transactions[0] = new ScalpingTransactionManagement();
			}
		}
		
		virtual void ExcludeChartTranDataWithMinlotsNotTransactionable()
		{
			BaseLotManagement baseLotManagement;
			ChartTransactionData tranDataArray[];
			this.CopyTransactionData(tranDataArray);
			int len = ArraySize(tranDataArray);
			
			// symbols cleaning; remove wrong margin symbols
			for(int i=0;i<len;i++)
			{
				string symbol = tranDataArray[i].TranSymbol;
				double minLots = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
				
				if(!baseLotManagement.IsMarginOk(symbol, minLots, 0.4))
				{
					string message = __FUNCTION__ + " ChartTransactionData excluded because margin is not enough for symbol \"" + symbol + "\" in file " + __FILE__;
					/*if(IsVerboseMode())*/ Print(message);
					GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
						GlobalContext.Config.GetSessionName(),
						message,
						TimeAsParameter());
					
					for(int k=i;k<len;k++)
						tranDataArray[i] = tranDataArray[i+1];
					ArrayResize(tranDataArray, len-1);
					i = i - 1;
					len = ArraySize(tranDataArray);
				}
			}
			
			ReplaceTransactionDataArray(tranDataArray);
		}
		
		// to do: remove unused decision, transaction, lot management - check with tranDataArray/ChartTransactionData
		virtual void RemoveUnusedDecisionsTransactionsAndLots()
		{
			int len;
			ChartTransactionData tranDataArray[];
			this.CopyTransactionData(tranDataArray);
			
			// decisions cleaning; remove unused decisions
			len = ArraySize(decisions);
			for(int i=0;i<len;i++)
			{
				bool exists = false;
				for(int j=0;j<ArraySize(tranDataArray);j++)
					if((decisions[i] != NULL) && tranDataArray[j].DecisionName == decisions[i].GetDecisionName())
						exists = true;
				
				if(!exists)
				{
					if(CheckPointer(decisions[i]) == POINTER_DYNAMIC)
						delete decisions[i];
					
					for(int k=i;k<len-1;k++)
						decisions[i] = decisions[i+1];
					ArrayResize(decisions, len-1);
					i = i - 1;
					len = ArraySize(decisions);
				}
			}
			
			// transactions cleaning; remove unused transactions
			len = ArraySize(transactions);
			for(int i=0;i<len;i++)
			{
				bool exists = false;
				for(int j=0;j<ArraySize(tranDataArray);j++)
					if(tranDataArray[j].TransactionName == transactions[i].GetTransactionName())
						exists = true;
				
				if(!exists)
				{
					if(CheckPointer(transactions[i]) == POINTER_DYNAMIC)
						delete transactions[i];
					
					for(int k=i;k<len-1;k++)
						transactions[i] = transactions[i+1];
					ArrayResize(transactions, len-1);
					i = i - 1;
					len = ArraySize(transactions);
				}
			}
			
			// lots cleaning; remove unused transactions
			len = ArraySize(lots);
			for(int i=0;i<len;i++)
			{
				bool exists = false;
				for(int j=0;j<ArraySize(tranDataArray);j++)
					if(tranDataArray[j].LotName == lots[i].GetLotName())
						exists = true;
				
				if(!exists)
				{
					if(CheckPointer(lots[i]) == POINTER_DYNAMIC)
						delete lots[i];
					
					for(int k=i;k<len-1;k++)
						transactions[i] = transactions[i+1];
					ArrayResize(lots, len-1);
					i = i - 1;
					len = ArraySize(lots);
				}
			}
		}
		
		virtual void TestTransactionSystemForCurrentSymbol (
			bool useLogging = true,
			bool simulateTranSystemOnlyTradeAllowedNow = true,
			bool isLightSystem = false,
			bool keepAllObjects = false,
			bool printMessages = false)
		{
			InternalSystemRunForCurrentSymbol(useLogging, true, simulateTranSystemOnlyTradeAllowedNow, printMessages, isLightSystem, keepAllObjects);
		}
		
		virtual void RunTransactionSystemForCurrentSymbol (bool useLogging = true, bool printMessages = false)
		{
         RemoveUnusedDecisionsTransactionsAndLots(); // EA should run faster; delete unused stuff in arrays
         ExcludeChartTranDataWithMinlotsNotTransactionable(); // EA shouldn't try for nothing
			InternalSystemRunForCurrentSymbol(useLogging, false, false, printMessages);
		}
		
		virtual void AddChartTransactionData(XmlElement *element)
		{
			AddChartTransactionDataFromXml(element);
		}
		
		virtual void LoadCurrentOrdersToAllTransactionTypes()
		{
			bool tradeWasAllowedOnEA = GlobalContext.Config.IsTradeAllowedOnEA();
			
			if(tradeWasAllowedOnEA)
				GlobalContext.Config.DenyTrades();
			
#ifdef __MQL4__
			for(int currentChartTransactionDataPosition=0; currentChartTransactionDataPosition<ArraySize(chartTranData); currentChartTransactionDataPosition++)
			{
				chartTranData[currentChartTransactionDataPosition].lastDecision = OP_BUYLIMIT;


				for(int i=0;i<OrdersTotal();i++)
				{
					bool ok = OrderSelect(i, SELECT_BY_POS);
					int orderType = OrderType();
					
					if((orderType != OP_SELL) && (orderType != OP_BUY))
						continue;
					
					if(OrderSymbol() != _Symbol)
						continue;
					
					if(ok) {
						int shift = iBarShift(_Symbol, PERIOD_CURRENT /*IntegerToTimeFrame(_Period)*/, OrderOpenTime());
						
						for(int j=0;j<ArraySize(transactions);j++)
							transactions[j].SimulateOrderSend(
								_Symbol, orderType, OrderLots(), OrderOpenPrice(), /*Slippage*/ 0, OrderStopLoss(),
								OrderTakeProfit(), OrderComment(), OrderMagicNumber(), OrderExpiration(),
								clrNONE, shift, OrderTicket());
						
						chartTranData[currentChartTransactionDataPosition].lastDecision = orderType;
					}
				}	
			}
#else
         Print("Metatrader 5 " + __FUNCSIG__ + " not ported ");
#endif

			if(tradeWasAllowedOnEA)
				GlobalContext.Config.AllowTrades();
		}
		
		virtual bool ValidateMargin(string symbol, BaseLotManagement &currentLotsManagement, double saveMarginPercent, double &currentLots, bool simulateTranSystem)
		{
			if((!simulateTranSystem) && (!currentLotsManagement.IsMarginOk(symbol, currentLots, saveMarginPercent)))
			{
				string message = __FUNCTION__ + " Not enough margin for currentLots=" + DoubleToString(currentLots,5) + " and saveMarginPercent=" + DoubleToString(saveMarginPercent,2);
				/*if(IsVerboseMode())*/ Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
				
				if((!simulateTranSystem) && (!currentLotsManagement.TryFixMargin(symbol, currentLots, saveMarginPercent)))
					return false;
			}
			return true;
		}
		
		virtual bool ValidateTradeAllowedNow(string symbol, bool simulateTranSystem, bool simulateTranSystemOnlyTradeAllowedNow)
		{
			datetime timeRightNow = iTime(symbol, PERIOD_CURRENT, 0);
			bool isTradeAllowed = IsTradeAllowed(symbol, timeRightNow);
			
			if(((!simulateTranSystem) || // EA
			((simulateTranSystem) && (simulateTranSystemOnlyTradeAllowedNow))) && // simulation & only trade allowed now
			(!isTradeAllowed)) // check if trade allowed
			{
				string message = __FUNCTION__ + " Trade not allowed on symbol " + symbol + " now/" + TimeToString(timeRightNow) + ". Doing nothing in " + __FUNCTION__ + ".";
				/*if(IsVerboseMode())*/ Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
				
				return false;
			}
			
			return true;
		}
		
		virtual bool ValidateChartTransactionData(bool simulateTranSystem, int &currentChartTransactionDataPosition, int decisionIndex, int lotIndex, int transactionIndex)
		{
			if(!simulateTranSystem)
			{
				if(currentChartTransactionDataPosition == -1)
				{
					string message = __FUNCTION__ + " ChartTransactionData data skipped: Symbol=" + _Symbol + 
						" Period=" + EnumToString(IntegerToTimeFrame(_Period)) +
						" decisionIndex=" + IntegerToString(decisionIndex) +
						" lotIndex=" + IntegerToString(lotIndex) +
						" transactionIndex=" + IntegerToString(transactionIndex) +
						" ArraySize(chartTranData)=" + IntegerToString(ArraySize(chartTranData)) + 
						" ArraySize(decisions)=" + IntegerToString(ArraySize(decisions)) + 
						" ArraySize(transactions)=" + IntegerToString(ArraySize(transactions)) + 
						" ArraySize(lots)=" + IntegerToString(ArraySize(lots));
					/*if(IsVerboseMode())*/ SafePrintString(message);
					GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
						GlobalContext.Config.GetSessionName(),
						message,
						TimeAsParameter());
					
					return false;
				}
			}
			else
			{
				if(currentChartTransactionDataPosition == -1)
				{
					AddChartTransactionData(_Symbol, IntegerToTimeFrame(_Period), decisions[decisionIndex].GetDecisionName(), lots[lotIndex].GetLotName(), transactions[transactionIndex].GetTransactionName(), false);
					currentChartTransactionDataPosition = CurrentTransactionDataPosition(_Symbol, IntegerToTimeFrame(_Period), decisions[decisionIndex].GetDecisionName(), lots[lotIndex].GetLotName(), transactions[transactionIndex].GetTransactionName());
				}
			}
			
			return true;
		}			
			
		virtual void ChangeLimitsAndDecisionForInverseDecision(ChartTransactionData &currentChartTranData, bool simulateTranSystem, double &currentDecision, double &TP, double &SL)
		{
			if((!simulateTranSystem) && (currentChartTranData.IsInverseDecision)) // IsInverseDecisionForChartTransactionData(_Symbol, IntegerToTimeFrame(_Period), decisionIndex, lotIndex, transactionIndex)
			{
				currentDecision = -currentDecision;
				double aux = TP; TP = SL; SL = aux;
			}
		}
		
		virtual void AddGeneratorData()
		{
//			GlobalContext.Limit.GetFirstTransactionData(
//				generatorData[tranInternalDataIndex],
//				false,
//				price,
//				orderTypeValue,
//				generatorConfig.GeneratorStart * SpreadPips(),
//				generatorConfig.GeneratorStop * SpreadPips(),
//				generatorConfig.GeneratorStep * SpreadPips()
//			);
//			GlobalContext.Limit.ValidateAndFixTPandSL(
//				generatorData[tranInternalDataIndex].TakeProfit,
//				generatorData[tranInternalDataIndex].StopLoss,
//				price,
//				orderTypeValue);
//
//			while((++tranInternalDataIndex < ArraySize(generatorData)) &&
//			(GlobalContext.Limit.GetNextTransactionData(generatorData[tranInternalDataIndex])))
//				GlobalContext.Limit.ValidateAndFixTPandSL(
//					generatorData[tranInternalDataIndex].TakeProfit,
//					generatorData[tranInternalDataIndex].StopLoss,
//					price,
//					orderTypeValue
//				);
//			transactions[transactionIndex].AutoAddTransactionData(generatorData);
		}
		
		virtual bool SymbolExistsInDiscovery(string symbolName)
		{
			int len = ArraySize(discoveryData);
			for(int i=0;i<len;i++)
				if(discoveryData[i].symbol == symbolName)
					return true;
			return false;
		}
		
		virtual void SystemDiscovery()
		{
			if(SymbolExistsInDiscovery(_Symbol))
				return;
			
			int len = ArraySize(discoveryData);
			ArrayResize(discoveryData, len + 1);
			
			discoveryData[len].Initialize(
				_Symbol,
				SpreadFromSymbol(_Symbol),
				Volatility(_Symbol),
				MaxPossibleMinLots(_Symbol),
				iVolume(_Symbol,PERIOD_CURRENT, 0),
				SwapLong(_Symbol),
				SwapShort(_Symbol)
			);
		}
		
		virtual void SystemDiscoveryDeleteWorseThanAverage()
		{
			int len = ArraySize(discoveryData);
			double sumSpreadPips = 0.0, avgSpreadPips;
			double sumSwap = 0.0, avgSwap;
			double sumVolatility = 0.0, avgVolatility;
			double sumVolume = 0.0, avgVolume;
			double sumMaxPossibleMinlots = 0.0, avgMaxPossibleMinlots;
			
			for(int i=0;i<len;i++)
			{
				sumSpreadPips += discoveryData[i].spread;
				sumSwap += (discoveryData[i].swapLong + discoveryData[i].swapShort)/2.0;
				sumVolatility += discoveryData[i].volatility;
				sumVolume += discoveryData[i].volume;
				sumMaxPossibleMinlots += discoveryData[i].maxPossibleMinlots;
			}
			
			avgSpreadPips = sumSpreadPips / len;
			avgSwap = sumSwap / len;
			avgVolatility = sumVolatility / len;
			avgVolume = sumVolume / len;
			avgMaxPossibleMinlots = sumMaxPossibleMinlots / len;
			
			for(int i=0;i<len;i++)
			{
				if((discoveryData[i].spread < avgSpreadPips) ||
				(((discoveryData[i].swapLong + discoveryData[i].swapShort)/2.0) < avgSwap) ||
				(discoveryData[i].volatility < avgVolatility) ||
				(discoveryData[i].volume < avgVolume) ||
				(discoveryData[i].maxPossibleMinlots < avgMaxPossibleMinlots))
				{
					for(int j=i;j<len-1;j++)
						discoveryData[j] = discoveryData[j+1];
					ArrayResize(discoveryData, len-1);
					len -= 1;
				}
			}
		}


		virtual void SystemDiscoveryPrintBetterThanAverage()
		{
			int len = ArraySize(discoveryData);
			double sumSpreadPips = 0.0, avgSpreadPips;
			double sumSwap = 0.0, avgSwap;
			double sumVolatility = 0.0, avgVolatility;
			double sumVolume = 0.0, avgVolume;
			double sumMaxPossibleMinlots = 0.0, avgMaxPossibleMinlots;
			
			for(int i=0;i<len;i++)
			{
				sumSpreadPips += discoveryData[i].spread;
				sumSwap += (discoveryData[i].swapLong + discoveryData[i].swapShort)/2.0;
				sumVolatility += discoveryData[i].volatility;
				sumVolume += discoveryData[i].volume;
				sumMaxPossibleMinlots += discoveryData[i].maxPossibleMinlots;
			}
			
			avgSpreadPips = sumSpreadPips / len;
			avgSwap = sumSwap / len;
			avgVolatility = sumVolatility / len;
			avgVolume = sumVolume / len;
			avgMaxPossibleMinlots = sumMaxPossibleMinlots / len;
			
			for(int i=0;i<len;i++)
			{
				if((discoveryData[i].spread < avgSpreadPips) ||
				(((discoveryData[i].swapLong + discoveryData[i].swapShort)/2.0) < avgSwap) ||
				(discoveryData[i].volatility < avgVolatility) ||
				(discoveryData[i].volume < avgVolume) ||
				(discoveryData[i].maxPossibleMinlots < avgMaxPossibleMinlots))
				{
   					discoveryData[i].SystemPrintDiscoveryData("BetterThanAVG: ");
				}
			}
		}

		virtual void SystemDiscoveryPrintWorseThanAverage()
		{
			int len = ArraySize(discoveryData);
			double sumSpreadPips = 0.0, avgSpreadPips;
			double sumSwap = 0.0, avgSwap;
			double sumVolatility = 0.0, avgVolatility;
			double sumVolume = 0.0, avgVolume;
			double sumMaxPossibleMinlots = 0.0, avgMaxPossibleMinlots;
			
			for(int i=0;i<len;i++)
			{
				sumSpreadPips += discoveryData[i].spread;
				sumSwap += (discoveryData[i].swapLong + discoveryData[i].swapShort)/2.0;
				sumVolatility += discoveryData[i].volatility;
				sumVolume += discoveryData[i].volume;
				sumMaxPossibleMinlots += discoveryData[i].maxPossibleMinlots;
			}
			
			avgSpreadPips = sumSpreadPips / len;
			avgSwap = sumSwap / len;
			avgVolatility = sumVolatility / len;
			avgVolume = sumVolume / len;
			avgMaxPossibleMinlots = sumMaxPossibleMinlots / len;
			
			for(int i=0;i<len;i++)
			{
				if((discoveryData[i].spread < avgSpreadPips) ||
				(((discoveryData[i].swapLong + discoveryData[i].swapShort)/2.0) < avgSwap) ||
				(discoveryData[i].volatility < avgVolatility) ||
				(discoveryData[i].volume < avgVolume) ||
				(discoveryData[i].maxPossibleMinlots < avgMaxPossibleMinlots))
				{
   					discoveryData[i].SystemPrintDiscoveryData("WorstThanAVG: ");
				}
			}
		}
		
		virtual void SystemDiscoveryPrintData()
		{
			int len = ArraySize(discoveryData);
			for(int i=0;i<len;i++)
   			discoveryData[i].SystemPrintDiscoveryData();
		}
		
		
		virtual void DiscoveryFillStringArray(string &array[], int digits = 8)
		{
			int len = ArraySize(discoveryData);
			ArrayResize(array, len);
			for(int i=0;i<len;i++)
   			discoveryData[i].FillStringWithDiscoveryData(array[i], digits);
		}
		
		virtual void SystemDiscoveryFillStringArray(string &array[])
		{
			int len = ArraySize(discoveryData);
			ArrayResize(array, len);
			for(int i=0;i<len;i++)
   			discoveryData[i].FillStringWithSystemDiscoveryData(array[i]);
		}
		
		virtual void UpdateChartTranDataLastDecisionInfo(string symbol, ChartTransactionData &currentChartTranData, double currentDecision, double currentLots, int timeShift, 
			double TP, double SL)
		{
			currentChartTranData.lastDecision = GetOrderTypeBasedOnDecision(currentDecision);
			currentChartTranData.lastDecisionLots = currentLots;
			currentChartTranData.LastDecisionBarDateTime = iTime(_Symbol, IntegerToTimeFrame(_Period), timeShift);
			currentChartTranData.LastDecisionBarShift = timeShift;
			currentChartTranData.lastDecisionTakeProfit = TP;
			currentChartTranData.lastDecisionStopLoss = SL;
		}
		
		virtual int OrdersCount()
		{
		   int orders = 0;
		   int len = ArraySize(transactions);
		   for(int i=0;i<len;i++)
            orders += transactions[i].GetOrdersCount();
         return orders;
		}
		
		virtual string GetLastSymbol()
		{
		   return ""; // Clean way to return the same without useless WebService call
		   
		   // Removing circular dependency that also doesn't work
		   /*
			XmlElement element;
			GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
			GlobalContext.DatabaseLog.CallWebServiceProcedure("ReadLastSymbol");
			element.ParseXml(GlobalContext.DatabaseLog.Result);
			
			TagType tagType = element.GetTagType();
			
			if (tagType == TagType_DataWithoutTag || tagType == TagType_CleanTag)
			{
			   Print(__FUNCSIG__ + " Invalid element received! TagType:" + EnumToString(tagType) + " element:" + element.ToString());
			   return "";
			}
			
			return element.GetChildByPosition(0).GetTagData();
			*/
		}
		
		virtual void FreeArrays() {
	      for(int i=0;i<ArraySize(lots);i++)
		      delete lots[i];
		   for(int i=0;i<ArraySize(decisions);i++)
		      delete decisions[i];
		   for(int i=0;i<ArraySize(transactions);i++)
		      delete transactions[i];
		   
		   CleanTranData();
			ArrayResize(decisions,0);
			ArrayResize(lots,0);
			ArrayResize(transactions,0);
		}
		
		virtual void Clean() { FreeArrays(); }
		
		virtual string ToString() {
			string retString = typename(this) + " { ";
			retString += "AllowedDecisionsConfig:" + EnumToString(AllowedDecisionsConfig) + " ";
			retString += "AllowedLotManagementConfig:" + EnumToString(AllowedLotManagementConfig) + " ";
			retString += "AllowedTransactionManagementConfig:" + EnumToString(AllowedTransactionManagementConfig) + " ";
			retString += "decisions:" + IntegerToString(ArraySize(decisions)) + " ";
			retString += "lot:" + IntegerToString(ArraySize(lots)) + " ";
			retString += "transactions:" + IntegerToString(ArraySize(transactions)) + " ";
			retString += "} ";
			return retString;
		}
};
