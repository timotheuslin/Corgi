
#include-once

#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.1.1 (beta)

 R1 Timothy 12:48 PM 1/8/2014 - "date/time using the format of the Unix "date" command result.
 R0 Timothy Lin 2009/Sep/29

 Script Function:
    Template AutoIt script.

#ce ----------------------------------------------------------------------------

;move to Global.au3:  Global $Global_TimerElapsedTime    = 0

#include "TimeZone.au3"
#Include <Timers.au3>
#Include <Date.au3>

Local $Timer_StartElapsedTimer  = False
Local $Timer_ElapsedTimerId = 0
Local $Timer_StartTimeStamp = 0

Local $Timer_Paused     = False
Local $Timer_PauseStamp     = 0
Local $Timer_PausedTime     = 0

Const $Timer_HiRes      = 100
Const $Timer_LoRes      = 1000

;
; Use a timer of higher resolution when Corgi is busy.
;
Func StartElapsedTimer()

    If $Timer_ElapsedTimerId <> 0 Then
        _Timer_KillTimer($MainForm, $Timer_ElapsedTimerId)
    EndIf
    $Timer_ElapsedTimerId = _Timer_SetTimer($MainForm, $Timer_HiRes, "Timer_UpdateElapsedTime")

    $Timer_StartElapsedTimer = True
    $Timer_StartTimeStamp   = TimerInit()
    $Timer_PausedTime   = 0
    $Timer_Paused       = False
EndFunc

;
; use a slower timer when Corgi is idle.
;
Func StopElapsedTimer()

    $Timer_StartElapsedTimer = False
    $Timer_StartTimeStamp   = 0
    $Timer_Paused       = False

    If $Timer_ElapsedTimerId <> 0 Then
        _Timer_KillTimer($MainForm, $Timer_ElapsedTimerId)
        $Timer_ElapsedTimerId = _Timer_SetTimer($MainForm, $Timer_LoRes, "Timer_UpdateElapsedTime")
    EndIf

EndFunc

;
; Use a timer of higher resolution when Corgi is paused, since we still need a more accurate record of the "paused time"
;
Func PauseElapsedTimer($Paused=True)
    $Timer_Paused       = $Paused
    $Timer_PauseStamp   = TimerInit()
EndFunc

Local $ConsoleCaretLine = 0
Local $ConsoleTextSize = 0
Local $ConsoleSel[2] = [0, 0]

Local $Timer_Old_Display_HM = ""
Local $Timer_Old_LineInfo = ""
Local $Timer_Old_Elapsed_Time_String = ""

