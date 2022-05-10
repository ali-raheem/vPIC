# vPIC

A work in progress Microchip PIC microcontroller emulator.

Currently emulates the 12F508, all 33 instructions decoded, almost all instructions are emulated but there several important features missing!

Here it is running:
```
MOVLW 170
MOVWF 10
INCF 12, F
SWAPF 12, W
MOVLW 17
MOVWF FSR
INCF INDF, F
BTFSC INDF, 0
INCF INDF, F
INCF INDF, F
GOTO 0
```
Output of running this for 2 loops (first 20 or so operations)
```
ali@peanut:~/Code/vPIC$ v run .
OPCODE: 0b110010101010
PC: 1
W: 170
RAM: [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
OPCODE: 0b000000101010
PC: 2
W: 170
RAM: [0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 170, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
INCF 12, now = 1
OPCODE: 0b001010101100
PC: 3
W: 170
RAM: [0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 170, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
OPCODE: 0b001110101100
PC: 4
W: 170
RAM: [0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 170, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
OPCODE: 0b110000010001
PC: 5
W: 17
RAM: [0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 170, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
OPCODE: 0b000000100100
PC: 6
W: 17
RAM: [0, 0, 6, 0, 17, 0, 0, 0, 0, 0, 170, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
INCF 0, now = 1
OPCODE: 0b001010100000
PC: 7
W: 17
RAM: [0, 0, 7, 0, 17, 0, 0, 0, 0, 0, 170, 0, 16, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0]
OPCODE: 0b011000000000
PC: 8
W: 17
RAM: [0, 0, 8, 0, 17, 0, 0, 0, 0, 0, 170, 0, 16, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0]
INCF 0, now = 2
OPCODE: 0b001010100000
PC: 9
W: 17
RAM: [0, 0, 9, 0, 17, 0, 0, 0, 0, 0, 170, 0, 16, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0]
INCF 0, now = 3
OPCODE: 0b001010100000
PC: 10
W: 17
RAM: [0, 0, 10, 0, 17, 0, 0, 0, 0, 0, 170, 0, 16, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0]
OPCODE: 0b101000000000
PC: 1
W: 17
RAM: [0, 0, 1, 0, 17, 0, 0, 0, 0, 0, 170, 0, 16, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0]
OPCODE: 0b000000101010
PC: 2
W: 17
RAM: [0, 0, 2, 0, 17, 0, 0, 0, 0, 0, 17, 0, 16, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0]
INCF 12, now = 17
OPCODE: 0b001010101100
PC: 3
W: 17
RAM: [0, 0, 3, 0, 17, 0, 0, 0, 0, 0, 17, 0, 17, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0]
OPCODE: 0b001110101100
PC: 4
W: 17
RAM: [0, 0, 4, 0, 17, 0, 0, 0, 0, 0, 17, 0, 17, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0]
OPCODE: 0b110000010001
PC: 5
W: 17
RAM: [0, 0, 5, 0, 17, 0, 0, 0, 0, 0, 17, 0, 17, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0]
OPCODE: 0b000000100100
PC: 6
W: 17
RAM: [0, 0, 6, 0, 17, 0, 0, 0, 0, 0, 17, 0, 17, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0]
INCF 0, now = 4
OPCODE: 0b001010100000
PC: 7
W: 17
RAM: [0, 0, 7, 0, 17, 0, 0, 0, 0, 0, 17, 0, 17, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0]
OPCODE: 0b011000000000
PC: 9
W: 17
RAM: [0, 0, 9, 0, 17, 0, 0, 0, 0, 0, 17, 0, 17, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0]
INCF 0, now = 5
OPCODE: 0b001010100000
PC: 10
W: 17
RAM: [0, 0, 10, 0, 17, 0, 0, 0, 0, 0, 17, 0, 17, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0]
OPCODE: 0b101000000000
PC: 1
W: 17
RAM: [0, 0, 1, 0, 17, 0, 0, 0, 0, 0, 17, 0, 17, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0]
```

## TODO
* All control registers
* Timers (TMR0 and WDT)
* Loads of testing (branches not fully tested)
* GPIO etc not done
