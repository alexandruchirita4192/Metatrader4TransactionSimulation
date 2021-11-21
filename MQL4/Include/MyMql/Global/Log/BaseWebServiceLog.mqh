#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/Base/BaseObject.mqh>
#include <MyMql/Base/BaseLog.mqh>

static bool loadedWSProcedures = false;
    
class BaseWebServiceLog : public BaseLog
{
	public:
		BaseWebServiceLog()
		{
			// parse urls (only once)
			if (!loadedWSProcedures)
			{
   			int reserveLength = ParseURLs(GlobalContext.Config.GetValue("WebServiceURLs"));
   			ParseBulkURLs(GlobalContext.Config.GetValue("BulkWebServiceURLs"), reserveLength);
   			LogWSProcedures(__FUNCTION__);
   			loadedWSProcedures = true;
   		}
		}
		
		void LogWSProcedures(string context)
		{
		   //LogInfoMessage(context + " WSProcedures size: " + IntegerToString(ArraySize(WSProcedures)));
		   //for(int i=0;i<ArraySize(WSProcedures);i++)
		   //   LogInfoMessage(context + " WSProcedures[" + IntegerToString(i) + "]=" + WSProcedures[i].structName + " " + WSProcedures[i].procedure + " Size(operationParams)=" + IntegerToString(ArraySize(WSProcedures[i].operationParams)));
		}
		
		string GetBaseWebServiceURL()
		{
		   string baseWebServiceURL = GlobalContext.Config.GetValue("BaseWebServiceURL");
		   
			if (StringIsNullOrEmpty(baseWebServiceURL))
				Print("BaseWebServiceURL not configured! WebService Log won't work!! in file " + __FILE__ + " at line " + IntegerToString(__LINE__));
		   
		   return baseWebServiceURL;
	   }
		
		virtual bool WebServiceProcedureExists(string procedure, int params, bool isBulk = false)
		{
   		//LogWSProcedures(__FUNCTION__ + "[" + procedure + "," + IntegerToString(params) + "," + BoolToString(isBulk) + "]");
   		
			for(int i = 0; i < ArraySize(WSProcedures); i++ )
				if ((WSProcedures[i].procedure == procedure) && (WSProcedures[i].isBulk == isBulk))
				{
					if (params == WSProcedures[i].numberOfParams)
						return true;

					if (WSProcedures[i].numberOfParams != params)
						SafePrintString(__FUNCTION__ + ": \"numberOfParams\" of " + procedure + " different than \"params\"! numberOfParams:" + IntegerToString(WSProcedures[i].numberOfParams) + " params:" + IntegerToString(params), true);

					return false;
				}
            //else
            //   LogInfoMessage("WebServiceProcedureExists: " + procedure + " != " + WSProcedures[i].procedure + " or (isBulk)" + BoolToString(isBulk) + " != " + BoolToString(WSProcedures[i].isBulk));
               
			return false;
		}

		virtual int WebServiceProcedureGetParams(string procedure)
		{
			for(int i = 0; i < ArraySize(WSProcedures); i++)
				if(WSProcedures[i].procedure == procedure)
					return WSProcedures[i].numberOfParams;
			return -1;
		}
		
		virtual string WebServiceProcedureGetParamName(string procedure, int position)
		{
			for(int i = 0; i < ArraySize(WSProcedures); i++)
				if((WSProcedures[i].procedure == procedure) && (position < ArraySize(WSProcedures[i].operationParams)))
					return WSProcedures[i].operationParams[position];
			return NULL;
		}
		
		virtual void FillCommandsArray(string &commands[])
		{
			int currentLen = ArraySize(commands);
			int lenProcedures = ArraySize(WSProcedures);
			ArrayResize(commands, currentLen + lenProcedures);
			
			for( int i = currentLen; i < currentLen + lenProcedures; i++ )
				commands[i] = WSProcedures[i-currentLen].procedure;
		}
		
		virtual void PrintWebServiceUrls()
		{
			for( int i = 0; i < ArraySize(WSProcedures); i++ )
				Print("url:" + WSProcedures[i].procedure + " numberOfParams:" + IntegerToString(WSProcedures[i].numberOfParams));
		}

		virtual void InternalCallWebServiceProcedure(string webServiceProcedure, string &params[]) {}

