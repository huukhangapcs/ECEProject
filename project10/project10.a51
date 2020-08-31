ORG 0H
	rs EQU P3.2
	rw EQU P3.3
	e EQU P3.4
	row1 BIT P1.0
	row2 BIT P1.1
	row3 BIT P1.2
	row4 BIT P1.3
	col1 BIT P1.4
	col2 BIT P1.5
	col3 BIT P1.6
	col4 BIT P1.7
	Keycode EQU 34H
	COL EQU 32H
	CONFIRM BIT P3.0 
	LOCK BIT P3.5
	REPASS BIT P3.6
	DEL BIT P3.1
	MOV 71H,#0	 ; 
	MOV R0,#40H	 ; address of default pass
	MOV R1,#50H	 ; address of entered pass
	;;;;;;;;;;;;;;;;;;R0:DEFAULT PASS
	;;;;;;;;;;;;;;;;;;R1: ENTERED PASS
	;;;;;;;;;;;;;;;;;;R2: LENGTH 0F ENTERED PASS
	;;;;;;;;;;;;;;;;;;R3: LENGTH OF DEFAULT PASS
	;;;;;;;;;;;;;;;;;;R4: CHECK MODE 4:NORMAL, 1: ENTER OLD PASS, 2: ENTER NEW PASS, 3: CONFIRM NEW PASS 
INIT_PASSWORD:
	MOV R2,#6
LOOP_INIT_PASS:
	MOV @R0,#'1'
	MOV R4, #4
	INC R0
	DJNZ R2,LOOP_INIT_PASS
	MOV R0,#40H
	MOV R2,#0
	MOV R3,#6 ; LENGTH OF DEFAULT PASS
	CLR REPASS
	CLR DEL
MAIN:
CALL LCD_INIT;
CALL DELAY_120MS
CALL DISPLAY_ENTERPASS
MOV A, #0C0H
CALL CMD_WRITE
LOOP_MAIN:
CALL ROWOFF
CALL KEYBOARD_PRESS
SJMP LOOP_MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LCD_INIT:
	MOV A,#38h ;Init LCD 2 lines, 5x7 matrix
	CALL CMD_WRITE ;Call CMD_WRITE
	CALL DELAY_120MS
	MOV A,#0FH ;Display ON cursor OFF
	CALL CMD_WRITE ;Call CMD_WRITE
	CALL DELAY_120MS
	MOV A,#01h ;Clear display screen
	CALL CMD_WRITE ;Call CMD_WRITE
	CALL DELAY_120MS
	MOV A,#80h ;Force cursor to the beginning of the  fist line
	CALL CMD_WRITE ;Call CMD_WRITE
	CALL DELAY_120MS
	CLR CONFIRM
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CMD_WRITE:
	MOV P2,A ;Send command code
	CLR rs ;RS=0 for command
	CLR rw ;R/W = 0 to write
	SETB e ;E = 1
	CALL DELAY_120MS
	CLR e ;E = 0, to latch
	RET
SEND_DATA:
	MOV P2, A
	SETB rs
	CLR rw
	SETB e;
	CALL DELAY_60MS
	CLR e
	CALL DELAY_60MS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DELAY_120MS:
		MOV R6, #200
	LOOP_DELAY_120MS:
		CALL DELAY_60MS
		DJNZ R6, LOOP_DELAY_120MS
		RET
DELAY_60MS:
	MOV R5, #250
	DJNZ R5,$
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
KEYBOARD_PRESS:
	CALL DELETE_PRESSED
	CALL ENTER_PRESSED
	CALL CHANGE_PASS_PRESSED
	CALL FIND_PRESSED_KEY
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MSG1: 
DB '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
ENTERPASS:
DB 'ENTER PASS:',0
PASSWORD:
DB '1','1','1','1','1',0
R_PASS:
DB 'SUCCESSFUL',0
W_PASS:
DB 'WRONG PASSWORD',0
C_PASS:
DB 'CHANGE:',0
DISPLAY_ENTERPASS:
	MOV DPTR, #ENTERPASS
	CALL DISPLAY
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROWOFF:
SETB col1
SETB col2
SETB col3
SETB col4
CLR row1
CLR row2
CLR row3
CLR row4
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FIND_PRESSED_KEY:
	JNB col1, Scan
	JNB col2, Scan
	JNB col3, Scan
	JNB col4, Scan
	RET
Scan:
	CALL DELAY_120MS
	CALL Scan_keyboard
	RET
