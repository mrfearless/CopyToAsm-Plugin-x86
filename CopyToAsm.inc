;=====================================================================================
; x64dbg plugin SDK For Assembler x86 - fearless
; https://github.com/mrfearless/x64dbg-Plugin-SDK-for-x86-Assembler
;
; CopyToAsm.inc
;
;-------------------------------------------------------------------------------------
include windows.inc
include user32.inc
include kernel32.inc
includelib user32.lib
includelib kernel32.lib

include masm32.inc
includelib masm32.lib


CTALoadMenuIcon                     PROTO :DWORD, :DWORD

DoCopyToAsm                         PROTO :DWORD
CTABuildJmpTable                    PROTO :DWORD, :DWORD
CTAClearJmpTable                    PROTO
CTAAddressInJmpTable                PROTO :DWORD
CTALabelFromJmpEntry                PROTO :DWORD, :DWORD
CTAJmpLabelFromJmpEntry             PROTO :DWORD, :DWORD, :DWORD, :DWORD
CTAOutputLabelsOutsideRangeBefore   PROTO :DWORD, :DWORD
CTAOutputLabelsOutsideRangeAfter    PROTO :DWORD, :DWORD
CTARefViewLabelsOutsideRangeBefore  PROTO :DWORD, :DWORD
CTARefViewLabelsOutsideRangeAfter   PROTO :DWORD, :DWORD

CTAMnemonicToMasmHex                PROTO :DWORD, :DWORD, :DWORD

CTA_AddColumnsToRefView             PROTO :DWORD, :DWORD
CTA_AddRowToRefView                 PROTO :DWORD, :DWORD

Strip_x64dbg_calls                  PROTO :DWORD, :DWORD
Strip_x64dbg_segments               PROTO :DWORD, :DWORD
atou_ex                             PROTO :DWORD
utoa_ex                             PROTO :DWORD, :DWORD


JMPTABLE_ENTRY          STRUCT
    dwAddress           dd 0
JMPTABLE_ENTRY          ENDS



.CONST
CRLF                    TEXTEQU <13,10,0> ; carriage return and linefeed for strings that require them (GuiAddLogMessage for example) 

ICO_COPYTOASM           EQU 99
IMG_COPYTOASM_MAIN      EQU 100 ; PNG image for plugin menu icon
IMG_COPYTOASM_CLPB      EQU 101 ; PNG image for plugin menu icon
IMG_COPYTOASM_REFV      EQU 102 ; PNG image for plugin menu icon

MENU_COPYTOASM_CLPB1    EQU 1
MENU_COPYTOASM_CLPB2    EQU 2
MENU_COPYTOASM_REFV1    EQU 3
MENU_COPYTOASM_REFV2    EQU 4


.DATA
szCopyToAsm             DB "CopyToAsm",0
szCopyToAsmLoaded       DB "CopyToAsm loaded.",CRLF
szCopyToAsmUnloaded     DB "CopyToAsm unloaded.",CRLF
szCopyToAsmMenuClip     DB "Process selected range to clipboard",0
szCopyToAsmMenuRefv     DB "Process selected range to reference view",0
szCopyToAsmInfo         DB 13,10         
                        DB "CopyToAsm x86 x64dbg plugin by fearless 2018 - www.LetTheLight.in",13,10
                        DB 13,10
                        DB "CopyToAsm Features & Usage:",13,10
                        DB " - Copy selected range to masm style assembler code.",13,10  
                        DB " - Outputs assembler code to clipboard or reference view.",13,10
                        DB " - Adds labels for jump destinations.",13,10
                        DB " - Adjusts jump instructions to point to added labels.",13,10
                        DB " - Indicates if jump destinations are outside selection range.",13,10
                        DB " - Code comments to indicate start/end and outside range.",13,10
                        DB " - Removes '0x' from values and appends 'h' for masm style hex values.",13,10
                        DB 13,10,0

szDebuggingRequired     DB "CopyToAsm: you need to be debugging to use this option.",CRLF
szStartCopyToAsm        DB "CopyToAsm: Processing selection, please wait...",CRLF
szFinishCopyToAsm       DB "CopyToAsm: finshed processing information, output is on the clipboard.",CRLF
szFinishCopyToAsmRefView DB "CopyToAsm: finshed processing information, output is in the reference view tab.",CRLF
szErrorMaxEntries       DB "CopyToAsm: error building jump table, maximum entries exceeded. Operation aborted.",CRLF
szErrorAllocMemJmpTable DB "CopyToAsm: error allocating memory for jump table. Operation aborted.",CRLF
szErrorClipboardData    DB "CopyToAsm: error allocating memory for clipboard. Operation aborted.",CRLF

szCommentSelStart       DB 13,10,"; Start of selected range: ",0 ;CRLF
szCommentSelFinish      DB "; Finish of selected range: ",0 ;13,10,13,10
szCommentBeforeRange    DB "; Labels outside selected range (before)",CRLF
szCommentAfterRange     DB 13,10,"; Labels outside selected range (after)",CRLF
szCommentOutsideRange   DB " ; outside range",0

szModBaseHex            DB " - ",0
szModBase               DB " (base 0x",0
szModuleSource          DB "; Source: ",0
szModuleName            DB MAX_PATH DUP (0)
szValueString           DB 32 DUP (0)
szLabelX                DB 32 DUP (0)
szCALLFunction          DB MAX_PATH DUP (0)
szDisasmText            DB GUI_MAX_DISASSEMBLY_SIZE DUP (0)
szFormattedDisasmText   DB GUI_MAX_DISASSEMBLY_SIZE DUP (0)


szRefCopyToAsm          DB "CopyToAsm: ",0
szRefAsmCode            DB "Assembly Code",0
szRefHdrMsg             DB MAX_PATH DUP (0)




szNull                  DB 0,0
szPlus                  DB "+",0
szMinus                 DB "-",0
szMnemStarOnePlus       DB "*1+",0
szMnemStarOneMinus      DB "*1-",0
szMasmHexH              DB "h",0
szHex                   DB "0x",0
szCRLF                  DB 13,10,0
szColon                 DB ":",0
szSpace                 DB " ",0
szLabel                 DB "LABEL_",0
szCall                  DB "call ",0
szOffsetLeftBracket     DB " (",0
szRightBracket          DB ")",0 
szCmntStart             DB " ; 0x",0

ModBase                 DD 0

CLIPDATASIZE            DD 0

JMPTABLE_ENTRIES_MAX    DD 0
JMPTABLE_ENTRIES_TOTAL  DD 0
JMPTABLE                DD 0 ; pointer to array of JMPTABLE_ENTRIES



.DATA?
hInstance               DD ?

