;
; find all child process
;
; http://read-only.autoitscript.com/forum/index.php?s=ec53a82b72ce09a9cccc6900891e7a13&showtopic=59041
; by JerryD
;

#include-once

#region Sample Code
#cs
#include <array.au3>
$ProcList = ProcessList ( )
For $i = 1 To $ProcList[0][0]
    $Child = _ChildProcess ( $ProcList[$i][1] )
    $Err = @error
    If $Child[0][0] > 0 Then
        _ArrayDisplay ( $Child, 'Children of ' & $ProcList[$i][0] & ' [' & $ProcList[$i][1] & ']' & ' - Error: ' & $Err )
    EndIf
Next
#ce
#endregion Sample Code

;===============================================================================
; Function Name:    _ChildProcess
; Description:    Returns an array containing child process info
; Parameter(s):  $iParentPID - Parent Process PID
;          
; Requirement(s):   AutoIt 3.8+
; Return Value(s):  two dimensional array $aChildren[][] as follows
;               $aChildren[0][0] = Number of children found
;
;               $aChildren[x][0] = Child Process's PID (called Handle, but not a handle object)
;               $aChildren[x][1] = Child Process's Name
;               $aChildren[x][2] = Child Process's Command Line
;               $aChildren[x][3] = Child Process's Executable Path
;               $aChildren[x][4] = Child Process's Creation Date and Time
;               $aChildren[x][5] = Child Process's Session Id
;               $aChildren[x][6] = Child Process's Status
;               $aChildren[x][7] = Child Process's Termination Date
;
; AutoIt Version:   3.2.8.1
; Author:         JerryD
;===============================================================================

Func _GetChildProcessList ( $iParentPID )
    Local Const $wbemFlagReturnImmediately = 0x10, $wbemFlagForwardOnly = 0x20
    Local Const $sQuery = 'SELECT * FROM Win32_Process Where ParentProcessId = ' & $iParentPID & ' AND Handle <> ' & $iParentPID
    Local $aChildren[1][8]
    $aChildren[0][0] = 0
    $aChildren[0][1] = 'Name'
    $aChildren[0][2] = 'Command Line'
    $aChildren[0][3] = 'Executable Path'
    $aChildren[0][4] = 'Creation Date and Time'
    $aChildren[0][5] = 'Session Id'
    $aChildren[0][6] = 'Status'
    $aChildren[0][7] = 'Termination Date'
   
    Local $objWMIService = ObjGet ( 'winmgmts:\\localhost\root\CIMV2' )
    If NOT IsObj ( $objWMIService ) Then
        SetError ( 1 )
        Return $aChildren
    EndIf
    Local $colItems = $objWMIService.ExecQuery ( $sQuery, 'WQL', $wbemFlagReturnImmediately + $wbemFlagForwardOnly )
    If IsObj($colItems) then
        For $objItem In $colItems
            $aChildren[0][0] += 1
            ReDim $aChildren[$aChildren[0][0]+1][8]
            $aChildren[$aChildren[0][0]][0] = $objItem.Handle
            $aChildren[$aChildren[0][0]][1] = $objItem.Name
            $aChildren[$aChildren[0][0]][2] = $objItem.CommandLine
            $aChildren[$aChildren[0][0]][3] = $objItem.ExecutablePath
            $aChildren[$aChildren[0][0]][4] = $objItem.CreationDate
            $aChildren[$aChildren[0][0]][5] = $objItem.SessionId
            $aChildren[$aChildren[0][0]][6] = $objItem.Status
            $aChildren[$aChildren[0][0]][7] = $objItem.TerminationDate
        Next
    Else
        SetError ( 2 )
        Return $aChildren
    EndIf
    SetError ( 0 )
    Return $aChildren
EndFunc

