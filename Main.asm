; Main.asm
; Name:
; UTEid: 
; Continuously reads from x2600 making sure its not reading duplicate
; symbols. Processes the symbol based on the program description
; of mRNA processing.
               .ORIG x3000
; initialize the stack pointer




; set up the keyboard interrupt vector table entry



; enable keyboard interrupts



; start of actual program

		.END
