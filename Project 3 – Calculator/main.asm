.ORIG x3000 

; ================= MAIN =================
; Get number 1 → operation → number 2 → calculate → display → repeat

LOOP 

LEA R0, PROMPT1
PUTS

JSR GETNUM          ; R0 = first number
ST R0, NUM1

LEA R0, PROMPT2
PUTS

JSR GETOP           ; R0 = +, -, or *
ST R0, OP

LEA R0, PROMPT3
PUTS

JSR GETNUM          ; R0 = second number
ST R0, NUM2

; CALC needs:
; R0 = num1, R1 = num2, R2 = operation
LD R0, NUM1
LD R1, NUM2
LD R2, OP

JSR CALC            ; R0 = answer
JSR DISPLAY         ; print answer

BRNZP LOOP          ; repeat


HALT


; ================= GETNUM =================
; Reads digits until ENTER.
; Returns number in R0.
; R1 = number being built

GETNUM 
ST R7, SAVER7

AND R1, R1, #0      ; R1 = 0

GNLOOP 
GETC

ADD R2,R0, #-10     ; ENTER? (ASCII 10)
BRz GNDONE          ; yes → finish

OUT

LD R3, NEG48        ; convert ASCII → number
ADD R0, R0, R3

; R1 = R1 * 10 + new digit
ADD R2,R1,R1        ; 2x
ADD R1,R2,R2        ; 4x
ADD R1,R1,R1        ; 8x
ADD R1,R1,R2        ; 10x
ADD R1, R1, R0      ; + digit

BRnzp GNLOOP

GNDONE 
ADD R0,R1, #0       ; return number in R0
LD R7, SAVER7
RET


; ================= GETOP =================
; Reads +, -, or *
; Returns operation in R0

GETOP 
ST R7, SAVER7

GETC
OUT

ADD R1,R0,#0        ; save operation

GETC                ; read ENTER

ADD R0,R1,#0        ; return operation
LD R7, SAVER7

RET


; ================= CALC =================
; R0 = num1
; R1 = num2
; R2 = operation
; R0 = answer

CALC

; Check for +
LD R3, NEGPLUS
ADD R3,R2,R3
BRz addition

; Check for -
LD R3, NEGMINUS
ADD R3, R2, R3
BRz subtraction

; Otherwise → multiplication
BRnzp MULTI


; ---------- ADD ----------
addition
ADD R0,R0, R1
RET


; ---------- SUBTRACT ----------
; R0 - R1 = R0 + (-R1)
subtraction
NOT R1,R1          ; two's complement
ADD R1, R1, #1
ADD R0, R0, R1
RET


; ---------- MULTIPLY ----------
; Repeated addition
; R3 = total, R1 = counter

MULTI
AND R3,R3,#0       ; total = 0
ADD R1,R1,#0
BRz done           ; multiplying by 0

MUL
ADD R3,R3,R0       ; total += R0
ADD R1,R1,#-1     ; counter--
BRp MUL             ; keep going if > 0

done
ADD R0,R3,#0       ; return answer
RET


; ================= DISPLAY =================
; R0 = answer
; Prints the answer
; Uses -1000, -100, -10, -1 to find each digit

DISPLAY

ST R7, SAVER7
ADD R1,R0,#0       ; R1 = answer

LEA R0, RESULTM
PUTS

; If negative → print '-' and make positive
ADD R1, R1,#0
BRzp DIS

LD R0, INIT_X
OUT

NOT R1,R1
ADD R1,R1,#1

DIS
AND R6,R6,#0       ; R6 = printed-a-digit flag
LEA R3, PLACES     ; point to -1000


DLOOP

LDR R4, R3, #0     ; get place value
BRz PEND           ; 0 = finished

AND R2,R2,#0       ; digit counter = 0


; Keep subtracting place value
; R2 counts how many times it fits

SUBLOOP
ADD R5, R1,R4
BRn PRINTD         ; went negative → stop

ADD R1, R5, #0
ADD R2, R2, #1

BRnzp SUBLOOP


; Print the digit
PRINTD

ADD R2,R2,#0
BRp show           ; digit > 0 → print

; Skip leading zeros
ADD R6,R6,#0
BRp show           ; already printed something

; Special case: print 0 for result 0
ADD R5,R4,#1
BRnp SKIP


show
LD R5, ASSCII0
ADD R0, R2,R5      ; number → ASCII
OUT

ADD R6,R6,#1       ; mark digit printed

SKIP
ADD R3,R3,#1       ; next place
BRnzp DLOOP


PEND
LD R7, SAVER7
RET


; ================= DATA =================

; Digit places: thousands → hundreds → tens → ones → end
PLACES  .FILL #-1000
        .FILL #-100
        .FILL #-10
        .FILL #-1
        .FILL #0

ASSCII0 .FILL #48       ; ASCII '0'
NEGPLUS .FILL #-43      ; -ASCII '+'
NEGMINUS .FILL #-45     ; -ASCII '-'
SAVER7  .BLKW 1         ; saved return address
NEG48   .FILL #-48      ; used to convert ASCII digit
NUM1    .BLKW 1
NUM2    .BLKW 1
OP      .BLKW 1
INIT_X  .FILL X2D       ; ASCII '-'

RESULTM .FILL X0A
        .STRINGZ "Result: "
PROMPT1 .FILL X0A
        .STRINGZ "Enter first number(0 - 99): "
PROMPT2 .FILL X0A
        .STRINGZ "Enter an operation(+ , -, *): "
PROMPT3 .FILL X0A
        .STRINGZ "Enter second number(0 - 99): "
.END