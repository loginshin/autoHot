
#singleinstance force
#persistent

  OnExit, lblShowDefaultCursor     ; ��ũ��Ʈ�� ����� ���콺Ŀ���� ó�������� ����.
  setTimer, tmrHanModeCheck, 200
return


;지정된 간격으로 한영 모드를 확인하고 커서를 변경하는 함수
tmrHanModeCheck:
  changeHanEngCursors( imeCheckWintitle("A") )
return
lblShowDefaultCursor:
 changeHanEngCursors()
ExitApp





;한영 모드에 따라 커서 스타일을 변경하는 함수입니다.
changeHanEngCursors( bHanCursorMode="" )   ; ����μ���->    1:�ѱ�Cursor,  0:����Cursor , ��Ÿ:�ʱ�Cursor
{
   local  h_cursor
   static $, prev$
        , c0,c1,c2  
        , e1,e2     
        , h1,h2     
        , i1,i2     
    if( $="")       
    {
        system_cursors = 32512,32513    ;,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650
        StringSplit c, system_cursors, `,
        Loop %c0%
        {
            h_cursor:= DllCall( "LoadCursor", "uint",0, "uint",c%A_Index% )
            i%A_Index% := DllCall( "CopyImage",  "uint",h_cursor, "uint",2, "int",0, "int",0, "uint",0 )
            if(c%A_index%=32512 ){   ; IDC_ARROW = 32512
                   h%A_index%:=DllCall("LoadCursorFromFile","Str", A_ScriptDir . "\Cursor\myHan_Arrow.cur")
                   e%A_index%:=DllCall("LoadCursorFromFile","Str", A_ScriptDir . "\Cursor\myEng_Arrow.cur")
                   z%A_index%:=DllCall("LoadCursorFromFile","Str", A_ScriptDir . "\Cursor\myEng_ArrowB.cur")
            }else if(c%A_index%=32513 ){   ; IDC_IBEAM = 32513
                   h%A_index%:=DllCall("LoadCursorFromFile","Str", A_ScriptDir . "\Cursor\myHan_Ibeam.cur")
                   e%A_index%:=DllCall("LoadCursorFromFile","Str", A_ScriptDir . "\Cursor\myEng_Ibeam.cur")
                   z%A_index%:=DllCall("LoadCursorFromFile","Str", A_ScriptDir . "\Cursor\myEng_IbeamB.cur")
            }
        }
    }

   if(bHanCursorMode=True)
      $:="h"
   else if(bHanCursorMode=False)
   {
      if (GetKeyState("CapsLock" , "T"))
         $:="z"
      else    
         $:="e"
   }          
   else
      $:="i"


   if($=prev$)          ;�ѱۻ��°� �������¿� ���ٸ� �Լ��� ��������.
         return
   else
         prev$:=$

   Loop %c0%
   {
           if(c%A_index%=32512 ){          ; IDC_ARROW = 32512
                   h_cursor:=%$%1
            }else if(c%A_index%=32513 ){   ; IDC_IBEAM = 32513
                   h_cursor:=%$%2
            }else{
                msgbox ,16 ,Error,  c%A_index%=undefined!
                ExitApp
            }
            h_cursor := DllCall( "CopyImage", "uint",h_cursor, "uint",2, "int",0, "int",0, "uint",0 )
            DllCall( "SetSystemCursor", "uint",h_cursor, "uint",c%A_Index% )
   }
}




;--------(IMECHECK.AHK)------->
hangulMode(){
    if(imeCheckWintitle() = "0")
    {
        Send, {vk15sc138}
        sleep, 500
    }
}


englishMode(){
    if(imeCheckWintitle() <>"0")
    {
        Send, {vk15sc138}
     }
}

imeCheckWinTitle(WinTitle="")
{
    if(WinTitle="")
           WinTitle:="A"
    WinGet,hWnd,ID,%WinTitle%
   return imeCheckHWND(hWnd)

}

imeCheckHWND( hWnd )
{
    Return Send_ImeControl(ImmGetDefaultIMEWnd(hWnd),0x005,"")
}


ImmGetDefaultIMEWnd(hWnd)
{
    return DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hWnd, Uint)
}
Send_ImeControl(DefaultIMEWnd, wParam, lParam)
{
    detectSave := A_DetectHiddenWindows
    DetectHiddenWindows,ON
    SendMessage 0x283, wParam,lParam,,ahk_id %DefaultIMEWnd%
    if (detectSave <> A_DetectHiddenWindows)
        DetectHiddenWindows,%detectSave%
    return ErrorLevel
}

