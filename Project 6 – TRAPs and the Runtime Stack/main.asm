; Sample Code for Lab 6
; This sample code implements the int main() function

.ORIG x3000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; int main()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Main's return value
LD R6, STACK_BASE		; R6 = x6000

; Main's return address
ADD R6, R6, #-1			; R6 = x5FFF
STR R7, R6, #0

; Previous frame pointer
ADD R6, R6, #-1			; R6 = x5FFE
STR R5, R6, #0

; Set frame pointer
ADD R5, R6, #0			; R5 = R6 = x5FFE

; node_t *head
ADD R6, R6, #-1			; R6 = x5FFD
AND R0, R0, #0			; R0 = 0
STR R0, R6, #0

; char selection
ADD R6, R6, #-1			; R6 = x5FFC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; while(selection != 'q')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Perform the check for the while loop
; We check to see if char selection is equal to 'q'
; If equal, quit
; It not equal, continue running the loop
CHECK_WHILE
LDR R0, R5, #-2			; R0 = char selection
LD R1, LOWERCASE_Q
NOT R1, R1
ADD R1, R1, #1
ADD R1, R0, R1
BRz BREAK_WHILE_LOOP

; Print the options menu
LEA R0, PROMPT_MENU
PUTS

; Get a character from the keyboard and put it in selection
; (We don't have to write our own scanf() function)
GETC
STR R0, R5, #-2			; Store the character on the runtime stack in char selection (R0 = char selection)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; if(selection == 'p')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Check if char selection is equal to 'p'
LD R1, LOWERCASE_P
NOT R1, R1
ADD R1, R1, #1
ADD R1, R0, R1
BRnp ELSE_IF_A			; If not equal to 'p' check 'a'

; Display prompt
LEA R0, PROMPT_PRINT
PUTS

; node_t **head (&head) (input to printList())
ADD R6, R6, #-1			; R6 = x5FFA
ADD R0, R5, #-1			; R0 = &head = x5FFD
STR R0, R6, #0

JSR PRINT_LIST

; Pop node_t **head
ADD R6, R6, #1			; R6 = x5FFB

BRnzp CONTINUE_WHILE_LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; else if(selection == 'a')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Check if char selection is equal to 'a'
ELSE_IF_A
LD R1, LOWERCASE_A
NOT R1, R1
ADD R1, R1, #1
ADD R1, R0, R1
BRnp ELSE_IF_R

; int a
ADD R6, R6, #-1			; R6 = x5FFB
AND R0, R0, #0
STR R0, R6, #0

; Display prompt
LEA R0, PROMPT_ADD
PUTS

; Call TRAP service routine for getting number here
TRAP x40

; Store number entered into int a
STR R0, R5, #-3

; node_t **head (&head) (input to addValue())
ADD R6, R6, #-1			; R6 = x5FFA
ADD R0, R5, #-1			; R0 = &head = x5FFD
STR R0, R6, #0

; int added (a) (input to addValue())
ADD R6, R6, #-1			; R6 = x5FF9
LDR R0, R5, #-3
STR R0, R6, #0

JSR ADD_VALUE

; Pop int added
ADD R6, R6, #1			; R6 = x5FFA

; Pop node_t **head
ADD R6, R6, #1			; R6 = x5FFB

; Pop int a
ADD R6, R6, #1			; R6 = x5FFC

BRnzp CONTINUE_WHILE_LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; else if(selection == 'r')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Check if char selection is equal to 'r'
ELSE_IF_R
LD R1, LOWERCASE_R
NOT R1, R1
ADD R1, R1, #1
ADD R1, R0, R1
BRnp CONTINUE_WHILE_LOOP

; int r
ADD R6, R6, #-1			; R6 = x5FFB
AND R0, R0, #0
STR R0, R6, #0

; Display prompt
LEA R0, PROMPT_REMOVE
PUTS

TRAP x40
; Store number entered into int r
STR R0, R5, #-3

; node_t **head (&head) (input to removeValue())
ADD R6, R6, #-1			; R6 = x5FFA
ADD R0, R5, #-1			; R0 = &head = x5FFD
STR R0, R6, #0

; int removed (r) (input to removeValue())
ADD R6, R6, #-1			; R6 = x5FF9
LDR R0, R5, #-3
STR R0, R6, #0

JSR REMOVE_VALUE

; Pop int removed
ADD R6, R6, #1			; R6 = x5FFA

; Pop node_t **head
ADD R6, R6, #1			; R6 = x5FFB

; Pop int r
ADD R6, R6, #1			; R6 = x5FFC

BRnzp CONTINUE_WHILE_LOOP

; Loop back to check the while loop condition again
CONTINUE_WHILE_LOOP
BRnzp CHECK_WHILE

BREAK_WHILE_LOOP

; Pop local variables in main
ADD R6, R6, #2			; R6 = x5FFE

; Pop previous frame pointer
LDR R5, R6, #0
ADD R6, R6, #1			; R6 = x5FFF

; Pop return address
LDR R7, R6, #0
ADD R6, R6, #1			; R6 = x6000

HALT

STACK_BASE .FILL x6000

LOWERCASE_A .FILL x0061
LOWERCASE_P .FILL x0070
LOWERCASE_Q .FILL x0071
LOWERCASE_R .FILL x0072

PROMPT_MENU .STRINGz 	"Available options:\np - Print linked list\na - Add value to linked list\nr - Remove value from linked list\nq - Quit\nChoose an option: "
PROMPT_PRINT .STRINGz 	"\nContents of the linked list: \n"
PROMPT_ADD .STRINGz 	"\nType a number to add: \n"
PROMPT_REMOVE .STRINGz 	"\nType a number to remove: \n"

; void printList(node_t **head)
PRINT_LIST
ADD R6,R6, #-1
STR R7, R6, #0
ADD R6, R6, #-1
STR R5, R6, #0
ADD R5, R6, #0
ADD R6, R6, #-1

LDR R0, R5, #2
LDR R0,R0, #0
STR R0, R5,#-1


PL_LOOP

LDR R0, R5, #-1
BRz PL_DONE
LDR R0,R0, #0

TRAP x41

LDR R0,R5, #-1
LDR R0, R0, #1
STR R0, R5, #-1
BRz PL_DONE

LEA R0, ARROW
PUTS
BRnzp PL_LOOP

PL_DONE

LEA R0, NL_STR
PUTS
ADD R6, R5, #0
LDR R5,R6, #0
ADD R6, R6, #1
LDR R7, R6, #0
ADD R6,R6, #1
RET

ARROW   .STRINGz " -> "
NL_STR  .STRINGz "\n"

; void addValue(node_t **head, int added)
ADD_VALUE
ADD R6, R6, #-1
STR R7, R6, #0
ADD R6,R6,#-1
STR R5, R6, #0
ADD R5, R6, #0

LD R0, HEAP_PTR
ADD R1, R0, #2
ST R1, HEAP_PTR
LDR R1, R5, #2
STR R1, R0, #0
AND R1,R1,#0
STR R1, R0, #1

LDR R1, R5, #3
LDR R2, R1, #0
BRnp AV_LOOP
STR R0, R1, #0
BRnzp AV_DONE

AV_LOOP
LDR R3, R2, #1
BRz AV_ATTACH
ADD R2, R3, #0
BRnzp AV_LOOP

AV_ATTACH
STR R0, R2, #1

AV_DONE
ADD R6,R5,#0
LDR R5, R6, #0
ADD R6, R6, #1
LDR R7, R6, #0
ADD R6, R6, #1

RET

HEAP_PTR    .FILL x7000

; void removeValue(node_t **head, int removed)
REMOVE_VALUE

ADD R6, R6, #-1
STR R7, R6, #0
ADD R6, R6, #-1
STR R5, R6, #0
ADD R5, R6, #0

LDR R1, R5, #3
LDR R2, R1, #0
BRz RV_DONE

LDR R0, R5, #2
NOT R0, R0
ADD R0, R0, #1

LDR R3, R2, #0
ADD R3, R3, R0
BRnp RV_SEARCH
LDR R3, R2, #1
STR R3, R1, #0
BRnzp RV_DONE

RV_SEARCH
LDR R4, R2, #1
RV_LOOP
ADD R4, R4, #0

BRz RV_DONE
LDR R3, R4, #0
ADD R3, R3, R0
BRz RV_FOUND
ADD R2, R4, #0
LDR R4, R4, #1
BRnzp RV_LOOP

RV_FOUND
LDR R3, R4, #1
STR R3, R2, #1

RV_DONE
ADD R6, R5, #0
LDR R5, R6, #0
ADD R6, R6, #1
LDR R7, R6, #0
ADD R6, R6, #1

RET

.END