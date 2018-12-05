#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.2.12.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------


#include-once

#Include <GuiSlider.au3>
#include <Misc.au3>


Local $DummyControlForWbEsc = GuiCtrlCreateDummy()
GUICtrlSetOnEvent($DummyControlForWbEsc, "BW_EscKeyFunc")

Global $WbHotkeyFuncList[2][2] = [ 			_
		[ "{ESC}", 	$DummyControlForWbEsc],	_
		["^w", 		$DummyControlForWbEsc]	_
	]
GUISetAccelerators($WbHotkeyFuncList, $WildButtonConfigForm)


; [][0] -> ID
; [][1] -> Button's Cardinal Name
; [][2] -> Caption
; [][3] -> Commands
; [][4] -> WorkingDirectory
; [][5] -> Hint
; [][6] -> Hotkey
; [][7] -> Global
; [][8] -> FireAndForget
Global $WBS[20][9]

$WBS[ 0][0] = 16

$WBS[ 1][0] = $ButtonWild
$WBS[ 2][0] = $ButtonWild2
$WBS[ 3][0] = $ButtonWild3
$WBS[ 4][0] = $ButtonWild4
$WBS[ 5][0] = $ButtonWild5
$WBS[ 6][0] = $ButtonWild6
$WBS[ 7][0] = $ButtonWild7
$WBS[ 8][0] = $ButtonWild8
$WBS[ 9][0] = $ButtonWild9
$WBS[10][0] = $ButtonWildA
;$WBS[11][0] = $ButtonWildB
;$WBS[12][0] = $ButtonWildC
;$WBS[13][0] = $ButtonWildD
;$WBS[14][0] = $ButtonWildE
;$WBS[15][0] = $ButtonWildF
;$WBS[16][0] = $ButtonWildG
;$WBS[ 9][0] = 0;$ButtonStart
;$WBS[10][0] = 0;$ButtonCleanUp


$WBS[ 1][1] = "WCB 1"
$WBS[ 2][1] = "WCB 2"
$WBS[ 3][1] = "WCB 3"
$WBS[ 4][1] = "WCB 4"
$WBS[ 5][1] = "WCB 5"
$WBS[ 6][1] = "WCB 6"
$WBS[ 7][1] = "WCB 7"
$WBS[ 8][1] = "WCB 8"
$WBS[ 9][1] = "WCB 9"
$WBS[10][1] = "WCB A"
$WBS[11][1] = "WCB B"
$WBS[12][1] = "WCB C"
$WBS[13][1] = "WCB D"
$WBS[14][1] = "WCB E"
$WBS[15][1] = "WCB F"
$WBS[16][1] = "WCB G"
;$WBS[ 9][1] = "Start"
;$WBS[10][1] = "Clean"


Local $WBS_WorkingIndex = 0

Const $WB_DefaultHingString	= "Ctrl + LeftMouseClick to config this button."

Func BW_INIT($INI=$GlobalIni)

	GUICtrlSetOnEvent($BWC_Button1,		"BWC_Button1Func")		; "OK"    in the setup form
	GUICtrlSetOnEvent($BWC_Button2,		"BWC_Button2Func")		; "Cancel in the setup form
	GUICtrlSetOnEvent($BWC_Button3,		"BWC_Button3Func")		; "Reset" in the setup form
	GUICtrlSetOnEvent($BWC_Button4,		"BWC_Button4Func")		; "Reset" in the setup form
	GUICtrlSetOnEvent($BWC_Button5,		"BWC_Button5Func")		; "Browse Working Directory" in the setup form
	GUICtrlSetOnEvent($BWC_Slider1,		"BWC_Slider1Func")
	_GUICtrlSlider_SetRange($BWC_Slider1, 0,  $WBS[0][0]-1)

	
