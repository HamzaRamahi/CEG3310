; ============================================================
; PROGRAM SUMMARY
; Computes a POWER: INIT_X ^ INIT_Y (here 5^2) using only
; addition. LC-3 has no multiply, so multiplication is done
; by repeated addition, and the power is done by repeating
; the multiplication. The answer is stored at memory x8000.
;
; STRUCTURE: two loops, one inside the other
;   OUTER LOOP (POWER) = runs Y times, one multiply per run
;   INNER LOOP (MULTI) = does one multiply using repeated adds
;
; REGISTER MAP
;   R0 = accumulator for the current multiplication result
;   R1 = X, the base (5). Never changes
;   R2 = Y, the exponent (2). Outer loop counter, counts down
;   R3 = leftover, not used for anything (see notes below)
;   R4 = inner loop counter, counts down
;   R5 = the running result (starts at 1)
; ============================================================

.ORIG X3000                    ; Program starts at memory address x3000

LD R1, INIT_X                  ; R1 = 5 (loads the value stored at INIT_X). This is the base
LD R2, INIT_Y                  ; R2 = 2 (loads the value stored at INIT_Y). This is the exponent / outer loop counter

ADD R3, R3, R2                 ; R3 = R3 + R2. R3 was never set, and nothing reads it later, so this line has no effect on the answer

AND R5, R5, #0                 ; R5 = 0 (AND with #0 clears a register)
ADD R5, R5, #1                 ; R5 = 0 + 1 = 1. Running result starts at 1, like starting a product at 1


POWER                          ; ===== OUTER LOOP START: runs once per exponent step (Y times) =====

AND R0, R0, #0                 ; R0 = 0. Clear the accumulator before each new multiplication
ADD R4, R1, #0                 ; R4 = R1 + 0 = 5. Copy R1 into R4 (the "move" trick). R4 = inner loop counter

MULTI                          ; ===== INNER LOOP START: repeated addition, runs R4 times =====
ADD R0, R1, R0                 ; R0 = R1 + R0. Add the base into the accumulator
ADD R4, R4, #-1                ; R4 = R4 - 1. Counter goes down (also sets condition codes N, Z, P)
BRp MULTI                      ; ===== INNER LOOP CONDITION: if R4 > 0, branch back to MULTI =====
                               ; When R4 hits 0, falls through to the next line

ADD R5, R0, #0                 ; R5 = R0 + 0. Copy the multiplication result into R5 (the running result)

ADD R2, R2, #-1                ; R2 = R2 - 1. Outer counter goes down (sets condition codes)
BRP POWER                      ; ===== OUTER LOOP CONDITION: if R2 > 0, branch back to POWER =====
                               ; When R2 hits 0, falls through
                               ; (BRP and BRp are the same, the assembler ignores case)

STI R5, RESULT                 ; STORE INDIRECT: reads the address stored AT RESULT (x8000),
                               ; then stores R5 into memory at THAT address. So memory x8000 = R5

HALT                           ; TRAP: stops the program

RESULT .FILL X8000             ; DATA: holds the ADDRESS x8000 (not the answer). STI uses it as a pointer
INIT_X .FILL #5                ; DATA: the base, decimal 5
INIT_Y .FILL #2                ; DATA: the exponent, decimal 2

.END                           ; Tells the assembler the program is finished