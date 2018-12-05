#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.0.0

 Script Function:
    "Get Legacy Code" support

; R0    Timothy 2009/Oct/7

#ce ----------------------------------------------------------------------------

#include-once

Global  $GetLegacyBuildCmd      = "dir"

Const   $GetLegacyString        = $GlobalTaskSectionName[$Enum_GlobalTask_GetLegacy]
Const   $GetLegacyNubiosTipString   = "NubiosTip"
Const   $GetLegacyOemTipString      = "OemTip"

Const   $GetLegacyNubiosString      = "NUBIOS"

Global  $GetLegacyPreBuildCmd       = ""

Func GetLegacy_Init($INI=$GlobalIni)
    GUICtrlSetState($Button1,   $GUI_DISABLE)
    
    GUICtrlSetState($Button2,   $GUI_ENABLE)
    GUICtrlSetState($Button3,   $GUI_ENABLE)
    _GUICtrlButton_SetText($Button2, $NubiosString)
    _GUICtrlButton_SetText($Button3, $OemTipString)

    GUICtrlSetState($Button4,   $GUI_DISABLE)
    GUICtrlSetState($Button5,   $GUI_DISABLE)

    GUICtrlSetState($Input1,    $GUI_DISABLE)
    GUICtrlSetState($Input2,    $GUI_ENABLE+$GUI_FOCUS)
    GUICtrlSetState($Input3,    $GUI_ENABLE)
    GUICtrlSetState($Input4,    $GUI_DISABLE)
    GUICtrlSetState($Input5,    $GUI_DISABLE)
    GUICtrlSetState($Input6,    $GUI_ENABLE)
    GUICtrlSetState($Label1,    $GUI_ENABLE)

    TRunningState(False)

    GUICtrlSetState($ButtonStart, $GUI_ENABLE)
    GUICtrlSetState($ButtonRebuild, $GUI_ENABLE)
    GUICtrlSetState($ButtonCleanUp, $GUI_DISABLE)
    _GUICtrlButton_SetText($ButtonStart, "Get")
    _GUICtrlButton_SetText($ButtonRebuild, "Quick Get")
    

    Local $GetLegacyNubiosTip   = IniRead($INI, $GetLegacyString, $GetLegacyNubiosTipString, "")
    Local $GetLegacyOemTip      = IniRead($INI, $GetLegacyString, $GetLegacyOemTipString, "")
    Local $EnvVarsX         = IniRead($INI, $GetLegacyString, $EnvVarsString, "")

    If $EnvVarsX <> "" Then
        $EnvVarsX       = BinaryToString("0x" & $EnvVarsX)
    EndIf

    _GUICtrlEdit_SetText($Input2, $GetLegacyNubiosTip)
    _GUICtrlEdit_SetText($Input3, $GetLegacyOemTip)
    _GUICtrlEdit_SetText($Edit1, $EnvVarsX)

;
;Timothy: Beware, these GUICtrlSetData() causes Menu's behavior bizarre: After selecting any menu item, program exits unconditionally.
;   GUICtrlSetData($Input4, $EfiSource)
;   GUICtrlSetData($Input5, $BuildTip)
;   GUICtrlSetData($Edit1, $EnvVars)
;   GUICtrlSetData($Edit2, $LeadingCmds)

    GUICtrlSetOnEvent($Button2, "Button2SetNubios")
    GUICtrlSetOnEvent($Button3, "Button3SetOemTip")

EndFunc


