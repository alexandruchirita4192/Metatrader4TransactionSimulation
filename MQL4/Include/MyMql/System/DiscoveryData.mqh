#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/Base/BeforeObject.mqh>

class DiscoveryData
{
	public:
		string symbol;
		double spread;
		double volatility;
		double maxPossibleMinlots;
		double volume;
		double swapLong, swapShort;
		
		DiscoveryData(const DiscoveryData &discoveryData)
		{
			CopyDiscoveryData(discoveryData);
		}
		
		DiscoveryData(string _symbol, double _spread, double _volatility, double _maxPossibleMinlots, double _volume, double _swapLong, double _swapShort)
		{
			Initialize(_symbol, _spread, _volatility, _maxPossibleMinlots, _volume, _swapLong, _swapShort);
		}
		
		DiscoveryData()
		{
			Initialize(NULL, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
		}
		
		void Initialize(string _symbol, double _spread, double _volatility, double _maxPossibleMinlots, double _volume, double _swapLong, double _swapShort)
		{
			symbol = _symbol;
			spread = _spread;
			volatility = _volatility;
			maxPossibleMinlots = _maxPossibleMinlots;
			volume = _volume;
			swapLong = _swapLong;
			swapShort = _swapShort;
		}
		
		void CopyDiscoveryData(const DiscoveryData &discoveryData)
		{
			Initialize(discoveryData.symbol, discoveryData.spread, discoveryData.volatility, discoveryData.maxPossibleMinlots,
			   discoveryData.volume, discoveryData.swapLong, discoveryData.swapShort);
		}
		
		void operator = (const DiscoveryData &discoveryData)
		{
			CopyDiscoveryData(discoveryData);
		}
		
		void PrintDiscoveryData(int digits = 8)
		{
		   SafePrintString("Symbol: \"" + symbol + "\" spread: " + DoubleToString(spread, digits) + 
		      " volatility: " + DoubleToString(volatility, digits) + 
		      " maxMinLots: " + DoubleToString(maxPossibleMinlots, digits) +
		      " volume: " + DoubleToString(maxPossibleMinlots, digits) +
		      " swapLong: " + DoubleToString(swapLong, digits) +
		      " swapShort: " + DoubleToString(swapShort, digits), true);
		}
		
		void SystemPrintDiscoveryData(string prefix = NULL)
		{
			if(prefix == NULL)
				prefix = "";

			SafePrintString(prefix + symbol +
				" spread=" + DoubleToString(spread,4) +
				" swapLong=" + DoubleToString(swapLong,2) +
				" swapShort=" + DoubleToString(swapShort,2) +
				" volatility=" + DoubleToString(volatility,2) +
				" volume=" + DoubleToString(volume,2) +
				" maxPossibleMinlots=" + DoubleToString(maxPossibleMinlots,0), true);
		}
		
		void FillStringWithDiscoveryData(string s, int digits = 8)
		{
			s = "Symbol: \"" + symbol + "\" spread: " + DoubleToString(spread, digits) + 
		      " volatility: " + DoubleToString(volatility, digits) + 
		      " maxMinLots: " + DoubleToString(maxPossibleMinlots, digits) +
		      " volume: " + DoubleToString(maxPossibleMinlots, digits) +
		      " swapLong: " + DoubleToString(swapLong, digits) +
		      " swapShort: " + DoubleToString(swapShort, digits);
		}
		
		void FillStringWithSystemDiscoveryData(string s)
		{
			s = symbol +
				" spread=" + DoubleToString(spread,4) +
				" swapLong=" + DoubleToString(swapLong,2) +
				" swapShort=" + DoubleToString(swapShort,2) +
				" volatility=" + DoubleToString(volatility,2) +
				" volume=" + DoubleToString(volume,2) +
				" maxPossibleMinlots=" + DoubleToString(maxPossibleMinlots,0);
		}
};

