#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#Region ### START Koda GUI section ### Form=about.kxf
$AboutForm1 = GUICreate("About Corgi", 219, 455, 433, 193, BitOR($WS_SIZEBOX,$WS_THICKFRAME,$WS_SYSMENU))
GUISetBkColor(0xFFFFFF)
$AboutGroup1 = GUICtrlCreateGroup("", 4, 0, 210, 377)
$AboutPic1 = GUICtrlCreatePic("D:\studio0\Autoit\Corgi2\Icons\Welsh_Corgi_256x256.jpg", 16, 16, 182, 200)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$AboutLabel2 = GUICtrlCreateLabel("Original Idea: Simon Yang", 12, 252, 179, 16)
GUICtrlSetFont(-1, 9, 400, 0, "Lucida Console")
$AboutLabel3 = GUICtrlCreateLabel("GUI Design: Timothy Lin", 12, 272, 165, 16)
GUICtrlSetFont(-1, 9, 400, 0, "Lucida Console")
$AboutLabel4 = GUICtrlCreateLabel("Consultant: Harrison Hsieh", 12, 292, 186, 56)
GUICtrlSetFont(-1, 9, 400, 0, "Lucida Console")
$AboutLabel5 = GUICtrlCreateLabel("@Phoenix, May/2009", 12, 352, 130, 16)
GUICtrlSetFont(-1, 9, 400, 0, "Lucida Console")
$AboutLabel1 = GUICtrlCreateLabel("- Version 0.9.0.1", 62, 232, 123, 16)
GUICtrlSetFont(-1, 9, 400, 0, "Lucida Console")
$AboutPic2 = GUICtrlCreatePic("D:\studio0\Autoit\Corgi2\Icons\corgi.bmp", 12, 230, 43, 15)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$AboutButton1 = GUICtrlCreateButton("&OK", 134, 392, 75, 25)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit

	EndSwitch
WEnd
