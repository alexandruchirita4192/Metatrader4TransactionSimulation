#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql\Global\Log\BaseWebServiceLog.mqh>

class OnlineWebServiceLog : public BaseWebServiceLog
{
	private:
		bool showErrors;
		char internalResult[];
		char post[];
		string Result;
		
		void MakePostRequest(string url, char &result[], char &postArray[], int postSize = -1)
		{
			if(postSize < 0)
				postSize = ArraySize(postArray);
			string headers = NULL; //"Host: localhost\nContent-Type: application/x-www-form-urlencoded\n";
			int timeout = 5000;
			AlertInCaseOfError(WebRequest("POST", url, NULL, headers, timeout, postArray, postSize, result, headers), url, postArray, result, headers, timeout);
		}
		
		void MakeIndividualSoapPostRequest(string url, string &headers, char &soapRequest[], char &soapResponse[], int postSize = -1)
		{
			if(postSize < 0)
				postSize = ArraySize(soapRequest);
			headers = "Accept: application/soap+xml\r\nContent-Type: application/soap+xml\r\n\r\n";
			
			if(soapRequest[postSize-1] == 0)
			{
				ArrayResize(soapRequest, postSize-1);
				postSize--;
			}
			
			int timeout = 1000;
			AlertInCaseOfError(WebRequest("POST", url, headers, timeout, soapRequest, soapResponse, headers), url, soapRequest, soapResponse, headers, timeout);
		}
		
		void AlertInCaseOfError(int responseCode, string url, char &soapRequest[], char &soapResponse[], string headers = NULL, int timeout = 0)
		{
		   if (responseCode != 200) // 200 = OK; log only errors
		   {
		      LogInfoMessage("WebRequest made. Url: " + url + " Headers: " + headers + " ResponseCode: " + IntegerToString(responseCode) + " Timeout: " + IntegerToString(timeout));
		      LogInfoMessage("SoapRequest: " + CharArrayToString(soapRequest));
		      LogInfoMessage("SoapResponse: " + CharArrayToString(soapResponse));
		   }
		   
			if((responseCode == -1) && (showErrors))
			{
				if(!StringIsNullOrEmpty(headers))
					SafePrintString("Headers received: " + headers, true);
				SafePrintString("Error in WebRequest. Error code  =" +  IntegerToString(_LastError) + " (" + ErrorDescription(_LastError) + ")", true);
				SafePrintString("Check the address '" + url + "' in the list of allowed URLs on tab 'Expert Advisors'", true);
			}
			ResetLastError();
		}
		
		void CleanInternalData()
		{
			ArrayFree(internalResult); ArrayFree(post); ResetLastError();
		}
		
		string ReturnResult(const char &result[])
		{
			string retString = CharArrayToString(result);
			StringReplace(retString, "&#x0;", ""); // replace HTML encoded NULL
			this.UnEscapeString(retString);
			return retString;
		}
		
	public:
		OnlineWebServiceLog(bool showerrors = false)
		{
			this.showErrors = showerrors;
		}
		
		virtual string GetResult() {
			CleanInternalData();
			return this.UnEscapeString(Result);
		}
		
		virtual void InternalCallWebServiceProcedure(string webServiceProcedure, string &params[])
		{
		   //LogInfoMessage(__FUNCSIG__ + "[" + webServiceProcedure + "]: Size(params)=" + IntegerToString(ArraySize(params)));
			CleanInternalData();
			
//			int parametersLen = ArraySize(params);
//			if(parametersLen != 0)
//			{
//				string paramsString = "";
//				for(int i = 0; i < ArraySize(params); i++)
//					if(i == 0)
//						paramsString = WebServiceProcedureGetParamName(webServiceProcedure, i) + "=" + EscapeString(params[i]);
//					else
//						paramsString += "&" + WebServiceProcedureGetParamName(webServiceProcedure, i) + "=" + EscapeString(params[i]);
//				
//				StringToCharArray(paramsString, post);
//				if((ArraySize(post) > 0) && (post[ArraySize(post)-1] == 0))
//					ArrayResize(post, ArraySize(post)-1); // remove NULL
//			}

         // prepare call parameters
         WebServiceCallParameters callParams[];
         ArrayResize(callParams, 1);
         ArrayCopy(callParams[0].parameters, params);
         
			string url = GetBaseWebServiceURL(); // + "/" + webServiceProcedure;
			
			string soapRequest = MakeSoapRequest(webServiceProcedure, callParams);
			char soapRequestChar[];
			StringToCharArray(soapRequest, soapRequestChar);
					
			//MakePostRequest(url, internalResult, post, 0);

			string headers;
			MakeIndividualSoapPostRequest(url, headers, soapRequestChar, internalResult, -1);
			
			Result = ReturnResult(internalResult);
			//LogInfoMessage("Result=" + Result);
			CleanInternalData();
		}
		
		virtual string MakeSoapRequest(string procedureName, WebServiceCallParameters &params[])
		{
			// to do: complete this
			return InternalGetSoapRequest(procedureName, params);
		}
		
		virtual void InternalCallBulkWebServiceProcedure(string webServiceProcedure, BulkWebServiceCall &bulkCallsArray[])
		{
			string url = GetBaseWebServiceURL();
			int len = ArraySize(bulkCallsArray);
			
			for(int i=0;i<len;i++)
				if((StringIsNullOrEmpty(webServiceProcedure)) || (webServiceProcedure == bulkCallsArray[i].ProcedureName))
				{
					string procedureName = bulkCallsArray[i].ProcedureName;
					int lenParams = ArraySize(bulkCallsArray[i].parameters);
					
					CleanInternalData();
					string soapRequest = MakeSoapRequest(procedureName, bulkCallsArray[i].parameters);
					char soapRequestChar[];
					StringToCharArray(soapRequest, soapRequestChar);
					
					string headers;
					MakeIndividualSoapPostRequest(url, headers, soapRequestChar, internalResult, -1);
					
      			Result = ReturnResult(internalResult);
      			//LogInfoMessage("Result=" + Result);
      			CleanInternalData();
				}
		}
};
