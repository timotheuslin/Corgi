#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.0.0, 3.3.14.5(R1)

 Script Function:
    SCT 2.0/3/4.x support

; R1    Timothy 2018/Nov/30  SCT 4.x support
; R1    Timothy 2013/Jan/7  SCT 4.x support
; R0    Timothy 2009/Aug/7

#ce ----------------------------------------------------------------------------

#include-once

Const   $Sct2String                     = $GlobalTaskSectionName[$Enum_GlobalTask_Sct2]
Const   $Sct2ProjectDirectoryString1    = "ProjectDirectory"
Const   $Sct2MlistString1               = "ModuleList"
Const   $PhmakeOptions                  = "Arguments"
Const   $PhmakeOptionsIni               = "PhMakeArguments"

Func SCT2_Init($INI=$GlobalIni)
    GUICtrlSetState($Button2, $GUI_DISABLE)
    GUICtrlSetState($Button3, $GUI_DISABLE)

    GUICtrlSetState($Button1, $GUI_ENABLE)
    GUICtrlSetState($Button4, $GUI_ENABLE)
    GUICtrlSetState($Button5, $GUI_ENABLE)
    _GUICtrlButton_SetText($Button1, $PhmakeOptions)
    _GUICtrlButton_SetText($Button4, "ProjectDir")
    _GUICtrlButton_SetText($Button5, $Sct2MlistString1)
    GUICtrlSetImage($Button1,   @ScriptFullPath, -11, 0)

    GUICtrlSetState($Input1, $GUI_ENABLE)
    GUICtrlSetState($Input2, $GUI_DISABLE)
    GUICtrlSetState($Input3, $GUI_DISABLE)
    GUICtrlSetState($Input4, $GUI_ENABLE+$GUI_FOCUS)
    GUICtrlSetState($Input5, $GUI_ENABLE)
    GUICtrlSetState($Input6, $GUI_DISABLE)

    GUICtrlSetState($Label1, $GUI_DISABLE)

    GUICtrlSetState($ButtonStart, $GUI_ENABLE)
    GUICtrlSetState($ButtonRebuild, $GUI_ENABLE)
    GUICtrlSetState($ButtonCleanUp, $GUI_ENABLE)
    _GUICtrlButton_SetText($ButtonStart,   "Build")
    _GUICtrlButton_SetText($ButtonRebuild, "Rebuild")
    _GUICtrlButton_SetText($ButtonCleanUp, "Clean")

    TRunningState(False)

    _GUICtrlEdit_SetText($Input1, IniRead($INI, $Sct2String, $PhmakeOptionsIni, ""))
    _GUICtrlEdit_SetText($Input4, IniRead($INI, $Sct2String, $Sct2ProjectDirectoryString1, ""))
    _GUICtrlEdit_SetText($Input5, IniRead($INI, $Sct2String, $Sct2MlistString1, ""))
    _GUICtrlEdit_SetText($Edit1, BinaryToString("0x" & IniRead($INI, $Sct2String, $EnvVarsString, "")))
    Local $LeadingCmds      = BinaryToString("0x" & IniRead($INI, $Sct2String, $LeadingCmdsString, ""))

;    If $EnvVarsX <> "" Then
;        $EnvVarsX       = BinaryToString("0x" & $EnvVarsX)
;    EndIf
;    $LeadingCmds        = BinaryToString("0x" & $LeadingCmds)

;    _GUICtrlEdit_SetText($Input4, $Sct2ProjectDirectory)
;    _GUICtrlEdit_SetText($Input5, $Sct2Mlist)

;    _GUICtrlEdit_SetText($Edit1, $EnvVarsX)
;
;Timothy: Beware, these GUICtrlSetData() causes Menu's behavior bizarre: After selecting any menu item, program exits unconditionally.
;   GUICtrlSetData($Input4, $EfiSource)
;   GUICtrlSetData($Input5, $BuildTip)
;   GUICtrlSetData($Edit1, $EnvVars)
;   GUICtrlSetData($Edit2, $LeadingCmds)

    GUICtrlSetOnEvent($Button1, "Button1Sct2OptBuild")
    GUICtrlSetOnEvent($Button4, "Button4SetSct2ProjectDirectory")
    GUICtrlSetOnEvent($Button5, "Button5SetSct2Mlist")

