#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.10.2
 Author:         Timothy

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

#include-once

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

Global $Global_TimerElapsedTime = 0

Global $Global_EnableConsoleLogging = 1

Global $Global_ConsoleBufferSize = 20*1024*1024

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

$GlobalTaskSectionName[$Enum_GlobalTask_Sct2] = "SCT - Build"
$GlobalTaskSectionName[$Enum_GlobalTask_Sct2_DB] = "SCT - Driver Build"
$GlobalTaskSectionName[$Enum_GlobalTask_RioVerde] = "RioVerde - Build"
$GlobalTaskSectionName[$Enum_GlobalTask_Benton2] = "Benton2 - Build"
$GlobalTaskSectionName[$Enum_GlobalTask_Legacy] = "Legacy - Build"
$GlobalTaskSectionName[$Enum_GlobalTask_GetLegacy] = "Legacy - Get"

Const $CorgiEditorDefault = "C:\Program Files\Notepad++\notepad++.exe"
Const $CorgiEditorDefaultFallbacks = [ _
    "C:\Program Files (x86)\Notepad++\notepad++.exe", _
    "C:\Program Files\Notepad++\notepad++.exe", _
    "c:\windows\system32\notepad.exe"]
Global $Global_CorgiEditor = $CorgiEditorDefault
Global $Global_ToolChain_Str = "ToolChain"
Global $Global_ToolChains_Id = 0

; Ref. UDK's tools_def.template/tools_def.txt
Global $Global_ToolChains[] = [ _
    'MYTOOLS', _
    'VS2008x86', _
    'VS2010x86', _
    'VS2012x86', _
    'VS2013x86', _
    'VS2015x86', _
    'VS2017', _
    'CLANG38', _
    'GCC5' _
    ]

; Global INI data - end

; Global misc data - start
; Ipc Command that clears console
Global $CmdClearScreen = "::{FE8B1CD6-AAB2-464c-B93A-8834711F6FD7}::"
Global $CmdClearScreen_IpcKey = ""
Global $IpcKey = ""
; Global misc data - end
