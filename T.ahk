; Timer
; By: Chdata
; 5/11/2014

#SingleInstance, Force
ListLines Off
#NoEnv

FrqAltSubmit := Array("Fixed Date"
    ,"Hourly"
    ,"Daily"
    ,"Weekly"
    ,"Monthly"
    ,"Yearly"
    ,"Countdown")

FrqTitle := Array("Time, date:"
    , "Hour, minute:"
    , "Time:"
    , "Time, days of week:"
    , "Time, day:"
    , "Time, month, day:"
    , "Hours, minutes, seconds left: ")

; Weekly is the only option where days of week are enabled

FrqTime := Array("hh:mm:ss tt"
    , "mm:ss 'hourly'"
    , "hh:mm:ss tt"
    , "hh:mm:ss tt"
    , "hh:mm:ss tt"
    , "hh:mm:ss tt"
    , "HH:mm:ss")

FrqDate := Array("M/dd/yyyy"
    , "'---'"
    , "'---'"
    , "'---'"
    , "dd"
    , "MMM dd"
    , "'---'")

;0x1 LV0x1  Show grid lines
;+0x200     Can edit first box
;0x4        Single select only
;-LV0x10    No dragging columns

; Create the ListView and its columns:
Gui, Add, ListView, xm r12 w385 -LV0x10 +0x200 0x4 vMainListView gMyListView, Alarm|Frequency|Time|Date|f|t|d|w
LV_ModifyCol(1, 124)         ; Modify the width of each column
LV_ModifyCol(2, 80)          ; 65
LV_ModifyCol(3, 80)
LV_ModifyCol(4, 80)
LV_ModifyCol(5, 0)           ; Frequency value
LV_ModifyCol(6, 0)           ; Time YYYYMMDDHH24MISS
LV_ModifyCol(7, 0)           ; Date YYYYMMDDHH24MISS
LV_ModifyCol(8, 0)           ; Days of week
;LV_ModifyCol(3, "Integer")  ; For sorting, indicate that the Size column is an integer.

LV_Add("", "It is time to..sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss.", "Fixed date", "09:00:00 AM", "13th day", "", "", "", "")
LV_Add("", "---", "---", "---", "---", "", "", "", "")
LV_Add("", "---", "---", "---", "---", "", "", "", "")
LV_Add("", "---", "---", "---", "---", "", "", "", "")

; Buttons appearing on the main GUI
Gui, Add, Button,       gFunc_AddTimer , Add
Gui, Add, Button, x+8   gFunc_EditTimer, Edit
Gui, Add, Button, x+8   gFunc_DelTimer , Delete
Gui, Add, Button, x+8   gFunc_Options  , Options
Gui, Add, Button, x+165 gGuiClose      , Close

; Create the right-click menu (context menu)
Menu, MyContextMenu, Add, Open, ContextOpenFile
Menu, MyContextMenu, Add, Properties, ContextProperties
Menu, MyContextMenu, Add, Clear from ListView, ContextClearRows
Menu, MyContextMenu, Default, Open  ; Make "Open" a bold font to indicate that double-click does the same thing.

; Spawn the main GUI to be interacted with
Gui, Show,, Tick Tocker
return

MyListView:
if A_GuiEvent = DoubleClick  ; There are many other possible values the script can check.
{
msgbox meow
    ;LV_GetText(FileName, A_EventInfo, 1) ; Get the text of the first field.
    ;LV_GetText(FileDir, A_EventInfo, 2)  ; Get the text of the second field.
}
return

/*
Handles adding a new timer to the existing list

*/
Func_AddTimer:
Gui, 2:New
Gui, 2:+Owner1
Gui 1:+Disabled

Gui, 2:Add, Tab2, w400 h355, General|Sound && Video|Volume Control|Others

; General
Gui, 2:Tab, 1
Gui, 2:Add, Text, xp+10 y40 h20, Alarm Message:
Gui, 2:Add, Edit, xp+10 yp+20 r7 w361 h105 vAlarmMsg, It is time for... 

Gui, 2:Add, Text, xp-9 yp+115 h20, Frequency:
Gui, 2:Add, DropDownList, xp+65 yp-3 w145 AltSubmit vAlarmFrq g2Func_Freq, Fixed Date|Hourly|Daily|Weekly||Monthly|Yearly|Countdown

