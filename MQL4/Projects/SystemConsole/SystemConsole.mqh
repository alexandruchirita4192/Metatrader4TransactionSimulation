#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict

#include <MyMql\Base\BeforeObject.mqh>

#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>
#include <Controls\ListView.mqh>
#include <Controls\ComboBox.mqh>
#include <Controls\SpinEdit.mqh>
#include <Controls\RadioGroup.mqh>
#include <Controls\CheckGroup.mqh>

#include "SystemCommands.mqh"


#include <MyMql\Global\Global.mqh>
//#include <MyMql\Global\CNamedPipe.mqh>

static GlobalVariableCommunication comm(false, true);
//static CNamedPipe comm;


//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      (10)      // gap by X coordinate
#define CONTROLS_GAP_Y                      (10)      // gap by Y coordinate
//--- for buttons
#define BUTTON_WIDTH                        (100)     // size by X coordinate
#define BUTTON_HEIGHT                       (20)      // size by Y coordinate
//--- for the indication area
#define EDIT_HEIGHT                         (20)      // size by Y coordinate

#define LABEL_HEIGHT                        (15)      // size by Y coordinate

//+------------------------------------------------------------------+
//| Class SystemConsole                                              |
//| Usage: main dialog of the SimplePanel application                |
//+------------------------------------------------------------------+
class SystemConsole : public CAppDialog
{
private:
	CLabel            outputEdit[];                      // the display field object
	CEdit             inputEdit;                       // input edit
	CButton           lockButton;                       // the fixed button object
	CListView         optionsListView;                     // the list object
	CCheckGroup       configCheckGroup;                   // the check box group object

	string configString[];
	bool configValue[];
	SystemCommands sCommands;

public:
	SystemConsole(void);
	~SystemConsole(void);
	//--- create
	virtual bool      Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2);
	//--- chart event handler
	virtual bool      OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam);

	void              ExecuteCommand(string command);
protected:
	//--- create dependent controls
	bool              CreateOutputEdit(void);
	bool              CreateInputEdit(void);
	bool              CreateLockButton(void);
	bool              CreateConfigCheckGroup(void);
	bool              CreateOptionsListView(void);
	//--- internal event handlers
	virtual bool      OnResize(void);
	//--- handlers of the dependent controls events
	void              OnClickLockButton(void);
	void              OnChangeOptionsListView(void);
	void              OnChangeConfigCheckGroup(void);
	void              OnEndEditInputEdit(void);
	bool              OnDefault(const int id, const long &lparam, const double &dparam, const string &sparam);
	//--- Text handlers
	void              AddLine(string line);
	void              SetText(string text);
	void              UpdateControls(string command);
};

//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(SystemConsole)
ON_EVENT(ON_CLICK, lockButton, OnClickLockButton)
ON_EVENT(ON_CHANGE, configCheckGroup, OnChangeConfigCheckGroup)
ON_EVENT(ON_CHANGE, optionsListView, OnChangeOptionsListView)
ON_EVENT(ON_END_EDIT, inputEdit, OnEndEditInputEdit)
ON_OTHER_EVENTS(OnDefault)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
SystemConsole::SystemConsole(void)
{
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
SystemConsole::~SystemConsole(void)
{
}
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool SystemConsole::Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2)
{
	if (!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2))
		return (false);
//--- create dependent controls
	if (!CreateOutputEdit())
		return (false);
	if (!CreateInputEdit())
		return (false);
	if (!CreateLockButton())
		return (false);
	if (!CreateConfigCheckGroup())
		return (false);
	if (!CreateOptionsListView())
		return (false);
//--- succeed
	return (true);
}

//+------------------------------------------------------------------+
//| Create the display field                                         |
//+------------------------------------------------------------------+
bool SystemConsole::CreateOutputEdit(void)
{
//--- coordinates
	int x1 = INDENT_LEFT;
	int y1 = INDENT_TOP;
	int x2 = ClientAreaWidth() - (CONTROLS_GAP_X + BUTTON_WIDTH + CONTROLS_GAP_X + BUTTON_WIDTH + INDENT_RIGHT);
	int y2 = y1 + EDIT_HEIGHT;
	int yMax = ClientAreaHeight() - (CONTROLS_GAP_Y + EDIT_HEIGHT + INDENT_BOTTOM);
	int nr = yMax / LABEL_HEIGHT;
	ArrayResize(outputEdit, nr);

//--- create
	for (int i = 0; i < nr; i++)
	{
		if (!outputEdit[i].Create(m_chart_id, m_name + "OutputEdit" + IntegerToString(i), m_subwin, x1, y1, x2, y2))
			return (false);
		//if(!outputEdit.ReadOnly(true))
		//   return(false);
		if (!Add(outputEdit[i]))
			return (false);
		outputEdit[i].FontSize(8);
		outputEdit[i].Font("Courier New");
		outputEdit[i].Alignment(WND_ALIGN_WIDTH, INDENT_LEFT, 0, INDENT_RIGHT + BUTTON_WIDTH + CONTROLS_GAP_X, 0);

		y1 = y2;
		y2 = y1 + LABEL_HEIGHT;
	}

//--- succeed
	return (true);
}

