# vPIC

A work in progress Microchip PIC microcontroller emulator.

Currently emulates the 12F508, all 33 instructions decoded, almost all instructions are emulated but there several important features missing!

Here it is running:
```
MOVLW 1
MOVWF 10
MOVWF 11
MOVF 10, W
ADDWF 11, W
MOVWF 12
MOVF 11, W
MOVWF 10
MOVF 12, W
GOTO 1
```
After 87 cycles the state is (generating the fibbonachi sequence)
```
ali@peanut:~/Code/vPIC$ v run . --bin fib.bin -c 87
OPCODE: 0b000000101100
PC: 6
W: 233
RAM: [0, 87, 6, 49, 224, 254, 0, 0, 0, 0, 89, 144, 233, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
```

## TODO
* Config word
* External TMR0, WDT if ever
* Loads of testing (branches not fully tested)
* GPIO etc not done
