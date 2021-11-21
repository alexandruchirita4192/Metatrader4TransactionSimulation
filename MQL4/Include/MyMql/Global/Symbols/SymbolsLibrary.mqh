#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql\Global\Symbols\BaseSymbol.mqh>
#include <MyMql\Global\Log\FileLog.mqh>

const string SymbolsStoreFileName = "SymbolsStore.dat";

class SymbolData
{
	public:
		string symbol;
		double close;
		double open;
		double high;
		double low;
};

class SymbolsLibrary : public BaseSymbol
{
	private:
		FileLog *file;
		SymbolData data[];
	      
		int GetPositionOfSymbol(string symbol = NULL)
		{
			if(symbol == NULL)
	      		symbol = _Symbol;
			
			for(int i=0;i<ArraySize(data);i++)
				if(data[i].symbol == symbol)
					return i;
					
			return -1;
		}
      
      
	public:
		SymbolsLibrary() : BaseSymbol()
		{
			file = new FileLog(SymbolsStoreFileName, false, false);
			ParseSymbolsAndLoadData();
			LoadLastSymbolDefinition();
		}
		
		~SymbolsLibrary()
		{
			delete file;
		}
		
		void SaveLastSymbolDefinition()
		{
			file.OpenLog(SymbolsStoreFileName);
			for(int i=0;i<ArraySize(data);i++)
			file.WriteLine(data[i].symbol + " " + DoubleToString(data[i].close) + " " + DoubleToString(data[i].open) + " " + DoubleToString(data[i].high) + " " + DoubleToString(data[i].low));
			file.CloseLog();
		}
		
		void LoadLastSymbolDefinition()
		{
			file.Open(SymbolsStoreFileName,FILE_READ);
			string line = file.ReadString();
			while(line != "")
			{
				string words[];
				int len = StringSplit(line, ' ', words);
				
				if(len != 5)
					break;
				
				AddOrUpdateSymbolData(words[0], StringToDouble(words[1]), StringToDouble(words[2]), StringToDouble(words[3]), StringToDouble(words[4]));
			}
			file.Close();
		}
		
		void AddOrUpdateSymbolData(string symbol, double close, double open, double high, double low)
		{
			int pos = GetPositionOfSymbol(symbol);
			
			if(pos == -1)
			{
				int len = ArraySize(data);
				ArrayResize(data,len+1);
				data[len].symbol = symbol;
				data[len].open = open;
				data[len].close = close;
				data[len].low = low;
			}
			else
			{
				if(open != 0.0)
					data[pos].open = open;
				
				if(close != 0.0)
					data[pos].close = close;
				
				if(high != 0.0)
					data[pos].high = high;
				
				if(low != 0.0)
					data[pos].low = low;
			}
		}
		
		bool SymbolDataExists(string symbol = NULL)
		{
			if(symbol == NULL)
				symbol = _Symbol;
			for(int i=0;i<ArraySize(data);i++)
				if(data[i].symbol == symbol)
					return true;
			return false;
		}
		
		void ParseSymbolsAndLoadData()
		{
			for(int i=0;i<SymbolsTotal(false);i++)
			{
				string symbol = SymbolName(i, false);
				AddOrUpdateSymbolData(symbol, iClose(symbol,0,0), iOpen(symbol,0,0), iHigh(symbol,0,0), iLow(symbol,0,0));
			}
		}
		
		int NumberOfSymbolsInLibrary()
		{
			return ArraySize(data);
		}
		
		double High(string symbol = NULL)
		{
			ParseSymbolsAndLoadData(); // update data
			int pos = GetPositionOfSymbol(symbol);
			if(pos != -1)
				return data[pos].high;
			return 0.0;
		}   
		
		double Low(string symbol = NULL)
		{
			ParseSymbolsAndLoadData(); // update data
			int pos = GetPositionOfSymbol(symbol);
			if(pos != -1)
				return data[pos].low;
			return 0.0;
		}
		
		double Open(string symbol = NULL)
		{
			ParseSymbolsAndLoadData(); // update data
			int pos = GetPositionOfSymbol(symbol);
			if(pos != -1)
				return data[pos].open;
			return 0.0;
		}
		
		double Close(string symbol = NULL)
		{
			ParseSymbolsAndLoadData(); // update data
			int pos = GetPositionOfSymbol(symbol);
			if(pos != -1)
				return data[pos].close;
			return 0.0;
		}
		
		bool IsTradeAllowedOnSymbol(string symbol = NULL)
		{
			if(symbol == NULL)
				symbol = _Symbol;
			return IsTradeAllowed(symbol, 0);
		}
};
