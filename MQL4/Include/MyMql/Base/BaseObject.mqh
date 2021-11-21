#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#define DEBUG false
#define VERBOSE false
#define VERBOSE_LEVEL 1

#include <MyMql\Base\BeforeObject.mqh>
#include <Object.mqh>

class BaseObject : public CObject
{
	private:
		//bool TracingProcedureStart;
		//string TracingProcedureName;
		
	public:
		BaseObject() { }
		
//		void TraceProcedure(string procedureName = "");

		virtual bool IsVerboseMode();
		virtual bool IsDebugMode();
		
		virtual int GetVerboseLevel();
		
		virtual string ToString();
		virtual void PrintThis();
		
		virtual string Type();
};
		
//void BaseObject::TraceProcedure(string procedureName = "")
//{
//	if((StringIsNullOrEmpty(procedureName)) && (StringIsNullOrEmpty(TracingProcedureName)))
//		return;
//	if(!StringIsNullOrEmpty(procedureName))
//		this.TracingProcedureName = procedureName;
//	
//	if(this.TracingProcedureStart)
//	{
//		Print(" > " + this.TracingProcedureName + " entered");
//		this.TracingProcedureStart = false;
//	} else {
//		Print(" > " + this.TracingProcedureName + " exited");
//		this.TracingProcedureStart = true;
//		this.TracingProcedureName = "";
//	}
//}

bool BaseObject::IsVerboseMode() { return VERBOSE; }
bool BaseObject::IsDebugMode() { return DEBUG; }

int BaseObject::GetVerboseLevel()
{
	return VERBOSE_LEVEL;
}


string BaseObject::ToString()
{
	return typename(this) + " { } ";
}

void BaseObject::PrintThis()
{
	SafePrintString(ToString());
}

string BaseObject::Type()
{
	return typename(this);
}


#include <MyMql\Base\BaseLog.mqh>

