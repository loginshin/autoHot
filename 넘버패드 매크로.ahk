; 제목을 적으면 네이버, 다음, 구글에 검색하기


; 안뜨면 저품질
; <사용법>
; num1:: 클립보드, 드래그한것을 구글 검색
; num2:: 클립보드, 드래그한것을 다음검색 검색
; num3:: 클립보드, 드래그한것을 네이버검색 검색
; num4::
; num5::
; num6::
; num7::
; num8::
; num9::



    ;Run "https://search.daum.net/search?nil_suggest=btn&w=tot&DA=SBC&q=%clipboard%" = 새로운 창으로 열기
    ;Run "https://search.daum.net/search?q=%clipboard%" 기존 창으로 열기
    ;nil_suggest=btn&w=tot&DA=SBC&


Numpad1::
Send ^c
Sleep 55
Run "http://www.google.com/search?q=%clipboard%"
return


Numpad2::
Send ^c 
Sleep 55
Run "https://search.daum.net/search?q=%clipboard%"
return


Numpad3::
Send ^c
Sleep 55
Run "https://search.naver.com/search.naver?query=%clipboard%"
return




Numpad4::
InputBox, inputValue, 입력, 값을 입력하세요.
;MsgBox % "입력된 값: " . inputValue

return












; Numpad5::


; ; 설정 초기화
; #NoEnv
; #Warn
; SendMode Input
; SetWorkingDir %A_ScriptDir%
; #SingleInstance, force
; CoordMode, Mouse, Screen
; SetBatchLines, -1

; global yPos := 30 ; 초기 입력 필드의 y 좌표
; Hotkey, Numpad5, OpenInputWindow ; NumPad5 키를 눌렀을 때 OpenInputWindow 함수를 호출
; Return

; ; 입력 창 생성 함수
; OpenInputWindow:
; Gui, Font, s10
; ; 입력 필드를 생성하는 버튼 추가
; Gui, Add, Button, gCreateField x+10 y10, 추가 입력 받기
; ; 입력이 완료되었을 때, 검색하는 버튼 추가
; Gui, Add, Button, gSubmitButton x+100 y10, 검색하기
; ; 입력 필드를 삭제하는 버튼 추가
; Gui, Add, Button, gDeleteField x+190 y10, 삭제하기

; Goto, CreateField ; 실행시 첫 번째 입력 필드를 생성합니다.

; ; 입력 필드 추가 함수
; CreateField:
; Gui, Font, s10
; ; 입력 필드 옆의 '값' 텍스트 추가
; Gui, Add, Text, vText%yPos% x20 y%yPos%, 값 %yPos%:
; ; 입력 필드 추가
; Gui, Add, Edit, vInputValue%yPos% x80 y%yPos% w400, % (yPos=30 ? "검색어를 입력해주세요." : "")

; yPos += 45 ; 텍스트 필드 간격 더 넓게 조정
; Gui, Show, AutoSize, 입력 창 ; 입력 창의 이름을 설정하고 크기를 자동 조절합니다.
; Return

; ; 검색하기 버튼 클릭 시 이벤트
; SubmitButton:
; Gui, Submit, NoHide
; Loop, % (yPos / 45) {
;     GuiControlGet, inputValue, , InputValue%A_Index% ; 입력값 가져오기
;     searchUrl := "https://www.google.com/search?q=" . URLEncode(inputValue) ; 검색 URL 생성
;     Run, %searchUrl% ; 웹 브라우저로 검색 URL 실행
;     Sleep, 500 ; 이전 결과창 남기기 위해 잠시 대기
; }
; yPos := 30 ; 다음 입력 창을 위해 초기화합니다.
; Gui, Destroy ; 입력 창 닫고 초기화합니다.
; Return

; ; 입력 필드 삭제 함수
; DeleteField:
; if (yPos > 30) {
;     yPos -= 45 ; 다음 입력 창을 삭제하기 위해 초기화합니다.
;     GuiControl, delete, InputValue% (yPos / 45 + 1) % ; 마지막 입력 필드 제거
;     GuiControl, delete, Text% (yPos / 45 + 1) % ; 마지막 '값' 텍스트 제거
; }
; Return

; GuiClose:
; ExitApp

; ; 인코딩 함수
; URLEncode(str) {
;     VarSetCapacity(Var, StrPut(str, "UTF-8") * 3, 0)
;     StrPut(str, &Var, "UTF-8")
;     While Code := NumGet(Var, A_Index - 1, "UChar"){
;         If (Code >= 33) && (Code <= 126) && (Code != 0x25){
;             Res .= Chr(Code)
;         } Else {
;             Res .= (Code < 0x100 ? "%0" : "%u00") . SubStr(Format("{:x}", Code), -1)
;         }
;     }
;     Return, Res
; }














Numpad6::












Numpad7::
Numpad8::
Numpad9::
Numpad0::