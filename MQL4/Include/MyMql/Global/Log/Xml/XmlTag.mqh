#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql\Base\BaseObject.mqh>
#include <MyMql\Global\Log\Xml\XmlAttribute.mqh>

enum TagType
{
	TagType_InvalidTag = -1, 
	TagType_CleanTag = 0,// a little rare invalid tag (which looks like a tag, but isn't)
	TagType_FullTag = 1,
	TagType_OpenTag = 2,
	TagType_CloseTag = 3,
	TagType_DataWithoutTag = 4, // might as well be an invalid tag; who knows? no way to test that easily, though
	TagType_IgnoredTag = 5
};

string GetXmlTimeFormat(datetime d = 0)
{
	if(d == 0)
		d = TimeCurrent();
	
	string timeFormat = TimeToString(d);
	StringReplace(timeFormat, ".", "-");
	StringReplace(timeFormat, " ", "-");
	return timeFormat;
}

string TimeAsParameter(datetime d = 0)
{
	return GetXmlTimeFormat(d);
}

class XmlTag : public BaseObject
{
	private:
		
		string tagName;
		string tagData;
		TagType tagType;
		XmlAttribute attributes[];
		
	public:
		XmlTag() { Clear(); }
		
		string GetElementName() { return tagName; }
		TagType GetTagType() { return tagType; }
		string GetTagData() { return tagData; }
		
		bool HasAttribute(string attributeName) {
			for(int i=0;i<ArraySize(attributes);i++)
				if(attributes[i].name == attributeName)
					return true;
			return false;
		}
		
		void CopyAttributes(XmlAttribute &attrs[])
		{
			int lenAttributes = ArraySize(attributes);
			ArrayResize(attrs, lenAttributes);
			
			for(int i=0;i<lenAttributes;i++)
			{
				attrs[i].name = attributes[i].name;
				attrs[i].value = attributes[i].value;
			}
		}
		
		XmlAttribute GetAttributePosition(string attributeName) {
			XmlAttribute nullAttr;
			for(int i=0;i<ArraySize(attributes);i++)
				if(attributes[i].name == attributeName)
					return attributes[i];
			return nullAttr;
		}
		
		string GetAttributeValue(string attributeName) {
			for(int i=0;i<ArraySize(attributes);i++)
				if(attributes[i].name == attributeName)
					return attributes[i].value;
			return NULL;
		}
		
