
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
jmp reset
jmp reset
jmp reset
jmp gata_conversia
jmp reset
jmp reset
jmp reset
jmp reset
reset:
ldi r16, high(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16

ldi r16, 0xFF
out DDRB, r16 ;port a unde sunt conectate ledurile e de iesire
ldi r17, 0x00
out PORTB, r17 ;sting ledurile

main:
cli
;configuram senzorul de lumina
	ldi r16, 0b00100000 ;setare ADC: AREF este referinta(5v), canal ADC0, adica pinul PA0
	out ADMUX, r16      ;rez se aliniaza la stanga, precizie 8 biti 
	ldi r16, 0b00101111 ;activare intrer., setare ceas ca fosc/128
	out ADCSRA, r16     ;deocamdata nu s-a initiat conversia si nu s-a pornit modulul
	in r16, SFIOR
	andi r16, 0b00011111 ;setarea modului de funct. pe semnal timer 16b prag b
	ori r16, 0b10100000
	out SFIOR, r16
;am terminat configurarea senzorului, rezultatul conversiei se afla in ADCH

;configurare UART
	ldi r16, 0b00001000  ;in randurile de mai jos se configureaza 
	out UCSRB, r16       ;modul USART prin registrii UCSRB si UCSRC
	ldi r16, 0b10100110
	out UCSRC, r16
	ldi r16, 0x00        ;se seteaza viteza de comunicatie
	out UBRRH, r16       ;avand in vedere frecventa ceasului 8mhz
	ldi r16, 0x33
	out UBRRL, r16
;/configurare UART

;setare timere
	ldi r16, 0b00000000
	out TCCR1A, r16      ;mod CTC
	ldi r16, 0b00001000
	out TCCR1B, r16
	in r16, TIMSK
	andi r16, 0b11000011  ;nu se utilizeaza nicio intrerupere
	out TIMSK, r16
	ldi r16, 0x1E         ;se incarca valoarea de prag A: 0x1E85=7813
	out OCR1AH, r16      ;7813 * 1/(8mhz/1024) = 1s
	ldi r16, 0x85
	out OCR1AL, r16
	ldi r16, 0x1E        ;se incarca valoarea de prag b: 0x1E85=7813
	out OCR1BH, r16      ;7813 * 1/(8mhz/1024) = 1s
	ldi r16, 0x85
	out OCR1Bl, r16

	ldi r16, 0b00001000 ;setare timer0: nu se util prin OC0, timer oprit
	out TCCR0, r16       ;mod ctc
	in r16, TIMSK
	andi r16, 0b11111100 ;nu se util nicio intr
	out TIMSK, r16
;/configurare timere



;afisare mesaj
	ldi r16, 0x4E     ;codul ascii pt "N"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

	ldi r16, 0x69     ;codul ascii pt "i"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

	ldi r16, 0x76     ;codul ascii pt "v"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

	ldi r16, 0x65     ;codul ascii pt "e"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

	ldi r16, 0x6C     ;codul ascii pt "l"
	out UDR, r16
	call wait         ;apelez o functie de asteptare
	
	ldi r16, 0x20     ;codul ascii pt " "
	out UDR, r16
	call wait         ;apelez o functie de asteptare

	ldi r16, 0x4C     ;codul ascii pt "L"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

	ldi r16, 0x75     ;codul ascii pt "u"	
	out UDR, r16
	call wait         ;apelez o functie de asteptare

	ldi r16, 0x6D     ;codul ascii pt "m"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

	ldi r16, 0x69     ;codul ascii pt "i"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

	ldi r16, 0x6E     ;codul ascii pt "n"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

	ldi r16, 0x6F     ;codul ascii pt "o"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

	ldi r16, 0x7A     ;codul ascii pt "z"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

	ldi r16, 0x69     ;codul ascii pt "i"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

	ldi r16, 0x74     ;codul ascii pt "t"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

	ldi r16, 0x61     ;codul ascii pt "a"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

	ldi r16, 0x74     ;codul ascii pt "t"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

	ldi r16, 0x65     ;codul ascii pt "e"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

	ldi r16, 0x3A     ;codul ascii pt ":"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

	ldi r16, 0x20     ;codul ascii pt " "
	out UDR, r16
	call wait         ;apelez o functie de asteptare

sei
sbi ADCSRA, ADEN      ;se porneste ADC, bitul ADEN din ADCSRA devine 1
in r16, TCCR1b
andi r16, 0b11111101  ;se porneste timerul 16b
ori r16, 0b00000101
out TCCR1B, r16

bucla:
rjmp bucla


gata_conversia:
in r20, SREG


in r17, ADCH   ;se citeste rez conversiei pe 8 biti
in r16, TIFR
ori r16, 0b00001000  ;se reseteaza flagul timerului 16biti
out TIFR, r16
ldi r16, 0x00
out PORTB, r16	    ;se sting toate ledurile
	
	ldi r16, 0x30     ;codul ascii pt "0"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

cpi r17, 4			;primul nivel de comparatie echiv la 78mV
brlo end
ldi r16, 0x01		;nu e mai mare, deci aprindem doar un led
out PORTB, r16
	
	ldi r16, 0x31     ;codul ascii pt "1"
	out UDR, r16
	call wait         ;apelez o functie de asteptare
	

cpi r17, 16   ;2nd nivel de comparatie echiv la 312V
brlo end
ldi r16, 0x03
out PORTB, r16

	ldi r16, 0x32     ;codul ascii pt "2"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

cpi r17, 24   ;3rd nivel de comparatie echiv la 468mV
brlo end
ldi r16, 0x07
out PORTB, r16

	ldi r16, 0x33     ;codul ascii pt "3"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

cpi r17, 50   ;4th nivel de comparatie echiv la 975mV
brlo end
ldi r16, 0x0F
out PORTB, r16

	ldi r16, 0x34     ;codul ascii pt "4"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

cpi r17, 128  ;5th nivel de comparatie echiv la 2496mV
brlo end
ldi r16, 0x1F
out PORTB, r16

	ldi r16, 0x35     ;codul ascii pt "5"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

cpi r17, 160   ;6th nivel de comparatie echiv la 3120mV
brlo end
ldi r16, 0x3F
out PORTB, r16

	ldi r16, 0x36     ;codul ascii pt "6"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

cpi r17, 192   ;7th nivel de comparatie echiv la 3744mV
brlo end
ldi r16, 0x7F
out PORTB, r16

	ldi r16, 0x37     ;codul ascii pt "7"
	out UDR, r16
	call wait         ;apelez o functie de asteptare

cpi r17, 224   ;8th nivel de comparatie echiv la 4368mV
brlo end
ldi r16, 0xFF
out PORTB, r16

	ldi r16, 0x38     ;codul ascii pt "8"
	out UDR, r16
	call wait         ;apelez o functie de asteptare



end:
out SREG, r20
reti

wait:
in r21, UCSRA     ;citesc starea modulului USART
sbrs r21, UDRE    ;verific daca registrul de emisie/receptie e gol
rjmp wait         ;registrul nu e gol, mai astept
ret               ;registrul e gol, revin din asteptare


