 .386                   
 .model flat, stdcall   
 option casemap :none   

 include windows.inc
 include user32.inc
 include kernel32.inc
 include gdi32.inc
  
 includelib user32.lib
 includelib gdi32.lib
 includelib kernel32.lib
 
.data
  szAppName 		db "PONGer",0 
  CommandLine  	dd 0
  hWnd            		dd 0
  hInstance       		dd 0
  szClassName 	db "Generic_Class",0
  compPos		dd 0
  compPos2		dd 0  
  humanPos		dd 0
  humanPos2		dd 0  
  xBallPos			dd 346
  yBallPos			dd 183
  xBallPos2		dd 0
  yBallPos2		dd 0
  xAddBallPos		dd -5
  yAddBallPos		dd 3
  wWidth			dd 0
  wHeight			dd 0
  hDoubleBuffer	dd 0
  blockHeight		dd 0
  was				dd 0
.code

  RGB MACRO r,g,b
    XOR EAX,EAX
    MOV AL,b
    SHL EAX,8
    MOV AL ,g
    SHL EAX,8
    MOV AL,r
  ENDM 

  start:
    push NULL
    call GetModuleHandle
    mov hInstance, eax
    
    push SW_SHOWDEFAULT
    push NULL
    push NULL
    push hInstance
    call WinMain
    
    push NULL
    call ExitProcess
    

     WinMain proc hInst :DWORD, hPrevInst :DWORD, CmdLine :DWORD, CmdShow :DWORD
    
      LOCAL wc :WNDCLASSEX
      LOCAL msg :MSG
      LOCAL dispX :DWORD
      LOCAL dispY :DWORD


      mov wc.cbSize, SIZEOF WNDCLASSEX
      mov wc.style, CS_HREDRAW or CS_VREDRAW
      mov wc.lpfnWndProc, OFFSET WndProc
      mov wc.cbClsExtra, NULL
      mov wc.cbWndExtra, NULL
      
      push hInst
      pop wc.hInstance
      mov wc.hbrBackground, COLOR_BACKGROUND
      mov wc.lpszMenuName, NULL
      mov wc.lpszClassName, OFFSET szClassName
      
      push IDI_APPLICATION
      push NULL
      call LoadIcon
      mov wc.hIcon, eax
   
      push IDC_ARROW
      push NULL
      call LoadCursor
      mov wc.hCursor, eax
      mov wc.hIconSm, NULL
   
      lea eax, wc
      push eax
      call RegisterClassEx
       
     push NULL
     push hInst
     push NULL
     push NULL
     push 400
     push 700
     push SM_CYSCREEN
     call GetSystemMetrics
     shr eax, 1
     sub eax, 200
     push 0;eax
     push SM_CXSCREEN
     call GetSystemMetrics    
     shr eax, 1
     sub eax, 350
     push 0;eax
     push WS_OVERLAPPEDWINDOW
     lea eax, szAppName
     push eax
     lea eax, szClassName
     push eax
     push NULL
     call CreateWindowEx
     mov hWnd, eax
     
     push hWnd
     call GetDC
     push eax
     call CreateCompatibleDC
     mov hDoubleBuffer, eax
     
     push SW_SHOWNORMAL
     push hWnd
     call ShowWindow
     
     push hWnd
     call UpdateWindow
     
     beginWhile:
     
       push NULL
       push 10
       push 1
       push hWnd
       call SetTimer
     
       push 0
       push 0
       push NULL
       lea eax, msg
       push eax
       call GetMessage
       
       cmp eax, 0
       je endWhile
       lea eax, msg
       push eax
       call TranslateMessage
       
       lea eax, msg
       push eax
       call DispatchMessage      
       jmp beginWhile
     endWhile:
     mov eax, msg.wParam
     ret
   WinMain EndP
