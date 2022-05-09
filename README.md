# vPIC

A work in progress Microchip PIC microcontroller emulator.

Currently emulates the 12F508, all 33 instructions decoded, almost all instructions are emulated but there several important features missing!

Here it is running:
```
MOVLW 170
MOVWF 10
NOP
NOP
```
Output:
```
ali@peanut:~/Code/vPIC$ v run .
OPCODE: 3242
PC: 1
W: 170
RAM: [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
OPCODE: 42
PC: 2
W: 170
RAM: [0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 170, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
OPCODE: 0
PC: 3
W: 170
RAM: [0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 170, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
OPCODE: 0
PC: 4
W: 170
RAM: [0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 170, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
```

## TODO
* All control registers
* Flags for digit carry and carry
* Timers (TMR0 and WDT)
