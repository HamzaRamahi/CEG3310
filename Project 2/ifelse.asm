; ============================================================
; PROGRAM SUMMARY
; An IF / ELSE in LC-3. It checks whether INIT_X equals INIT_Y.
;   - If they are EQUAL     -> result = 5
;   - If they are NOT equal -> result = -5
; The result is stored at memory x8002. With X = 11 and Y = 11,
; the answer is 5.
;
; Same idea in C++/Java:
;     int result = 0;
;     if (x == y) { result = 5; }
;     else        { result = -5; }
;
; HOW EQUALITY IS TESTED: LC-3 has no compare instruction, so
; the program subtracts (Y - X) and checks if the answer is 0.
;
; REGISTER MAP
;   R0 = Y (11)
;   R1 = -X (negated, so we can "subtract" by adding)
;   R2 = Y - X (the difference). 0 means equal
;   R3 = the result (starts at 0, ends as 5 or -5)
; ============================================================

.ORIG X3000                    ; Program starts at memory address x3000

LD R1, INIT_X                  ; R1 = 11 (loads the value stored at INIT_X). This is X
LD R0, INIT_Y                  ; R0 = 11 (loads the value stored at INIT_Y). This is Y

AND R3, R3, #0                 ; R3 = 0 (AND with #0 clears a register). Result starts at 0

NOT R1, R1                     ; R1 = flip all bits of R1 (step 1 of making X negative)
ADD R1, R1, #1                 ; R1 = R1 + 1 (step 2). NOT + 1 = two's complement, so R1 = -X

ADD R2, R1, R0                 ; R2 = -X + Y = Y - X. This is the "comparison". Also sets condition codes
BRz EQUAL                      ; BRANCH: if R2 was Zero (X == Y), jump ahead to EQUAL, skipping the next line
ADD R3, R3, #-5                ; Only runs if X != Y: R3 = R3 - 5 = -5. (Sets the condition codes based on R3, which matters below)

EQUAL                          ; ===== LABEL: both paths meet here (X == Y jumped here, X != Y fell through) =====


ADD R2, R2, #0                 ; R2 = R2 + 0. Changes nothing, but RE-SETS the condition codes based on R2
                               ; (needed because the line above may have changed them based on R3)
BRnp ELSE                      ; BRANCH: if R2 is Negative or Positive (X != Y), jump to ELSE, skipping the next line

ADD R3, R3, #5                 ; Only runs if X == Y: R3 = R3 + 5 = 5

ELSE                           ; ===== LABEL: end of the if/else. Both paths continue from here =====

STI R3, RESULT                 ; STORE INDIRECT: reads the address stored AT RESULT (x8002),
                               ; then stores R3 into memory at THAT address


HALT                           ; TRAP: stops the program

RESULT .FILL x8002             ; DATA: holds the ADDRESS x8002 (not the answer). STI uses it as a pointer
INIT_X .FILL #11               ; DATA: X, decimal 11
INIT_Y .FILL #11               ; DATA: Y, decimal 11

.END                           ; Tells the assembler the program is finished