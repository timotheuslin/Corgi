#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.10.2
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

#include-once

#include <Misc.au3>
#include "Mouse.au3"
#include "About.au3"
#include "resources.au3"

_GUICtrlEdit_SetLimitText($Edit3, $Global_ConsoleBufferSize)

GUICtrlSetState($ButtonPause,   $GUI_DISABLE)
GUICtrlSetState($ButtonStop,    $GUI_DISABLE)

_ResourceSetImageToCtrl($AboutPic1, "Welsh_Corgi")
GUICtrlSetImage($ButtonStart,   @ScriptFullPath, -5, 1)
GUICtrlSetImage($ButtonRebuild, @ScriptFullPath, -6, 1)
GUICtrlSetImage($ButtonCleanUp, @ScriptFullPath, -7, 1)
GUICtrlSetImage($ButtonPause,   @ScriptFullPath, -8, 1)
GUICtrlSetImage($ButtonStop,    @ScriptFullPath, -10, 1)


Const $ConsoleString        = "Console"
Const $FontNameString       = "Font.Name"
Const $FontSizeString       = "Font.Size"
Const $FontWeightString     = "Font.Weight"
Const $FontAttributeString  = "Font.Attribute"
Const $FontColorString      = "FgColor"
Const $ConsoleBgColorString = "BgColor"


Global $ConsoleFontName
Global $ConsoleFontSize
Global $ConsoleFontWeight
Global $ConsoleFontAttribute
Global $ConsoleFontColor
Global $ConsoleBGColor

Const $DefaultConsoleFontName       =   "Lucida Console"
Const $DefaultConsoleFontSize       =   12
Const $DefaultConsoleFontWeight     =   400
Const $DefaultConsoleFontAttribute  =   0
Const $DefaultConsoleFontColor      =   0xFFFFFF
Const $DefaultConsoleBGColor        =   0

Func Console_Init($INI)
    $ConsoleFontName    = IniRead($INI, $ConsoleString, $FontNameString,    $DefaultConsoleFontName)
    $ConsoleFontSize    = IniRead($INI, $ConsoleString, $FontSizeString,    $DefaultConsoleFontSize)
    $ConsoleFontWeight  = IniRead($INI, $ConsoleString, $FontWeightString,  $DefaultConsoleFontWeight)
    $ConsoleFontAttribute   = IniRead($INI, $ConsoleString, $FontWeightString,  $DefaultConsoleFontAttribute)
    $ConsoleFontColor   = IniRead($INI, $ConsoleString, $FontColorString,   $DefaultConsoleFontColor)
    $ConsoleBGColor     = IniRead($INI, $ConsoleString, $ConsoleBgColorString,  $DefaultConsoleBGColor)

    ;Local $ChosedConsoleFont = _ChooseFont($ConsoleFontName, $ConsoleFontSize, $ConsoleFontColor, $ConsoleFontWeight)
    ;$ConsoleFontName   =   $ChosedConsoleFont[2]
    ;$ConsoleFontSize   =   $ChosedConsoleFont[3]
    ;$ConsoleFontWeight =   $ChosedConsoleFont[4]
    ;$ConsoleFontColor  =       $ChosedConsoleFont[7]
    ;$ConsoleBGColor = _ChooseColor(2, $ConsoleBGColor, 2)

    GUICtrlSetFont($Edit3, $ConsoleFontSize, $ConsoleFontWeight, $ConsoleFontAttribute, $ConsoleFontName)
    GUICtrlSetColor($Edit3, $ConsoleFontColor)
    GUICtrlSetBkColor($Edit3, $ConsoleBGColor)
EndFunc

Func Console_IniUpdate($INI)
    IniUpdate($INI, $ConsoleString, $FontNameString,    $ConsoleFontName)
    IniUpdate($INI, $ConsoleString, $FontSizeString,    $ConsoleFontSize)
    IniUpdate($INI, $ConsoleString, $FontWeightString,  $ConsoleFontWeight)
    IniUpdate($INI, $ConsoleString, $FontColorString,   $ConsoleFontColor)
    IniUpdate($INI, $ConsoleString, $ConsoleBgColorString,  $ConsoleBGColor)
EndFunc


Func Console_SetFocus()
    GUICtrlSetState($Edit3, $GUI_FOCUS)
EndFunc

Func Console_ConfigFont()
    Local $ColorScheme = _ColorConvert($ConsoleFontColor)
    Local $FontScheme = _ChooseFont($ConsoleFontName, $ConsoleFontSize, $ColorScheme, $ConsoleFontWeight)

    If IsArray($FontScheme) And $FontScheme[0] > 5 Then
        $ConsoleFontName    = $FontScheme[2]
        $ConsoleFontSize    = $FontScheme[3]
        $ConsoleFontColor   = $FontScheme[7]
        $ConsoleFontWeight  = $FontScheme[4]

        GUICtrlSetFont($Edit3, $ConsoleFontSize, $ConsoleFontWeight, $ConsoleFontAttribute, $ConsoleFontName)
        GUICtrlSetColor($Edit3, $ConsoleFontColor)
        GUICtrlSetBkColor($Edit3, $ConsoleBGColor)
    EndIf


EndFunc

