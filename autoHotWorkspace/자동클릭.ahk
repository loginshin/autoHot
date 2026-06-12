XButton1::
;3번째 버튼 루를때만 자동 클릭 버튼 때면 실행금지
; {
;     Loop{
;     if(MouseClick, XButton1,Down){
;     MouseCLICK, Left
;     SLEEP,30
;     }Else{
;         break
;     }
;     }
; }

;마우스 사이드버튼 위에꺼 누를시 연타 / 왼쪽 버튼으로하자
; XButton2::
; while (GetKeyState("XButton2", "P")) {
;     Click, Left
;     Sleep, 30
; }
; return
f::
while (GetKeyState("f", "P")) {
    Click, Left
    Sleep, 10
}
return