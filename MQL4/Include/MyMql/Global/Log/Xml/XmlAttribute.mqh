#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


enum XmlAttributeType
{
	XmlAttributeType_String = 0,
	XmlAttributeType_DateTime = 1,
	XmlAttributeType_Color = 2,
	XmlAttributeType_Double = 3,
	XmlAttributeType_Integer = 4 // long used instead
};

struct XmlAttribute
{
	private:
		// maybe unfinished, but works for now
		bool IsDateTime() { return TimeToString(StringToTime(value)) == value; }
		bool IsColor() { return ColorToString(StringToColor(value)) == value; }
		bool IsDouble() { double val = StringToDouble(value); return ((DoubleToString(val) == value) || (val != NormalizeDouble(val,0))); }
		bool IsInteger() { long val = StringToInteger(value); return ((IntegerToString(val) == value) || (((double)val) == StringToDouble(value))); } // StringToInteger returns long
		
		
	public:
		string name;
		string value;
		XmlAttributeType type;
		
		XmlAttribute(string attributeName = NULL, string attributeValue = NULL)
		{
			name = attributeName;
			value = attributeValue;
			DecodeValueType();
		}
		
		XmlAttribute(XmlAttribute &attr)
		{
			name = attr.name;
			value = attr.value;
			type = attr.type;
		}
		
		XmlAttributeType DecodeValueType()
		{
			type = XmlAttributeType_String; 
			if(IsDateTime())
				type = XmlAttributeType_DateTime;
			else if(IsColor())
				type = XmlAttributeType_Color;
			else if(IsDouble())
				type = XmlAttributeType_Double;
			else if(IsInteger())
				type = XmlAttributeType_Integer;
			return type;
		}
		
		datetime GetDateTimeValue() { return StringToTime(value); }
		color GetColorValue() { return StringToColor(value); }
		double GetDoubleValue() { return StringToDouble(value); }
		long GetIntegerValue() { return StringToInteger(value); }
		string GetStringValue() { return value; }
		void GetCharArrayValue(char &cArray[]) { StringToCharArray(value, cArray); } // just to have it, even if it's weird af
};