;	GUICtrlSetOnEvent($ButtonStart, 	"BW_ButtonGenericFunc")
;	GUICtrlSetOnEvent($ButtonCleanUp, 	"BW_ButtonGenericFunc")
	GUICtrlSetOnEvent($ButtonWild, 		"BW_ButtonGenericFunc")
	GUICtrlSetOnEvent($ButtonWild2,		"BW_ButtonGenericFunc")
	GUICtrlSetOnEvent($ButtonWild3,		"BW_ButtonGenericFunc")
	GUICtrlSetOnEvent($ButtonWild4,		"BW_ButtonGenericFunc")
	GUICtrlSetOnEvent($ButtonWild5,		"BW_ButtonGenericFunc")
	GUICtrlSetOnEvent($ButtonWild6,		"BW_ButtonGenericFunc")
	GUICtrlSetOnEvent($ButtonWild7,		"BW_ButtonGenericFunc")
	GUICtrlSetOnEvent($ButtonWild8,		"BW_ButtonGenericFunc")
	GUICtrlSetOnEvent($ButtonWild9,		"BW_ButtonGenericFunc")
	GUICtrlSetOnEvent($ButtonWildA,		"BW_ButtonGenericFunc")
;	GUICtrlSetOnEvent($ButtonWildB,		"BW_ButtonGenericFunc")
;	GUICtrlSetOnEvent($ButtonWildC,		"BW_ButtonGenericFunc")
;	GUICtrlSetOnEvent($ButtonWildD,		"BW_ButtonGenericFunc")
;	GUICtrlSetOnEvent($ButtonWildE,		"BW_ButtonGenericFunc")
;	GUICtrlSetOnEvent($ButtonWildF,		"BW_ButtonGenericFunc")
;	GUICtrlSetOnEvent($ButtonWildG,		"BW_ButtonGenericFunc")

EndFunc

; BW_ButtonGenericFunc() - Generic handler for any wildcard button.
;
Func BW_ButtonGenericFunc()
	Local $i
	For $i = 1 to $WBS[0][0]
		If $WBS[$i][0] == @GUI_CTRLID Then
			$WBS_WorkingIndex = $i
			ExitLoop
		EndIf
	Next
	
	; If $WBIndex == 0, there must be error.
	If $WBS_WorkingIndex > 0 Then
		If _IsPressed("11") Then		; "11" =  Ctrl key
			GUICtrlSetData($BWC_Slider1, $WBS_WorkingIndex-1)
			BW_ButtonSetup()
		Else
			BW_ButtonExec()
		EndIf
        EndIf
EndFunc


Func BW_ButtonSetup()

	; todo : provide vaild environment variable list
	WinSetTitle($WildButtonConfigForm, "", "Config WildCard Button : " & $WBS[$WBS_WorkingIndex][1])
	;GUICtrlSetState($WildButtonConfigForm, $GUI_FOCUS)
	
	GUICtrlSetData ($BWC_GROUP1, "Button: " & $WBS[$WBS_WorkingIndex][1])
	
	;todo: hotkey
	_GUICtrlEdit_SetText($BWC_Input1, $WBS[$WBS_WorkingIndex][2])	; [][2] -> Caption         
	_GUICtrlEdit_SetText($BWC_Edit1,  $WBS[$WBS_WorkingIndex][3])   ; [][3] -> Commands        
	_GUICtrlEdit_SetText($BWC_Input3, $WBS[$WBS_WorkingIndex][4])   ; [][4] -> WorkingDirectory
	_GUICtrlEdit_SetText($BWC_Input4, $WBS[$WBS_WorkingIndex][5])   ; [][5] -> Hint
	_GUICtrlEdit_SetText($BWC_Input5, $WBS[$WBS_WorkingIndex][6])   ; [][6] -> Hotkey
	__GuiCtrlCheckBox_SetCheckedState($BWC_CheckBox1, $WBS[$WBS_WorkingIndex][7])  	; [][7] -> Global
	__GuiCtrlCheckBox_SetCheckedState($BWC_CheckBox2, $WBS[$WBS_WorkingIndex][8])  	; [][8] -> FireAndForget

	GUISetState(@SW_SHOW, $WildButtonConfigForm)
EndFunc

Func BW_EscKeyFunc()
	BWC_Button2Func()
EndFunc