EndFunc

Func SCT2_SetToolChain()
    Local $ToolChainId = _GUICtrlComboBox_GetCurSel($ComboToolChain)
    Local $ToolChainTag
    _GUICtrlComboBox_GetLBText($ComboToolChain, $ToolChainId, $ToolChainTag)
    Local $VsPath = ""
    Local $VsBat = ""
    Local $VsBatArgs = ""
    Switch $ToolChainTag
        Case "VS2008x86"
            $VsPath = "VS90COMNTOOLS"
            $VsBat = "vsvars32.bat"
            $VsBatArgs = "x86"
        Case "VS2010x86"
            $VsPath = "VS100COMNTOOLS"
            $VsBat = "vsvars32.bat"
            $VsBatArgs = "x86"
        Case "VS2012x86"
            $VsPath = "VS110COMNTOOLS"
            $VsBat = "vsvars32.bat"
            $VsBatArgs = "x86"
        Case "VS2013x86"
            $VsPath = "VS120COMNTOOLS"
            $VsBat = "vsvars32.bat"
            $VsBatArgs = "x86"
        Case "VS2015x86"
            $VsPath = "VS140COMNTOOLS"
            $VsBat = "..\..\VC\vcvarsall.bat"
            $VsBatArgs = "x86"
        Case "VS2017"
            $VsPath = "VS150COMNTOOLS"
            $VsBat = "VsDevCmd.bat"
        Case "VS2019"
            $VsPath = "VS160COMNTOOLS"
            $VsBat = "VsDevCmd.bat"
    EndSwitch
    AppendExecCommand('ECHO Tool Chain: ' & $ToolChainTag )
    If $VsPath <> "" Then
        Local $VsPathX = '"%' & $VsPath & '%' & $VsBat & '"'
        AppendExecCommand('IF EXIST ' & $VsPathX & ' (' )
        AppendExecCommand('    CALL ' & $VsPathX & ' ' & $VsBatArgs)
        AppendExecCommand(') ELSE (' )
        AppendExecCommand('    ECHO ERROR: Invalid Tool Chain: ' & $ToolChainTag)
        AppendExecCommand('    EXIT /B 1')
        AppendExecCommand(')')
    EndIf
EndFunc

Global $SCT4 = False

Func SCT2_SetVariables($WarningOnMissedPath=False)

    Local $Sct2ProjectDirectory = Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input4), 1+2))
    Local $Mlist                = StringReplace(StringStripWS(GUICtrlRead($Input5), 1+2), ",", " ")
    Local $Sct2BuildCmd0   = $Sct2ProjectDirectory & "\PhMake.BAT"

    If FileExists($Sct2BuildCmd0) Then
        $SCT4 = True
    Else
        $SCT4 = False
    EndIf

    TEnvAdd($Sct2ProjectDirectoryString1, $Sct2ProjectDirectory)
    TEnvAdd("ProjectDir", $Sct2ProjectDirectory)
    TEnvAdd("PROJ_DIR", $Sct2ProjectDirectory)

    Local $MlistArray = StringSplit($Mlist, " ")
    $Mlist = ""
    For $i = 1 To $MlistArray[0]
        If $MlistArray[$i] <> "" Then
            If $i > 1 Then
                $Mlist = $Mlist & "," & $MlistArray[$i]
            Else
                $Mlist = $MlistArray[$i]
            EndIf
        EndIf
    Next

    TEnvAdd("ModuleList", $Mlist)
    TEnvAdd("MLIST", $Mlist)

    Local $BuildTip = Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input4), 1+2)) ; "1+2" = strip leading/trailing space
    Local $Sct2Root = LocateSct2Root($BuildTip)

    If Not $SCT4 and $Sct2Root <> "" Then
        TEnvAdd("Sct2Root", $Sct2Root)
        TEnvAdd("SctRoot", $Sct2Root)
    EndIf

    If $WarningOnMissedPath Then
        If Not FileExists($Sct2ProjectDirectory) Then MsgBox(48, "Error", "Project Directory : " & $Sct2ProjectDirectory &" does not exist!")
    EndIf

    SCT2_SetToolChain()

