@echo off

rem Setup the Metatrader 4 terminal directory
set TerminalDir=2E8DC23981084565FA3E19C061F586B2

copy *.ex4 %APPDATA%\MetaQuotes\Terminal\%TerminalDir%\MQL4\Experts
copy TestSimulateTranSystemIndicatorOneSymbol.ex4 %APPDATA%\MetaQuotes\Terminal\%TerminalDir%\MQL4\Indicators

pause