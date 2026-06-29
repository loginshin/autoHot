#Requires AutoHotkey v2.0

; ════════════════════════════════════════════════════════════
;  자동화 도구
;  ------------------------------------------------------------
;  기능 요약
;    1. 선택 쇼핑몰 검색
;       - 쇼핑몰 선택과 검색어 입력
;       - 선택한 쇼핑몰 검색 페이지를 Chrome으로 실행
;
;    2. 엑셀찾기
;       - 엑셀 검색어 입력
;       - [엑셀찾기] 버튼 클릭
;       - 마지막으로 사용했던 Excel 창에서 ActiveSheet 검색
;
;  주의
;    - 엑셀찾기는 여러 Excel 창 중 마지막으로 활성화했던 Excel 창을 기준으로 동작한다.
;    - 검색 전 원하는 Excel 창을 한 번 클릭해두면 가장 안정적이다.
; ════════════════════════════════════════════════════════════


; ════════════════════════════════════════════════════════════
;  SECTION 1 — 전역 상태 및 설정
; ════════════════════════════════════════════════════════════

global historyList := []
global MAX_HISTORY := 20
global statusColor := Map("ok", "0x2ECC71", "fail", "0xE74C3C", "idle", "0x95A5A6")
global isPinned    := true
global currentMode := 1
global marketOptions := ["네이버", "11번가", "G마켓", "옥션", "쿠팡"]
global selectedMarket := marketOptions[1]

; 마지막으로 사용자가 활성화했던 Excel 창의 HWND
; - 여러 Excel 창을 켜둔 경우, 가장 최근에 사용한 Excel 창을 기억하기 위해 사용
; - [엑셀찾기] 버튼 클릭 시 이 창을 다시 활성화한 뒤 검색 수행
global lastExcelHwnd := 0

; 마지막으로 사용자가 활성화했던 Chrome 창의 HWND
; - [크롤링] 버튼 클릭 시 이 창의 페이지 텍스트를 복사해 택배사/송장번호 추출
global lastChromeHwnd := 0


; ════════════════════════════════════════════════════════════
;  SECTION 2 — GUI 초기화
; ════════════════════════════════════════════════════════════

myGui := Gui("+AlwaysOnTop -MaximizeBox +MinimizeBox", "자동화 도구")
myGui.BackColor := "0x1E1E2E"
myGui.SetFont("s9 cWhite", "Segoe UI")


; ───────────────────────────────────────────────────────────
;  2-1. 헤더
; ───────────────────────────────────────────────────────────

myGui.AddText("x12 y14 cWhite", "⌨  자동화 도구")

global ddlMarket := myGui.AddDropDownList("x106 y8 w76 Background0x313244 cWhite Choose1", marketOptions)
ddlMarket.SetFont("s8 cWhite")
ddlMarket.OnEvent("Change", ChangeMarket)

global btnHelp := myGui.AddButton("x188 y8 w40 h24 Background0x6C63FF", "도움")
btnHelp.SetFont("s8 cWhite")
btnHelp.OnEvent("Click", ShowHelp)

global btnPin := myGui.AddButton("x234 y8 w38 h24 Background0x45475A", "ON")
btnPin.SetFont("s8 cWhite")
btnPin.OnEvent("Click", TogglePin)


; ════════════════════════════════════════════════════════════
;  SECTION 2-3 — Mode 1 컨트롤
;  ------------------------------------------------------------
;  Mode 1 안에 들어가는 기능
;    1. 선택 쇼핑몰 검색
;    2. 마지막으로 사용한 Excel 창에서 값 찾기
; ════════════════════════════════════════════════════════════


; ───────────────────────────────────────────────────────────
;  Mode 1-A. 선택 쇼핑몰 검색
; ───────────────────────────────────────────────────────────

global m1_lblNaverTitle := myGui.AddText("x12 y48 w260 cWhite", "쇼핑몰 검색")
m1_lblNaverTitle.SetFont("s9 cWhite")

global m1_lblNaverKeyword := myGui.AddText("x12 y74 w260 cGray", "검색어")
global m1_editNaverKeyword := myGui.AddEdit("x12 y94 w260 h24 Background0x313244 cWhite", "")

global m1_btnNaver := myGui.AddButton("x12 y128 w260 h30 Default Background0x03C75A", "선택 쇼핑몰 검색")
m1_btnNaver.SetFont("s10 cWhite")
m1_btnNaver.OnEvent("Click", OpenMarketSearch)


; 구분선
global m1_divider := myGui.AddText("x12 y174 w260 h1 Background0x313244", "")


; ───────────────────────────────────────────────────────────
;  Mode 1-B. 엑셀찾기
;  ------------------------------------------------------------
;  기존 F8 방식 제거
;  입력칸에 검색어를 넣고 [엑셀찾기] 버튼으로 검색
; ───────────────────────────────────────────────────────────

global m1_lblExcelTitle := myGui.AddText("x12 y190 w260 cWhite", "엑셀찾기")
m1_lblExcelTitle.SetFont("s9 cWhite")

