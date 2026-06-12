
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
buttonClick(4)
Sleep, 100
Send {Enter}
sleep, 2830 
buttonClick(6) 
Sleep, 100
Send {Enter}
sleep, 2800 
buttonClick(3)
Sleep, 100
Send {Enter}
sleep, 2833 
buttonClick(5)
Sleep, 100
Send {Enter}
sleep, 2829 
buttonClick(8) 
Sleep, 100
Send {Enter}
sleep, 2800 
buttonClick(7) 
Sleep, 100
Send {Enter}
return


^CapsLock::
ExitApp
return