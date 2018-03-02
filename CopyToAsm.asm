;=====================================================================================
; x64dbg plugin SDK for Masm - fearless 2016 - www.LetTheLight.in
;
; CopyToAsm.asm
;
;-------------------------------------------------------------------------------------

.686
.MMX
.XMM
.model flat,stdcall
option casemap:none

;DEBUG32 EQU 1

IFDEF DEBUG32
    PRESERVEXMMREGS equ 1
    includelib M:\Masm32\lib\Debug32.lib
    DBG32LIB equ 1
    DEBUGEXE textequ <'M:\Masm32\DbgWin.exe'>
    include M:\Masm32\include\debug32.inc
ENDIF

Include x64dbgpluginsdk.inc               ; Main x64dbg Plugin SDK for your program, and prototypes for the main exports 

include x64dbgpluginsdk_x86.inc
includelib x64dbgpluginsdk_x86.lib

Include CopyToAsm.inc ; plugin's include file

Include CopyToAsmIni.asm

;=====================================================================================


.CONST
PLUGIN_VERSION      EQU 1

.DATA
PLUGIN_NAME         DB "CopyToAsm x86",0

.DATA?
;-------------------------------------------------------------------------------------
; GLOBAL Plugin SDK variables
;-------------------------------------------------------------------------------------
PUBLIC              pluginHandle
PUBLIC              hwndDlg
PUBLIC              hMenu
PUBLIC              hMenuDisasm
PUBLIC              hMenuDump
PUBLIC              hMenuStack

pluginHandle        DD ?
hwndDlg             DD ?
hMenu               DD ?
hMenuDisasm         DD ?
hMenuDump           DD ?
hMenuStack          DD ?
hMenuOptions        DD ?
;-------------------------------------------------------------------------------------


.CODE

;=====================================================================================
; Main entry function for a DLL file  - required.
;-------------------------------------------------------------------------------------
DllMain PROC hinstDLL:HINSTANCE, fdwReason:DWORD, lpvReserved:DWORD
    .IF fdwReason == DLL_PROCESS_ATTACH
        mov eax, hinstDLL
        mov hInstance, eax
    .ENDIF
    mov eax,TRUE
    ret
DllMain ENDP


;=====================================================================================
; pluginit - Called by debugger when plugin.dp32 is loaded - needs to be EXPORTED
; 
; Arguments: initStruct - a pointer to a PLUG_INITSTRUCT structure
;
; Notes:     you must fill in the pluginVersion, sdkVersion and pluginName members. 
;            The pluginHandle is obtained from the same structure - it may be needed in
;            other function calls.
;
;            you can call your own setup routine from within this function to setup 
;            menus and commands, and pass the initStruct parameter to this function.
;
;-------------------------------------------------------------------------------------
pluginit PROC C PUBLIC USES EBX initStruct:DWORD
    mov ebx, initStruct

    ; Fill in required information of initStruct, which is a pointer to a PLUG_INITSTRUCT structure
    mov eax, PLUGIN_VERSION
    mov [ebx].PLUG_INITSTRUCT.pluginVersion, eax
    mov eax, PLUG_SDKVERSION
    mov [ebx].PLUG_INITSTRUCT.sdkVersion, eax
    Invoke lstrcpy, Addr [ebx].PLUG_INITSTRUCT.pluginName, Addr PLUGIN_NAME
    
    mov ebx, initStruct
    mov eax, [ebx].PLUG_INITSTRUCT.pluginHandle
    mov pluginHandle, eax
    
    ; Do any other initialization here

    ; Construct plugin's .ini file from module filename
    Invoke GetModuleFileName, 0, Addr szModuleFilename, SIZEOF szModuleFilename
    Invoke GetModuleFileName, hInstance, Addr CopyToAsmIni, SIZEOF CopyToAsmIni
    Invoke szLen, Addr CopyToAsmIni
    lea ebx, CopyToAsmIni
    add ebx, eax
    sub ebx, 4 ; move back past 'dp32' extention
    mov byte ptr [ebx], 0 ; null so we can use lstrcat
    Invoke szCatStr, ebx, Addr szIni ; add 'ini' to end of string instead     

	mov eax, TRUE
	ret
pluginit ENDP


;=====================================================================================
; plugstop - Called by debugger when the plugin.dp32 is unloaded - needs to be EXPORTED
;
; Arguments: none
; 
; Notes:     perform cleanup operations here, clearing menus and other housekeeping
;
;-------------------------------------------------------------------------------------
plugstop PROC C PUBLIC 
    
    ; remove any menus, unregister any callbacks etc
    Invoke _plugin_menuclear, hMenu
    Invoke GuiAddLogMessage, Addr szCopyToAsmUnloaded
    
    mov eax, TRUE
    ret
plugstop ENDP


;=====================================================================================
; plugsetup - Called by debugger to initialize your plugins setup - needs to be EXPORTED
;
; Arguments: setupStruct - a pointer to a PLUG_SETUPSTRUCT structure
; 
; Notes:     setupStruct contains useful handles for use within x64dbg, mainly Qt 
;            menu handles (which are not supported with win32 api) and the main window
;            handle with this information you can add your own menus and menu items 
;            to an existing menu, or one of the predefined supported right click 
;            context menus: hMenuDisam, hMenuDump & hMenuStack
;            
;            plugsetup is called after pluginit. 
;-------------------------------------------------------------------------------------
plugsetup PROC C PUBLIC USES EBX setupStruct:DWORD
    LOCAL hIconData:ICONDATA
    LOCAL hIconDataOptions:ICONDATA
    mov ebx, setupStruct

    ; Extract handles from setupStruct which is a pointer to a PLUG_SETUPSTRUCT structure  
    mov eax, [ebx].PLUG_SETUPSTRUCT.hwndDlg
    mov hwndDlg, eax
    mov eax, [ebx].PLUG_SETUPSTRUCT.hMenu
    mov hMenu, eax
    mov eax, [ebx].PLUG_SETUPSTRUCT.hMenuDisasm
    mov hMenuDisasm, eax
    mov eax, [ebx].PLUG_SETUPSTRUCT.hMenuDump
    mov hMenuDump, eax
    mov eax, [ebx].PLUG_SETUPSTRUCT.hMenuStack
    mov hMenuStack, eax
    
    ; Do any setup here: add menus, menu items, callback and commands etc

    Invoke _plugin_menuaddentry, hMenu, MENU_COPYTOASM_CLPB1, Addr szCopyToAsmMenuClip    
    Invoke _plugin_menuaddentry, hMenu, MENU_COPYTOASM_REFV1, Addr szCopyToAsmMenuRefv
    Invoke _plugin_menuaddseparator, hMenu
    Invoke _plugin_menuadd, hMenu, Addr szCTACommentOptions
    mov hMenuOptions, eax    
    ;Invoke _plugin_menuaddentry, hMenu, MENU_COPYTOASM_FMT1, Addr szCopyToAsmFormat
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTARANGELABELS1, Addr szCTAOutsideRangeLabels
    Invoke _plugin_menuaddseparator, hMenuOptions
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTACMTRANGE1, Addr szCTACmntOutsideRange
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTACMTJMPDEST1, Addr szCTACmntJmpDest
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTACMTCALLDEST1, Addr szCTACmntCallDest
    Invoke _plugin_menuaddseparator, hMenuOptions
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTALBLUSEADDRESS1, Addr szCTALblsUseAddress
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTALBLUSELABEL1, Addr szCTALblsUseLabel
    Invoke _plugin_menuaddseparator, hMenuOptions
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_COPYTOASM_FMT1, Addr szCopyToAsmFormat    
    Invoke CTALoadMenuIcon, IMG_MENU_OPTIONS, Addr hIconDataOptions
    Invoke _plugin_menuseticon, hMenuOptions, Addr hIconDataOptions

    Invoke _plugin_menuaddentry, hMenuDisasm, MENU_COPYTOASM_CLPB2, Addr szCopyToAsmMenuClip
    Invoke _plugin_menuaddentry, hMenuDisasm, MENU_COPYTOASM_REFV2, Addr szCopyToAsmMenuRefv
    Invoke _plugin_menuaddseparator, hMenuDisasm
    Invoke _plugin_menuadd, hMenuDisasm, Addr szCTACommentOptions
    mov hMenuOptions, eax
    ;Invoke _plugin_menuaddentry, hMenuDisasm, MENU_COPYTOASM_FMT2, Addr szCopyToAsmFormat
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTARANGELABELS2, Addr szCTAOutsideRangeLabels
    Invoke _plugin_menuaddseparator, hMenuOptions
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTACMTRANGE2, Addr szCTACmntOutsideRange
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTACMTJMPDEST2, Addr szCTACmntJmpDest
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTACMTCALLDEST2, Addr szCTACmntCallDest
    Invoke _plugin_menuaddseparator, hMenuOptions
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTALBLUSEADDRESS2, Addr szCTALblsUseAddress
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_CTALBLUSELABEL2, Addr szCTALblsUseLabel
    Invoke _plugin_menuaddseparator, hMenuOptions
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_COPYTOASM_FMT2, Addr szCopyToAsmFormat
    Invoke _plugin_menuseticon, hMenuOptions, Addr hIconDataOptions

    Invoke CTALoadMenuIcon, IMG_COPYTOASM_MAIN, Addr hIconData
    .IF eax == TRUE
        Invoke _plugin_menuseticon, hMenu, Addr hIconData
        Invoke _plugin_menuseticon, hMenuDisasm, Addr hIconData
    .ENDIF

    Invoke CTALoadMenuIcon, IMG_COPYTOASM_CLPB, Addr hIconData
    .IF eax == TRUE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_CLPB1, Addr hIconData
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_CLPB2, Addr hIconData
    .ENDIF
    
    Invoke CTALoadMenuIcon, IMG_COPYTOASM_REFV, Addr hIconData
    .IF eax == TRUE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_REFV1, Addr hIconData
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_REFV2, Addr hIconData
    .ENDIF

    Invoke CTALoadMenuIcon, IMG_MENU_CHECK, Addr hImgCheck
    Invoke CTALoadMenuIcon, IMG_MENU_NOCHECK, Addr hImgNoCheck
    
    Invoke IniGetOutsideRangeLabels
    mov g_OutsideRangeLabels, eax
    .IF eax == 1
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTARANGELABELS1, Addr hImgCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTARANGELABELS2, Addr hImgCheck
    .ELSE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTARANGELABELS1, Addr hImgNoCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTARANGELABELS2, Addr hImgNoCheck
    .ENDIF
    
    Invoke IniGetCmntOutsideRange
    mov g_CmntOutsideRange, eax
    .IF eax == 1
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTRANGE1, Addr hImgCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTRANGE2, Addr hImgCheck
    .ELSE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTRANGE1, Addr hImgNoCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTRANGE2, Addr hImgNoCheck
    .ENDIF
    
    Invoke IniGetCmntJumpDest
    mov g_CmntJumpDest, eax
    .IF eax == 1
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTJMPDEST1, Addr hImgCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTJMPDEST2, Addr hImgCheck
    .ELSE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTJMPDEST1, Addr hImgNoCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTJMPDEST2, Addr hImgNoCheck
    .ENDIF
    
    Invoke IniGetCmntCallDest
    mov g_CmntCallDest, eax
    .IF eax == 1
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTCALLDEST1, Addr hImgCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTCALLDEST2, Addr hImgCheck
    .ELSE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTCALLDEST1, Addr hImgNoCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTCALLDEST2, Addr hImgNoCheck
    .ENDIF    

    Invoke IniGetLblUseAddress
    mov g_LblUseAddress, eax
    .IF eax == 1
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTALBLUSEADDRESS1, Addr hImgCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTALBLUSEADDRESS2, Addr hImgCheck
    .ELSE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTALBLUSEADDRESS1, Addr hImgNoCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTALBLUSEADDRESS2, Addr hImgNoCheck
    .ENDIF   

    Invoke IniGetLblUseLabel
    mov g_LblUseLabel, eax
    .IF eax == 1
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTALBLUSELABEL1, Addr hImgCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTALBLUSELABEL2, Addr hImgCheck
    .ELSE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTALBLUSELABEL1, Addr hImgNoCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTALBLUSELABEL2, Addr hImgNoCheck
    .ENDIF       
    
    Invoke IniGetFormatType
    mov g_FormatType, eax
    .IF eax == 1
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_FMT1, Addr hImgCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_FMT2, Addr hImgCheck
    .ELSE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_FMT1, Addr hImgNoCheck
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_FMT2, Addr hImgNoCheck
    .ENDIF   



    Invoke GuiAddLogMessage, Addr szCopyToAsmInfo
    Invoke GuiGetWindowHandle
    mov hwndDlg, eax   
        
    ret