global m1_lblExcelKeyword := myGui.AddText("x12 y216 w150 cGray", "엑셀에서 찾을 값")
global m1_btnAddressCrawl := myGui.AddButton("x176 y212 w96 h22 Background0x45475A", "주소 크롤링")
m1_btnAddressCrawl.SetFont("s8 cWhite")
m1_btnAddressCrawl.OnEvent("Click", CrawlAddressFromLastChrome)
global m1_editExcelKeyword := myGui.AddEdit("x12 y236 w260 h24 Background0x313244 cWhite", "")

global m1_lblCourier := myGui.AddText("x12 y266 w260 cGray", "택배사 B열")
global m1_editCourier := myGui.AddEdit("x12 y286 w210 h24 Background0x313244 cWhite", "")
global m1_btnCopyCourier := myGui.AddButton("x228 y286 w44 h24 Background0x45475A", "복사")
m1_btnCopyCourier.SetFont("s8 cWhite")
m1_btnCopyCourier.OnEvent("Click", CopyCourier)

global m1_lblInvoice := myGui.AddText("x12 y316 w260 cGray", "송장번호 C열")
global m1_editInvoice := myGui.AddEdit("x12 y336 w210 h24 Background0x313244 cWhite", "")
global m1_btnCopyInvoice := myGui.AddButton("x228 y336 w44 h24 Background0x45475A", "복사")
m1_btnCopyInvoice.SetFont("s8 cWhite")
m1_btnCopyInvoice.OnEvent("Click", CopyInvoice)

global m1_btnCrawl := myGui.AddButton("x12 y372 w92 h30 Background0x45475A", "송장 크롤링")
m1_btnCrawl.SetFont("s9 cWhite")
m1_btnCrawl.OnEvent("Click", CrawlFromLastChrome)

global m1_btnFindExcel := myGui.AddButton("x110 y372 w82 h30 Background0x6C63FF", "엑셀찾기")
m1_btnFindExcel.SetFont("s10 cWhite")
m1_btnFindExcel.OnEvent("Click", FindInLastExcel)

global m1_btnResetInputs := myGui.AddButton("x198 y372 w74 h30 Background0x45475A", "초기화")
m1_btnResetInputs.SetFont("s9 cWhite")
m1_btnResetInputs.OnEvent("Click", ResetInputs)

global m1_lblExcelInfo := myGui.AddText("x12 y414 w260 h18 cGray", "중복 발견 시 입력하지 않습니다.")
m1_lblExcelInfo.SetFont("s8")

; ───────────────────────────────────────────────────────────
;  Mode 1-C. 상태 / 히스토리
; ───────────────────────────────────────────────────────────

global m1_lblStatus := myGui.AddText("x12 y438 w260 h40", "대기 중")
m1_lblStatus.SetFont("s9 c" statusColor["idle"])

global m1_lblHistTitle := myGui.AddText("x12 y492 w260 cGray", "검색 히스토리  (더블클릭 → 복사)")
global m1_lbHistory := myGui.AddListBox("x12 y510 w260 h64 Background0x313244 cWhite -Border", [])
m1_lbHistory.OnEvent("DoubleClick", CopyHistory)

global m1_btnClear := myGui.AddButton("x12 y584 w260 h28 Background0x45475A", "히스토리 지우기")
m1_btnClear.SetFont("s9 cWhite")
m1_btnClear.OnEvent("Click", ClearHistory)

; ───────────────────────────────────────────────────────────
;  2-6. 창 표시 및 종료 이벤트
; ───────────────────────────────────────────────────────────

myGui.OnEvent("Close", (*) => ExitApp())

xPos := A_ScreenWidth - 310
myGui.Show("w284 h632 x" xPos " y40")

; Excel 창 추적 타이머
; - 0.3초마다 현재 활성 창이 Excel인지 확인
; - Excel 창이면 lastExcelHwnd에 저장
SetTimer(TrackLastExcelWindow, 300)
SetTimer(TrackLastChromeWindow, 300)
OnMessage(0x0100, ExcelEditEnter)

; 시작 시 사용법 자동 표시
ShowHelp()


; ════════════════════════════════════════════════════════════
;  SECTION 3 — GUI 이벤트 핸들러
; ════════════════════════════════════════════════════════════


; ───────────────────────────────────────────────────────────
;  TogglePin
;  ------------------------------------------------------------
;  GUI 창 상단 고정 ON/OFF
; ───────────────────────────────────────────────────────────
TogglePin(*) {
    global isPinned, myGui, btnPin

    isPinned := !isPinned

    if isPinned {
        myGui.Opt("+AlwaysOnTop")
        btnPin.Text := "ON"
    } else {
        myGui.Opt("-AlwaysOnTop")
        btnPin.Text := "OFF"
    }
}


; ───────────────────────────────────────────────────────────
;  ChangeMarket
;  ------------------------------------------------------------
;  이후 쇼핑몰별 검색/크롤링 구현을 위한 선택값만 저장
; ───────────────────────────────────────────────────────────
ChangeMarket(ctrl, *) {
    global selectedMarket, marketOptions

    selectedMarket := marketOptions[ctrl.Value]
    SetStatus("선택 쇼핑몰: " selectedMarket, "idle")
}


