
; 자바스크립트 입력 함수
buttonClick(num){
    Send, {F6}
    Sleep, 20
    Clipboard = javascript
    ; sendinput, javascript:
    Sleep, 33
    send ^v
    Sleep, 50
    send, :
    ; sendinput, javascript:
    Sleep, 33
    Clipboard =document.querySelectorAll('.tbody_td li:nth-child(1)').forEach(li => {if (li.textContent.trim() === '%num%') {li.parentElement.querySelector('input[type="button"].btn_basic.valignM').click();}});
    Sleep, 50
    send ^v
    Sleep, 100
    sendinput {Enter}
    Sleep, 10
    ; PageInst.WaitForLoad() ;페이지 로딩 대기
    return
}




; 수강신청 매크로----------===================-------------------


; 수강신청 매크로 시작
CapsLock::
buttonClick(2)
Sleep, 100
Send {Enter}
sleep, 2830 
buttonClick(1) 
Sleep, 100
Send {Enter}
return

^CapsLock::
ExitApp
return