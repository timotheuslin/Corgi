#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Icons\Corgi6.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Fileversion=0.9.0.0
#AutoIt3Wrapper_Res_Icon_Add=Icons\Burn.ico
#AutoIt3Wrapper_Res_Icon_Add=Icons\Refresh.ico
#AutoIt3Wrapper_Res_Icon_Add=Icons\Recycle.ico
#AutoIt3Wrapper_Res_Icon_Add=Icons\Pause.ico
#AutoIt3Wrapper_Res_Icon_Add=Icons\Play.ico
#AutoIt3Wrapper_Res_Icon_Add=Icons\Cancel.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****




#cs ----------------------------------------------------------------------------
	
	AutoIt Version: 3.3.1.1 beta (minimal required version)
	Author:         timothy
	
	Script Function:
	Template AutoIt script.
	
#ce ----------------------------------------------------------------------------

;
; TODO: status bar - refine !!! StatusBar_SetText($TaskName[1] & " - Build") ...
;
;

;#RequireAdmin              ; Windows7

;Opt("MustDeclareVars", 1)      ;0=no, 1=require pre-declare
Opt("GUIOnEventMode", 1) ;0=disabled, 1=OnEvent mode enabled
Opt("GUIResizeMode", 802) ;0=no resizing, <1024 special resizing
Opt("GUICloseOnESC", 0) ;1=ESC  closes, 0=ESC won't close
Opt("TrayIconHide", 1) ;0=show, 1=hide tray icon

AutoItSetOption("ExpandEnvStrings", 0)

Global $CorgiRevision = "0.9.0.0"
Global $MainForm = 0
Global $GlobalPauseFlag = False
Global $DebugMode = False
Global $ViewBatchFile = False


#include <Constants.au3>
#include <Misc.au3>
#include <File.au3>
#include <GuiButton.au3>
#include <WindowsConstants.au3>
#include <GuiEdit.au3>
#include <GuiComboBox.au3>
#include <FolderJanitor.au3>
#include <Date.au3>


;Func OnAutoItExit ( )
;   _Exit()
;EndFunc

; Const strings - start

Const $ConfigIni = "corgi.ini"

Const $GlobalSectionString = "Global"
Const $TaskIdString = "TaskId"
Const $BentonString = "Benton"
Const $PpmNameString = "PpmName"
Const $PpmsVersionString = "PpmsVersion"
Const $SampleVclString = "SampleVcl"
Const $EnvVarsString = "EnvVars"
Const $LeadingCmdsString = "LeadingCommands"

Const $CleanString = "Clean"
Const $RebuildString = "Rebuild"
Const $BuildString = "Build"
Const $ResumeString = "Resume"
Const $PauseString = "Pause"
Const $HelpString = "Help"

Const $MenuActionBuildString = "&Build"
Const $MenuActionRebuildString = "&Rebuild"
Const $MenuActionCleanString = "&Clean"
Const $MenuActionPauseString = "&Pause"
Const $MenuActionResumeString = "R&esume"
Const $MenuActionStopString = "&Stop"

Const $ExternalEditorString = "ExternalEditor"

Const $CRLFx2 = @CRLF & @CRLF

Const $ConsoleDoneString = "=============== Done ==============="
Const $ConsoleBuildString = "============= Building ============="
Const $ConsoleCleanUpString = "============= Cleaning ============="
Const $ConsoleRebuildString = "============ Rebuilding ============"
Const $ConsoleCancelString = "============= Canceled ============="
Const $ConsoleHelpString = "============ Help/Usage ============"
Const $ConsoleQkBuildString = "======== Quick Build Start ========="
Const $ConsoleGetCodeString = "========== Getting Code ============"
Const $ConsoleQkGetCodeString = "======= Quick Getting Code ========="
Const $ConsoleScript2EditorString = "== Script has been sent to Editor =="

Global $GlobalIni = @ScriptDir & "\" & $ConfigIni
Global $OriginalGlobalIni = $GlobalIni

Global $CorgiHomePath = @AppDataDir & "\Corgi"
Global $HomeIni = $CorgiHomePath & "\corgi.ini"

Global $CorgiTempDir = @TempDir & "\Corgi"

Global $OverrideConfigFileToken = False

Global $GlobalCorgiIsBusy = False
Global $TaskCommand = ""

Global $TimerElapsedTime = 0

Global $LogFileHandle = 0

; Const strings - end


; Global INI data - start

