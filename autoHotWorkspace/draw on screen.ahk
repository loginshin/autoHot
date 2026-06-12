/*
from:
http://www.autohotkey.com/forum/viewtopic.php?p=253705#253705
Shimanov, Metaxal, maximo3491, Relayer
If Shimanov agrees:
GNU General Public License 3.0 or higher <http://www.gnu.org/licenses/gpl-3.0.txt>

Version 1.9 - Metaxal 2010/06/10
  - fixed: bugs with show/hide tooltips
  - shows mouse pointer with width and color
  - erase the background with current color (F6)
  - uses Mbutton, MouseWheel

Version 1.8 - Metaxal 2010/06/09
  - added NumpadAdd/PgUp and NumpadSub/PgDown to control replay speed 
  - restored emptying of temp_file in batch (safety measure)
  - delete temp_file after compilation
  - moved tooltips to top left, because it messes with drawing ;
    retored drawing while help is on.
  
Version 1.7 - Relayer 2010/06/08, Metaxal 2010/06/09
  - fixed: generated batch files depends on the script name
  - modified extension of included script to ahkinc
    -> generated files are not standalone scripts
  - added Relayer modifications:
    - automatically delete the temporary work file
    - allow a drawing to be appended after replay when NOT compiled
    - changed the playback script to use the drawLine function (this eliminated mouse interference during playback and fixed a problem where the playback would not obey the mouse button UP)
    - added a help function to F1 and moved the function of the other keys to F2 thru F5
    - added color names (and moved the color order around a bit)
    - added a transient tooltip that shows the color and width when changed

Version 1.6 - Metaxal 2010/06/06
  - creates the batch scripts (DrawOnSCreen and compile) to replay files and compile them
  - script can replay a saved script! (not anymore in paint, but on the screen directly!)
    using the batch file.
    Works even with multiple-screens!
  - keypresses are also logged! (erase screen, widen pen, etc.)
  
Version 1.5 - Metaxal 2010/06/05
  - added multiple display support

TODO:
- draw point even if mouse not moved
- background can be erased to current color
- more colors, better UI ?
- scale mouse move to screen resolution ? (-> still ok if script replayed on a different screen)
  not easy to do
- command line parameters (initial width, color, etc.)
- when replaying a generated script, hotkeys (+/-) to speed up/down the moves
- display the disk width/color at mouse position (requires a new buffer)
*/

/*
    ********************
    *** README FIRST ***
    ********************

   
    ** Simple usage **

Just launch this script, draw on the screen with mouse moves, left and right mouse buttons, and keys F1-F5,
and press Escape when you're finished.

Press F1 for help when the script is running.
    left = draw
    right = erase
    Escape = quit
    F1 = show/hide this window
    F2/middle button = toggle colors
    F3/F4/MouseWheel = dec/inc width
    F5 = erases screen
    F6 = erase screen with color

Notice that 2 files are created the first time you launch DrawOnScreen.ahk:
- DrawOnScreen.bat (see next section)
- compile.bat (to create executables)

WARNING: From now on, you must run DrawOnScreen.bat instead of DrawOnScreen.ahk

    ** Replaying mouse-move scripts **

After pressing Escape, the mouse movements are saved to "painting.ahkinc".
Rename this file to whatever name you want to save it.

To replay a saved file, just drag&drop it onto the batch script "DrawOnScreen.bat".
At the end of the replay, you may need to press Escape to return to Windows.

You can use NumpadAdd/PgUp and NumpadSub/PgDown while replaying to control the speed

    ** Compiling move scripts **

To create a stand-alone executable from a saved move file,
just drag&drop it onto the batch script "compile.bat".
At the end of the replay, it will automatically exit after 1 second.

You can now send this .exe file to a friend!
Beware however that his/her screen resolution may be different from yours.

    ** Modifying a move script **

To modify the mouse speed, or end the script as soon as it is finished,
check the first and last lines of the generated script.
You can of course make other adjustments if you need.
 
*/

color_index := 2  ; first color to show
width := 2        ; initial width


; added by JB
; Menu, Tray, Icon, %A_ScriptDir%\159.ico
TO := 0

create_batch(bat_file, text) {
    if !( A_IsCompiled OR FileExist(bat_file))
        FileAppend %text%, %bat_file%
}

out_file =  painting.ahkinc
temp_file = paintingtemp.ahkinc ; WARNING: also change the filename at the #include lie (~line 228)

compile_bat =
(
:: move to script directory
cd /d `%0\..

copy `%1 "%temp_file%"
>> "%temp_file%" echo.
>> "%temp_file%" echo Sleep 1000
>> "%temp_file%" echo ExitApp
"%A_AhkPath%\..\Compiler\Ahk2exe.exe" /in "%A_ScriptName%" /out "`%~n1.exe"
del "%temp_file%"
)