plugsetup ENDP


;=====================================================================================
; CBMENUENTRY - Called by debugger when a menu item is clicked - needs to be EXPORTED
;
; Arguments: cbType
;            cbInfo - a pointer to a PLUG_CB_MENUENTRY structure. The hEntry contains 
;            the resource id of menu item identifiers
;  
; Notes:     hEntry can be used to determine if the user has clicked on your plugins
;            menu item(s) and to do something in response to it.
;            Needs to be PROC C type procedure call to be compatible with debugger
;-------------------------------------------------------------------------------------
CBMENUENTRY PROC C PUBLIC USES EBX cbType:DWORD, cbInfo:DWORD
    mov ebx, cbInfo
    mov eax, [ebx].PLUG_CB_MENUENTRY.hEntry
    
    .IF eax == MENU_COPYTOASM_CLPB1 || eax == MENU_COPYTOASM_CLPB2
       Invoke DbgIsDebugging
        .IF eax == FALSE
            Invoke GuiAddStatusBarMessage, Addr szDebuggingRequired
            Invoke GuiAddLogMessage, Addr szDebuggingRequired
        .ELSE
            Invoke DoCopyToAsm, 0 ; clipboard
        .ENDIF
        
    .ELSEIF eax == MENU_COPYTOASM_REFV1 || eax == MENU_COPYTOASM_REFV2
       Invoke DbgIsDebugging
        .IF eax == FALSE
            Invoke GuiAddStatusBarMessage, Addr szDebuggingRequired
            Invoke GuiAddLogMessage, Addr szDebuggingRequired
        .ELSE
            Invoke DoCopyToAsm, 1 ; refview
        .ENDIF
    
    .ELSEIF eax == MENU_COPYTOASM_FMT1 || eax == MENU_COPYTOASM_FMT2

        mov eax, g_FormatType
        .IF eax == 1
            mov g_FormatType, 0
            Invoke IniSetFormatType, 0
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_FMT1, Addr hImgNoCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_FMT2, Addr hImgNoCheck
        .ELSE
            mov g_FormatType, 1
            Invoke IniSetFormatType, 1
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_FMT1, Addr hImgCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_COPYTOASM_FMT2, Addr hImgCheck
        .ENDIF

    .ELSEIF eax == MENU_CTARANGELABELS1 || eax == MENU_CTARANGELABELS2

        mov eax, g_OutsideRangeLabels
        .IF eax == 1
            mov g_OutsideRangeLabels, 0
            Invoke IniSetOutsideRangeLabels, 0
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTARANGELABELS1, Addr hImgNoCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTARANGELABELS2, Addr hImgNoCheck
        .ELSE
            mov g_OutsideRangeLabels, 1
            Invoke IniSetOutsideRangeLabels, 1
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTARANGELABELS1, Addr hImgCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTARANGELABELS2, Addr hImgCheck
        .ENDIF

    .ELSEIF eax == MENU_CTACMTRANGE1 || eax == MENU_CTACMTRANGE2

        mov eax, g_CmntOutsideRange
        .IF eax == 1
            mov g_CmntOutsideRange, 0
            Invoke IniSetCmntOutsideRange, 0
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTRANGE1, Addr hImgNoCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTRANGE2, Addr hImgNoCheck
        .ELSE
            mov g_CmntOutsideRange, 1
            Invoke IniSetCmntOutsideRange, 1
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTRANGE1, Addr hImgCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTRANGE2, Addr hImgCheck
        .ENDIF

    .ELSEIF eax == MENU_CTACMTJMPDEST1 || eax == MENU_CTACMTJMPDEST2

        mov eax, g_CmntJumpDest
        .IF eax == 1
            mov g_CmntJumpDest, 0
            Invoke IniSetCmntJumpDest, 0
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTJMPDEST1, Addr hImgNoCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTJMPDEST2, Addr hImgNoCheck
        .ELSE
            mov g_CmntJumpDest, 1
            Invoke IniSetCmntJumpDest, 1
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTJMPDEST1, Addr hImgCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTJMPDEST2, Addr hImgCheck
        .ENDIF

    .ELSEIF eax == MENU_CTACMTCALLDEST1 || eax == MENU_CTACMTCALLDEST2

        mov eax, g_CmntCallDest
        .IF eax == 1
            mov g_CmntCallDest, 0
            Invoke IniSetCmntCallDest, 0
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTCALLDEST1, Addr hImgNoCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTCALLDEST2, Addr hImgNoCheck
        .ELSE
            mov g_CmntCallDest, 1
            Invoke IniSetCmntCallDest, 1
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTCALLDEST1, Addr hImgCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTACMTCALLDEST2, Addr hImgCheck
        .ENDIF


    .ELSEIF eax == MENU_CTALBLUSEADDRESS1 || eax == MENU_CTALBLUSEADDRESS2
        mov eax, g_LblUseAddress
        .IF eax == 1
            mov g_LblUseAddress, 0
            Invoke IniSetLblUseAddress, 0
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTALBLUSEADDRESS1, Addr hImgNoCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTALBLUSEADDRESS2, Addr hImgNoCheck
        .ELSE
            mov g_LblUseAddress, 1
            Invoke IniSetLblUseAddress, 1
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTALBLUSEADDRESS1, Addr hImgCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTALBLUSEADDRESS2, Addr hImgCheck
        .ENDIF
        
    .ELSEIF eax == MENU_CTALBLUSELABEL1 || eax == MENU_CTALBLUSELABEL2

        mov eax, g_LblUseLabel
        .IF eax == 1
            mov g_LblUseLabel, 0
            Invoke IniSetLblUseLabel, 0
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTALBLUSELABEL1, Addr hImgNoCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTALBLUSELABEL2, Addr hImgNoCheck
        .ELSE
            mov g_LblUseLabel, 1
            Invoke IniSetLblUseLabel, 1
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTALBLUSELABEL1, Addr hImgCheck
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_CTALBLUSELABEL2, Addr hImgCheck
        .ENDIF

    .ENDIF
    
    mov eax, TRUE
    ret

CBMENUENTRY ENDP


;=====================================================================================
; CTALoadMenuIcon - Loads RT_RCDATA png resource and assigns it to ICONDATA
; Returns TRUE in eax if succesful or FALSE otherwise.
;-------------------------------------------------------------------------------------
CTALoadMenuIcon PROC USES EBX dwImageResourceID:DWORD, lpIconData:DWORD
    LOCAL hRes:DWORD
    
    ; Load image for our menu item
    Invoke FindResource, hInstance, dwImageResourceID, RT_RCDATA ; load png image as raw data
    .IF eax != NULL
        mov hRes, eax
        Invoke SizeofResource, hInstance, hRes
        .IF eax != 0
            mov ebx, lpIconData
            mov [ebx].ICONDATA.size_, eax
            Invoke LoadResource, hInstance, hRes
            .IF eax != NULL
                Invoke LockResource, eax
                .IF eax != NULL
                    mov ebx, lpIconData
                    mov [ebx].ICONDATA.data, eax
                    mov eax, TRUE
                .ELSE
                    ;PrintText 'Failed to lock resource'
                    mov eax, FALSE
                .ENDIF
            .ELSE
                ;PrintText 'Failed to load resource'
                mov eax, FALSE
            .ENDIF
        .ELSE
            ;PrintText 'Failed to get resource size'
            mov eax, FALSE
        .ENDIF
    .ELSE
        ;PrintText 'Failed to find resource'
        mov eax, FALSE
    .ENDIF    
    ret

CTALoadMenuIcon ENDP