;________________________________________    
  WndProc proc hWin :DWORD, uMsg :DWORD, wParam :DWORD, lParam :DWORD
   
    LOCAL hDC : HDC
    LOCAL bRect: RECT
    LOCAL wRect: RECT
    LOCAL wRect2: RECT
    LOCAL compRect: RECT
    LOCAL humanRect: RECT
    LOCAL ball: RECT
    LOCAL ball2: RECT   
    LOCAL ps  : PAINTSTRUCT
    LOCAL hBrush : HBRUSH
    LOCAL hBBrush : HBRUSH   
    LOCAL humanRect2: RECT  
    LOCAL compRect2: RECT     
    cmp uMsg, WM_DESTROY
    je wmDestroy
    cmp uMsg, WM_PAINT
    je wmPaint
    cmp uMsg, WM_TIMER
    je wmTimer   
    cmp uMsg, WM_KEYDOWN
    je wmKeyDown
    cmp uMsg, WM_ERASEBKGND
    je wmEraseBknd
    
    
    push lParam
    push wParam
    push uMsg
    push hWin
    call DefWindowProc
    ret
    
    wmEraseBknd:
    ret
                
    wmDestroy:
      push 1
      push NULL
      call KillTimer    
      push 0
      call PostQuitMessage
      ret
      
  wmTimer:         
    push FALSE
    push NULL
    push hWin
    call InvalidateRect   
   
   mov eax, xBallPos
   mov [xBallPos2], eax
   mov eax, yBallPos
   mov [yBallPos2], eax  
   
   cmp xBallPos, 7
    jg left
    mov eax, xAddBallPos
    imul eax, -1				;*-1				;*-1
    mov xAddBallPos, eax
  left:
    mov eax, wWidth
    sub eax, 7
    cmp xBallPos, eax
    jl right
    mov eax, yBallPos				;150
    mov ebx, humanPos			;80
    cmp humanPos, eax			;80 > 150
    jg wmDestroy
    add ebx, blockHeight			;116
    add ebx, blockHeight			;152
    cmp ebx, eax				;152 > 150
    jb wmDestroy      
    mov eax, xAddBallPos
    imul eax, -1				;*-1				;*-1
    mov xAddBallPos, eax
  right:
    cmp yBallPos, 3
    jge up
    mov eax, yAddBallPos
    imul eax, -1				;*-1			;*-1
    mov yAddBallPos, eax
  up:
    mov eax, wHeight
    sub eax, 11
    cmp yBallPos, eax
    jl down
    cdq
    mov eax, yAddBallPos
    imul eax, -1				;*-1
    mov yAddBallPos, eax
  down:
    mov eax, xAddBallPos
    add [xBallPos], eax
    mov eax, yAddBallPos
    add [yBallPos], eax
    ret

  wmKeyDown:         
    mov eax, [humanPos]
    mov [humanPos2], eax    
    mov eax, [wParam]
    cmp al, 28h
    je posunP
    cmp al, 26h
    je posunM

    posunP:  		
      mov eax, blockHeight			;36
      add eax, blockHeight			;72
      mov ebx, wHeight			;360
      sub ebx, eax				;288
      cmp [humanPos], ebx			;180 288
      jge noM					;
      add [humanPos],5			;
      xor eax, eax
      ret
    posunM:
      cmp [humanPos], 0
      jle noM
      sub [humanPos], 5
    noM:
    ret 
      
    wmPaint:
      lea eax, ps
      push eax
      push hWin
      call BeginPaint
      mov hDC, eax   
                   
      lea eax, bRect
      push eax
      push hWin
      call GetClientRect
      
;      mov bRect.top, 32
;      mov bRect.bottom,366
;      mov bRect.left,0
;      mov bRect.right, 688
      
;      RGB 0h, 0h, 0h
;      invoke SetBkColor, hDC, eax
      
      push BLACK_BRUSH
      call GetStockObject
      mov hBBrush, eax
      
      push WHITE_BRUSH
      call GetStockObject
      mov hBrush, eax 
      
    hdal:  
      cmp [was], 1
      je sec
      
      push hBBrush			;zacerni pozadi
      lea eax, bRect
      push eax
      push hDC
      call FillRect
      
      mov eax, bRect.bottom
      CDQ
      mov ebx, 10
      div ebx
      mov [blockHeight], eax
      mov eax, bRect.right      
      mov [wWidth], eax
      mov eax, bRect.bottom
      mov [wHeight], eax			;360
      cdq
      mov ebx, 2
      div ebx					;180
      sub eax, [blockHeight]			;180-36
      mov [humanPos], eax			;144
  
      
   
   sec:         
            
   mov eax, bRect.top
      mov wRect.top, eax
      add eax, 5
      mov wRect.bottom, eax
      mov eax, bRect.right
      mov wRect.right, eax
      mov eax, bRect.left
      mov wRect.left, eax    
      
      push hBrush
      lea eax, wRect
      push eax
      push hDC
      call FillRect      
      
      mov eax, bRect.bottom
      mov wRect2.bottom, eax
      sub eax, 5
      mov wRect2.top, eax
      mov eax, bRect.right
      mov wRect2.right, eax
      mov eax, bRect.left
      mov wRect2.left, 0      
      
      push hBrush
      lea eax, wRect2
      push eax
      push hDC
      call FillRect                 
