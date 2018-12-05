#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.0.0

 Script Function:
	SCT 2.0 support


快速檢查某個 driver 的 syntax 的時候，很好用。(90秒 V.S. 3秒)

1)	Additional Environment Variable 設定這幾行:
EFI_SOURCE=F:\Eugene\Current
BUILD_DIR=%ProjectDir%\temp
TOOLS_DIR=TOOLS\000
NUMBER_OF_PROCESSORS=2

2)	Button 設定: (ctrl + 任一個 “WCB button” 以 設定)
2.1) Commands:
call "C:\Program Files\Microsoft Visual Studio 8\Common7\Tools\vsvars32.bat"
nmake all
2.2) Working Directory:
%ProjectDir%\temp\X64\System\000\BootManager\Dxe
or
F:\SCT20\4571\Projects\CalpellaCrb\000\temp\X64\System\000\BootManager\Dxe

3)	Actions 選 SCT2 - build


EFI_SOURCE 和  NUMBER_OF_PROCESSORS 只能先這樣 hard-coding. EFI_SOURCE 就是 放 phmake.cfg 的那層目錄。
Working directory 就是到 對應的 temp\ 底下的目錄



; R0	Timothy 2010/Feb/20
; R1	Timothy 2010/Jun/22
;
; TODO: parse base name and delete $(base_name)*.* when cleaning/rebuilding
;

#ce ----------------------------------------------------------------------------

#include-once

Const	$Sct2DbString			= $GlobalTaskSectionName[$Enum_GlobalTask_Sct2_DB]		; match the name indexed in $GlobalTaskSectionName
Const	$Sct2DbProjectDirectoryString	= "ProjectDirectory"
Const	$Sct2DbModuleString		= "Module"

Global	$Sct2DbPreBuildCmd							; would be initialized later

Func SCT2_DB_Init($INI=$GlobalIni)
	GUICtrlSetState($Button1, $GUI_DISABLE)
	GUICtrlSetState($Button2, $GUI_DISABLE)
	GUICtrlSetState($Button3, $GUI_DISABLE)

	GUICtrlSetState($Button4, $GUI_ENABLE)
	GUICtrlSetState($Button5, $GUI_ENABLE)
	_GUICtrlButton_SetText($Button4, "ProjectDir")
	_GUICtrlButton_SetText($Button5, "Module")

	GUICtrlSetState($Input1, $GUI_DISABLE)
	GUICtrlSetState($Input2, $GUI_DISABLE)
	GUICtrlSetState($Input3, $GUI_DISABLE)
	GUICtrlSetState($Input4, $GUI_ENABLE+$GUI_FOCUS)
	GUICtrlSetState($Input5, $GUI_ENABLE)
	GUICtrlSetState($Input6, $GUI_DISABLE)

	GUICtrlSetState($Label1, $GUI_DISABLE)

	GUICtrlSetState($ButtonStart, $GUI_ENABLE)
	GUICtrlSetState($ButtonRebuild, $GUI_ENABLE)
	GUICtrlSetState($ButtonCleanUp, $GUI_ENABLE)
	_GUICtrlButton_SetText($ButtonStart, "Build")
	_GUICtrlButton_SetText($ButtonRebuild, "Rebuild")
	_GUICtrlButton_SetText($ButtonCleanUp, "Clean")

	TRunningState(False)

	Local $Sct2dbProjectDirectory	= IniRead($INI, $Sct2dbString, $Sct2DbProjectDirectoryString, "")
	Local $Sct2dbModuleName		= IniRead($INI, $Sct2dbString, $Sct2DbModuleString, "")
	Local $EnvVarsX			= IniRead($INI, $Sct2DbString, $EnvVarsString, "")
	Local $LeadingCmds		= IniRead($INI, $Sct2DbString, $LeadingCmdsString, "")

	If $EnvVarsX <> "" Then
		$EnvVarsX 		= BinaryToString("0x" & $EnvVarsX)
	EndIf
	$LeadingCmds			= BinaryToString("0x" & $LeadingCmds)

	_GUICtrlEdit_SetText($Input4, $Sct2dbProjectDirectory)
	_GUICtrlEdit_SetText($Input5, $Sct2dbModuleName)

	_GUICtrlEdit_SetText($Edit1, $EnvVarsX)

