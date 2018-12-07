#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.2.12.1
 Author:         myName

 Script Function:
    Template AutoIt script.

#ce ----------------------------------------------------------------------------

#include-once

#include <Misc.au3>
#include "Mouse.au3"
#include "About.au3"
#include "resources.au3"


Func MainFormResize($Mode)
    If $Mode == 0 Then
        WinMove($MainForm, "", Default, Default, 1016, 425) ; top-panel's height + 51
;       _GUICtrlStatusBar_ShowHide($StatusBar1, @SW_HIDE)
    Else
        WinMove($MainForm, "", Default, Default, 1016, 700)  ; Main form's height + 19
;       _GUICtrlStatusBar_ShowHide($StatusBar1, @SW_SHOW)
;       _GUICtrlStatusBar_Resize($StatusBar1)
    EndIf
EndFunc


Func TRunningState($Running)
    $GlobalCorgiIsBusy = $Running
    If $Running Then
        GUICtrlSetState($ButtonStart,   $GUI_DISABLE)
        GUICtrlSetState($ButtonCleanUp, $GUI_DISABLE)
        GUICtrlSetState($ButtonRebuild, $GUI_DISABLE)
        GUICtrlSetState($ButtonPause,   $GUI_ENABLE)
        GUICtrlSetState($ButtonStop,    $GUI_ENABLE)

        GUICtrlSetState($ComboTask, $GUI_DISABLE)
        GUICtrlSetState($ComboToolChain, $GUI_DISABLE)

        WildButton_Enable(False)
        StartElapsedTimer()

        _GUICtrlMenu_EnableMenuItem($hAction, $idBuild,     2, False)
        _GUICtrlMenu_EnableMenuItem($hAction, $idRebuild,   2, False)
        _GUICtrlMenu_EnableMenuItem($hAction, $idCleanUp,   2, False)
        _GUICtrlMenu_EnableMenuItem($hAction, $idPause,     0, False)
        _GUICtrlMenu_EnableMenuItem($hAction, $idStop,      0, False)

        _GUICtrlMenu_EnableMenuItem($hConsole, $idLoadLog,  2, False)   ; 2: disable
        ;StatusBar_SetText("Running", 2)

    Else    ; IDLE now
        GUICtrlSetState($ButtonStart,   $GUI_ENABLE)
        GUICtrlSetState($ButtonCleanUp, $GUI_ENABLE)
        GUICtrlSetState($ButtonRebuild, $GUI_ENABLE)
        GUICtrlSetState($ButtonPause,   $GUI_DISABLE)
        GUICtrlSetState($ButtonStop,    $GUI_DISABLE)

        GUICtrlSetState($ComboTask, $GUI_ENABLE)
        GUICtrlSetState($ComboToolChain, $GUI_ENABLE)

        WildButton_Enable(True)
        StatusBar_SetText("Idle", 2)
        StopElapsedTimer()

        _GUICtrlMenu_EnableMenuItem($hAction, $idBuild,     0, False)
        _GUICtrlMenu_EnableMenuItem($hAction, $idRebuild,   0, False)
        _GUICtrlMenu_EnableMenuItem($hAction, $idCleanUp,   0, False)
        _GUICtrlMenu_EnableMenuItem($hAction, $idPause,     2, False)
        _GUICtrlMenu_EnableMenuItem($hAction, $idStop,      2, False)

        _GUICtrlMenu_EnableMenuItem($hConsole, $idLoadLog,  0, False)   ; 0: disable
    EndIf
EndFunc

;
; Load a log file into the console
;
Func LoadLog()
    If $GlobalCorgiIsBusy Then Return

    Local $LoadingLog = FileOpenDialog ("Select a Console Log to Load ", $CorgiTempDir, "LOG (*.log)|All Files (*.*)", 1+2, "")
    If $LoadingLog == "" Then Return

    Local $LogContent = FileRead($LoadingLog)
    If @error Then Return

    TConsoleCleanUp()
    TConsoleWrite($LogContent)
    If Not $MainFormEnlarged Then
        MainFormResize(1)
        $MainFormEnlarged = 1
    EndIf
    $LogContent = ""

EndFunc

;
; Dump the console content to notepad.exe
;
Func DumpToNotepad()
    If _GUICtrlEdit_GetTextLen($Edit3) == 0 Then
        return
    EndIf
    
    Local $CpText
    Local $LogFileName
    Local $NotePadCmd
    
    $CpText = ""
    ;$Global_CorgiEditor
    $NotePadCmd = "notepad.exe"
    $LogFileName = TConsoleLogFileName()
    If $LogFileName <> "" Then
        $NotePadCmd &= ' "' & $LogFileName & '"'
    Else
        $CpText = _GUICtrlEdit_GetText($Edit3)
    EndIf
    Run($NotePadCmd)
    WinWaitActive("[Class:Notepad]", "", 10)
    If WinExists ("[CLASS:Notepad]") Then
        If $LogFileName == "" Then
            ClipPut($CpText)
            ControlSend("[CLASS:Notepad]", "", "Edit1", "^V")
        EndIf
    Else
        Msgbox(48, "Error", "Fail to launch editor !")
    EndIf