; Create the compiler if does not exists
create_batch("compile.bat", compile_bat)

drawonscreen_bat = 
( 
:: move to script directory
cd /d `%0\..

:: create or empty %temp_file% (necessary if %temp_file% already exists)
>> "%temp_file%" echo.
:: does nothing if `%1 does not exist:
copy `%1 "%temp_file%"
start "%A_AhkPath%" "%A_ScriptName%" "`%1"
)

if !( A_IsCompiled OR FileExist("DrawOnScreen.bat"))
{
    ; Create batch launching file if does not exist (and not compiled)
    create_batch("DrawOnScreen.bat", drawonscreen_bat)
    MsgBox Please now use the DrawOnScreen.bat file
    ExitApp
}


color_codes=0x000000,0x0000FF,0xFF0000,0x008000,0x00FFFF,0xC0C0C0,0x808080,0xFFFFFF,0x800000,0x800080,0xFF00FF,0x00FF00,0x808000,0xFFFF00,0x000080,0x008080
color_names=Black,Red,Blue,Green,Yellow,Silver,Gray,White,Navy,Purple,Fuchsia,Lime,Teal,Aqua,Maroon,Olive

max_width = 200 ; max width of the brush

log_movement := !( A_IsCompiled ) && !(%0% > 0)  ; 0 for false, 1 for true
append_movement := false
;msgbox, %log_movement%
CoordMode, Mouse, Screen

Process, Exist
pid_this := ErrorLevel

hdc_screen := DllCall( "GetDC", "uint", 0 )

; Get the number of monitors:
SysGet, MonitorCount, MonitorCount

MonitorNum := 1 ; primary monitor

; if multiple displays:
if (MonitorCount > 1) {
    Gui, Add, Text,, Select the display:
    Gui, Add, Text,, 1
    Gui, Add, UpDown, vMonitorNum Range1-%MonitorCount%, 1
    Gui, Add, Button, default, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
    Gui, Show
    return  ; End of auto-execute section. The script is idle until the user does something.
}

ButtonOK:
Gui, Submit
Gui, Destroy
Sleep, 100 ; wait for the GUI to hide

; Get info about the monitor size
SysGet, Screen, Monitor, %MonitorNum%
; -> creates the 4 variables ScreenLeft, ScreenTop, ScreenRight, ScreenBottom

ScreenWidth := ScreenRight - ScreenLeft
ScreenHeight := ScreenBottom - ScreenTop


; Create a working buffer
hdc_buffer := DllCall( "CreateCompatibleDC", "uint", hdc_screen )
hbm_buffer := DllCall( "CreateCompatibleBitmap", "uint", hdc_screen, "int", ScreenWidth, "int", ScreenHeight )
DllCall( "SelectObject", "uint", hdc_buffer, "uint", hbm_buffer )

; Init the buffer with a screenshot
DllCall( "BitBlt", "uint", hdc_buffer, "int", 0, "int", 0, "int", ScreenWidth, "int", ScreenHeight, "uint", hdc_screen, "int", ScreenLeft, "int", ScreenTop, "uint", 0x00CC0020 )

; Same for secondary buffer
hdc_buffer2 := DllCall( "CreateCompatibleDC", "uint", hdc_screen )
hbm_buffer2 := DllCall( "CreateCompatibleBitmap", "uint", hdc_screen, "int", ScreenWidth, "int", ScreenHeight )
DllCall( "SelectObject", "uint", hdc_buffer2, "uint", hbm_buffer2 )
DllCall( "BitBlt", "uint", hdc_buffer2, "int", 0, "int", 0, "int", ScreenWidth, "int", ScreenHeight, "uint", hdc_screen, "int", ScreenLeft, "int", ScreenTop, "uint", 0x00CC0020 )

; Create a (completely transparent) window with the size of the display
Gui, +AlwaysOnTop -Caption
Gui, Show, x%ScreenLeft% y%ScreenTop% w%ScreenWidth% h%ScreenHeight%

; Get the hwnd associated with the canvas of the current window
WinGet, hw_canvas, ID, ahk_class AutoHotkeyGUI ahk_pid %pid_this%

; Get the canvas of the created window
hdc_canvas := DllCall( "GetDC", "uint", hw_canvas )

; Begin by drawing the background in the canvas
DllCall( "BitBlt", "uint", hdc_canvas, "int", 0, "int", 0, "int", ScreenWidth, "int", ScreenHeight, "uint", hdc_buffer, "int", 0, "int", 0, "uint", 0x00CC0020 )

; not exactly because colors are reverse in SetPixel...
StringSplit colors, color_codes, `,
StringSplit cnames, color_names, `,

color := colors%color_index%

x_last := 0
y_last := 0
Pace := 0