; ───────────────────────────────────────────────────────────
;  ExcelEditEnter
;  ------------------------------------------------------------
;  엑셀 관련 입력칸에서 Enter를 누르면 네이버 기본 버튼 대신 엑셀찾기 실행
; ───────────────────────────────────────────────────────────
ExcelEditEnter(wParam, lParam, msg, hwnd) {
    global m1_editExcelKeyword, m1_editCourier, m1_editInvoice

    if (wParam != 13) {
        return
    }

    if (
        hwnd = m1_editExcelKeyword.Hwnd
        || hwnd = m1_editCourier.Hwnd
        || hwnd = m1_editInvoice.Hwnd
    ) {
        FindInLastExcel()
        return 0
    }
}


; ───────────────────────────────────────────────────────────
;  ResetInputs
;  ------------------------------------------------------------
;  네이버 검색어와 엑셀 입력값을 모두 비움
; ───────────────────────────────────────────────────────────
ResetInputs(*) {
    global m1_editNaverKeyword, m1_editExcelKeyword, m1_editCourier, m1_editInvoice

    m1_editNaverKeyword.Value := ""
    m1_editExcelKeyword.Value := ""
    m1_editCourier.Value := ""
    m1_editInvoice.Value := ""

    SetStatus("입력값 초기화 완료", "idle")
}


CopyCourier(*) {
    global m1_editCourier

    CopyInputValue(m1_editCourier, "택배사")
}


CopyInvoice(*) {
    global m1_editInvoice

    CopyInputValue(m1_editInvoice, "송장번호")
}


CopyInputValue(editCtrl, label) {
    value := Trim(editCtrl.Value)

    if (value = "") {
        SetStatus(label " 값이 없습니다", "fail")
        return
    }

    A_Clipboard := value
    SetStatus(label " 복사 완료", "ok")
}


; ───────────────────────────────────────────────────────────
;  ShowHelp
;  ------------------------------------------------------------
;  사용법 팝업
; ───────────────────────────────────────────────────────────
ShowHelp(*) {
    global myGui

    helpGui := Gui("+Owner" myGui.Hwnd " +AlwaysOnTop -MaximizeBox -MinimizeBox", "사용법")
    helpGui.BackColor := "0x1E1E2E"
    helpGui.SetFont("s9 cWhite", "Segoe UI")

    helpGui.AddText("x16 y16 w280 cWhite", "📖  사용법")
    helpGui.SetFont("s8 cGray")

    ; 쇼핑몰
    helpGui.AddText("x16 y44 w52 c0x03C75A", "쇼핑몰")
    helpGui.SetFont("s8 cWhite")
    helpGui.AddText("x70 y44 w226", "상단에서 쇼핑몰을 선택하고")
    helpGui.AddText("x70 y60 w226", "검색어 입력 후 검색 버튼을 누릅니다.")
    helpGui.AddText("x70 y76 w226", "네이버는 기존 구매내역 검색을 엽니다.")
    helpGui.AddText("x70 y92 w226", "[주소 크롤링]은 엑셀 검색어를 채우고")
    helpGui.AddText("x70 y108 w226", "[송장 크롤링]은 택배사/송장번호를 채웁니다.")

    ; 엑셀
    helpGui.SetFont("s8 c0x6C63FF")
    helpGui.AddText("x16 y140 w52", "엑셀")
    helpGui.SetFont("s8 cWhite")
    helpGui.AddText("x70 y140 w226", "엑셀에서 찾을 값을 입력한 뒤")
    helpGui.AddText("x70 y156 w226", "[엑셀찾기] 버튼을 누릅니다.")
    helpGui.AddText("x70 y172 w226", "여러 Excel 창을 켜둔 경우")
    helpGui.AddText("x70 y188 w226", "마지막으로 클릭했던 창에서 찾습니다.")
    helpGui.AddText("x70 y204 w226", "원하는 창을 먼저 클릭해두면 안정적입니다.")
    helpGui.AddText("x70 y220 w226", "같은 값이 여러 개면 입력을 중단합니다.")

    ; 핀
    helpGui.SetFont("s8 c0x6C63FF")
    helpGui.AddText("x16 y284 w52", "📌 핀")
    helpGui.SetFont("s8 cWhite")
    helpGui.AddText("x70 y284 w226", "창을 항상 위에 고정하거나 해제합니다.")

    ; 히스토리
    helpGui.SetFont("s8 c0x6C63FF")
    helpGui.AddText("x16 y308 w52", "기록")
    helpGui.SetFont("s8 cWhite")
    helpGui.AddText("x70 y308 w226", "더블클릭하면 검색어가 복사됩니다.")

    helpGui.AddText("x16 y336 w280 h1 Background0x313244", "")

    btnClose := helpGui.AddButton("x90 y348 w120 h28 Background0x45475A", "닫기")
    btnClose.SetFont("s9 cWhite")
    btnClose.OnEvent("Click", (*) => helpGui.Destroy())

    helpGui.Show("w312 h392")
}


