#include-once

Func _IsHoveredWnd($hWnd)
	Local $iRet = False
	Local $aWin_Pos = WinGetPos($hWnd)

	If @Error Then
		Return False
	EndIf

	Local $aMouse_Pos = MouseGetPos()

	If ($aMouse_Pos[0] >= $aWin_Pos[0]) And ($aMouse_Pos[0] <= ($aWin_Pos[0] + $aWin_Pos[2])) And _
		($aMouse_Pos[1] >= $aWin_Pos[1]) And ($aMouse_Pos[1] <= ($aWin_Pos[1] + $aWin_Pos[3])) Then $iRet = True

	Return $iRet
EndFunc