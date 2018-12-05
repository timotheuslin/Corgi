#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.2.12.1
 Author:         Timothy Lin @ Phoenix  2009/May

 Script Function:
    Template AutoIt script.

#ce ----------------------------------------------------------------------------

#include-once

#include <Process.au3>

#Region ### Parent Process - start ###

Global  $GlobalChildId          = 0

Global  $IpcControlString       = "IpcCtrl"
Global  $IpcMessageDoneString   = "IpcMsgDone"

Const   $IpcControlMsg          = "IpCcTrL-"
Const   $IpcMessageDoneMsg      = "DoNe"
Const   $DoneMsg                = $IpcControlMsg & $IpcMessageDoneMsg
Global  $CpDirString            = "CpDir"
Global  $HuskyDebugModeString   = "HuskyDbg"

Global  $GlobalCmdBatchFile     = ""
Global  $GlobalCmdBatchHandle   = 0

Func GlobalCmdBatchClean()
    ;
    ; The batch file is opened, which means we have to clean/delete it.
    ;
    If FileExists($GlobalCmdBatchFile) Then
        If $GlobalCmdBatchHandle <> 0 Then
            FileClose($GlobalCmdBatchHandle)
            $GlobalCmdBatchHandle = 0
        EndIf
        Sleep(100)
        FileDelete($GlobalCmdBatchFile)
        $GlobalCmdBatchFile = ""
    EndIf

EndFunc

;Global $StartTimeStamp

; ParentReceiver() - Receive IPC message from child process and dump the message to the console until "done-signal" is received (at parent side)
;
; Todo: Beware, there is still a chance that one "control message" is split accidentally into 2 pieces of strings
;
Func ParentReceiver($Str)

    Local $PrStrLoc = StringInStr($Str, $CmdClearScreen_IpcKey, 0, -1)    ; case-insensitive, the first instance from the right side.
    If $PrStrLoc > 0 Then
        $Str = StringTrimLeft($Str, $PrStrLoc + StringLen($CmdClearScreen_IpcKey))
        TConsoleCleanUp()
    EndIf

    If StringInStr($Str, $DoneMsg) Then
        $Str = StringReplace($Str, $DoneMsg, "", 1, 1)  ; one occurrence, case-sensitive
        TConsoleWrite($Str)
        TConsoleWrite(@CRLF & $ConsoleDoneString & $CRLFx2)
        CoProcess_Stop(True)
        SetButtonPauseState(True)

        If Not WinActive($MainForm) Then
            WinFlash($MainForm, "", 2, 50)
        EndIf

        TRunningState(False)
        GlobalCmdBatchClean()
    Else
        If $DebugMode Then
            Local $TimeStr = " @ " & Timer_GetElapsedTime() & @CRLF
            $Str = StringReplace($Str, @CRLF, $TimeStr, -1, 1)
        EndIf

        TConsoleWrite($Str)
    EndIf
EndFunc


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; CoProcess_Execution() - execute a command/encoded-command-list (at parent side)

Global $MainFormEnlarged = 0

Func CoProcess_Execution($Cmd, $WorkingDirectory=".", $FireAndForget=False)

    Console_SetFocus()

    If Not $MainFormEnlarged Then
        MainFormResize(1)
        $MainFormEnlarged = 1
    EndIf

    If $WorkingDirectory == "" Then
        TRunningState(False)
        return
    EndIf

    If Not $FireAndForget Then
        TRunningState(True)
    EndIf

    ;
    ; Setup inter-process-communication variables
    ;
    EnvSet("FAF",                   $FireAndForget)
    EnvSet($IpcControlString,       $IpcControlMsg)
    EnvSet($IpcMessageDoneString,   $IpcMessageDoneMsg)
    EnvSet($CpDirString,            $WorkingDirectory)
    EnvSet($HuskyDebugModeString,   $DebugMode)

    GlobalCmdBatchClean()
    ;
    ; Create a private working directory to place the temporary batch file.
    ;
    If (FileExists($CorgiTempDir) == 0 AND DirCreate($CorgiTempDir) <> 1) Then
        MsgBox(48+1,"", "Cannot Create Temporary Directory: " & $CorgiTempDir)
    EndIf
    Local $TmpBatch = _TempFile($CorgiTempDir, @YEAR&@MON&@MDAY&"."&@HOUR&@MIN&@SEC&"."&@MSEC&"."&StringReplace($GlobalTaskSectionName[$GlobalTaskId], " ", ".")&".", ".bat", 4)

    ;
    ; Change directory to the designated working directory.
    ;
    If (StringCompare($WorkingDirectory, ".") <> 0) AND _
       (StringCompare($WorkingDirectory, @WorkingDir, 2) <> 0) Then
        ; TODO/NEWREL: error message in console
        ;If Not FileExists($WorkingDirectory) Then
        ;    AppendPrologueCommand("IF not exist " & $WorkingDirectory & " ECHO Directory does not exist: " & $WorkingDirectory)
        ;EndIf
        AppendPrologueCommand("CD /D " & $WorkingDirectory)
    EndIf

    If ($Cmd <> "") Then
        AppendExecCommand($Cmd)
    EndIf

    If $FireAndForget Then
        AppendEpilogueCommand("PAUSE")                  ; TODO: add an option to decide if the batch file will pause at the end of the task.
        AppendEpilogueCommand("DEL /F " & $TmpBatch)    ; TODO: add an option to decide if the batch file will be delete when the task is done.
    EndIf

    Local $CmdLines = GenerateRunCommand()

    FileWriteLine($TmpBatch, $CmdLines)

    ;
    ; open the batch file to make it "locked"
    ;
    If Not $FireAndForget Then
        $GlobalCmdBatchFile = $TmpBatch
        $GlobalCmdBatchHandle = FileOpen($GlobalCmdBatchFile, 0)
    EndIf

    If $ViewBatchFile Then
        TEdit($TmpBatch)
        TConsoleWrite(@CRLF & $ConsoleScript2EditorString & @CRLF)
        TRunningState(False)

        ;
        ; shall we delete the batch?
        ;
    Else
        Dim $GlobalChildId = _CoProc ("ChildProcess", $TmpBatch)
    EndIf

