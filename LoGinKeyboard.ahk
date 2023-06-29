; 다중 인스턴스 실행 방지
#SingleInstance Off

If WinExist("ahk_class AutoHotkeyGUI")
{
	WinActivate
	ExitApp
}

;GUI 함수화
LoginGUI(){
        
    Gui, Font, s20, Arial ; 글꼴 크기 20으로 설정
    Gui, Add, Text, x380 y30, LoGinKeyboard 사용법 안내 ; Title
    Gui, Font,s11, Arial ; 기본 글꼴 크기로 복원
    Gui, Add, Text,x330,사용법 확인 =>  - RControl + CapsLock (방향키 옆 한자키 + 캡스락)



    ;변수 선언
    Rcntl1:="- RControl + 방향키(←,→,↑,↓) => Home, End, PGUP, PGDN키 사용 가능"
    Rcntl2:="- (글씨 드래그) 후 RControl + Enter => 구글 검색"
    Rcntl3:="- (글씨 드래그) 후 RControl + RShift => 한글로 번역"
    ; Code render
    Gui, Font, s16, Arial ; 글꼴 크기 20으로 설정
    Gui, Add, Text, x120 y120 cGreen, RControl 조합법
    Gui, Font,s11, Arial ; 기본 글꼴 크기로 복원
    Gui, Add, Text,x50,%Rcntl1%
    Gui, Add, Text,,%Rcntl2%
    Gui, Add, Text,,%Rcntl3%

    ;구분선
    ; Gui, Add, Text,x550 y160,  ㅣ
    ; Gui, Add, Text,x550 y180,  ㅣ
    ; Gui, Add, Text,x550 y200,  ㅣ
    ; int y = 160; ; 오토핫키는 C++과 다르게 세미콜론, for문을 사용하지 않는다 '='도사용하지 않는다.
    ;구분선
    y := 120
    Loop, 10
    {
        Gui, Add, Text, x520 y%y%, ㅣ
        y += 20
    }


    caps1:="- CapsLock + spaceBar,z,x,c,a,s,d,q,w,e키 누르면 숫자 출력 (흡사 NumberPad)"
    caps2:="- CapsLock + j,k,l,i (키보드 돌기튀어나온 J부터 방향키 왼쪽) 방향키 +) H+j,k,l,i 는 홈엔드..."
    caps3:="- capslock + 방향키(←,→,↑,↓) => 화살표 출력"
    Gui, Font, s16, Arial ; 글꼴 크기 20으로 설정
    Gui, Add, Text, x640 y118 cGreen, CapsLock 조합법
    Gui, Font,s11, Arial ; 기본 글꼴 크기로 복원
    Gui, Add, Text,x560 y160,%caps1%
    Gui, Add, Text,x560 y200,%caps2%
    Gui, Add, Text,x560 y240,%caps3%
    Gui, Add, Text,x560 , `n


    Gui, Add, Text,x420 y340,Lctrl + LShift + Q => 프로그램 종료 `n



    Gui, Add, Text,,  ↓↓↓아래 텍스트에 연습해보세요↓↓↓
    Gui, Add, Edit, x370 w300 h30 ,위에 단축키 연습해보세요 ;텍스트 연습하는곳



    Gui, Font, s20, Arial ; 글꼴 크기 20으로 설정
    Gui, Add, Text, x50 cRed ,주의
    Gui, Font,s11, Arial ; 기본 글꼴 크기로 복원
    Gui, Add, Text, x50, 게임할땐 꼭 이프로그램을 꺼주세요
    Gui, Add, Text,, CapsLock키, NumberLock키, ScrollLock키는 잡궈뒀습니다.
    Gui, Add, Text,, CapsLock 버튼을 사용하시려면 CapsLock + Tab 키를 누르면 활성화/비활성화 할 수 있습니다..


    btnText1:= "부팅 시 실행하는 법"
    btnText2:= "매크로 추가요청"
    btnText3:= "Thankyou LoGin"
    ; Gui, Add, Button, vGoToLink, 이동 ; 장식자 g, v
    Gui, Add, Button, x50 y640 gGoToLink, %btnText1%
    Gui, Add, Button,x180 y640 gQuestion, %btnText2%
    Gui, Add, Button,x900 y640 w130 -BackgroundColorBlue default, %btnText3%


    ; ASCII Art 추가
    LBody:="|          |"
    ; 읽기전용 Edit을 만들고 스크롤들을 없에준다
    Gui, Add, Edit, x920 y460 w100 readonly -VScroll -HScroll, A___A`n|  ・ㅅ・|  `n| っ ｃ |  `n%LBody%`n%LBody%`n%LBody% `nU￣￣U
    Gui, Add, Text,x860 y600, © copyright sign.신정환LoGinShin

    Gui, Show, w1100 h700 , AutoHotkeyGUI ;   ;gui크기 설정, 최소화, 닫기 상단윈도우컨트롤러 제거
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

;==========================GUI 끝=================================



;============loGin Key MAIN    ======================
LoginGUI()
;넘버락 항상 켜기, 캡스락 항상 끄기, 스크롤 락 항상 끄기
SetNumLockState, AlwaysOn
SetCapsLockState, AlwaysOff
SetScrollLockState, AlwaysOff
; 단일 한자키만 먹지 않게
*SC1F1::
*vk19::
return

CapsLock & Tab::CapsLock



; 한자키 이용 조합키
#if GetKeyState("SC1F1","p")

;프로젝트 사용법 설명
CapsLock::LoginGUI() ;---------------GUI 보이기


Right:: end
Left:: Home
Up:: PGUP
Down:: PGDN


Enter::
Send ^c
Sleep 55
Run "http://www.google.com/search?q=%clipboard%"
return

RShift::
SendInput,^c
Sleep 50
; run,https://translate.google.com/#view=home&op=translate&sl=en&tl=ko&text=%clipboard%  ;한국어 -> 영어
run,https://translate.google.co.kr/?hl=ko&sl=auto&tl=ko&text=%clipboard%&op=translate    ; 언어감지 -> 영어
return
#if



;CapsLock누르고 있을시 Fn화
#if GetKeyState("CapsLock","P") 
h & j::Home
h & l::End
i::Up
j::Left
l::Right
k::Down

Space::SendInput 0
z::SendInput, 1
x::SendInput,2
c::SendInput,3
a::SendInput,4
s::SendInput,5
d::SendInput,6
q::SendInput,7
w::SendInput,8
e::SendInput,9
Esc:: SendInput, ``
Up::SendInput ↑
Down::SendInput ↓
Left::SendInput ←
Right::SendInput →
#if

;종료
^+q::
ExitApp
return

;롤 클라이언트 작동시 꺼지기
#ifWinActive ahk_exe LeagueClientUx.exe
LButton::
ExitApp
return