;-------------------------------------------------------------------------------------
; Copies selected disassembly range to clipboard and formats as masm style code
; fixes jmps and labels relative to each other, removes segments and 0x from instructions
;-------------------------------------------------------------------------------------
DoCopyToAsm PROC USES EBX ECX dwOutput:DWORD
    LOCAL bii:BASIC_INSTRUCTION_INFO ; basic 
    LOCAL cbii:BASIC_INSTRUCTION_INFO ; call destination
    LOCAL sel:SELECTIONDATA
    LOCAL sellength:DWORD
    LOCAL dwStartAddress:DWORD
    LOCAL dwFinishAddress:DWORD
    LOCAL dwCurrentAddress:DWORD
    LOCAL JmpDestination:DWORD
    LOCAL CallDestination:DWORD
    LOCAL ptrClipboardData:DWORD
    LOCAL LenClipData:DWORD
    LOCAL pClipData:DWORD
    LOCAL hClipData:DWORD
    LOCAL bOutsideRange:DWORD
    LOCAL dwCTALIndex:DWORD
    
    
    Invoke DbgIsDebugging
    .IF eax == FALSE
        Invoke GuiAddLogMessage, Addr szDebuggingRequired
        ret
    .ENDIF
    Invoke GuiAddStatusBarMessage, Addr szStartCopyToAsm


    ;----------------------------------
    ; Get selection information
    ;----------------------------------
    Invoke GuiSelectionGet, GUI_DISASSEMBLY, Addr sel
    mov eax, sel.finish
    mov dwFinishAddress, eax
    mov ebx, sel.start
    mov dwStartAddress, ebx
    sub eax, ebx
    mov sellength, eax
    mov dwCTALIndex, 0

    ;----------------------------------
    ; Get some info for user
    ;----------------------------------
    Invoke ModNameFromAddr, sel.start, Addr szModuleName, TRUE
    Invoke ModNameFromAddr, sel.start, Addr szModuleNameStrip, FALSE
    Invoke szCatStr, Addr szModuleNameStrip, Addr szDot
    Invoke ModBaseFromAddr, sel.start
    mov ModBase, eax


    ;----------------------------------
    ; 1st pass build jmp destination array
    ;----------------------------------
    Invoke CTABuildJmpTable, dwStartAddress, dwFinishAddress
    .IF eax == FALSE
        ret
    .ENDIF

    ;----------------------------------
    ; 2nd pass build call destination array
    ;----------------------------------
    Invoke CTABuildCallTable, dwStartAddress, dwFinishAddress
    .IF eax == FALSE
        ret
    .ENDIF


    .IF dwOutput == 0 ; clipboard
        ;----------------------------------
        ; Alloc space for clipboard data
        ;----------------------------------
        .IF CLIPDATASIZE != 0
            Invoke szLen, Addr szModuleName
            add eax, 64d; "; Source: "+CRLF + CRLF + (base 0x12345678 - 12345678)
            add CLIPDATASIZE, eax
    
            Invoke GlobalAlloc, GMEM_FIXED + GMEM_ZEROINIT, CLIPDATASIZE
            .IF eax == NULL
                Invoke GuiAddStatusBarMessage, Addr szErrorClipboardData
                mov eax, FALSE
                ret
            .ENDIF
            mov ptrClipboardData, eax    
            Invoke OpenClipboard, 0
            .IF eax == 0
                Invoke GlobalFree, ptrClipboardData
                Invoke GuiAddStatusBarMessage, Addr szErrorClipboardData
                mov eax, FALSE
                ret
            .ENDIF
            Invoke EmptyClipboard
        .ELSE
            Invoke GuiAddStatusBarMessage, Addr szErrorClipboardData
        .ENDIF
    
    
        ;----------------------------------
        ; Start : Module Name and Base
        ;----------------------------------
        Invoke szCatStr, ptrClipboardData, Addr szModuleSource
        Invoke szCatStr, ptrClipboardData, Addr szModuleName
        Invoke dw2hex, ModBase, Addr szValueString
        Invoke szCatStr, ptrClipboardData, Addr szModBase
        Invoke szCatStr, ptrClipboardData, Addr szValueString
        Invoke utoa_ex, ModBase, Addr szValueString
        Invoke szCatStr, ptrClipboardData, Addr szModBaseHex
        Invoke szCatStr, ptrClipboardData, Addr szValueString
        Invoke szCatStr, ptrClipboardData, Addr szRightBracket
        Invoke szCatStr, ptrClipboardData, Addr szCRLF
        Invoke szCatStr, ptrClipboardData, Addr szCRLF
    
        .IF g_OutsideRangeLabels == 1
            ;----------------------------------
            ; Labels Before
            ;----------------------------------
            Invoke CTAOutputLabelsOutsideRangeBefore, dwStartAddress, ptrClipboardData
            Invoke CTAOutputCallLabelsOutsideRangeBefore, dwStartAddress, ptrClipboardData
        .ENDIF
    
        ;----------------------------------
        ; Start Information
        ;----------------------------------
        Invoke szCatStr, ptrClipboardData, Addr szCommentSelStart
        Invoke dw2hex, dwStartAddress, Addr szValueString
        Invoke szCatStr, ptrClipboardData, Addr szHex
        Invoke szCatStr, ptrClipboardData, Addr szValueString
        ;Invoke szCatStr, ptrClipboardData, Addr szOffsetLeftBracket
        ;Invoke utoa_ex, dwStartAddress, Addr szValueString
        ;Invoke szCatStr, ptrClipboardData, Addr szValueString
        ;Invoke szCatStr, ptrClipboardData, Addr szRightBracket
        Invoke szCatStr, ptrClipboardData, Addr szCRLF
        
    .ELSE ; output to reference view

        Invoke CTA_AddColumnsToRefView, dwStartAddress, dwFinishAddress
        
        .IF g_OutsideRangeLabels == 1
            ;----------------------------------
            ; Labels Before
            ;----------------------------------        
            Invoke CTARefViewLabelsOutsideRangeBefore, dwStartAddress, dwCTALIndex
            mov dwCTALIndex, eax
            Invoke CTARefViewCallLabelsOutsideRangeBefore, dwStartAddress, dwCTALIndex
            mov dwCTALIndex, eax
        .ENDIF

    .ENDIF


    ;----------------------------------
    ; Start main loop processing selection
    ;----------------------------------
    mov eax, dwStartAddress
    mov dwCurrentAddress, eax
    .WHILE eax <= dwFinishAddress
        
        ; Check instruction is in our jmp table as a destination for a jump, if so insert a label
        Invoke CTAAddressInJmpTable, dwCurrentAddress
        .IF eax != 0
            Invoke CTALabelFromJmpEntry, eax, dwCurrentAddress, Addr szLabelX
            .IF dwOutput == 0 ; output to clipboard
                Invoke szCatStr, ptrClipboardData, Addr szCRLF
                Invoke szCatStr, ptrClipboardData, Addr szLabelX
                Invoke szCatStr, ptrClipboardData, Addr szCRLF
            .ELSE ; output to reference view
                Invoke CTA_AddRowToRefView, dwCTALIndex, Addr szLabelX
                inc dwCTALIndex
            .ENDIF
        .ENDIF
        
        ; Check instruction is in our call table as a destination for a call, if so insert a label
        Invoke CTAAddressInCallTable, dwCurrentAddress
        .IF eax != 0
            Invoke CTALabelFromCallEntry, eax, Addr szLabelX
            .IF dwOutput == 0 ; output to clipboard
                Invoke szCatStr, ptrClipboardData, Addr szCRLF
                Invoke szCatStr, ptrClipboardData, Addr szLabelX
                Invoke szCatStr, ptrClipboardData, Addr szCRLF
            .ELSE ; output to reference view
                Invoke CTA_AddRowToRefView, dwCTALIndex, Addr szLabelX
                inc dwCTALIndex
            .ENDIF
        .ENDIF
        
        Invoke DbgDisasmFastAt, dwCurrentAddress, Addr bii
        movzx eax, byte ptr bii.call_
        movzx ebx, byte ptr bii.branch
        
        .IF eax == 1 && ebx == 1 ; we have call statement
            Invoke GuiGetDisassembly, dwCurrentAddress, Addr szDisasmText
            mov eax, bii.address
            mov CallDestination, eax
            Invoke DbgDisasmFastAt, CallDestination, Addr cbii
            mov eax, bii.address
            mov JmpDestination, eax
            Invoke Strip_x64dbg_calls, Addr szDisasmText, Addr szCALLFunction
            Invoke szCopy, Addr szCall, Addr szFormattedDisasmText
            Invoke szCatStr, Addr szFormattedDisasmText, Addr szCALLFunction
            
            ;PrintDec bii.address
            ;PrintDec cbii.address
            
            movzx eax, byte ptr cbii.branch
            .IF eax == 1 ; external function call
            .ELSE ; internal function call
                
                Invoke dw2hex, JmpDestination, Addr szValueString
                .IF g_CmntOutsideRange == 1
                    mov eax, dwStartAddress
                    mov ebx, dwFinishAddress
                    .IF JmpDestination < eax || JmpDestination > ebx
                        Invoke szCatStr, Addr szFormattedDisasmText, Addr szCmnt
                        Invoke szCatStr, Addr szFormattedDisasmText, Addr szDestJmp
                        Invoke szCatStr, Addr szFormattedDisasmText, Addr szHex
                        Invoke szCatStr, Addr szFormattedDisasmText, Addr szValueString
                        Invoke szCatStr, Addr szFormattedDisasmText, Addr szCommentOutsideRange2
                    .ELSE
                        .IF g_CmntCallDest == 1
                            Invoke szCatStr, Addr szFormattedDisasmText, Addr szCmnt
                            Invoke szCatStr, Addr szFormattedDisasmText, Addr szDestJmp
                            Invoke szCatStr, Addr szFormattedDisasmText, Addr szHex
                            Invoke szCatStr, Addr szFormattedDisasmText, Addr szValueString
                        .ENDIF
                    .ENDIF
                .ELSE
                    .IF g_CmntCallDest == 1
                        Invoke szCatStr, Addr szFormattedDisasmText, Addr szCmnt
                        Invoke szCatStr, Addr szFormattedDisasmText, Addr szDestJmp
                        Invoke szCatStr, Addr szFormattedDisasmText, Addr szHex
                        Invoke szCatStr, Addr szFormattedDisasmText, Addr szValueString
                    .ENDIF
                .ENDIF
            .ENDIF

        .ELSEIF eax == 0 && ebx == 1 ; jumps
            Invoke DbgGetBranchDestination, dwCurrentAddress
            mov JmpDestination, eax
            
            mov eax, dwStartAddress
            mov ebx, dwFinishAddress
            .IF JmpDestination < eax || JmpDestination > ebx
                mov bOutsideRange, TRUE
            .ELSE
                mov bOutsideRange, FALSE
            .ENDIF
            
            Invoke GuiGetDisassembly, dwCurrentAddress, Addr szDisasmText
            Invoke CTAAddressInJmpTable, JmpDestination
            .IF eax != 0
                Invoke CTAJmpLabelFromJmpEntry, eax, JmpDestination, bOutsideRange, Addr szDisasmText, Addr szFormattedDisasmText
            .ELSE
                ;PrintText 'jmp destination not in CTAAddressInJmpTable!'
            .ENDIF

        .ELSE ; normal non jump or call instructions
            Invoke GuiGetDisassembly, dwCurrentAddress, Addr szDisasmText
            ;PrintString szDisasmText
            Invoke Strip_x64dbg_segments, Addr szDisasmText, Addr szFormattedDisasmText
            Invoke Strip_x64dbg_anglebrackets, Addr szFormattedDisasmText, Addr szDisasmText
            Invoke Strip_x64dbg_modulename, Addr szDisasmText, Addr szFormattedDisasmText


        .ENDIF
        
        Invoke ConvertHexValues, Addr szFormattedDisasmText, Addr szDisasmText, g_FormatType
        Invoke szCopy, Addr szDisasmText, Addr szFormattedDisasmText
        
        .IF dwOutput == 0 ; output to clipboard
            Invoke szCatStr, ptrClipboardData, Addr szFormattedDisasmText
            Invoke szCatStr, ptrClipboardData, Addr szCRLF
        .ELSE ; output to reference view
            Invoke CTA_AddRowToRefView, dwCTALIndex, Addr szFormattedDisasmText
        .ENDIF
        
        inc dwCTALIndex
        
        mov eax, bii.size_ 
        add dwCurrentAddress, eax        
        mov eax, dwCurrentAddress
    .ENDW    
    ;----------------------------------
    ; End main loop
    ;----------------------------------


    .IF dwOutput == 0 ; output to clipboard
        ;----------------------------------
        ; Finish Information
        ;----------------------------------
        Invoke szCatStr, ptrClipboardData, Addr szCommentSelFinish
        Invoke dw2hex, dwFinishAddress, Addr szValueString
        Invoke szCatStr, ptrClipboardData, Addr szHex
        Invoke szCatStr, ptrClipboardData, Addr szValueString
        ;Invoke szCatStr, ptrClipboardData, Addr szOffsetLeftBracket
        ;Invoke utoa_ex, dwFinishAddress, Addr szValueString
        ;Invoke szCatStr, ptrClipboardData, Addr szValueString
        ;Invoke szCatStr, ptrClipboardData, Addr szRightBracket
        Invoke szCatStr, ptrClipboardData, Addr szCRLF
        ;Invoke szCatStr, ptrClipboardData, Addr szCRLF
    
        .IF g_OutsideRangeLabels == 1
            ;----------------------------------
            ; Labels After
            ;----------------------------------
            Invoke CTAOutputLabelsOutsideRangeAfter, dwFinishAddress, ptrClipboardData
            Invoke CTAOutputCallLabelsOutsideRangeAfter, dwFinishAddress, ptrClipboardData
        .ENDIF
        
    .ELSE

        .IF g_OutsideRangeLabels == 1
            ;----------------------------------
            ; Labels After
            ;----------------------------------    
            Invoke CTARefViewLabelsOutsideRangeAfter, dwFinishAddress, dwCTALIndex
            mov dwCTALIndex, eax
            Invoke CTARefViewCallLabelsOutsideRangeAfter, dwFinishAddress, dwCTALIndex
            mov dwCTALIndex, eax
        .ENDIF
    
    .ENDIF


    Invoke CTAClearJmpTable ; free jmp table
    Invoke CTAClearCallTable ; free call table


    .IF dwOutput == 0 ; output to clipboard
        ;----------------------------------
        ; set clipboard data
        ;----------------------------------
        Invoke szLen, ptrClipboardData
        .IF eax != 0
            mov LenClipData, eax
            inc eax
            Invoke GlobalAlloc, GMEM_MOVEABLE, eax
            .IF eax == NULL
                Invoke GlobalFree, ptrClipboardData
                Invoke CloseClipboard
                ret
            .ENDIF
            mov hClipData, eax
            
            Invoke GlobalLock, hClipData
            .IF eax == NULL
                Invoke GlobalFree, ptrClipboardData
                Invoke GlobalFree, hClipData
                Invoke CloseClipboard
                ret
            .ENDIF
            mov pClipData, eax
            mov eax, LenClipData
            Invoke RtlMoveMemory, pClipData, ptrClipboardData, eax
            
            Invoke GlobalUnlock, hClipData 
            invoke SetClipboardData, CF_TEXT, hClipData
        
            Invoke CloseClipboard
            Invoke GlobalFree, ptrClipboardData
        .ENDIF
    
        ;PrintText 'Finished'
        Invoke GuiAddStatusBarMessage, Addr szFinishCopyToAsm
        
    .ELSE
    
        Invoke GuiAddStatusBarMessage, Addr szFinishCopyToAsmRefView
        Invoke GuiReferenceSetSingleSelection, 0, TRUE
        Invoke GuiReferenceReloadData
    .ENDIF
    ret