Enum $Enum_GlobalTask_RioVerde = 2, _
		$Enum_GlobalTask_Sct2 = 0, _
		$Enum_GlobalTask_Benton2 = 3, _
		$Enum_GlobalTask_Legacy = 4, _
		$Enum_GlobalTask_GetLegacy = 5, _
		$Enum_GlobalTask_Sct2_DB = 1

Global $GlobalTaskAmount = 6
Global $GlobalTaskId
Global $GlobalTaskSectionName[$GlobalTaskAmount]

$GlobalTaskSectionName[$Enum_GlobalTask_Sct2] = "Sct - Build"
$GlobalTaskSectionName[$Enum_GlobalTask_Sct2_DB] = "Sct - Driver Build"
$GlobalTaskSectionName[$Enum_GlobalTask_RioVerde] = "RioVerde - Build"
$GlobalTaskSectionName[$Enum_GlobalTask_Benton2] = "Benton2 - Build"
$GlobalTaskSectionName[$Enum_GlobalTask_Legacy] = "Legacy - Build"
$GlobalTaskSectionName[$Enum_GlobalTask_GetLegacy] = "Legacy - Get"

Const $CorgiEditorDefault = "c:\windows\system32\notepad.exe"
Global $CorgiEditor = $CorgiEditorDefault



; Global INI data - end

; Global misc data - start

; Ipc Command that clears console
Global $CmdClearScreen = "::{FE8B1CD6-AAB2-464c-B93A-8834711F6FD7}::"
Global $CmdClearScreen_IpcKey = ""
Global $IpcKey = ""
; Global misc data - end


#include "CoProc.au3"       ; multithread (false simulation)
#include "Batch.au3"
#include "Common.au3"
#include "ChildProc.au3"
#include "cp.au3"           ; childprocess



;MultiTasking - start
$TypeLib = ObjCreate("Scriptlet.TypeLib")
$IpcKey = $TypeLib.Guid
$CmdClearScreen_IpcKey = $CmdClearScreen & "_" & $IpcKey
EnvSet("IpcKey", $IpcKey)
_CoProcReceiver("ParentReceiver")
;MultiTasking - end


;GUI - start

#include "WildButtonForm.au3"
#include "MainForm.au3"
#include "MainFormMenu.au3"
#include "MainFormHandlers.au3"
#include "WildButton.au3"

Local $ComboTask_List = $GlobalTaskSectionName[0]
For $i = 1 To $GlobalTaskAmount - 1
	$ComboTask_List &= "|" & $GlobalTaskSectionName[$i]
Next

GUICtrlSetData($ComboTask, $ComboTask_List)

Local $DummyControlForExit = GUICtrlCreateDummy()
GUICtrlSetOnEvent($DummyControlForExit, "_Exit")
Local $DummyControlForF7 = GUICtrlCreateDummy()
GUICtrlSetOnEvent($DummyControlForF7, "F7KeyFunc")
HotKeySet("{F7}")
HotKeySet("!x")
HotKeySet("{F10}")
HotKeySet("!{F4}")
Global $HotkeyFuncList[5][2] = [ _
		["{F7}", $DummyControlForF7], _
		["{Pause}", $ButtonPause], _
		["!x", $DummyControlForExit], _
		["{F10}", $DummyControlForExit], _
		["!{F4}", $DummyControlForExit] _
		]
GUISetAccelerators($HotkeyFuncList, $MainForm)

GUICtrlSetState($Group1, $GUI_DROPACCEPTED)
GUICtrlSetState($Group2, $GUI_DROPACCEPTED)
GUICtrlSetState($Group3, $GUI_DROPACCEPTED)

;GUI - end

#include "Timer.au3"    ; should exist after mainform is initialized

;
; insert code-base handler module  - start
;
#include "RioVerde.au3"
#include "LegacyBios.au3"
#include "SCT2.au3"
#include "Sct2Db.au3"
#include "Benton2.au3"
#include "GetLegacy.au3"

#include "TaskTable.au3"

;
; insert code-base handler module  - end
;


MainFormResize(0)

GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
GUISetOnEvent($GUI_EVENT_DROPPED, "_DropFile")

;
; Select a Local ini file or a home-path ini file
;

Local $UseHomeSetting = True
If FileExists($OriginalGlobalIni) Then
	$UseHomeSetting = IniRead($OriginalGlobalIni, $GlobalSectionString, $OriginalGlobalIni, False)
Else
	$UseHomeSetting = True
EndIf

If $UseHomeSetting Then
	$GlobalIni = $HomeIni
	If Not FileExists($CorgiHomePath) Then
		DirCreate($CorgiHomePath) ; TODO: should we ignore error silently?
	EndIf
