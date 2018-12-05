#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.2.12.1
 Author:         myName

 Script Function:
    Template AutoIt script.

#ce ----------------------------------------------------------------------------

#include-once

#include <GuiMenu.au3>
#include <GuiConstantsEx.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>
#Include <GuiEdit.au3>
#include <ScrollBarConstants.au3>
#Include <WinAPI.au3>

Global Enum $idImportConfig = 1000, $idExportConfig, $idExit, $idCopy, $idClean, $idHelpx, $idSelectAllnCopy, $idAbout, _
        $idDumpToNotepad, $idExecSelected, $idSaveconfig, $idWordWrap, $idQuickRun, $idIncreaseFontSize, _
        $idDecreaseFontSize, $idEditSelected, $idPopLogDirectory, $idEditConfig, $idLoadLog, _
        $idBuild, $idRebuild, $idCleanUp, $idPause, $idStop, $idDebug, $idBatchOnly, $idConfigFont

Local $hConsole = _GUICtrlMenu_CreateMenu ()
_GUICtrlMenu_InsertMenuItem ($hConsole,  0, "&Copy Selected",           $idCopy)
_GUICtrlMenu_InsertMenuItem ($hConsole,  1, "Copy &All",                $idSelectAllnCopy)
_GUICtrlMenu_InsertMenuItem ($hConsole,  2, "&Empty Console",           $idClean)
_GUICtrlMenu_InsertMenuItem ($hConsole,  3, "Dump to &Notepad",         $idDumpToNotepad)
_GUICtrlMenu_InsertMenuItem ($hConsole,  4, "",             0)
_GUICtrlMenu_InsertMenuItem ($hConsole,  5, "&Open Selected as Path",   $idExecSelected)
_GUICtrlMenu_InsertMenuItem ($hConsole,  6, "",             0)
_GUICtrlMenu_InsertMenuItem ($hConsole,  7, "Config &Font",             $idConfigFont)
_GUICtrlMenu_InsertMenuItem ($hConsole,  8, "&Increase Font Size",      $idIncreaseFontSize)
_GUICtrlMenu_InsertMenuItem( $hConsole,  9, "&Decrease Font Size",      $idDecreaseFontSize)
_GUICtrlMenu_InsertMenuItem( $hConsole, 10, "",             0)
_GUICtrlMenu_InsertMenuItem( $hConsole, 11, "&Load Log",                $idLoadLog)
_GUICtrlMenu_InsertMenuItem( $hConsole, 12, "&Historical Logs",         $idPopLogDirectory)

;_GUICtrlMenu_InsertMenuItem( $hConsole, 9, "",         0)
;_GUICtrlMenu_InsertMenuItem( $hConsole, 10, "WordWrap",        $idWordWrap)

Local $hFile = _GUICtrlMenu_CreateMenu ()
_GUICtrlMenu_InsertMenuItem ($hFile, 41, "&Load Config",    $idImportConfig)
_GUICtrlMenu_InsertMenuItem ($hFile, 42, "&Save Config",    $idSaveConfig)
_GUICtrlMenu_InsertMenuItem ($hFile, 43, "Save Config &As", $idExportConfig)
_GUICtrlMenu_InsertMenuItem ($hFile, 44, "",            0)
_GUICtrlMenu_InsertMenuItem ($hFile, 45, "&Edit Config",    $idEditConfig)
_GUICtrlMenu_InsertMenuItem ($hFile, 46, "",            0)
_GUICtrlMenu_InsertMenuItem ($hFile, 47, "E&xit",       $idExit)

Local $hAction = _GUICtrlMenu_CreateMenu ()
_GUICtrlMenu_InsertMenuItem ($hAction, 31, "&Build  F7",    $idBuild)
_GUICtrlMenu_InsertMenuItem ($hAction, 32, "&Rebuild",      $idRebuild)
_GUICtrlMenu_InsertMenuItem ($hAction, 33, "&Clean",        $idCleanUp)
_GUICtrlMenu_InsertMenuItem ($hAction, 33, "&Pause",        $idPause)
_GUICtrlMenu_InsertMenuItem ($hAction, 33, "&Stop",     $idStop)
_GUICtrlMenu_InsertMenuItem ($hAction, 34, "",          0)
_GUICtrlMenu_InsertMenuItem ($hAction, 35, "&Verbose",      $idDebug)
_GUICtrlMenu_InsertMenuItem ($hAction, 35, "Scrip&t",       $idBatchOnly)

