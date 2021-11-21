#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql\Global\Log\OfflineWebServiceLog.mqh>
#include <MyMql\Global\Log\OnlineWebServiceLog.mqh>

class WebServiceLog : public BaseWebServiceLog
{
	private:
		OfflineWebServiceLog *offLog;
		OnlineWebServiceLog *onLog;
		bool IsOnline;
		
	public:
		string Result;
		WebServiceLog() { Initialize(true, true); }
		WebServiceLog(bool isOnline, bool showerrors = true, bool rewrite = false, string file = NULL)
		{
			Initialize(isOnline, showerrors, rewrite, file);
			
			LogInfoMessage(" init: isOnline=" + BoolToString(isOnline) + " showerrors=" + BoolToString(showerrors) + " rewrite=" + BoolToString(rewrite) + " file=" + file);
		}
		
		void WebServiceLogDeinit()
		{
		   if (onLog != NULL)
			   delete onLog;
			if (offLog != NULL)
			   delete offLog;
		}
		
		void Initialize(bool isOnline, bool showerrors = false, bool rewrite = false, string file = NULL)
		{
		   WebServiceLogDeinit();
		   
		   onLog = new OnlineWebServiceLog(showerrors);
			
			if (file == NULL)
				offLog = new OfflineWebServiceLog("OfflineLogFile.txt", rewrite);
			else
				offLog = new OfflineWebServiceLog(file, rewrite);
			
			IsOnline = isOnline;
			Result = "";
		}
		
		bool CanLogOnline()
		{
			return IsOnline;
		}
		
		void LogOldOfflineData(string file = "")
		{
		   // TODO: C# read
		   
		   if(CheckPointer(onLog) == POINTER_INVALID)
		   {
		      LogInfoMessage(__FUNCSIG__ + " invalid pointer onLog");
		      return;
		   }
		   
			if(file == "")
				file = ConstOfflineFile;
			
			CFileTxt logFile;
			logFile.Open(file, FILE_READ | FILE_ANSI);
			
			string line = logFile.ReadString();
			StringReplace(line,"\n",""); // clean a little
			
			while(!logFile.IsEnding())
			{
				// save procedureName + get number of parameters in paramsLen
				string procedureName = line;
				int paramsLen = WebServiceProcedureGetParams(procedureName);
				if(paramsLen == -1)
				{
					////string message = __FUNCTION__ + " Ignoring invalid line (continue):" + procedureName + " in file " + __FILE__;
					////if(IsVerboseMode()) Print(message);
					////GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					////	GlobalContext.Config.GetSessionName(),
					////	message,
					////	TimeAsParameter());
					if(IsVerboseMode())
						Print("Ignoring invalid line (continue):" + procedureName);
					continue;
				}

				// read parameters if necessary
				string params[];
				if(paramsLen != 0)
				{
					line = logFile.ReadString();
					StringReplace(line, "\n", ""); // clean a little
					StringSplit(line, StringGetCharacter("&",0), params); // split

					if(paramsLen != ArraySize(params))
						Alert("Something went wrong: LogOldOfflineData " + procedureName + "\nline=" + line + "paramsLen=" + IntegerToString(paramsLen));
				}
				
				onLog.CallWebServiceProcedure(procedureName); // make the call
				//Result = onLog.GetResult(); // no idea if we need result
				
				line = logFile.ReadString();
				StringReplace(line,"\n",""); // clean a little
			}
			
			logFile.Flush();
			logFile.Close();
			
			// clean file
			logFile.Open(file, FILE_WRITE | FILE_ANSI | FILE_REWRITE);
			logFile.Flush();
			logFile.Close();
		}
		
		virtual void InternalCallWebServiceProcedure(string webServiceProcedure, string &params[])
		{
			if(IsOnline)
			{
			   if(CheckPointer(onLog) == POINTER_INVALID)
			   {
			      LogInfoMessage(__FUNCSIG__ + " invalid pointer onLog");
			      return;
			   }
				onLog.InternalCallWebServiceProcedure(webServiceProcedure, params);
				Result = onLog.GetResult();
			}
			else
			{
			   if(CheckPointer(offLog) == POINTER_INVALID)
			   {
			      LogInfoMessage(__FUNCSIG__ + " invalid pointer offLog");
			      return;
			   }
				offLog.InternalCallWebServiceProcedure(webServiceProcedure, params);
				Result = "";
			}
		}
		
		virtual void InternalCallBulkWebServiceProcedure(string webServiceProcedure, BulkWebServiceCall &bulkCallsArray[])
		{
			if (IsOnline)
			{
			   if(CheckPointer(onLog) == POINTER_INVALID)
			   {
			      LogInfoMessage(__FUNCSIG__ + " invalid pointer onLog");
			      return;
			   }
				onLog.InternalCallBulkWebServiceProcedure(webServiceProcedure, bulkCallsArray);
				Result = onLog.GetResult();
			}
			else
			{
			   if(CheckPointer(offLog) == POINTER_INVALID)
			   {
			      LogInfoMessage(__FUNCSIG__ + " invalid pointer offLog");
			      return;
			   }
				offLog.InternalCallBulkWebServiceProcedure(webServiceProcedure, bulkCallsArray);
				Result = "";
			}
		}
};