; ───────────────────────────────────────────────────────────
;  CopyHistory
;  ------------------------------------------------------------
;  히스토리 더블클릭 시 검색어 복사
; ───────────────────────────────────────────────────────────
CopyHistory(ctrl, *) {
    global historyList

    idx := ctrl.Value

    if (idx = 0)
        return

    raw := historyList[idx]
    pure := SubStr(raw, 3)

    A_Clipboard := pure
    SetStatus("복사됨: " pure, "ok")
}


; ───────────────────────────────────────────────────────────
;  ClearHistory
;  ------------------------------------------------------------
;  히스토리 초기화
; ───────────────────────────────────────────────────────────
ClearHistory(*) {
    global historyList, m1_lbHistory

    historyList := []
    m1_lbHistory.Delete()

    SetStatus("히스토리 삭제됨", "idle")
}


; ════════════════════════════════════════════════════════════
;  SECTION 4 — 공통 유틸리티
; ════════════════════════════════════════════════════════════


; ───────────────────────────────────────────────────────────
;  SetStatus
;  ------------------------------------------------------------
;  상태 라벨 텍스트와 색상 변경
; ───────────────────────────────────────────────────────────
SetStatus(msg, state) {
    global m1_lblStatus, statusColor

    m1_lblStatus.Text := msg
    m1_lblStatus.SetFont("s9 c" statusColor[state])
}


; ───────────────────────────────────────────────────────────
;  AddHistory
;  ------------------------------------------------------------
;  검색 히스토리 추가
; ───────────────────────────────────────────────────────────
AddHistory(keyword, found) {
    global historyList, MAX_HISTORY, m1_lbHistory

    prefix := found ? "✓ " : "✗ "
    entry  := prefix keyword

    for i, v in historyList {
        if (v = entry) {
            historyList.RemoveAt(i)
            break
        }
    }

    historyList.InsertAt(1, entry)

    if (historyList.Length > MAX_HISTORY)
        historyList.Pop()

    m1_lbHistory.Delete()

    for v in historyList {
        m1_lbHistory.Add([v])
    }
}


; ════════════════════════════════════════════════════════════
;  SECTION 5 — 쇼핑몰 검색
; ════════════════════════════════════════════════════════════


; ───────────────────────────────────────────────────────────
;  OpenMarketSearch
;  ------------------------------------------------------------
;  선택한 쇼핑몰 기준으로 검색 URL 생성 후 실행
; ───────────────────────────────────────────────────────────
OpenMarketSearch(*) {
    global m1_editNaverKeyword, selectedMarket

    keyword := Trim(m1_editNaverKeyword.Value)

    if (keyword = "") {
        SetStatus("검색어를 입력하세요", "fail")
        return
    }

    url := CreateMarketSearchUrl(selectedMarket, keyword)

    try {
        Run("chrome.exe " Chr(34) url Chr(34))
    } catch {
        Run(url)
    }

    AddHistory(keyword, true)
    SetStatus(selectedMarket " 검색: " keyword, "ok")
}


CreateMarketSearchUrl(market, keyword) {
    encodedKeyword := UrlEncode(keyword)
    formKeyword := UrlFormEncode(keyword)

    if (market = "네이버") {
        dates := GetRecentSearchDates()

        return "https://shopping.naver.com/my/order?startDate=" dates.displayStart
            . "&endDate=" dates.displayEnd
            . "&keyword=" encodedKeyword
    }

    if (market = "11번가") {
        dates := GetRecentSearchDates()

        return "https://buy.11st.co.kr/my11st/order/OrderList.tmall?currpageNo="
            . "&pageNumber=1"
            . "&pageNumberPendingDone=1"
            . "&pageNumberPendingFail=1"
            . "&shDateFrom=" dates.compactStart
            . "&shDateTo=" dates.compactEnd
            . "&shPrdNm=" formKeyword
            . "&shOrdprdStat=%2C%2C%2C%2C"
            . "&type=orderList2nd"
            . "&ver=02"
            . "&nDate="
    }

    if (market = "G마켓") {
        dates := GetRecentSearchDates()

        return "https://my.gmarket.co.kr/ko/pc/list/all?pageNo=1"
            . "&searchRangeEnum=All"
            . "&searchStartDate=" UrlEncode(dates.utcStart)
            . "&searchEndDate=" UrlEncode(dates.utcEnd)
            . "&searchWord=" encodedKeyword
            . "&searchKindEnum=All"
    }

    if (market = "옥션") {
        return "https://escrow.auction.co.kr/Close/OrderProcessList.aspx?tabType=S&SearchStatus=10&SearchOption=0"
    }

    if (market = "쿠팡") {
        return "https://mc.coupang.com/ssr/desktop/order/list?isSearch=true&keyword=" encodedKeyword
    }

    return "https://www.google.com/search?q=" encodedKeyword
}