//+------------------------------------------------------------------+
//| Create the display field                                         |
//+------------------------------------------------------------------+
bool SystemConsole::CreateInputEdit(void)
{
//--- coordinates
	int x1 = INDENT_LEFT;
	int y1 = ClientAreaHeight() - (EDIT_HEIGHT + INDENT_BOTTOM);
	int x2 = ClientAreaWidth() - (CONTROLS_GAP_X + BUTTON_WIDTH + CONTROLS_GAP_X + BUTTON_WIDTH + INDENT_RIGHT);
	int y2 = y1 + EDIT_HEIGHT;
//--- create
	if (!inputEdit.Create(m_chart_id, m_name + "InputEdit", m_subwin, x1, y1, x2, y2))
		return (false);
	if (!inputEdit.ReadOnly(false))
		return (false);
	if (!Add(inputEdit))
		return (false);
	inputEdit.TextAlign(ALIGN_LEFT);
	inputEdit.Alignment(WND_ALIGN_WIDTH, INDENT_LEFT, 0, CONTROLS_GAP_X + BUTTON_WIDTH + INDENT_RIGHT, 0);
//--- succeed
	return (true);
}

//+------------------------------------------------------------------+
//| Create the "CreateLockButton" fixed button                       |
//+------------------------------------------------------------------+
bool SystemConsole::CreateLockButton(void)
{
//--- coordinates
	int x1 = ClientAreaWidth() - (BUTTON_WIDTH + INDENT_RIGHT);
	int y1 = ClientAreaHeight() - (BUTTON_HEIGHT + INDENT_BOTTOM);
	int x2 = x1 + BUTTON_WIDTH;
	int y2 = y1 + BUTTON_HEIGHT;
//--- create
	if (!lockButton.Create(m_chart_id, m_name + "LockButton", m_subwin, x1, y1, x2, y2))
		return (false);
	if (!lockButton.Text("Locked"))
		return (false);
	if (!Add(lockButton))
		return (false);
	lockButton.Locking(true);
	lockButton.Alignment(WND_ALIGN_RIGHT | WND_ALIGN_BOTTOM, 0, 0, INDENT_RIGHT, INDENT_BOTTOM);
//--- succeed
	return (true);
}
//+------------------------------------------------------------------+
//| Create the "CheckGroup" element                                  |
//+------------------------------------------------------------------+
bool SystemConsole::CreateConfigCheckGroup(void)
{
//--- coordinates
	int x1 = ClientAreaWidth() - (BUTTON_WIDTH + INDENT_RIGHT);
	int y1 = INDENT_TOP;
	int x2 = x1 + BUTTON_WIDTH;
	int y2 = ClientAreaHeight() - (CONTROLS_GAP_Y + EDIT_HEIGHT + INDENT_BOTTOM);
//--- create
	if (!configCheckGroup.Create(m_chart_id, m_name + "CheckGroup", m_subwin, x1, y1, x2, y2))
		return (false);
	if (!Add(configCheckGroup))
		return (false);

	configCheckGroup.Alignment(WND_ALIGN_HEIGHT, 0, y1, 0, INDENT_BOTTOM);
//--- fill out with strings

//   for(int i=0;i<10;i++)
//      if(!configCheckGroup.AddItem("Item "+IntegerToString(i),1<<i))
//         return(false);
//
	GlobalContext.Config.FillWithBoolValues(configString, configValue);

	//Print("Before adding items to check group");
	int len1 = ArraySize(configString), len2 = ArraySize(configValue);
	//Print("ArraySize(configString)=" + IntegerToString(len1) + " ArraySize(configValue)=" + IntegerToString(len2));
   
   int maxIndex = 16;
   int configArraySize = ArraySize(configValue);
   if (maxIndex > configArraySize)
      maxIndex = configArraySize;
   
	for (int i = 0; i < maxIndex; i++) // do not allow more than "int" can hold (watch the shift left operation)
	{
		//Print("Adding item " + configString[i] + " with value " + IntegerToString(1 << i) + " at index " + IntegerToString(i));
		if (!configCheckGroup.AddItem(configString[i], 1 << i))
			return (false);
		if (configValue[i])
			configCheckGroup.Check(i, 1 << i);
	}
	//Print("Finished creating check group");

//--- succeed
	return (true);
}
//+------------------------------------------------------------------+
//| Create the "ListView" element                                    |
//+------------------------------------------------------------------+
bool SystemConsole::CreateOptionsListView(void)
{
//--- coordinates
	int x1 = ClientAreaWidth() - (BUTTON_WIDTH + CONTROLS_GAP_X + BUTTON_WIDTH + INDENT_RIGHT);
	int y1 = INDENT_TOP;
	int x2 = x1 + BUTTON_WIDTH;
	int y2 = ClientAreaHeight() - INDENT_BOTTOM;
//--- create
	if (!optionsListView.Create(m_chart_id, m_name + "ListView", m_subwin, x1, y1, x2, y2))
		return (false);
	if (!Add(optionsListView))
		return (false);
	optionsListView.Alignment(WND_ALIGN_HEIGHT, 0, y1, 0, INDENT_BOTTOM);
//--- fill out with strings

	string commands [];
	sCommands.GetSystemCommands(commands);

	for (int i = 0; i < ArraySize(commands); i++)
		if (!optionsListView.ItemAdd(commands[i]))
			return (false);
//--- succeed
	return (true);
}
//+------------------------------------------------------------------+
//| Handler of resizing                                              |
//+------------------------------------------------------------------+
bool SystemConsole::OnResize(void)
{
//--- call method of parent class
	if (!CAppDialog::OnResize()) return (false);
//--- coordinates

	int paddingTop = 2 * INDENT_TOP;

	// outputEdit align, move, resize
	int x1 = INDENT_LEFT;
	int y1 = INDENT_TOP;
	int x2 = ClientAreaWidth() - (CONTROLS_GAP_X + BUTTON_WIDTH + CONTROLS_GAP_X + BUTTON_WIDTH + INDENT_RIGHT);
	int y2 = y1 + EDIT_HEIGHT;
	int yMax = ClientAreaHeight() - (CONTROLS_GAP_Y + EDIT_HEIGHT + INDENT_BOTTOM);
	int nr = yMax / EDIT_HEIGHT;
	ArrayResize(outputEdit, nr);

	for (int i = 0; i < nr; i++)
	{
		outputEdit[i].Move(x1, paddingTop + y1);
		outputEdit[i].Width(x2 - x1);
		outputEdit[i].Height(y2 - y1);
		outputEdit[i].Alignment(WND_ALIGN_WIDTH, INDENT_LEFT, 0, INDENT_RIGHT + BUTTON_WIDTH + CONTROLS_GAP_X, 0);

		y1 = y2;
		y2 = y1 + EDIT_HEIGHT;
	}

	// inputEdit align, move, resize
	x1 = INDENT_LEFT;
	y1 = ClientAreaHeight() - (EDIT_HEIGHT + INDENT_BOTTOM);
	x2 = ClientAreaWidth() - (CONTROLS_GAP_X + BUTTON_WIDTH + CONTROLS_GAP_X + BUTTON_WIDTH + INDENT_RIGHT);
	y2 = y1 + EDIT_HEIGHT;
	inputEdit.Move(x1, paddingTop + y1);
	inputEdit.Width(x2 - x1);
	inputEdit.Height(y2 - y1);
	inputEdit.Alignment(WND_ALIGN_WIDTH, INDENT_LEFT, 0, CONTROLS_GAP_X + BUTTON_WIDTH + INDENT_RIGHT, 0);

	// lockButton align, move, resize
	x1 = ClientAreaWidth() - (BUTTON_WIDTH + INDENT_RIGHT);
	y1 = ClientAreaHeight() - (BUTTON_HEIGHT + INDENT_BOTTOM);
	x2 = x1 + BUTTON_WIDTH;
	y2 = y1 + BUTTON_HEIGHT;
	lockButton.Move(x1, paddingTop + y1);
	lockButton.Width(x2 - x1);
	lockButton.Height(y2 - y1);
	lockButton.Alignment(WND_ALIGN_RIGHT | WND_ALIGN_BOTTOM, 0, 0, INDENT_RIGHT, INDENT_BOTTOM);

	// configCheckGroup align, move, resize
	x1 = ClientAreaWidth() - (BUTTON_WIDTH + INDENT_RIGHT);
	y1 = INDENT_TOP;
	x2 = x1 + BUTTON_WIDTH;
	y2 = ClientAreaHeight() - (CONTROLS_GAP_Y + EDIT_HEIGHT + INDENT_BOTTOM);
	configCheckGroup.Move(x1, paddingTop + y1);
	configCheckGroup.Width(x2 - x1);
	configCheckGroup.Height(y2 - y1);
	configCheckGroup.Alignment(WND_ALIGN_HEIGHT, 0, y1, 0, INDENT_BOTTOM);

	// optionsListView align, move, resize
	x1 = ClientAreaWidth() - (BUTTON_WIDTH + CONTROLS_GAP_X + BUTTON_WIDTH + INDENT_RIGHT);
	y1 = INDENT_TOP;
	x2 = x1 + BUTTON_WIDTH;
	y2 = ClientAreaHeight() - INDENT_BOTTOM;
	optionsListView.Move(x1, paddingTop + y1);
	optionsListView.Width(x2 - x1);
	optionsListView.Height(y2 - y1);
	optionsListView.Alignment(WND_ALIGN_HEIGHT, 0, y1, 0, INDENT_BOTTOM);

//--- succeed
	return (true);
}
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void SystemConsole::OnClickLockButton(void)
{
	if (lockButton.Pressed())
	{
		//outputEdit.Text(__FUNCTION__+"On");
		inputEdit.ReadOnly(true);
		configCheckGroup.Disable();
		optionsListView.Disable();
	}
	else
	{
		//outputEdit.Text(__FUNCTION__+"Off");
		inputEdit.ReadOnly(false);
		configCheckGroup.Enable();
		optionsListView.Enable();
		//CreateConfigCheckGroup();
		//CreateOptionsListView();
		this.Enable();
	}
}
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void SystemConsole::OnChangeOptionsListView(void)
{
	if (optionsListView.IsEnabled())
	{
		//AddLine(__FUNCTION__+" \""+optionsListView.Select()+"\"");

		string command = optionsListView.Select();
		UpdateControls(command);

		//outputEdit.Text(__FUNCTION__+" \""+optionsListView.Select()+"\"");
	}
}

