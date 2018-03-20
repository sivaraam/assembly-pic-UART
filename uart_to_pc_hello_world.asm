#include "p16f873a.inc"

; CONFIG
; __config 0xFFBA
 __CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_ON & _CPD_OFF & _WRT_OFF & _CP_OFF

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

MAIN_PROG CODE                      ; let linker place main program

START
    ; see if this is not necessary
    bsf RCSTA, SPEN	; enable uart transmission by enabling serial port
    
    bsf STATUS, RP0	; switch to bank 1 for further config
    ; TRISC bits are set by default so no need to configure for TX and RX
    
    ; configure baud rate to 9.615 kbaud for 20MHz clock
    movlw 0x81
    movwf SPBRG
    bsf TXSTA, BRGH ; set high baud rate

    ; configure TXSTA for async transmission
    bcf TXSTA, SYNC
    
    ; enable transmission
    bsf TXSTA, TXEN
    
    ; make 5th bit of RB5 as input
    ; this is used to enable transmission
    ; bsf TRISB, TRISB5 ; input by default
    
    ; switch back to bank 0 and wait for trigger
    bcf 0x83, RP0

    ; wait for trigger (logic high) in 5th pin of PORTB
trigger_loop
    btfss PORTB, RB5
    goto trigger_loop
    
    ; start transmitting
    movlw 0x48	; 'H'
    call transmit
    
    movlw 0x65	; 'e'
    call transmit
    
    movlw 0x6c	; 'l'
    call transmit
    
    movlw 0x6c	; 'l'
    call transmit
    
    movlw 0x6f	; 'o'
    call transmit
    
    movlw 0x20	; SPACE
    call transmit
    
    movlw 0x77	; 'w'
    call transmit
    
    movlw 0x6f	; 'o'
    call transmit
    
    movlw 0x72	; 'r'
    call transmit
    
    movlw 0x6c	; 'l'
    call transmit
    
    movlw 0x64	; 'd'
    call transmit
    
    movlw 0x21	; '!'
    call transmit
    
    GOTO $

; transmit the value in the working register
transmit
    movwf TXREG
txreg_wait_loop
    ; check that TXREG is empty
    btfss PIR1, TXIF
    goto txreg_wait_loop
    
    bsf STATUS, RP0
tsr_wait_loop
    ; check that TSR is empty
    btfss TXSTA, TRMT
    goto tsr_wait_loop
    bcf 0x83, RP0

    return
    
    END