		virtual void CallWebServiceProcedure(string webServiceProcedure)
		{
   		LogWSProcedures(__FUNCTION__ + "[" + webServiceProcedure + "]");
			int parametersLen = ArraySize(WSPParameters);	
			if (!WebServiceProcedureExists(webServiceProcedure, parametersLen, false))
			{
			   SafePrintString(__FUNCSIG__ + " Web service procedure does not exist! webServiceProcedure: " + webServiceProcedure + " parameters:" + IntegerToString(parametersLen), true);
				return;
			}
			
			InternalCallWebServiceProcedure(webServiceProcedure, WSPParameters);
		}
		
		virtual void InternalCallBulkWebServiceProcedure(string webServiceProcedure, BulkWebServiceCall &bulkCallsArray[]) {}
		
		virtual void CallBulkWebServiceProcedure(string webServiceProcedure, bool callNow = false, bool ignoreWSPparameters = true)
		{
   		//LogWSProcedures(__FUNCTION__ + "[" + webServiceProcedure + "," + BoolToString(callNow) + "]");
   		
   		if (!ignoreWSPparameters)
   		{
   			int parametersLen = ArraySize(WSPParameters);	
   			if (!WebServiceProcedureExists(webServiceProcedure, parametersLen, true))
   			{
   			   SafePrintString(__FUNCSIG__ + " Bulk web service procedure does not exist! webServiceProcedure: " + webServiceProcedure + " parameters:" + IntegerToString(parametersLen), true);
   			}
   			else
   			{
   				bool foundProcedure = false;
   				int len = ArraySize(WSPBulkCalls);
   				for(int i=0;i<len;i++)
   					if(WSPBulkCalls[i].ProcedureName == webServiceProcedure)
   					{
   						foundProcedure = true;
   						int lenParams = ArraySize(WSPBulkCalls[i].parameters);
   						
   						ArrayResize(WSPBulkCalls[i].parameters, lenParams+1);
   						ArrayCopy(WSPBulkCalls[i].parameters[lenParams].parameters, WSPParameters);
   					}
   				
   				if(!foundProcedure)
   				{
   					ArrayResize(WSPBulkCalls, len+1);
   					WSPBulkCalls[len].Initialize(webServiceProcedure, WSPParameters);
   				}
   			}
			}
			
			if (callNow)
			{
				int len = ArraySize(WSPBulkCalls);
				InternalCallBulkWebServiceProcedure(webServiceProcedure, WSPBulkCalls);
				
				for(int i=0;i<len;i++)
					ArrayFree(WSPBulkCalls[i].parameters);
				ArrayFree(WSPBulkCalls);
			}
		}
		
		virtual int ParseURLs(string urls, int reserveLength = 0)
		{
		   //LogInfoMessage("ParseURLs call: " + urls);
		   
			if (StringIsNullOrEmpty(urls))
			{
				string message = __FUNCTION__ + " Invalid config. WebServiceURLs cannot be parsed correctly [1]; StringIsNullOrEmpty(urls) = true";
				SafePrintString(message, true);
				//GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
				//	GlobalContext.Config.GetSessionName(),
				//	message,
				//	TimeAsParameter());
				return 0;
			}

			string internalURLs[];
			StringReplace(urls, " ", "");
			StringSplit(urls, ',', internalURLs);
			
			int len = ArraySize(internalURLs);
			int newLen = len + reserveLength;
			
			ArrayResize(WSProcedures, newLen);

			for(int i=0; i<len; i++)
			{
				string words[];
				StringSplit(internalURLs[i], '/', words);

				if (ArraySize(words) != 3)
				{
					SafePrintString("Invalid config. WebServiceURLs cannot be parsed correctly [2]; ArraySize(words)=" + IntegerToString(ArraySize(words)) + "; internalURLs[i]= " + internalURLs[i], true);
					continue;
				}

				int secondWordLen = StringLen(words[1]);
				if((secondWordLen != 1) && (IsVerboseMode()))
					SafePrintString("Warning: words[1] length is different than 1 (len=" + IntegerToString(secondWordLen) + "); words[1]=" + words[1] + " internalURLs[i]=" + internalURLs[i], true);

				WSProcedures[i + reserveLength].procedure = words[0];
				WSProcedures[i + reserveLength].isBulk = false;
				WSProcedures[i + reserveLength].structName = NULL;
				WSProcedures[i + reserveLength].numberOfParams = (int)StringToInteger(words[1]);
				WSProcedures[i + reserveLength].SplitParameters(words[2]);
			}
			
			return len;
		}
		
