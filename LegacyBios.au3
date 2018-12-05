#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.2.12.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

#include-once

;TODO: Adapt VS2003 and VS2008 as option flag
;Global $RioVerdeBuildCmd = 'build.bat -config "X64|VS2005|GreenHV1"'

Const	$LegacyBiosString 	= $GlobalTaskSectionName[$Enum_GlobalTask_Legacy]
Const	$NubiosString		= "NUBIOS"
Const	$OemTipString		= "OEM_TIP"

Func LegacyBios_Init($INI=$GlobalIni)

	GUICtrlSetState($Button1, $GUI_DISABLE)

	GUICtrlSetState($Button2, $GUI_ENABLE+$GUI_FOCUS)
	GUICtrlSetState($Button3, $GUI_ENABLE)
	_GUICtrlButton_SetText($Button2, $NubiosString)
	_GUICtrlButton_SetText($Button3, $OemTipString)

	GUICtrlSetState($Button4, $GUI_DISABLE)
	GUICtrlSetState($Button5, $GUI_DISABLE)
	

	GUICtrlSetState($Input1, $GUI_DISABLE)
	GUICtrlSetState($Input2, $GUI_ENABLE)
	GUICtrlSetState($Input3, $GUI_ENABLE)
	GUICtrlSetState($Input4, $GUI_DISABLE)
	GUICtrlSetState($Input5, $GUI_DISABLE)
	GUICtrlSetState($Input6, $GUI_DISABLE)

	GUICtrlSetState($Label1, $GUI_DISABLE)

	GUICtrlSetState($ButtonStart, $GUI_ENABLE)
	GUICtrlSetState($ButtonRebuild, $GUI_ENABLE)
	GUICtrlSetState($ButtonCleanUp, $GUI_ENABLE)
	_GUICtrlButton_SetText($ButtonStart, "Build")
	_GUICtrlButton_SetText($ButtonRebuild, "Rebuild")
	_GUICtrlButton_SetText($ButtonCleanUp, "Clean")
	
	TRunningState(False)

	Local $Nubios		= IniRead($INI, $LegacyBiosString, $NubiosString, "")
	Local $OemTip		= IniRead($INI, $LegacyBiosString, $OemTipString, "")
	Local $EnvVarsX		= IniRead($INI, $LegacyBiosString, $EnvVarsString, "")
	Local $LeadingCmds	= IniRead($INI, $LegacyBiosString, $LeadingCmdsString, "")

	If $EnvVarsX <> "" Then
		$EnvVarsX 		= BinaryToString("0x" & $EnvVarsX)
	EndIf
	$LeadingCmds		= BinaryToString("0x" & $LeadingCmds)

	_GUICtrlEdit_SetText($Input2, $Nubios)
	_GUICtrlEdit_SetText($Input3, $OemTip)
	_GUICtrlEdit_SetText($Edit1, $EnvVarsX)
	
;
;Timothy: Beware, these GUICtrlSetData() causes Menu's behavior bizarre: After selecting any menu item, program exits unconditionally.
;	GUICtrlSetData($Input4, $EfiSource)
;	GUICtrlSetData($Input5, $BuildTip)
;	GUICtrlSetData($Edit1, $EnvVars)
;	GUICtrlSetData($Edit2, $LeadingCmds)

	GUICtrlSetOnEvent($Button2,	"Button2SetNubios")
	GUICtrlSetOnEvent($Button3,	"Button3SetOemTip")
EndFunc


