#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql\Base\BaseObject.mqh>
#include <Files\FileTxt.mqh>

class FileLog : public CFileTxt
{
private:
	string fileName;
	bool closed;
	bool writeFlag, rewriteFlag;

	void CleanLog() // this only cleanes variables; use CloseLog() in most situations instead
	{
		fileName = NULL; closed = true; writeFlag = false; rewriteFlag = false;
	}

public:
	FileLog()
	{
		this.CleanLog(); // this only cleanes variables
	}

	FileLog(string filename, bool write = true, bool rewrite = false, bool fileText = false)
	{
		Initialize(filename, write, rewrite, fileText);
	}

	~FileLog()
	{
		this.CloseLog();
	}

	void Initialize(string filename, bool write = true, bool rewrite = false, bool fileText = false)
	{
		this.CloseLog();

		fileName = filename;
		writeFlag = write;
		rewriteFlag = rewrite;

		int openFlags = FILE_READ | FILE_SHARE_READ;// | FILE_ANSI;
		if (writeFlag)
		{
			openFlags = openFlags | FILE_SHARE_WRITE | FILE_WRITE;
			if (rewriteFlag)
				openFlags = openFlags | FILE_REWRITE;
		}

		if (fileText)
			openFlags = openFlags | FILE_TXT;

		this.Open(fileName, openFlags);

		// seek end only if writing
		if (!rewrite && write)
			this.Seek(0, SEEK_END);

		closed = false;
	}


	void InitializeAndWriteAllText(string filename, string text, bool write = true, bool rewrite = false)
	{
		this.CloseLog();

		this.Initialize(filename, write, rewrite);
		this.WriteString(text);

		this.CloseLog();
	}

	void virtual WriteLine(string text)
	{
		if (!closed)
		{
			this.WriteString(text + "\n");
			this.Flush();
		}
		else
			Print(__FUNCTION__ + " called without opening the file properly.");
	}

	void OpenLog(const string filename = "", int openFlags = 0, const short delimiter = 9)
	{
		this.CloseLog();

		if (filename != NULL && filename != "")
			fileName = filename;
		if ((openFlags == 0) && (fileName != NULL) && (fileName != ""))
		{
			openFlags = FILE_READ | FILE_ANSI;
			if (writeFlag)
				openFlags = openFlags | FILE_WRITE;
			if (writeFlag && rewriteFlag)
				openFlags = openFlags | FILE_REWRITE;
		}

		this.Open(fileName, openFlags, delimiter);
		closed = false;
	}

	void CloseLog(unsigned int delay = 1)
	{
		if (!closed)
		{
			if (writeFlag)
				this.Flush();
			this.Close();
			CleanLog();
			Sleep(delay); // delay = 1 (default CloseLog)
		}
	}
};