//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void SystemConsole::OnChangeConfigCheckGroup(void)
{
	if (configCheckGroup.IsEnabled())
	{
		//AddLine(__FUNCTION__);
		//AddLine("Value="+IntegerToString(configCheckGroup.Value()));
		long checkGroupValue = configCheckGroup.Value();
		bool cond = true;

		for (int i = 0; i < ArraySize(configValue); i++)
		{
			bool currentValue = checkGroupValue & (1 << i);
			if (currentValue != configValue[i])
			{
				configValue[i] = currentValue;
				GlobalContext.Config.SetBoolValue(configString[i], configValue[i]);
				LogInfoMessageIfTrue(cond, configString[i] + "=" + BoolToString(configValue[i]));
			}
		}
		//outputEdit.Text(__FUNCTION__+" : Value="+IntegerToString(configCheckGroup.Value()));
	}
}
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void SystemConsole::OnEndEditInputEdit(void)
{
	if (inputEdit.IsEnabled())
	{
		//AddLine(__FUNCTION__+" : Text=\""+inputEdit.Text()+"\"");
		//outputEdit.Text(__FUNCTION__+" : Text="+inputEdit.Text());
		//inputEdit.Activate();

		string command = inputEdit.Text();
		UpdateControls(command);

		inputEdit.Text(NULL);

		//Print(__FUNCTION__ + "SetFocus & SetActiveWindow");
		//int hWnd = WindowHandle(_Symbol, 0);
		//SetFocus(hWnd);
		//SetActiveWindow(hWnd);

		//for(int i=0;i<inputEdit.ControlsTotal();i++)
		//{
		//   CWnd* ctrl = inputEdit.Control(i);
		//   ctrl.Id();
		//}


//    //EventChartCustom(ChartID(), CHARTEVENT_CLICK, inputEdit.Left(), inputEdit.Top(), NULL);
//    long x = (inputEdit.Left() + inputEdit.Right())/2;
//    double y = (inputEdit.Top() + inputEdit.Bottom())/2;
//    //inputEdit.OnMouseEvent(x, y, MOUSE_LEFT);
//    //EventChartCustom(0, CHARTEVENT_OBJECT_CLICK, x, y, NULL);
//    //EventChartCustom(0, CHARTEVENT_CLICK, x, y, NULL);
//    //EventChartCustom(0, CHARTEVENT_OBJECT_ENDEDIT, x, y, NULL);
//    EventChartCustom(0, CHARTEVENT_OBJECT_CHANGE, x, y, NULL);
//
//    string sth = NULL;
//    inputEdit.OnEvent(CHARTEVENT_OBJECT_ENDEDIT, x, y, sth);

	}
}


