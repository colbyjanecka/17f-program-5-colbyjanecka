; ISR.asm
; Name: Colby Janecka
; UTEid: CDJ2326
; Keyboard ISR runs when a key is struck
; Checks for a valid RNA symbol and places it at x2600

            			.ORIG			x2500

				ST			R0, SAVE0			; Save values used by this interrupt service routine...
				ST			R1, SAVE1
				ST			R2, SAVE2
				ST			R3, SAVE3
				ST			R6, SAVE6
				ST			R7, SAVE7

				LEA			R0, ACGU			; Load address of ACGU array
				LD	 		R1, KBDR			; Load address of the KBDR register...
				LDR			R1, R1, #0			; ... and Load values found at this address
				LD			R3, FIVE			; Set counter to 5 (four loops)

LOOPx4				ADD 			R3, R3, #-1			; Decrement counter
				BRnz			NONE				; Exit once counter is 0

				LDR			R2, R0, #0			; Load letter in array
				ADD 			R2, R2, R1			; compare it to letter inputted
				BRz			VERIFIED			; if they are the same, go to VERIFIED
				ADD 			R0, R0, #1			; add one to R0 (array pointer)
				BR			LOOPx4				; continue loop four times


VERIFIED			LD			R2, Char_Address		; If it is a letter...
				STR	 		R1, R2, #0			; Store its ASCII code in x2600 for Main program to find

NONE				LD			R0, SAVE0			; Load values of registers before changed by ISR
				LD			R1, SAVE1
				LD			R2, SAVE2
				LD			R3, SAVE3
				LD			R6, SAVE6
				LD			R7, SAVE7

				RTI							; And return from the interrupted service

				HALT

FIVE				.FILL			#5
KBSR				.FILL        		xFE00
KBDR				.FILL			xFE02
Char_Address			.FILL			x2600
NewChar				.FILL			x8000
ACGU				.FILL			xFFBF
				.FILL			xFFBD
				.FILL			xFFB9
				.FILL			xFFAB
SAVE0				.FILL			x0000
SAVE1				.FILL			x0000
SAVE2				.FILL			x0000
SAVE3				.FILL			x0000
SAVE6 				.FILL			x0000
SAVE7				.FILL			x0000

				.END