Gui, 2:Add, GroupBox, xp-65 yp+35 w368 h138 vFrqy, Time, days of week:

Gui, 2:Add, Text, xp+200 yp+26 h104 0x11  ;Vertical Line > Etched Gray

Gui, 2:Add, Text, xp-182 yp+4 h20, Time:  ;xp+20 yp+30
Gui, 2:Add, DateTime, xp+31 yp-3 w137 h20 vStartTime 1, hh:mm:ss tt

Gui, 2:Add, Text, xp-30 yp+40 h20, Date:
Gui, 2:Add, DateTime, xp+30 yp-3 w137 h20 g2UpDate vStartDate Section,
GuiControl, 2:Disable, StartDate

Gui, 2:Add, Button, xp+42 y+20 w95 v2GetTime g2GetTime, Get Current Time

Gui, 2:Add, Text, xp+130 yp-80 h20, Days of week:

Gui, 2:Add, Checkbox, vDay1, Sun
Gui, 2:Add, Checkbox, vDay2, Mon
Gui, 2:Add, Checkbox, vDay3, Tue
Gui, 2:Add, Checkbox, vDay4, Wed

Gui, 2:Add, Checkbox, xp+75 yp-57 vDay5, Thu
Gui, 2:Add, Checkbox, vDay6, Fri
Gui, 2:Add, Checkbox, vDay7, Sat

; Sound & Video
Gui, 2:Tab, 2
Gui, 2:Add, Radio, vMyRadio, Sample radio1
Gui, 2:Add, Radio,, Sample radio2

; Volume Control
Gui, 2:Tab, 3
Gui, 2:Add, Edit, vMyEdit r5  ; r5 means 5 rows tall.

; Others
Gui, 2:Tab, 4
Gui, 2:Add, Button, default xp+6, OK  ; xm puts it at the bottom left corner.
Gui, 2:Add, ComboBox, vColoraChoice, Red|Green|Blue|Black|White

; Exists on all tabs
Gui, 2:Tab
Gui, 2:Add, Button, x+120 y+283 w65 g2ButtonOK, OK
Gui, 2:Add, Button, x+8 w65 g2GuiClose, Cancel

Gui, 2:Show,, Create Alarm
return

2ButtonOK:
Gui, 2:Submit
Gui, 1:Default

Weekdays := 0
Loop 7
{
    Weekdays := Weekdays | ( Day%A_Index% << (A_Index-1) )
}

FormatTime, EndTime, StartTime, % FrqTime[AlarmFrq]

if (AlarmFrq == 5)
{
    FormatTime, EndDate, %StartDate%, d
    FormatTime, EndDate, %StartDate%, % "d'" . NatSuf(EndDate) . " day'"
}
else
{
    FormatTime, EndDate, StartDate, % FrqDate[AlarmFrq]
}

;dunno if I can make it differentiate between the title of my GUI and something else happening to have the same title

LV_Add("", AlarmMsg, FrqAltSubmit[AlarmFrq], EndTime, EndDate, AlarmFrq, StartTime, StartDate, Weekdays)

2GuiClose:
2GuiEscape:
Gui 1:-Disabled
WinActivate, Tick Tocker        ; This brings the GUI back to the top after we close this interface
Gui, 2:Destroy
return

; When a Frequency is chosen in the General tab
; This changes the text in the GroupBox
; As well as what type of Time/Date we are selecting
2Func_Freq:
Gui, 2:Submit, NoHide
GuiControl, 2:, Frqy, % FrqTitle[AlarmFrq]

; If it's weekly, the checkboxes remain enabled - else disabled
Weekly := (AlarmFrq == 4)
Loop 7
{
    GuiControl, 2:Enable%Weekly%, Day%A_Index%

    /* All this does is change whether or not stuff remains checkmarked or not when switching from yearly to weekly or otherwise

    if (AlarmFrq == 2 || AlarmFrq == 3) ; Hourly or Daily
    {
        GuiControl, 2:, Day%A_Index%, 1
    }
    else if (AlarmFrq != 4) ; Not weekly
    {
        GuiControl, 2:, Day%A_Index%, 0
    }
    */
}

GuiControl, 2:Text, StartTime, % FrqTime[AlarmFrq]

