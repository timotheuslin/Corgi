#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.0.0
 Author:         Timothy Lin

 Script Function:
    
 R0.1   2010/6/22   Timothy

#ce ----------------------------------------------------------------------------

#include-once


Global $PrologueBatch
Global $ExecBatch
Global $EpilogueBatch
Global $FinalBatch

Const $PrologueBatchHeader = _ 
        "::" & @CRLF & _
        ":: Prologue Commands "& @CRLF & _
        "::" & $CRLFx2

Const $ExecBatchHeader = _
        "::" & @CRLF & _
        ":: Major Commands "& @CRLF & _
        "::" & $CRLFx2


Const $EpilogueBatchHeader = _
        "::" & @CRLF & _
        ":: Epilogue Commands "& @CRLF & _
        "::" & $CRLFx2

Func InitBatchCommandList()
    $PrologueBatch  = ""
    $ExecBatch  = ""
    $EpilogueBatch  = ""
    $FinalBatch = ""
EndFunc

Func AppendPrologueCommand($cmd)
    $PrologueBatch = $PrologueBatch & $cmd & @CRLF
    ;If $DebugMode Then
    ;   $PrologueBatch = $PrologueBatch & "ECHO %TIME%" & @CRLF
    ;EndIf
EndFunc

Func AppendExecCommand($cmd)
    $cmd = StringReplace($cmd, $CmdClearScreen, @CRLF & "@ECHO " & $CmdClearScreen_IpcKey & @CRLF, 0, 0)  ; all occurrences, case-insensitive
    $ExecBatch = $ExecBatch & $cmd & @CRLF
    ;If $DebugMode Then
    ;   $ExecBatch = $ExecBatch & "ECHO %TIME%" & @CRLF
    ;EndIf
EndFunc

Func AppendEpilogueCommand($cmd)
    $EpilogueBatch = $EpilogueBatch & $cmd & @CRLF
    ;If $DebugMode Then
    ;   $EpilogueBatch = $EpilogueBatch & "ECHO %TIME%" & @CRLF
    ;EndIf
EndFunc

Func GenerateRunCommand()

    $FinalBatch = _
            "::"  & @CRLF & _
            ":: Batch Script Created By Corgi " & $CorgiRevision & @CRLF & _
            "::"  & @CRLF & _
            ":: " & $GlobalTaskSectionName[$GlobalTaskId] & " : " & $TaskCommand & @CRLF & _
            "::"  & @CRLF & _
            ":: " & @YEAR&"/"&@MON&"/"&@MDAY&"  "&@HOUR&":"&@MIN&":"&@SEC&@CRLF & _
            "::"  & $CRLFx2
        

    If NOT $DebugMode Then
        $FinalBatch = $FinalBatch & "@ECHO OFF" & $CRLFx2
    EndIf
    
    ;If $DebugMode Then
    ;   $FinalBatch = $FinalBatch & "ECHO %TIME%" & @CRLF
    ;EndIf

    $FinalBatch = $FinalBatch & "SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION" & $CRLFx2

    If $PrologueBatch <> "" Then
        $FinalBatch = $FinalBatch & $PrologueBatchHeader & $PrologueBatch & @CRLF
    EndIf
    
    If $ExecBatch <> "" Then
        $FinalBatch = $FinalBatch & $ExecBatchHeader & $ExecBatch & @CRLF
    EndIf
    
    If $EpilogueBatch <> "" Then
        $FinalBatch = $FinalBatch & $EpilogueBatchHeader & $EpilogueBatch & $CRLFx2
    EndIf

    $FinalBatch = $FinalBatch & "ENDLOCAL" & @CRLF

    return $FinalBatch
EndFunc