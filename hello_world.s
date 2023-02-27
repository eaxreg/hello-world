;---------------------------------------;
; hello_world.s                         ;
; copyright 2023-2-28 eax (eaxreg)
;---------------------------------------;
; prints "Hello, World!" and exits
;                                       ;
;--[ How to execute ]-------------------;
; compile with                          ;
;                                       ;
; $> uasm -elf hello_world.s            ; compile as 32-bit code
; $> ld -m elf_i386 -o hw hello_world.o ; link as 32-bit executable
; $> ./hw                               ;
;---------------------------------------;

.686                                    ; specify cpu model, pentium pro
.model flat                             ; specify memory model: linux, windows, as well as most modern OSes use a flat model

;---------------------------------------;
; the processor divides the code into different segments.
; while loading the executable, the kernel will load different "segments" of the binary code into different memory segments
;---------------------------------------;

data SEGMENT                            ; "data" is a segment reserved for RO memory, normally contains data allocated by the program
    ; string to print                   ;
    text DB "Hello, World!", 0AH        ; 0AH = ascii 'newline'
    ; calculate length of the string    ;
    stringLen EQU $ - text              ; macro-constant, won't appear in the binary file
data ENDS

code SEGMENT                            ; "code" is used as segment for executable memory, it is read-only, contains processor instructions and their immediate operands

_start PROC                             ; by default, ld will start execution at the _start label

    ;--------[print the string]---------;
    ; we are using "system calls" which are a way of giving back control to the kernel
    ; we pass arguments to the kernel through the registers.
    ;-----------------------------------;
    MOV eax, 4                          ; eax = function number, 4 for sys_write
    MOV ebx, 1                          ; ebx = file handle, 1 for stdout
    MOV ecx, OFFSET data:text           ; ecx = pointer to string buffer, offset gets the memory address of the variable, since it is in another segment we need to specify that
    MOV edx, stringLen                  ; edx = string length
    INT 80h                             ; all linux-syscalls are triggered with interrupt 80H
    
    ;--------- [exit program]-----------;
    MOV eax, 1                          ; eax = function number, sys_exit
    MOV ebx, 0                          ; ebx = exit code, 0 for successful execution
    INT 80h                             ; trigger interrupt 80H

    ;--------------[DONE]---------------;
    ; this line will only be reached if sys_exit is fault
    ; in this case, the cpu will continue reading the memory ahead of the program if it was normal "executabe" memory
    ; once the cpu runs out of bounds of the allocated segmemts it will raise a SIGSEV signal (memory out of bounds, segmentation fault)
    ;-----------------------------------;
_start ENDP                             ;
code ENDS                               ;
END                                     ; end of file