//+------------------------------------------------------------------+
//| Rest events handler                                                    |
//+------------------------------------------------------------------+
bool SystemConsole::OnDefault(const int id, const long &lparam, const double &dparam, const string &sparam)
{
//--- restore buttons' states after mouse move'n'click
	//if(id==CHARTEVENT_CLICK)
	//   m_radio_group.RedrawButtonStates();
//--- let's handle event by parent
	return (false);
}
//+------------------------------------------------------------------+

void SystemConsole::AddLine(string line)
{
	int outputEditLength = ArraySize(outputEdit);

	for (int i = 1; i < outputEditLength; i++)
		outputEdit[i - 1].Text(outputEdit[i].Text());
	outputEdit[outputEditLength - 1].Text(line);
}

void SystemConsole::SetText(string text)
{
	string lines[];
	StringSplit(text, '\n', lines);

	int len = ArraySize(lines);
	for (int i = 0; i < len; i++)
		AddLine(lines[i]);
}

void SystemConsole::UpdateControls(string command)
{
	ExecuteCommand(command);
	sCommands.SetCommand(command);

	if (sCommands.NeedRefresh())
	{
		optionsListView.Select(CONTROLS_INVALID_INDEX);
		optionsListView.ItemsClear();
		optionsListView.VScrolled(false);

		string commands [];
		sCommands.GetSystemCommands(commands);

		for (int i = 0; i < ArraySize(commands); i++)
			if (!optionsListView.ItemAdd(commands[i]))
				return;
	}

	//AddLine("\"" + sCommands.GetContext() + "\" \"" + command + "\"");
}

