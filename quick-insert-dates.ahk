#NoEnv	;
;	#Warn	;
SendMode Input	;
SetWorkingDir %A_ScriptDir%	;
#SingleInstance, force


settings_file = Mdate_Settings.ini
startup_shortcut := A_Startup . "\Mdate.lnk"
settings := Object()

; Initialize Settings in the following way:
; array[key]   := ["Section", "Key", "Value"]
settings["dash"] := ["Format", "dashseparated", true]
settings["dott"] := ["Format", "dotseparated", false]
settings["sww"] := ["General", "startup_run", false]

if !FileExist(settings_file) {
    write_settings(settings)
    settingsGui()
}
read_settings(settings)

; Set up the right click menu
Menu, Tray, NoStandard

; Menu, Tray, Add, About, about
Menu, Tray, Add, Settings, settingsGui
Menu, Tray, Default, Settings
Menu, Tray, Add,
Menu, Tray, Add, Reset, reset
Menu, Tray, Add, Restart, restart
Menu, Tray, Add, Exit, exit
Menu, Tray, Tip, Quick Insert Dates

; Define the settings GUI
settingsGui() {
    global

    ; Initialization
    Gui, Settings: New
    Gui, Settings: -Resize -MaximizeBox +OwnDialogs

    ; Title and Copyright
    Gui, Settings:font, s18, Arial
    Gui, Settings:Add, Text, Center W475, Insert Date Settings
    Gui, Settings:font, s8 c808080, Trebuchet MS
    Gui, Settings:Add, Text, Center W475 yp+26, Copyright (c) 2016 Jason Cemra (Em-n-en Script)

    ; Standard Settings
    Gui, Settings:font, s8 c505050, Trebuchet MS
    Gui, Settings:Add, GroupBox, w455 h283, Standard Settings
    Gui, Settings:font, s10 c10101f, Trebuchet MS
    Gui, Settings:Add, Text, Left w210 xp+12 yp+22, Format for Date Insertion:

    Gui, Add, Checkbox, yp+25 vcheck_dashseparated_format, Dash Separated
    Gui, Settings:font, s8 c808080, Trebuchet MS
    Gui, Settings:Add, Text, W400 yp+20, To insert date in the yyyy-MM-dd format, type "ymd-"
    Gui, Settings:font, s10 c10101f, Trebuchet MS
	
	Gui, Add, Checkbox, yp+25 vcheck_dottseparated_format, Dot Separated
    Gui, Settings:font, s8 c808080, Trebuchet MS
    Gui, Settings:Add, Text, W400 yp+20, To insert date in the yyyy.MM.dd format, type "ymd."
    Gui, Settings:font, s10 c10101f, Trebuchet MS

    Gui, Settings:Add, Text, Left w210 yp+35, Other Settings:
    Gui, Add, Checkbox, yp+25 vcheck_start_with_windows, Start on Windows Startup
    Gui, Settings:font, s10 c810000, Arial
    Gui, Settings:Add, Button, yp+25 w180 gSettingsButtonReset, Reset everything to default

    ; Buttons
    Gui, Settings:Add, Button, Default xp+158 yp+50 w85, Ok
    Gui, Settings:Add, Button, xp+100 w85, Apply
    Gui, Settings:Add, Button, xp+100 w85, Cancel

    loadSettingsToGui()
    Gui, show, W500 H400 center, Insert Date Settings
}
; GUI Actions
settingsButtonOk() {
    if (pullSettingsFromGui()) {
        Gui, Settings:Destroy
    } else {
        MsgBox, Errer!
    }
}
settingsButtonApply(){
    pullSettingsFromGui()
}
loadSettingsToGui(){
    global
    GuiControl, Settings:, check_dashseparated_format, % settings["dash"][3]
    GuiControl, Settings:, check_dottseparated_format, % settings["dott"][3]
	GuiControl, Settings:, check_start_with_windows, % settings["sww"][3]
}
pullSettingsFromGui(){
    global
    Gui, Settings:Submit, NoHide
    settings["dash"][3] := check_dashseparated_format
    settings["dott"][3] := check_dottseparated_format	
    settings["sww"][3] := check_start_with_windows
    save()
    update_sww_state(settings["sww"][3])
    return true
}
settingsButtonCancel(){
    Gui, Settings:Destroy
}
settingsButtonReset() {
    Gui, Settings: +OwnDialogs
    reset()
}


;  On-startup logic
sww() {
    global
    settings["sww"][3] := !settings["sww"][3]
    save()
    update_sww_state(settings["sww"][3])
    loadSettingsToGui()
}

update_sww_state(state){
    global startup_shortcut
    if (state) {
        FileGetShortcut, %startup_shortcut%, shortcut_path
        if (!FileExist(startup_shortcut) || shortcut_path != A_ScriptFullPath) {
            startup_shortcut_create()
        }
    } else {
        startup_shortcut_destroy()
    }
}

startup_shortcut_create() {
    global startup_shortcut
    FileCreateShortcut, %A_ScriptFullPath%, %startup_shortcut%, %A_WorkingDir%
}

startup_shortcut_destroy() {
    global startup_shortcut
    FileDelete, %startup_shortcut%
}

; Settings logic
save() {
    global settings
    write_settings(settings)
}

write_settings(settings) {
    global settings_file
    for index, var in settings {
        IniWrite, % var[3], %settings_file%, % var[1], % var[2]
    }
}

read_settings(ByRef settings) {
    global settings_file
    for index, var in settings {
        IniRead, buffer, %settings_file%, % var[1], % var[2]
        var[3] := buffer
    }
}

; Exit logic
restart() {
    save()
    Reload
    ExitApp
}

exit() {
    save()
    ExitApp
}

reset(){
    global
    MsgBox, 0x34, Are you sure?, This will completely wipe all settings and exit the program.
    IfMsgBox, No
        return
    FileDelete, %settings_file%
    startup_shortcut_destroy()
    ExitApp
}

#If, settings["dash"][3]
:*?:ymd-::
FormatTime, CurrDate, A_now, yyyy-MM-dd
Send, %CurrDate%
return

#If, settings["dott"][3]
:*?:ymd.::
FormatTime, CurrDate, A_now, yyyy.MM.dd
Send, %CurrDate%
return