EndFunc


Enum $Enum_CoProcessPause = 1, $Enum_CoProcessResume=2, $Enum_CoProcessStop=3


;CoProcess_Pause() - Pause/resume the execution of the child process(es)

Func CoProcess_Pause($Pause)
    Local $PauseResumeStr
    Local $PRS = 0

    PauseElapsedTimer($Pause)

    If $Pause Then
        $PauseResumeStr = "Pause"
        $PRS = $Enum_CoProcessPause
    Else
        $PauseResumeStr = "Resume"
        $PRS = $Enum_CoProcessResume
    EndIf
    TDebugConsoleWrite(@CRLF & "Attempt to " & $PauseResumeStr & " Following Process(es):" & @CRLF)
    _CoProcess_PauseResumeStop($PRS, $GlobalChildId)
EndFunc


;CoProcess_Stop() - Stop the execution of the child process(es)

Func CoProcess_Stop($CleanUp=False)
    If Not $CleanUp Then
        TDebugConsoleWrite(@CRLF & "Attempt to Stop Following Process(es):" & @CRLF)
    EndIf
    _CoProcess_PauseResumeStop($Enum_CoProcessStop, $GlobalChildId)
    $GlobalChildId = 0
    TRunningState(False)

    TConsoleWrite("Elapsed Time: " & Timer_GetElapsedTime() & @CRLF)
    TConsoleWrite(DateTime_GetCurrentDateTime() & @CRLF)

    ;If $LogFileHandle > 0 Then
    ;   FileFlush($LogFileHandle)
    ;EndIf
EndFunc


;_CoProcess_PauseResumeStop() - a generic routine to pause/resume/stop all child processes (recursively)

$ExternalTaskKill = True

Func _CoProcess_PauseResumeStop($PRS, $PID)

    If $PID == 0 OR Not ProcessExists($PID) Then
        Return
    EndIf

    If ($PRS == $Enum_CoProcessStop) AND ($ExternalTaskKill) Then
        TDebugConsoleWrite(@CRLF & "Taskkill /F /T /PID " & $GlobalChildId & @CRLF)
        ShellExecuteWait(@SystemDir & "\taskkill.exe", " /F /T /PID " & $PID, "", "", @SW_HIDE)
        Sleep(100)
        ;MsgBox(0, "", "Taskkill /F /T /PID " & $GlobalChildId)
        return
    EndIf

    Local $Child = _GetChildProcessList($PID)
    Local $i
        For $i = 1 to $Child[0][0]
            If $PID == $Child[$i][0] Then
                ContinueLoop
            EndIf
            _CoProcess_PauseResumeStop($PRS, $Child[$i][0])
        Next

    TDebugConsoleWrite(_ProcessGetName($PID) & @CRLF)

    Switch $PRS
    Case $Enum_CoProcessPause
        _ProcSuspend($PID)
    Case $Enum_CoProcessResume
        _ProcResume($PID)
    Case $Enum_CoProcessStop
        ProcessClose($PID)
    EndSwitch

    $Child = 0
EndFunc

#Region ### Parent Process - end ###

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


#Region ### Child Process - start ###



; ChildProcess() - Execute a child process with a specify command/encoded-command-list
;
; Here, $Cmd accepts 2 flavors of commands: 1) plain one-line command 2) multi-line commands which are encrypted to be a hexadecimal string with a leading "0x"

