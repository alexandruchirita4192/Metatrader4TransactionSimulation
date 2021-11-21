# Metatrader 4 indicators (`TestChangeChartGlobalVar`, `SystemConsole`) and experts (`SystemProcessor`) used to simulate transactions on history to check if some decisions are reliable
Some custom Metatrader 4 libraries along with some custom Metatrader 4 projects (the projects are still a work in progress, not finished yet)

## Known issues:
- Profit calculation has some issues and sometimes doesn't calculate profit properly. Please note that the formula used is confirmed by some broker, but the result is still unreliable (and I couldn't find a way to make it work better).

## Requirements:
- Install the latest Metatrader 4 from a broker and check `%APPDATA%\MetaQuotes\Terminal\[TerminalId]` to get the `[TerminalId]` for your Metatrader 4 installation.

## Installation:
The [MQL4](https://github.com/alexandruchirita4192/Metatrader4ProjectsAndIncludes/tree/main/MQL4) folder can be copied on your `%APPDATA%\MetaQuotes\Terminal\[TerminalId]\MQL4` folder.

## Build:
Build in Metatrader 4 Editor the following Metatrader Projects (MqProj files):
- [MQL4/Projects/TestChangeChartGlobalVar/TestChangeChartGlobalVar.mqproj](https://github.com/alexandruchirita4192/Metatrader4ProjectsAndIncludes/blob/main/MQL4/Projects/TestChangeChartGlobalVar/TestChangeChartGlobalVar.mqproj) - Indicator required for changing charts
- [MQ4/Projects/SystemConsole/SystemConsole.mqproj](https://github.com/alexandruchirita4192/Metatrader4ProjectsAndIncludes/blob/main/MQL4/Projects/SystemConsole/SystemConsole.mqproj) - The most used custom indicator created (incomplete)
- [MQ4/Projects/SystemConsole/SystemProcessor.mqproj](https://github.com/alexandruchirita4192/Metatrader4ProjectsAndIncludes/blob/main/MQL4/Projects/SystemConsole/SystemProcessor.mqproj) - The most used expert created
- Any other project or mq4 file in [MQ4/Projects](https://github.com/alexandruchirita4192/Metatrader4ProjectsAndIncludes/tree/main/MQL4/Projects)

## Deploy (automatically for the most used projects; manually for others):
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
