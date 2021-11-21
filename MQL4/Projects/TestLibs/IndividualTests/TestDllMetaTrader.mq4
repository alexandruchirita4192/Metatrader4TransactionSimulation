//+------------------------------------------------------------------+
//|                                            TestDllMetaTrader.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#import "msvcrt.dll"
  int memcpy(int &dst, int &src, int cnt);
  int strcpy(uchar &dst[], int src);
#import

#import "MetaTraderExtensionLibrary.dll"

/// 1. PrefixDLL char* DLL FileReadLine(char* fileName, int lineNumber)
/// 2. [DllExport("FileReadLine", CallingConvention = CallingConvention.StdCall)]
///    public static string FileReadLine([MarshalAs(UnmanagedType.LPArray)] string fileName, int lineNumber)
//string FileReadLine(string fileName, int lineNumber);
//string FileReadLine(char  &fileName[], int lineNumber);
int FileReadLine(char  &fileName[], int lineNumber);
int EnvVar(uchar &var[]);
void FreePointer(int ptr);
void GetRefValue(uchar &var[], int pointer);

/// 1. PrefixDLL void DLL FileReadLineRef(char* fileName, int lineNumber, char* lineRef)
/// 2. [DllExport("FileReadLineRef", CallingConvention = CallingConvention.StdCall)]
///    public static bool FileReadLineRef([MarshalAs(UnmanagedType.LPWStr)] string fileName, int lineNumber, [In, Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder line)
//void FileReadLineRef(char &fileName[], int lineNumber, char &lineRef[]);
void FileReadLineRef(uchar &fileName[], int lineNumber, uchar &lineRef[]);
//bool FileReadLineRef(string fileName, int lineNumber, string lineRef);

#import

string GetEnvValue(string env = "appdata")
{
	uchar appDataVarArray[], appDataResultArray[];
	ArrayResize(appDataResultArray, 1024);
	StringToCharArray("appdata", appDataVarArray);
	GetRefValue(appDataResultArray, EnvVar(appDataVarArray));
	return CharArrayToString(appDataResultArray);
}

string ReadLineFromConfig(string appDataDir = "", string file = "Config.txt", int lineNumber = 1)
{
	if(appDataDir == "")
		appDataDir = GetEnvValue("appdata");
	
	// Get %appdata% env variable:
	uchar resultArray[], fileNameArray[];
	StringToCharArray(appDataDir + "\\MetaQuotes\\Terminal\\E5A4E68F1B7E15DF3B06ED6AF0EC4859\\MQL4\\Files\\" + file, fileNameArray);
	ArrayResize(resultArray, 1024);
	FileReadLineRef(fileNameArray, lineNumber, resultArray);
	return CharArrayToString(resultArray);
}


int OnInit()
{
	
	
	//Print(FileReadLine(fileName, 1));
	//string result;
	//FileReadLineRef(fileName, 1, result);
	//Print(result);
	
	
	//char fileNameChar[];
	//StringToCharArray(fileName,fileNameChar);
	//Print(FileReadLine(fileNameChar, 1));
	
	int lineNumber = 1;
	string appDataDir = GetEnvValue("appdata");
	string line = ReadLineFromConfig(appDataDir, "Config.txt", lineNumber);
	
	while(line != "")
	{
		Print(line);
		
		lineNumber ++;
		line = ReadLineFromConfig(appDataDir, "Config.txt", lineNumber);
	}
	
	return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

}

void OnTick()
{

}
