;만약 chrome이 포커싱이 돼있다면 url을 f6이나 ctrl + l로 url을 클릭보드에 저장
; 저장이 되면 InStr으로 문자열에 thebook이 있는지 검사
;없다면 메시지, 있다면 기능 실행
;기능 url을 이용한 자바스크립트 조작


; 오토핫키 스크립트 시작
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed.
#SingleInstance  off;프로세스 연속 사용금지

If WinExist("ahk_class AutoHotkeyGUI")
{
	WinActivate
	ExitApp
}

;************************************
;      함수 선언
;************************************

nextPage() {
        ; Sleep, 20
        ; sendinput,javascript:document.getElementById("next-page").click()
        ; sendinput,{Enter}
        ;위에 코드에서 입력되는 속도도 줄일려고 클립보드를 사용했다. 

    Send, {F6}
    Sleep, 20
    Clipboard = javascript
    Sleep, 20
    send ^v
    sendinput : ;url에서 javasctip라는 단어를 붙여넣기가 안된다.
    Clipboard = document.getElementById("next-page").click()
    send ^v
    Sleep, 20
    sendinput {Enter}
    Sleep, 100
    ; PageInst.WaitForLoad() ;페이지 로딩 대기
    return
}

prePage() {
    Send, {F6}
    Sleep, 20
    Clipboard = javascript
    Sleep, 20
    send ^v
    sendinput : ;url에서 javasctip라는 단어를 붙여넣기가 안된다.
    Clipboard = document.getElementById("prev-page").click()
    send ^v
    Sleep, 20
    sendinput {Enter}
    Sleep, 100
    ; PageInst.WaitForLoad() ;페이지 로딩 대기
    return
}


;크롬 브라우저라면...
IsChromeActive() {
    WinGetClass, ActiveClass, A
    if (ActiveClass != "Chrome_WidgetWin_1") {
        return false
    }
    WinGetClass, ActiveTitle, A
    if (RegExMatch(ActiveTitle, "i)\bthebook\.io\b")) {
        return true
    }
    return true
}

;url을 복사해 클립보드에 복사헤 넣는다.
getUrl(){
    ; 현재 활성화된 창의 정보를 가져오기 위한 작업
    WinGet, currentWindow, ID, A
    WinGetClass, currentWinClass, ahk_id %currentWindow%

    ; 현재 브라우저가 Chrome 인지 확인
    if (currentWinClass == "Chrome_WidgetWin_1")
    {
        ; 주소 표시줄에 있는 URL 텍스트를 가져오기 위해 F6 누르기
        Send, {F6}
        Sleep, 20

        ; 복사하기를 사용하여 URL 텍를 클립보드로 복사
        Send, ^c
        Sleep, 30
        Send, {Esc}
        Sleep, 20

        ; 클립보드에 저장된 값을 URL 변수로 할당
        url := Clipboard
    }

    ; 브라우저가 다른 종류라면 어떤작업을 할지 정의
    ; 클립보드의 내용을 검하여 "thebook"이라는 문자열이 있는지 확인
    ; if InStr(url, "thebook")
    if InStr(url, "080266`/0") || InStr(url, "0080266/0") ;스프링 사이트여야만한다, 그것도 페이지 하나 선택해야해
    {
        ; "thebook"이 포함된 경우 true 반환
       return true
    }
    else
    {
        ; "thebook"이 포함되지 않은 경우 false 반환
    return false
    }

}