EndFunc

;
; shellexecute a selected text as a path
;
Func ExecSelected()
    Local $se = _GUICtrlEdit_GetSel($Edit3)
    If $se[1] > $se[0] Then
        Local $AllText = _GUICtrlEdit_GetText($Edit3)
        Local $CpText = StringMid($AllText, $se[0]+1, $se[1]-$se[0])
        Local $CmdList = StringSplit($CpText, @CRLF, 1)
        Local $FAttr = FileGetAttrib ($CmdList[1])

        If Not FileExists($CmdList[1]) Then
            MsgBox(16, "Oops!", $CmdList[1] & "does not exist!")
            return
        EndIf

        Local $CmdStr = $CmdList[1]
        If StringInStr ($FAttr, "D") Then               ; Is it a directory?
            TLaunchDirectory($CmdStr)
        Else
            TFreeRun($CmdStr, @SW_MAXIMIZE)
        EndIf
    EndIf
EndFunc

;
; edit a selected text as a file path
;
Func EditSelected()
    Local $se = _GUICtrlEdit_GetSel($Edit3)
    If $se[1] > $se[0] Then
        Local $AllText = _GUICtrlEdit_GetText($Edit3)
        Local $CpText = StringMid($AllText, $se[0]+1, $se[1]-$se[0])
        Local $CmdList = StringSplit($CpText, @CRLF, 1)
        Local $FAttr =  FileGetAttrib ($CmdList[1])

        If Not FileExists($CmdList[1]) Then
            MsgBox(16, "Oops!", $CmdList[1] & "does not exist!")
            return
        EndIf

        Local $CmdStr = '"' & $CmdList[1] & '"'

        If StringInStr ($FAttr, "D") Then               ; Is it a directory?
            MsgBox(16, "Oops!", $CmdStr & "is not a regular file!")
        Else
            TEdit($CmdStr)
        EndIf
    EndIf
EndFunc

;Local $ConsoleSaveFile  = ""

Func ConsoleSave($hWnd)
    Local $ConsoleSaveFile = FileSaveDialog  ("File Name To Save The Console Text", @WorkingDir, "All Files (*.*)", 2+16, "", $hWnd)
    If @error Then Return
    Local $CpText = _GUICtrlEdit_GetText($Edit3)
    FileWrite($ConsoleSaveFile, $CpText)
EndFunc

Global $ConsoleFindText = ""
Global $ConsoleFindTextOccurrence = 0
Global $ResetSearchPointer = False

Func ConsoleFind($hWnd, $Direction=1, $CaseSensitive=False)
    ;
    ; TODO: elaborated the dialogue box!
    ;
    Local $ConsoleText = _GUICtrlEdit_GetText($Edit3)
    If $ConsoleText == "" Then Return

    $ConsoleFindText = InputBox("Find", "Specify a text string to search:", $ConsoleFindText, "", -1, 150, Default, Default, 0, $hWnd)
    If @error Or $ConsoleFindText == "" Then Return

    Local $pos = StringInStr($ConsoleText, $ConsoleFindText, $CaseSensitive, $Direction)
    If $pos > 0 Then
        _GUICtrlEdit_SetSel($Edit3, $pos-1, $pos+StringLen($ConsoleFindText)-1)
        _GUICtrlEdit_Scroll($Edit3, $SB_SCROLLCARET)
        $ConsoleFindTextOccurrence += $Direction
    Else
        Msgbox(48, "Console", $ConsoleFindText & " is not found.")
        $ConsoleFindTextOccurrence = 0
    EndIf
EndFunc

Func ConsoleFindNext($hWnd, $Recursive=1)

    If ($Recursive > 2) Then Return             ; something abnormal happens...

    If ($Recursive == 1) Then
        If ($ConsoleFindText == "" OR $ConsoleFindTextOccurrence == 0) Then
        ConsoleFind($hWnd)
        $ResetSearchPointer = False
        Return
        EndIf
    EndIf

    Local $ConsoleText = _GUICtrlEdit_GetText($Edit3)
    If ($ConsoleText == "") Then Return

    Local $CaretCharIndex

    If $ResetSearchPointer Then
        $ConsoleFindTextOccurrence = 0
        $CaretCharIndex = 0
        $ResetSearchPointer = False
    Else
        Local $GCEGS = _GUICtrlEdit_GetSel($Edit3)
        $CaretCharIndex = $GCEGS[1]

        $ConsoleText = StringTrimLeft($ConsoleText,$CaretCharIndex)
        ;MsgBox(0, $CaretCharIndex, $ConsoleText)
    EndIf


    Local $pos = StringInStr($ConsoleText, $ConsoleFindText, 0, 1)
    If $pos > 0 Then
        _GUICtrlEdit_SetSel($Edit3, $CaretCharIndex+$pos-1, $CaretCharIndex+$pos+StringLen($ConsoleFindText)-1)
        _GUICtrlEdit_Scroll($Edit3, $SB_SCROLLCARET)
        $ConsoleFindTextOccurrence += 1
    Else
        If MsgBox(4+32, "Console", "No additional match found." & @CRLF & "Restart search from the beginning?") == 6 Then   ; "yes"
            $ResetSearchPointer = True
            $ConsoleFindTextOccurrence = 0
            ConsoleFindNext($hWnd, $Recursive+1)
        Else
            Return
        EndIf
    EndIf

    $ConsoleText = ""
    ;MsgBox(0, "ConsoleFindTextOccurrence", $ConsoleFindTextOccurrence)