EndFunc

Global $Sct2RootMissed = "ERROR: Cannot Locate SCT Root Directory." & @CRLF & _
                         "Maybe phmake.cfg is missing?" & $CRLFx2

Local $Sct2OptBuild = "Sct2PhmakeWitOptions"

Func SCT2_Build($Arg="", $ExtParams="")

    Local $BuildTip          = Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input4), 1+2)) ; "1+2" = strip leading/trailing space
    Local $PhmakeParamsValue = StringStripWS(GUICtrlRead($Input1), 1+2+4)               ; "1+2+4" = strip leading/trailing/double space
    Local $Sct2Root          = LocateSct2Root($BuildTip)
    Local $ConsoleMsg        = ""
    Local $Sct2BuildCmd      = ""
    Local $HasFatalError     = False

    While True
        If Not FileExists($BuildTip) Then
            TConsoleErrorWrite("Project Directory does not exist: " & $BuildTip)
            $HasFatalError = True
            ExitLoop
        EndIf
        If $Sct2Root == "" Then
            TConsoleErrorWrite("Cannot Locate SCT Root Directory." & @CRLF & "Maybe PHMAKE.CFG is missing?")
            $HasFatalError = True
            ExitLoop
        EndIf

        Local $Sct2BuildCmd_Path0   = $BuildTip
        Local $Sct2BuildCmd_Path1   = $Sct2Root & "\Tools"
        Local $Sct2BuildCmd_Path2   = $Sct2Root & "\Phoenix\Tools"

        Local $Sct2BuildCmd0   = $Sct2BuildCmd_Path0 & "\PhMake.BAT"        ; SCT4
        Local $Sct2BuildCmd0_0 = "CALL " & $Sct2BuildCmd0
        Local $Sct2BuildCmd1   = $Sct2BuildCmd_Path1 & "\PHMAKE.EXE"
        Local $Sct2BuildCmd2   = $Sct2BuildCmd_Path2 & "\PHMAKE.EXE"

        $Sct2BuildCmd = ""
        If FileExists($Sct2BuildCmd0) Then
            $Sct2BuildCmd   = $Sct2BuildCmd0_0              ; SCT4
        ElseIf FileExists($Sct2BuildCmd1) Then
            $Sct2BuildCmd   = $Sct2BuildCmd1
        ElseIf FileExists($Sct2BuildCmd2) Then
            $Sct2BuildCmd   = $Sct2BuildCmd2                ; SCT 3.2
        EndIf

        If $Sct2BuildCmd == "" Then
            TConsoleErrorWrite("PHKMAKE.EXE/PHMAKE.BAT is missed in: " & $Sct2BuildCmd_Path0 & ", " & $Sct2BuildCmd_Path1 & " or" & $Sct2BuildCmd_Path2 & ".")
            $HasFatalError = True
            ExitLoop
        EndIf

        $ConsoleMsg = @CRLF & "SCT Root Directory, EFI_SOURCE = " & $Sct2Root & @CRLF

        If StringCompare($ExtParams, $Sct2OptBuild, 0) == 0 Then
            $ConsoleMsg &= @CRLF & $ConsoleBuildString & $CRLFx2
            AppendExecCommand($Sct2BuildCmd & " " & $PhmakeParamsValue)
            ExitLoop
        EndIf

        If StringCompare($Arg, $BuildString, 0) == 0 Then
            $ConsoleMsg &= @CRLF & $ConsoleBuildString & $CRLFx2
            AppendExecCommand($Sct2BuildCmd)
            ExitLoop
        EndIf

        If StringCompare($Arg, $CleanString, 0) == 0 Then
            $ConsoleMsg &= @CRLF & $ConsoleCleanUpString & $CRLFx2
            AppendExecCommand($Sct2BuildCmd & " del")
            ExitLoop
        EndIf

        If StringCompare($Arg, $RebuildString, 0) == 0 Then
            $ConsoleMsg &= @CRLF & $ConsoleRebuildString & $CRLFx2
            AppendExecCommand($Sct2BuildCmd & " del")
            AppendExecCommand($Sct2BuildCmd)
            ExitLoop
        EndIf
        ExitLoop
    WEnd

    Local $CmdList[4] = [3, $ConsoleMsg, "", $BuildTip]

    If $HasFatalError Then
        $CmdList[3] = ""
    EndIf

    return $CmdList