LoginGUI(){
    Gui, Font, s20, Arial ; 글꼴 크기 20으로 설정
    Gui, Add, Text, x140 y30, LoGinRemote 사용법 안내 ; Title
    Gui, Font,s11, Arial ; 기본 글꼴 크기로 복원


    ;변수 선언
    Rcntl1:="- PageUp = prePage"
    Rcntl2:="- PageDown = NextPage"

    ; Code render
    Gui, Font, s16, Arial ; 글꼴 크기 20으로 설정
    Gui, Add, Text, x100 y120 cBlue, 사용법
    Gui, Font,s11, Arial ; 기본 글꼴 크기로 복원
    Gui, Add, Text,x50,%Rcntl1%
    Gui, Add, Text,,%Rcntl2%



    Gui, Font, s20, Arial ; 글꼴 크기 20으로 설정
    Gui, Add, Text, x70 cRed ,주의
    Gui, Font,s11, Arial ; 기본 글꼴 크기로 복원
    Gui, Add, Text, x50, - 오로지 더 북 스프링에서만 동작합니다
    Gui, Add, Text,, - 가끔 한글로 변환돼서 검색될때가 있습니다.
    Gui, Add, Text,, - 무조건 페이지 하나 선택해서 사용하셔야합니다
    Gui, Add, Text,, - 즐겁게 코딩합시다


    btnText1:= "부팅 시 실행하는 법"
    btnText2:= "매크로 추가요청"
    btnText3:= "Thankyou LoGin"
    btnText4:= "스프링 공부하기"
    btnText5:= "스프링 깃허브"
    btnText6:= "스프링 코드다운"
    ; Gui, Add, Button, vGoToLink, 이동 ; 장식자 g, v
    Gui, Add, Button, x50 y640 gGoToLink, %btnText1%
    Gui, Add, Button,x180 y640 gQuestion, %btnText2%
    Gui, Add, Button,x450 y640 w130 -BackgroundColorBlue default, %btnText3%
    Gui, Add, Button, x250 y430 h80 gGoToStudy, %btnText4%
    Gui, Add, Button, x100 y480 gGitDown, %btnText5%
    Gui, Add, Button, x400 y480 gSrcDown, %btnText6%


    ; ASCII Art 추가
    LBody:="|          |"
    ; 읽기전용 Edit을 만들고 스크롤들을 없에준다
    Gui, Add, Edit, x400 y120 w100 readonly -VScroll -HScroll, A___A`n|  ・ㅅ・|  `n| っ ｃ |  `n%LBody%`n%LBody%`n%LBody% `nU￣￣U
    Gui, Add, Text,x340 y280, © copyright sign.신정환LoGinShin

    Gui, Show, w600 h700 , AutoHotkeyGUI ;   ;gui크기 설정, 최소화, 닫기 상단윈도우컨트롤러 제거
    Gui, -Caption -Border +ToolWindow +AlwaysOnTop ;GUI 옵션 사용 
    return


;버튼 클릭 이벤트 처리
ButtonThankyouLoGin:
Gui, Destroy
return
}
;버튼 이벤트 함수화
GoToLink(){
     URL := "https://loginshin.tistory.com/17" ; 이동하려는 링크를 지정합니다.
    Run, %URL% ; 지정된 링크를 기본 웹 브라우저로 여는 데 사용됩니다.
}
Question(){
    URL := "https://open.kakao.com/o/sVFNtrrf" ; 이동하려는 링크를 지정합니다.
    Run, %URL% ; 지정된 링크를 기본 웹 브라우저로 여는 데 사용됩니다.
}
GitDown(){
    URL := "https://github.com/gilbutITbook/080266" ; 이동하려는 링크를 지정합니다.
    Run, %URL% ; 지정된 링크를 기본 웹 브라우저로 여는 데 사용됩니다.
}
GoToStudy(){
     URL := "https://thebook.io/080266/" ; 이동하려는 링크를 지정합니다.
    Run, %URL% ; 지정된 링크를 기본 웹 브라우저로 여는 데 사용됩니다.
}
SrcDown(){
     URL := "https://www.gilbut.co.kr/book/view?bookcode=BN003594#bookData" ; 이동하려는 링크를 지정합니다.
    Run, %URL% ; 지정된 링크를 기본 웹 브라우저로 여는 데 사용됩니다.
}


;************************************
;      메인 코드
;************************************

LoginGUI() ;사용


;페이지 열기
ScrollLock::
Run "https://thebook.io/080266/"
return

; MButton & RButton::
PgDn::
if(IsChromeActive() and getUrl()){
nextPage()

}else {
    MsgBox 조건 : 더북 스프링페이지여야만합니다, 
  }
  return


  
; MButton & LButton::
PgUp::
if(IsChromeActive() and getUrl()){
prePage()
PageInst.WaitForLoad() ;페이지 로딩 대기
}else {
    MsgBox 더북 스프링사이트 페이지여야만합니다
  }

  return


; #if GetKeyState("MButton","p")

;     LButton & RButton::
;     Run "https://thebook.io/080266/"
;     return


;     RButton::
;     if(IsChromeActive() and getUrl()){
;     nextPage()
;     PageInst.WaitForLoad() ;페이지 로딩 대기
;     Return
;     }else {
;         MsgBox 더북 스프링사이트 페이지여야만합니다
;         Return
;     }
;     return



;     LButton::
;     if(IsChromeActive() and getUrl()){
;     prePage()
;     PageInst.WaitForLoad() ;페이지 로딩 대기
;     Return
;     }else {
;     MsgBox 더북 스프링사이트 페이지여야만합니다
;     Return
;     }
;     return

; #if


; Return