Scan_keyboard:
	clr		row1  				; quet hang A
	setb	row2
	setb	row3
	setb	row4
	acall	CHECK_COL			; kiem tra co phim nao cua hang A duoc nhan hay khong
	mov		A,COL				; tra ve vi tri Cot cua phim duoc nhan
	jz		to_row2				; nhay sang quet hang tiep theo neu khong co phim nao cua hang A duoc nhan
	subb	A,#1
	mov		Keycode,A			; neu co phim cua hang A duoc nhan thi luu gia tri phim ( 0...1...2...3)
	sjmp	ok
to_row2:
	clr		row2
	setb	row1
	setb	row3
	setb	row4
	acall	CHECK_COL
	mov		A,COL
	jz		to_row3
	add		A,#3
	mov		Keycode,A		   ;neu co phim cua hang B duoc nhan thi luu gia tri phim ( 4...5...6...7)
	sjmp	ok
to_row3:
	clr		row3
	setb	row1
	setb	row2
	setb	row4
	acall	CHECK_COL
	mov		A,COL
	jz		to_row4
	add		A,#7			   ;neu co phim cua hang C duoc nhan thi luu gia tri phim ( 8...9..a...b)
	mov		Keycode,A
	sjmp	ok
to_row4:
	clr		row4
	setb	row1
	setb	row2
	setb	row3
	acall	CHECK_COL
	mov		A,COL
	jz		ok
	add		A,#11			  ;neu co phim cua hang D duoc nhan thi luu gia tri phim ( c...d...e...f)
	mov		Keycode,A
ok:

CALL SAVE_KEY
 ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_COL:
	jb		col1,check_col2
	mov		COL,#1			  				; co phim o Cot 1 duoc nhan
	sjmp	finish
check_col2:
	jb		col2,check_col3
	mov		COL,#2							;			Cot 2
	sjmp	finish
check_col3:
	jb		col3,check_col4
	mov		COL,#3							; 			Cot 3
	sjmp	finish
check_col4:
	jb		col4,no_col
	mov		COL,#4							;			Cot 4
	sjmp	finish
no_col:
	mov		COL,#0							;			khong tim thay phim nao duoc nhan cua 1 Hang
finish:
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
SAVE_KEY:
MOV DPTR, #MSG1
	MOVC A, @A + DPTR
	MOV @R1,A
	INC R1
	INC R2
	CALL SEND_DATA
	CALL DELAY_120MS
	RET
CONTINUE_PRESS:
	JMP LOOP_MAIN
	RET
DISPLAY:
	CLR A
	MOVC A,@A+DPTR
	JZ EXIT
	CALL SEND_DATA
	CALL DELAY_120MS
	INC DPTR
	SJMP DISPLAY
EXIT:
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DEL
DELETE_PRESSED:
	JB DEL, NEXT_DELETE 
	RET
NEXT_DELETE:
	JMP MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ENTER
ENTER_PRESSED:
	JB CONFIRM, ENTER
	RET
ENTER:
	CLR A
	MOV A,R4
	CJNE A,#1,ENTER_NEXT
	JMP ENTER_OLD_PASS
	RET
ENTER_NEXT:
	MOV A,R4
	CJNE A,#2,ENTER_NEXT2
	JMP ENTER_NEW_PASS
	RET
ENTER_NEXT2:
	MOV A,R4
	CJNE A,#3,ENTER_NORMAL_MODE
	JMP REENTER_NEW_PASS
	RET
; *******************************************
;**********************************************

;************************************************
CHANGE_PASS_PRESSED:
	JB REPASS, CHANGE_PASSWORD
	RET
CHANGE_PASSWORD:
	MOV R4, #1
	JMP LCD_ENTER_OLD_PASS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LCD_ENTER_OLD_PASS:
	MOV R4,#1
	MOV A,#01H
	CALL CMD_WRITE
	CALL DELAY_120MS
	MOV DPTR,#CHANGE_PASS_TEXT1
	CALL DISPLAY
	MOV A,#0C0H
	CALL CMD_WRITE
	CALL DELAY_120MS 
	JMP KEYBOARD_PRESS
	RET
LCD_ENTER_NEW_PASS:
	MOV R1,#60H
	MOV R7,#0
	MOV R2,#0
	MOV R4,#2
	MOV A,#01H
	CALL CMD_WRITE
	CALL DELAY_120MS
	MOV DPTR,#CHANGE_PASS_TEXT2
	CALL DISPLAY
	MOV A,#0C0H
	CALL CMD_WRITE
	CALL DELAY_120MS
	JMP KEYBOARD_PRESS
	RET