GetRecentSearchDates() {
    endDateRaw := A_Now
    startDateRaw := DateAdd(endDateRaw, -5, "Days")

    return {
        displayStart: FormatTime(startDateRaw, "yyyy-MM-dd"),
        displayEnd: FormatTime(endDateRaw, "yyyy-MM-dd"),
        compactStart: FormatTime(startDateRaw, "yyyyMMdd"),
        compactEnd: FormatTime(endDateRaw, "yyyyMMdd"),
        utcStart: FormatGmarketUtcDate(startDateRaw),
        utcEnd: FormatGmarketUtcDate(endDateRaw, 1)
    }
}


FormatGmarketUtcDate(dateRaw, addDays := 0) {
    localMidnight := FormatTime(dateRaw, "yyyyMMdd") "000000"
    localBoundary := addDays ? DateAdd(localMidnight, addDays, "Days") : localMidnight
    utcDateRaw := DateAdd(localBoundary, -9, "Hours")

    return FormatTime(utcDateRaw, "yyyy-MM-dd") "T" FormatTime(utcDateRaw, "HH:mm:ss") ".000Z"
}


UrlFormEncode(str) {
    return StrReplace(UrlEncode(str), "%20", "+")
}


; ───────────────────────────────────────────────────────────
;  TrackLastChromeWindow
;  ------------------------------------------------------------
;  마지막으로 활성화된 Chrome 창 저장
; ───────────────────────────────────────────────────────────
TrackLastChromeWindow(*) {
    global lastChromeHwnd

    hwnd := WinActive("ahk_exe chrome.exe")

    if hwnd {
        lastChromeHwnd := hwnd
    }
}


; ───────────────────────────────────────────────────────────
;  CrawlFromLastChrome
;  ------------------------------------------------------------
;  최근 Chrome 페이지 텍스트에서 택배사/송장번호를 추출해 입력칸에 채움
; ───────────────────────────────────────────────────────────
CrawlFromLastChrome(*) {
    global m1_editCourier, m1_editInvoice

    pageText := GetLastChromePageText()

    if (Trim(pageText) = "") {
        return
    }

    courier := ExtractCourier(pageText)
    invoice := ExtractInvoice(pageText)

    if (courier = "" && invoice = "") {
        SetStatus("택배사/송장번호를 찾지 못했습니다", "fail")
        return
    }

    if (courier != "") {
        m1_editCourier.Value := courier
    }

    if (invoice != "") {
        m1_editInvoice.Value := invoice
    }

    summary := ""

    if (courier != "") {
        summary .= courier
    }

    if (invoice != "") {
        summary .= (summary = "" ? "" : " / ") invoice
    }

    SetStatus("송장 크롤링 완료: " summary, "ok")
}


; ───────────────────────────────────────────────────────────
;  CrawlAddressFromLastChrome
;  ------------------------------------------------------------
;  최근 Chrome 페이지 텍스트에서 주소 검색 키만 추출해 엑셀 검색어 입력칸에 채움
; ───────────────────────────────────────────────────────────
CrawlAddressFromLastChrome(*) {
    global m1_editExcelKeyword

    pageText := GetLastChromePageText()

    if (Trim(pageText) = "") {
        return
    }

    addressKey := ExtractAddressSearchKey(pageText)

    if (addressKey = "") {
        SetStatus("주소를 찾지 못했습니다", "fail")
        return
    }

    m1_editExcelKeyword.Value := addressKey
    SetStatus("주소 크롤링 완료: " addressKey, "ok")
}


GetLastChromePageText() {
    global lastChromeHwnd

    if (!lastChromeHwnd || !WinExist("ahk_id " lastChromeHwnd)) {
        lastChromeHwnd := WinExist("ahk_exe chrome.exe")
    }

    if (!lastChromeHwnd) {
        SetStatus("열려 있는 Chrome 창 없음", "fail")
        return ""
    }

    try {
        WinActivate("ahk_id " lastChromeHwnd)
        WinWaitActive("ahk_id " lastChromeHwnd, , 2)
        Sleep(300)
    } catch {
        SetStatus("Chrome 창 활성화 실패", "fail")
        return ""
    }

    pageText := CopyChromePageText()

    if (Trim(pageText) = "") {
        SetStatus("크롬 화면 텍스트를 가져오지 못했습니다", "fail")
        return ""
    }

    return pageText
}


CopyChromePageText() {
    savedClipboard := ""

    try {
        savedClipboard := ClipboardAll()
    }

    A_Clipboard := ""
    Send("{Esc}")
    Sleep(80)
    Send("^a")
    Sleep(120)
    Send("^c")

    if (!ClipWait(2)) {
        try {
            if IsObject(savedClipboard) {
                A_Clipboard := savedClipboard
            }
        }

        return ""
    }

    pageText := A_Clipboard

    try {
        if IsObject(savedClipboard) {
            A_Clipboard := savedClipboard
        }
    }

    return pageText
}


ExtractCourier(text) {
    couriers := [
        "CJ대한통운",
        "대한통운",
        "한진택배",
        "롯데택배",
        "우체국택배",
        "우체국",
        "로젠택배",
        "로젠",
        "경동택배",
        "대신택배",
        "일양로지스",
        "합동택배",
        "천일택배",
        "건영택배",
        "쿠팡로지스틱스",
        "DHL",
        "FedEx",
        "UPS",
        "EMS"
    ]

    for courier in couriers {
        if InStr(text, courier, false) {
            return NormalizeCourier(courier)
        }
    }

    return ""
}


