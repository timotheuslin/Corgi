#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.1.1 beta (minimal required version)
 Author:         Timothy

 Script Function:
    Template AutoIt script.

 R0 2010/6/22   Timothy

#ce ----------------------------------------------------------------------------

#include-once

;
; "Build/CleanUp"
;

; Start-CleanUp-Rebuild generic function


Global $TtScrTasks[$GlobalTaskAmount]   ; Start-CleanUp-Rebuild task

$TtScrTasks[$Enum_GlobalTask_Sct2]      = "SCT2_Build"
$TtScrTasks[$Enum_GlobalTask_Sct2_DB]   = "SCT2_DB_Build"
$TtScrTasks[$Enum_GlobalTask_RioVerde]  = "RioVerde_Build"
$TtScrTasks[$Enum_GlobalTask_Benton2]   = "B2_Build"
$TtScrTasks[$Enum_GlobalTask_Legacy]    = "LegacyBios_Build"
$TtScrTasks[$Enum_GlobalTask_GetLegacy] = "GetLegacy_Build"


Global $TtSetVar[$GlobalTaskAmount] ; Set Variable

$TtSetVar[$Enum_GlobalTask_Sct2]        = "SCT2_SetVariables"
$TtSetVar[$Enum_GlobalTask_Sct2_DB]     = "Sct2_DB_SetVariables"
$TtSetVar[$Enum_GlobalTask_RioVerde]    = "RioVerde_SetVariables"
$TtSetVar[$Enum_GlobalTask_Benton2]     = "B2_SetVariables"
$TtSetVar[$Enum_GlobalTask_Legacy]      = "LegacyBios_SetVariables"
$TtSetVar[$Enum_GlobalTask_GetLegacy]   = "GetLegacy_SetVariables"


Global $TtIniUpdata[$GlobalTaskAmount]  ; Ini update

$TtIniUpdata[$Enum_GlobalTask_Sct2]     = "SCT2_IniUpdate"
$TtIniUpdata[$Enum_GlobalTask_Sct2_DB]  = "Sct2_DB_IniUpdate"
$TtIniUpdata[$Enum_GlobalTask_RioVerde] = "RioVerde_IniUpdate"
$TtIniUpdata[$Enum_GlobalTask_Benton2]  = "B2_IniUpdate"
$TtIniUpdata[$Enum_GlobalTask_Legacy]   = "LegacyBios_IniUpdate"
$TtIniUpdata[$Enum_GlobalTask_GetLegacy]= "GetLegacy_IniUpdate"


Global $TtMfInit[$GlobalTaskAmount] ; MainForm Init

$TtMfInit[$Enum_GlobalTask_Sct2]        = "SCT2_Init"
$TtMfInit[$Enum_GlobalTask_Sct2_DB]     = "Sct2_DB_Init"
$TtMfInit[$Enum_GlobalTask_RioVerde]    = "RioVerde_Init"
$TtMfInit[$Enum_GlobalTask_Benton2]     = "B2_Init"
$TtMfInit[$Enum_GlobalTask_Legacy]      = "LegacyBios_Init"
$TtMfInit[$Enum_GlobalTask_GetLegacy]   = "GetLegacy_Init"