Local $hHelp = _GUICtrlMenu_CreateMenu ()
_GUICtrlMenu_InsertMenuItem ($hHelp, 21, "&Help",        $idHelpx)
_GUICtrlMenu_InsertMenuItem ($hHelp, 22, "",             0)
_GUICtrlMenu_InsertMenuItem ($hHelp, 23, "&About",       $idAbout)

; Create Main menu
Local $hMain = _GUICtrlMenu_CreateMenu ()
_GUICtrlMenu_InsertMenuItem ($hMain,    100, "&File", 0,    $hFile)
_GUICtrlMenu_InsertMenuItem ($hMain,    101, "&Action", 0,  $hAction)
_GUICtrlMenu_InsertMenuItem ($hMain,    102, "&Console", 0,     $hConsole)
_GUICtrlMenu_InsertMenuItem ($hMain,    103, "&Help", 0,    $hHelp)

_GUICtrlMenu_SetMenu ($MainForm, $hMain)

GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

_GUICtrlMenu_EnableMenuItem ($hConsole, $idCopy,        2, False)   ; 2: disable
_GUICtrlMenu_EnableMenuItem ($hConsole, $idSelectAllnCopy,  2, False)   ; 2: disable
_GUICtrlMenu_EnableMenuItem ($hConsole, $idClean,       2, False)   ; 2: disable
_GUICtrlMenu_EnableMenuItem ($hConsole, $idDumpToNotepad,   2, False)   ; 2: disable
_GUICtrlMenu_EnableMenuItem ($hConsole, $idExecSelected,    2, False)   ; 2: disable
_GUICtrlMenu_EnableMenuItem ($hConsole, $idConfigFont,      2, False)   ; 2: disable
_GUICtrlMenu_EnableMenuItem ($hConsole, $idIncreaseFontSize,    2, False)   ; 2: disable
_GUICtrlMenu_EnableMenuItem ($hConsole, $idDecreaseFontSize,    2, False)   ; 2: disable

; Handle menu commands
Func WM_COMMAND($hWnd, $iMsg, $iwParam, $ilParam)
    Switch _WinAPI_LoWord ($iwParam)
        Case $idImportConfig
            Local $NewIni = FileOpenDialog ("Locate an INI File to Load from", @WorkingDir, "INI (*.INI)|All Files (*.*)", 1+2, $GlobalIni)
            If $NewIni == "" Then Return
            __ImportConfigFile($NewIni)

        Case $idExportConfig
            Local $NewIni = FileSaveDialog  ("Specify the INI File Name to Save to", @WorkingDir, "INI (*.INI)|All Files (*.*)", 2+16, $GlobalIni)
            If $NewIni == "" Then Return
            IniUpdateAll($NewIni)
        Case $idSaveConfig
            IniUpdateAll()
        ;Case $idSelectAll
        ;   _GUICtrlEdit_SetSel($Edit3, 1, _GUICtrlEdit_GetTextLen($Edit3))
        Case $idCopy
            Local $se = _GUICtrlEdit_GetSel($Edit3)
            If $se[1] > $se[0] Then
                Local $AllText = _GUICtrlEdit_GetText($Edit3)
                Local $CpText = StringMid($AllText, $se[0]+1, $se[1]-$se[0])
                ClipPut($CpText)
            EndIf
        Case $idSelectAllnCopy
            Local $CpText = _GUICtrlEdit_GetText($Edit3)
            If $CpText <> "" Then ClipPut($CpText)
        Case $idClean
            ;MainFormResize(0)
            TConsoleCleanUp()
        Case $idDumpToNotepad
            DumpToNotepad()
        Case $idExecSelected
            ExecSelected()
        Case $idConfigFont
            Console_ConfigFont()
        Case $idIncreaseFontSize
            ConsoleAdjustFontSize(+1)
        Case $idDecreaseFontSize
            ConsoleAdjustFontSize(-1)
        Case $idLoadLog
            LoadLog()
        Case $idPopLogDirectory
            ShellExecute($CorgiTempDir)
        Case $idEditConfig
            ShellExecute($HomeIni)
        Case $idHelpx
            MsgBox(64, "?", "Need Help?" & @CRLF & "Contact: timothy_lin@phoenix.com")
        Case $idAbout
            AboutCorgi()