Func GetLegacy_SetVariables($WarningOnMissedPath=False)

    AutoItSetOption("ExpandEnvStrings", 1)

    ;Local $GetNubiosTip = Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input2), 1+2))
    ;Local $GetOemTip    = Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input3), 1+2))
    ;
    ;TEnvAdd($GetLegacyNubiosString, $GetNubiosTip)
    ;TEnvAdd($GetLegacyOemTipString, $GetOemTip)
    
    
    Local $NubiosTip     = Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input2), 1+2))
    Local $OemTip        = Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input3), 1+2))
    Local $Version       = Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input6), 1+2))
    Local $VersionParams = ""
    Local $ConsoleMsg    = @CRLF
    
    If $Version <> 0 Then
        $VersionParams = " -r " & $Version
    EndIf

    ;
    ; TODO: warning when oemtip exists
    ;

    Local $szDrive, $szDir, $szFName, $szExt, $TestPath
    $TestPath = _PathSplit($NubiosTip, $szDrive, $szDir, $szFName, $szExt)
    Local $FullPathNoDrive = $szDir & $szFName & $szExt
    If $FullPathNoDrive == "" OR StringCompare($FullPathNoDrive, "\") == 0 Then
        MsgBox(16, "Ouch", "Root directory is not allowed!")
        Return
    EndIf

        Local $BadUserNameHelp = "Your User-Login-Name is malformed. Ask IT/MIS for Help"
    Local $UserName = EnvGet("USERNAME")
    If $UserName == "" Then
        MsgBox(0, "", $BadUserNameHelp)
        Return
    EndIf
    Local $VcsIdSplit = StringRegExp($UserName, "([A-Z][a-z]{1,})_([A-Z][a-z]{1,})", 3)
    If @Error Then
        MsgBox(0, "", $BadUserNameHelp)
        Return
    EndIf

    Local $VcsId = ""
    For $i = 0 to UBound($VcsIdSplit) - 1
        $VcsId = $VcsId & $VcsIdSplit[$i]
    Next

    TEnvAdd("NUBIOS",       $NubiosTip)
    TEnvAdd("VCSID",        $VcsId)
    If $Version <> "" Then
        TEnvAdd("VERSION",  $Version)
    EndIf
    TEnvAdd("OemTip",       $OemTip)
    TEnvAdd("OEM_TIP",      $OemTip)
    TEnvAdd("PATH",         $NubiosTip & "\tools600;j:\pv\dos;" & @WindowsDir & ";" & @SystemDir)
    TEnvAdd("NUCORE",       "600")
    TEnvAdd("NuBiosSrcDrv", "k:")
    TEnvAdd("NuBiosArcDrv", "k:")
    TEnvAdd("MTOOLS",       $NubiosTip & "\tools600")
    TEnvAdd("PPMA",         "K:\NB\ARCHIVE\NUBIOS")
    TEnvAdd("PPMC",         "K:\NB\SOURCE\NUBIOS")
    TEnvAdd("PPMS",         $NubiosTip & "\TEMP")
    TEnvAdd("PPMP",         $NubiosTip)

;   If $WarningOnMissedPath Then
;       If Not FileExists($GetNubiosTip) Then MsgBox(48, "Ouch", "Project Directory : " & $GetNubiosTip &" does not exist!")
;       If Not FileExists($GetOemTip) Then MsgBox(48, "Ouch", "Project Directory : " & $GetOemTip &" does not exist!")
;   EndIf

    AutoItSetOption("ExpandEnvStrings", 0)

EndFunc

Func GetLegacy_Build($Arg="", $ExtParams="")

    Local $NubiosTip     = Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input2), 1+2))
    Local $OemTip        = Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input3), 1+2))
    Local $Version       = Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input6), 1+2))
    Local $VersionParams = ""
    Local $ConsoleMsg    = @CRLF
    
    If $Version <> 0 Then
        $VersionParams = " -r " & $Version
    EndIf

    ;
    ; TODO: warning when oemtip exists
    ;

    Local $szDrive, $szDir, $szFName, $szExt, $TestPath
    $TestPath = _PathSplit($NubiosTip, $szDrive, $szDir, $szFName, $szExt)
    Local $FullPathNoDrive = $szDir & $szFName & $szExt
    If $FullPathNoDrive == "" OR StringCompare($FullPathNoDrive, "\") == 0 Then
        MsgBox(16, "Ouch", "Root directory is not allowed!")
        Return
    EndIf

        Local $BadUserNameHelp = "Your User-Login-Name is malformed. Ask IT/MIS for Help"
    Local $UserName = EnvGet("USERNAME")
    If $UserName == "" Then
        MsgBox(0, "", $BadUserNameHelp)
        Return
    EndIf
    Local $VcsIdSplit = StringRegExp($UserName, "([A-Z][a-z]{1,})_([A-Z][a-z]{1,})", 3)
    If @Error Then
        MsgBox(0, "", $BadUserNameHelp)
        Return
    EndIf

    Local $VcsId = ""
    For $i = 0 to UBound($VcsIdSplit) - 1
        $VcsId = $VcsId & $VcsIdSplit[$i]
    Next

    TEnvAdd("NUBIOS",       $NubiosTip)
    TEnvAdd("VCSID",        $VcsId)
    If $Version <> "" Then
        TEnvAdd("VERSION",  $Version)
    EndIf
    TEnvAdd("OemTip",       $OemTip)
    TEnvAdd("OEM_TIP",      $OemTip)
    TEnvAdd("PATH",         $NubiosTip & "\tools600;j:\pv\dos;" & @WindowsDir & ";" & @SystemDir)
    TEnvAdd("NUCORE",       "600")
    TEnvAdd("NuBiosSrcDrv", "k:")
    TEnvAdd("NuBiosArcDrv", "k:")
    TEnvAdd("MTOOLS",       $NubiosTip & "\tools600")
    TEnvAdd("PPMA",         "K:\NB\ARCHIVE\NUBIOS")
    TEnvAdd("PPMC",         "K:\NB\SOURCE\NUBIOS")
    TEnvAdd("PPMS",         $NubiosTip & "\TEMP")
    TEnvAdd("PPMP",         $NubiosTip)

    $ConsoleMsg &= "NUBIOS  = " & $NubiosTip & @CRLF
    $ConsoleMsg &= "OEM Tip = " & $OemTip & @CRLF
    If $Version <> "" Then
        $ConsoleMsg &= "Version = " & $Version & @CRLF
    EndIf
    $ConsoleMsg &= "VCSID   = " & $VcsId & @CRLF
    
    If (StringCompare($Arg, $RebuildString) == 0) Then  ; $Rebuild Button == Quick Get Code
        $ConsoleMsg &= @CRLF & $ConsoleQkGetCodeString & $CRLFx2
    Else
        AppendExecCommand("if not exist %OemTip% mkdir %OemTip%")
        AppendExecCommand("if not exist %NUBIOS%\temp mkdir %NUBIOS%\temp")
        AppendExecCommand("if not exist %NUBIOS%\tools600 mkdir %NUBIOS%\tools600")
        AppendExecCommand("if not exist %NUBIOS%\script.600 mkdir %NUBIOS%\script.600")
        AppendExecCommand("xcopy.exe /K /R /Y k:\nb\source\nubios\tools600 %NUBIOS%\tools600")
        AppendExecCommand("xcopy.exe /K /R /Y k:\nb\source\nubios\script.600\*.m?k %NUBIOS%\script.600")
        $ConsoleMsg &= @CRLF & $ConsoleGetCodeString & $CRLFx2
    EndIf

    AppendExecCommand("cd /D %OemTip%")
    AppendExecCommand("makevcs.exe")
    AppendExecCommand("get.exe" & $VersionParams & " version.mak")
    AppendExecCommand("get.exe make.mak")
    AppendExecCommand("get.exe partnum.mak")
    AppendExecCommand("makmaker.exe")
    AppendExecCommand("nmaker.exe getver")

    Local $CmdList[4] = [3, $ConsoleMsg, "", "."]
    return $CmdList
EndFunc

Func GetLegacy_CleanUp()
    ;GetLegacy_Build("Quick");
    MsgBox(0, "!", "Not know what to clean yet!")
EndFunc


Func GetLegacy_IniUpdate($INI)

    Local   $NewGetLegacyNubiosTip  = GUICtrlRead($Input2)
    Local   $NewGetLegacyOemTip = GUICtrlRead($Input3)
    Local   $NewEnvVars     = GUICtrlRead($Edit1)

    IniUpdate($INI, $GetLegacyString, $GetLegacyNubiosTipString, $NewGetLegacyNubiosTip)
    IniUpdate($INI, $GetLegacyString, $GetLegacyOemTipString, $NewGetLegacyOemTip)
    IniUpdate($INI, $GetLegacyString, $EnvVarsString, $NewEnvVars, True)

EndFunc

;; extern'd in LegacyBios.au3

;;Func Button2SetNubiosTip()
;;
;;  AutoItSetOption("ExpandEnvStrings", 1)
;;  Local $NubiosTip    = Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input2), 1+2))
;;  AutoItSetOption("ExpandEnvStrings", 0)
;;
;;  If _IsPressed("11") AND FileExists($NubiosTip) Then     ; "11" =  Ctrl key
;;      ShellExecute($NubiosTip)
;;      Return
;;  EndIf
;;
;;  $NubiosTip = FileSelectFolder("Select NUBIOS Directory:", "", 2+4, $NubiosTip)
;;  If $NubiosTip <> "" Then
;;      _GUICtrlEdit_SetText($Input2, $NubiosTip)
;;  EndIf
;;EndFunc
;;
;;Func Button3SetOemTip()
;;
;;  AutoItSetOption("ExpandEnvStrings", 1)
;;  Local $OemTip   = Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input3), 1+2))
;;  AutoItSetOption("ExpandEnvStrings", 0)
;;
;;  If _IsPressed("11") AND FileExists($OemTip) Then    ; "11" =  Ctrl key
;;      ShellExecute($OemTip)
;;      Return
;;  EndIf
;;
;;  $OemTip = FileSelectFolder("Select OEM Tip:", "", 2+4, $OemTip)
;;  If $OemTip <> "" Then
;;      _GUICtrlEdit_SetText($Input3, $OemTip)
;;  EndIf
;;EndFunc