Func ConsoleAdjustFontSize($PointDelta)
    $ConsoleFontSize += $PointDelta
    Local $FontChanged = True
    If $ConsoleFontSize < 5.5 Then
        $ConsoleFontSize = 5.5
        $FontChanged = False
    EndIf
    If $ConsoleFontSize > 100 Then
        $ConsoleFontSize = 100
        $FontChanged = False
    EndIf
    If $FontChanged Then
        ;useless _GUICtrlEdit_BeginUpdate($Edit3)
        ;Partial parameter causes control to load "default" setting : GUICtrlSetFont($Edit3, $ConsoleFontSize)
        GUICtrlSetFont($Edit3, $ConsoleFontSize, $ConsoleFontWeight, $ConsoleFontAttribute, $ConsoleFontName)
        GUICtrlSetColor($Edit3, $ConsoleFontColor)
        GUICtrlSetBkColor($Edit3, $ConsoleBGColor)
        ;useless _GUICtrlEdit_EndUpdate($Edit3)
    EndIf
EndFunc

;Func ConsoleSetColorFG($FG)
;   GUICtrlSetColor($Edit3, $FG)
;EndFunc

Local $ConsolePreviousInputText = ""

Func TConsoleCleanUp()

    _GUICtrlEdit_SetText($Edit3, "")
    TConsoleLogFileClose()
    _GUICtrlMenu_EnableMenuItem ($hConsole, $idCopy,                2, False)   ; 2: disable
    _GUICtrlMenu_EnableMenuItem ($hConsole, $idSelectAllnCopy,      2, False)   ; 2: disable
    _GUICtrlMenu_EnableMenuItem ($hConsole, $idClean,               2, False)   ; 2: disable
    _GUICtrlMenu_EnableMenuItem ($hConsole, $idDumpToNotepad,       2, False)   ; 2: disable
    _GUICtrlMenu_EnableMenuItem ($hConsole, $idExecSelected,        2, False)   ; 2: disable
    _GUICtrlMenu_EnableMenuItem ($hConsole, $idConfigFont,          2, False)   ; 2: disable
    _GUICtrlMenu_EnableMenuItem ($hConsole, $idIncreaseFontSize,    2, False)   ; 2: disable
    _GUICtrlMenu_EnableMenuItem ($hConsole, $idDecreaseFontSize,    2, False)   ; 2: disable
    $ConsolePreviousInputText = ""

    ;Timothy: never use GUICtrlSetData on an Edit control, this function cause system terminated abnormally
    ;GUICtrlSetData($Edit3, "")
EndFunc


;Information: ;_GUICtrlEdit_BeginUpdate($hEdit) & _GUICtrlEdit_EndUpdate($hEdit) have no effect on alleviate flickers

Func TConsoleWrite($Str)
    If $Str <> "" Then
        _GUICtrlEdit_AppendText($Edit3, $Str)
        TConsoleLogFileWrite($Str)
        If $ConsolePreviousInputText = "" Then
            $ConsolePreviousInputText = $Str

            ; Enable console menu's items when it is not empty
            _GUICtrlMenu_SetItemState($hConsole, 0, False)

            _GUICtrlMenu_EnableMenuItem ($hConsole, $idCopy,                0, False)   ; 0: enable
            _GUICtrlMenu_EnableMenuItem ($hConsole, $idSelectAllnCopy,      0, False)   ; 0: enable
            _GUICtrlMenu_EnableMenuItem ($hConsole, $idClean,               0, False)   ; 0: enable
            _GUICtrlMenu_EnableMenuItem ($hConsole, $idDumpToNotepad,       0, False)   ; 0: enable
            _GUICtrlMenu_EnableMenuItem ($hConsole, $idExecSelected,        0, False)   ; 0: enable
            _GUICtrlMenu_EnableMenuItem ($hConsole, $idConfigFont,          0, False)   ; 0: enable
            _GUICtrlMenu_EnableMenuItem ($hConsole, $idIncreaseFontSize,    0, False)   ; 0: enable
            _GUICtrlMenu_EnableMenuItem ($hConsole, $idDecreaseFontSize,    0, False)   ; 0: enable
        EndIf
    EndIf
EndFunc

Local $ConsoleLogFileHandle = 0
Local $ConsoleLogFileName = ""
Func TConsoleLogFileNew()
    If $Global_EnableConsoleLogging Then
        If $ConsoleLogFileHandle <= 0 Then
            $ConsoleLogFileName = _TempFile($CorgiTempDir, @YEAR&@MON&@MDAY&"."&@HOUR&@MIN&@SEC&"."&@MSEC&".", ".log", 4)
            $ConsoleLogFileHandle = FileOpen($ConsoleLogFileName, 2+128)  ; 2: override, 128: utf8
        EndIf
    EndIf
EndFunc

Func TConsoleLogFileClose()
    If $ConsoleLogFileHandle > 0 Then
        FileClose($ConsoleLogFileHandle)
    EndIf
    $ConsoleLogFileHandle = 0
    $ConsoleLogFileName = ""
EndFunc

Func TConsoleLogFileWrite($Str)
    If $Global_EnableConsoleLogging Then
        If $ConsoleLogFileHandle <= 0 Then
            TConsoleLogFileNew()
        EndIf
        FileWrite($ConsoleLogFileHandle, $Str)
    EndIf
EndFunc

Func TConsoleLogFileName()
    If $Global_EnableConsoleLogging Then
        return $ConsoleLogFileName
    EndIf
    return ""
EndFunc


Func TDebugConsoleWrite($Str)
    If $Str <> "" AND $DebugMode Then
        ;_GUICtrlEdit_BeginUpdate($Edit3)
        _GUICtrlEdit_AppendText($Edit3, $Str)
        ;_GUICtrlEdit_EndUpdate($Edit3)
    EndIf
EndFunc


Func TConsoleErrorWrite($Str)
    TConsoleWrite(@CRLF & "** ERROR: " & $Str & @CRLF)
EndFunc