if (AlarmFrq == 1 || (AlarmFrq > 4 && AlarmFrq != 7))
{
    GuiControl, 2:Enable, StartDate

    if (AlarmFrq == 5)
    {
        FormatTime, EndDate, %StartDate%, d
        ;FrqDate[5] := "d'" . NatSuf(EndDate+0) . " day'"
        GuiControl, 2:Text, StartDate, % "d'" . NatSuf(EndDate+0) . " day'"
    }
    else
    {
        GuiControl, 2:Text, StartDate, % FrqDate[AlarmFrq]
    }
}
else
{
    if (AlarmFrq == 7)
    {
        GuiControl, 2:, StartTime, 00000000000 ;broken failing
        GuiControl, 2:Disable, 2GetTime
    }

    GuiControl, 2:Disable, StartDate
    GuiControl, 2:Text, StartDate, M/dd/yyyy
}

return

; Update the DateTime field appropriately for the "monthly" frequency
2UpDate:
{
    if (AlarmFrq == 5)
    {
        FormatTime, EndDate, %StartDate%, d
        ;FrqDate[5] := "d'" . NatSuf(EndDate+0) . " day'"
        GuiControl, 2:Text, StartDate, % "d'" . NatSuf(EndDate+0) . " day'"
    }
    return
}

NatSuf(n) ; NatSuf() by VxE
{
    return mod(n + 9, 10) >= 3 || mod(n + 89, 100) < 3 ? "th" : mod(n, 10) = 1 ? "st" : mod(n, 10) = 2 ? "nd" : "rd"
}

; Updates DateTime with the current time
2GetTime:
GuiControl, 2:, StartTime, %A_Now%
GuiControl, 2:, StartDate, %A_Now%
if (AlarmFrq == 5)
{
    FormatTime, EndDate, %A_Now%, d
    ;FrqDate[5] := "d'" . NatSuf(EndDate+0) . " day'"
    GuiControl, 2:Text, StartDate, % "d'" . NatSuf(EndDate+0) . " day'"
}
return

Func_EditTimer:
Func_DelTimer:
Func_Options:
LV_Delete()  ; Clear the ListView, but keep icon cache intact for simplicity.
return



GuiContextMenu:  ; Launched in response to a right-click or press of the Apps key.
if A_GuiControl <> MainListView  ; Display the menu only for clicks inside the ListView.
    return
; Show the menu at the provided coordinates, A_GuiX and A_GuiY.  These should be used
; because they provide correct coordinates even if the user pressed the Apps key:
Menu, MyContextMenu, Show, %A_GuiX%, %A_GuiY%
return

ContextOpenFile:  ; The user selected "Open" in the context menu.
ContextProperties:  ; The user selected "Properties" in the context menu.
; For simplicitly, operate upon only the focused row rather than all selected rows:
FocusedRowNumber := LV_GetNext(0, "F")  ; Find the focused row.
if not FocusedRowNumber  ; No row is focused.
    return
LV_GetText(FileName, FocusedRowNumber, 1) ; Get the text of the first field.
LV_GetText(FileDir, FocusedRowNumber, 2)  ; Get the text of the second field.
IfInString A_ThisMenuItem, Open  ; User selected "Open" from the context menu.
    Run %FileDir%\%FileName%,, UseErrorLevel
else  ; User selected "Properties" from the context menu.
    Run Properties "%FileDir%\%FileName%",, UseErrorLevel
if ErrorLevel
    MsgBox Could not perform requested action on "%FileDir%\%FileName%".
return

ContextClearRows:  ; The user selected "Clear" in the context menu.
RowNumber = 0  ; This causes the first iteration to start the search at the top.
Loop
{
    ; Since deleting a row reduces the RowNumber of all other rows beneath it,
    ; subtract 1 so that the search includes the same row number that was previously
    ; found (in case adjacent rows are selected):
    RowNumber := LV_GetNext(RowNumber - 1)
    if not RowNumber  ; The above returned zero, so there are no more selected rows.
        break
    LV_Delete(RowNumber)  ; Clear the row from the ListView.
}
return

;GuiSize:  ; Expand or shrink the ListView in response to the user's resizing of the window.
;if A_EventInfo = 1  ; The window has been minimized.  No action needed.
;    return
; Otherwise, the window has been resized or maximized. Resize the ListView to match.
;GuiControl, Move, MainListView, % "W" . (A_GuiWidth - 20) . " H" . (A_GuiHeight - 40)
;return

; Handles closing the GUI
GuiClose:
ExitApp