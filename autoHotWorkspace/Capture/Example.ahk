#Include Capture.ahk
OBJ := new Capture()
return

F1::
SaveDir := A_ScriptDir "\test.png"
if OBJ.Capture(SaveDir)
	MsgBox, % "캡쳐가 완료되었습니다.`n" SaveDir
else
	MsgBox, 캡쳐 취소.
return



Esc::
ExitApp