Func BW_ButtonExec()

	InitBatchCommandList()
	
	Local	$FAF=False
	;If __GuiCtrlCheckBox_IsChecked($BWC_CheckBox2) Then
	If $WBS[$WBS_WorkingIndex][8] Then
		$FAF=True
	EndIf
	
	SetGlobalVariables()
	
	;MsgBox(0, "BW_ButtonExec", $WBS[$WBS_WorkingIndex][1])
	If $WBS[$WBS_WorkingIndex][3] <> "" Then
		$TaskCommand = StringReplace($WBS[$WBS_WorkingIndex][2], "&", "")
		;$Cmd = "0x" & Hex(StringToBinary($WBS[$WBS_WorkingIndex][3]))
		StatusBar_SetText("WB - " & $WBS[$WBS_WorkingIndex][2])
		StatusBar_SetText("Running", 2)
		CoProcess_Execution($WBS[$WBS_WorkingIndex][3], $WBS[$WBS_WorkingIndex][4], $FAF)
	Else
		MsgBox(64, "Ouch", "This button's function is not set yet." & @CRLF & $WB_DefaultHingString)
	EndIf
EndFunc

;
; "OK"
;
Func BWC_Button1Func()

	;TODO: hotkey
	Local $Caption		= GUICtrlRead($BWC_Input1)
	Local $Command		= GUICtrlRead($BWC_Edit1)
	Local $WorkingDirectory	= GUICtrlRead($BWC_Input3)
	Local $Hint		= GUICtrlRead($BWC_Input4)
	Local $Glbl		= __GuiCtrlCheckBox_IsChecked($BWC_CheckBox1)	;"Global" checkbox
	Local $Faf		= __GuiCtrlCheckBox_IsChecked($BWC_CheckBox2)	; Fire and Forget
	
	$WBS[$WBS_WorkingIndex][2] = $Caption
	$WBS[$WBS_WorkingIndex][3] = $Command
	$WBS[$WBS_WorkingIndex][4] = $WorkingDirectory
	$WBS[$WBS_WorkingIndex][5]=  $Hint
	$WBS[$WBS_WorkingIndex][6]=  ""		;$Hotkey
	$WBS[$WBS_WorkingIndex][7]=  $Glbl	;$Global Button
	$WBS[$WBS_WorkingIndex][8]=  $Faf	;FireAndForget

	If $Caption == "" Then 
		$Caption = $WBS[$WBS_WorkingIndex][1]
	EndIf
	
	If $Hint == "" Then
		$Hint = $WBS[$WBS_WorkingIndex][3]
	EndIf
	GUICtrlSetData($WBS[$WBS_WorkingIndex][0], 	$Caption)
	GUICtrlSetTip($WBS[$WBS_WorkingIndex][0], 	$Hint)

	BW_IniUpdate()
	BW_Load()
	GUISetState(@SW_HIDE, $WildButtonConfigForm)
EndFunc

;
; "Cacel"
;
Func BWC_Button2Func()
	BW_Load()					; shall we?
	GUISetState(@SW_HIDE, $WildButtonConfigForm)
EndFunc

;
; "Reset"
;
Func BWC_Button3Func()
	_GUICtrlEdit_SetText($BWC_Input1, "")		; [][2] -> Caption         
	_GUICtrlEdit_SetText($BWC_Edit1, "")    	; [][3] -> Commands        
	_GUICtrlEdit_SetText($BWC_Input3, "")   	; [][4] -> WorkingDirectory
	_GUICtrlEdit_SetText($BWC_Input4, "")   	; [][5] -> Hint            
	_GUICtrlEdit_SetText($BWC_Input5, "")   	; [][6] -> Hotkey
	;__GuiCtrlCheckBox_SetCheckedState($BWC_CheckBox1, False)  	; [][7] -> Global
	__GuiCtrlCheckBox_SetCheckedState($BWC_CheckBox2, False)  	; [][8] -> Fire and forget
EndFunc


