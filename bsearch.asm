;;===============================
;;Name: Nathan Dass
;;===============================

; Main
; Do not edit this function!

;@plugin filename=lc3_udiv vector=x80

.orig x3000

	LD R6, STACK	; Initialize stack pointer

	LD R0, ARR_PTR	; \ Load parameters
	AND R1, R1, 0	; |
	LD R2, ARR_LEN	; |
	ADD R2, R2, -1	; |
	LD R3, X	; /

	ADD R6, R6, -4	; \ Call BSEARCH
	STR R0, R6, 0	; | Array pointer
	STR R1, R6, 1	; | Low
	STR R2, R6, 2	; | High
	STR R3, R6, 3	; | X
	JSR BSEARCH	; /

	LDR R0, R6, 0	; \ Pop return value and args off the stack
	ADD R6, R6, 5	; /

	ST R0, ANSWER

	HALT

STACK   .fill xF000 ; Bottom of the stack + 1
ARR_PTR .fill x6000 ; Pointer to the array of elements
ARR_LEN .fill 16
X       .fill -2    ; What to search for
ANSWER  .fill -999  ; Do NOT write to this label from the subroutine!



; To call UDIV, use TRAP x80
; Preconditions:
;    R0 = X
;    R1 = Y
; Postconditions:
;    R0 = X / Y
;    R1 = X % Y

BSEARCH
		ADD 		R6, R6, -3			; Decremement R6 by 3 (Point R6 to position of old frame pointer)
		STR 		R7, R6, 1 			; Put value of R7 into address of R6 with offset of 1 (Store return address)
		STR 		R5, R6, 0 			; Put value of R5 into address of R6 with no offset (Store old frame pointer)
		ADD 		R5, R6, -1 			; Add -1 to R6 and store in R5 (Create new frame pointer)
		ADD 		R6, R6, -1 			; Subtract 1 from R6 (Make space for local variables)

		AND 		R4, R4, 0 			; And R4 with 0 and store in R4 (clear R4)
		STR 		R4, R5, 0 			; Store R4 in address of R5 with no offset (mem[R5] = R4; store default value of 0 for mid on stack)
		LDR 		R0, R5, 5 			; Load value of R5 with an offset of 5 in R0 (R0 = mem[R5 + 5]; R0 is low)
		LDR 		R1, R5, 6 			; Load value of R6 with an offset of 6 in R1 (R1 = mem[R5 + 6]; R1 is high)
		NOT 		R2, R1 				; Not R1 and store in R2
		ADD 		R2, R2, 1 			; Add 1 to R1 and store in R2 (R2 = -high)
		ADD 		R2, R0, R2 			; Add R0 to R2 and store in R2 (R2 = low - high)
		BRnz 		LESSEQ 				; If low <= high, go to LESSEQ
		
		AND 		R0, R0, 0 			; And R0 with 0 and store in R0 (clear R0)
		ADD 		R0, R0, -1 			; Add -1 to R0 and store in R0 (R0 = return value)
		BR 			RETURN 				; Go to RETURN

LESSEQ 	LDR 		R0, R5, 5 			; Load value of R5 with an offset of 5 in R0 (R0 = mem[R5 + 5]; R0 is low)
		LDR 		R1, R5, 6 			; Load value of R6 with an offset of 6 in R1 (R1 = mem[R5 + 6]; R1 is high)
		ADD 		R0, R0, R1 			; Add R1 to R0 and store in R0
		AND 		R1, R1, 0 			; And R1 with 0 and store in R1 (clear R1)
		ADD 		R1, R1, 2 			; Add 2 to R1 and store in R1 (R1 = 2)
		TRAP 		x80 				; UDIV
		STR 		R0, R5, 0 			; Store value of R0 in R5 with no offset (mem[R5] = R0; updates value of mid)

		LDR 		R1, R5, 4 			; Load value of R5 with an offset of 4 in R1 (mem[R5 + 4] = R1, R1 is ARR_PTR)
		ADD 		R1, R1, R0 			; Add R0 to R1 and store in R1 (R1 = *array[mid])
		LDR 		R0, R1, 0 			; Load value of R1 in R0 (R0 = array[mid])
		LDR 		R2, R5, 7 			; Load value of R5 with an offset of 7 in R2 (mem[R5 + 7] = R2, R2 is X)
		NOT 		R2, R2 				; Negate R2 and store in R2
		ADD 		R2, R2, 1 			; Add 1 to R2 and store in R2 (R2 = -X)
		ADD 		R3, R0, R2 			; Add R0 to R2 and store in R3 (R3 = array[mid] - X)
		
		BRn 		LESS 				; If R3 < 0, go to LESS
		BRp 		GREATER 			; If R3 > 0, go to GREATER

		LDR 		R0, R5, 0 			; Load value of R5 with no offset in R0 (R0 = mem[R5]; R0 = mid)
		BR 			RETURN 				; Go to RETURN

