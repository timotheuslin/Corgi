#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.2.12.1
 Author:         Timothy Lin @ Phoenix	2010/Sep

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

#include-once

#Include <File.au3>
#Include <Array.au3>

;
; Remove successive files in a folder, by judging the chronicle number in its file name
;

Func FolderJanitor($Path, $Filter, $ReservedFileNumber)
	Local $DirList = _FileListToArray($Path,  $Filter)
	Local $i
	
	$Path = Path_TrimTrailingSlash($Path)
	If IsArray($DirList) Then
		_ArraySort($DirList, 1, 1)	; 1:descending, 1: started sorting entry
		;_ArrayDisplay($DirList,"$FileList")
		For $i=$ReservedFileNumber+1 to $DirList[0]
			FileDelete($Path & "\" & $DirList[$i])
		Next
	EndIf
EndFunc