;==================================================================================
; 파일명 : Capture.ahk
; 설명 : 화면 특정 영역 캡쳐 라이브러리
; 버전: v2.0
; 라이센스: CC BY-SA 3.0 (https://creativecommons.org/licenses/by-sa/3.0/deed.ko)
; 설치방법: #Include Capture.ahk
; 제작자: https://catlab.tistory.com/ (fty816@gmail.com)
;==================================================================================

#Include Gdip_All.ahk

class Capture
{
	__New(PenColor:="FFFF0000", PenWidth:=1, BackgroundColor:="56000000")
	{
		Gui, RECGUI: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs +hwndREC_HWND
		Gui, RECGUI: Show, NA
		this.REC_HWND := REC_HWND
		
		SetBatchLines -1
		this.Width := A_ScreenWidth, this.Height := A_ScreenHeight
		this.pToken := Gdip_Startup()
		
		this.hbm := CreateDIBSection(this.Width, this.Height)
		this.hdc := CreateCompatibleDC()
		this.obm := SelectObject(this.hdc, this.hbm)
		
		this.G := Gdip_GraphicsFromHDC(this.hdc)
		Gdip_SetSmoothingMode(this.G, 1)
		
		this.pPen := Gdip_CreatePen("0x" PenColor, PenWidth)
		this.pBrush := Gdip_BrushCreateSolid("0x" BackgroundColor)
	}
	
	Capture(SaveDir:= "Capture.png")
	{
		CoordMode, Mouse, Screen
		
		Width := this.Width, Height := this.Height
		pPen := this.pPen, pBrush := this.pBrush
		REC_HWND := this.REC_HWND
		G := this.G, hdc := this.hdc
		
		ScreenBitmap := Gdip_BitmapFromScreen()
		Gdip_DrawImage(G, ScreenBitmap)
		
		Gdip_FillRectangle(G, pBrush, 0, 0, Width, Height)
		UpdateLayeredWindow(REC_HWND, hdc, 0, 0, Width, Height)
		
		this.ReplaceSystemCursors("IDC_CROSS")
		
		KeyWait, LButton, D
		MouseGetPos, x1, y1
		
		while getKeyState("LButton", "P")
		{
			MouseGetPos, x2, y2
			
			Gdip_GraphicsClear(G)
			Gdip_DrawImage(G, ScreenBitmap)
			Gdip_FillRectangle(G, pBrush, 0, 0, Width, min(y1, y2))
			Gdip_FillRectangle(G, pBrush, 0, max(y1, y2), Width, Height - y2)
			Gdip_FillRectangle(G, pBrush, 0, min(y1, y2), min(x1, x2), abs(y2-y1))
			Gdip_FillRectangle(G, pBrush, max(x1, x2), min(y1, y2), Width - x2, abs(y2-y1))
			
			Gdip_DrawRectangle(G, pPen, min(x1,x2), min(y1,y2), abs(x2-x1), abs(y2-y1))
			
			UpdateLayeredWindow(REC_HWND, hdc, 0, 0, Width, Height)
			
			if getKeyState("RButton", "D")
			{
				Gdip_GraphicsClear(G)
				Gdip_DisposeImage(ScreenBitmap)
				UpdateLayeredWindow(REC_HWND, hdc, 0, 0, Width, Height)
				this.ReplaceSystemCursors()
				
				return 0
			}
		}
		
		Gdip_GraphicsClear(G)
		UpdateLayeredWindow(REC_HWND, hdc, 0, 0, Width, Height)
		this.ReplaceSystemCursors()
		
		Result_X1 := min(x1,x2), Result_Y1 := min(y1,y2)
		Result_X2 := Result_X1 + abs(x2-x1), Result_Y2 := Result_Y1 + abs(y2-y1)
		Result_W1 := abs(x2-x1), Result_H1 := abs(y2-y1)
		
		;MsgBox,% "결과 : `nX1 : " Result_X1 " Y1 : " Result_Y1 "`nX2 : " Result_X2 " Y2 : " Result_Y2
		
		; 저장하면서 상단의 ScreenBitmap 객체 해제
		this.SaveImage(ScreenBitmap, Result_X1, Result_Y1, Result_W1, Result_H1, SaveDir)
		
		return 1
	}
	
	;[참조] : https://www.autohotkey.com/boards/viewtopic.php?t=90286
	ReplaceSystemCursors(IDC = "")
	{
	    static IMAGE_CURSOR := 2, SPI_SETCURSORS := 0x57
			, SysCursors := { IDC_APPSTARTING: 32650
							, IDC_ARROW      : 32512
							, IDC_CROSS      : 32515
							, IDC_HAND       : 32649
							, IDC_HELP       : 32651
							, IDC_IBEAM      : 32513
							, IDC_NO         : 32648
							, IDC_SIZEALL    : 32646
							, IDC_SIZENESW   : 32643
							, IDC_SIZENWSE   : 32642
							, IDC_SIZEWE     : 32644
							, IDC_SIZENS     : 32645 
							, IDC_UPARROW    : 32516
							, IDC_WAIT       : 32514 }
		if !IDC
			DllCall("SystemParametersInfo", UInt, SPI_SETCURSORS, UInt, 0, UInt, 0, UInt, 0)
		else  
	    {
			hCursor := DllCall("LoadCursor", Ptr, 0, UInt, SysCursors[IDC], Ptr)
			for k, v in SysCursors  
			{
				hCopy := DllCall("CopyImage", Ptr, hCursor, UInt, IMAGE_CURSOR, Int, 0, Int, 0, UInt, 0, Ptr)
				DllCall("SetSystemCursor", Ptr, hCopy, UInt, v)
			}
	    }
	}
	
	SaveImage(pBitmap, X, Y, W, H, FileDir)
	{
		pBitmap_Crop := Gdip_CloneBitmapArea(pBitmap, X, Y, W, H)
		Gdip_SaveBitmapToFile(pBitmap_Crop, FileDir)
		Gdip_DisposeImage(pBitmap), Gdip_DisposeImage(pBitmap_Crop)
	}
	
	__Delete()
	{
		Gdip_DeleteBrush(this.pBrush)
		Gdip_DeletePen(this.Pen)
		Gdip_DeleteGraphics(this.G)
		
		SelectObject(this.hdc, this.obm)
		DeleteObject(this.hbm)
		DeleteDC(this.hdc)
		
		Gdip_Shutdown(this.pToken)
		Gui, RECGUI: Destroy
	}
}