;
; Delete a button's setting
;
Func BWC_Button4Func()

	Local $SectionStr
	
	If __GuiCtrlCheckBox_IsChecked($BWC_CheckBox1) Then
		$SectionStr = "Global.WB." & $WBS_WorkingIndex
	Else
		$SectionStr = $GlobalTaskSectionName[$GlobalTaskId] & ".WB." & $WBS_WorkingIndex
	EndIf
	; TODO: not a safe usage of the global name: $GlobalIni
	IniDelete($GlobalIni, $SectionStr)

	$WBS[$WBS_WorkingIndex][2] = ""
	$WBS[$WBS_WorkingIndex][3] = ""
	$WBS[$WBS_WorkingIndex][4] = ""
	$WBS[$WBS_WorkingIndex][5]=  ""
	$WBS[$WBS_WorkingIndex][6]=  ""
	$WBS[$WBS_WorkingIndex][7]=  False
	$WBS[$WBS_WorkingIndex][8]=  False

	__GuiCtrlCheckBox_SetCheckedState($BWC_CheckBox1, False)  	; [][7] -> Global
	BWC_Button3Func()
	BW_Load()
EndFunc

;
; "Browse Folder"
;
Func BWC_Button5Func()

	Local $WCB_WorkingFolder= Path_TrimTrailingSlash(StringStripWS(GUICtrlRead($BWC_Input3), 1+2))

	$WCB_WorkingFolder = FileSelectFolder("Select A Working Directory:", "", 2+4, $WCB_WorkingFolder)
	If $WCB_WorkingFolder <> "" Then
		_GUICtrlEdit_SetText($BWC_Input3, $WCB_WorkingFolder)
	EndIf
EndFunc


Func WildButton_Enable($Enable=True)
	Local $i, $Msg
	If $Enable Then
		$Msg = $GUI_ENABLE
	Else
		$Msg = $GUI_DISABLE
	EndIf
	For $i=1 to $WBS[0][0]
		If $WBS[$i][0] == 0 Then ContinueLoop
		GUICtrlSetState($WBS[$i][0], $Msg)
	Next
EndFunc