;           MsgBox(64, "About", _
;               "Corgi - Version " & $CorgiRevision & @CRLF & @CRLF & _
;               "Original Idea: Simon Yang" & @CRLF & @CRLF & _
;               "GUI Design: Timothy Lin" & @CRLF & @CRLF & _
;               "Consultant: Harrison Hsieh" & @CRLF & @CRLF & _
;               "@ Phoenix, May/2009" _
;           )
        Case $idExit
            _Exit()

        Case $idBuild
            ButtonStartFunc()

        Case $idRebuild
            ButtonRebuildFunc()

        Case $idCleanUp
            ButtonCleanUpFunc()

        Case $idPause
            ButtonPauseFunc()

        Case $idStop
            ButtonStopFunc()

        Case $idDebug
            If $DebugMode Then
                $DebugMode = False
            Else
                $DebugMode = True
            EndIf

            _GUICtrlMenu_SetItemChecked($hAction, $idDebug, $DebugMode, False)
        Case $idBatchOnly
            If $ViewBatchFile Then
                $ViewBatchFile = False
            Else
                $ViewBatchFile = True
            EndIf

            _GUICtrlMenu_SetItemChecked($hAction, $idBatchOnly, $ViewBatchFile, False)

    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND


;-----------------------------------------------------------------------------
; Subclassing the pop-menu of an Edit component
;-----------------------------------------------------------------------------

Global Enum $idSave=2000, $idCopyAll, $idFind, $idFindNext, $idFindPrevious

Local $hMenuEdit3 = _GUICtrlMenu_CreatePopup()

_GUICtrlMenu_InsertMenuItem($hMenuEdit3, 00, "Find Text     Ctrl-F",    $idFind)
_GUICtrlMenu_InsertMenuItem($hMenuEdit3, 01, "Find Previous Alt-Up",    $idFindPrevious)
_GUICtrlMenu_InsertMenuItem($hMenuEdit3, 02, "Find Next     Alt-Down",  $idFindNext)
_GUICtrlMenu_InsertMenuItem($hMenuEdit3, 30, "")
_GUICtrlMenu_InsertMenuItem($hMenuEdit3, 04, "Save Console Log",        $idSave)
_GUICtrlMenu_InsertMenuItem($hMenuEdit3, 05, "Clear Console",           $idClean)
_GUICtrlMenu_InsertMenuItem($hMenuEdit3, 06, "Copy Selected Text",      $WM_COPY)
_GUICtrlMenu_InsertMenuItem($hMenuEdit3, 07, "Copy All Text",           $idSelectAllnCopy)
_GUICtrlMenu_InsertMenuItem($hMenuEdit3, 08, "Dump Console to Notepad",     $idDumpToNotepad)
_GUICtrlMenu_InsertMenuItem($hMenuEdit3, 09, "Load Log",            $idLoadLog)
_GUICtrlMenu_InsertMenuItem($hMenuEdit3, 10, "")
_GUICtrlMenu_InsertMenuItem($hMenuEdit3, 11, "Open Selected as Path",       $idExecSelected)
_GUICtrlMenu_InsertMenuItem($hMenuEdit3, 12, "Edit Selected as File",       $idEditSelected)
;_GUICtrlMenu_InsertMenuItem($hMenuEdit3, 13, "Word Wrap",      $idWordWrap)
;_GUICtrlMenu_InsertMenuItem($hMenuEdit3,  10, "Quick Run",         $idQuickRun)
;_GUICtrlMenu_InsertMenuItem($hMenuEdit3, 11, "")