EndFunc


Func ConsoleFindPrevious($hWnd, $Recursive=1)

    If $Recursive > 2 Then Return               ; something abnormal happens...

    If $Recursive == 1 Then
        If $ConsoleFindText == "" OR $ConsoleFindTextOccurrence == 0 Then
            ConsoleFind($hWnd, -1)
            $ResetSearchPointer = False
            Return
        EndIf
    EndIf

    Local $ConsoleText = _GUICtrlEdit_GetText($Edit3)
    If $ConsoleText == "" Then Return

    Local $CaretCharIndex

    If $ResetSearchPointer Then
        $CaretCharIndex = _GUICtrlEdit_GetTextLen($Edit3)
        $ResetSearchPointer = False
    Else
        Local $GCEGS = _GUICtrlEdit_GetSel($Edit3)
        $CaretCharIndex = $GCEGS[0]

        If $CaretCharIndex > 0 Then $CaretCharIndex -= 1
        $ConsoleText = StringLeft ($ConsoleText,$CaretCharIndex)
        ;MsgBox(0, $CaretCharIndex, $ConsoleText)
    EndIf

    Local $pos = StringInStr($ConsoleText, $ConsoleFindText, 0, -1)
    If $pos > 0 Then
        _GUICtrlEdit_SetSel($Edit3, $pos-1, $pos+StringLen($ConsoleFindText)-1)
        _GUICtrlEdit_Scroll($Edit3, $SB_SCROLLCARET)
        $ConsoleFindTextOccurrence -= 1
    Else
        If MsgBox(4+32, "Console", "No additional match found." & @CRLF & "Restart search from the end?") == 6 Then ; "yes"
            $ResetSearchPointer = True
            $ConsoleFindTextOccurrence = 0
            ConsoleFindPrevious($hWnd, $Recursive+1)
        Else
            Return
        EndIf
    EndIf
    $ConsoleText = ""
    ;MsgBox(0, "ConsoleFindTextOccurrence", $ConsoleFindTextOccurrence)
EndFunc


Func MainForm_Maximize()
    _GUICtrlStatusBar_Resize($StatusBar1)
EndFunc


Func MainForm_Resize()
    _GUICtrlStatusBar_Resize($StatusBar1)
EndFunc

Global $MainForm_WinTitleX = ""

Func StatusBar_SetText($Message, $Part=1)
    _GUICtrlStatusBar_SetText($StatusBar1, $Message, $Part)
    StatusBar_SetShellIcon(1)

    If ($Part <> 2) and ($MainForm_WinTitleX <> "") Then Return
    
    Local $Input4X = StringStripWS(GUICtrlRead($Input4), 1+2) ; "1+2" = strip leading/trailing space
    ;Pythonic:  $StatusX = 'Corgi' if (not Status2 and not Input4X) else ' - '.join([Status2, Input4X)]
    Local $StatusX = $Message
    If ($StatusX <> "") And ($Input4X <> "") Then
        $StatusX &= ' - '
    EndIf
    $StatusX &= $Input4X
    If $StatusX == "" Then
        $StatusX = 'Corgi'
    EndIf

    WinSetTitle($MainForm, "", $StatusX)
    $MainForm_WinTitleX = $StatusX

EndFunc

;
; $Index :  -1 = remove icon
;       other = index of shhell32.dll's internal icon
;

Func StatusBar_SetShellIcon($Index)
    _GUICtrlStatusBar_SetIcon ($StatusBar1, 0, $Index, "shell32.dll")
EndFunc


Func AboutCorgi()
    GUISetState(@SW_SHOW, $AboutForm1)
EndFunc

; Resize the status bar when GUI size changes
Func StatusBar_WM_SIZE($hWnd, $iMsg, $iwParam, $ilParam)
    #forceref $hWnd, $iMsg, $iwParam, $ilParam
    _GUICtrlStatusBar_Resize($StatusBar1)
    Return $GUI_RUNDEFMSG
EndFunc   ;==>StatusBar_WM_SIZE

Local $aParts[6] = [25, 180, 300, 500, 700, 800]
_GUICtrlStatusBar_SetParts($StatusBar1, $aParts)

GUIRegisterMsg($WM_SIZE, "StatusBar_WM_SIZE")
GUISetOnEvent($GUI_EVENT_MAXIMIZE, "MainForm_Maximize")
GUISetOnEvent($GUI_EVENT_RESIZED, "MainForm_Resize")