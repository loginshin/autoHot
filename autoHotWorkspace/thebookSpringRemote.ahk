;만약 chrome이 포커싱이 돼있다면 url을 f6이나 ctrl + l로 url을 클릭보드에 저장
; 저장이 되면 InStr으로 문자열에 thebook이 있는지 검사
;없다면 메시지, 있다면 기능 실행


; 오토핫키 스크립트 시작
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed.


;************************************
;      함수 선언
;************************************

nextPage() {
    Loop, 5 {
         Send, +{Tab}
        sleep, 20
    }
    SendInput, {Enter}
    return
}

prePage() {
    Loop, 9 {
         Send, +{Tab}
        sleep, 20
    }
    SendInput, {Enter}
    return
}



; IsChromeActive() {
;     ;크롬을 포커싱 중이라면
;     WinGetClass, ActiveClass, A
;     if (ActiveClass = "Chrome_WidgetWin_1") {
;         return true
;     } else {
;         ;크롬을 포커싱하고있지 않다면
;         return false
;     }
; }





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


;************************************
;      메인 코드
;************************************
browserName := "Chrome" ; 브라우저 이름을 설정하세요.


;페이지 열기
ScrollLock::
Run "https://thebook.io/080266/"
return

; MButton & RButton::
PgDn::
if(IsChromeActive() and getUrl()){
nextPage()
PageInst.WaitForLoad() ;페이지 로딩 대기
}else {
    MsgBox 더북 스프링사이트 페이지여야만합니다
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