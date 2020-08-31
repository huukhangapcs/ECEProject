SECOND      EQU    R2
MINUTE     EQU    R3
HOUR        EQU    R4
COUNT    EQU    R5 ; LOOP 20 TIMES FOR 1 SECOND
ORG    000H
JMP    MAIN
ORG    00BH   
JMP    STOP

MAIN:
	CLR P1.0
	CLR P1.1
	CLR P1.2
    MOV    TMOD,#01H
    MOV    TH0,#HIGH(-50000)
    MOV    TL0,#LOW(-50000)
    CLR    TF0
    SETB    TR0
    MOV    IE,#82H
LOOP:
	MOV    HOUR,#0
RESET_MIN:    
	MOV    MINUTE,#0
RESET_SEC:    
	MOV    SECOND,#0
RESET_COUNT: 
	MOV    COUNT,#0
    CALL    HEX_BCD
    CALL    GET_LED_CODE
NO_RESET: 
	CALL    DISPLAY
	JB P1.0,CHANGE_HOUR
	JB P1.1,CHANGE_MIN
	JB P1.2,CHANGE_SEC
    CJNE    COUNT,#20,NO_RESET
	INC_SEC: INC    SECOND
    CJNE    SECOND,#60,RESET_COUNT
    INC_MIN: INC    MINUTE
    CJNE    MINUTE,#60,RESET_SEC
    INC_HOUR: INC    HOUR
    CJNE    HOUR,#24,RESET_MIN
    JMP    LOOP
;*********************************************
STOP:
    MOV    TL0,#LOW(-50000)
    MOV    TH0,#HIGH(-50000) ;DELAY 50MS -> LAP 20LAN = 1S
    INC    COUNT
RETI
;*********************************************
CHANGE_HOUR:
	CALL DELAY_50MS
	JMP INC_HOUR
	RET
CHANGE_MIN:
	CALL DELAY_50MS
	JMP INC_MIN
	RET
CHANGE_SEC:
	CALL DELAY_50MS
	JMP INC_SEC
	RET
;*********************************************
HEX_BCD:
    MOV     A,SECOND
    MOV     B,#10
    DIV       AB
    MOV    10H,B            ;LUU SO HANG DV GIAY
    MOV    11H,A              ;LUU SO HANG CHUC GIAY
   
    MOV    A,MINUTE
    MOV    B,#10
    DIV       AB
    MOV    12H,B            ;LUU SO HANG DV PHUT
    MOV    13H,A            ;LUU SO HANG CHUC PHUT

    MOV    A,HOUR
    MOV    B,#10
    DIV       AB
    MOV    14H,B        ;LUU SO HANG DV GIO
    MOV    15H,A        ;LUU SO HANG CHUC GIO
RET
;*********************************************
GET_LED_CODE:
    MOV    DPTR,#LED_CODE
    MOV    R0,#10H       
    MOV    R1,#20H
GM1: 
	MOV    R6,#2
GM2: 
	MOV    A,@R0
    MOVC  A,@A+DPTR
    MOV    @R1,A
    INC      R0
    INC      R1
    DJNZ    R6,GM2
    MOV    @R1,#0BFH
    INC       R1
    CJNE    R0,#16H,GM1
RET
;*********************************************
DISPLAY:
    MOV     R0,#20H
    MOV     A,#80H
LOOP_DISPLAY: 
	MOV   P0,@R0
    MOV     P2,A
    CALL    DELAY
    MOV     P2,#00H        ;CHONG LEM
    INC       R0
    RR        A
    CJNE    A,#80H,LOOP_DISPLAY
RET
;*********************************************
DELAY_MORE:
	MOV R6, #150
	LOOP_DELAY_MORE:
		CALL DELAY
		DJNZ R6, LOOP_DELAY_MORE
	RET
;**********************************************
DELAY_50MS:
		MOV R6, #255
		LOOP_DELAY_50MS:
			CALL DELAY
			CALL DELAY
			DJNZ R6, LOOP_DELAY_50MS
			RET
DELAY:
    MOV    R7,#255
    DJNZ    R7,$
RET
;*********************************************
LED_CODE:
DB 0C0H,0F9H,0A4H,0B0H,99H,92H,82H,0F8H,80H,90H
END