SetBatchLines, -1
SetMouseDelay -1 ; 1.5

left_down := false
right_down := false

if log_movement
{
    l =
(
; change the PaceFactor to speed up or slow down the replay
; PaceFactor = 0 is the fastest
; Try values like 0.05
PaceFactor := 1
)
   log .= l
}

/*
http://msdn.microsoft.com/en-us/library/ms645616(VS.85).aspx
wParam:
*/
WM_MOUSEMOVE = 0x0200
/*
; numbers
MK_CONTROL  := 0x0008
MK_LBUTTON  := 0x0001
MK_MBUTTON  := 0x0010
MK_RBUTTON  := 0x0002
MK_SHIFT    := 0x0004
MK_XBUTTON1 := 0x0020
MK_XBUTTON2 := 0x0040
*/

replaying := true

; Load the user script, and redraw the included actions
#Include *i paintingtemp.ahkinc

replaying := false

;this has been moved below the include to prevent mouse movements from messing with a replay
;it is enabled after so that an append can take place
if !( A_IsCompiled )
   OnMessage( WM_MOUSEMOVE, "onMouseMove" )


;; End of auto-executed section
return

getPace() {
    global Pace
    n := Pace*10
    if n > 1000
        return 1000
    else
        return n
}

onPaint() {
    global
    
    DllCall( "BitBlt", "uint", hdc_canvas, "int", 0, "int", 0, "int", ScreenWidth, "int", ScreenHeight, "uint", hdc_buffer2, "int", 0, "int", 0, "uint", 0x00CC0020 )
    
    if not replaying
    {
        cBrush := DllCall("gdi32.dll\CreateSolidBrush", "uint", color )
        drawCircle(round(x_last),round(y_last), cBrush, hdc_canvas)
        DllCall("gdi32.dll\DeleteObject", "uint", cBrush)
    }

    ; CAUTION !
    ; be careful not to call a function that calls onPaint!
    ; Prefer WM_ONPAINT (called only once) ?
    
}

onMouseMove( p_w, p_l ) {
   global hdc_canvas, hdc_buffer, x_last, y_last, width, color, left_down, right_down, log, log_movement, ScreenLeft, ScreenTop, Pace, append_movement

   x := (p_l & 0xFFFF)
   y := (p_l >> 16)

   lbutton := p_w & 0x0001 ; MK_LBUTTON
   rbutton := p_w & 0x0002 ; MK_RBUTTON

   if (lbutton)
   {
      if not left_down
      {
         SetTimer, Pacer, 10
         left_down := true
         if !(log_movement)
            append_movement := true
      }
      ;else
      ;{ 
         drawLine(x_last, y_last, x, y, color)
         l = drawLine( %x_last%, %y_last%, %x%, %y%, %color%)
         log_function(l, "true")
         Pace := 1
      ;}
   }
   else if (left_down)
      left_down := false

   if (rbutton)
   {
      if not right_down
      {
         SetTimer, Pacer, 10
         right_down := true
         if !(log_movement)
            append_movement := true
      }
      else
      {
         drawLine(x_last, y_last, x, y, "ERASE")
         l = drawLine( %x_last%, %y_last%, %x%, %y%, "ERASE")
         log_function(l, "true")
;         log .= "`ndrawLine(" . x_last . "," . y_last . "," . x . "," . y . ",""ERASE"" )"
         Pace := 1
      }
   }
   else if (right_down)
      right_down := false
   
   x_last := x
   y_last := y
   
   onPaint()
}

drawLine(x0, y0, x1, y1, color_ini=0) {
    global hdc_buffer2
    
    if (color_ini="ERASE")  
        cBrush := "ERASE"
    else
        cBrush := DllCall("gdi32.dll\CreateSolidBrush", "uint", color_ini )
        

    dx := x1 - x0
    dy := y1 - y0

    dxy := (Abs(dx) > Abs(dy) ? Abs(dx) : Abs(dy) )

    dx := dx / dxy
    dy := dy / dxy

    Loop %dxy%
    {
        x0 += dx
        y0 += dy

        drawCircle(round(x0),round(y0), cBrush, hdc_buffer2)
    }

    if color_ini!=ERASE
        DllCall("gdi32.dll\DeleteObject", "uint", cBrush)
        

    onPaint()
}

