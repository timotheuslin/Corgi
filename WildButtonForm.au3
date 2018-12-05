;#include <ButtonConstants.au3>
;#include <EditConstants.au3>
;#include <GUIConstantsEx.au3>
;#include <SliderConstants.au3>
;#include <StaticConstants.au3>
;#include <WindowsConstants.au3>
;#Region ### START Koda GUI section ### Form=D:\Studio0\autoit\Corgi\WildButton.kxf
;$WildButtonConfigForm = GUICreate("Config This Wild Button", 328, 284, 476, 135, BitOR($WS_CAPTION,$WS_POPUP,$WS_BORDER), BitOR($WS_EX_APPWINDOW,$WS_EX_TOOLWINDOW))
;$BWC_Button1 = GUICtrlCreateButton("&OK", 192, 248, 59, 25, $WS_GROUP)
;$BWC_Button2 = GUICtrlCreateButton("&Cancel", 256, 248, 59, 25, $WS_GROUP)
;$BWC_Button3 = GUICtrlCreateButton("&Reset", 48, 248, 59, 25, $WS_GROUP)
;$BWC_Group1 = GUICtrlCreateGroup("WildCard Button 1", 8, 28, 313, 209)
;GUICtrlCreateLabel("Caption:", 16, 52, 43, 17)
;GUICtrlCreateLabel("Hint:", 16, 82, 26, 17)
;$BWC_LabelHotkey = GUICtrlCreateLabel("Hotkey:", 16, 112, 41, 17)
;GUICtrlSetState(-1, $GUI_DISABLE)
;$BWC_Input1 = GUICtrlCreateInput("", 58, 48, 110, 21)
;$BWC_Input4 = GUICtrlCreateInput("", 58, 78, 110, 21)
;$BWC_Input5 = GUICtrlCreateInput("", 58, 108, 110, 21)
;GUICtrlSetState(-1, $GUI_DISABLE)
;$Group2 = GUICtrlCreateGroup("Commands", 176, 40, 137, 129)
;$BWC_Edit1 = GUICtrlCreateEdit("", 178, 55, 133, 112, BitOR($ES_AUTOVSCROLL,$ES_AUTOHSCROLL,$ES_WANTRETURN), 0)
;GUICtrlCreateGroup("", -99, -99, 1, 1)
;$Group3 = GUICtrlCreateGroup("Working Directory", 16, 180, 297, 49)
;$BWC_Input3 = GUICtrlCreateInput("", 17, 204, 268, 21, -1, 0)
;$BWC_Button5 = GUICtrlCreateButton("...", 288, 204, 21, 21, $WS_GROUP)
;GUICtrlCreateGroup("", -99, -99, 1, 1)
;$BWC_Checkbox1 = GUICtrlCreateCheckbox("Global Button", 16, 140, 89, 17)
;$BWC_Checkbox2 = GUICtrlCreateCheckbox("Fire-and-forget", 16, 156, 89, 17)
;GUICtrlCreateGroup("", -99, -99, 1, 1)
;$BWC_Slider1 = GUICtrlCreateSlider(0, 8, 326, 21)
;GUICtrlSetLimit(-1, 7, 0)
;GUICtrlSetTip(-1, "Select a button index")
;$BWC_Button4 = GUICtrlCreateButton("&Delete", 120, 248, 59, 25, $WS_GROUP)
;;GUISetState(@SW_SHOW)
;#EndRegion ### END Koda GUI section ###
;

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <SliderConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#Region ### START Koda GUI section ### Form=D:\studio0\Autoit\Corgi\WildButton.kxf
;$WildButtonConfigForm = GUICreate("Config This Wild Button", 603, 279, 476, 135, $WS_POPUP, BitOR($WS_EX_APPWINDOW,$WS_EX_TOOLWINDOW))
$WildButtonConfigForm = GUICreate("Config This Wild Button", 603, 279, 476, 135, BitOR($WS_CAPTION,$WS_POPUP,$WS_BORDER), BitOR($WS_EX_APPWINDOW,$WS_EX_TOOLWINDOW))
$BWC_Button1 = GUICtrlCreateButton("&OK", 467, 248, 59, 25, $BS_NOTIFY)
$BWC_Button2 = GUICtrlCreateButton("&Cancel", 536, 248, 59, 25, $BS_NOTIFY)
$BWC_Button3 = GUICtrlCreateButton("&Reset", 328, 248, 59, 25, $BS_NOTIFY)
$BWC_Group1 = GUICtrlCreateGroup("WildCard Button 1", 8, 28, 585, 209)
GUICtrlCreateLabel("Caption:", 16, 52, 43, 17, 0)
GUICtrlCreateLabel("Hint:", 16, 82, 26, 17, 0)
$BWC_LabelHotkey = GUICtrlCreateLabel("Hotkey:", 16, 112, 41, 17, 0)
GUICtrlSetState(-1, $GUI_DISABLE)
$BWC_Input1 = GUICtrlCreateInput("", 58, 48, 175, 21, $GUI_SS_DEFAULT_INPUT)
$BWC_Input4 = GUICtrlCreateInput("", 58, 78, 175, 21, $GUI_SS_DEFAULT_INPUT)
$BWC_Input5 = GUICtrlCreateInput("", 58, 108, 175, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetState(-1, $GUI_DISABLE)
$Group2 = GUICtrlCreateGroup("Commands", 240, 40, 345, 137)
$BWC_Edit1 = GUICtrlCreateEdit("", 242, 55, 341, 120, BitOR($ES_AUTOVSCROLL,$ES_AUTOHSCROLL,$ES_WANTRETURN), 0)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group3 = GUICtrlCreateGroup("Working Directory", 16, 180, 569, 49)
$BWC_Input3 = GUICtrlCreateInput("", 17, 204, 540, 21, $GUI_SS_DEFAULT_INPUT, 0)
$BWC_Button5 = GUICtrlCreateButton("...", 560, 204, 21, 21, $BS_NOTIFY)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$BWC_Checkbox1 = GUICtrlCreateCheckbox("Global Button", 16, 140, 89, 17)
$BWC_Checkbox2 = GUICtrlCreateCheckbox("Fire-and-forget", 120, 140, 89, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$BWC_Slider1 = GUICtrlCreateSlider(0, 8, 598, 21, $GUI_SS_DEFAULT_SLIDER)
GUICtrlSetLimit(-1, 7, 0)
GUICtrlSetTip(-1, "Select a button index")
$BWC_Button4 = GUICtrlCreateButton("&Delete", 397, 248, 59, 25, $BS_NOTIFY)
;GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###