void SystemConsole::ExecuteCommand(string command)
{
	sCommands.SetCommand(command);
	string newCommand = sCommands.GetSystemCommandToExecute(), context = sCommands.GetContext();

	LogInfoMessageIfTrue(false, __FUNCTION__ + " command: \"" + command + "\" newCommand: \"" + newCommand + "\" context: \"" + context + "\"");

	if ((command == "[h]help") || (command == "h") || (command == "help"))
	{
		AddLine("Commands:");
		AddLine(" [h]help   - print this");
		AddLine(" [p]print  - print values");
		AddLine(" [o]config - get/set config");
		AddLine("  Discovery/System/EA:");
		AddLine("   [d]discovery");
		AddLine("   [l]light system");
		AddLine("   [s]system - run simulation");
		AddLine("   [a]EA     - Expert Advisor");
		AddLine(" [i]indicator");
		AddLine(" [n]analysis indicator");
		AddLine(" [o]orders view");
		AddLine(" [%]probability of order");
		AddLine(" [m]manual order");
		AddLine(" [u]update order");
		AddLine(" [c]call WS proc");
		AddLine(" [r]screenshot");
		AddLine(" [x]exit/[q]quit");
	}

	else if ((command == "[x]exit/[q]quit") || (command == "[x]exit") || (command == "[q]quit") || (command == "x") || (command == "q") || (command == "exit") || (command == "quit"))
	{
		if (GlobalContext.Config.IsIndicator())
			ChartIndicatorDelete(ChartID(), 0, "SystemConsole");
		else
			ExpertRemove();

		LogInfoMessageIfTrue(false, __FUNCTION__ + " - Tried to exit");
	}
	else if ((command == "[r]screenshot") || (command == "r") || (command == "screenshot"))
	{
		long chartId = ChartID();
		string timeMinutesStr = TimeToString(TimeCurrent(), TIME_SECONDS);
		StringReplace(timeMinutesStr, ":", ".");
		string fileName = "ScreenShot_" + ChartSymbol(chartId) + "_" + TimeFrameToString(ChartPeriod(chartId)) + "_" + TimeToString(TimeCurrent(), TIME_DATE) + "_" + timeMinutesStr + ".jpg";
		int width = (int)ChartGetInteger(chartId, CHART_WIDTH_IN_PIXELS);
		int height = (int)ChartGetInteger(chartId, CHART_HEIGHT_IN_PIXELS);

		ChartScreenShot(chartId, "Chart_" + fileName, width, height);
		//WindowScreenShot("Window_" + fileName, width, height);
	}
	else if ((command == "[b]back") || (command == "back") || (command == "b"))
	{
		//sCommands.UpdateContext(NULL, true);
	}
	else if (!StringIsNullOrEmpty(context))
	{
		if (!StringIsNullOrEmpty(newCommand))
		{
			comm.SendText(newCommand);
			//comm.WriteANSI(newCommand);

			LogInfoMessageIfTrue(true, __FUNCTION__ + " Sending to SystemProcessor the command: \"" + newCommand + "\"; context: \"" + context + "\" command: \"" + command + "\"");
		}
	}
}