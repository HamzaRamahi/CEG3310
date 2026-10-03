; ============================================================
; PROGRAM SUMMARY
; A FOR loop in LC-3. It adds 5 to a total, MAX times
; (MAX = 5), so the answer is 5 + 5 + 5 + 5 + 5 = 25.
; The result is stored at memory x8001.
;
; Same idea in C++/Java:
;     int total = 0;
;     for (int i = 0; i < 5; i++) {
;         total += 5;
;     }
;
; REGISTER MAP
;   R0 = -MAX (negative of 5, so we can "subtract" with ADD)
;   R1 = i, the loop counter (counts UP from 0)
;   R3 = total, the running sum
;   R4 = temp: holds i - MAX, only used to test the condition
; ============================================================

.ORIG X3000                    ; Program starts at memory address x3000

AND R3, R3, #0                 ; R3 = 0 (AND with #0 clears a register). total = 0
AND R1, R1, #0                 ; R1 = 0. i = 0
LD R0, MAX                     ; R0 = 5 (loads the value stored at MAX)
NOT R0, R0                     ; R0 = flip all bits of R0 (step 1 of making it negative)
ADD R0, R0, #1                 ; R0 = R0 + 1 (step 2). NOT + 1 = two's complement, so R0 = -5


FOR_LOOPING                    ; ===== LOOP START: the condition is checked FIRST, then the body runs =====
ADD R4, R1, R0                 ; R4 = i + (-5) = i - 5. This is the subtraction used for the comparison
BRzp CHECK                     ; ===== LOOP CONDITION (exit test): if R4 is Zero or Positive (i >= 5), jump out to CHECK =====
                               ; If R4 is negative (i < 5), the branch is NOT taken and the body below runs

ADD R3, R3, #5                 ; LOOP BODY: total = total + 5
ADD R1, R1, #1                 ; i = i + 1 (counter goes UP)
BR FOR_LOOPING                 ; UNCONDITIONAL BRANCH: always jump back to the top to re-check the condition


CHECK                          ; ===== LOOP EXIT: lands here once i reaches 5 =====

STI R3, RESULT                 ; STORE INDIRECT: reads the address stored AT RESULT (x8001),
                               ; then stores R3 (the total) into memory at THAT address

HALT                           ; TRAP: stops the program

MAX .FILL #5                   ; DATA: the loop limit, decimal 5
RESULT .FILL X8001             ; DATA: holds the ADDRESS x8001 (not the answer). STI uses it as a pointer
.END                           ; Tells the assembler the program is finished