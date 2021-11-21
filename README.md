# Metatrader 4 indicators and experts used to simulate transactions
Some custom Metatrader 4 libraries `MQL4/Include/MyMql` along with some custom Metatrader 4 projects (most important ones are `TestChangeChartGlobalVar` indicator, `SystemConsole` indicator, `SystemProcessor` expert) used to simulate transactions on history to check if some decisions are reliable.

## Known issues:
- Profit calculation has some issues and sometimes doesn't calculate profit properly. Please note that the formula used is confirmed by some broker, but the result is still unreliable (and I couldn't find a way to make it work better).

## Requirements:
- SQL Server installation for logging transactions simulation data to the `MetatraderLog` database
- Internet Information Services (IIS) windows features enabled used for adding the [MetatraderLogWeb](https://github.com/alexandruchirita4192/MetatraderLogWeb) web application.
- SQL Server Management Studio installed used for restoring the [MetatraderLog.bak](https://github.com/alexandruchirita4192/MetatraderLogWeb/blob/main/MetatraderLog.bak) database or for executing some queries on the database (for example: seeing the results of the simulation).
- Visual Studio for building [MetatraderLogWeb](https://github.com/alexandruchirita4192/MetatraderLogWeb) project, [ScriptsPackage](https://github.com/alexandruchirita4192/ScriptsPackage) project and [DotNetLibrary](https://github.com/alexandruchirita4192/DotNetTestLibrary) project.
- Metatrader 4 installed from a broker.

## Installation:
- Check the `%APPDATA%\MetaQuotes\Terminal\[TerminalId]` path to get the `[TerminalId]` for your Metatrader 4 installation.
- The [MQL4](https://github.com/alexandruchirita4192/Metatrader4ProjectsAndIncludes/tree/main/MQL4) folder can be copied on your `%APPDATA%\MetaQuotes\Terminal\[TerminalId]\MQL4` folder.
- The database `MetatraderLog` can be restored using [MetatraderLog.bak](https://github.com/alexandruchirita4192/MetatraderLogWeb/blob/main/MetatraderLog.bak) or created without data by building the project [ScriptsPackage](https://github.com/alexandruchirita4192/ScriptsPackage), running the project and using the output script from project on an empty database.
- The [MetatraderLogWeb](https://github.com/alexandruchirita4192/MetatraderLogWeb) project built, configured (Web.config requires changes pointing to the restored `MetatraderLog` database) and added as an IIS application.
- Metatrader 4 installed needs configuration to allow DLL calls (for the [DotNetLibrary](https://github.com/alexandruchirita4192/DotNetTestLibrary) project) and WebService calls to the IIS application url used by [MetatraderLogWeb](https://github.com/alexandruchirita4192/MetatraderLogWeb) installed web application.
- Optional:
  - Building the [DotNetLibrary](https://github.com/alexandruchirita4192/DotNetTestLibrary) project using Visual Studio and resulting the `DotNetLibrary.dll`
  - Copying `DotNetLibrary.dll` to `%APPDATA%\MetaQuotes\Terminal\[TerminalId]\MQL4\Indicators` and `%APPDATA%\MetaQuotes\Terminal\[TerminalId]\MQL4\Experts` folders

## Build:
- Build in Metatrader 4 Editor the following Metatrader Projects (MqProj files):
  - [MQL4/Projects/TestChangeChartGlobalVar/TestChangeChartGlobalVar.mqproj](https://github.com/alexandruchirita4192/Metatrader4ProjectsAndIncludes/blob/main/MQL4/Projects/TestChangeChartGlobalVar/TestChangeChartGlobalVar.mqproj) - Indicator required for changing charts
  - [MQ4/Projects/SystemConsole/SystemConsole.mqproj](https://github.com/alexandruchirita4192/Metatrader4ProjectsAndIncludes/blob/main/MQL4/Projects/SystemConsole/SystemConsole.mqproj) - The most used custom indicator created (incomplete)
  - [MQ4/Projects/SystemConsole/SystemProcessor.mqproj](https://github.com/alexandruchirita4192/Metatrader4ProjectsAndIncludes/blob/main/MQL4/Projects/SystemConsole/SystemProcessor.mqproj) - The most used expert created
  - Any other project or mq4 file in [MQ4/Projects](https://github.com/alexandruchirita4192/Metatrader4ProjectsAndIncludes/tree/main/MQL4/Projects)

## Deploy:
- For deploying `TestChangeChartGlobalVar` project:
  - Change the [MQL4/Projects/TestChangeChartGlobalVar/Deploy.cmd](https://github.com/alexandruchirita4192/Metatrader4ProjectsAndIncludes/blob/main/MQL4/Projects/TestChangeChartGlobalVar/Deploy.cmd) file with the proper `TerminalDir` for your Metatrader 4 installation.
  - Run the [MQL4/Projects/TestChangeChartGlobalVar/Deploy.cmd](https://github.com/alexandruchirita4192/Metatrader4ProjectsAndIncludes/blob/main/MQL4/Projects/TestChangeChartGlobalVar/Deploy.cmd) file to copy the compiled `TestChangeChartGlobalVar.ex4` to the Indicators folder

- For deploying `SystemConsole` and `SystemProcessor` projects:
  - Change the [MQL4/Projects/SystemConsole/Deploy.cmd](https://github.com/alexandruchirita4192/Metatrader4ProjectsAndIncludes/blob/main/MQL4/Projects/SystemConsole/Deploy.cmd) file with the proper `TerminalDir` for your Metatrader 4 installation.
  - Run the [MQL4/Projects/SystemConsole/Deploy.cmd](https://github.com/alexandruchirita4192/Metatrader4ProjectsAndIncludes/blob/main/MQL4/Projects/SystemConsole/Deploy.cmd) file to copy the compiled files to the proper folders (copy `SystemConsole.ex4` to `Indicators` folder and `SystemProcessor.ex4` to `Experts` folder)
- For other projects or mq4 files in [MQ4/Projects](https://github.com/alexandruchirita4192/Metatrader4ProjectsAndIncludes/tree/main/MQL4/Projects):
  - You need to copy the compiled file manually to the `Indicators` folder or `Exports` folder depending on the project type or mq4 file type.

## Note:
- The precompiled dll DotNetTestLibrary.dll is added in "Experts" and "Indicators" folders but can be compiled manually using the [DotNetTestLibrary project]( https://github.com/alexandruchirita4192/DotNetTestLibrary).
