; loGin Key
; 한영 자판 변환 프로그램
; 창 조절 프로그램






;============loGin Key ==================
;넘버락 항상 켜기, 캡스락 항상 끄기, 스크롤 락 항상 끄기
SetNumLockState, AlwaysOn

SetCapsLockState, AlwaysOff

SetScrollLockState, AlwaysOff



;capsLock키와 j,k,l,i,u,o키로 방향키 조합----------------------------------
CapsLock & Tab::CapsLock


F13::
Send, #1
sleep, 50
send, #2
sleep, 50
send, #3



;like 660m Fn 방향키 조합 home end-------------------------------------------
SC1F1 & Left:: Home
SC1F1 & Right:: end
VK19 & Left:: Home
VK19 & Right:: end
SC1F1 & Up:: PGUP
SC1F1 & Down::PGDN
VK19 & Up:: PGUP
VK19 & Down:: PGDN



;휠버튼 누른상태로 볼륨 조절
~MButton & WheelUp:: Volume_Up
~MButton & WheelDown:: Volume_Down
;더블 휠 클릭시 뮤트
~MButton::
if (A_PriorHotkey != "~MButton") || (A_TimeSincePriorHotkey > 300) ; 휠 클릭 2번이면 닫기
return
Send, {Volume_Mute}
return


; 휠버튼 + 좌클릭 = 뒤로가기, 휠버튼 + 우클릭 = 앞으로 가기
~Mbutton & RButton:: Media_Next
~Mbutton & LButton:: Media_Prev



 ;궁금한거 복사해서 scroll lock 키 누르면 구글 크롬에 검색해줌
 ScrollLock::
Send ^c
Sleep 55
Run "http://www.google.com/search?q=%clipboard%"
return
 
;pus/Brk 키 누를시 영/한 번역
pause::
SendInput,^c
Sleep 50
run,https://translate.google.com/#view=home&op=translate&sl=en&tl=ko&text=%clipboard%
return




CapsLock::RAlt
#if GetKeyState("CapsLock","P")
h & j::Home
h & l::End
i::Up
j::Left
l::Right
k::Down
p::BackSpace
`;::delete


Space::SendInput 0
z::SendInput, 1
x::SendInput, 2
c::SendInput, 3
a::SendInput, 4
s::SendInput, 5
d::SendInput, 6
q::SendInput, 7
w::SendInput, 8
e::SendInput, 9
Esc:: SendInput, ``


Up::SendInput ↑
Down::SendInput ↓
Left::SendInput ←
Right::SendInput →


1::SendInput ①
2::SendInput ②
3::SendInput ③
4::SendInput ④
5::SendInput ⑤
6::SendInput ⑥
7::SendInput ⑦
8::SendInput ⑧
9::SendInput ⑨
0::SendInput ⑩○●



.::Send {…}
r::SendInput, ■:(대주제) ▶:(소주제), ▷:(설명)
f::SendInput, ± ∴(그러므로) ∵(왜냐하면)
v::SendInput, {ㆍ}


#if





vk19 & Space::SendInput 0
vk19 & z::SendInput, 1
vk19 & x::SendInput, 2
vk19 & c::SendInput, 3
vk19 & a::SendInput, 4
vk19 & s::SendInput, 5
vk19 & d::SendInput, 6
vk19 & q::SendInput, 7
vk19 & w::SendInput, 8
vk19 & e::SendInput, 9
vk19 & Esc:: SendInput, ``





AppsKey & Up::SendInput ↑
AppsKey & Down::SendInput ↓
AppsKey & Left::SendInput ←
AppsKey & Right::SendInput →


AppsKey & 1::SendInput ①
AppsKey & 2::SendInput ②
AppsKey & 3::SendInput ③
AppsKey & 4::SendInput ④
AppsKey & 5::SendInput ⑤
AppsKey & 6::SendInput ⑥
AppsKey & 7::SendInput ⑦
AppsKey & 8::SendInput ⑧
AppsKey & 9::SendInput ⑨
AppsKey & 0::SendInput ⑩○●



AppsKey & .::Send {…}
AppsKey & q::SendInput, ■:(대주제) ▶:(소주제), ▷:(설명)
AppsKey & w::SendInput, ± ∴(그러므로) ∵(왜냐하면)
AppsKey & e::SendInput, {ㆍ}
AppsKey & v::SendInput, {♥}


#J::run Taskmgr ;win + j 키로 작업관리자 시작






;====================창 조절 프로그램===============

#SingleInstance force	; 중복실행시 다시 실행

Menu, Tray, NoStandard	; 트레이 기본 메뉴 삭제
Menu, Tray , Add, 종료, Close	; 종료 메뉴 추가
Return

^+!q::	; 컨트롤 + 시프트 + 알트 + Q
Close:
ExitApp

;^+!t::	; 컨트롤 + 시프트 + 알트 + T
;CapsLock & ScrollLock::
;CapsLock & MButton::
vk19 & MButton::
WinSet, AlwaysOnTop, toggle, A	; 포커스된 창을 항상 위로
Return

;^+!Up::	; 컨트롤 + 시프트 + 알트 + ↑
;CapsLock & PGUP::
; CapsLock & WheelUp::
vk19 & WheelUp::
WinGet, transparent, Transparent, A	; 투명도 알아내기
If transparent = 
	Return
transparent := transparent + 10	; 투명도 간격 10
If transparent >= 255	; 투명도 0 ~ 255
{
	WinSet, Transparent, off, A	; 투명창 끄기. 투명도를 255로 지정해도 불투명하나 그러면 투명창으로 인식하기 때문에 성능이 하락함.
	Return
}
WinSet, Transparent, %transparent%, A	; 포커스된 창을 투명하게
Return




;^+!Down::	; 컨트롤 + 시프트 + 알트 + ↓
;CapsLock & PGDN::
; CapsLock & WheelDown::
vk19 & WheelDown::
WinGet, transparent, Transparent, A
If transparent = 
	transparent := 255
transparent := transparent - 10
If transparent <= 0
	Return
WinSet, Transparent, %transparent%, A
Return




^+!m::	; 컨트롤 + 시프트 + 알트 + M
WinSet, Style, ^0x00020000, A	; 포커스된 창의 최소화 버튼 제거
Return

^+!s::	; 컨트롤 + 시프트 + 알트 + S
WinSet, Style, ^0x00040000, A	; 포커스된 창의 굵은 테두리 제거. 즉, 창 크기 변경 불가
Return