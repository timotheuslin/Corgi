
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.1.1 (beta)
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#include-once
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include "Resources.au3"

#Region ### START Koda GUI section ### Form=D:\studio0\Autoit\Corgi\About.kxf
$AboutForm1 = GUICreate("About Corgi", 215, 455, -1, -1, BitOR($WS_SIZEBOX,$WS_THICKFRAME,$WS_SYSMENU), -1)
GUISetBkColor(0xFFFFFF)
GUICtrlCreateGroup("", 4, 0, 205, 377)
$AboutPic1 = GUICtrlCreatePic("", 16, 16, 182, 200)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$AboutLabel2 = GUICtrlCreateLabel("Original Idea: Simon Yang", 12, 260, 179, 16)
GUICtrlSetFont(-1, 9, 400, 0, "Lucida Console")
$AboutLabel3 = GUICtrlCreateLabel("GUI Design: Timothy Lin", 12, 288, 165, 16)
GUICtrlSetFont(-1, 9, 400, 0, "Lucida Console")
$AboutLabel4 = GUICtrlCreateLabel("Consultant: Denise Chien, Harrison Hsieh", 12, 316, 186, 16)
GUICtrlSetFont(-1, 9, 400, 0, "Lucida Console")
$AboutLabel5 = GUICtrlCreateLabel("@Phoenix, 2009-2018", 12, 344, 180, 16)
GUICtrlSetFont(-1, 9, 400, 0, "Lucida Console")
$AboutLabel1 = GUICtrlCreateLabel("- Version " & $CorgiRevision, 50, 232, 150, 16)
GUICtrlSetFont(-1, 9, 400, 0, "Lucida Console")
$AboutPic2 = GUICtrlCreatePic("", 12, 230, 43, 15)
;GUICtrlCreateGroup("", -99, -99, 1, 1)
$AboutButton1 = GUICtrlCreateButton("&OK", 134, 392, 75, 25)
;GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

;GUICtrlSetImage($AboutPic1,	@ScriptFullPath, 201, 1)
;GUICtrlSetImage($AboutPic2,	@ScriptFullPath, 201, 1)

GUICtrlSetOnEvent($AboutButton1,		"AboutButton1Func")

Func AboutButton1Func()
	GUISetState(@SW_HIDE, $AboutForm1)
EndFunc
