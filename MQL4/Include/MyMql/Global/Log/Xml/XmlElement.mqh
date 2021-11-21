#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql\Global\BaseGlobal.mqh>

#include <MyMql\Base\BaseObject.mqh>
#include <MyMql\Global\Log\Xml\XmlAttribute.mqh>
#include <MyMql\Global\Log\Xml\XmlTag.mqh>

class XmlElement : public BaseObject
{
	private:
		string elementName, tagData;
		XmlAttribute attributes[];
		XmlElement children[];
		TagType tagType;
		
		int levelNumber;
		int pos[];
		XmlElement *ref[];
		
	public:
		XmlElement() { levelNumber = 0; }
		XmlElement(XmlElement &elem) { elementName = elem.GetElementName(); elem.CopyAttributes(attributes); tagType = elem.GetTagType(); tagData = elem.GetTagData(); }
		XmlElement(XmlTag &tag) { elementName = tag.GetElementName(); tag.CopyAttributes(attributes); tagType = tag.GetTagType(); tagData = tag.GetTagData(); }
		
		void Initialize(XmlElement &elem) { elementName = elem.GetElementName(); elem.CopyAttributes(attributes); tagType = elem.GetTagType(); tagData = elem.GetTagData(); }
		void Initialize(XmlTag &tag) { elementName = tag.GetElementName(); tag.CopyAttributes(attributes); tagType = tag.GetTagType(); tagData = tag.GetTagData(); }
		
		TagType GetTagType() { return tagType; }
		string GetTagData() { return tagData; }
		
		string GetElementName() { return elementName; }
		string GetFullElementData() {
			string ret = elementName;
			
			int lenAttributes = ArraySize(attributes);
			if(lenAttributes > 0)
			{
				ret += "[ ";
				for(int i=0;i<lenAttributes;i++)
				{
					ret += attributes[i].name + "=" + attributes[i].value + " ";
				}
				ret += "]";
			}
			
			int lenChildren = ArraySize(children);
			if(lenChildren > 0)
			{
				ret += "{ ";
				for(int i=0;i<lenChildren;i++)
				{
					ret += children[i].GetFullElementData() + " ";
				}
				ret += "}";
			}
			
			return ret;
		}
		
		XmlElement* GetChildByElementName(string name)
		{
			int lenChildren = ArraySize(children);
			if(lenChildren > 0)
			{
				for(int i=0;i<lenChildren;i++)
					if(children[i].GetElementName() == name)
						return &children[i];
				
				for(int i=0;i<lenChildren;i++)
				{
					XmlElement *elem = children[i].GetChildByElementName(name);
					if(elem != NULL)
						return elem;
				}
			}
			return NULL;
		}
		
		string GetChildTagDataByParentElementName(string name)
		{
			XmlElement *elem = this.GetChildByElementName(name);
			return elem != NULL && elem.HasChildren() ? elem.GetChildByPosition(0).GetTagData() : NULL;
		}
		
		XmlElement* GetChildByPosition(int cp)
		{
			if(ArraySize(children) <= cp)
				return NULL;	
			else
				return &children[cp];
		}
		
		bool HasChildren() { return (ArraySize(children) > 0); }
		