DoCopyToAsm ENDP


;-------------------------------------------------------------------------------------
; 1st pass of selection, build an array of jmp destinations
; estimates size required based on selection size (bytes) / 2 (jmp near = 2 bytes long)
; = no of entries (max safe estimate) * size jmptable_entry struct
; also roughly calcs the size of clipboard data required
;-------------------------------------------------------------------------------------
CTABuildJmpTable PROC USES EBX dwStartAddress:DWORD, dwFinishAddress:DWORD
    LOCAL bii:BASIC_INSTRUCTION_INFO ; basic 
    LOCAL dwJmpTableSize:DWORD
    LOCAL dwCurrentAddress:DWORD
    LOCAL JmpDestination:DWORD
    LOCAL nJmpEntry:DWORD
    LOCAL ptrJmpEntry:DWORD

    
    ;PrintText 'CTABuildJmpTable'
    
    mov CLIPDATASIZE, 0
    
    mov eax, dwFinishAddress
    mov ebx, dwStartAddress
    sub eax, ebx
    .IF sdword ptr eax < 0
        neg eax
    .ENDIF
    shr eax, 1 ; div by 2
    mov JMPTABLE_ENTRIES_MAX, eax
    mov ebx, SIZEOF JMPTABLE_ENTRY
    mul ebx
    mov dwJmpTableSize, eax
    
    Invoke GlobalAlloc, GMEM_FIXED + GMEM_ZEROINIT, dwJmpTableSize
    .IF eax == NULL
        Invoke GuiAddStatusBarMessage, Addr szErrorAllocMemJmpTable
        mov eax, FALSE
        ret
    .ENDIF
    mov JMPTABLE, eax
    mov ptrJmpEntry, eax
    mov nJmpEntry, 0

    mov eax, dwStartAddress
    mov dwCurrentAddress, eax


    .WHILE eax <= dwFinishAddress
        Invoke DbgDisasmFastAt, dwCurrentAddress, Addr bii
        movzx eax, byte ptr bii.call_
        movzx ebx, byte ptr bii.branch
        
        .IF eax ==0 && ebx == 1 ; jumps
            ;mov eax, bii.address
            Invoke DbgGetBranchDestination, dwCurrentAddress
            mov JmpDestination, eax
           ; PrintDec JmpDestination
            
            Invoke CTAAddressInJmpTable, JmpDestination
            .IF eax == 0            
            
                mov ebx, ptrJmpEntry
                mov eax, JmpDestination
                mov [ebx].JMPTABLE_ENTRY.dwAddress, eax
                
                inc nJmpEntry
                inc JMPTABLE_ENTRIES_TOTAL
                
                mov eax, JMPTABLE_ENTRIES_TOTAL
                .IF eax >= JMPTABLE_ENTRIES_MAX
                    Invoke GuiAddStatusBarMessage, Addr szErrorMaxEntries
                    mov eax, FALSE
                    ret
                .ENDIF
                
                add ptrJmpEntry, SIZEOF JMPTABLE_ENTRY
            .ENDIF
        .ENDIF
        
        Invoke GuiGetDisassembly, dwCurrentAddress, Addr szDisasmText
        Invoke szLen, Addr szDisasmText
        add eax, 2 ; for CRLF pairs for each line
        add CLIPDATASIZE, eax

        mov eax, bii.size_ 
        add dwCurrentAddress, eax
        mov eax, dwCurrentAddress
    .ENDW    
    
    mov eax, JMPTABLE_ENTRIES_TOTAL
    mov ebx, 3 ; for extra label entries at start/finish for outside range labels
    mul ebx
    mov ebx, 96d ; LABEL_123456789 CRLF (18) + JMP LABEL_123456789 CRLF (22) = (40) round up = 64 + 16 for jmp outside range
    mul ebx
    add eax, 240d ;32d + 32d + 48d + 48d +8 +8 +20 +20; for additional comments
    add CLIPDATASIZE, eax
    
    
    ;PrintDec dwJmpTableSize
    ;PrintDec JMPTABLE_ENTRIES_MAX
    ;PrintDec JMPTABLE_ENTRIES_TOTAL
    ;mov eax, JMPTABLE_ENTRIES_TOTAL
    ;mov ebx, SIZEOF JMPTABLE_ENTRY
    ;mul ebx
    ;DbgDump JMPTABLE, eax
    
    mov eax, TRUE
    ret

CTABuildJmpTable ENDP



;-------------------------------------------------------------------------------------
; 2nd pass of selection, build an array of call destinations
; estimates size required based on selection size (bytes) / 4 (call xxxx (5) 4 bytes long)
; = no of entries (max safe estimate) * size jmptable_entry struct
; also roughly calcs the size of clipboard data required
;-------------------------------------------------------------------------------------
CTABuildCallTable PROC USES EBX dwStartAddress:DWORD, dwFinishAddress:DWORD
    LOCAL bii:BASIC_INSTRUCTION_INFO ; basic 
    LOCAL cbii:BASIC_INSTRUCTION_INFO ; call destination
    LOCAL dwCallTableSize:DWORD
    LOCAL dwCurrentAddress:DWORD
    LOCAL CallDestination:DWORD
    LOCAL nCallEntry:DWORD
    LOCAL ptrCallEntry:DWORD

    mov eax, dwFinishAddress
    mov ebx, dwStartAddress
    sub eax, ebx
    .IF sdword ptr eax < 0
        neg eax
    .ENDIF
    shr eax, 2 ; div by 4
    mov CALLTABLE_ENTRIES_MAX, eax
    mov ebx, SIZEOF CALLTABLE_ENTRY
    mul ebx
    mov dwCallTableSize, eax
    
    Invoke GlobalAlloc, GMEM_FIXED + GMEM_ZEROINIT, dwCallTableSize
    .IF eax == NULL
        Invoke GuiAddStatusBarMessage, Addr szErrorAllocMemCallTable
        mov eax, FALSE
        ret
    .ENDIF
    mov CALLTABLE, eax
    mov ptrCallEntry, eax
    mov nCallEntry, 0

    mov eax, dwStartAddress
    mov dwCurrentAddress, eax


    .WHILE eax <= dwFinishAddress
        Invoke DbgDisasmFastAt, dwCurrentAddress, Addr bii
        movzx eax, byte ptr bii.call_
        movzx ebx, byte ptr bii.branch
        
        .IF eax == 1 && ebx == 1 ; we have call statement

            mov eax, bii.address
            mov CallDestination, eax
            Invoke DbgDisasmFastAt, CallDestination, Addr cbii
            
            movzx eax, byte ptr cbii.branch
            .IF eax == 1 ; external function call
            .ELSE ; internal function call        
                
                Invoke CTAAddressInCallTable, CallDestination
                .IF eax == 0
                
                    mov ebx, ptrCallEntry
                    mov eax, CallDestination
                    mov [ebx].CALLTABLE_ENTRY.dwAddress, eax
                    mov eax, dwCurrentAddress
                    mov [ebx].CALLTABLE_ENTRY.dwCallAddress, eax
                    
                    inc nCallEntry
                    inc CALLTABLE_ENTRIES_TOTAL
                    
                    mov eax, CALLTABLE_ENTRIES_TOTAL
                    .IF eax >= CALLTABLE_ENTRIES_MAX
                        Invoke GuiAddStatusBarMessage, Addr szErrorMaxEntries
                        mov eax, FALSE
                        ret
                    .ENDIF
                    
                    add ptrCallEntry, SIZEOF CALLTABLE_ENTRY
                    
                .ENDIF
            .ENDIF
        .ENDIF
        
        Invoke GuiGetDisassembly, dwCurrentAddress, Addr szDisasmText
        Invoke szLen, Addr szDisasmText
        add eax, 2 ; for CRLF pairs for each line
        add CLIPDATASIZE, eax

        mov eax, bii.size_ 
        add dwCurrentAddress, eax
        mov eax, dwCurrentAddress
    .ENDW    
    
    mov eax, CALLTABLE_ENTRIES_TOTAL
    mov ebx, 3 ; for extra label entries at start/finish for outside range labels
    mul ebx
    mov ebx, 64d
    mul ebx
    add CLIPDATASIZE, eax
    
    
    ;PrintDec dwCallTableSize
    ;PrintDec CALLTABLE_ENTRIES_MAX
    ;PrintDec CALLTABLE_ENTRIES_TOTAL
    ;mov eax, CALLTABLE_ENTRIES_TOTAL
    ;mov ebx, SIZEOF CALLTABLE_ENTRY
    ;mul ebx    
    ;DbgDump CALLTABLE, eax
    
    mov eax, TRUE
    ret

CTABuildCallTable ENDP


;-------------------------------------------------------------------------------------
; Frees memory of the jmptable and reset vars
;-------------------------------------------------------------------------------------
CTAClearJmpTable PROC
    
    mov JMPTABLE_ENTRIES_MAX, 0
    mov JMPTABLE_ENTRIES_TOTAL, 0
    mov eax, JMPTABLE
    .IF eax != 0
        Invoke GlobalFree, eax
    .ENDIF
    ret

CTAClearJmpTable ENDP


;-------------------------------------------------------------------------------------
; Frees memory of the calltable and reset vars
;-------------------------------------------------------------------------------------
CTAClearCallTable PROC
    
    mov CALLTABLE_ENTRIES_MAX, 0
    mov CALLTABLE_ENTRIES_TOTAL, 0
    mov eax, CALLTABLE
    .IF eax != 0
        Invoke GlobalFree, eax
    .ENDIF
    ret

CTAClearCallTable ENDP


;-------------------------------------------------------------------------------------
; returns 0 if address is not in JMPTABLE, otherwise returns an 1-based index in eax
; each address can be checked to see if it a destination for a jmp instruction
; if it is then a label can be created an inserted before the instruction
; if it is a jmp instruction the jmp destination can be searched for and if found
; a jmp label can be inserted instead of the disassembled jmp instruction.
;-------------------------------------------------------------------------------------
CTAAddressInJmpTable PROC USES EBX dwAddress:DWORD
    LOCAL nJmpEntry:DWORD
    LOCAL ptrJmpEntry:DWORD
    
    .IF JMPTABLE == 0 || JMPTABLE_ENTRIES_TOTAL == 0
        mov eax, 0
        ret
    .ENDIF
    
    mov eax, JMPTABLE
    mov ptrJmpEntry, eax
    mov nJmpEntry, 0
    mov eax, 0
    .WHILE eax < JMPTABLE_ENTRIES_TOTAL
        mov ebx, ptrJmpEntry
        mov eax, [ebx].JMPTABLE_ENTRY.dwAddress
        .IF eax == dwAddress
            mov eax, nJmpEntry
            inc eax ; for 1 based index
            ret
        .ENDIF
        add ptrJmpEntry, SIZEOF JMPTABLE_ENTRY
        inc nJmpEntry
        mov eax, nJmpEntry
    .ENDW
    mov eax, 0
    ret
CTAAddressInJmpTable ENDP