LESS 	LDR 		R0, R5, 7 			; Load value of R5 with an offset of 7 in R0 (R0 = mem[R5 + 7]; R0 = X)
		STR 		R0, R5, -1 			; Store value of R0 in R5 with an offset of -1 (mem[R5 - 1] = R0; store X on the stack)
		LDR 		R0, R5, 6 			; Load value of R5 with an offset of 6 in R0 (R0 = mem[R5 + 6]; R0 = high)
		STR 		R0, R5, -2 			; Store value of R0 in R5 with an offset of -2 (mem[R5 - 2] = R0; store high on the stack)
		LDR 		R0, R5, 0 			; Load value of R5 with no offset in R0 (R0 = mem[R5]; R0 = mid)
		ADD 		R0, R0, 1 			; Add 1 to R0 and store in R0 (R0 = mid + 1)
		STR 		R0, R5, -3 			; Store value of R0 in R5 with an offset of -3 (mem[R5 - 3] = R0; store (mid + 1) on the stack)
		LDR 		R0, R5, 4 			; Load value of R5 with an offset of 4 in R0 (R0 = mem[R5 + 4]; R0 = ARR_PTR)
		STR 		R0, R5, -4 			; Store value of R0 in R5 with an offset of -4 (mem[R5 - 3] = R0; store ARR_PTR on the stack)
		ADD 		R6, R6, -4 			; Add -4 to R6 and sotre in R6 (Update position of stack pointer)
		JSR 		BSEARCH				; Recurse
		BR 			RETURN 				; Go to RETURN

GREATER LDR 		R0, R5, 7 			; Load value of R5 with an offset of 7 in R0 (R0 = mem[R5 + 7]; R0 = X)
		STR 		R0, R5, -1 			; Store value of R0 in R5 with an offset of -1 (mem[R5 - 1] = R0; store X on the stack)
		LDR 		R0, R5, 0 			; Load value of R5 with no offset in R0 (R0 = mem[R5]; R0 = mid)
		ADD 		R0, R0, -1 			; Add -1 to R0 and store in R0 (R0 = mid - 1)
		STR 		R0, R5, -2 			; Store value of R0 in R5 with an offset of -2 (mem[R5 - 2] = R0; store (mid - 1) on the stack)
		LDR 		R0, R5, 5 			; Load value of R5 with an offset of 5 in R0 (R0 = mem[R5 + 5]; R0 = low)
		STR 		R0, R5, -3 			; Store value of R0 in R5 with an offset of -3 (mem[R5 - 3] = R0; store low on the stack)
		LDR 		R0, R5, 4 			; Load value of R5 with an offset of 4 in R0 (R0 = mem[R5 + 4]; R0 = ARR_PTR)
		STR 		R0, R5, -4 			; Store value of R0 in R5 with an offset of -4 (mem[R5 - 3] = R0; store ARR_PTR on the stack)
		ADD 		R6, R6, -4 			; Add -4 to R6 and sotre in R6 (Update position of stack pointer)
		JSR 		BSEARCH				; Recurse
		BR 			RETURN 				; Go to RETURN

RETURN
		STR 		R0, R5, 3			; Store value of R0 in address of R5 with offset of 3 (mem[R5+3] = return value)
		ADD 		R6, R5, 3			; Add 3 to R5 and store in R6 (Point stack pointer to return value)
		LDR 		R7, R5, 2			; Load R5 with an offset of 2 in R7 (Restore return address)
		LDR 		R5, R5, 1			; Load R5 with an offset of 1 in R5 (Load old frame pointer)
		RET
.end

.orig x6000

	.fill -45
	.fill -42
	.fill -30
	.fill -2
	.fill 6
	.fill 15
	.fill 16
	.fill 28
	.fill 51
	.fill 78
	.fill 99
	.fill 178
	.fill 200
	.fill 299
	.fill 491
	.fill 5103

.end