Func Timer_UpdateElapsedTime($hWnd, $Msg, $iIDTimer, $dwTime)

    Local $New_Display_HM
    $New_Display_HM = StringFormat("%02d:%02d:%02d", @HOUR, @MIN, @SEC)
    $New_Display_HM &= "     "
    If StringCompare($New_Display_HM, $Timer_Old_Display_HM) <> 0 Then
        $Timer_Old_Display_HM = $New_Display_HM
        StatusBar_SetText(@TAB & @TAB & $New_Display_HM, 5)
    EndIf

    If $Timer_Paused Then
        $Timer_PausedTime = $Timer_PausedTime + TimerDiff($Timer_PauseStamp)    ; accumulate fractions of paused time
        $Timer_PauseStamp = TimerInit()                     ; update timestamp of pause time
    EndIf

    If $Timer_StartElapsedTimer Then
        ;Local $ElapsedTime
        ;Local $ElapsedTimeSec
        ;Local $ElapsedSec
        ;Local $ElapsedMin
        ;Local $ElapsedHour
        Local $Timer_Elapsed_Time_String

        $Global_TimerElapsedTime = (TimerDiff($Timer_StartTimeStamp) - $Timer_PausedTime) / 1000.0
        ;$Global_TimerElapsedTime = $ElapsedTime
        
        $Timer_Elapsed_Time_String = "Elapsed Time: " & Timer_GetElapsedTime()
        
        ;$ElapsedTimeSec = StringFormat("%.2fs", $ElapsedTime)
        ;$ElapsedSec = StringFormat("%d", Mod($ElapsedTime, 60))
        ;$ElapsedTime = $ElapsedTime / 60
        ;$ElapsedMin = StringFormat("%d", Mod($ElapsedTime, 60))
        ;$ElapsedTime = $ElapsedTime / 60
        ;$ElapsedHour = StringFormat("%d", $ElapsedTime)
        ;$Timer_Elapsed_Time_String = ""
        ;$Timer_Elapsed_Time_String = "Elapsed: " & $ElapsedTimeSec & " (" & $ElapsedHour & ":" & $ElapsedMin & ":" & $ElapsedSec & ")"

        If StringCompare($Timer_Elapsed_Time_String ,$Timer_Old_Elapsed_Time_String) <> 0 Then
            $Timer_Old_Elapsed_Time_String = $Timer_Elapsed_Time_String
            StatusBar_SetText($Timer_Elapsed_Time_String, 3)
        EndIf
    EndIf

    DIM $ConsoleSelNew[2]
    Local $ConsoleCaretLineNew
    Local $ConsoleTextSizeNew

    $ConsoleSelNew = _GUICtrlEdit_GetSel($Edit3)
    $ConsoleCaretLineNew = _GUICtrlEdit_LineFromChar($Edit3, -1)+1
    $ConsoleTextSizeNew = _GUICtrlEdit_GetTextLen($Edit3)

    If  $ConsoleCaretLine <> $ConsoleCaretLineNew Or _
        $ConsoleTextSize <> $ConsoleTextSizeNew Or _
        $ConsoleSel <> $ConsoleSelNew Then
        Local $LineInfo

        $LineInfo = "Ln " & $ConsoleCaretLineNew & "/" & _GUICtrlEdit_GetLineCount($Edit3) & ", "
        If $ConsoleSelNew[0] == $ConsoleSelNew[1] Then
                $LineInfo &= "Chr " & $ConsoleSelNew[0] & "/" & $ConsoleTextSizeNew
        Else
                $LineInfo &= "Chr " & $ConsoleSelNew[0] & "-" & $ConsoleSelNew[1] & "/" & $ConsoleTextSizeNew
        EndIf

        If StringCompare ($LineInfo, $Timer_Old_LineInfo) <> 0 Then
            $Timer_Old_LineInfo = $LineInfo
            StatusBar_SetText($LineInfo, 4)
        EndIf

        $ConsoleCaretLine = $ConsoleCaretLineNew
        $ConsoleTextSize = $ConsoleTextSizeNew
        $ConsoleSel = $ConsoleSelNew
    EndIf

EndFunc

Func Timer_GetElapsedTime()
    return StringFormat("%.2fs", $Global_TimerElapsedTime) & _
        " (" & _
        StringFormat("%d", $Global_TimerElapsedTime / 3600) & _
        ":" & _
        StringFormat("%d", Mod($Global_TimerElapsedTime / 60, 60)) & _
        ":" & _
        StringFormat("%d", Mod($Global_TimerElapsedTime, 60)) & _
        ")"
EndFunc

Func DateTime_GetCurrentDateTime()
    Local $aInfo = _Date_Time_GetTimeZoneInformation()
    return                                      _
        StringFormat(                           _
            "%s %s %2d %02d:%02d:%02d %s %s",   _
            _DateDayOfWeek(@WDAY, 1),           _
            _DateToMonth(@MON, 1),              _
            @MDAY, @HOUR, @MIN, @SEC,           _
            TimeZoneDictFullToAbbr($aInfo[2]),  _
            @YEAR                               _
       )
EndFunc

$Timer_ElapsedTimerId = _Timer_SetTimer($MainForm, $Timer_LoRes, "Timer_UpdateElapsedTime")