;-------------------------------------------------------------------------------------
; returns 0 if address is not in CALLTABLE, otherwise returns an 1-based index in eax
; each address can be checked to see if it a destination for a call instruction
; if it is then a label can be created an inserted before the instruction
;-------------------------------------------------------------------------------------
CTAAddressInCallTable PROC USES EBX dwAddress:DWORD
    LOCAL nCallEntry:DWORD
    LOCAL ptrCallEntry:DWORD
    
    .IF CALLTABLE == 0 || CALLTABLE_ENTRIES_TOTAL == 0
        mov eax, 0
        ret
    .ENDIF
    
    mov eax, CALLTABLE
    mov ptrCallEntry, eax
    mov nCallEntry, 0
    mov eax, 0
    .WHILE eax < CALLTABLE_ENTRIES_TOTAL
        mov ebx, ptrCallEntry
        mov eax, [ebx].CALLTABLE_ENTRY.dwAddress
        .IF eax == dwAddress
            mov eax, nCallEntry
            inc eax ; for 1 based index
            ret
        .ENDIF
        add ptrCallEntry, SIZEOF CALLTABLE_ENTRY
        inc nCallEntry
        mov eax, nCallEntry
    .ENDW
    mov eax, 0
    ret
CTAAddressInCallTable ENDP


;-------------------------------------------------------------------------------------
; Called before main loop output to clipboard labels outside range (before) selection
;-------------------------------------------------------------------------------------
CTAOutputLabelsOutsideRangeBefore PROC USES EBX dwStartAddress:DWORD, pDataBuffer:DWORD
    LOCAL nJmpEntry:DWORD
    LOCAL ptrJmpEntry:DWORD
    LOCAL bOutputComment:DWORD
    LOCAL dwAddress:DWORD
    
    .IF JMPTABLE == 0 || JMPTABLE_ENTRIES_TOTAL == 0
        mov eax, 0
        ret
    .ENDIF
    
    mov bOutputComment, FALSE
    
    mov eax, JMPTABLE
    mov ptrJmpEntry, eax
    mov nJmpEntry, 0
    mov eax, 0
    .WHILE eax < JMPTABLE_ENTRIES_TOTAL
        mov ebx, ptrJmpEntry
        mov eax, [ebx].JMPTABLE_ENTRY.dwAddress
        mov dwAddress, eax
        .IF eax < dwStartAddress
            .IF bOutputComment == FALSE
                Invoke szCatStr, pDataBuffer, Addr szCommentBeforeRange
                mov bOutputComment, TRUE 
            .ENDIF
            
            mov eax, nJmpEntry
            inc eax ; for 1 based index
            Invoke CTALabelFromJmpEntry, eax, dwAddress, Addr szLabelX
            Invoke szCatStr, pDataBuffer, Addr szCRLF 
            Invoke szCatStr, pDataBuffer, Addr szLabelX
            .IF g_CmntJumpDest == 1
                Invoke dw2hex, dwAddress, Addr szValueString
                Invoke szCatStr, pDataBuffer, Addr szCmntStart
                Invoke szCatStr, pDataBuffer, Addr szValueString
            .ENDIF
            Invoke szCatStr, pDataBuffer, Addr szCRLF            

        .ENDIF
        add ptrJmpEntry, SIZEOF JMPTABLE_ENTRY
        inc nJmpEntry
        mov eax, nJmpEntry
    .ENDW
    mov eax, 0
    ret
CTAOutputLabelsOutsideRangeBefore ENDP


;-------------------------------------------------------------------------------------
; Called before main loop output to clipboard call labels outside range (before) selection
;-------------------------------------------------------------------------------------
CTAOutputCallLabelsOutsideRangeBefore PROC USES EBX dwStartAddress:DWORD, pDataBuffer:DWORD
    LOCAL nCallEntry:DWORD
    LOCAL ptrCallEntry:DWORD
    LOCAL bOutputComment:DWORD
    LOCAL dwAddress:DWORD
    
    .IF CALLTABLE == 0 || CALLTABLE_ENTRIES_TOTAL == 0
        mov eax, 0
        ret
    .ENDIF    
    
    mov bOutputComment, FALSE
    
    mov eax, CALLTABLE
    mov ptrCallEntry, eax
    mov nCallEntry, 0
    mov eax, 0
    .WHILE eax < CALLTABLE_ENTRIES_TOTAL
        mov ebx, ptrCallEntry
        mov eax, [ebx].CALLTABLE_ENTRY.dwAddress
        mov dwAddress, eax
        .IF eax < dwStartAddress
            .IF bOutputComment == FALSE
                Invoke szCatStr, pDataBuffer, Addr szCommentCallsBeforeRange
                mov bOutputComment, TRUE 
            .ENDIF

            Invoke CTALabelFromCallEntry, nCallEntry, Addr szLabelX
            Invoke szCatStr, pDataBuffer, Addr szCRLF 
            Invoke szCatStr, pDataBuffer, Addr szLabelX
            .IF g_CmntJumpDest == 1
                Invoke dw2hex, dwAddress, Addr szValueString
                Invoke szCatStr, pDataBuffer, Addr szCmntStart
                Invoke szCatStr, pDataBuffer, Addr szValueString
            .ENDIF
            Invoke szCatStr, pDataBuffer, Addr szCRLF           

        .ENDIF
        add ptrCallEntry, SIZEOF CALLTABLE_ENTRY
        inc nCallEntry
        mov eax, nCallEntry
    .ENDW
    mov eax, 0
    ret
CTAOutputCallLabelsOutsideRangeBefore ENDP


;-------------------------------------------------------------------------------------
; Called before main loop output to refview labels outside range (before) selection
;-------------------------------------------------------------------------------------
CTARefViewLabelsOutsideRangeBefore PROC USES EBX dwStartAddress:DWORD, dwCount:DWORD
    LOCAL nJmpEntry:DWORD
    LOCAL ptrJmpEntry:DWORD
    LOCAL dwAddress:DWORD
    LOCAL dwCTALIndex:DWORD
    
    .IF JMPTABLE == 0 || JMPTABLE_ENTRIES_TOTAL == 0
        mov eax, dwCount
        ret
    .ENDIF
    
    mov eax, dwCount
    mov dwCTALIndex, eax
    
    mov eax, JMPTABLE
    mov ptrJmpEntry, eax
    mov nJmpEntry, 0
    mov eax, 0
    .WHILE eax < JMPTABLE_ENTRIES_TOTAL
        mov ebx, ptrJmpEntry
        mov eax, [ebx].JMPTABLE_ENTRY.dwAddress
        mov dwAddress, eax
        .IF eax < dwStartAddress

            mov eax, nJmpEntry
            inc eax ; for 1 based index            
            Invoke CTALabelFromJmpEntry, eax, dwAddress, Addr szLabelX
            
            Invoke szCopy, Addr szLabelX, Addr szFormattedDisasmText
            .IF g_CmntJumpDest == 1
                Invoke dw2hex, dwAddress, Addr szValueString
                Invoke szCatStr, Addr szFormattedDisasmText, Addr szCmntStart
                Invoke szCatStr, Addr szFormattedDisasmText, Addr szValueString
            .ENDIF
            Invoke CTA_AddRowToRefView, dwCTALIndex, Addr szFormattedDisasmText
            inc dwCTALIndex

        .ENDIF
        add ptrJmpEntry, SIZEOF JMPTABLE_ENTRY
        inc nJmpEntry
        mov eax, nJmpEntry
    .ENDW
    mov eax, dwCTALIndex
    ret
CTARefViewLabelsOutsideRangeBefore ENDP


;-------------------------------------------------------------------------------------
; Called before main loop output to refview call labels outside range (before) selection
;-------------------------------------------------------------------------------------
CTARefViewCallLabelsOutsideRangeBefore PROC USES EBX dwStartAddress:DWORD, dwCount:DWORD
    LOCAL nCallEntry:DWORD
    LOCAL ptrCallEntry:DWORD
    LOCAL dwAddress:DWORD
    LOCAL dwCTALIndex:DWORD
    
    .IF CALLTABLE == 0 || CALLTABLE_ENTRIES_TOTAL == 0
        mov eax, dwCount
        ret
    .ENDIF    

    mov eax, dwCount
    mov dwCTALIndex, eax
    
    mov eax, CALLTABLE
    mov ptrCallEntry, eax
    mov nCallEntry, 0
    mov eax, 0
    .WHILE eax < CALLTABLE_ENTRIES_TOTAL
        mov ebx, ptrCallEntry
        mov eax, [ebx].CALLTABLE_ENTRY.dwAddress
        mov dwAddress, eax
        
        .IF eax < dwStartAddress
        
            Invoke CTALabelFromCallEntry, nCallEntry, Addr szLabelX
            Invoke szCopy, Addr szLabelX, Addr szFormattedDisasmText
            .IF g_CmntJumpDest == 1
                Invoke dw2hex, dwAddress, Addr szValueString
                Invoke szCatStr, Addr szFormattedDisasmText, Addr szCmntStart
                Invoke szCatStr, Addr szFormattedDisasmText, Addr szValueString
            .ENDIF
            Invoke CTA_AddRowToRefView, dwCTALIndex, Addr szFormattedDisasmText
            inc dwCTALIndex       

        .ENDIF
        add ptrCallEntry, SIZEOF CALLTABLE_ENTRY
        inc nCallEntry
        mov eax, nCallEntry
    .ENDW
    mov eax, dwCTALIndex
    ret
CTARefViewCallLabelsOutsideRangeBefore ENDP


;-------------------------------------------------------------------------------------
; Called after main loop output to clipboard labels outside range (after) selection
;-------------------------------------------------------------------------------------
CTAOutputLabelsOutsideRangeAfter PROC USES EBX dwFinishAddress:DWORD, pDataBuffer:DWORD
    LOCAL nJmpEntry:DWORD
    LOCAL ptrJmpEntry:DWORD
    LOCAL bOutputComment:DWORD
    LOCAL dwAddress:DWORD
    
    .IF JMPTABLE == 0 || JMPTABLE_ENTRIES_TOTAL == 0
        mov eax, 0
        ret
    .ENDIF
    
    mov bOutputComment, FALSE
    
    mov eax, JMPTABLE
    mov ptrJmpEntry, eax
    mov nJmpEntry, 0
    mov eax, 0
    .WHILE eax < JMPTABLE_ENTRIES_TOTAL
        mov ebx, ptrJmpEntry
        mov eax, [ebx].JMPTABLE_ENTRY.dwAddress
        mov dwAddress, eax
        .IF eax > dwFinishAddress
            .IF bOutputComment == FALSE
                Invoke szCatStr, pDataBuffer, Addr szCommentAfterRange
                mov bOutputComment, TRUE 
            .ENDIF
            
            mov eax, nJmpEntry
            inc eax ; for 1 based index            
            Invoke CTALabelFromJmpEntry, eax, dwAddress, Addr szLabelX
            Invoke szCatStr, pDataBuffer, Addr szCRLF 
            Invoke szCatStr, pDataBuffer, Addr szLabelX
            .IF g_CmntJumpDest == 1
                Invoke dw2hex, dwAddress, Addr szValueString
                Invoke szCatStr, pDataBuffer, Addr szCmntStart
                Invoke szCatStr, pDataBuffer, Addr szValueString
            .ENDIF
            Invoke szCatStr, pDataBuffer, Addr szCRLF

        .ENDIF
        add ptrJmpEntry, SIZEOF JMPTABLE_ENTRY
        inc nJmpEntry
        mov eax, nJmpEntry
    .ENDW
    mov eax, 0
    ret
CTAOutputLabelsOutsideRangeAfter ENDP


