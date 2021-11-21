#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql\Global\Log\BaseWebServiceLog.mqh>

// file to store offline webService logs
const string ConstOfflineFile = "OfflineLogFile.txt";

class OfflineWebServiceLog : public BaseWebServiceLog 
{
	private:
	   string offlineFileName;
		string Separator;
		
		void Initialize(string fileName, bool rewrite)
		{
		   offlineFileName = fileName;
		   if (rewrite)
		      CleanFile(offlineFileName);
		   SetSeparator();
		}
		
	public:
		OfflineWebServiceLog(bool rewrite = false) { Initialize(ConstOfflineFile, rewrite); }
		OfflineWebServiceLog(string file, bool rewrite = false) {Initialize(file, rewrite); }
		
		virtual void SetSeparator(string separator = ";")
		{
			Separator = separator;
		}
		
		virtual string CleanString(string text)
		{
			string ret = text;
			StringReplace(ret, "\n", Separator);
			return ret;
		}
		
		virtual void InternalCallBulkWebServiceProcedure(string webServiceProcedure, BulkWebServiceCall &bulkCallsArray[])
		{
//			//to do: save requests as individual requests
//			int len = ArraySize(bulkCallsArray);
//			for(int i=0;i<len;i++)
//			{
//				
//			}

			SafePrintString("OfflineWebServiceLog.InternalCallBulkWebServiceProcedure not implemented. Nothing will be logged here");
		}
		
		virtual void InternalCallWebServiceProcedure(string webServiceProcedure, string &params[])
		{
			AppendLine(offlineFileName, GetBaseWebServiceURL() + "/" + webServiceProcedure);

			int parametersLen = ArraySize(params);
			if(parametersLen != 0)
			{
				string paramsString = "";
				for(int i = 0; i < ArraySize(params); i++)
					if(i == 0)
						paramsString += "param" + IntegerToString(i+1) + "=" + EscapeString(CleanString(params[i]));
					else
						paramsString += "&param" + IntegerToString(i+1) + "=" + EscapeString(CleanString(params[i]));
				AppendLine(offlineFileName, paramsString);
			}
		}
};
