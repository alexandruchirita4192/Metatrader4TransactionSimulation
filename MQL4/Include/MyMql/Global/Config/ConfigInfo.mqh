#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql\Base\BaseObject.mqh>

string ConstDefaultConfigFileName = "Config.txt";

struct ConfigData
{
	string config;
	string value;
};


class ConfigInfo : BaseObject
{
private:
	string FileName;

	ConfigData conf[];
	
	void LoadData() // load data C# style (while being careful to have allocated enough memory)
	{
      bool arraySizeIsZero = ArraySize(conf) == 0;
      //LogInfoMessage(" arraySizeIsZero=" + BoolToString(arraySizeIsZero) + " with file " + FileName);
      
	   if (!arraySizeIsZero)
	      return;
	   
	   string fullPath = FileName;
      string line = "";
      
      
      // Ensure that the "line" string can hold maximum line length
      int maximumLineLength = GetFileMaximumLineLength(fullPath);
      //LogInfoMessage("maximumLineLength=" + IntegerToString(maximumLineLength) + " in path " + fullPath);
      bool reserved = StringInit(line, maximumLineLength);
      if (!reserved)
         LogInfoMessage("Cannot reserve string; GetLastError=" + IntegerToString(GetLastError()));
         
      // Get line count
		int lineCount = GetFileLinesCount(fullPath);
      //LogInfoMessage("LineCount=" + IntegerToString(lineCount) + " in path " + fullPath);
      
		string words[];
      
      for(int lineNumber = 0; lineNumber < lineCount; lineNumber++)
      {
         reserved = StringReserve(line, maximumLineLength);
         if (!reserved)
            LogInfoMessage("Cannot reserve string; GetLastError=" + IntegerToString(GetLastError()));
            
         int readStatus = ReadLine(fullPath, line, lineNumber);
         if (readStatus < 0)
         {
            LogInfoMessage("ReadLine failed with value: " + IntegerToString(readStatus));
            break;
         }
         //else
         //   LogInfoMessage("ReadLine read line " + IntegerToString(lineNumber) + ": " + line);
		   
			StringSplit(line, '=', words);
			if (ArraySize(words) == 2)
				AddOrUpdate(words[0], words[1], line);
			else
			{
   			string msg = NULL;
   			
			   if(StringIsNullOrEmpty(line))
			      msg = "Empty line "  + IntegerToString(lineNumber) + " in ";
			   else
   			   msg = "Weird line read "  + IntegerToString(lineNumber) + " in ";
            msg += __FUNCTION__ + " " + __FILE__ + ":" + IntegerToString(__LINE__) + " " + IntegerToString(ArraySize(words)) + " line=" + line + " in path " + fullPath;
            
				SafePrintString(msg, true);
         }
		}
		
		LogInfoMessage("Loaded " + IntegerToString(ArraySize(conf)) + " items");
	}
	
	void SaveData()
	{
      CleanFile(FileName);
      
		for (int i = 0; i < ArraySize(conf); i++)
		   if(conf[i].config != "ConfigFile") // the config is common, so we can't save ConfigFile
		      AppendLine(FileName, conf[i].config + "=" + conf[i].value);
		    
		LogInfoMessage("Saved " + IntegerToString(ArraySize(conf)) + " items");
	}


	void AddOrUpdate(string config, string value, string line = NULL)
	{
		bool debug = GlobalContext.Config.GetBoolValue("Debug");
		bool found = false;
		int len = ArraySize(conf);

		for (int i = 0; i < len; i++)
		{
			if (conf[i].config == config)
			{
				LogInfoMessageIfTrue(debug && conf[i].value != value, "[found=true] config=" + config + " value=" + conf[i].value + " newValue=" + value + (!StringIsNullOrEmpty(line) ? " line=" + line : ""));
				conf[i].value = value;
				found = true;
				break;
			}
		}

		if (found == false)
		{
			ArrayResize(conf, len + 1);
			conf[len].config = config;
			conf[len].value = value;
			//LogInfoMessageIfTrue(debug, "[new config] config=" + config + " value=" + value + (!StringIsNullOrEmpty(line) ? " line=" + line : ""));
		}
	}

public:
	ConfigInfo(string fileName = "")
	{
		if (fileName != "")
		{
		   FileName = fileName;
		   
		   LoadData();
		}
		else
			FileName = ConstDefaultConfigFileName;
	}

	void ConfigInfoDeinit()
	{
		if (GlobalContext.Config.GetBoolValue("IsExpertAdviser"))
			SaveData();
	}

	void SetValue(string config, string value, bool saveData = false)
	{
		AddOrUpdate(config, value);

		if (saveData)
			SaveData();
	}

	void SetValueIfNotExists(string config, string value, bool saveData = false)
	{
		if (!Exists(config))
			SetValue(config, value, saveData);
	}

	int GetPositionForValue(string config)
	{
		for (int i = 0; i < ArraySize(conf); i++)
			if (conf[i].config == config)
				return i;
		return -1;
	}

	bool Exists(string config)
	{
		return GetPositionForValue(config) != -1;
	}

	void DeleteValue(string config)
	{
		int pos = GetPositionForValue(config);
		int len = ArraySize(conf);

		if (pos == -1)
			return;

		// shift values
		for (int i = pos; i < len - 1; i++)
		{
			conf[i].config = conf[i + 1].config;
			conf[i].value  = conf[i + 1].value;
		}

		ArrayResize(conf, len - 1);
	}

	void FillWithBoolValues(string &configBoolArray[], bool &valueBoolArray[])
	{
		int len = 0;
		for (int i = 0; i < ArraySize(conf); i++)
			if (IsValidBool(conf[i].value))
			{
				len++;
				ArrayResize(configBoolArray, len);
				ArrayResize(valueBoolArray, len);

				configBoolArray[len - 1] = conf[i].config;
				valueBoolArray[len - 1] = StringToBool(conf[i].value);
			}
	}

	bool HasValue(string config)
	{
		for (int i = 0; i < ArraySize(conf); i++)
			if (conf[i].config == config)
				return true;
		return false;
	}
	
	string GetValue(string config)
	{
		for (int i = 0; i < ArraySize(conf); i++)
			if (conf[i].config == config)
				return conf[i].value;
		return "";
	}

	void SetBoolValue(string config, bool value, bool saveData = false)
	{
		SetValue(config, BoolToString(value), saveData);
	}

	void SetBoolValueIfNotExists(string config, bool value, bool saveData = false)
	{
		if (!Exists(config))
			SetValue(config, BoolToString(value), saveData);
	}

	bool GetBoolValue(string config)
	{
		return StringToBool(GetValue(config));
	}

	datetime GetTimeValue(string config)
	{
		return StringToTime(GetValue(config));
	}

	int GetIntegerValue(string config)
	{
		return (int)StringToInteger(GetValue(config));
	}

	long GetLongValue(string config)
	{
		return StringToInteger(GetValue(config));
	}

	void WriteConfig()
	{
		SaveData();
	}

	void ReloadConfig()
	{
		LoadData();
	}
};