Local $wEdit3ProcHandle = DllCallbackRegister("EditWndProc", "ptr", "hwnd;uint;wparam;lparam")
Local $wEdit3ProcOld = _WinAPI_SetWindowLong(GUICtrlGetHandle($Edit3), $GWL_WNDPROC, DllCallbackGetPtr($wEdit3ProcHandle))

Local $ConsoleWordNotWrap = 0

Global Const $EM_HIDESELECTION = ($WM_USER + 63)
Global Const $EM_SETTARGETDEVICE = ($WM_USER + 72)


Func EditWndProc($hWnd, $Msg, $wParam, $lParam)
    $Consumed = False
    If $hWnd == GUICtrlGetHandle($Edit3) Then
        Switch $Msg
        Case $WM_CONTEXTMENU
            _GUICtrlMenu_TrackPopupMenu($hMenuEdit3, $wParam)
            Return 1
        Case $WM_COMMAND
            Switch $wParam
                Case $WM_COPY
                _SendMessage($hWnd, $wParam)
                Case $idClean
                        ;MainFormResize(0)
                TConsoleCleanUp()
                Case $idSelectAllnCopy
                    _SendMessage($hWnd, $EM_SETSEL, 0, -1)
                    _SendMessage($hWnd, $WM_COPY)
                Case $idEditSelected
                    EditSelected()
                Case $idExecSelected
                ExecSelected()
            case $idDumpToNotepad
                DumpToNotepad()
            Case $idLoadLog
                LoadLog()
            case $idSave
                ConsoleSave($hWnd)
            case $idFind
                ConsoleFind($hWnd)
            case $idFindNext
                ConsoleFindNext($hWnd)
            case $idFindPrevious
                ConsoleFindPrevious($hWnd)
            case $idWordWrap
                Local $Edit3Hwnd = GUICtrlGetHandle($Edit3)

                ;$Edit3 = GUICtrlCreateEdit("", 6, 191, 996, 419, 0x50201844, 0)    ; wordwrap
                ;$Edit3 = GUICtrlCreateEdit("", 6, 191, 996, 419, 0x503018C4, 0)    ; no-wordwrap

                $ConsoleWordNotWrap = BitXor($ConsoleWordNotWrap, 1)
                Local $Style = _WinAPI_GetWindowLong($Edit3Hwnd, $GWL_STYLE)
                ;Local $ExStyle = _WinAPI_GetWindowLong($Edit3Hwnd, $GWL_EXSTYLE)

                ;MsgBox(0, "Style", StringFormat("%X", $Style))

                If ($ConsoleWordNotWrap == 0) Then
                    $Style = BitOr($Style, 0x00100080)
                    ;_WinAPI_SetWindowLong($Edit3Hwnd, $GWL_EXSTYLE, BitAnd(_WinAPI_GetWindowLong($Edit3Hwnd, $GWL_EXSTYLE), BitNot($WS_EX_CLIENTEDGE)))
                Else
                    $Style = BitAnd($Style, BitNot(0x00100080))
                    ;_WinAPI_SetWindowLong($Edit3Hwnd, $GWL_EXSTYLE, BitOr(_WinAPI_GetWindowLong($Edit3Hwnd, $GWL_EXSTYLE), $WS_EX_CLIENTEDGE))
                EndIf

                _WinAPI_SetWindowLong($Edit3Hwnd, $GWL_STYLE, $Style)
                ;_WinAPI_SetWindowLong($Edit3Hwnd, $GWL_EXSTYLE, $ExStyle)

                ;TODO: hide and unhide selection!
                _SendMessage($Edit3Hwnd, $EM_HIDESELECTION, 1, 0)
                _SendMessage($Edit3Hwnd, $EM_SETTARGETDEVICE, 0, $ConsoleWordNotWrap)
                _SendMessage($Edit3Hwnd, $EM_HIDESELECTION, 0, 1)

            case $idQuickRun
                MsgBox(0, "Wa!", "Quick run!")
            EndSwitch
        ;Case $WM_HELP
        Case $WM_MOUSEWHEEL
            Local $KeyStatus=BitAnd($wParam, 0xFFFF)
            If _IsHoveredWnd($hWnd) AND $KeyStatus == 8 Then    ; Ctrl
                ;Local $iWheelDelta=BitShift($wParam, 16)   ; direction is still preserved in the highest bit

                If _WinAPI_HiWord($wParam) > 0 Then
                    ConsoleAdjustFontSize(+1)
                Else
                    ConsoleAdjustFontSize(-1)
                EndIf
            EndIf