		virtual int ParseBulkURLs(string urls, int reserveLength = 0)
		{
		   //LogInfoMessage("ParseBulkURLs call: " + urls);
		   
			if (StringIsNullOrEmpty(urls))
			{
				SafePrintString("Invalid config. BulkWebServiceURLs cannot be parsed correctly [3]; StringIsNullOrEmpty(urls) = true", true);
				return 0;
			}

			string internalURLs[];
			StringReplace(urls, " ", "");
			StringSplit(urls, ',', internalURLs);
			
			// keep URLs from ParseURLs
			int len = ArraySize(internalURLs);
			int newLen = len + reserveLength;
			
			ArrayResize(WSProcedures, newLen);

			for(int i=0; i<len; i++)
			{
				string words[];
				StringSplit(internalURLs[i], '/', words);

				if(ArraySize(words) != 4)
				{
					SafePrintString("Invalid config. BulkWebServiceURLs cannot be parsed correctly [4]; internalURLs[i]=" + internalURLs[i], true);
					continue;
				}

				int secondWordLen = StringLen(words[1]);
				if((secondWordLen != 1) && (IsVerboseMode()))
					SafePrintString("Warning: words[1] length is different than 1 (len=" + IntegerToString(secondWordLen) + "); words[1]=" + words[1] + " internalURLs[i]=" + internalURLs[i], true);

				WSProcedures[i + reserveLength].procedure = words[0];
				WSProcedures[i + reserveLength].isBulk = true;
				WSProcedures[i + reserveLength].structName = words[1];
				WSProcedures[i + reserveLength].numberOfParams = (int)StringToInteger(words[2]);
				WSProcedures[i + reserveLength].SplitParameters(words[3]);
			}
			
			return len;
		}
		
		virtual string InternalGetSoapRequest(string procedureName, WebServiceCallParameters &params[])
		{
			string soapRequest =
				"<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n" +
				"<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\r\n" +
				"  <soap12:Body>\r\n" +
				"    <" + procedureName + " xmlns=\"http://tempuri.org/\">\r\n" +
				"      <list>\r\n";
			
			bool ok = false;
			int len = ArraySize(WSProcedures);
			for(int i=0;i<len;i++)
				if(WSProcedures[i].procedure == procedureName) // initially was used only in bulk requests
				{
					ok = true;
					
					int lenParams = ArraySize(params);
					for(int j=0;j<lenParams;j++)
					{
						int lenParameters = ArraySize(params[j].parameters);
						if(lenParameters == WSProcedures[i].numberOfParams)
						{
						   string tagName = NULL;
						   
						   if (WSProcedures[i].isBulk && (!StringIsNullOrEmpty(WSProcedures[i].structName)))
                        tagName = WSProcedures[i].structName;
						   else
						      tagName = procedureName;
						   
							soapRequest += "<" + tagName + ">\r\n";
							for(int k=0;k<lenParameters;k++)
							{
								soapRequest +=
									"<" + WSProcedures[i].operationParams[k] + ">" +
										EscapeString(params[j].parameters[k]) +
									"</" + WSProcedures[i].operationParams[k] + ">\r\n";
							}
							soapRequest += "</" + tagName + ">\r\n";
						}
						else
							SafePrintString("Error in " + __FUNCTION__ + " " + procedureName + ": wrong number of parameters", true);
					}
					
					break;
				}
			
			soapRequest +=
				"      </list>\r\n" +
				"    </" + procedureName + ">\r\n" +
				"  </soap12:Body>\r\n" +
				"</soap12:Envelope>";
			
			if(ok)
				return soapRequest;
			else
				return "";
		}
		
		// subject to change - using way too many characters to escape 1 char ("<" becomes "-*-lt;")
		virtual string EscapeString(string text)
		{
			int repl = StringReplace(text, "<", "&lt;"); //PrintLastError
			repl = StringReplace(text, ">", "&gt;"); //PrintLastError
			repl = StringReplace(text, "&", "-*-."); //PrintLastError
			repl = StringReplace(text, "=", "-_-."); //PrintLastError
			return text;
		}
		
		virtual string UnEscapeString(string text)
		{
			//int repl = StringReplace(text, "\0", ""); //PrintLastError
			int repl = StringReplace(text, "-*-.", "&"); //PrintLastError
			repl = StringReplace(text, "-_-.", "="); //PrintLastError
			repl = StringReplace(text, "&lt;", "<"); //PrintLastError
			repl = StringReplace(text, "&gt;", ">"); //PrintLastError
			return text;
		}
};
