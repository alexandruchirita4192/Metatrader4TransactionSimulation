#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict

#include <MyMql\Base\BaseObject.mqh>

struct WebServiceCallParameters
{
	public:
		string parameters[];
};

class BulkWebServiceCall {
	public:
		string ProcedureName;
		WebServiceCallParameters parameters[];
		
		BulkWebServiceCall() {}
		
		BulkWebServiceCall(BulkWebServiceCall &item)
		{
		   Copy(item);
		}
		
		BulkWebServiceCall(string procedureName) {
			ProcedureName = procedureName;
			ArrayResize(parameters, 0);
		}
		
		BulkWebServiceCall(string procedureName, string &params[]) {
			Initialize(procedureName, params);
		}
		
		void Initialize(string procedureName, string &params[]) {
			ProcedureName = procedureName;
			ArrayResize(parameters,1);
			ArrayCopy(parameters[0].parameters, params);
		}
		
		void Copy(BulkWebServiceCall &item)
		{
			ProcedureName = item.ProcedureName;
			
			//ArrayCopy(this.parameters, item.parameters);
			int len = ArraySize(item.parameters);
			ArrayResize(this.parameters, len);
			
			for(int i=0;i<len;i++)
            ArrayCopy(this.parameters[i].parameters, item.parameters[i].parameters);
		}
};

struct WebServiceProcedure
{
	public:
		string procedure;
		int numberOfParams;
		string operationParams[];
		string structName;
		bool isBulk;
		
		void SplitParameters(string params)
		{
			if((params == "") || (params == NULL) || (numberOfParams == 0))
				return;
			
			StringSplit(params, ';', operationParams);
			
			if(numberOfParams != ArraySize(operationParams))
				Print("operationParams parsed wrongly: ArraySize(operationParams)=" + IntegerToString(ArraySize(operationParams)) + " params=" + params);
		}
};


// WebService config log:
static WebServiceProcedure WSProcedures[];

// WebService Procedure Parameters:
static string WSPParameters[];

// Bulk WebService Procedure names & Parameters:
static BulkWebServiceCall WSPBulkCalls[];


class BaseLog : public BaseObject {
	public:
		// ParametersSet procedures
		void ParametersSet()
		{
			ArrayResize(WSPParameters, 0);
		}
		
		void ParametersSet(string parameter1)
		{
			ArrayResize(WSPParameters, 1);
			WSPParameters[0] = parameter1;
		}
		
		void ParametersSet(string parameter1, string parameter2)
		{
			ArrayResize(WSPParameters, 2);
			WSPParameters[0] = parameter1;
			WSPParameters[1] = parameter2;
		}
		
		void ParametersSet(string parameter1, string parameter2, string parameter3)
		{
			ArrayResize(WSPParameters, 3);
			WSPParameters[0] = parameter1;
			WSPParameters[1] = parameter2;
			WSPParameters[2] = parameter3;
		}
		
		void ParametersSet(string &params[])
		{
			ArrayCopy(WSPParameters, params);
		}
		
		
		void AddBulkParametersToArray(string procedureName, string &params[])
		{
			int lenBulkCalls = ArraySize(WSPBulkCalls);
			for(int j=0;j<lenBulkCalls;j++)
				if(WSPBulkCalls[j].ProcedureName == procedureName)
				{
					int lenBulkCallsParams = ArraySize(WSPBulkCalls[j].parameters);
					ArrayResize(WSPBulkCalls[j].parameters, lenBulkCallsParams+1);
					ArrayCopy(WSPBulkCalls[j].parameters[lenBulkCallsParams].parameters, params);
					return;
				}
			
			// if code gets here means procedure does not exist; add the first one
			ArrayResize(WSPBulkCalls, lenBulkCalls+1);
			WSPBulkCalls[lenBulkCalls].ProcedureName = procedureName;
			ArrayResize(WSPBulkCalls[lenBulkCalls].parameters, 1);
			ArrayCopy(WSPBulkCalls[lenBulkCalls].parameters[0].parameters, params);
		}
		
//		void MergeBulkArrays(BulkWebServiceCall &array[])
//		{
//			int lenNewArray = ArraySize(array);
//			int lenCurrentArray = ArraySize(bulkCalls);
//			
//			if(lenNewArray == 0) // nothing to do here
//				return;
//			
//			if(lenCurrentArray == 0)
//			{
//				ArrayCopy(bulkCalls, array);
//   			int len = ArraySize(array);
//   			ArrayResize(bulkCalls, len);
//   			for(int i=0;i<len;i++)
//               bulkCalls[i].Copy(array[i]);
//            
//				ArrayFree(array);
//				return;
//			}
//			
//			for(int i=0;i<lenCurrentArray;i++)
//				for(int j=0;j<lenNewArray;j++)
//					if(bulkCalls[i].ProcedureName == array[j].ProcedureName)
//					{
//						int lenCurrentParams = ArraySize(bulkCalls[i].parameters);
//						int lenNewParams = ArraySize(array[j].parameters);
//						ArrayResize(bulkCalls[i].parameters, lenCurrentParams + lenNewParams);
//						
//						for(int k=lenCurrentParams;k<lenCurrentParams + lenNewParams;k++)
//							ArrayCopy(bulkCalls[i].parameters[k].parameters,
//								array[j].parameters[k-lenCurrentParams].parameters);
//					}
//			ArrayFree(array);
//		}
		
		
		// BulkParametersSet procedures
		
		void BulkParametersSetFromParams(string procedureName)
		{
			BulkParametersSet(procedureName, WSPParameters);
		}
		
		virtual void BulkParametersSet(string procedureName, string &params[])
		{
			int len = ArraySize(WSProcedures);
			int lenParams = ArraySize(params);
			
			for(int i=0;i<len;i++)
				if((WSProcedures[i].isBulk) && (WSProcedures[i].procedure == procedureName))
				{
					if(lenParams == WSProcedures[i].numberOfParams)
					{
						AddBulkParametersToArray(procedureName, params);
					}
					else
					{
						string message = __FUNCTION__ + " numberOfParams is wrong for procedureName";
						Print(message);
						//GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
						//	GlobalContext.Config.GetSessionName(),
						//	message,
						//	TimeAsParameter());
						return;
					}
				}
			
			AddBulkParametersToArray(procedureName, params);
		}
		
		
		void BulkParametersSet(string procedureName)
		{
			BulkParametersSetFromParams(procedureName);
		}
		
		void BulkParametersSet(string procedureName, string parameter1)
		{
			string params[];
			ArrayResize(params, 1);
			params[0] = parameter1;
			
			BulkParametersSet(procedureName, params);
		}
		
		void BulkParametersSet(string procedureName, string parameter1, string parameter2)
		{
			string params[];
			ArrayResize(params, 2);
			params[0] = parameter1;
			params[1] = parameter2;
			
			BulkParametersSet(procedureName, params);
		}
		
		void BulkParametersSet(string procedureName, string parameter1, string parameter2, string parameter3)
		{
			string params[];
			ArrayResize(params, 3);
			params[0] = parameter1;
			params[1] = parameter2;
			params[2] = parameter3;
			
			BulkParametersSet(procedureName, params);
		}
};