;       Case $WM_LBUTTONDBLCLK
;               Local $ConsoleLine = _GUICtrlEdit_GetLine($Edit3, _GUICtrlEdit_LineFromChar($Edit3, -1))
;               Local $ConsoleSelNew = _GUICtrlEdit_GetSel($Edit3)
;               Local $LineIndex = _GUICtrlEdit_LineIndex($Edit3, -1)
;               Local $ColumnIndex = $ConsoleSelNew[0] - $LineIndex
;               Local $PathToOpen = ""
;               Local $ConsoleLineLeft = StringLeft($ConsoleLine, $ColumnIndex)
;               Local $ConsoleLineRight = StringTrimLeft($ConsoleLine, $ColumnIndex)
;
;               ;MsgBox(0, "", $ConsoleLineLeft & " - " & $ConsoleLineRight)
;
;               If $ConsoleSelNew[0] == $ConsoleSelNew[1] Then      ; No selected text
;                   Local $DblClkLeft = StringRegExp($ConsoleLineLeft, "\A([A-Za-z_~0-9]+)\z", 3)
;                   Local $DblClkRight = StringRegExp($ConsoleLineRight, "\A([A-Za-z_~0-9]+).*", 3)
;
;                   MsgBox(0, "", $DblClkLeft[0] & " - " & $DblClkRight[0])
;
;                   Local $DblClkLeftPos
;                   Local $DblClkRightPos
;                   If IsArray($DblClkLeft) AND IsArray($DblClkRight)Then
;                       $DblClkLeftPos = StringInStr($ConsoleLineLeft, $DblClkLeft[0], 1, -1)-1
;                       $DblClkRightPos = StringInStr($ConsoleLineRight, $DblClkRight[0], 1, 1)
;
;                       ;MsgBox(0, $DblClkLeftPos + $LineIndex, $DblClkLeftPos + $LineIndex + StringLen($DblClkLeft[0] & $DblClkRight[0]))
;                       _GUICtrlEdit_SetSel($Edit3, $DblClkLeftPos + $LineIndex, $DblClkLeftPos + $LineIndex + StringLen($DblClkLeft[0] & $DblClkRight[0]))
;                       ;_GUICtrlEdit_SetSel($Edit3,
;                       ;MsgBox(0, "", $DblClkLeftPos & " - " &  $DblClkRightPos + $ConsoleSelNew[1] - $LineIndex )
;                       ;MsgBox(0, "", $DblClkLeft[0] & $DblClkRight[0])
;                       Return
;                   EndIf
;               Else
;
;               EndIf
;
;           ;TODO:  double click behavior
;
;           ;MsgBox(0, "WA!", $ConsoleLineLeft)
;           $Consumed = True

        Case $WM_KEYDOWN, $WM_SYSKEYDOWN
            If _IsPressed("12")  Then         ; Alt
                If _IsPressed("28") Then      ; Alt-Down arrow : find next
                    ConsoleFindNext($hWnd)
                EndIf
            EndIf

            If _IsPressed("12")  Then         ; Alt
                If _IsPressed("26") Then      ; Alt-Up arrow : find previous
                    ConsoleFindPrevious($hWnd)
                EndIf
            EndIf


            If _IsPressed("72")  Then         ; F3 : find next
                ConsoleFindNext($hWnd)
            EndIf


            If _IsPressed("11") Then          ; Ctrl
                If _IsPressed("46") Then      ; Ctrl-F : Find first
                    ConsoleFind($hWnd)
                EndIf

                If _IsPressed("4F") Then            ; Ctrl-O : Load log
                    If Not $GlobalCorgiIsBusy Then
                        LoadLog()
                    EndIf
                EndIf

                If _IsPressed("41") Then      ; Ctrl-A : Select All
                    _GUICtrlEdit_SetSel($Edit3, 1, _GUICtrlEdit_GetTextLen($Edit3))
                EndIf

                ;
                ; Open File/Path in a selected text or at caret position
                ;
                If _IsPressed("44") Then      ; Ctrl-D : Open file at caret
                    Local $ConsoleLine = _GUICtrlEdit_GetLine($Edit3, _GUICtrlEdit_LineFromChar($Edit3, -1))
                    Local $ConsoleSelNew = _GUICtrlEdit_GetSel($Edit3)
                    Local $LineIndex = _GUICtrlEdit_LineIndex($Edit3, -1)
                    Local $ColumnIndex = $ConsoleSelNew[0] - $LineIndex

                    Local $PathToOpen = ""

                    If $ConsoleSelNew[0] == $ConsoleSelNew[1] Then      ; No selected text
                        Local $ConsoleLineLeft = StringLeft($ConsoleLine, $ColumnIndex)
                        Local $ConsoleLineRight = StringTrimLeft($ConsoleLine, $ColumnIndex)

                        Local $PathDelimiters = '"'
                        If StringInStr($ConsoleLineLeft, '"') AND StringInStr($ConsoleLineRight, '"') Then
                            $PathDelimiters = '"'
                        Else
                            $PathDelimiters = " *?<>|" & @TAB & @CR & @LF
                        EndIf

                        Local $CllSplit = StringSplit($ConsoleLineLeft, $PathDelimiters, 0)
                        Local $ClrSplit = StringSplit($ConsoleLineRight, $PathDelimiters, 0)

                        Local $PathAtCaret = ""
                        If $CllSplit[0] > 0 Then
                            $PathAtCaret = $CllSplit[$CllSplit[0]]
                        EndIf

                        If $ClRSplit[0] > 0 Then
                            $PathAtCaret &= $ClrSplit[1]
                        EndIf

                        ;MsgBox(0, "$PathAtCaret", $PathAtCaret)

                        ;
                        ; Here, consider both 1) cannonical path like: C:\Path\File.Ext and 2) Network path like: \\Server\Path\File.Exe
                        ;
                        $PathAtCaretArray = StringRegExp($PathAtCaret, ".*(\\\\.*|\S:\\.*)", 3)
                        If @Error <> 0 Then
                            Return
                        EndIf
                        $PathToOpen = $PathAtCaretArray[0];MsgBox(0, "$PathAtCaretArray[0]", $PathAtCaretArray[0])

                    Else    ; If $ConsoleSelNew[0] == $ConsoleSelNew[1] Then

                        $PathToOpen = StringMid($ConsoleLine, $ColumnIndex+1, $ConsoleSelNew[1]-$ConsoleSelNew[0])

                    EndIf   ; If $ConsoleSelNew[0] == $ConsoleSelNew[1] Then

                    If FileExists($PathToOpen) Then
                        If IsDirectory($PathToOpen) Then
                            TLaunchDirectory($PathToOpen)
                        Else
                            TEdit($PathToOpen)
                        EndIf
                    Else
                        While (StringLen($PathToOpen) > 3)
                            Local $SlashPointer = StringInStr($PathToOpen, "\", 1, -1)
                            If $SlashPointer <= 3 Then
                                ExitLoop
                            EndIf
                            $PathToOpen = StringLeft($PathToOpen, $SlashPointer-1)
                            If FileExists($PathToOpen) Then
                                TLaunchDirectory($PathToOpen)
                                ExitLoop
                            EndIf
                        WEnd
                    EndIf
                EndIf
            EndIf

        EndSwitch
    EndIf

;   If NOT $Consumed Then
        Local $aRet = DllCall("user32.dll", "int", "CallWindowProc", "ptr", $wEdit3ProcOld, _
                          "hwnd", $hWnd, "uint", $Msg, "wparam", $wParam, "lparam", $lParam)
        Return $aRet[0]
;   EndIf
;   Return 0

EndFunc
