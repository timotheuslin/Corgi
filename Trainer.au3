#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Icons\Play.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.1.1 (beta)
 Author:         Timothy Lin, 2010/9

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

$WinDesc = "[Title:Corgi : Sct2 - Build; Class:AutoIt v3 GUI]"

While 1
	WinActivate ($WinDesc)
	Send("!a")
	Sleep(20)
	Send("r")
	
	;
	; Todo: wait until the "status-bar" of Corgi shows "Idle"
	;
	
	Sleep(1000*15)
	
WEnd