NormalizeCourier(courier) {
    if (courier = "CJ대한통운" || courier = "대한통운") {
        return "CJ"
    }

    if (courier = "한진택배") {
        return "한진"
    }

    if (courier = "롯데택배") {
        return "롯데"
    }

    if (courier = "우체국택배" || courier = "우체국") {
        return "우체국"
    }

    if (courier = "로젠택배" || courier = "로젠") {
        return "로젠"
    }

    if (courier = "경동택배") {
        return "경동"
    }

    if (courier = "대신택배") {
        return "대신"
    }

    if (courier = "일양로지스") {
        return "일양"
    }

    if (courier = "합동택배") {
        return "합동"
    }

    if (courier = "천일택배") {
        return "천일"
    }

    if (courier = "건영택배") {
        return "건영"
    }

    return courier
}


ExtractInvoice(text) {
    normalized := StrReplace(text, "`r`n", "`n")
    normalized := StrReplace(normalized, "`r", "`n")
    lines := StrSplit(normalized, "`n")

    for i, line in lines {
        if RegExMatch(line, "i)(송장|운송장|등기|배송\s*조회|배송\s*추적|tracking)") {
            searchText := line

            Loop 3 {
                nextIndex := i + A_Index

                if (nextIndex <= lines.Length) {
                    searchText .= " " lines[nextIndex]
                }
            }

            invoice := ExtractInvoiceNumber(searchText)

            if (invoice != "") {
                return invoice
            }
        }
    }

    return ExtractInvoiceNumber(normalized)
}


ExtractInvoiceNumber(text) {
    pos := 1

    while (pos := RegExMatch(text, "\d[\d\s-]{7,}\d", &match, pos)) {
        raw := match[0]
        number := RegExReplace(raw, "\D")
        length := StrLen(number)

        if (length >= 9 && length <= 20 && !LooksLikeDate(number)) {
            return number
        }

        pos += StrLen(raw)
    }

    return ""
}


LooksLikeDate(number) {
    if (!RegExMatch(number, "^(20\d{2})(0[1-9]|1[0-2])([0-2]\d|3[01])$")) {
        return false
    }

    return true
}


ExtractAddressSearchKey(text) {
    address := ExtractAddressText(text)

    if (address = "") {
        address := text
    }

    address := NormalizeAddressText(address)

    if (RegExMatch(address, "([가-힣0-9]+(?:대로|로|길))\s+(\d+(?:-\d+)?)", &match)) {
        return match[1] " " match[2]
    }

    parts := StrSplit(address, " ")

    if (parts.Length >= 4) {
        return parts[3] " " parts[4]
    }

    return ""
}


ExtractAddressText(text) {
    if (RegExMatch(text, "주소</span>\s*([^<\r\n]+)", &htmlMatch)) {
        return htmlMatch[1]
    }

    normalized := StrReplace(text, "`r`n", "`n")
    normalized := StrReplace(normalized, "`r", "`n")
    lines := StrSplit(normalized, "`n")

    for i, line in lines {
        if RegExMatch(line, "(주소|배송지|도로명)") {
            candidate := RegExReplace(line, ".*?(주소|배송지|도로명)\s*", "")

            Loop 2 {
                nextIndex := i + A_Index

                if (nextIndex <= lines.Length) {
                    candidate .= " " lines[nextIndex]
                }
            }

            if RegExMatch(candidate, "[가-힣0-9]+(?:대로|로|길)\s+\d") {
                return candidate
            }
        }
    }

    return ""
}


NormalizeAddressText(address) {
    address := RegExReplace(address, "<[^>]+>", " ")
    address := RegExReplace(address, "\([^)]*\)", " ")
    address := RegExReplace(address, "\[[^\]]*\]", " ")
    address := RegExReplace(address, "\b\d{2,3}-\d{3,4}-\d{4}\b", " ")
    address := RegExReplace(address, "\b\d{5}\b", " ")
    address := RegExReplace(address, "\s+", " ")

    return Trim(address)
}

; ───────────────────────────────────────────────────────────
;  UrlEncode
;  ------------------------------------------------------------
;  검색어를 UTF-8 URL 인코딩
; ───────────────────────────────────────────────────────────
UrlEncode(str) {
    buf := Buffer(StrPut(str, "UTF-8"))
    StrPut(str, buf, "UTF-8")

    result := ""

    Loop buf.Size - 1 {
        c := NumGet(buf, A_Index - 1, "UChar")

        if (
            (c >= 0x30 && c <= 0x39)
            || (c >= 0x41 && c <= 0x5A)
            || (c >= 0x61 && c <= 0x7A)
            || c = 0x2D
            || c = 0x2E
            || c = 0x5F
            || c = 0x7E
        ) {
            result .= Chr(c)
        } else {
            result .= "%" Format("{:02X}", c)
        }
    }

    return result
}


