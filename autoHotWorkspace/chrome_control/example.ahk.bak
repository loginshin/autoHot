#Include Chrome.ahk


/*
	원작자 Github : 
		https://github.com/G33kDude/Chrome.ahk
		
	
	**** 장점:
	
    No external dependencies such as Selenium are required
    Chrome can be automated even when running in headless mode
        Launching in headless mode is not currently supported by this library
    Chrome consistently benchmarks better than Internet Explorer
    Chrome offers extensions which provide unique opportunities for interaction
        Automate your Chromecast
        Connect to remote servers with FoxyProxy and update web based configs
        Manage your password vault with LastPass
    Many features are available that would be difficult to replicate in Internet Explorer
        Page.printToPDF
        Page.captureScreenshot
        Geolocation spoofing
	
	번역:
	셀레늄같은 외부 의존요소가 없음(역자: 그치만 크롬은 있어야함)
	크롬을 헤드레스 모드(숨김모드)에서도 자동화시킬 수 있음
		헤드레스모드에서 실행시키는건 아직 이 라이브러리에선 지원안됨
	지속성부분에서 크롬이 IE보다는 좋음
	크롬은 상호작용에 있어서 고유한 부가적인 익스텐션들을 지원함.
		Chromecast 자동화
		FoxyProxy로 원격 서버에 접속하고 웹에 기초한 설정들을 업데이트 할 수 있음
		패스워드 관리가능
	IE에서는 구현하기 어려운 많은 기능들이 사용가능함
		Page.PrintToPDF 			: 페이지를 PDF로
		Page.captureScreenshot 		: 페이지 스크린샷
        Geolocation spoofing 		: 지리정보 캐내오기
	

	
	**** 한계점 :
    Chrome must be started in debug mode
        If chrome is already running out of debug mode, it must either be closed and reopened or launched again under a new profile that isn't already running
        You cannot attach to an existing non-debug session
    Less flexible than Internet Explorer's COM interface
        Cannot pass function references for callbacks
	
	번역:
	크롬이 디버그모드로 실행돼야함.
		만약 크롬이 이미 디버그 모드로 실행중이면, 끄거나 실행중이지 않은 새로운 프로필로 새로 만들어 열어야함
		디버그모드가 아닌 세션을 이걸로 작업시킬 수는 없음
	
	IE의 COM 인터페이스보다는 조금 덜 유연한 부분이 있음
		함수참조에 콜백시킬 수 없음
		

*/

; 그 밖에 참조 사이트(명령어 많음)
; https://chromedevtools.github.io/devtools-protocol/tot/Browser/


; Create an instance of the Chrome class using
; the folder ChromeProfile to store the user profile
FileCreateDir, ChromeProfile
ChromeInst := new Chrome("ChromeProfile")

; Connect to the newly opened tab and navigate to another website
; Note: If your first action is to navigate away, it may be just as
; effective to provide the target URL when instantiating the Chrome class
PageInst := ChromeInst.GetPage()

; 페이지 이동(Page Navigate)
PageInst.Call("Page.navigate", {"url": "https://autohotkey.com/"})


; 페이지 로딩대기
PageInst.WaitForLoad()


; 자바스크립트 실행(Execute some JavaScript)
PageInst.Evaluate("alert('Hello World!');")


; 컴포넌트 컨트롤(값 반환. 하나일 경우)
; 콘솔에 쳤을 때의 컴포넌트 정보를 오브젝트 형식으로 반환
JS_result := PageInst.Evaluate("MainTitle.innerText") ; MainTitle는 id 값임
msgbox,% "컴포넌트 컨트롤(값 반환. 하나일 경우)\n" . Chrome.Jxon_Dump(JS_result)


; 컴포넌트 컨트롤(값 반환. 여러개일 경우)
JS_result := PageInst.Evaluate("document.getElementsByClassName('mbr-buttons__link')")
msgbox,% "컴포넌트 컨트롤(값 반환. 여러개일 경우)\n" . Chrome.Jxon_Dump(JS_result)


; 컴포넌트 컨트롤(텍스트 변경)
; 다른 명령어가 있는것 같으나, 자바스크립트를 통해 해도 상관없는듯.
PageInst.Evaluate("MainTitle.innerText = 'Nadures AutoHotkey, Python, Django Blog';")


; 쿠키 얻기(Get Cookie)
; 오브젝트 반환이지만, Json string으로 일단 내용을 출력시킴.
cookie := PageInst.Call("Storage.getCookies", {})
msgbox,% Chrome.Jxon_Dump(cookie)

; DOM 오브젝트 반환(Get DOM)
; 자바스크립트를 실행시키면 되서 딱히 필요는 없을것 같긴 함.
dom := PageInst.Call("DOM.getDocument", {})
msgbox,% Chrome.Jxon_Dump(dom)

; Close the browser (note: this closes *all* pages/tabs)
PageInst.Call("Browser.close")

PageInst.Disconnect()

ExitApp
return

