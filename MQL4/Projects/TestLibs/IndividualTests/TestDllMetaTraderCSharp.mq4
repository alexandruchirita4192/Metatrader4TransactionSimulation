//+------------------------------------------------------------------+
//|                                      TestDllMetaTraderCSharp.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


//#import "msvcrt.dll"
//  int memcpy(int &dst, int &src, int cnt);
//  int strcpy(uchar &dst[], int src);
//#import

//bool FileReadLineRef(char &fileName[], int lineNumber, char &line[]);
//void FileClear(string fileName);
#import "MetaTraderExtensionLibrary.dll"
//bool FileReadLineRef(string fileName, int lineNumber, string &line);
void Test(int);
#import

//string GetEnvValue(string env = "appdata")
//{
//	uchar appDataVarArray[], appDataResultArray[];
//	ArrayResize(appDataResultArray, 1024);
//	StringToCharArray("appdata", appDataVarArray);
//	GetRefValue(appDataResultArray, EnvVar(appDataVarArray));
//	return CharArrayToString(appDataResultArray);
//}

////string ReadLineFromConfig(string appDataDir = "", string file = "Config.txt", int lineNumber = 1)
////{
////	//if(appDataDir == "")
////	//	appDataDir = GetEnvValue("appdata");
////	
////	// Get %appdata% env variable:
////	uchar resultArray[], fileNameArray[];
////	//StringToCharArray(appDataDir + "\\MetaQuotes\\Terminal\\E5A4E68F1B7E15DF3B06ED6AF0EC4859\\MQL4\\Files\\" + file, fileNameArray);
////	StringToCharArray(file, fileNameArray);
////	ArrayResize(resultArray, 1024);
////	FileReadLineRef(fileNameArray, lineNumber, resultArray);
////	return CharArrayToString(resultArray);
////}


int OnInit()
{
	//char stringArray[];
	//StringToCharArray("asda", stringArray);
	//FileClear("asda.txt");
	
	string line;
	int i = 0;
	//FileReadLineRef("\\MetaQuotes\\Terminal\\E5A4E68F1B7E15DF3B06ED6AF0EC4859\\MQL4\\Files\\config.txt", 1, line);
	Test(i);
	Print(i);
//////	
//////	//Print(FileReadLine(fileName, 1));
//////	//string result;
//////	//FileReadLineRef(fileName, 1, result);
//////	//Print(result);
//////	
//////	
//////	//char fileNameChar[];
//////	//StringToCharArray(fileName,fileNameChar);
//////	//Print(FileReadLine(fileNameChar, 1));
//////	
//////	int lineNumber = 1;
//////	string appDataDir = "";
//////	//string appDataDir = GetEnvValue("appdata");
//////	//////string line = ReadLineFromConfig(appDataDir, "Config.txt", lineNumber);
//////	string line;
//////	FileReadLineRef("Config.txt", lineNumber, line);
//////	
//////	while(line != "")
//////	{
//////		Print(line);
//////		
//////		lineNumber ++;
//////		//////line = ReadLineFromConfig(appDataDir, "Config.txt", lineNumber);
//////		FileReadLineRef("Config.txt", lineNumber, line);
//////	}
//////	
	return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

}

void OnTick()
{

}