Func BW_Load($INI=$GlobalIni, $TaskId=-1)

	Local $i, $SectionStr, $Faf
	
	For $i=1 to $WBS[0][0]
		$SectionStr = "Global.WB." & $i
		$WBS[$i][7] = False		; $global == false
		IniReadSection($Ini, $SectionStr)
		If @Error Then
			$WBS[$i][2] = ""						; [][2] -> Caption         
			$WBS[$i][3] = ""						; [][3] -> Commands        
			$WBS[$i][4] = ""						; [][4] -> WorkingDirectory
			$WBS[$i][5] = ""						; [][5] -> Hint
			$WBS[$i][6] = ""						; [][6] -> Hotkey
			$WBS[$i][7] = False
			$WBS[$i][8] = False
		Else
			$WBS[$i][2] = IniRead($INI, $SectionStr, "Caption", "")		; [][2] -> Caption         
			$WBS[$i][3] = IniRead($INI, $SectionStr, "Command", "")		; [][3] -> Commands        
			If $WBS[$i][3] <> "" Then $WBS[$i][3] = BinaryToString("0x" & $WBS[$i][3])
			$WBS[$i][4] = IniRead($INI, $SectionStr, "WorkingDirectory", "") ; [][4] -> WorkingDirectory
			$WBS[$i][5] = IniRead($INI, $SectionStr, "Hint", "")		; [][5] -> Hint
			$WBS[$i][6] = IniRead($INI, $SectionStr, "Hotkey", "")		; [][6] -> Hotkey
			$WBS[$i][7] = True
			
			$Faf 	= IniRead($INI, $SectionStr, "FireAndForget", "")	; [][8] -> Fire and forget
			$WBS[$i][8] = False
			If StringCompare($Faf, "True") == 0 Then $WBS[$i][8] = True
		EndIf
	Next

	;_ArrayDisplay($WBS)

	If $TaskId == -1 Then
		$TaskId = $GlobalTaskId
	EndIf
	
	For $i=1 to $WBS[0][0]
		$SectionStr = $GlobalTaskSectionName[$TaskId] & ".WB." & $i
		IniReadSection($Ini, $SectionStr)
		If @Error Then 
			ContinueLoop
		Else
			Local $WSB2 = IniRead($INI, $SectionStr, "Caption", "")			; [][2] -> Caption
			Local $WSB3 = IniRead($INI, $SectionStr, "Command", "")			; [][3] -> Commands
			Local $WSB4 = IniRead($INI, $SectionStr, "WorkingDirectory", "")	; [][4] -> WorkingDirectory
			
			;
			; If Caption, Commands and WorkingDirectory are all empty, then skip this entry
			;

			If ($WSB2 == "" And $WSB3 == "" And $WSB4 == "") Then
				ContinueLoop
			EndIf
			
			$WBS[$i][2] = IniRead($INI, $SectionStr, "Caption", "")		; [][2] -> Caption         
			$WBS[$i][3] = IniRead($INI, $SectionStr, "Command", "")		; [][3] -> Commands        
			If $WBS[$i][3] <> "" Then $WBS[$i][3] = BinaryToString("0x" & $WBS[$i][3])
			$WBS[$i][4] = IniRead($INI, $SectionStr, "WorkingDirectory", "") ; [][4] -> WorkingDirectory
			$WBS[$i][5] = IniRead($INI, $SectionStr, "Hint", "")		; [][5] -> Hint            
			$WBS[$i][6] = IniRead($INI, $SectionStr, "Hotkey", "")		; [][6] -> Hotkey
			$WBS[$i][7] = False

			$Faf 	= IniRead($INI, $SectionStr, "FireAndForget", "")	;[][8] -> Fire and forget
			$WBS[$i][8] = False
			If StringCompare($Faf, "True") == 0 Then $WBS[$i][8] = True

		EndIf
	Next
	
	
	For $i=1 to $WBS[0][0]
		Local $caption = $WBS[$i][2]	; [][2] -> Caption
		Local $hint    = $WBS[$i][5]    ; [][5] -> Hint   
		If $caption == "" Then 
			$caption = $WBS[$i][1]
			$hint 	 =  $WB_DefaultHingString
		EndIf
		GUICtrlSetData($WBS[$i][0], 	$caption)	
		GUICtrlSetTip($WBS[$i][0],	$hint)		
	Next
	
EndFunc

Func BW_IniUpdate($INI=$GlobalIni, $TaskId=-1)

	Local $i, $SectionStr
	
	If $TaskId == -1 Then
		$TaskId = $GlobalTaskId
	EndIf
	
	For $i=1 to $WBS[0][0]
		If $WBS[$i][7] == True Then
			$SectionStr = "Global.WB." & $i
		Else
			$SectionStr = $GlobalTaskSectionName[$TaskId] & ".WB." & $i
		EndIf
		
		;
		; If Caption, Commands and WorkingDirectory are all empty, then delete this entry
		;
		
		If ($WBS[$i][2] == "" And $WBS[$i][3] == "" And $WBS[$i][4] == "") Then
			IniDelete($INI, $SectionStr)
		Else
			IniUpdate($INI, $SectionStr, "Caption",		$WBS[$i][2])		; [][2] -> Caption         
			IniUpdate($INI, $SectionStr, "Command", 	$WBS[$i][3], True)	; [][3] -> Commands
			IniUpdate($INI, $SectionStr, "WorkingDirectory",$WBS[$i][4])		; [][4] -> WorkingDirectory
			IniUpdate($INI, $SectionStr, "Hint", 		$WBS[$i][5])		; [][5] -> Hint
			IniUpdate($INI, $SectionStr, "Hotkey", 		$WBS[$i][6])		; [][6] -> Hotkey
			IniUpdate($INI, $SectionStr, "FireAndForget", 	$WBS[$i][8])		; [][8] -> Fire and forget
		EndIf
	Next
EndFunc

Func BWC_Slider1Func()
	;MsgBox(0, "Slider", GUICtrlread($BWC_Slider1))
	Local $WIndex = GUICtrlread($BWC_Slider1)
	$WBS_WorkingIndex  = $WIndex+1
	BW_ButtonSetup()
EndFunc