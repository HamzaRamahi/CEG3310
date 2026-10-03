; ============================================================
; PROGRAM SUMMARY
; Asks the user to type a digit 10 times. Each key press is a
; character (like '7'), so the program converts it to the real
; number 7 and stores it in a 10-word array in memory.
;
; REGISTER MAP
;   R0 = temp: prompt address, then the typed character, then the digit
;   R1 = loop counter (starts at 10, counts down to 0)
;   R2 = temp: holds -x30 for the ASCII-to-number conversion
;   R6 = pointer to the current array slot (moves forward each loop)
; ============================================================

.ORIG x3000                    ; Program starts at memory address x3000

LD R1, ARRAY_SIZE              ; R1 = 10 (loads the value stored at ARRAY_SIZE). This is the loop counter
LEA R6, ARRAY                  ; R6 = the ADDRESS of the first array slot (LEA loads an address, not the data)


FILL_ARRAY_LOOP                ; ===== LOOP START: runs once per number entered =====
LEA R0, PROMPT                 ; R0 = address of the prompt string (PUTS needs the address in R0)
PUTS                           ; TRAP: prints the string at R0 until it hits the null (0) at the end
GETC                           ; TRAP: waits for a key press, puts its ASCII code in R0 (does NOT show it on screen)
OUT                            ; TRAP: prints the character in R0, so the user sees what they typed

LD R2, ASCII                   ; R2 = x0030 (the ASCII code for the character '0')
NOT R2, R2                     ; R2 = flip all bits of R2 (step 1 of making it negative)
ADD R2, R2, #1                 ; R2 = R2 + 1 (step 2). NOT + 1 = two's complement, so R2 = -x30
ADD R0, R0, R2                 ; R0 = R0 - x30. Converts the ASCII char to a number ('7' = x37, x37 - x30 = 7)

STR R0, R6, #0                 ; Store R0 into memory at address (R6 + 0), the current array slot

ADD R6, R6, #1                 ; R6 = R6 + 1, so the pointer moves to the next array slot
ADD R1, R1, #-1                ; R1 = R1 - 1 (counter goes down). This also sets the condition codes (N, Z, P)
BRp FILL_ARRAY_LOOP            ; ===== LOOP CONDITION: BRANCH if the last result was Positive (R1 > 0), go back to loop start =====
                               ; When R1 hits 0, the branch is NOT taken and the program falls through
HALT                           ; TRAP: stops the program

ARRAY_SIZE .FILL #10           ; DATA: one word holding the decimal value 10
ARRAY .BLKW #10                ; DATA: reserves 10 empty words in a row (this is the array)
ASCII .FILL X0030              ; DATA: one word holding x0030, the ASCII code of '0'
PROMPT .STRINGZ "ENTER A NUMBER: "  ; DATA: the text, stored one char per word, with a null (0) added at the end

.END                           ; Tells the assembler the program is finished