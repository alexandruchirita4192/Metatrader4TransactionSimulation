#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql\DecisionMaking\DecisionIndicator.mqh>
#include <MyMql\Global\LimitData.mqh>
#include <MyMql\Global\Log\Xml\XmlElement.mqh>

const datetime MinDateTime = D'01.01.1970 00:00';


struct ChartTransactionData
{
	public:
		string TranSymbol;
		ENUM_TIMEFRAMES TimeFrame;
		
		string DecisionName, TransactionName, LotName;
		double lastDecisionLots, lastDecisionTakeProfit, lastDecisionStopLoss;
		int lastDecision;
		bool IsInverseDecision;
		datetime LastBarDateTime, LastDecisionBarDateTime;
		int LastDecisionBarShift;
		
		LimitData data; // TakeProfitPips, StopLossPips, IsIrregularDecision
		
		
		//ChartTransactionData()
		//{
		//	DecisionName = NULL; TransactionName = NULL;
		//	DecisionName = 0; LotName = 0; TransactionName = 0;
		//	lastDecision = OP_BUYLIMIT;
		//	IsInverseDecision = false;
		//}
		
		ChartTransactionData(XmlElement *element)
		{
		   data.SetEmpty();
		   
			this.FillDataFromXmlElement(element);
			
			LastBarDateTime = MinDateTime;
			lastDecision = OP_BUYLIMIT;
			IsInverseDecision = false;
			lastDecisionLots = InvalidValue;
			lastDecisionTakeProfit = InvalidValue;
			lastDecisionStopLoss = InvalidValue;
		}
		
		ChartTransactionData(const ChartTransactionData &chartTransactionData)
		{
			CopyTransactionData(chartTransactionData);
		}
		
		ChartTransactionData(string symbol, ENUM_TIMEFRAMES timeFrame, string decisionName, string lotName, string transactionName, bool isInverseDecision, double takeProfit, double stopLoss)
		{
			Initialize(symbol, timeFrame, decisionName, lotName, transactionName, isInverseDecision, takeProfit, stopLoss);
		}
		
		ChartTransactionData() {
			Initialize(NULL, PERIOD_CURRENT, NULL, NULL, NULL, false, 0.0, 0.0);
		}
		
		void Initialize(string symbol, ENUM_TIMEFRAMES timeFrame, string decisionName, string lotName, string transactionName, bool isInverseDecision, double takeProfit, double stopLoss)
		{
			TranSymbol = symbol;
			TimeFrame = timeFrame;
			DecisionName = decisionName;
			TransactionName = transactionName;
			LotName = lotName;
			
			data.SetEmpty();
			data.TakeProfit = takeProfit;
			data.StopLoss = stopLoss;
			
			LastBarDateTime = MinDateTime;
			LastDecisionBarDateTime = MinDateTime;
			LastDecisionBarShift = -1;
			lastDecision = OP_BUYLIMIT;
			IsInverseDecision = isInverseDecision;
			lastDecisionLots = InvalidValue;
			lastDecisionTakeProfit = InvalidValue;
			lastDecisionStopLoss = InvalidValue;
		}
		
		void SetEmpty()
		{
			TranSymbol = NULL;
			TimeFrame = PERIOD_CURRENT;
			DecisionName = NULL;
			TransactionName = NULL;
			LotName = NULL;
			
			data.SetEmpty();
			
			LastBarDateTime = MinDateTime;
			LastDecisionBarDateTime = MinDateTime;
			LastDecisionBarShift = -1;
			lastDecision = OP_BUYLIMIT;
			IsInverseDecision = false;
			lastDecisionLots = InvalidValue;
			lastDecisionTakeProfit = InvalidValue;
			lastDecisionStopLoss = InvalidValue;
		}
		
		void CopyTransactionData(const ChartTransactionData &chartTransactionData)
		{
			TranSymbol = chartTransactionData.TranSymbol;
			TimeFrame = chartTransactionData.TimeFrame;
			DecisionName = chartTransactionData.DecisionName;
			TransactionName = chartTransactionData.TransactionName;
			LotName = chartTransactionData.LotName;
			
			data.CopyData(chartTransactionData.data);
			
			LastBarDateTime = chartTransactionData.LastBarDateTime;
			LastDecisionBarDateTime = chartTransactionData.LastDecisionBarDateTime;
			LastDecisionBarShift = chartTransactionData.LastDecisionBarShift;
			lastDecision = chartTransactionData.lastDecision;
			IsInverseDecision = chartTransactionData.IsInverseDecision;
			lastDecisionLots = chartTransactionData.lastDecisionLots;
			lastDecisionTakeProfit = chartTransactionData.lastDecisionTakeProfit;
			lastDecisionStopLoss = chartTransactionData.lastDecisionStopLoss;
		}
		
		bool operator == (const ChartTransactionData &chartTranData)
		{
			return ((chartTranData.TranSymbol == TranSymbol) &&
				(chartTranData.TimeFrame == TimeFrame));
				//(chartTranData.DecisionName == DecisionName) &&
				//(chartTranData.LotName == LotName) &&
				//(chartTranData.IsInverseDecision == IsInverseDecision) &&
				//(chartTranData.TransactionName == TransactionName));
		}
		
		bool operator != (const ChartTransactionData &chartTranData)
		{
			return !(this == chartTranData);
		}
		
		
		void operator = (const ChartTransactionData &chartTranData)
		{
			CopyTransactionData(chartTranData);
		}
		
		void FillDataFromXmlElement(XmlElement *element /*, BaseDecision &decisionsVector[], BaseTransactionManagement &transactionsVector[] */ )
		{
			this.TranSymbol = element.GetChildTagDataByParentElementName("Symbol");
			this.DecisionName = element.GetChildTagDataByParentElementName("DecisionName");
			this.TransactionName = element.GetChildTagDataByParentElementName("TransactionName");
			this.LotName = element.GetChildTagDataByParentElementName("LotName");
			this.TimeFrame = StringToTimeFrame(element.GetChildTagDataByParentElementName("Period"));
			this.IsInverseDecision = StringToBool(element.GetChildTagDataByParentElementName("IsInverseDecision"));
			this.LastDecisionBarDateTime = StringToTime(element.GetChildTagDataByParentElementName("LastDecisionTime"));
			this.LastDecisionBarShift = (int)StringToInteger(element.GetChildTagDataByParentElementName("LastDecisionBar"));
			
			//this.OrderNo = (int)StringToInteger(element.GetChildTagDataByParentElementName("OrderNo"));
			//this.BarsPerOrders = (int)StringToInteger(element.GetChildTagDataByParentElementName("BarsPerOrders"));
			//this.NegativeOrdersCount = (int)StringToInteger(element.GetChildTagDataByParentElementName("NegativeOrdersCount"));
			//this.PositiveOrdersCount = (int)StringToInteger(element.GetChildTagDataByParentElementName("PositiveOrdersCount"));
			//this.SumClosedOrders = (int)StringToInteger(element.GetChildTagDataByParentElementName("SumClosedOrders"));
			//this.ProcentualProfitResult = StringToDouble(element.GetChildTagDataByParentElementName("ProcentualProfitResult"));
		}
};