;
;Timothy: Beware, these GUICtrlSetData() causes Menu's behavior bizarre: After selecting any menu item, program exits unconditionally.
;	GUICtrlSetData($Input4, $EfiSource)
;	GUICtrlSetData($Input5, $BuildTip)
;	GUICtrlSetData($Edit1, $EnvVars)
;	GUICtrlSetData($Edit2, $LeadingCmds)

	GUICtrlSetOnEvent($Button4, "Button4SetSct2DbModuleDirectory")
	GUICtrlSetOnEvent($Button5, "Button5SetSct2dbMlist")

	;
	; BUGBUG: hard-coding
	;

	;$Sct2DbPreBuildCmd = "SET NUMBER_OF_PROCESSORS=1" & @CRLF & "SET TOOLS_DIR=TOOLS\000" & @CRLF & 'call "%VS80COMNTOOLS%vsvars32.bat"'

EndFunc


Global $Sct2_DB_ToolsDir	= ""
Global $ModulePath	 	= ""


;
; TODO: check the existence of project.def in project directory, and makefile in build module
;
;

Func SCT2_DB_SetVariables($WarningOnMissedPath=False)

	Local $Sct2dbModule = StringStripWS(GUICtrlRead($Input5), 1+2)
	Local $Sct2dbProjectDirectory = Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input4), 1+2))

	If $WarningOnMissedPath Then
		If Not FileExists($Sct2dbProjectDirectory) Then
			If $WarningOnMissedPath Then MsgBox(48, "Ouch", "Project Directory: " & $Sct2dbProjectDirectory &" does not exist!")
		EndIf
	EndIf

	Local $Sct2Root = LocateSct2Root($Sct2dbProjectDirectory)

	;
	; Parsing Project.def to find the Build-Module directory
	; Module Build,           001, BUILD      // location of the MAKEFILE.
	;

	Local $ProjectHPath = $Sct2dbProjectDirectory & "\temp\project.h"
	Local $ProjectHFile = FileRead ($ProjectHPath)
	If $ProjectHFile == -1 Then
		If $WarningOnMissedPath Then MsgBox(48, "", "Cannot read temp\project.h?! Please have this code base be fully built first!")
		return
	EndIf

	;#define SCT_PATH_BUILD OemBuild\001
	Local $BuildModules = StringRegExp($ProjectHFile, "#define\s+SCT_PATH_BUILD\s+(.*\\\d{3}).*", 3)
	If @Error OR (NOT IsArray($BuildModules)) Then
		If $WarningOnMissedPath Then  MsgBox(48, "", "Project.h cantains no build module?!")
		return
	EndIf
	$ProjectHFile = ""
	;MsgBox(0, "", $BuildModuleVersion)

	;
	; Locate makefile in Build-Module directory
	; TOOLSVER=001                            # version number of build tools.
	;

	Local $BuildModuleMakeFilePath = $Sct2Root & "\" & $BuildModules[0] & "\makefile"
	If Not FileExists($BuildModuleMakeFilePath) Then
		$BuildModuleMakeFilePath = $Sct2Root & "\Build\000\makefile"
		If Not FileExists($BuildModuleMakeFilePath) Then
			If $WarningOnMissedPath Then MsgBox(48, "", "No Build Module exits! Do you know what are you doing?")
			return
		EndIf
	EndIf
	Local $BuildModuleMakeFile = FileRead($BuildModuleMakeFilePath)
	If $BuildModuleMakeFile == -1 Then
		If $WarningOnMissedPath Then MsgBox(48, "", "Cannot read " & $BuildModuleMakeFilePath & " ?!")
		return
	EndIf

	Local $ToolsVers = StringRegExp($BuildModuleMakeFile, "TOOLSVER\s*=\s*(\d{3}).*", 3)
	If @Error OR (NOT IsArray($ToolsVers)) Then
		If $WarningOnMissedPath Then MsgBox(48, "", "Cannot find Tool directory in " & $BuildModuleMakeFilePath)
		return
	EndIf
	$BuildModuleMakeFile = ""
	;MsgBox(0, "ToolsVer", $ToolsVers[0])

	;
	; Parsing Module.List by an assigned Module Name
	; " EfiDriverLib              F:\Harrison\HR7820\System\001\Library\Dxe\EfiDriverLib\EfiDriverLib.inf "
	;

	Local $ModuleListFilePath = $Sct2dbProjectDirectory & "\temp\module.list"
	Local $ModuleListFile = FileRead($ModuleListFilePath)
	If $ModuleListFile == -1 Then
		If $WarningOnMissedPath Then MsgBox(48, "", "Cannot read Module List File : " & $ModuleListFilePath)
		return
	EndIf

	Local $ModulePaths = StringRegExp($ModuleListFile, $Sct2dbModule & "\s+(.+\.inf)\.*", 3)
	If @Error OR (NOT IsArray($ModulePaths)) Then
		If $WarningOnMissedPath Then MsgBox(48, "-" & $Sct2dbModule & "-", "Module does not exist: " & $Sct2dbModule)
		Return
	EndIf
	$ModuleListFile = ""
	;MsgBox(0, "ModulePath", "-"&$ModulePaths[0]&"-")

	Local $ModulePath0 = StringReplace($ModulePaths[0], $Sct2Root & "\", "", 1)

	$ModulePath = ""
	Local $i = StringInStr($ModulePath0, "\", 0, -1)
	If $i <= 1 Then 
		Return
	EndIf
	$ModulePath = StringLeft($ModulePath0, $i-1)
	;MsgBox(0, "ModuleMakefilePath0", $ModuleMakefilePath0)

	;COMPONENT_TYPE:	PE32_PEIM, APPLICATION, LIBRARY, ACPI_TABLES, BINARY, BS_DRIVER, RT_DRIVER, PEI_CORE, TextFile
	;

	TEnvAdd("MODULE", $Sct2dbModule)
	TEnvAdd("EFI_SOURCE", $Sct2Root)
	TEnvAdd("PROJ_DIR", $Sct2dbProjectDirectory)
	TEnvAdd("TOOLS_DIR", "tools\" & $ToolsVers[0])
	TEnvAdd("BUILD_DIR", "%PROJ_DIR%\temp")

	;
	; TODO: handle VS2008 and VS2010
	;
	Local $VcToolPath = EnvGet("VS80COMNTOOLS")
	If $VcToolPath == "" Then
		TEnvAdd("VS80COMNTOOLS", "C:\Program Files\Microsoft Visual Studio 8\Common7\Tools\")
	EndIf

	AppendPrologueCommand('call "%VS80COMNTOOLS%vsvars32.bat"')

EndFunc


Func SCT2_DB_Build($Arg="", $ExtParams="")

 	Local $ProjDir		= Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input4), 1+2))
	Local $Sct2Root 	= LocateSct2Root($ProjDir)
	Local $BuildDir		= $ProjDir & "\temp"
	Local $Sct2BuildCmd	= "NMAKE.EXE all"

	If $Sct2Root == "" Then
		MsgBox(48, "Ouch", $Sct2RootMissed)
	EndIf

	Local	$ConsoleMsg	= @CRLF & _
		"SCT Root Directory, EFI_SOURCE = " & $Sct2Root & @CRLF & _
		"Build Directory, BUILD_DIR = " & $BuildDir & @CRLF

	Local $ModuleIa32MakefilePath = $BuildDir & "\IA32\" & $ModulePath
	Local $ModuleX64MakefilePath  = $BuildDir & "\X64\"  & $ModulePath
	;MsgBox(0, "path", $ModuleIa32MakefilePath & "-" & $ModuleX64MakefilePath)

	If Not FileExists($ModuleIa32MakefilePath & "\makefile") Then
		$ModuleIa32MakefilePath = ""
	Else
		$ConsoleMsg &= "IA32, DEST_DIR = " & $ModuleIa32MakefilePath & @CRLF
	EndIf

	If Not FileExists($ModuleX64MakefilePath & "\makefile") Then
		$ModuleX64MakefilePath = ""
	Else
		$ConsoleMsg &= "X64, DEST_DIR = " & $ModuleX64MakefilePath & @CRLF
	EndIf


	Local $Sct2dbBuild = False
	Local $Sct2dbClean = False
	Local $Sct2dbRebuild = False

	If StringCompare($Arg, $BuildString, 0) == 0 Then
		$ConsoleMsg &= @CRLF & $ConsoleQkBuildString & $CRLFx2
		$Sct2dbBuild = True
	EndIf

	If (StringCompare($Arg, $CleanString, 0) == 0) Then
		$ConsoleMsg &= @CRLF & $ConsoleCleanUpString & $CRLFx2
		$Sct2dbClean = True
	EndIf

	If StringCompare($Arg, $RebuildString, 0) == 0 Then
		$ConsoleMsg &= @CRLF & $ConsoleRebuildString & $CRLFx2
		$Sct2dbRebuild = True
	EndIf

	;
	; since there is no "clean:" entry in the makefile, we have to manually collect the deleting file list
	;
	If $Sct2dbClean OR $Sct2dbRebuild Then
		Local $Dirs
		Local $Makefile

		If $ModuleIa32MakefilePath <> "" Then
			$Dirs = DirReadArray($ModuleIa32MakefilePath, $CorgiTempDir)
			;_ArrayDisplay($Dirs)
			If IsArray($Dirs) AND ($Dirs[0] > 0) then
				AppendExecCommand("SET DEST_DIR=%BUILD_DIR%\IA32\" & $ModulePath)
				AppendExecCommand("CD /D %DEST_DIR%")

				$Makefile = FileRead($ModuleIa32MakefilePath & "\makefile")
				If NOT @Error Then
					For $i = 1 to $Dirs[0]
						If (StringCompare($Dirs[$i], "makefile") == 0) Then
							ContinueLoop
						EndIf
						If StringInStr($Makefile, $Dirs[$i]) <> 0 AND _
							StringCompare(StringRight($Dirs[$i], 4), ".pkg") <> 0 Then
							;MsgBox(0,"", "-" & $Dirs[$i] & "-")
							AppendExecCommand('DEL "' & $Dirs[$i] & '"')
						EndIf
					Next
					$Makefile = ""
				EndIf
			EndIf
			AppendExecCommand('IF EXIST *.rsp DEL *.rsp')
			AppendExecCommand('IF EXIST *.pdb DEL *.pdb')
		EndIf

		If $ModuleX64MakefilePath <> "" Then
			$Dirs = DirReadArray($ModuleX64MakefilePath, $CorgiTempDir)
			;_ArrayDisplay($Dirs)
			If IsArray($Dirs) AND ($Dirs[0] > 0) then
				AppendExecCommand("SET DEST_DIR=%BUILD_DIR%\X64\" & $ModulePath)
				AppendExecCommand("CD /D %DEST_DIR%")
				
				$Makefile = FileRead($ModuleX64MakefilePath & "\makefile")
				If NOT @Error Then
					For $i = 1 to $Dirs[0]
						If (StringCompare($Dirs[$i], "makefile") == 0) Then
							ContinueLoop
						EndIf
						If StringInStr($Makefile, $Dirs[$i]) <> 0 AND _
							StringCompare(StringRight($Dirs[$i], 4), ".pkg") <> 0 Then
							;MsgBox(0,"", "-" & $Dirs[$i] & "-")
							AppendExecCommand('DEL "' & $Dirs[$i] & '"')
						EndIf
					Next
					$Makefile = ""
				EndIf
			EndIf
			AppendExecCommand('IF EXIST *.rsp DEL *.rsp')
			AppendExecCommand('IF EXIST *.pdb DEL *.pdb')
		EndIf

	EndIf

	If $Sct2dbBuild OR $Sct2dbRebuild then
		If $ModuleIa32MakefilePath <> "" Then
			;AppendExecCommand("SET DEST_DIR=" & $ModuleIa32MakefilePath)
			AppendExecCommand("SET DEST_DIR=%BUILD_DIR%\IA32\" & $ModulePath)
			AppendExecCommand("CD /D %DEST_DIR%")
			AppendExecCommand($Sct2BuildCmd)
		EndIf
		If $ModuleX64MakefilePath <> "" Then
			;AppendExecCommand("SET DEST_DIR=" & $ModuleX64MakefilePath)
			AppendExecCommand("SET DEST_DIR=%BUILD_DIR%\X64\" & $ModulePath)
			AppendExecCommand("CD /D %DEST_DIR%")
			AppendExecCommand($Sct2BuildCmd)
		EndIf


	EndIf

	Local $CmdList[4] = [3, $ConsoleMsg, "", $BuildDir]

	return $CmdList

EndFunc



Func SCT2_DB_IniUpdate($INI)

	Local	$NewSct2ProjectDirectory	= GUICtrlRead($Input4)
	Local	$NewSct2ModuleName		= GUICtrlRead($Input5)
	Local	$NewEnvVars			= GUICtrlRead($Edit1)

	IniUpdate($INI, $Sct2DbString, $Sct2DbProjectDirectoryString, $NewSct2ProjectDirectory)
	IniUpdate($INI, $Sct2DbString, $Sct2DbModuleString, $NewSct2ModuleName)
	IniUpdate($INI, $Sct2DbString, $EnvVarsString, $NewEnvVars, True)

EndFunc



Func Button4SetSct2DbModuleDirectory()

	AutoItSetOption("ExpandEnvStrings", 1)
	Local $ModuleDirectory = Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input4), 1+2))
	AutoItSetOption("ExpandEnvStrings", 0)

	If _IsPressed("11") AND FileExists($ModuleDirectory) Then 	; "11" =  Ctrl key
		ShellExecute($ModuleDirectory)
		Return
	EndIf

	$ModuleDirectory = FileSelectFolder("Select SCT2 Project Directory (PROJ_DIR):", "", 2+4, $ModuleDirectory)
	If $ModuleDirectory <> "" Then
		_GUICtrlEdit_SetText($Input4, $ModuleDirectory)
	EndIf
EndFunc


Func Button5SetSct2dbMlist()

	Local $Sct2dbProjectDirectory = Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($Input4), 1+2))
	Local $BuildDir = $Sct2dbProjectDirectory & "\temp"
	Local $Mlist = $BuildDir & "\module.list"

	If NOT FileExists($BuildDir) Then
		;MsgBox(48, "Ouch", "Build Directory: " & $Builddir & " does not exist!")
		Return
	EndIf

	If NOT FileExists($Mlist) Then
		;MsgBox(48, "Ouch", "Module List: " & $Mlist & " does not exist!")
		return
	EndIf

	If _IsPressed("12") AND FileExists($Mlist) Then 	; Alt key
		TEdit($Mlist)
		Return
	EndIf
	
	If _IsPressed("11") Then		; Ctrl key
		SCT2_DB_SetVariables(False)
		If  $ModulePath == "" Then
			Return
		EndIf
		Local $ModuleIa32MakefilePath = $BuildDir & "\IA32\" & $ModulePath
		If FileExists($ModuleIa32MakefilePath) Then ShellExecute($ModuleIa32MakefilePath)
		
		Local $ModuleX64MakefilePath = $BuildDir & "\X64\" & $ModulePath
		If FileExists($ModuleX64MakefilePath) Then ShellExecute($ModuleX64MakefilePath)
	EndIf
	
	;
	; TODO
	;

	;If FileExists($Mlist)
	;$EfiSource = FileSelectFolder("Select SCT2 Project Directory:", "", 2+4, $EfiSource)
	;If $EfiSource <> "" Then
	;	_GUICtrlEdit_SetText($Input4, $EfiSource)
	;EndIf
EndFunc


Func LocateSct2DbRoot($ProjectDirectory)
	Local $Sct2Root0 = $ProjectDirectory
	Local $i

	While True
		$i = StringInStr($Sct2Root0, "\", 0, -1)
		If $i <= 1 Then Return ""
		$Sct2Root0 = StringLeft($Sct2Root0, $i-1)
		If FileExists($Sct2Root0 & "\PHMAKE.CFG") Then
			Return $Sct2Root0
		EndIf
	WEnd
EndFunc


Func LocateSct2BuildDir($ModuleDirectory)

	Local $i = StringInStr($ModuleDirectory, "\temp\")
	Local $BuildDir = ""


	If $i > 0 Then
		return StringLeft($ModuleDirectory, $i) & "temp"
	EndIf

	return ""
EndFunc


#include <Process.au3>
#Include <File.au3>
#Include <Array.au3>

Func DirReadArray($dir, $TempDir=@TempDir)
	Local $DirTmpFile = _TempFile($TempDir)
	_RunDOS ("dir /b " & $dir &" > " & $DirTmpFile)
	Local $aArray
	_FileReadToArray($DirTmpFile, $aArray)
	FileDelete ($DirTmpFile)
	;_ArrayDisplay($aArray)
	return $aArray
EndFunc