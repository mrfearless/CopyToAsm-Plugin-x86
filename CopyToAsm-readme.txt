;=====================================================================================
;
; CopyToAsm-readme.txt
;
; v1.0.0.7 - Last updated 05/03/2018
;
;-------------------------------------------------------------------------------------


About
-----

CopyToAsm Plugin (x86) For x64dbg (32bit plugin)
by fearless - www.LetTheLight.in

Created with the x64dbg Plugin SDK For x86 Assembler
https://github.com/mrfearless/x64dbg-Plugin-SDK-For-x86-Assembler


Overview
--------

A plugin to copy a selected disassembly range in the x64dbg cpu view tab and convert to
a masm compatible style assembler code and output to clipboard or the reference view tab.


Features
--------

- Copy selected range to assembler style code.
- Outputs assembler code to clipboard or reference view.
- Adds labels for jump destinations.
- Adjusts jump instructions to point to added labels.
- Indicates if jump destinations are outside selection range.
- Code comments to indicate start/end and outside range.
- Options to adjust comments and label outputs.
- Format hex values as C style (0x) or Masm style.
- Registered commands: ctac/ctar


Notes
-----

- 29/01/2018 first release
- 03/02/2018 v1.0.0.1
- 07/02/2018 v1.0.0.2
- 09/02/2018 v1.0.0.3 - added call labels
- 02/03/2018 v1.0.0.4 - added c style/masm style hex values formatting
- 02/03/2018 v1.0.0.5 - added options dialog and registered commands
- 03/03/2018 v1.0.0.6 - call labels adjustments and _ prefix for hex only names
- 05/03/2018 v1.0.0.7 - add check for fastcall functions starting with '@'






