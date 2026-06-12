; 1.우선 크롬 브라우저 위에 마우스를 올렸을때 기능을 사용할 수 있도록 할거야, 마우스가 다른곳에 있는데 기능을 사용하면 '더 북 사이트여야만합니다'라는 메시지를 뜨게할거고
; 만약 브라우저에 마우스가 올라가있지만 'https://thebook.io/080266/'로 시작하는 url이 아니라면 마찬가지로'더 북 사이트여야만 합니다 라는 메시지를 보여줄거야',
; 2. 기능을 사용했을 때 'https://thebook.io/080266/'로 시작하는 사이트면 뒤에 페이지를 읽어오는 작업을할거야 그 숫자를 조작할거니까
; 예시로, url을 읽어왔을 때 'https://thebook.io/080266/0063/' 63페이지에 내가 위치하면 pageup키를 눌러서 다음페이지인 'https://thebook.io/080266/0064/' 로 이동을하게 만들거야
; 3. 마찬가지로 모든 조건이 충족했을때 pagedown키를 눌러서 이전 페이지인 'https://thebook.io/080266/0062/'페이지로 이동할거야



;************************************
;      함수 선언
;************************************


KoreanToEnglish(str) {
    Loop, Parse, str, / ; '/'로 문자열을 나눔
    {
        Loop, Parse, A_LoopField, - ; '-'로 문자열을 나눔
        {
            code := Asc(A_LoopField) ; 한글자씩 ASCII 코드로 변환
            if (code >= 44032 and code <= 55203) ; 한글 코드 범위 내인 경우에만 변환
                result .= Chr(code - 44032 + 12593) ; 한글을 영어로 변환하여 result 변수에 저장
            else
                result .= A_LoopField ; 한글 아닌 것은 그대로 저장
        }
        result .= "/"
    }
    return SubStr(result, 1, -1) ; 마지막에 추가한 '/'를 제거하여 반환
}


; 마우스가 브라우저 위에 있는지 확인하는 함수
IsMouseOverBrowser(browserName) {
  MouseGetPos, , , hWnd ;마우스가 있는 창의 id값을 받아오는 작업
  WinGetClass, this_class, ahk_id %hWnd%
  return (this_class == browserName) ? true : true ;이부분 둘다 true 로 바꾸니 진행됨
}

; 현재 URL이 올바른지 확인하는 함수
IsCurrentUrlValid() {
  url_ := GetCurrentUrl()
  return (StrLen(url_) > 0) && (InStr(url_, rootUrl) > 0)
}

; 현재 URL을 가져오는 함수
GetCurrentUrl() {
  clipboard := "" ; 클립보드를 비웁니다.
  Send, ^l
  Send, ^c
  ClipWait, 1 ; 클립보드가 복사되기를 기다립니다.
  return clipboard
}

; URL에서 페이지 번호를 가져오는 함수
GetCurrentPageNum(url) {
  regex := "\d{4}" ; 맨 뒤에 있는 4자리 숫자에 해당하는 정규식
  if RegExMatch(url, regex, page_num) ;url과 가공한 regex값을 합쳐 page_num으로 받는다
    return page_num
  else
    return -1 ; 에러 발생 시 -1 반환
}

; 새로운 URL로 이동하는 함수
NavigateTo(newUrl) {
  ; 여기에 원하는 브라우저에 따른 코드를 추가하세요.
  ; 이 예시에서는 크롬 브라우저를 대상으로 합니다.
  ; 아래 코드는 크롬 브라우저용입니다.
  ControlFocus, Chrome_RenderWidgetHostHWND1, ahk_class Chrome_WidgetWin_1
  Send ^l ; 주소창으로 커서를 이동
  Send %newUrl%{Enter} ; 새로운 URL을 입력하고 Enter 키를 누름
}


nextPage(){
SendInput, {ShiftDown}
sleep, 10
SendInput, Tab
sleep, 10
SendInput, Tab
sleep, 10
SendInput, Tab
sleep, 10
SendInput, Tab
sleep, 10
SendInput, Tab
sleep, 10
SendInput, Enter
sleep, 10
SendInput, {ShiftUp}
return
}


prePage(){
        SendInput, {ShiftDown}
    sleep, 10
    SendInput, Tab
    sleep, 10
    SendInput, Tab
    sleep, 10
    SendInput, Tab
    sleep, 10
    SendInput, Tab
    sleep, 10
    SendInput, Tab
    sleep, 10
    SendInput, Tab
    sleep, 10
    SendInput, Tab
    sleep, 10
    SendInput, Tab
    sleep, 10
    SendInput, Tab
    sleep, 10
    SendInput, Enter
    sleep, 10
    SendInput, {ShiftUp}
    return
}
; prePage() {
;     SendInput, {ShiftDown}{Tab 10}{Enter}{ShiftUp}
;     return
; }

;************************************
;      메인 코드
;************************************



rootUrl := "https://thebook.io/080266/"
browserName := "Chrome" ; 브라우저 이름을 설정하세요.



; 페이지 업 키(Menu)를 눌렀을 때 작동하는 함수
MButton & WheelUp::
  if (IsMouseOverBrowser(browserName) and IsCurrentUrlValid()) {
    ; CurrentUrl := GetCurrentUrl()
    PageNum := GetCurrentPageNum(CurrentUrl)
    if (PageNum + 1 <= 759) {
    ;   NewUrl := rootUrl . Format("{:04}", PageNum + 1)
    ;   NavigateTo(NewUrl) ;
        nextPage()
    }
  } else {
    MsgBox 더 북 사이트여야만합니다
  }
Return

; 페이지 다운 키(AppsKey)를 눌렀을 때 작동하는 함수
MButton & WheelDown::
  if (IsMouseOverBrowser(browserName) and IsCurrentUrlValid()) { ;브라우저 위에 마우스가 있고  url 값을 받아올 수 있으면
    ; CurrentUrl := GetCurrentUrl() ; 브라우저 url을 복사 후 변수에 저장
    PageNum := GetCurrentPageNum(CurrentUrl) ;
    if (PageNum - 1 >= 0) {
    ;   NewUrl := rootUrl . Format("{:04}", PageNum - 1)
    ;   NavigateTo(NewUrl) ;
    prePage()
    }
  } else {
    MsgBox 더 북 사이트여야만합니다
  }
Return
