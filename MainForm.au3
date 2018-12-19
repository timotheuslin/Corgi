#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiStatusBar.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#Region ### START Koda GUI section ### Form=mainform.kxf
$MainForm = GUICreate("", 1009, 633, -1, -1, BitOR($GUI_SS_DEFAULT_GUI,$WS_MAXIMIZEBOX,$WS_TABSTOP), BitOR($WS_EX_ACCEPTFILES,$WS_EX_WINDOWEDGE))
$Group1 = GUICtrlCreateGroup("", 120, 0, 497, 150)
$Input2 = GUICtrlCreateInput("", 208, 12, 402, 24, $GUI_SS_DEFAULT_INPUT)
$Input3 = GUICtrlCreateInput("", 208, 39, 402, 24, $GUI_SS_DEFAULT_INPUT)
$Input4 = GUICtrlCreateInput("", 208, 66, 402, 24, $GUI_SS_DEFAULT_INPUT)
$Input5 = GUICtrlCreateInput("", 208, 93, 402, 24, $GUI_SS_DEFAULT_INPUT)
$Button2 = GUICtrlCreateButton("NUBIOS", 124, 12, 80, 25, $BS_NOTIFY)
$Button3 = GUICtrlCreateButton("OEM_TIP", 124, 39, 80, 25, $BS_NOTIFY)
$Button4 = GUICtrlCreateButton("EFI_SOURCE", 124, 66, 80, 25, $BS_NOTIFY)
$Button5 = GUICtrlCreateButton("BUILD_TIP", 124, 93, 80, 25, $BS_NOTIFY)
$Button1 = GUICtrlCreateButton("SERVER_TIP", 124, 120, 80, 22, $BS_NOTIFY)
$Input1 = GUICtrlCreateInput("", 208, 120, 300, 24, $GUI_SS_DEFAULT_INPUT)
$Label1 = GUICtrlCreateLabel("Version:", 517, 124, 42, 24, 0)
$Input6 = GUICtrlCreateInput("", 558, 120, 52, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group2 = GUICtrlCreateGroup("Environment Settings", 620, 0, 208, 150)
$Edit1 = GUICtrlCreateEdit("", 622, 15, 204, 133, BitOR($ES_AUTOVSCROLL,$ES_AUTOHSCROLL,$ES_WANTRETURN), 0)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group5 = GUICtrlCreateGroup("", 830, 0, 174, 150)
$ButtonWild = GUICtrlCreateButton("Wild", 834, 12, 80, 25, $BS_NOTIFY)
$ButtonWild2 = GUICtrlCreateButton("Wild2", 834, 39, 80, 25, $BS_NOTIFY)
$ButtonWild3 = GUICtrlCreateButton("Wild3", 834, 66, 80, 25, $BS_NOTIFY)
$ButtonWild4 = GUICtrlCreateButton("Wild4", 834, 93, 80, 25, $BS_NOTIFY)
$ButtonWild5 = GUICtrlCreateButton("Wild5", 834, 120, 80, 25, $BS_NOTIFY)
$ButtonWild6 = GUICtrlCreateButton("Wild6", 918, 12, 80, 25, $BS_NOTIFY)
$ButtonWild7 = GUICtrlCreateButton("Wild7", 918, 39, 80, 25, $BS_NOTIFY)
$ButtonWild8 = GUICtrlCreateButton("Wild8", 918, 66, 80, 25, $BS_NOTIFY)
$ButtonWild9 = GUICtrlCreateButton("Wild9", 918, 93, 80, 25, $BS_NOTIFY)
$ButtonWildA = GUICtrlCreateButton("WildA", 918, 120, 80, 25, $BS_NOTIFY)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group3 = GUICtrlCreateGroup("", 2, 0, 118, 150)
$ButtonStart = GUICtrlCreateButton("Build", 6, 68, 34, 34)
GUICtrlSetTip(-1, "Build")
$ButtonPause = GUICtrlCreateButton("Pause", 44, 68, 34, 34)
GUICtrlSetTip(-1, "Pause")
$ButtonStop = GUICtrlCreateButton("Stop", 80, 68, 34, 34)
GUICtrlSetTip(-1, "Stop")
$ButtonCleanUp = GUICtrlCreateButton("Clean", 6, 108, 34, 34)
GUICtrlSetTip(-1, "Clean")
$ComboTask = GUICtrlCreateCombo("", 6, 12, 108, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetTip(-1, "CodeBase")
$ButtonRebuild = GUICtrlCreateButton("Rebuild", 44, 108, 34, 34)
GUICtrlSetTip(-1, "Rebuild")
$ComboToolChain = GUICtrlCreateCombo("", 6, 40, 108, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetTip(-1, "ToolChain")
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group4 = GUICtrlCreateGroup("", 2, 150, 1002, 460)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP)
$Edit3 = GUICtrlCreateEdit("", 4, 165, 998, 443, BitOR($GUI_SS_DEFAULT_EDIT,$ES_READONLY), 0)
GUICtrlSetFont(-1, 12, 400, 0, "Lucida Console")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x000000)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKBOTTOM)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$StatusBar1 = _GUICtrlStatusBar_Create($MainForm)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

;While 1
;$nMsg = GUIGetMsg()
;Switch $nMsg
;Case $GUI_EVENT_CLOSE
;Exit
;
;EndSwitch
;WEnd