Func ChildProcess($Cmd)

    ; Please ignore au3check's error message of const redifinition since this portion is in a "child process"
    $CpDirString        = "CpDir"
    $HuskyDebugModeString   = "HuskyDbg"

    Local   $WorkingDir     = EnvGet($CpDirString)
    Local   $DebugMode  = EnvGet($HuskyDebugModeString)
    Local   $FireAndForget  = EnvGet("FAF")

    ;EnvSet("CoProcParameter", "")
    ;Envset("CoProc", "")

    If StringCompare($FireAndForget, "True") <>0 Then
        $FireAndForget = False
    Else
        $FireAndForget = True
    EndIf


    ;If $DebugMode <> 0 Then
;use wildcardbutton to debug this :)        _CP_Exec("set", $WorkingDir)
    ;EndIf

    AutoItSetOption("ExpandEnvStrings", 1)

    If StringCompare(StringLeft($Cmd, 2), "0x") == 0 Then
        Local $CmdX = BinaryToString($Cmd)
        Local $CmdList = StringSplit($CmdX, @CRLF, 1)
        ;If @Error Then
        ;   MsgBox(16, "Ouch", "Invalid command list: " & $CmdX)
        ;EndIf
        For $i= 1 to $CmdList[0]
            _CP_Exec($CmdList[$i], $WorkingDir, $FireAndForget)
        Next
    Else
        _CP_Exec($Cmd, $WorkingDir, $FireAndForget)
    EndIf

    If Not $FireAndForget Then
        _CP_NotifyChildTermination()
    Else
        _CoProcSend($gi_CoProcParent, @CRLF & $ConsoleDoneString & @CRLF)
    EndIf

    AutoItSetOption("ExpandEnvStrings", 0)

EndFunc


; _CP_Exec() - execute a command
;
; Generally, if you execute a command-line program with "UseShell=False", the program will run bizarrely.
;
Func _CP_Exec($Command, $WorkingDirectory=".", $FireAndForget=False)


    Local $lines
    Local $RunCommand = @ComSpec & " /c " & $Command
    Local $ErrorCode

    ;If $UseShell Then
    ;   $RunCommand = @ComSpec & " /c " & $Command
    ;Else
    ;   $RunCommand = $Command
    ;EndIf

    ;MsgBox(0, $RunCommand, $WorkingDirectory)

    ;
    ; Find a working directory anyway. ---- Any other neat way?
    ;
    AutoItSetOption("ExpandEnvStrings", 1)
    If NOT FileExists($WorkingDirectory) Then
        $WorkingDirectory = $CorgiTempDir
    EndIf

    _CoProcSend ($gi_CoProcParent, $WorkingDirectory & "> " & $RunCommand & @CRLF)

    AutoItSetOption("ExpandEnvStrings", 0)

    If $FireAndForget Then
        Local $Pid
        ;$Pid = Run($RunCommand, $WorkingDirectory, @SW_HIDE)
        $Pid = Run($RunCommand, $WorkingDirectory)
        If @Error Then
            $ErrorCode  = @Error
            Sleep(100)
            _CoProcSend ($gi_CoProcParent, @CRLF & "Oops: Run() fails with error code: " & $ErrorCode & @CRLF)
            Return
        EndIf
        Sleep(100)
        _CoProcSend ($gi_CoProcParent, @CRLF & "A de-coupled sub-process is launched with PID: " & $Pid & @CRLF)
        Return
    EndIf


    Local $ShellScriptId = Run($RunCommand, $WorkingDirectory, @SW_HIDE, 15)
    If @Error Then
        $ErrorCode  = @Error
        Sleep(181)
        _CoProcSend ($gi_CoProcParent, @CRLF & "Oops: Run() fails with error code: " & $ErrorCode & @CRLF)
        Return
    EndIf

    While 1
        $lines = StdoutRead($ShellScriptId)
        If @error then ExitLoop
        IF $lines <> ""  Then
            _CoProcSend ($gi_CoProcParent, $lines)
        EndIF
        Sleep(73)
    WEnd

    Sleep(137)

    ProcessClose($ShellScriptId)
    $ShellScriptId = 0

EndFunc

; _CP_NotifyChildTermination() - notify the parent that the child process's task is complete

Func _CP_NotifyChildTermination()

    $IpcControlString           = "IpcCtrl"
    $IpcMessageDoneString       = "IpcMsgDone"

    Local $TerminateSignature1  = EnvGet($IpcControlString)
    Local $TerminateSignature2  = EnvGet($IpcMessageDoneString)

    ; send terminate string to parent
    _CoProcSend($gi_CoProcParent, $TerminateSignature1 & $TerminateSignature2)
EndFunc


#Region ### Child Process - end ###