EndFunc


Func SCT2_IniUpdate($INI)
    IniUpdate($INI, $Sct2String, $PhmakeOptionsIni, GUICtrlRead($Input1))
    IniUpdate($INI, $Sct2String, $Sct2ProjectDirectoryString1, GUICtrlRead($Input4))
    IniUpdate($INI, $Sct2String, $Sct2MlistString1, GUICtrlRead($Input5))
    IniUpdate($INI, $Sct2String, $EnvVarsString, GUICtrlRead($Edit1), True)
EndFunc


Func Button4SetSct2ProjectDirectory()

    AutoItSetOption("ExpandEnvStrings", 1)
    Local $EfiSource    = Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input4), 1+2))
    AutoItSetOption("ExpandEnvStrings", 0)

    If _IsPressed("11") AND FileExists($EfiSource) Then     ; "11" =  Ctrl key
        ShellExecute($EfiSource)
        Return
    EndIf

    $EfiSource = FileSelectFolder("Select SCT Project Directory:", $EfiSource, 2+4, $EfiSource)
    If $EfiSource <> "" Then
        _GUICtrlEdit_SetText($Input4, $EfiSource)
    EndIf
EndFunc



Func Button5SetSct2Mlist()

    AutoItSetOption("ExpandEnvStrings", 1)
    Local $EfiSource    = Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input4), 1+2))
    AutoItSetOption("ExpandEnvStrings", 0)
    Local $BuildDir = $EfiSource & "\temp"
    Local $Mlist = $BuildDir & "\module.list"

    If NOT FileExists($BuildDir) Then
        MsgBox(48, "Error", "Build Directory: " & $Builddir & " does not exist!")
        Return
    EndIf

    If NOT FileExists($Mlist) Then
        MsgBox(48, "Error", "Module List: " & $Mlist & " does not exist!")
        return
    EndIf

    If _IsPressed("12") AND FileExists($Mlist) Then     ; Alt key
        TEdit($Mlist)
        Return
    EndIf

    ;
    ; TODO
    ;

    ;If FileExists($Mlist)
    ;$EfiSource = FileSelectFolder("Select SCT2 Project Directory:", "", 2+4, $EfiSource)
    ;If $EfiSource <> "" Then
    ;   _GUICtrlEdit_SetText($Input4, $EfiSource)
    ;EndIf
EndFunc



Func LocateSct2Root($ProjectDirectory)
    Local $Sct2Root0 = $ProjectDirectory
    Local $i

    While True
        $i = StringInStr($Sct2Root0, "\", 0, -1)
        If $i <= 1 Then Return ""
        $Sct2Root0 = StringLeft($Sct2Root0, $i-1)
        If FileExists($Sct2Root0 & "\phmake.cfg") Then
            Return $Sct2Root0
        EndIf
    WEnd
EndFunc

Func Button1Sct2OptBuild()
    If (BitAND(GUICtrlGetState($ButtonStart), $GUI_ENABLE) == 0) Then
        Return
    EndIf
    StartCleanUpRebuildCommon($BuildString, $Sct2OptBuild)
EndFunc
