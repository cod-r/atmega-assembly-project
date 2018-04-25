
.include "m32def.inc"
jmp reset 
jmp reset 
jmp reset 
jmp reset 
jmp reset 
jmp reset 
jmp reset 
jmp reset 
jmp reset 
jmp reset 
jmp reset 
jmp reset 
jmp reset 
jmp receptie 
jmp reset 
jmp reset 
jmp reset 
jmp reset 
jmp reset 
jmp reset 
jmp reset 
reset: 
ldi r16, high (RAMEND) 
out SPH, r16 
ldi r16, low (RAMEND)
out SPL, r16


;pt LCD
ldi r16, 0b11110000
out DDRC, r16			;pinii pc7 ... pc4 sunt de iesire
ldi r16, 0b01000000
out DDRD, r16			;pinul pd6 iesire
ldi r16, 0b00000100
out DDRA, r16			;pinul pa2 iesire
;/pt LCD

main: 
cli 
;configurare UART, 9600 baud rate, 1 bit STOP, paritate para
	ldi r16, 0b10000000 
	out UCSRB, r16 
	ldi r16, 0b10100110 
	out UCSRC, r16 
	ldi r16, 0x00 
	out UBRRH, r16 
	ldi r16, 0x33 
	out UBRRL, r16 
	sbi UCSRB, RXEN      ;activez unitatea de receptie 
;/configurare UART

;configurare LCD
	cbi PORTD, PD6		  ;bitul 7 ia valoarea 0
	cbi PORTA, PA2		  ;bitul 3 ia valoarea 0
	ldi r16, 0b00001000   ;setare timer0:nu se util. pinul OC0, timer oprit deocamdata
	out TCCR0, r16        ;mod CTC cu prag dat de OCR0
	in r16, TIMSK
	andi r16, 0b11111100  ;nu seutiliz nicio intrer., fara a mod alti biti din TIMSK
	out TIMSK, r16	
;/configurare LCD

ldi r18, 0x00  ;contor pentru setare RAM lcd
ldi r19, 0x00  ;alt contor
sei

	call init_display
	ldi r17, 0b10000000
	call set_ram    ;prin r17 se seteaza adresa 0x00 pentru RAM de afisare
	

bucla: 
rjmp bucla 
 
receptie:
in r20, SREG       ;salvez registrul de stare in r20 
	
	inc r18
	in r17, UDR
	call put_char
	

	cpi r18, 0x06        ;scriu primele x caractere pe randul de sus al LCD-ului
	brlo end1
	
	;setez ramul pentru a afisa restul de caractere pe randul 2 al LCD
	inc r19	               ;r19 devine 1
	cpi r19, 0x02          ;
	brsh locatie_fixata    ;daca r19 >= cu 2 atunci sari la locatie_fixata
	ldi r17, 0b11000000    ;nu e mai mare deci setam ramul pentru randul 2
	call set_ram
	;^^^blocul asta se executa doar odata^^^
	
	locatie_fixata:        ;afisez nivelul luminozitatii in aceeasi loc. RAM pe LCD
	cpi r18, 0x14
	brlo end1
	ldi r17, 0b11001110
	call set_ram
	
	end1:

out SREG, r20    ;restaurez registrul de stare 
reti             ;revin din intrerupere



;functii display LCD
init_display:
cbi PORTA, PA2
ldi r16, 0b00100000
out PORTC, r16
sbi PORTD, PD6
call wait_48us
cbi PORTD, PD6

ldi r16, 0b00100000
out PORTC, r16
sbi PORTD, PD6
call wait_48us
cbi PORTD, PD6
ldi r16, 0b10000000
out PORTC, r16
sbi PORTD, PD6
call wait_48us
cbi PORTD, PD6
call wait_30ms

ldi r16, 0b00000000
out PORTC, r16
sbi PORTD, PD6
call wait_48us
cbi PORTD, PD6
ldi r16, 0b11000000
out PORTC, r16
sbi PORTD, PD6
call wait_48us
cbi PORTD, PD6
call wait_30ms

ldi r16, 0b00000000
out PORTC, r16
sbi PORTD, PD6
call wait_48us
cbi PORTD, PD6
ldi r16, 0b00010000
out PORTC, r16
sbi PORTD, PD6
call wait_48us
cbi PORTD, PD6
call wait_30ms

ldi r16, 0b00000000
out PORTC, r16
sbi PORTD, PD6
call wait_48us
cbi PORTD, PD6
ldi r16, 0b00100000
out PORTC, r16
sbi PORTD, PD6
call wait_48us
cbi PORTD, PD6
call wait_30ms
ret

set_ram:
cbi PORTA, PA2   ;crl2=portA,  rs=PA2
mov r16, r17
andi r16, 0xF0   ; retine doar nibble (4biti) superior
out PORTC, r16
sbi PORTD, PD6
nop
nop
cbi PORTD, PD6
mov r16, r17
andi r16, 0x0F    ;se retine doar nibble inferior
swap r16          ;interschimba nibble super cu inferior
out PORTC, r16
sbi PORTD, PD6
nop
nop
cbi PORTD, PD6
call wait_48us
ret

put_char:
sbi PORTA, PA2
mov r16, r17
andi r16, 0xF0
out PORTC, r16
sbi PORTD, PD6
nop
nop
cbi PORTD, PD6
mov r16, r17
andi r16, 0x0F
swap r16
out PORTC, r16
sbi PORTD, PD6
nop
nop
cbi PORTD, PD6
call wait_48us
ret

wait_48us:
ldi r16, 0x00
out TCNT0, r16
ldi r16, 0x06    ;se incarca valoarea de prag
out OCR0, r16    ;6 * 1/(8mhz/64) = 48us
in r16, TCCR0
andi r16, 0b11111000      ;se porneste timerul si este setat sa numere
ori r16, 0b00000011       ;la fiecare 64 perioade de ceas, fara a modifica alti biti
out TCCR0, r16
wait:
in r16, TIFR
sbrs r16, OCF0       ;se asteapta atingerea pragului OCR0
rjmp wait
in r16, TIFR
ori r16, 0b00000010
out TIFR, r16        ;se reseteaza flagul
in r16, TCCR0
andi r16, 0b11111000 ;se opreste timerul
out TCCR0, r16
ret


wait_30ms:
ldi r16, 0x00
out TCNT0, r16
ldi r16, 0xF0     ;se incarca valoarea de praf:0xF0=240
out OCR0, r16     ;240 * 1/(8mhz/10240 ~= 30ms
in r16, TCCR0
andi r16, 0b11111000    ;se porneste timerul si e setat sa numere
ori r16, 0b00000101     ;la fiecare 2014 per. de ceas, fara a modif. alti biti
out TCCR0, r16
wait1:
in r16, TIFR
sbrs r16, OCF0       ;se asteapta atingerea pragului OCR0
rjmp wait1
in r16, TIFR
ori r16, 0b00000010
out TIFR, r16        ;se reseteaza flagul
in r16, TCCR0
andi r16, 0b11111000 ;se opreste timerul
out TCCR0, r16
ret
;terminare functii display LCD
