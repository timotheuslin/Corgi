#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.0.0

 Script Function:
	Benton2 build
	
; R0	Timothy 2009/8/7	init		


TODO:	exit batch-build when error-level != 0

#ce ----------------------------------------------------------------------------

#include-once

Const	$B2String	 	= $GlobalTaskSectionName[$Enum_GlobalTask_Benton2]
Const	$B2NubiosString		= "NUBIOS"
Const	$B2OemTipString		= "OEM_TIP"
Const	$B2EfiSourceString	= "EfiSource"
Const	$B2BuildTipString	= "BuildTip" 

Func B2_Init($INI=$GlobalIni)

	GUICtrlSetState($Button1, $GUI_DISABLE)
	
	GUICtrlSetState($Button2, $GUI_ENABLE+$GUI_FOCUS)
	GUICtrlSetState($Button3, $GUI_ENABLE)
	GUICtrlSetState($Button4, $GUI_ENABLE)
	GUICtrlSetState($Button5, $GUI_ENABLE)
	
	_GUICtrlButton_SetText($Button2, $B2NubiosString)
	_GUICtrlButton_SetText($Button3, $B2OemTipString)
	_GUICtrlButton_SetText($Button4, "EFI_SOURCE")
	_GUICtrlButton_SetText($Button5, "BUILD_TIP")

	GUICtrlSetState($Input1, $GUI_DISABLE)
	GUICtrlSetState($Input2, $GUI_ENABLE)
	GUICtrlSetState($Input3, $GUI_ENABLE)
	GUICtrlSetState($Input4, $GUI_ENABLE)
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
	
	Local $EfiSource	= IniRead($INI, $B2String, $B2EfiSourceString, "")
	Local $BuildTip		= IniRead($INI, $B2String, $B2BuildTipString, "")
	Local $Nubios		= IniRead($INI, $B2String, $B2NubiosString, "")
	Local $OemTip		= IniRead($INI, $B2String, $B2OemTipString, "")
	Local $EnvVarsX		= IniRead($INI, $B2String, $EnvVarsString, "")
	;Local $LeadingCmds	= IniRead($INI, $B2String, $LeadingCmdsString, "")

	If $EnvVarsX <> "" Then
		$EnvVarsX 		= BinaryToString("0x" & $EnvVarsX)
	EndIf
	;$LeadingCmds		= BinaryToString("0x" & $LeadingCmds)

	_GUICtrlEdit_SetText($Input4, $EfiSource)
	_GUICtrlEdit_SetText($Input5, $BuildTip)
	_GUICtrlEdit_SetText($Input2, $Nubios)
	_GUICtrlEdit_SetText($Input3, $OemTip)
	_GUICtrlEdit_SetText($Edit1, $EnvVarsX)
	
;
;Timothy: Beware, these GUICtrlSetData() causes Menu's behavior bizarre: After selecting any menu item, program exits unconditionally.
;	GUICtrlSetData($Input4, $EfiSource)
;	GUICtrlSetData($Input5, $BuildTip)
;	GUICtrlSetData($Edit1, $EnvVars)
;	GUICtrlSetData($Edit2, $LeadingCmds)

	GUICtrlSetOnEvent($Button2,	"Button2SetB2Nubios")
	GUICtrlSetOnEvent($Button3,	"Button3SetB2OemTip")
	GUICtrlSetOnEvent($Button4,	"Button4SetB2EfiSource")
	GUICtrlSetOnEvent($Button5,	"Button5SetB2BuildTip")

EndFunc

Func B2_EnvPreset()
	Local $BUILD_VS_VERSION = EnvGet("BUILD_VS_VERSION")
	If $BUILD_VS_VERSION == "" Then
		If EnvGet("VS80COMNTOOLS") Then
			$BUILD_VS_VERSION = "VS2005"
		EndIf
		If EnvGet("VS90COMNTOOLS ") Then
			$BUILD_VS_VERSION = "VS2008"
		EndIf
		TEnvAdd("BUILD_VS_VERSION", $BUILD_VS_VERSION)
	EndIf
	
	Local $BUILD_DIR = EnvGet("BUILD_DIR")
	If $BUILD_DIR == "" Then
		$BUILD_DIR ="X64." & $BUILD_VS_VERSION & ".GreenHV1"
		TEnvAdd("BUILD_DIR", $BUILD_DIR)
	EndIf
EndFunc