LCD_REENTER_NEW_PASS:
	MOV R1,#50H
	MOV R2,#0
	MOV R4,#3
	MOV A,#01H
	CALL CMD_WRITE
	CALL DELAY_120MS
	MOV DPTR,#CHANGE_PASS_TEXT4
	CALL DISPLAY
	MOV A,#0C0H
	CALL CMD_WRITE
	CALL DELAY_120MS
	JMP KEYBOARD_PRESS
	RET
CHANGE_PASS_TEXT4: DB 'REENTER NEW PASS:',0
CHANGE_PASS_TEXT2: DB 'NEW PASS',0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ENTER_NORMAL_MODE:
	MOV A,R2
	MOV 74H,R3
	SUBB A,74H
	CJNE A,#00H,WRONG_PASS
	MOV R1,#50H
	MOV R0,#40H
LOOP_ENTER_NORMAL_MODE:
MOV A,@R0
MOV 74H,@R1
SUBB A,74H
CJNE A,#00H,WRONG_PASS
INC R1
INC R0
DJNZ R2,LOOP_ENTER_NORMAL_MODE
JMP OPEN_LOCK
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ENTER_OLD_PASS:
	MOV A,R2
	MOV 74H,R3
	SUBB A,74H
	CJNE A,#00H,WRONG_PASS
	MOV R1,#50H
	MOV R0,#40H
	LOOP_ENTER_OLD_PASS:
	MOV A,@R0
	MOV 74H,@R1
	SUBB A,74H
	CJNE A,#00H,WRONG_PASS
	INC R1
	INC R0
	DJNZ R2,LOOP_ENTER_OLD_PASS
	JMP LCD_ENTER_NEW_PASS
	RET
ENTER_NEW_PASS:
	MOV A,R2
	MOV R7,A
JMP LCD_REENTER_NEW_PASS
RET
; *************************
REENTER_NEW_PASS:
	MOV A,R7
	MOV 74H,R2
	SUBB A,74H
	CJNE A,#0,OPEN_LOCK
	MOV R1,#60H
	MOV R0,#50H
	ENTER121:
	MOV 74H,@R0
	MOV A,@R1
	SUBB A,74H
	CJNE A,#0,WRONG_PASS
	INC R1
	INC R0
	DJNZ R2, ENTER121
	JMP SAVE_PASSWORD
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SAVE_PASSWORD:
	CLR A
	MOV A,R7
	MOV R3,A
	MOV R1,#60H
	MOV R0,#40H
	LOOP_SAVE_PASS:
	CLR A
	MOV A,@R1
	MOV @R0,A
	INC R0
	INC R1
	DJNZ R4,LOOP_SAVE_PASS
	MOV R4,#4
	MOV R0,#40H
	MOV R1,#50H
	MOV R7,#0
	MOV R2,#0
	MOV 71H,#0
	JMP CHANGED_SUCCESSFULL
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WRONG_PASS:
	CALL RESET_STATE
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHANGED_SUCCESSFULL:
MOV A,#01H
CALL CMD_WRITE
CALL DELAY_120MS
MOV DPTR,#COMPLETE_CHANGE
CALL DISPLAY
CALL DELAY_120MS
CALL DELAY_120MS
CALL DELAY_120MS
JMP MAIN
RET
COMPLETE_CHANGE: DB 'CHANGED PASSWORD',0	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OPEN_LOCK:
	CLR LOCK
	MOV A,#01H;clear
	CALL CMD_WRITE
	CALL DELAY_120MS
	MOV DPTR, #R_PASS
	CALL DISPLAY
	CALL DELAY_120MS
	LOOP_OPEN:
		JNB LOCK, LOOP_OPEN
		JMP MAIN
RET
RESET_STATE:
	MOV A,#01H;clear
	CALL CMD_WRITE
	CALL DELAY_120MS
	MOV DPTR,#W_PASS
	CALL DISPLAY
	MOV A,#0C0H
	CALL CMD_WRITE
	CALL DELAY_120MS
	CALL DELAY_120MS
	CALL DELAY_120MS
	MOV R2,#0
	MOV R1,#50H
	JMP MAIN
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CHANGE_PASS_TEXT1: DB 'OLD PASS:',0
END