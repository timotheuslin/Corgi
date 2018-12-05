#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.2.12.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

#include-once

Const	$RioVerdeString		= $GlobalTaskSectionName[$Enum_GlobalTask_RioVerde]
Const	$EfiSourceString	= "EfiSource"
Const	$BuildTipString		= "BuildTip" 


Func RioVerde_Init($INI=$GlobalIni)
	GUICtrlSetState($Button1, $GUI_DISABLE)
	GUICtrlSetState($Button2, $GUI_DISABLE)
	GUICtrlSetState($Button3, $GUI_DISABLE)

	GUICtrlSetState($Button4, $GUI_ENABLE)
	GUICtrlSetState($Button5, $GUI_ENABLE)
	_GUICtrlButton_SetText($Button4, "EFI_SOURCE")
	_GUICtrlButton_SetText($Button5, "BUILD_TIP")

	GUICtrlSetState($Input1, $GUI_DISABLE)
	GUICtrlSetState($Input2, $GUI_DISABLE)
	GUICtrlSetState($Input3, $GUI_DISABLE)
	GUICtrlSetState($Input4, $GUI_ENABLE+$GUI_FOCUS)
	GUICtrlSetState($Input5, $GUI_ENABLE)
	GUICtrlSetState($Input6, $GUI_DISABLE)
	GUICtrlSetState($Label1, $GUI_DISABLE)
	
	GUICtrlSetState($ButtonStart, $GUI_ENABLE)
	GUICtrlSetState($ButtonRebuild, $GUI_ENABLE)
	GUICtrlSetState($ButtonCleanUp, $GUI_ENABLE)
	_GUICtrlButton_SetText($ButtonStart, "Build")
	_GUICtrlButton_SetText($ButtonRebuild, "Rebuild")
	_GUICtrlButton_SetText($ButtonCleanUp, "Clean")
	
	TRunningState(False)
	
	;GUICtrlSetState($Label3, $GUI_DISABLE)
	;GUICtrlSetState($Edit2, $GUI_DISABLE)
	
	Local $EfiSource	= IniRead($INI, $RioVerdeString, $EfiSourceString, "")
	Local $BuildTip		= IniRead($INI, $RioVerdeString, $BuildTipString, "")
	Local $EnvVarsX		= IniRead($INI, $RioVerdeString, $EnvVarsString, "")
	Local $LeadingCmds	= IniRead($INI, $RioVerdeString, $LeadingCmdsString, "")

	If $EnvVarsX <> "" Then
		$EnvVarsX 		= BinaryToString("0x" & $EnvVarsX)
	EndIf
	$LeadingCmds		= BinaryToString("0x" & $LeadingCmds)

	_GUICtrlEdit_SetText($Input4, $EfiSource)
	_GUICtrlEdit_SetText($Input5, $BuildTip)
	_GUICtrlEdit_SetText($Edit1, $EnvVarsX)
	
;
;Timothy: Beware, these GUICtrlSetData() causes Menu's behavior bizarre: After selecting any menu item, program exits unconditionally.
;	GUICtrlSetData($Input4, $EfiSource)
;	GUICtrlSetData($Input5, $BuildTip)
;	GUICtrlSetData($Edit1, $EnvVars)
;	GUICtrlSetData($Edit2, $LeadingCmds)

	GUICtrlSetOnEvent($Button4,	"Button4SetEfiSource")
	GUICtrlSetOnEvent($Button5,	"Button5SetBuildTip")
EndFunc


Func RioVerde_SetVariables($WarningOnMissedPath=False)

	Local $EfiSource	= Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input4), 1+2))
	Local $BuildTip		= Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input5), 1+2))

	TEnvAdd("EFI_SOURCE", 	$EfiSource)
	TEnvadd("BUILD_TIP", 	$BuildTip)
	
	Local $BuildTip0	= StringReplace($BuildTip, $EfiSource, "")
	If $BuildTip0 <> "" Then
		TEnvAdd("BUILD_TIP0", $BuildTip0)
	EndIf
	
	If $WarningOnMissedPath Then
		If Not FileExists($EfiSource) Then MsgBox(48, "Ouch", "EFI_SOUCE : " & $EfiSource &" does not exist!")
		If Not FileExists($BuildTip) Then MsgBox(48, "Ouch", "BUILD_TIP: " & $BuildTip & " does not exist!")
	EndIf

EndFunc

Func RioVerde_Build($Arg="", $ExtParams="")

	;TODO: Adapt VS2003 and VS2008 as option flag
	Local $RioVerdeBuildCmd = 'build.bat -config "X64|VS2005|GreenHV1"'
	
 	Local $BuildTip		= Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input5), 1+2))
	Local $ConsoleMsg	= ""
	
	If StringCompare($Arg, $BuildString, 0) == 0 Then
		$ConsoleMsg &= @CRLF & $ConsoleBuildString & $CRLFx2
		AppendExecCommand($RioVerdeBuildCmd)
	EndIf

	If StringCompare($Arg, $CleanString, 0) == 0 Then
		$ConsoleMsg &= @CRLF & $ConsoleCleanUpString & $CRLFx2
		AppendExecCommand($RioVerdeBuildCmd & " Clean")
	EndIf

	If StringCompare($Arg, $RebuildString, 0) == 0 Then
		$ConsoleMsg &= @CRLF & $ConsoleRebuildString & $CRLFx2

		;TODO: figure out what's the "rebuild command" for phmake
		AppendExecCommand($RioVerdeBuildCmd & " rebuild")
	EndIf

	Local $CmdList[4] = [3, $ConsoleMsg, "", $BuildTip]

	return $CmdList

EndFunc


Func RioVerde_IniUpdate($INI)
	
	Local	$NewEfiSource	= GUICtrlRead($Input4)
	Local	$NewBuildTip	= GUICtrlRead($Input5)
	Local	$NewEnvVars	= GUICtrlRead($Edit1)
	;Local	$NewLeadingCmds	= GUICtrlRead($Edit2)
	
	IniUpdate($INI, $RioVerdeString, $EfiSourceString, $NewEfiSource)
	IniUpdate($INI, $RioVerdeString, $BuildTipString, $NewBuildTip)
	IniUpdate($INI, $RioVerdeString, $EnvVarsString, $NewEnvVars, True)
;	IniUpdate($INI, $RioVerdeString, $LeadingCmdsString, $NewLeadingCmds, True)

EndFunc


Func Button4SetEfiSource()

	AutoItSetOption("ExpandEnvStrings", 1)
	Local $EfiSource	= Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input4), 1+2))
	AutoItSetOption("ExpandEnvStrings", 0)

	If _IsPressed("11") AND FileExists($EfiSource) Then 	; "11" =  Ctrl key
		ShellExecute($EfiSource)
		Return
	EndIf

	$EfiSource = FileSelectFolder("Select EFI_SOURCE Directory:", "", 2+4, $EfiSource)
	If $EfiSource <> "" Then
		_GUICtrlEdit_SetText($Input4, $EfiSource)
	EndIf
EndFunc
	
Func Button5SetBuildTip()
	AutoItSetOption("ExpandEnvStrings", 1)
	Local $BuildTip		= Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input5), 1+2))
	AutoItSetOption("ExpandEnvStrings", 0)


	If _IsPressed("11") AND FileExists($BuildTip) Then 	; "11" =  Ctrl key
		ShellExecute($BuildTip)
		Return
	EndIf

	$BuildTip = FileSelectFolder("Select BUILD_TIP Directory:", "", 2+4, $BuildTip)
	If $BuildTip <> "" Then
		_GUICtrlEdit_SetText($Input5, $BuildTip)
	EndIf
EndFunc