; ════════════════════════════════════════════════════════════
;  SECTION 6 — 엑셀찾기
; ════════════════════════════════════════════════════════════


; ───────────────────────────────────────────────────────────
;  TrackLastExcelWindow
;  ------------------------------------------------------------
;  마지막으로 활성화된 Excel 창 저장
;
;  설명
;    [엑셀찾기] 버튼을 누르는 순간에는 자동화 도구 GUI가 활성화된다.
;    그래서 버튼 클릭 시점의 활성 창이 아니라,
;    사용자가 마지막으로 클릭했던 Excel 창을 미리 저장해둔다.
; ───────────────────────────────────────────────────────────
TrackLastExcelWindow(*) {
    global lastExcelHwnd

    hwnd := WinActive("ahk_class XLMAIN")

    if hwnd {
        lastExcelHwnd := hwnd
    }
}


; ───────────────────────────────────────────────────────────
;  FindInLastExcel
;  ------------------------------------------------------------
;  마지막으로 사용한 Excel 창의 현재 시트에서 값 찾기
;
;  검색 대상
;    - 마지막으로 활성화했던 Excel 창
;    - 해당 Excel 창의 ActiveSheet
;    - UsedRange
;
;  검색 방식
;    - 부분 일치
;    - 대소문자 구분 없음
;    - 검색어와 셀 값의 모든 공백을 제거한 뒤 비교
; ───────────────────────────────────────────────────────────
FindInLastExcel(*) {
    global lastExcelHwnd, m1_editExcelKeyword, m1_editCourier, m1_editInvoice

    keyword := Trim(m1_editExcelKeyword.Value)

    if (keyword = "") {
        SetStatus("엑셀 검색어를 입력하세요", "fail")
        return
    }

    ; 마지막 Excel 창이 없거나 이미 닫혔으면 현재 열려 있는 Excel 창을 찾는다.
    if (!lastExcelHwnd || !WinExist("ahk_id " lastExcelHwnd)) {
        lastExcelHwnd := WinExist("ahk_class XLMAIN")
    }

    if (!lastExcelHwnd) {
        AddHistory(keyword, false)
        SetStatus("열려 있는 엑셀 창 없음", "fail")
        return
    }

    ; 마지막으로 사용한 Excel 창 활성화
    try {
        WinActivate("ahk_id " lastExcelHwnd)
        WinWaitActive("ahk_id " lastExcelHwnd, , 2)
        Sleep(300)
    } catch {
        AddHistory(keyword, false)
        SetStatus("엑셀 창 활성화 실패", "fail")
        return
    }

    ; 특정 Excel 창 HWND 기준으로 COM 연결 시도
    ; 실패하면 일반 ComObjActive 방식으로 fallback
    try {
        xl := ExcelAppFromHwnd(lastExcelHwnd)
    } catch {
        try {
            xl := ComObjActive("Excel.Application")
        } catch {
            AddHistory(keyword, false)
            SetStatus("엑셀 COM 연결 실패", "fail")
            return
        }
    }

    ; ActiveSheet에서 값 검색
    try {
        ws := ComRetry(() => xl.ActiveSheet)
        rng := ComRetry(() => ws.UsedRange)

        matchedCells := GetAllSpaceInsensitiveMatches(rng, keyword)

        if (matchedCells.Length = 0) {
            AddHistory(keyword, false)
            SetStatus("엑셀에서 찾지 못함: " keyword, "fail")
            return
        }

        found := matchedCells[1]

        if (matchedCells.Length > 1) {
            ComRetry(() => xl.Goto(found, true))
            SelectMatchedRows(ws, matchedCells)

            AddHistory(keyword, false)
            SetStatus("찾는 대상이 여러 개입니다: " matchedCells.Length "건 - 입력 중단", "fail")
            return
        }

        ComRetry(() => xl.Goto(found, true))

        ; 찾은 셀은 상단에 보이게 유지하되, 좌우 스크롤은 A열부터 보이게 고정
        ComRetry(() => SetScrollColumn(xl, 1))

        foundRow := found.Row

        courier := Trim(m1_editCourier.Value)
        invoice := Trim(m1_editInvoice.Value)

        ; B열 = 택배사
        if (courier != "") {
            ComRetry(() => SetCellValue(ws, foundRow, 2, courier))
        }

        ; C열 = 송장번호
        if (invoice != "") {
            ComRetry(() => SetCellValue(ws, foundRow, 3, invoice))
        }

        AddHistory(keyword, true)
        foundAddress := ComRetry(() => found.Address(false, false))
        SetStatus("엑셀 찾음/입력 완료 → " foundAddress, "ok")

    } catch as e {
        AddHistory(keyword, false)
        SetStatus("엑셀 검색 오류: " e.Message, "fail")
    }
}


SetScrollColumn(xl, column) {
    xl.ActiveWindow.ScrollColumn := column
}


SetCellValue(ws, row, column, value) {
    ws.Cells(row, column).Value := value
}


NormalizeFindText(value) {
    text := "" value
    text := RegExReplace(text, "[\s　]+", "")

    return StrLower(text)
}