		bool HasAttribute(string attributeName) {
			for(int i=0;i<ArraySize(attributes);i++)
				if(attributes[i].name == attributeName)
					return true;
			return false;
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
		
		void ParseXml(string xmlString)
		{
			if((this.elementName != NULL) ||
			(ArraySize(this.children) != 0) ||
			(ArraySize(this.attributes) != 0) ||
			(this.GetTagType() != TagType_CleanTag))
			{
				if(IsVerboseMode())
					Print("WTF, dude. Not cleaned here. It's gonna get crashed. Cleaning and starting the job to be done.");
				Clear();
			}
			
			//GlobalFileLog.InitializeAndWriteAllText("00.BeforeAll.txt", xmlString, true, true);
			
			string lines[];
			
			
			// clean
			StringReplace(xmlString, "\t", " "); //GlobalFileLog.InitializeAndWriteAllText("01.Repl.txt", xmlString, true, true);
			StringReplace(xmlString, "< ", "<"); //GlobalFileLog.InitializeAndWriteAllText("02.Repl.txt", xmlString, true, true);
			StringReplace(xmlString, "= ", "="); //GlobalFileLog.InitializeAndWriteAllText("03.Repl.txt", xmlString, true, true);
			StringReplace(xmlString, " =", "="); //GlobalFileLog.InitializeAndWriteAllText("04.Repl.txt", xmlString, true, true);
			StringReplace(xmlString, " >", ">"); //GlobalFileLog.InitializeAndWriteAllText("05.Repl.txt", xmlString, true, true);
			StringReplace(xmlString, " />", "/>"); //GlobalFileLog.InitializeAndWriteAllText("06.Repl.txt", xmlString, true, true);
			StringReplace(xmlString, "\n", ""); //GlobalFileLog.InitializeAndWriteAllText("07.Repl.txt", xmlString, true, true);
			StringReplace(xmlString, "\r", ""); //GlobalFileLog.InitializeAndWriteAllText("08.Repl.txt", xmlString, true, true);
			StringReplace(xmlString, ">", ">\n"); //GlobalFileLog.InitializeAndWriteAllText("09.Repl.txt", xmlString, true, true);
			StringReplace(xmlString, "<", "\n<"); //GlobalFileLog.InitializeAndWriteAllText("10.Repl.txt", xmlString, true, true);
			StringReplace(xmlString, "\n\n", "\n"); //GlobalFileLog.InitializeAndWriteAllText("11.Repl.txt", xmlString, true, true);
			
			
			int repl = StringReplace(xmlString, "><", ">\n<");
			while((repl != -1) && (repl != 0))
				repl = StringReplace(xmlString, "><", ">\n<");
			//GlobalFileLog.InitializeAndWriteAllText("12.Repl.txt", xmlString, true, true);
			
			repl = StringReplace(xmlString, "\n\n", "\n");
			while((repl != -1) && (repl != 0))
				repl = StringReplace(xmlString, "\n\n", "\n");
			//GlobalFileLog.InitializeAndWriteAllText("13.Repl.txt", xmlString, true, true);
				
			repl = StringReplace(xmlString, "  ", " ");
			while((repl != -1) && (repl != 0))
				repl = StringReplace(xmlString, "  ", " ");
			//GlobalFileLog.InitializeAndWriteAllText("14.Repl.txt", xmlString, true, true);
			
			// split lines
			StringSplit(xmlString, '\n', lines);
			
			if(ArraySize(lines) <= 0)
			{
				if(IsVerboseMode())
					SafePrintString(__FUNCTION__ + " nothing to parse. xmlString: " + xmlString, true);
				return;
			}
				
			//GlobalFileLog.InitializeAndWriteAllText("15.Split0.txt", lines[0], true, true);
			
			//if(ArraySize(lines) > 1)
				//GlobalFileLog.InitializeAndWriteAllText("16.Split1.txt", lines[1], true, true);
			
			if(ArraySize(lines) <= 0)
			{
				if(IsVerboseMode())
					SafePrintString(__FUNCTION__ + " nothing to parse. xmlString: " + xmlString, true);
				return;
			}
			
			//int currentElementPositionLen = 1;
			//ArrayResize(currentElementPosition,1);
			//ArrayResize(currentElementReference,1);
			XmlTag currentTag;
			XmlElement newElement;
			levelNumber = 0;
			
			for(int i=0;i<ArraySize(lines);i++)
			{
				string line = lines[i];
				TagType currentTagType = TagType_InvalidTag;
				
				if(StringIsEmptyLine(line))
					continue;
				
				currentTag.Clear();
				currentTag.ParseTag(line);
				currentTagType = currentTag.GetTagType();
				
				if((currentTagType == TagType_IgnoredTag) ||
				(currentTagType == TagType_InvalidTag) ||
				(currentTagType == TagType_CleanTag))
				{
					if(IsVerboseMode())
						Print("Got an invalid/ignored line. Continuing anyway. XD. line=" + line);
					continue;
				}
				
				newElement.Clear();
				newElement.Initialize(currentTag);
				
				switch(currentTagType)
				{
					case TagType_DataWithoutTag:
					case TagType_FullTag:
						UpdateVectors();
						AddElement(newElement);
						
						if(levelNumber>=0)
							pos[levelNumber]++;
						
//						if(currentTagType == TagType_DataWithoutTag)
//							pos[levelNumber]--;
						
						break;
						
					case TagType_OpenTag:
						UpdateVectors();
						AddElement(newElement);
						levelNumber++;
						break;

					case TagType_CloseTag:
						if(levelNumber>=0)
							pos[levelNumber]=0;
						levelNumber--;
						if(levelNumber>=0)
							pos[levelNumber]++;
						//UpdateVectors();
						break;
						
					case TagType_InvalidTag:
						if(IsVerboseMode())
							SafePrintString(__FUNCTION__ + " Error: TagType is InvalidTag; lines[i] = " + lines[i], true);
					
					case TagType_CleanTag:
					case TagType_IgnoredTag:
					default:
						break;
				};
			}
		}
		
		void AddElement(XmlElement &element)
		{
			if(elementName == NULL)
			{
				this.Initialize(element);
				ref[levelNumber] = &this;
			}
			else
			{
				ref[levelNumber-1].children[pos[levelNumber]].Clear();
				ref[levelNumber-1].children[pos[levelNumber]].Initialize(element);
				ref[levelNumber] = &ref[levelNumber-1].children[pos[levelNumber]];
			}
		}
		
		void UpdateVectors()
		{
			int len = ArraySize(pos);
			if(levelNumber+1 > len)
			{
				ArrayResize(pos,levelNumber+1);
				ArrayResize(ref,levelNumber+1);
				
				pos[levelNumber] = 0;
				ref[levelNumber] = NULL;
			}
			if((levelNumber > 0) && (ref[levelNumber-1] != NULL))
			{
				len = ArraySize(ref[levelNumber-1].children);
				if(pos[levelNumber]+1 > len)
					ArrayResize(ref[levelNumber-1].children, pos[levelNumber]+1);
			}
		}
		
		void TestEndingTag(XmlElement &element)
		{
			if(IsVerboseMode())
			{
				// test might be so bad that it's not even tested
				string currentElementName = element.GetElementName();
				
				if(ref[levelNumber].GetElementName() != currentElementName)
					Print("Wrong ending tag?");
			}
		}
		
		string GetXmlFromElement()
		{
			if (tagType == TagType_DataWithoutTag)
				return tagData;
			else if(tagType == TagType_InvalidTag)
				return "";
			else if((elementName == "") || (elementName == NULL))
			{
				Print("Undetected invalid tag; no element name!");
				return "";
			}
			
			string xml = "<" + elementName;
			int attributesLen = ArraySize(attributes);
			if(attributesLen > 0)
			{
				string attrs = "";
				for(int i=0;i<attributesLen;i++)
					attrs += attributes[i].name + "=\"" + attributes[i].value + "\" ";
				
				attrs = StringSubstr(attrs,0,StringLen(attrs)-1);
				xml += " " + attrs;
			}
			
			int childrenLen = ArraySize(children);
			if(childrenLen > 0)
			{
				xml += ">";
				for(int i=0;i<childrenLen;i++)
					xml += children[i].GetXmlFromElement();
				xml += "</" + elementName + ">";
			}
			else
				xml += "/>";
			
			return xml;
		}
		
		void Clear()
		{
			elementName = NULL;
			tagData = NULL;
			tagType = TagType_CleanTag;
			
			ArrayResize(attributes,0);
			for(int i=0;i<ArraySize(children);i++)
				children[i].Clear();
			ArrayResize(children,0);
			
			levelNumber = 0;
			ArrayResize(pos,0);
			ArrayResize(ref,0);
		}
};
