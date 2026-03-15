# Practical Vim
PS: as a vim user, only partial skills will be written
---
|mode|trick|description|
|---|---|---|
normal|\.| repeated lastest operation
normal|\>G|indent each line after current line
normal|\* |match current word that cursor pointed at in the whole file
insert|\<C-u>|delete until cursor at the front of the line
command|\:t|copy current line to specific line
command|\:m|move current line to specific line
normal|ea|add in the end of current line
normal|m{letter}|mark current posistion with letter
normal|'{letter}|jump to posistion marked with letter 
## Macro
use q{register} to record operation until q key is entered again, use @{register} to use the command set recoreded in the register