; ───────────────────────────────────────────────────────────
;  ComRetry
;  ------------------------------------------------------------
;  Excel이 일시적으로 바쁠 때 COM 호출이 거부되는 상황을 짧게 재시도
; ───────────────────────────────────────────────────────────
ComRetry(action, attempts := 10, delayMs := 150) {
    lastError := ""

    Loop attempts {
        try {
            return action.Call()
        } catch as e {
            lastError := e
            Sleep(delayMs)
        }
    }

    if IsObject(lastError) {
        throw lastError
    }

    throw Error("COM 호출 실패")
}


; ───────────────────────────────────────────────────────────
;  GetAllSpaceInsensitiveMatches
;  ------------------------------------------------------------
;  UsedRange 전체를 순회하며 검색어/셀 값의 공백을 모두 제거한 뒤 부분 일치 비교
; ───────────────────────────────────────────────────────────
GetAllSpaceInsensitiveMatches(rng, keyword) {
    matches := []
    normalizedKeyword := NormalizeFindText(keyword)

    if (normalizedKeyword = "") {
        return matches
    }

    rowCount := ComRetry(() => rng.Rows.Count)
    columnCount := ComRetry(() => rng.Columns.Count)

    Loop rowCount {
        rowIndex := A_Index

        Loop columnCount {
            columnIndex := A_Index
            cell := ComRetry(() => rng.Cells(rowIndex, columnIndex))
            value := ComRetry(() => cell.Value)

            if (value = "") {
                continue
            }

            normalizedValue := NormalizeFindText(value)

            if (normalizedValue != "" && InStr(normalizedValue, normalizedKeyword, false)) {
                matches.Push(cell)
            }
        }
    }

    return matches
}


; ───────────────────────────────────────────────────────────
;  GetAllFindMatches
;  ------------------------------------------------------------
;  Range.Find로 찾은 첫 셀부터 FindNext를 반복해 전체 일치 셀 수집
; ───────────────────────────────────────────────────────────
GetAllFindMatches(rng, firstFound) {
    matches := [firstFound]
    firstAddress := firstFound.Address(false, false)
    current := firstFound

    Loop {
        current := ComRetry(() => rng.FindNext(current))

        if !current {
            break
        }

        currentAddress := current.Address(false, false)

        if (currentAddress = firstAddress) {
            break
        }

        matches.Push(current)
    }

    return matches
}


; ───────────────────────────────────────────────────────────
;  SelectMatchedRows
;  ------------------------------------------------------------
;  검색어가 여러 셀에서 발견되면 입력을 막고 관련 행을 선택해 확인 가능하게 함
; ───────────────────────────────────────────────────────────
SelectMatchedRows(ws, matchedCells) {
    rowSeen := Map()
    rowAddress := ""

    for cell in matchedCells {
        row := cell.Row

        if rowSeen.Has(row) {
            continue
        }

        rowSeen[row] := true
        rowAddress .= (rowAddress = "" ? "" : ",") row ":" row
    }

    if (rowAddress != "") {
        ComRetry(() => ws.Range(rowAddress).Select())
    }
}


; ───────────────────────────────────────────────────────────
;  ExcelAppFromHwnd
;  ------------------------------------------------------------
;  특정 Excel 창 HWND에서 Excel.Application 객체 얻기
;
;  필요한 이유
;    Excel 창을 여러 개 켜둔 경우 ComObjActive("Excel.Application")만으로는
;    마지막으로 사용한 창과 정확히 연결되지 않을 수 있다.
;
;  실패 가능성
;    Excel 버전, 실행 권한, 보안 설정에 따라 실패할 수 있다.
;    실패하면 FindInLastExcel()에서 ComObjActive 방식으로 재시도한다.
; ───────────────────────────────────────────────────────────
ExcelAppFromHwnd(hwnd) {
    static OBJID_NATIVEOM := 0xFFFFFFF0
    static IID_IDispatch := 0

    if !IID_IDispatch {
        IID_IDispatch := Buffer(16)

        DllCall("ole32\CLSIDFromString"
            , "WStr", "{00020400-0000-0000-C000-000000000046}"
            , "Ptr", IID_IDispatch)
    }

    hwndExcel := 0

    for ctrlName in WinGetControls("ahk_id " hwnd) {
        if RegExMatch(ctrlName, "^EXCEL7") {
            hwndExcel := ControlGetHwnd(ctrlName, "ahk_id " hwnd)
            break
        }
    }

    if !hwndExcel {
        throw Error("EXCEL7 컨트롤을 찾을 수 없음")
    }

    pacc := 0

    hr := DllCall("oleacc\AccessibleObjectFromWindow"
        , "Ptr", hwndExcel
        , "UInt", OBJID_NATIVEOM
        , "Ptr", IID_IDispatch
        , "Ptr*", &pacc)

    if (hr != 0 || !pacc) {
        throw Error("AccessibleObjectFromWindow 실패")
    }

    windowObj := ComValue(9, pacc, 1)

    return windowObj.Application
}