;-------------------------------------------------------------------------------------
; Called before main loop output to clipboard call labels outside range (after) selection
;-------------------------------------------------------------------------------------
CTAOutputCallLabelsOutsideRangeAfter PROC USES EBX dwFinishAddress:DWORD, pDataBuffer:DWORD
    LOCAL nCallEntry:DWORD
    LOCAL ptrCallEntry:DWORD
    LOCAL bOutputComment:DWORD
    LOCAL dwAddress:DWORD
    
    .IF CALLTABLE == 0 || CALLTABLE_ENTRIES_TOTAL == 0
        mov eax, 0
        ret
    .ENDIF    
    
    mov bOutputComment, FALSE
    
    mov eax, CALLTABLE
    mov ptrCallEntry, eax
    mov nCallEntry, 0
    mov eax, 0
    .WHILE eax < CALLTABLE_ENTRIES_TOTAL
        mov ebx, ptrCallEntry
        mov eax, [ebx].CALLTABLE_ENTRY.dwAddress
        mov dwAddress, eax
        .IF eax > dwFinishAddress
            .IF bOutputComment == FALSE
                Invoke szCatStr, pDataBuffer, Addr szCommentCallsAfterRange
                mov bOutputComment, TRUE 
            .ENDIF
            Invoke CTALabelFromCallEntry, nCallEntry, Addr szLabelX
            Invoke szCatStr, pDataBuffer, Addr szCRLF 
            Invoke szCatStr, pDataBuffer, Addr szLabelX
            .IF g_CmntJumpDest == 1
                Invoke dw2hex, dwAddress, Addr szValueString
                Invoke szCatStr, pDataBuffer, Addr szCmntStart
                Invoke szCatStr, pDataBuffer, Addr szValueString
            .ENDIF
            Invoke szCatStr, pDataBuffer, Addr szCRLF           

        .ENDIF
        add ptrCallEntry, SIZEOF CALLTABLE_ENTRY
        inc nCallEntry
        mov eax, nCallEntry
    .ENDW
    mov eax, 0
    ret
CTAOutputCallLabelsOutsideRangeAfter ENDP


;-------------------------------------------------------------------------------------
; Called before main loop output to refview labels outside range (after) selection
;-------------------------------------------------------------------------------------
CTARefViewLabelsOutsideRangeAfter PROC USES EBX dwFinishAddress:DWORD, dwCount:DWORD
    LOCAL nJmpEntry:DWORD
    LOCAL ptrJmpEntry:DWORD
    LOCAL dwAddress:DWORD
    LOCAL dwCTALIndex:DWORD
    
    .IF JMPTABLE == 0 || JMPTABLE_ENTRIES_TOTAL == 0
        mov eax, dwCount
        ret
    .ENDIF
    
    mov eax, dwCount
    mov dwCTALIndex, eax
    
    mov eax, JMPTABLE
    mov ptrJmpEntry, eax
    mov nJmpEntry, 0
    mov eax, 0
    .WHILE eax < JMPTABLE_ENTRIES_TOTAL
        mov ebx, ptrJmpEntry
        mov eax, [ebx].JMPTABLE_ENTRY.dwAddress
        mov dwAddress, eax
        .IF eax > dwFinishAddress

            mov eax, nJmpEntry
            inc eax ; for 1 based index            
            Invoke CTALabelFromJmpEntry, eax, dwAddress, Addr szLabelX
            Invoke szCopy, Addr szLabelX, Addr szFormattedDisasmText
            .IF g_CmntJumpDest == 1
                Invoke dw2hex, dwAddress, Addr szValueString
                Invoke szCatStr, Addr szFormattedDisasmText, Addr szCmntStart
                Invoke szCatStr, Addr szFormattedDisasmText, Addr szValueString
            .ENDIF
            Invoke CTA_AddRowToRefView, dwCTALIndex, Addr szFormattedDisasmText
            inc dwCTALIndex

        .ENDIF
        add ptrJmpEntry, SIZEOF JMPTABLE_ENTRY
        inc nJmpEntry
        mov eax, nJmpEntry
    .ENDW
    mov eax, dwCTALIndex
    ret
CTARefViewLabelsOutsideRangeAfter ENDP


;-------------------------------------------------------------------------------------
; Called before main loop output to refview call labels outside range (after) selection
;-------------------------------------------------------------------------------------
CTARefViewCallLabelsOutsideRangeAfter PROC USES EBX dwFinishAddress:DWORD, dwCount:DWORD
    LOCAL nCallEntry:DWORD
    LOCAL ptrCallEntry:DWORD
    LOCAL dwAddress:DWORD
    LOCAL dwCTALIndex:DWORD
    
    .IF CALLTABLE == 0 || CALLTABLE_ENTRIES_TOTAL == 0
        mov eax, dwCount
        ret
    .ENDIF    

    mov eax, dwCount
    mov dwCTALIndex, eax

    mov eax, CALLTABLE
    mov ptrCallEntry, eax
    mov nCallEntry, 0
    mov eax, 0
    .WHILE eax < CALLTABLE_ENTRIES_TOTAL
        mov ebx, ptrCallEntry
        mov eax, [ebx].CALLTABLE_ENTRY.dwAddress
        mov dwAddress, eax
        
        .IF eax > dwFinishAddress
        
            Invoke CTALabelFromCallEntry, nCallEntry, Addr szLabelX
            Invoke szCopy, Addr szLabelX, Addr szFormattedDisasmText
            .IF g_CmntJumpDest == 1
                Invoke dw2hex, dwAddress, Addr szValueString
                Invoke szCatStr, Addr szFormattedDisasmText, Addr szCmntStart
                Invoke szCatStr, Addr szFormattedDisasmText, Addr szValueString
            .ENDIF
            Invoke CTA_AddRowToRefView, dwCTALIndex, Addr szFormattedDisasmText
            inc dwCTALIndex       

        .ENDIF
        add ptrCallEntry, SIZEOF CALLTABLE_ENTRY
        inc nCallEntry
        mov eax, nCallEntry
    .ENDW
    mov eax, dwCTALIndex
    ret
CTARefViewCallLabelsOutsideRangeAfter ENDP



;-------------------------------------------------------------------------------------
; Creates string "LABEL_X:"+(CRLF) from dwJmpEntry number X
;-------------------------------------------------------------------------------------
CTALabelFromJmpEntry PROC dwJmpEntry:DWORD, dwAddress:DWORD, lpszLabel:DWORD
    LOCAL szValue[16]:BYTE
    .IF lpszLabel != NULL
        .IF g_LblUseAddress == 1
            Invoke dw2hex, dwAddress, Addr szValue
        .ELSE
            Invoke utoa_ex, dwJmpEntry, Addr szValue
        .ENDIF
        ;Invoke szCopy, Addr szCRLF, lpszLabel
        .IF g_LblUseLabel == 1
            Invoke szCopy, Addr szLabel, lpszLabel
        .ELSE
            Invoke szCopy, Addr szUnderscore, lpszLabel
        .ENDIF
        ;Invoke szCatStr, lpszLabel, Addr szLabel
        .IF g_LblUseAddress == 1
            Invoke szCatStr, lpszLabel, Addr szHex
        .ENDIF
        Invoke szCatStr, lpszLabel, Addr szValue
        Invoke szCatStr, lpszLabel, Addr szColon
        ;Invoke szCatStr, lpszLabel, Addr szCRLF
    .ENDIF
    ret
CTALabelFromJmpEntry ENDP


;-------------------------------------------------------------------------------------
; Creates string "LABEL_X:"+(CRLF) from dwCallEntry number X
;-------------------------------------------------------------------------------------
CTALabelFromCallEntry PROC USES EBX dwCallEntry:DWORD, lpszLabel:DWORD
    LOCAL ptrCallEntry:DWORD
    LOCAL dwCallAddress:DWORD
    
    mov ebx, SIZEOF CALLTABLE_ENTRY
    mov eax, dwCallEntry
    .IF eax > CALLTABLE_ENTRIES_TOTAL
        Invoke szCopy, Addr szErrCallLabel, lpszLabel
        ret
    .ENDIF
    mul ebx
    mov ebx, CALLTABLE
    add eax, ebx
    mov ptrCallEntry, eax
    mov ebx, eax
    mov eax, [ebx].CALLTABLE_ENTRY.dwCallAddress
    mov dwCallAddress, eax
    
    Invoke GuiGetDisassembly, dwCallAddress, Addr szCallLabelText
    
    Invoke Strip_x64dbg_calls, Addr szCallLabelText, Addr szCALLFunction
    Invoke szCatStr, Addr szCALLFunction, Addr szColon
    Invoke szCopy, Addr szCALLFunction, lpszLabel
    ret

CTALabelFromCallEntry ENDP



;-------------------------------------------------------------------------------------
; Creates string for jump xxx instruction "jxxx LABEL_X" from dwJmpEntry number x
;-------------------------------------------------------------------------------------
CTAJmpLabelFromJmpEntry PROC USES EDI ESI dwJmpEntry:DWORD, dwAddress:DWORD, bOutsideRange:DWORD, lpszJxxx:DWORD, lpszJumpLabel:DWORD
    LOCAL szValue[16]:BYTE
    LOCAL szJmp[16]:BYTE
    
    .IF lpszJxxx != NULL && lpszJumpLabel != NULL
        
        .IF g_LblUseAddress == 1
            Invoke dw2hex, dwAddress, Addr szValue
        .ELSE
            Invoke utoa_ex, dwJmpEntry, Addr szValue
        .ENDIF
        
        lea edi, szJmp
        mov esi, lpszJxxx
        
        movzx eax, byte ptr [esi]
        .WHILE al != 0
            .IF al == " " ; space
                mov byte ptr [edi], al
                inc edi
                .BREAK
            .ENDIF
            mov byte ptr [edi], al
            inc esi
            inc edi
            movzx eax, byte ptr [esi]
        .ENDW
        mov byte ptr [edi], 0h ; add null to string
        
        Invoke szCopy, Addr szJmp, lpszJumpLabel
        ;Invoke szCatStr, lpszJumpLabel, Addr szJmp
        .IF g_LblUseLabel == 1
            Invoke szCatStr, lpszJumpLabel, Addr szLabel
        .ELSE
            Invoke szCatStr, lpszJumpLabel, Addr szUnderscore
        .ENDIF
        .IF g_LblUseAddress == 1
            Invoke szCatStr, lpszJumpLabel, Addr szHex
        .ENDIF
        Invoke szCatStr, lpszJumpLabel, Addr szValue
        .IF g_CmntJumpDest == 1
            Invoke szCatStr, lpszJumpLabel, Addr szCmnt
            Invoke szCatStr, lpszJumpLabel, Addr szDestJmp
            Invoke dw2hex, dwAddress, Addr szValueString
            Invoke szCatStr, lpszJumpLabel, Addr szHex
            Invoke szCatStr, lpszJumpLabel, Addr szValueString
        .ENDIF
        .IF bOutsideRange == TRUE
            .IF g_CmntOutsideRange == 1
                .IF g_CmntJumpDest == 1
                    Invoke szCatStr, lpszJumpLabel, Addr szCommentOutsideRange2
                .ELSE
                    Invoke szCatStr, lpszJumpLabel, Addr szCommentOutsideRange
                .ENDIF
            .ENDIF
        .ENDIF
        ;Invoke szCatStr, lpszLabel, Addr szCRLF
    .ENDIF
    ret
CTAJmpLabelFromJmpEntry ENDP