EndIf

Local $TaskId = IniRead($GlobalIni, $GlobalSectionString, $TaskIdString, 0)
$GlobalTaskId = $TaskId


MainForm_Init()

;
; Clean up the mess in the private temporary folder
;

FolderJanitor(@TempDir & "\Corgi\", "*.log", 100)
FolderJanitor(@TempDir & "\Corgi\", "*.bat", 100)
FolderJanitor(@TempDir & "\Corgi\", "*.ini", 100)

While 1
	Sleep(17)
	;$msg = GUIGetMsg()
	;If $msg == $GUI_EVENT_CLOSE Then ExitLoop
WEnd

_Exit()


;----------------------------------------------------------------------------

Func _Exit()
	CoProcess_Stop(True)
	IniUpdateAll()
	Exit
EndFunc   ;==>_Exit

Func _DropFile()
	If @GUI_DragFile <> "" Then
		__ImportConfigFile(@GUI_DragFile)
	EndIf
EndFunc   ;==>_DropFile

Func __ImportConfigFile($INI)

	Local $TaskId = IniRead($INI, $GlobalSectionString, $TaskIdString, -1)
	If $TaskId == -1 Then
		MsgBox(48, "Ouch", "Not a Config File: " & $INI)
		Return
	EndIf

	IniUpdateAll()

	$GlobalTaskId = $TaskId

	MainForm_Init($INI, $TaskId)

	Local $szDrive, $szDir, $szFName, $szExt
	_PathSplit($INI, $szDrive, $szDir, $szFName, $szExt)
	Local $TitleX = WinGetTitle($MainForm) & " (" & $szFName & $szExt & ")"
	WinSetTitle($MainForm, "", $TitleX)

EndFunc   ;==>__ImportConfigFile


Func MainForm_Init($INI = $GlobalIni, $TaskId = -1)

	GUICtrlSetOnEvent($ComboTask, "ComboTaskFunc")
	GUICtrlSetOnEvent($ButtonStart, "ButtonStartFunc")
	GUICtrlSetOnEvent($ButtonPause, "ButtonPauseFunc")
	GUICtrlSetOnEvent($ButtonStop, "ButtonStopFunc")
	GUICtrlSetOnEvent($ButtonCleanUp, "ButtonCleanUpFunc")
	GUICtrlSetOnEvent($ButtonRebuild, "ButtonRebuildFunc")

	If $TaskId == -1 Then
		$TaskId = IniRead($INI, $GlobalSectionString, $TaskIdString, 0)
	EndIf

	$CorgiEditor = IniRead($INI, $GlobalSectionString, $ExternalEditorString, $CorgiEditorDefault)
	If Not FileExists($CorgiEditor) Then
		$CorgiEditor = $CorgiEditorDefault
	EndIf

	BW_INIT($INI)
	BW_Load($INI, $TaskId)

	Local $TaskCaption
	_GUICtrlComboBox_SetCurSel($ComboTask, $GlobalTaskId)
	_GUICtrlComboBox_GetLBText($ComboTask, $GlobalTaskId, $TaskCaption)

	WinSetTitle($MainForm, "", "Corgi : " & $TaskCaption)

	Console_Init($INI)

	Call($TtMfInit[$TaskId], $INI)
EndFunc   ;==>MainForm_Init


Func IniUpdateAll($INI = $GlobalIni)
	AutoItSetOption("ExpandEnvStrings", 0) ; 0.7d

	Call($TtIniUpdata[$GlobalTaskId], $INI)

	BW_IniUpdate($INI)
	Console_IniUpdate($INI)

	IniUpdate($INI, $GlobalSectionString, $TaskIdString, $GlobalTaskId)
	IniUpdate($INI, $GlobalSectionString, $ExternalEditorString, $CorgiEditor)

EndFunc   ;==>IniUpdateAll


Func F7KeyFunc()
	If (BitAND(GUICtrlGetState($ButtonStart), $GUI_ENABLE)) Then
		ButtonStartFunc()
	Else
		ButtonPauseFunc()
	EndIf

EndFunc   ;==>F7KeyFunc

Func StartCleanUpRebuildCommon($cmd)

	$TaskCommand = $cmd

	TConsoleCleanup()
	InitBatchCommandList()

	Local $TaskName = $GlobalTaskSectionName[$GlobalTaskId]

	;Local $TaskNames = StringRegExp($TaskName, "\S+\s*-\s*(.*)", 3)
	;MsgBox(0, "", $GlobalTaskSectionName[$GlobalTaskId])
	;MsgBox(0, "", $TaskNames[0])
	;$TaskName = StringSplit($GlobalTaskSectionName[$GlobalTaskId], " - ", 1)

	;If (NOT @Error) AND IsArray($TaskNames) Then
	;   $TaskName = $TaskNames[0]
	;EndIf

	StatusBar_SetText($TaskName & " : " & $cmd)
	StatusBar_SetText("Running", 2)
	SetGlobalVariables(True)

	TConsoleWrite(DateTime_GetCurrentDateTime() & @CRLF)

	Local $CmdList = Call($TtScrTasks[$GlobalTaskId], $cmd)
	If (Not IsArray($CmdList)) Or ($CmdList[0] == 0) Then
		Return
	EndIf

	If $CmdList[1] <> "" Then
		TConsoleWrite($CmdList[1])
	EndIf
	CoProcess_Execution($CmdList[2], $CmdList[3])
EndFunc   ;==>StartCleanUpRebuildCommon

;
; "Build"
;

Func ButtonStartFunc()

	If (BitAND(GUICtrlGetState($ButtonStart), $GUI_ENABLE) == 0) Then
		Return
	EndIf
	StartCleanUpRebuildCommon($BuildString)

EndFunc   ;==>ButtonStartFunc

;
; "Pause/Resume"
;

Func SetButtonPauseState($PauseFlag)
	If $PauseFlag == False Then
		$PauseFlag = True
		GUICtrlSetData($ButtonPause, $ResumeString)
		GUICtrlSetTip($ButtonPause, $ResumeString)
		StatusBar_SetText("Paused", 2)
		GUICtrlSetImage($ButtonPause, @ScriptFullPath, -9, 1) ; "play.ico"
		_GUICtrlMenu_SetItemText($hAction, $idPause, $MenuActionResumeString, False)
	Else
		$PauseFlag = False
		GUICtrlSetData($ButtonPause, $PauseString)
		GUICtrlSetTip($ButtonPause, $PauseString)
		StatusBar_SetText("Running", 2)
		GUICtrlSetImage($ButtonPause, @ScriptFullPath, -8, 1) ; "pause.ico"
		_GUICtrlMenu_SetItemText($hAction, $idPause, $MenuActionPauseString, False)
	EndIf

	Return $PauseFlag
EndFunc   ;==>SetButtonPauseState

Func ButtonPauseFunc()
	If (BitAND(GUICtrlGetState($ButtonPause), $GUI_ENABLE) == 0) Then
		Return
	EndIf

	$GlobalPauseFlag = SetButtonPauseState($GlobalPauseFlag)

	CoProcess_Pause($GlobalPauseFlag)
	Console_SetFocus()
EndFunc   ;==>ButtonPauseFunc

;
; "Stop/Cancel"
;

Func ButtonStopFunc()
	TConsoleWrite(@CRLF & $ConsoleCancelString & $CRLFx2)
	CoProcess_Stop()
	StatusBar_SetText("Idle", 2)
	Console_SetFocus()
	SetButtonPauseState(True)
EndFunc   ;==>ButtonStopFunc

;
; "Clean"
;

Func ButtonCleanUpFunc()
	If (BitAND(GUICtrlGetState($ButtonCleanUp), $GUI_ENABLE) == 0) Then
		Return
	EndIf
	StartCleanUpRebuildCommon($CleanString)
EndFunc   ;==>ButtonCleanUpFunc

;
; "Rebuild"
;

Func ButtonRebuildFunc()
	If (BitAND(GUICtrlGetState($ButtonRebuild), $GUI_ENABLE) == 0) Then
		Return
	EndIf
	StartCleanUpRebuildCommon($RebuildString)
EndFunc   ;==>ButtonRebuildFunc

;
; Task selection
;

Func ComboTaskFunc()
	Local $TaskId = _GUICtrlComboBox_GetCurSel($ComboTask)

	If $GlobalTaskId <> $TaskId Then
		IniUpdateAll()
		$GlobalTaskId = $TaskId
		MainForm_Init($GlobalIni, $TaskId)
	EndIf
EndFunc   ;==>ComboTaskFunc


Func SetGlobalVariables($WarningOnMissedPath = False)
	AutoItSetOption("ExpandEnvStrings", 1)

	Call($TtSetVar[$GlobalTaskId], False)

	Local $EnvVars = GUICtrlRead($Edit1)
	TEnvSet($EnvVars)

	AutoItSetOption("ExpandEnvStrings", 0)

EndFunc   ;==>SetGlobalVariables