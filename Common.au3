#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.2.12.1
 Author:         Timothy Lin

 Script Function:

 R0.1	2009/6/5	Timothy		IniUpdate() - write value to ini anyway (removal "identical-value" checking which minimizes ini-write but causes myterious write-lost.

#ce ----------------------------------------------------------------------------

#include-once

#include <GUIConstantsEx.au3>
#include <File.au3>


Func TEnvAdd($Env, $EnvValue="")
	AppendPrologueCommand("SET " & $Env & "=" & $EnvValue)
EndFunc

;
; TEnvSet - Set environment variables from an editor's content (delimetered by @CRLF)
;
Func TEnvSet($EnvVars)

	Local $EnvVarsList = StringSplit($EnvVars, @CRLF, 1)

	;If @Error Then Return

	For $i = 1 to $EnvVarsList[0]
		Local $evs = StringStripWS ($EnvVarsList[$i], 8)
		If $evs == "" Then
			ContinueLoop
		EndIf

		Local $Malformation = false
		Local $Envs0 = StringRegExp($EnvVarsList[$i], "\s*([A-Za-z_0-9@]+)\s+([A-Za-z_0-9@]+)=*.*", 3)
		Local $Envs11 = ""
		If NOT @Error Then
			If StringCompare($Envs0[0], "SET") == 0 Then
				$Envs11 = $Envs0[1]
			ElseIf (StringCompare($Envs0[0], "REM") == 0) Then
                ContinueLoop
            ElseIf (StringCompare($Envs0[0], "::") == 0) Then
                ContinueLoop
            Else
				$Malformation = true
			EndIf
		Else
			Local $Envs1 = StringRegExp($EnvVarsList[$i], "\s*([A-Za-z_0-9@]+)\s*=*.*", 3)
			If @Error Then
				$Malformation = true
			Else
				$Envs11 = $Envs1[0]
			EndIf
		EndIf

		If $Malformation Then
			MsgBox(16, "Ouch", 'Variable is bad format in "Additional Environment Variables"' &@CRLF& 'Line: ' & $i & @CRLF & $EnvVarsList[$i])
			$Malformation = false
			ContinueLoop
		EndIf

		Local $Envs2 = StringRegExp($EnvVarsList[$i], "[^=]*\s*=(.*)$", 3)
		Local $Envs22 = ""
		If @Error Then
			$Envs22 = ""
		Else
			$Envs22 = StringStripWS($Envs2[0], 3)
		EndIf
		If $Envs11 <> "" Then
			AutoItSetOption("ExpandEnvStrings", 1)
			TEnvAdd($Envs11, $Envs22)
			AutoItSetOption("ExpandEnvStrings", 0)
		EndIf
	Next


EndFunc


;
; IniUpdate - update an INI key
;
Func IniUpdate($Ini, $Sec, $Key, $NewValue, $HexEncode=False)


	If $HexEncode Then
		$NewValue = Hex(StringToBinary($NewValue))
	EndIf

	IniWrite($Ini, $Sec, $Key, $NewValue)
EndFunc

;
; Path_TrimTrailingSlash - Trim a path name's trailing slash if any
;
Func Path_TrimTrailingSlash($Path)
	If StringRight($Path, 1) == '\' Then
		Return StringTrimRight($Path, 1)
	Else
		Return $Path
	EndIf
EndFunc


#Include <File.au3>
Func Path_IsExtension($Path, $Ext)
	Local	$szDrive, $szDir, $szFName, $szExt
	_PathSplit($Path, $szDrive, $szDir, $szFName, $szExt)
	Return (StringCompare($Ext, $szExt, 0) == 0)
EndFunc


Func __GuiCtrlCheckBox_SetCheckedState($ControlId, $Checked)
	Local $Msg = $GUI_UNCHECKED
	If $Checked Then
		$Msg = $GUI_CHECKED
	EndIf
	GUICtrlSetState($ControlId, $Msg)
EndFunc

Func __GuiCtrlCheckBox_IsChecked($ControlId)
	If BitAnd(GUICtrlRead($ControlId), $GUI_CHECKED) <> 0 Then Return True
	Return False
EndFunc

Func IsDirectory($Name)
	Local $attr = FileGetAttrib($Name)
	If StringInStr($attr, "D") Then
		Return True
	Else
		Return False
	EndIf
EndFunc

Func TEdit($Fname)
	If StringLeft($Fname, 1) <> '"' Then
		$Fname = '"' & $Fname & '"'
	EndIf
	TDebugConsoleWrite("Edit: " & $Fname)
	ShellExecute($Global_CorgiEditor, $Fname)
EndFunc

Func TLaunchDirectory($Dir)
	$DirTail = StringRight($Dir, 1)
	If StringInStr("\/", $DirTail) == 0 Then
		$Dir = $Dir & "\"
	EndIf
	If StringLeft($Dir, 1) <> '"' Then
		$Dir = '"' & $Dir & '"'
	EndIf
	TDebugConsoleWrite("LaunchDirectory: " & $Dir)
	ShellExecute($Dir)
EndFunc

Func TFreeRun($Cmd, $Show = @SW_HIDE)
	If StringLeft($Cmd, 1) <> '"' Then
		$Cmd = '"' & $Cmd & '"'
	EndIf
	;Run(@ComSpec & ' /c ' & $Cmd, "", $Show)
	TDebugConsoleWrite("ShellExecute: " & $Cmd)
	ShellExecute($Cmd)
EndFunc


;
; Timothy: Here, I am still puzzled about the behavior regarding an "imported" config file
;		-- So I decided to make it "read-only" when using an imported config file
;		-- I've changed my mind. An "imported" config file is just an "imported" file. It should not be a port of current setting's record. Use "Export" to save the new setting.
;
;Enum $Enum_OCF_Query=1, $Enum_OCF_Yes=6, $Enum_OCF_No=7
;
;$OverrideConfigFileToken = $Enum_OCF_Query
;
;Func Is_ConfigFileUpdate($Ini)
;	If $OverrideConfigFileToken == $Enum_OCF_Yes Then
;		Return True
;	EndIf
;
;	If StringCompare($Ini, $OriginalGlobalIni) <> 0 Then
;		Return False
;	Else
;		Return True
;	EndIf
;
;	;MsgBox(0, $OverrideConfigFileToken, $Enum_OCF_Query)
;;	If $OverrideConfigFileToken == $Enum_OCF_Query Then
;;		;MsgBox(0, $Ini, $OriginalGlobalIni)
;;		If StringCompare($Ini, $OriginalGlobalIni) <> 0 Then
;;			Local $YN = MsgBox(3+32, "Update", "Settings in/from: " & $Ini & " are changed, save it?")	; 4: Yes, No & Cancel
;;			If $YN == 6 Then	; yes:6, No: 7
;;				$OverrideConfigFileToken = $Enum_OCF_Yes
;;			ElseIf $YN == 7 Then
;;				$OverrideConfigFiletoken = $Enum_OCF_No
;;			EndIf
;;
;;		Else
;;			$OverrideConfigFileToken = $Enum_OCF_Yes
;;		EndIf
;;	EndIf
;;
;;	If $OverrideConfigFileToken == $Enum_OCF_Yes Then
;;		Return True
;;	Else
;;		Return False
;;	EndIf
;EndFunc
;
;Func Reset_ConfigFileUpdate()
;	$OverrideConfigFileToken = $Enum_OCF_Query
;EndFunc
;
;Func Set_ConfigFileUpdate()
;	$OverrideConfigFileToken = $Enum_OCF_Yes
;EndFunc

;Func isExecutable($Path)
;	Dim $szDrive, $szDir, $szFName, $szExt
;	$TestPath = _PathSplit($Path, $szDrive, $szDir, $szFName, $szExt)
;	If $szExt == "" Then Return False
;
;	Local $PathExt = EnvGet("PATHEXT")
;	if $PathExt == "" Then
;		$PathExt = ".COM;.EXE;.BAT;.CMD"
;	EndIf
;
;	Local $ExecExts = StringSplit($PathExt, ";")
;	Local $i
;
;	For $i = 1 to $ExecExts[0]
;		If StringCompare($szExt, $ExecExts[$i]) == 0 Then Return True
;	Next
;
;	Return False
;EndFunc


;
;http://www.autoitscript.com/forum/index.php?showtopic=73302&st=0&p=534401&#
;author:    SmOke_N

Func _ColorConvert($nColor);RGB to BGR or BGR to RGB
    Return _
        BitOR(BitShift(BitAND($nColor, 0x000000FF), -16), _
        BitAND($nColor, 0x0000FF00), _
        BitShift(BitAND($nColor, 0x00FF0000), 16))
EndFunc
