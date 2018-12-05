#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiStatusBar.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#Region ### START Koda GUI section ### Form=mainform.kxf
;$MainForm = GUICreate("", 1009, 633, -1, -1, BitOR($GUI_SS_DEFAULT_GUI,$WS_MAXIMIZEBOX,$WS_TABSTOP), BitOR($WS_EX_ACCEPTFILES,$WS_EX_WINDOWEDGE))
$MainForm = GUICreate("", 1009, 633, -1, -1, BitOR($WS_SIZEBOX, $WS_MAXIMIZEBOX, $WS_MINIMIZEBOX, $WS_SYSMENU, $WS_CAPTION, $WS_POPUP, $WS_POPUPWINDOW, $WS_GROUP, $WS_TABSTOP, $WS_BORDER, $WS_CLIPSIBLINGS), BitOR($WS_EX_ACCEPTFILES, $WS_EX_WINDOWEDGE))
$Group1 = GUICtrlCreateGroup("Tips", 312, 0, 481, 150)
$Input2 = GUICtrlCreateInput("", 400, 24, 388, 21, $GUI_SS_DEFAULT_INPUT)
$Input3 = GUICtrlCreateInput("", 400, 48, 388, 21, $GUI_SS_DEFAULT_INPUT)
$Input4 = GUICtrlCreateInput("", 400, 72, 388, 21, $GUI_SS_DEFAULT_INPUT)
$Input5 = GUICtrlCreateInput("", 400, 96, 388, 21, $GUI_SS_DEFAULT_INPUT)
$Button2 = GUICtrlCreateButton("NUBIOS", 320, 24, 75, 22, $BS_NOTIFY)
$Button3 = GUICtrlCreateButton("OEM_TIP", 320, 48, 75, 22, $BS_NOTIFY)
$Button4 = GUICtrlCreateButton("EFI_SOURCE", 320, 72, 75, 22, $BS_NOTIFY)
$Button5 = GUICtrlCreateButton("BUILD_TIP", 320, 96, 75, 22, $BS_NOTIFY)
$Button1 = GUICtrlCreateButton("SERVER_TIP", 320, 120, 75, 22, $BS_NOTIFY)
$Input1 = GUICtrlCreateInput("", 400, 120, 266, 21, $GUI_SS_DEFAULT_INPUT)
$Label1 = GUICtrlCreateLabel("Version:", 684, 120, 42, 17, 0)
$Input6 = GUICtrlCreateInput("", 736, 120, 52, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group2 = GUICtrlCreateGroup("Additional Environment Variables", 796, 0, 208, 150)
$Edit1 = GUICtrlCreateEdit("", 798, 15, 204, 133, BitOR($ES_AUTOVSCROLL,$ES_AUTOHSCROLL,$ES_WANTRETURN), 0)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group3 = GUICtrlCreateGroup("Actions", 4, 0, 297, 150)
$ButtonStart = GUICtrlCreateButton("Build", 10, 68, 34, 34)
GUICtrlSetTip(-1, "Build")
$ButtonPause = GUICtrlCreateButton("Pause", 48, 68, 34, 34)
GUICtrlSetTip(-1, "Pause")
$ButtonStop = GUICtrlCreateButton("Stop", 86, 68, 34, 34)
GUICtrlSetTip(-1, "Stop")
$ButtonCleanUp = GUICtrlCreateButton("Clean", 10, 108, 34, 34)
GUICtrlSetTip(-1, "Clean")
$ButtonWild = GUICtrlCreateButton("Wild", 126, 16, 80, 22, $BS_NOTIFY)
$ButtonWild2 = GUICtrlCreateButton("Wild2", 126, 42, 80, 22, $BS_NOTIFY)
$ComboTask = GUICtrlCreateCombo("", 10, 16, 108, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetTip(-1, "CodeBase")
$ButtonWild3 = GUICtrlCreateButton("Wild3", 126, 68, 80, 22, $BS_NOTIFY)
$ButtonWild4 = GUICtrlCreateButton("Wild4", 126, 94, 80, 22, $BS_NOTIFY)
$ButtonWild5 = GUICtrlCreateButton("Wild5", 126, 120, 80, 22, $BS_NOTIFY)
$ButtonWild6 = GUICtrlCreateButton("Wild6", 214, 16, 80, 22, $BS_NOTIFY)
$ButtonWild7 = GUICtrlCreateButton("Wild7", 214, 42, 80, 22, $BS_NOTIFY)
$ButtonWild8 = GUICtrlCreateButton("Wild8", 214, 68, 80, 22, $BS_NOTIFY)
$ButtonWild9 = GUICtrlCreateButton("Wild9", 214, 94, 80, 22, $BS_NOTIFY)
$ButtonWildA = GUICtrlCreateButton("WildA", 214, 120, 80, 22, $BS_NOTIFY)
$ButtonRebuild = GUICtrlCreateButton("Rebuild", 48, 108, 34, 34)
GUICtrlSetTip(-1, "Rebuild")
$ComboToolChain = GUICtrlCreateCombo("", 10, 42, 108, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetTip(-1, "ToolChain")
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group4 = GUICtrlCreateGroup("", 4, 150, 1000, 460)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP)
$Edit3 = GUICtrlCreateEdit("", 6, 165, 996, 443, BitOR($GUI_SS_DEFAULT_EDIT,$ES_READONLY), 0)
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