/*
This could be clearly enhanced !
Many things should be in draw-line instead!
*/
drawCircle(x,y, cBrush, hdc_dest) {
    global hdc_buffer, width, ScreenWidth, ScreenHeight

    cRegion := DllCall( "gdi32.dll\CreateRoundRectRgn", "int", x-width , "int", y-width , "int", x+width , "int", y+width, "int", width*2, "int", width*2 )

    if (cBrush="ERASE")
    {
        ; from http://msdn.microsoft.com/en-us/library/dd183437%28VS.85%29.aspx
        ; Select clipping region
        DllCall( "SelectClipRgn", "uint", hdc_dest, "uint", cRegion )
     
        ; Transfer (draw) the bitmap into the clipped rectangle.
        DllCall( "BitBlt", "uint", hdc_dest, "int", 0, "int", 0, "int", ScreenWidth, "int", ScreenHeight, "uint", hdc_buffer, "int", 0, "int", 0, "uint", 0x00CC0020 ) ; SRCCOPY http://www.pinvoke.net/default.aspx/gdi32/bitblt.html
       
        ; Select the full region back
        DllCall( "SelectClipRgn", "uint", hdc_dest, "uint", 0 )
    }
    else
        DllCall( "gdi32.dll\FillRgn" , "uint", hdc_dest , "uint", cRegion , "uint", cBrush )

    DllCall("gdi32.dll\DeleteObject", "uint", cRegion)
}

rotate_color() {
    global
    color_index++
    if(color_index > 16)
        color_index := 1
    color := colors%color_index%
    onPaint()
    Gosub, ShowTip
}

color_erase_canvas() {
    global
    cBrush := DllCall("gdi32.dll\CreateSolidBrush", "uint", color )
    DllCall( "SelectObject", "uint", hdc_buffer2, "uint", cBrush )
    DllCall( "BitBlt", "uint", hdc_buffer2, "int", 0, "int", 0, "int", ScreenWidth, "int", ScreenHeight, "uint", hdc_buffer, "int", 0, "int", 0, "uint", 0x00F00021 ) ; PATPAINT 
    DllCall( "SelectObject", "uint", hdc_buffer2, "uint", 0 )
    DllCall("gdi32.dll\DeleteObject", "uint", cBrush)
    onPaint()
}

erase_canvas() {
    global
    DllCall( "BitBlt", "uint", hdc_buffer2, "int", 0, "int", 0, "int", ScreenWidth, "int", ScreenHeight, "uint", hdc_buffer, "int", 0, "int", 0, "uint", 0x00CC0020 )
    onPaint()
}

width_minus() {
    global
    if width > 1
        width--
    onPaint()
   Gosub, ShowTip
}

width_plus() {
    global
    if width < %max_width%
        width++
    onPaint()
   Gosub, ShowTip
}

log_function(fun_str, wait="false") {
    global log
    if wait is number
        log .= "`nSleep, " . wait
    else if (wait!="false")
        log .= "`nSleep, % " . getPace() . "*PaceFactor"  ; %
    log .= "`n" . fun_str
}

F1::
Tooltip ; hide it, just in case
if (TO = 1)
   Goto, nTO
TO := 1
;OnMessage( WM_MOUSEMOVE, "" )
   Help = 
(
* Draw on Screen
    hold left button = draw
    hold right button = erase
    Escape = quit
    F1 = show/hide this window
    F2/middle button = toggle colors
    F3/F4/MouseWheel = dec/inc width
    F5 = erases screen
    F6 = erase screen with color
   
* While Replaying
    Numpad+/PageUp = speed up
    Numpad-/PageDown = slow down
)
ToolTip, %Help%, 5, 5
Return

nTO:
TO := 0
Tooltip
;if !( A_IsCompiled )
;   OnMessage( WM_MOUSEMOVE, "onMouseMove" )
Return


ShowTip:
Tooltip ; hide it, just in case
TO := 0
if !( A_IsCompiled )
{
   cname := cnames%color_index%
   Tip := cnames%color_index%
   ToolTip, %Tip% %width%, 5, 5
   SetTimer, EndTip, 700
}   
Return   

EndTip:
   SetTimer, EndTip, Off
   ToolTip
Return
 
MButton::
F2::
    rotate_color()
    log_function("rotate_color()", false)
return
   
WheelDown::
F3::
    width_minus()
    log_function("width_minus()")
return

WheelUp::
F4::
    width_plus()
    log_function("width_plus()")
return

F5::
    erase_canvas()
    log_function("erase_canvas()")
return

F6::
    color_erase_canvas()
    log_function("color_erase_canvas()")
return

Pacer:
    Pace += 1
Return

PgUp::
NumpadAdd::
PaceFactor *= .8
return

PgDn::
NumpadSub::
PaceFactor *= 1.125
return


Escape::
if ((log_movement || append_movement) && (Pace <> 0)) ; if Pace > 0, then there has been some move, e.g. by appending after replay
{
    if !(append_movement)
      FileDelete, %out_file%
      
    l =
(

;Sleep 1000 ; uncomment these two lines..."
;ExitApp ; ...to end the script as soon as it is finished"

)
    log .= l
    FileAppend, %log%, %out_file%
}
FileDelete, %temp_file%
ExitApp