;      push hBBrush			;zacerni pozadi
;      lea eax, bRect
;      push eax
;      push hDC
;      call FillRect

      mov eax, [compPos]											;smaz compRect
      mov compRect2.top, eax
      add eax, blockHeight
      add eax, blockHeight
      mov compRect2.bottom, eax      
      mov eax, bRect.left
      mov compRect2.left, eax
      add eax, 5
      mov compRect2.right, eax  
          
      push hBBrush
      lea eax, compRect2
      push eax
      push hDC
      call FillRect       


    posun:
      mov eax, bRect.bottom
      CDQ
      mov ebx, 10
      div ebx
      mov ebx, [blockHeight]		;30
      mov ecx, [yBallPos]			;160
      sub ecx, eax				;130
      cmp ebx, [yBallPos]
      jle nic
      mov ecx, 0
    nic:
      mov compRect.top, ecx		;130
      mov [compPos], ecx
      mov eax, [yBallPos]			;160     
      cmp ebx, [yBallPos]			; 30 -- 160
      jle nic2
      mov eax, ebx					
    nic2:      
      add eax, ebx   
      mov compRect.bottom, eax
      cmp eax, bRect.bottom
      jle nic3
      mov eax, bRect.bottom
      mov compRect.bottom, eax
      sub eax, ebx
      sub eax, ebx
      mov compRect.top , eax
    nic3:
      mov eax, bRect.left
      mov compRect.left, eax  
      add eax, 5
      mov compRect.right, eax
    
      push hBrush
      lea eax, compRect
      push eax
      push hDC
      call FillRect           
      
      
;      cmp was, 1
;      jnz wasn
;      mov eax, [humanRect.top]
;      mov humanRect2.top, eax
;      mov eax, [humanRect.bottom]
;      mov humanRect2.bottom, eax
;      mov eax, [humanRect.left]
;      mov humanRect2.left, eax
;      mov eax, [humanRect.right]
;      mov humanRect2.right, eax
;     
;      push hBBrush
;      lea eax, humanRect2
;      push eax
;      push hDC
;      call FillRect    
;    wasn:
      mov [was], 1   
             
      mov eax, [humanPos2]
      mov humanRect2.top, eax
      add eax, blockHeight
      add eax, blockHeight
      mov humanRect2.bottom, eax      
      mov eax, bRect.right
      mov humanRect2.right, eax
      sub eax, 5
      mov humanRect2.left, eax  
          
      push hBBrush
      lea eax, humanRect2
      push eax
      push hDC
      call FillRect             
      
      
      mov eax, [humanPos]
      mov humanRect.top, eax
      add eax, blockHeight
      add eax, blockHeight
      mov humanRect.bottom, eax      
      mov eax, bRect.right
      mov humanRect.right, eax
      sub eax, 5
      mov humanRect.left, eax  
          
      push hBrush
      lea eax, humanRect
      push eax
      push hDC
      call FillRect           
      
      push hBBrush
      push hDC
      call SelectObject   
            
      mov eax, bRect.bottom		;zmiz kulicku			
      CDQ
      mov ebx, 35
      div ebx
      mov ecx, eax
      mov eax, [yBallPos2]
      mov ball2.top, eax
      add eax, ecx
      mov ball2.bottom, eax      
      mov eax, [xBallPos2]
      mov ball2.left, eax 
      add ecx, [xBallPos2]
      mov ball2.right, ecx 
      
      push ecx
      push ecx
      push ball2.bottom
      push ball2.right
      push ball2.top
      push ball2.left
      push hDC    
      call RoundRect    
      
      push hBrush
      push hDC
      call SelectObject 
      
      mov eax, bRect.bottom
      CDQ
      mov ebx, 35
      div ebx
      mov ecx, eax
      mov eax, [yBallPos]
      mov ball.top, eax
      add eax, ecx
      mov ball.bottom, eax      
      mov eax, [xBallPos]
      mov ball.left, eax 
      add ecx, [xBallPos]
      mov ball.right, ecx 
      
        
      
      push ecx
      push ecx
      push ball.bottom
      push ball.right
      push ball.top
      push ball.left
      push hDC    
      call RoundRect    
          
      
      lea eax, ps
      push eax
      push hWin
      call EndPaint  
      ret
  WndProc EndP
;________________________________________    
end start