		void ParseTag(string tagLine)
		{
			this.tagType = TagType_InvalidTag;
			string lines[], words[];
			
			// clean
			StringReplace(tagLine, "\t", " ");
			StringReplace(tagLine, "< ", "<");
			StringReplace(tagLine, "= ", "=");
			StringReplace(tagLine, " =", "=");
			StringReplace(tagLine, " >", ">");
			StringReplace(tagLine, " />", "/>");
			
			//repl = StringReplace(tagLine, "><", ">\n<");
			//while((repl != -1) && (repl != 0))
			//	repl = StringReplace(tagLine, "><", ">\n<");
			
			int repl = StringReplace(tagLine, "  ", " ");
			while((repl != -1) && (repl != 0))
				repl = StringReplace(tagLine, "  ", " ");
			
			// split lines
			StringSplit(tagLine, '\n', lines);
			
			// return invalid if we have many lines
			if(ArraySize(lines) != 1)
				return;
		
			// 1 line anyway, but whatever XD
			string line = lines[0];
			StringReplace(line, "\n", "");
			StringReplace(line, "\r", "");
			
			int lineLength = StringLen(line);
			if((line[0] != '<') || (line[lineLength-1] != '>'))
			{
				if((line == NULL) ||
				(line == " ") ||
				(line == ""))
					return;
				
				tagType = TagType_DataWithoutTag;
				tagData = line;
				
				//if(IsVerboseMode())
				//	Print(__FUNCTION__ + " Error: No '<' at beginning or '>' at end. line: " + line);
				return;
			}
			
			line = StringSubstr(line, 1, lineLength-2);
			
			// there should be no starting tags anymore
			int replaceWrongs = StringReplace(line, "<","");
			if((replaceWrongs != -1) && (replaceWrongs != 0))
			{
				if(IsVerboseMode())
					Print(__FUNCTION__ + " Error: There should be no starting tags anymore.");
				return;
			}
			
			// there should be no stopping tags anymore
			replaceWrongs = StringReplace(line, ">","");
			if((replaceWrongs != -1) && (replaceWrongs != 0))
			{
				if(IsVerboseMode())
					Print(__FUNCTION__ + " Error: There should be no stopping tags anymore.");
				return;
			}
			
			lineLength = StringLen(line);
			if((line[0] == '/') && (line[lineLength-1] != '/'))
			{
				tagType = TagType_CloseTag;
				line = StringSubstr(line, 1, lineLength-1);
				lineLength--;
			}
			else if((line[0] != '/') && (line[lineLength-1] == '/'))
			{
				tagType = TagType_FullTag;
				line = StringSubstr(line, 0, lineLength-1);
				lineLength--;
			}
			else if((line[0] != '/') && (line[lineLength-1] != '/'))
			{
				// No need to parse "<?xml version="1.0" encoding="utf-8"?>" or "<?xml version="1.0" encoding="utf-16"?>".
				// I ignore that stuff, even though the parser would get it mostly right (at the end, would return invalid tag because of value not surrounded by '"'s;
				//  it is surrounded by '"' and '?' instead XD )
				if((line[0] == '?') && (line[lineLength-1] == '?'))
				{
					tagType = TagType_IgnoredTag;
					return;
				} else // else it's a real open tag, go on
					tagType = TagType_OpenTag;
				
			} else {
				if(IsVerboseMode())
					SafePrintString(__FUNCTION__ + " Error: there are 2 '\'s at the start and end of the line. WTF. Line right now: " + line, true);
				return;
			}
			
			// split words
			StringSplit(line, ' ', words);
			
			// we should have at least 1 word - else return invalid
			int numberOfWords = ArraySize(words);
			if(numberOfWords <= 0)
			{
				tagType = TagType_InvalidTag;
				if(IsVerboseMode())
					SafePrintString(__FUNCTION__ + " Error: We should have at least 1 word. Line right now: " + line, true);
				return;
			}
			
			
			// "<element/>" or "<element>" or "</element>"
			if(numberOfWords == 1)
				tagName = words[0];
			// "<element attr1="value1"/>" or "<element attr1="value1">" or  "<element attr1="value1" attr2="value2"/>" or "<element attr1="value1" attr2="value2">" or ...
			else if(numberOfWords >= 2)
			{
				tagName = words[0];
				
				for(int i=1;i<numberOfWords;i++)
				{
					// attrX="valueX"
					string attrPair[];
					StringSplit(words[i], '=', attrPair);
					
					if(ArraySize(attrPair) != 2)
					{
						tagType = TagType_InvalidTag;
						if(IsVerboseMode())
							SafePrintString(__FUNCTION__ + " Error: Attributes should have only 2 words after split by '='. words[i] before split: " + words[i], true);
						return;
					}
					
					string attributeName = attrPair[0];
					string attributeValue = attrPair[1];
					
					int attributeValueLength = StringLen(attributeValue);
					if((attributeValue[0] == '"') && (attributeValue[attributeValueLength-1] == '"'))
						attributeValue = StringSubstr(attributeValue, 1, attributeValueLength-2);
					else
					{
						tagType = TagType_InvalidTag;
						if(IsVerboseMode())
							SafePrintString(__FUNCTION__ + " Error: Value should be surrounded by \"\"s. attributeValue: " + attributeValue, true);
						return;
					}
					
					ArrayResize(attributes,i);
					attributes[i-1].name = attributeName;
					attributes[i-1].value = attributeValue;
				}
			}
		}
		
		void Clear()
		{
			tagName = NULL;
			tagType = TagType_CleanTag;
			tagData = NULL;
			ArrayResize(attributes,0);
		}
		
		
};