;=====================================================================================
; Strips out the brackets, underscores, full stops and @ symbols from calls: call <winbif._GetModuleHandleA@4> and returns just the api call: GetModuleHandle
; Returns true if succesful and lpszAPIFunction will contain the stripped api function name, otherwise false and lpszAPIFunction will be a null string
;-------------------------------------------------------------------------------------
Strip_x64dbg_calls PROC USES EDI ESI lpszCallText:DWORD, lpszAPIFunction:DWORD
    
    .IF lpszCallText != 0
        mov esi, lpszCallText
        mov edi, lpszAPIFunction
        
        movzx eax, byte ptr [esi]
        .WHILE al != '.' && al != '&'; 64bit have & in the api calls, so to check for that as well
            .IF al == 0h ; ended here, maybe have a call eax or call rax type call
                ; go back and look for space instead
                mov esi, lpszCallText
                mov edi, lpszAPIFunction
                movzx eax, byte ptr [esi]
                .WHILE al != ' '
                    .IF al == 0h ; reached end of string and no . and no & and no space now?
                        mov byte ptr [edi], 0h ;
                        mov eax, FALSE
                        ret
                    .ENDIF
                    inc esi
                    movzx eax, byte ptr [esi]
                .ENDW
                .BREAK
            .ENDIF
            inc esi
            movzx eax, byte ptr [esi]
        .ENDW
    
        inc esi ; jump over the . and the first _ if its there
        movzx eax, byte ptr [esi]
        .IF al == '_'
            inc esi
        .ENDIF
    
        movzx eax, byte ptr [esi]
        .WHILE al != '@' && al != '>' && al != 0
            mov byte ptr [edi], al
            inc edi
            inc esi
            movzx eax, byte ptr [esi]
        .ENDW
        mov byte ptr [edi], 0h ; null out string
        mov eax, TRUE
    .ELSE
        mov eax, FALSE
    .ENDIF
    ret

Strip_x64dbg_calls endp


;=====================================================================================
; Strips out the segment text before brackets ss:[], ds:[] etc and any 0x
;-------------------------------------------------------------------------------------
Strip_x64dbg_segments PROC USES EBX EDI ESI lpszDisasmText:DWORD, lpszFormattedDisamText:DWORD

    .IF lpszDisasmText != 0
        mov esi, lpszDisasmText
        mov edi, lpszFormattedDisamText
        
        movzx eax, byte ptr [esi]
        .WHILE al != ':'
            .IF al == 0h
                mov byte ptr [edi], 0h ; add null to string
                mov eax, FALSE
                ret
            .ENDIF
            mov byte ptr [edi], al
            inc edi
            inc esi
            movzx eax, byte ptr [esi]
        .ENDW
    
        inc esi ; jump over the :, then skip back before segment text
        dec edi
        dec edi
    
        movzx eax, byte ptr [esi]
        .WHILE al != 0
            mov byte ptr [edi], al
            inc edi
            inc esi
            movzx eax, byte ptr [esi]
        .ENDW
        mov byte ptr [edi], 0h ; add null to string
        mov eax, TRUE
    .ELSE
        mov eax, FALSE
    .ENDIF
    ret

Strip_x64dbg_segments ENDP


;=====================================================================================
; Strips out the angle brackets < >
;-------------------------------------------------------------------------------------
Strip_x64dbg_anglebrackets PROC USES EDI ESI lpszDisasmText:DWORD, lpszFormattedDisamText:DWORD
    
    .IF lpszDisasmText != 0
        mov esi, lpszDisasmText
        mov edi, lpszFormattedDisamText
        
        movzx eax, byte ptr [esi]
        .WHILE al != 0
            .IF al == '<' || al == '>'
            .ELSE
                mov byte ptr [edi], al
                inc edi
            .ENDIF
            inc esi
            movzx eax, byte ptr [esi]
        .ENDW
        mov byte ptr [edi], 0
        mov eax, TRUE
    .ELSE
        mov eax, FALSE
    .ENDIF
    
    ret
Strip_x64dbg_anglebrackets ENDP


;=====================================================================================
; Strips out the module name plus dot if it exists
;-------------------------------------------------------------------------------------
Strip_x64dbg_modulename PROC lpszDisasmText:DWORD, lpszFormattedDisasmText:DWORD
    .IF lpszDisasmText != 0
        Invoke InString, 1, lpszDisasmText, Addr szModuleNameStrip
        .IF sdword ptr eax > 0
            Invoke szRep, lpszDisasmText, lpszFormattedDisasmText, Addr szModuleNameStrip, Addr szNull
        .ELSE
            Invoke szCopy, lpszDisasmText, lpszFormattedDisasmText
        .ENDIF
        mov eax, TRUE
    .ELSE
        mov eax, FALSE
    .ENDIF
    ret
Strip_x64dbg_modulename ENDP



;=====================================================================================
; Converts values to c style (dwstyle=0) or masm style (dwstyle=1)
;-------------------------------------------------------------------------------------
ConvertHexValues PROC USES EBX EDI ESI lpszStringToParse:DWORD, lpszStringOutput:DWORD, dwStyle:DWORD
    LOCAL dwLenString:DWORD
    LOCAL dwCurrentPos:DWORD
    LOCAL dwStartHex:DWORD
    LOCAL dwEndHex:DWORD
    LOCAL dwTmpPos:DWORD
    LOCAL ArrayHex[16]:DWORD
    LOCAL dwCountHex:DWORD
    LOCAL dwCurrentHex:DWORD
    LOCAL bHexFlag:DWORD
    
    .IF lpszStringToParse == 0 || lpszStringOutput == 0
        mov eax, FALSE
        ret
    .ENDIF
    
    Invoke szLen, lpszStringToParse
    .IF eax == 0
        mov eax, FALSE
        ret
    .ENDIF
    mov dwLenString, eax
    
    mov esi, lpszStringToParse
    mov edi, lpszStringOutput
    
    mov bHexFlag, FALSE
    mov dwCountHex, 0
    mov dwStartHex, 0
    mov dwEndHex,0 
    mov dwCurrentPos, 0
    mov eax, 0
    .WHILE eax < dwLenString

Continue:
        
        mov esi, lpszStringToParse
        add esi, dwCurrentPos
        movzx eax, byte ptr [esi]
   
        .IF (al >= 'a' && al <= 'f') || (al >= 'A' && al <= 'F') || (al >= '0' && al <= '9') 
            ; might be a hex value
            .IF al == '0'
                movzx ebx, byte ptr [esi+1]
                .IF bl == 'x'
                    
                    mov eax, dwCurrentPos
                    mov dwStartHex, eax
                    mov dwTmpPos, eax
                    add dwTmpPos, 2
                    add esi, 2
                    ;add dwCurrentPos, 2

                .ELSE
                    mov eax, dwCurrentPos
                    mov dwStartHex, eax
                    mov dwTmpPos, eax
                .ENDIF
            .ELSE
                mov eax, dwCurrentPos
                mov dwStartHex, eax
                mov dwTmpPos, eax
            .ENDIF
            
            movzx eax, byte ptr [esi]
            .WHILE (al >= 'a' && al <= 'f') || (al >= 'A' && al <= 'F') || (al >= '0' && al <= '9') ;&& al != 0 ;|| al == 'x'
                inc dwTmpPos
                inc esi
                movzx eax, byte ptr [esi]
                .IF al == 0
                    .BREAK
                .ENDIF
            .ENDW
            
            movzx eax, byte ptr [esi]
            .IF al == 0
                mov eax, dwLenString
                mov dwCurrentPos, eax
                mov eax, dwTmpPos
                mov dwEndHex, eax
                jmp ProcessHex

            .ELSEIF al == ']' || al == '(' || al == ')' || al == '[' || al == ',' || al == '*' || al == '+' || al == '-' ;|| al == ' ' 
                .IF al == ' '
                    ; doublecheck
                    movzx eax, byte ptr [esi-2]
                    .IF al >= 'g' && al <= 'z' || al >= 'G' && al <= 'Z'
                        ; false positive
                        mov eax, dwTmpPos
                        mov dwCurrentPos, eax
                        mov dwStartHex, 0
                        mov dwEndHex,0                        
                    .ELSE
                        mov eax, dwTmpPos
                        mov dwCurrentPos, eax
                        mov dwEndHex, eax
                        jmp ProcessHex
                    .ENDIF
                .ELSE
                    mov eax, dwTmpPos
                    mov dwCurrentPos, eax
                    mov dwEndHex, eax
                    jmp ProcessHex
                .ENDIF
            
            .ELSE ; false 
                mov eax, dwTmpPos
                mov dwCurrentPos, eax
                mov dwStartHex, 0
                mov dwEndHex,0
            .ENDIF

        .ELSEIF al == 0
            .IF dwStartHex != 0
                mov eax, dwLenString
                mov dwEndHex, eax
                jmp ProcessHex
            .ENDIF
        
        .ELSEIF al >= 'g' && al <= 'z' || al >= 'G' && al <= 'Z' ; skip over most words that start with g-z and any subsequent ascii and numerics till end of word
            movzx eax, byte ptr [esi]
            .WHILE (al >= 'a' && al <= 'z') || (al >= 'A' && al <= 'Z') || (al >= '0' && al <= '9') ;&& al != 0
                inc dwCurrentPos
                inc esi
                movzx eax, byte ptr [esi]
                .IF al == 0
                    .BREAK
                .ENDIF                
            .ENDW
            
        .ELSE
            inc dwCurrentPos
        .ENDIF

        mov eax, dwCurrentPos
    .ENDW

    .IF dwStartHex == 0
        jmp Finished
    .ENDIF

ProcessHex:

    ; do some processing
    
    mov ebx, 8
    mov eax, dwCountHex
    mul ebx
    lea ebx, ArrayHex
    add ebx, eax
    mov eax, dwStartHex
    mov [ebx], eax
    mov eax, dwEndHex
    mov [ebx+4], eax
    inc dwCountHex
    
    mov eax, dwCurrentPos
    .IF eax < dwLenString
        mov dwStartHex, 0
        mov dwEndHex,0
        mov bHexFlag, FALSE     
        jmp Continue
    .ENDIF

Finished:
    ;PrintDec dwCountHex
    ;lea ebx, ArrayHex
    ;DbgDump ebx, 16

    mov esi, lpszStringToParse
    mov edi, lpszStringOutput
    
    mov dwCurrentHex, 0
    mov dwCurrentPos, 0
    mov eax, 0
    .WHILE eax < dwLenString
    
        mov eax, dwCurrentHex
        .IF eax < dwCountHex
            mov ebx, 8
            mov eax, dwCurrentHex
            mul ebx
            lea ebx, ArrayHex
            add ebx, eax
            mov eax, [ebx]
            mov dwStartHex, eax
            mov eax, [ebx+4]
            mov dwEndHex, eax
        .ELSE
            mov dwStartHex, 0
            mov dwEndHex,0 
        .ENDIF

        .IF dwStartHex != 0
            mov eax, dwCurrentPos
            .WHILE eax < dwStartHex
                movzx eax, byte ptr [esi]
                mov byte ptr [edi], al
                inc esi
                inc edi
                inc dwCurrentPos
                mov eax, dwCurrentPos
            .ENDW
            
            ; start of hex
            
            .IF dwStyle == 0 ; c style hex - add 0x before all hex values
                movzx eax, byte ptr [esi]
                .IF al == '0'
                    movzx ebx, byte ptr [esi+1]
                    .IF bl == 'x'                
                        ; already has 0x
                    .ELSE
                        ; add 0x
                        mov byte ptr [edi], '0'
                        inc edi
                        mov byte ptr [edi], 'x'
                        inc edi
                    .ENDIF
                .ELSE
                    ; add 0x
                    mov byte ptr [edi], '0'
                    inc edi
                    mov byte ptr [edi], 'x'
                    inc edi
                .ENDIF
            
            .ELSE ; masm style hex - add 0 if A-F and remove 0x before hex values
                movzx eax, byte ptr [esi]
                .IF al == '0'
                    movzx ebx, byte ptr [esi+1]
                    .IF bl == 'x'
                        add esi, 2
                        add dwCurrentPos, 2
                        movzx eax, byte ptr [esi]
                    .ENDIF
                .ENDIF
                
                .IF al >= 'A' && al <= 'F'
                    mov byte ptr [edi], '0'
                    inc edi
                .ENDIF
                
            .ENDIF
            
            mov eax, dwCurrentPos
            .WHILE eax < dwEndHex
                movzx eax, byte ptr [esi]
                mov byte ptr [edi], al
                inc esi
                inc edi
                inc dwCurrentPos
                mov eax, dwCurrentPos
            .ENDW
            
            
            .IF dwStyle == 1 ; masm style hex - append 'h'
                mov byte ptr [edi], 'h'
                inc edi
            .ENDIF
            
            inc dwCurrentHex
            
        .ELSE
            movzx eax, byte ptr [esi]
            mov byte ptr [edi], al
            inc esi
            inc edi
            inc dwCurrentPos
        
        .ENDIF
        
        mov eax, dwCurrentPos
    .ENDW
    mov byte ptr [edi], 0h
    
    mov eax, TRUE
    ret

