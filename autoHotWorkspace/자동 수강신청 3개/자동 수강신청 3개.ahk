
; 사용자에게 아이디 비번 얻어서 수강신청 페이지에서
;수강신청 페이지에서 중요도 순서대로 맞춰서 tab버튼으로 이동하면 2.8초마다 엔터

start :=0

F1::
start = 1
;위로 스크롤 버튼 없으면 바로 시작
    ; sendinput {lshift down}
    ; sleep, 1000
    ; sendinput {Tab}
    ; sleep, 1000
    ; sendinput {lshift Up}
loop{
    if(start =1){
        ;첫번째 (밑에부터) 수강신청
        sendinput {lshift down}
        sleep, 100
        sendinput {Tab}
        sleep, 100
        sendinput {Tab}
        sleep, 100
        sendinput {Tab}
        sleep, 100
        sendinput {lshift Up}}
        Sleep, 1000
        Send {Enter}
        Sleep, 1000
        Send {Enter}
        sleep, 1000

        ; 2번째 엔터
        sendinput {lshift down}
        sleep, 100
        sendinput {Tab}
        sleep, 100
        sendinput {Tab}
        sleep, 100
        sendinput {lshift Up}
        Sleep, 1000
        Send {Enter}
        Sleep, 1000
        Send {Enter}
        sleep, 1000

        ; 3번째 엔터
        sendinput {lshift down}
        sleep, 100
        sendinput {Tab}
        sleep, 100
        sendinput {Tab}
        sleep, 100
        sendinput {lshift Up}
        Sleep, 1000
        Send {Enter}
        Sleep, 1000
        Send {Enter}
        sleep, 1000

        Send {F5}
        Sleep, 1000
        Send {Enter}
        sleep, 3000
    }ELSE IF(START =0)
    Break
}Return

F2::
start =0
return