Func B2_SetVariables($WarningOnMissedPath=False)

	AutoItSetOption("ExpandEnvStrings", 1)

	Local $EfiSource	= Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input4), 1+2))
	Local $BuildTip		= Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input5), 1+2))	
	Local $Nubios		= Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input2), 1+2))
	Local $OemTip		= Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input3), 1+2))

	TEnvAdd("EFI_SOURCE", 	$EfiSource)
	TEnvAdd("BUILD_TIP", 	$BuildTip)
	TEnvAdd("NUBIOS", 	$Nubios)
	TEnvAdd("OEM_TIP", 	$OemTip)
	TEnvAdd("NUCORE",	"600")
	TEnvAdd("MASMVER",	"800")

	TEnvAdd("Path", $Nubios & "\TOOLS600;" & @WindowsDir & ";" & @SystemDir)	;0.7g
	

	Local $BuildTip0	= StringReplace($BuildTip, $EfiSource, "")
	If $BuildTip0 <> "" Then
		TEnvAdd("BUILD_TIP0", $BuildTip0)
	EndIf

	Local $OemTip0	= StringReplace($OemTip, $Nubios, "")
	If $OemTip0 <> "" Then
		TEnvAdd("OEM_TIP0", $OemTip0)
	EndIf
	

	IF $WarningOnMissedPath Then
		If Not FileExists($EfiSource) 	Then MsgBox(48, "Ouch", "EFI_SOUCE : " & $EfiSource &" does not exist!")
		If Not FileExists($BuildTip) 	Then MsgBox(48, "Ouch", "BUILD_TIP: " & $BuildTip & " does not exist!")
		If Not FileExists($Nubios) 	Then MsgBox(48, "Ouch", "NUBIOS: " & $Nubios &" does not exist!")
		If Not FileExists($OemTip) 	Then MsgBox(48, "Ouch", "OEM_TIP: " & $OemTip & " does not exist!")
	EndIf

	AutoItSetOption("ExpandEnvStrings", 0)

EndFunc

Func B2_Build($Arg="", $ExtParams="")

	B2_EnvPreset()
	Local $BuildTip		= Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input5), 1+2))
	Local $Cmd

	Local $B2TianoBuildCmd	= 'call build.bat -config "X64|%BUILD_VS_VERSION%|GreenHV1"'
	Local $ConsoleMsg = ""

	If StringCompare($Arg, $BuildString, 0) == 0 Then
		$ConsoleMsg &= @CRLF & $ConsoleBuildString & $CRLFx2
		AppendExecCommand("SETLOCAL")
		AppendExecCommand($B2TianoBuildCmd)
		AppendExecCommand("@if NOT %ERRORLEVEL% == 0 GOTO:EOF")
		AppendExecCommand("ENDLOCAL")
		AppendExecCommand("Cd /D " & "%OEM_TIP%")
		AppendExecCommand("makmaker")
		AppendExecCommand("nmaker bb")
		AppendExecCommand("nmaker")
	EndIf

	If StringCompare($Arg, $CleanString, 0) == 0 Then
		$ConsoleMsg &= @CRLF & $ConsoleCleanUpString & $CRLFx2
		AppendExecCommand("SETLOCAL")
		AppendExecCommand($B2TianoBuildCmd & " Clean")
		AppendExecCommand("@if NOT %ERRORLEVEL% == 0 GOTO:EOF")
		AppendExecCommand("ENDLOCAL")
		AppendExecCommand("CD /D " & "%OEM_TIP%")
		AppendExecCommand("makmaker")
		AppendExecCommand("nmaker clean")
	EndIf

	If StringCompare($Arg, $RebuildString, 0) == 0 Then
		$ConsoleMsg &= @CRLF & $ConsoleRebuildString & $CRLFx2
		AppendExecCommand("SETLOCAL")
		AppendExecCommand($B2TianoBuildCmd & " rebuild")
		AppendExecCommand("@if NOT %ERRORLEVEL% == 0 GOTO:EOF")
		AppendExecCommand("ENDLOCAL")
		AppendExecCommand("cd /D " & "%OEM_TIP%")
		AppendExecCommand("makmaker")
		AppendExecCommand("nmaker clean")
		AppendExecCommand("makmaker" )
		AppendExecCommand("nmaker bb")
		AppendExecCommand("nmaker")

	EndIf

	Local $CmdList[4] = [3, $ConsoleMsg, "", $BuildTip]

	return $CmdList
	
EndFunc

Func B2_IniUpdate($INI)
	
	Local	$Nubios		= GUICtrlRead($Input2)
	Local	$OemTip		= GUICtrlRead($Input3)
	Local	$NewEfiSource	= GUICtrlRead($Input4)
	Local	$NewBuildTip	= GUICtrlRead($Input5)
	Local	$NewEnvVars	= GUICtrlRead($Edit1)
	
	IniUpdate($INI, $B2String, $B2NubiosString,	$Nubios)
	IniUpdate($INI, $B2String, $B2OemTipString,	$OemTip)
	IniUpdate($INI, $B2String, $B2EfiSourceString,	$NewEfiSource)
	IniUpdate($INI, $B2String, $B2BuildTipString,	$NewBuildTip)
	IniUpdate($INI, $B2String, $EnvVarsString,	$NewEnvVars, True)	; hex-encoded

EndFunc


Func Button2SetB2Nubios()
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
	
Func Button3SetB2OemTip()
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

Func Button4SetB2EfiSource()

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
	
Func Button5SetB2BuildTip()
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