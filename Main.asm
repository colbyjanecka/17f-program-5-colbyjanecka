; Main.asm; Main.asm
; Name: Colby Janecka
; UTEid: CDJ2326
; Continuously reads from x2600 making sure its not reading duplicate
; symbols. Processes the symbol based on the program description
; of mRNA processing.

               .ORIG 	x3000

; initialize the stack pointer

				LD 			R6, IntEnable		; Initialized stack pointer to x4000

; set up the keyboard interrupt vector table entry

				LD 			R1, IVT_ADDRESS		; Load address of keyboard interrupt vector location
				LD			R2, ISR_ADDRESS		; 		..
				STR 			R2, R1, #0		; and store the ISR origin address at the IVT address.

; enable keyboard interrupts

				LD			R1, KBSR_ADDRESS	; Load address of the KBSR register
				LDR 			R2, R1, #2		; Load contents of the KBDR register (at xFE02, in order to clear input data)
				LD			R3, IntEnable		; Load the value x4000, which
				STR			R3, R1, #0			;								sets the interrupt enable bit at KBSR[14] to 1.

; start of actual program

START 				JSR			GET_LETTER
				JSR			PRINT_LETTER
				LD			R3, A				; If input is A, continue to START2
				ADD 			R3, R3, R0			;		..
				BRz			START2				;		..
				LD			R0, LETTER			; Verify no changes to input letter stored in R0
				BRnp			START				; If input is not A, return back to START
				BR			START				; Else, return to START

START2				JSR			GET_LETTER
				JSR			PRINT_LETTER
				LD			R3, U				; If input is U, continue to START3
				ADD 			R3, R3, R0			;		..
				BRz			START3				;		..
				LD			R3, A				; If input is A, keep pollng for U
				ADD 			R3, R3, R0			;		..
				BRz 			START2				;		..
				LD			R0, LETTER			; Verify no changes to input letter stored in R0
				BRnp			START				; If input is not A/U, return back to START
				BR			START2				; Else, return to START2

START3				JSR			GET_LETTER
				JSR			PRINT_LETTER
				LD			R3, G				; If input is G, continue to SEQUENCE
				ADD 			R3, R3, R0			;		..
				BRz			SEQUENCE			;		..
				LD			R3, A				; If input is A, continue to START2
				ADD 			R3, R3, R0			;		..
				BRz			START2				;		..
				LD			R0, LETTER			; Verify no changes to input letter stored in R0
				BRnp			START				; If input is not G, return back to START
				BR			START3				; Else, return to START3

SEQUENCE			LD			R0, BAR
				OUT

SEQLOOP				JSR			GET_LETTER
				JSR			PRINT_LETTER
				LD			R3, U				; If input is U, continue to END1
				ADD 			R3, R3, R0			;		..
				BRz			END1				;		..
				LD			R0, LETTER			; Verify no changes to input letter stored in R0
				BR			SEQLOOP				; Else, return to SEQLOOP

END1				JSR			GET_LETTER
				JSR			PRINT_LETTER
				LD			R3, A				; If input is A, go to END2
				ADD 			R3, R3, R0			;		..
				BRz			END2				;		..
				LD			R3, G				; If input is G, go to END3
				ADD 			R3, R3, R0			;		..
				BRz 			END3				;		..
				LD			R3, U				; If input is U, keep polling for A/G
				ADD			R3, R3, R0			;		..
				BRz 			END1				;		..
				LD			R0, LETTER			; Verify no changes to input letter stored in R0
				BRnp			SEQLOOP				; If input is not G/A/U, return back to SEQLOOP
				BR			END1				; Else, return to END1

END2				JSR			GET_LETTER
				JSR			PRINT_LETTER
				LD			R3, G				; If input is G, continue to END
				ADD 			R3, R3, R0			;		..
				BRz			END					;		..
				LD			R3, A				; If input is A, continue to END
				ADD 			R3, R3, R0			;		..
				BRz 			END				;		..
				LD			R3, U				; If input is U, continue to END1
				ADD 			R3, R3, R0			;		..
				BRz 			END1				;		..
				LD			R0, LETTER			; Verify no changes to input letter stored in R0
				BRnp			SEQLOOP				; If input is not G/A, return back to SEQLOOP
				BR			END2				; Else, return to END2

END3				JSR			GET_LETTER
				JSR			PRINT_LETTER
				LD			R3, A				; If input is A, continue to END
				ADD 			R3, R3, R0			;		..
				BRz 			END				;		..
				LD			R3, U				; If input is U, continue to END1
				ADD 			R3, R3, R0			;		..
				BRz 			END1				;		..
				LD			R0, LETTER			; Verify no changes to input letter stored in R0
				BRnp			SEQLOOP				; If input is not A, return back to SEQLOOP
				BR			END3				; Else, return to END3

END 				HALT							; If END codon is recieved, then halt the program.


; ********************
; GET_LETTER
; Output: R0
; Gets the current value stored in x2600 and loads it into R0
; then saves it for later access at the label LETTER.
;*********************
GET_LETTER			ST			R7, SAVE70			; Save current RET value
				LD			R1, Char_Address		; Load x2600 into R1
				LDR			R0, R1, #0			; Load value stored at this memory location
				ST			R0, LETTER			; And save it in the LETTER label
				LD			R7, SAVE70			; Load current RET value

				RET


; ********************
; PRINT_LETTER
; Input: R1 has x2600
; Prints the current letter that is stored at the LETTER label,
; and sets the value in M[x2600] to #0 (x0000)
;*********************
PRINT_LETTER			ST			R7, SAVE71			; Save current RET value
				LD			R0, LETTER			; Load current input letter
				BRz 			#5				; If none, skip printing

				ST			R1, SAVE1			; Save R1, which is used by OUT trap routine
				OUT							; Perform printing of letter
				LD			R1, SAVE1			; Load previous value for R1

				AND			R5, R5, #0			; Set 0 -> M[x2600]
				STR			R5, R1, #0
				LD			R7, SAVE71			; Load current RET value

				RET

BAR 				.FILL		x007C
Char_Address			.FILL		x2600
IVT_ADDRESS			.FILL		x0180
ISR_ADDRESS			.FILL		x2500
KBSR_ADDRESS			.FILL		xFE00
KBDR 				.FILL		xFE02
IntEnable			.FILL		x4000
SAVE1				.FILL		x0000
SAVE70				.FILL		x0000
SAVE71				.FILL		x0000
A				.FILL		xFFBF
C				.FILL		xFFBD
G				.FILL		xFFB9
U				.FILL		xFFAB
LETTER 				.FILL		x0000


				.END