Func LegacyBios_SetVariables($WarningOnMissedPath=False)

	AutoItSetOption("ExpandEnvStrings", 1)
	
	Local $Nubios	= Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input2), 1+2))
	Local $OemTip	= Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input3), 1+2))

	TEnvAdd("NUBIOS", 	$Nubios)
	TEnvAdd("OEM_TIP", 	$OemTip)
	TEnvAdd("NUCORE",	"600")
	TEnvAdd("MASMVER",	"800")

	TEnvAdd("Path", $Nubios & "\TOOLS600;" & @WindowsDir & ";" & @SystemDir)	;0.7g
	
	Local $OemTip0	= StringReplace($OemTip, $Nubios, "")
	If $OemTip0 <> "" Then
		TEnvAdd("OEM_TIP0", $OemTip0)
	EndIf
	

	IF $WarningOnMissedPath Then
		If Not FileExists($Nubios) Then MsgBox(48, "Ouch", "NUBIOS: " & $Nubios &" does not exist!")
		If Not FileExists($OemTip) Then MsgBox(48, "Ouch", "OEM_TIP: " & $OemTip & " does not exist!")
	EndIf
	
	AutoItSetOption("ExpandEnvStrings", 0)

EndFunc

Func LegacyBios_Build($Arg="", $ExtParams="")
	
	Local $BuildTip	= Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input3), 1+2))
	Local $ConsoleMsg = ""
	
	Local $Cmd = ""
	If StringCompare($Arg, $BuildString, 0) == 0 Then
		$ConsoleMsg &= @CRLF & $ConsoleBuildString & $CRLFx2
		$Cmd = _
			"makmaker" 	& @CRLF & _
			"nmaker bb" 	& @CRLF & _
			"nmaker"	& @CRLF
	EndIf

	If StringCompare($Arg, $CleanString, 0) == 0 Then
		$ConsoleMsg &= @CRLF & $ConsoleCleanUpString & $CRLFx2
		$Cmd = _
			"makmaker" 	& @CRLF & _
			"nmaker clean"	& @CRLF
	EndIf

	If StringCompare($Arg, $RebuildString, 0) == 0 Then
		$ConsoleMsg &= @CRLF & $ConsoleRebuildString & $CRLFx2
		$Cmd =  "makmaker" 	& @CRLF & _
			"nmaker clean"	& @CRLF & _
			"makmaker"	& @CRLF & _
			"nmaker bb"	& @CRLF & _
			"nmaker"	& @CRLF
	EndIf

	Local $CmdList[4] = [3, $ConsoleMsg, $Cmd, $BuildTip]

	return $CmdList

	
EndFunc



Func LegacyBios_IniUpdate($INI)
	
	Local	$Nubios	= GUICtrlRead($Input2)
	Local	$OemTip	= GUICtrlRead($Input3)
	Local	$EnvVars	= GUICtrlRead($Edit1)
	
	IniUpdate($INI, $LegacyBiosString, $NubiosString, $Nubios)
	IniUpdate($INI, $LegacyBiosString, $OemTipString, $OemTip)
	IniUpdate($INI, $LegacyBiosString, $EnvVarsString, $EnvVars, True)

EndFunc


Func Button2SetNubios()
	AutoItSetOption("ExpandEnvStrings", 1)
	Local $Nubios	= Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input2), 1+2))
	AutoItSetOption("ExpandEnvStrings", 0)

	If _IsPressed("11") AND FileExists($Nubios) Then 	; "11" =  Ctrl key
		ShellExecute($Nubios)
		Return
	EndIf

	$Nubios = FileSelectFolder("Select NUBIOS Directory:", "", 2+4, $Nubios)
	If $Nubios <> "" Then
		_GUICtrlEdit_SetText($Input2, $Nubios)
	EndIf
EndFunc
	
Func Button3SetOemTip()
	AutoItSetOption("ExpandEnvStrings", 1)
	Local $OemTip		= Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input3), 1+2))
	AutoItSetOption("ExpandEnvStrings", 0)

	If _IsPressed("11") AND FileExists($OemTip) Then 	; "11" =  Ctrl key
		ShellExecute($OemTip)
		Return
	EndIf
	
	$OemTip = FileSelectFolder("Select OEM_TIP Directory:", "", 2+4, $OemTip)
	If $OemTip <> "" Then
		_GUICtrlEdit_SetText($Input3, $OemTip)
	EndIf
EndFunc