ConvertHexValues ENDP



;-------------------------------------------------------------------------------------
; Adds columns to the Reference View tab in x64dbg for displaying copied code
;-------------------------------------------------------------------------------------
CTA_AddColumnsToRefView PROC dwStartAddress:DWORD, dwFinishAddress:DWORD
    Invoke szCopy, addr szRefCopyToAsm, Addr szRefHdrMsg
    Invoke szCatStr, Addr szRefHdrMsg, Addr szModuleName
    Invoke szCatStr, Addr szRefHdrMsg, Addr szOffsetLeftBracket
    Invoke szCatStr, Addr szRefHdrMsg, Addr szHex
    Invoke dw2hex, dwStartAddress, Addr szValueString
    Invoke szCatStr, Addr szRefHdrMsg, Addr szValueString
    Invoke szCatStr, Addr szRefHdrMsg, Addr szModBaseHex
    Invoke szCatStr, Addr szRefHdrMsg, Addr szHex
    Invoke dw2hex, dwFinishAddress, Addr szValueString
    Invoke szCatStr, Addr szRefHdrMsg, Addr szValueString    
    Invoke szCatStr, Addr szRefHdrMsg, Addr szRightBracket
    Invoke GuiReferenceInitialize, Addr szRefHdrMsg
    Invoke GuiReferenceAddColumn, 0, Addr szRefAsmCode
    ;Invoke GuiReferenceSetCurrentTaskProgress, 0, Addr szRefCopyToAsmProcess
    Invoke GuiReferenceReloadData
    ret
CTA_AddColumnsToRefView ENDP


;-------------------------------------------------------------------------------------
; Adds a row of information about a code to the Reference View tab in x64dbg
;-------------------------------------------------------------------------------------
CTA_AddRowToRefView PROC dwCount:DWORD, lpszRowText:DWORD
    mov eax, dwCount
    inc eax
    Invoke GuiReferenceSetRowCount, eax
    Invoke GuiReferenceSetCellContent, dwCount, 0, lpszRowText
    mov eax, TRUE
    ret
CTA_AddRowToRefView ENDP



;--------------------------------------------------------------------------------------------------------------------
; Convert ascii string pointed to by String param to unsigned dword value. Returns dword value in eax.
;--------------------------------------------------------------------------------------------------------------------
OPTION PROLOGUE:NONE
OPTION EPILOGUE:NONE

align 16

atou_ex proc String:DWORD

  ; ------------------------------------------------
  ; Convert decimal string into UNSIGNED DWORD value
  ; ------------------------------------------------

    mov edx, [esp+4]

    xor ecx, ecx
    movzx eax, BYTE PTR [edx]
    test eax, eax
    jz quit

    lea ecx, [ecx+ecx*4]
    lea ecx, [eax+ecx*2-48]
    movzx eax, BYTE PTR [edx+1]
    test eax, eax
    jz quit

    lea ecx, [ecx+ecx*4]
    lea ecx, [eax+ecx*2-48]
    movzx eax, BYTE PTR [edx+2]
    test eax, eax
    jz quit

    lea ecx, [ecx+ecx*4]
    lea ecx, [eax+ecx*2-48]
    movzx eax, BYTE PTR [edx+3]
    test eax, eax
    jz quit

    lea ecx, [ecx+ecx*4]
    lea ecx, [eax+ecx*2-48]
    movzx eax, BYTE PTR [edx+4]
    test eax, eax
    jz quit

    lea ecx, [ecx+ecx*4]
    lea ecx, [eax+ecx*2-48]
    movzx eax, BYTE PTR [edx+5]
    test eax, eax
    jz quit

    lea ecx, [ecx+ecx*4]
    lea ecx, [eax+ecx*2-48]
    movzx eax, BYTE PTR [edx+6]
    test eax, eax
    jz quit

    lea ecx, [ecx+ecx*4]
    lea ecx, [eax+ecx*2-48]
    movzx eax, BYTE PTR [edx+7]
    test eax, eax
    jz quit

    lea ecx, [ecx+ecx*4]
    lea ecx, [eax+ecx*2-48]
    movzx eax, BYTE PTR [edx+8]
    test eax, eax
    jz quit

    lea ecx, [ecx+ecx*4]
    lea ecx, [eax+ecx*2-48]
    movzx eax, BYTE PTR [edx+9]
    test eax, eax
    jz quit

    lea ecx, [ecx+ecx*4]
    lea ecx, [eax+ecx*2-48]
    movzx eax, BYTE PTR [edx+10]
    test eax, eax
    jnz out_of_range

  quit:
    lea eax, [ecx]      ; return value in EAX
    or ecx, -1          ; non zero in ECX for success
    ret 4

  out_of_range:
    xor eax, eax        ; zero return value on error
    xor ecx, ecx        ; zero in ECX is out of range error
    ret 4

atou_ex endp

OPTION PROLOGUE:PrologueDef
OPTION EPILOGUE:EpilogueDef


; Paul Dixon's utoa_ex function. unsigned dword to ascii. 

OPTION PROLOGUE:NONE
OPTION EPILOGUE:NONE

    align 16

utoa_ex proc uvar:DWORD,pbuffer:DWORD

  ; --------------------------------------------------------------------------------
  ; this algorithm was written by Paul Dixon and has been converted to MASM notation
  ; --------------------------------------------------------------------------------

    mov eax, [esp+4]                ; uvar      : unsigned variable to convert
    mov ecx, [esp+8]                ; pbuffer   : pointer to result buffer

    push esi
    push edi

    jmp udword

  align 4
  chartab:
    dd "00","10","20","30","40","50","60","70","80","90"
    dd "01","11","21","31","41","51","61","71","81","91"
    dd "02","12","22","32","42","52","62","72","82","92"
    dd "03","13","23","33","43","53","63","73","83","93"
    dd "04","14","24","34","44","54","64","74","84","94"
    dd "05","15","25","35","45","55","65","75","85","95"
    dd "06","16","26","36","46","56","66","76","86","96"
    dd "07","17","27","37","47","57","67","77","87","97"
    dd "08","18","28","38","48","58","68","78","88","98"
    dd "09","19","29","39","49","59","69","79","89","99"

  udword:
    mov esi, ecx                    ; get pointer to answer
    mov edi, eax                    ; save a copy of the number

    mov edx, 0D1B71759h             ; =2^45\10000    13 bit extra shift
    mul edx                         ; gives 6 high digits in edx

    mov eax, 68DB9h                 ; =2^32\10000+1

    shr edx, 13                     ; correct for multiplier offset used to give better accuracy
    jz short skiphighdigits         ; if zero then don't need to process the top 6 digits

    mov ecx, edx                    ; get a copy of high digits
    imul ecx, 10000                 ; scale up high digits
    sub edi, ecx                    ; subtract high digits from original. EDI now = lower 4 digits

    mul edx                         ; get first 2 digits in edx
    mov ecx, 100                    ; load ready for later

    jnc short next1                 ; if zero, supress them by ignoring
    cmp edx, 9                      ; 1 digit or 2?
    ja   ZeroSupressed              ; 2 digits, just continue with pairs of digits to the end

    mov edx, chartab[edx*4]         ; look up 2 digits
    mov [esi], dh                   ; but only write the 1 we need, supress the leading zero
    inc esi                         ; update pointer by 1
    jmp  ZS1                        ; continue with pairs of digits to the end

  align 16
  next1:
    mul ecx                         ; get next 2 digits
    jnc short next2                 ; if zero, supress them by ignoring
    cmp edx, 9                      ; 1 digit or 2?
    ja   ZS1a                       ; 2 digits, just continue with pairs of digits to the end

    mov edx, chartab[edx*4]         ; look up 2 digits
    mov [esi], dh                   ; but only write the 1 we need, supress the leading zero
    add esi, 1                      ; update pointer by 1
    jmp  ZS2                        ; continue with pairs of digits to the end

  align 16
  next2:
    mul ecx                         ; get next 2 digits
    jnc short next3                 ; if zero, supress them by ignoring
    cmp edx, 9                      ; 1 digit or 2?
    ja   ZS2a                       ; 2 digits, just continue with pairs of digits to the end

    mov edx, chartab[edx*4]         ; look up 2 digits
    mov [esi], dh                   ; but only write the 1 we need, supress the leading zero
    add esi, 1                      ; update pointer by 1
    jmp  ZS3                        ; continue with pairs of digits to the end

  align 16
  next3:

  skiphighdigits:
    mov eax, edi                    ; get lower 4 digits
    mov ecx, 100

    mov edx, 28F5C29h               ; 2^32\100 +1
    mul edx
    jnc short next4                 ; if zero, supress them by ignoring
    cmp edx, 9                      ; 1 digit or 2?
    ja  short ZS3a                  ; 2 digits, just continue with pairs of digits to the end

    mov edx, chartab[edx*4]         ; look up 2 digits
    mov [esi], dh                   ; but only write the 1 we need, supress the leading zero
    inc esi                         ; update pointer by 1
    jmp short  ZS4                  ; continue with pairs of digits to the end

  align 16
  next4:
    mul ecx                         ; this is the last pair so don; t supress a single zero
    cmp edx, 9                      ; 1 digit or 2?
    ja  short ZS4a                  ; 2 digits, just continue with pairs of digits to the end

    mov edx, chartab[edx*4]         ; look up 2 digits
    mov [esi], dh                   ; but only write the 1 we need, supress the leading zero
    mov byte ptr [esi+1], 0         ; zero terminate string

    pop edi
    pop esi
    ret 8

  align 16
  ZeroSupressed:
    mov edx, chartab[edx*4]         ; look up 2 digits
    mov [esi], dx
    add esi, 2                      ; write them to answer

  ZS1:
    mul ecx                         ; get next 2 digits
  ZS1a:
    mov edx, chartab[edx*4]         ; look up 2 digits
    mov [esi], dx                   ; write them to answer
    add esi, 2

  ZS2:
    mul ecx                         ; get next 2 digits
  ZS2a:
    mov edx, chartab[edx*4]         ; look up 2 digits
    mov [esi], dx                   ; write them to answer
    add esi, 2

  ZS3:
    mov eax, edi                    ; get lower 4 digits
    mov edx, 28F5C29h               ; 2^32\100 +1
    mul edx                         ; edx= top pair
  ZS3a:
    mov edx, chartab[edx*4]         ; look up 2 digits
    mov [esi], dx                   ; write to answer
    add esi, 2                      ; update pointer

  ZS4:
    mul ecx                         ; get final 2 digits
  ZS4a:
    mov edx, chartab[edx*4]         ; look them up
    mov [esi], dx                   ; write to answer

    mov byte ptr [esi+2], 0         ; zero terminate string

  sdwordend:

    pop edi
    pop esi

    ret 8

utoa_ex endp

OPTION PROLOGUE:PrologueDef
OPTION EPILOGUE:EpilogueDef




END DllMain
















