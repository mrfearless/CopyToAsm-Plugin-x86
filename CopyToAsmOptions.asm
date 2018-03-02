include ModernUI.inc
includelib ModernUI.lib

include ModernUI_CaptionBar.inc
includelib ModernUI_CaptionBar.lib

include ModernUI_SmartPanel.inc
Includelib ModernUI_SmartPanel.lib

include ModernUI_Button.inc
includelib ModernUI_Button.lib

include ModernUI_Checkbox.inc
includelib ModernUI_Checkbox.lib

OptionsDlgProc              PROTO :DWORD, :DWORD, :DWORD, :DWORD
OptionsPanel0Proc           PROTO :DWORD, :DWORD, :DWORD, :DWORD
OptionsPanel1Proc           PROTO :DWORD, :DWORD, :DWORD, :DWORD
OptionsPanel2Proc           PROTO :DWORD, :DWORD, :DWORD, :DWORD
OptionsPanel3Proc           PROTO :DWORD, :DWORD, :DWORD, :DWORD




.CONST
ICO_OPTIONS_LABELS          EQU 130
ICO_OPTIONS_COMMENTS        EQU 131
ICO_OPTIONS_FORMATSTYLE     EQU 132
ICO_OPTIONS_EXIT            EQU 133

; MUI Caption bar images: ICO format
ICO_MUI_MIN                 EQU 140
ICO_MUI_MAX                 EQU 141
ICO_MUI_RES                 EQU 142
ICO_MUI_CLOSE               EQU 143
ICO_MUI_NOCHECKMARK         EQU 144
ICO_MUI_CHECKMARK           EQU 145
ICO_MUI_NOSETRADIO          EQU 146
ICO_MUI_RADIO               EQU 147


; Options Dialog
IDD_OPTIONSDLG              EQU 1000
IDC_CAPTIONBAR              EQU 1001
IDC_SP1                     EQU 1002
IDC_MENUTEXT                EQU 1009
IDC_OPTIONSMENUITEM0        EQU 1010
IDC_OPTIONSMENUITEM1        EQU 1011
IDC_OPTIONSMENUITEM2        EQU 1012
IDC_OPTIONSMENUITEM3        EQU 1013
IDC_OPTIONSMENUITEM4        EQU 1014
IDC_OPTIONSMENUITEM5        EQU 1015

;OptionsPanel0.dlg
IDD_OptionsPanel0			EQU 1500
IDC_CHECKBOX1               EQU 1501
IDC_CHECKBOX2               EQU 1502
IDC_CHECKBOX3               EQU 1503
IDC_CHECKBOX4               EQU 1504

;OptionsPanel1.dlg
IDD_OptionsPanel1			EQU 1600
IDC_CHECKBOX5               EQU 1601
IDC_CHECKBOX6               EQU 1602
IDC_CHECKBOX7               EQU 1603

;OptionsPanel2.dlg
IDD_OptionsPanel2			EQU 1700
IDC_RADIO1                  EQU 1701
IDC_RADIO2                  EQU 1702
IDC_INFOFORMATSTYLE			EQU 1710




.DATA
;---------------------------
; Options Dialog
;---------------------------
szOptionsDlgTitle           DB "CopyToAsm Options",0
szOptionsMenu0Text          DB 'Label Options',0
szOptionsMenu1Text          DB 'Comments Options',0
szOptionsMenu2Text          DB 'Format Style Options',0
szOptionsMenu3Text          DB 'Exit',0
szOptionsMenu4Text          DB ' ',0
szOptionsMenu5Text          DB ' ',0
szCheckbox1Text             DB 'Label name uses destination address',0
szCheckbox2Text             DB "Label name prepended with 'LABEL_'",0
szCheckbox3Text             DB 'Outside range labels for jumps/calls',0
szCheckbox4Text             DB 'Use x64dbg labels when present',0
szCheckbox5Text             DB 'Jumps with destination address',0
szCheckbox6Text             DB 'Internal calls with destination address',0
szCheckbox7Text             DB 'Destination addresses outside range',0
szCheckbox8Text             DB ' ',0
szCheckbox9Text             DB ' ',0
szRadio1Text                DB 'C Style - Prefix hex values with 0x',0
szRadio2Text                DB "MASM Style - Append hex values with 'h'",0                
szFormatStyle               DB "Hex value format style: ",0




.DATA?
hPreMenuBtn                 DD ?
hOptionsMenu0               DD ?
hOptionsMenu1               DD ?
hOptionsMenu2               DD ?
hOptionsMenu3               DD ?
hOptionsMenu4               DD ?
hOptionsMenu5               DD ?
hCaptionBar                 DD ?
hCurrentPanel               DD ?
hSP1                        DD ?
hOptionsPanel0              DD ?
hOptionsPanel1              DD ?
hOptionsPanel2              DD ?
hOptionsPanel3              DD ?
hChk1                       DD ?
hChk2                       DD ?
hChk3                       DD ?
hChk4                       DD ?
hChk5                       DD ?
hChk6                       DD ?
hChk7                       DD ?
hChk8                       DD ?
hChk9                       DD ?
hRadio1                     DD ?
hRadio2                     DD ?
hBtnFormatStyle             DD ?
hMenuText                   DD ?





.CODE


;=====================================================================================
; Options Dialog Procedure
;-------------------------------------------------------------------------------------
OptionsDlgProc PROC hWin:HWND,iMsg:DWORD,wParam:WPARAM, lParam:LPARAM

    mov eax, iMsg
    .IF eax == WM_INITDIALOG
        
        Invoke GetDlgItem, hWin, IDC_MENUTEXT
        mov hMenuText, eax
        Invoke SetWindowText, hMenuText, Addr szOptionsMenu0Text
        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_CaptionBar & ModernUI style dialog
        ;-----------------------------------------------------------------------------------------------------    
		Invoke MUIApplyToDialog, hWin, FALSE
		
		; Create CaptionBar control and save handle
		Invoke MUICaptionBarCreate, hWin, Addr szOptionsDlgTitle, 26, IDC_CAPTIONBAR, MUICS_WINNODROPSHADOW + MUICS_NOMAXBUTTON + MUICS_NOMINBUTTON + MUICS_LEFT ;or MUICS_REDCLOSEBUTTON
		mov hCaptionBar, eax

		; Set some properties for our CaptionBar control 
		Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBackColor, MUI_RGBCOLOR(27,161,226)
		Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnTxtRollColor, MUI_RGBCOLOR(61,61,61)
		Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnBckRollColor, MUI_RGBCOLOR(87,193,244)	

        ;-----------------------------------------------------------------------------------------------------
		; Create ModernUI_Button controls for our menu items
		Invoke MUIButtonCreate, hWin, Addr szOptionsMenu5Text, 1, 27, 220, 43, IDC_OPTIONSMENUITEM5, MUIBS_LEFT ;+ MUIBS_HAND
		mov hPreMenuBtn, eax
        Invoke MUIButtonSetAllProperties, hPreMenuBtn, Addr MUI_MENUITEM_DARK_THEME_BLANK_2, SIZEOF MUI_BUTTON_PROPERTIES		
		
		Invoke MUIButtonCreate, hWin, Addr szOptionsMenu0Text, 1, 70, 220, 45, IDC_OPTIONSMENUITEM0, MUIBS_LEFT ;+ MUIBS_HAND
		mov hOptionsMenu0, eax
		Invoke MUIButtonSetProperty, hOptionsMenu0, @ButtonDllInstance, hInstance
		Invoke MUIButtonLoadImages, hOptionsMenu0, MUIBIT_ICO, ICO_OPTIONS_LABELS, ICO_OPTIONS_LABELS, ICO_OPTIONS_LABELS, ICO_OPTIONS_LABELS, ICO_OPTIONS_LABELS
		Invoke MUIButtonSetAllProperties, hOptionsMenu0, Addr MUI_MENUITEM_DARK_THEME_2, SIZEOF MUI_BUTTON_PROPERTIES
		
		Invoke MUIButtonCreate, hWin, Addr szOptionsMenu1Text, 1, 115, 220, 45, IDC_OPTIONSMENUITEM1, MUIBS_LEFT + MUIBS_HAND
		mov hOptionsMenu1, eax
		Invoke MUIButtonSetProperty, hOptionsMenu1, @ButtonDllInstance, hInstance
		Invoke MUIButtonLoadImages, hOptionsMenu1, MUIBIT_ICO, ICO_OPTIONS_COMMENTS, ICO_OPTIONS_COMMENTS, ICO_OPTIONS_COMMENTS, ICO_OPTIONS_COMMENTS, ICO_OPTIONS_COMMENTS
		Invoke MUIButtonSetAllProperties, hOptionsMenu1, Addr MUI_MENUITEM_DARK_THEME_2, SIZEOF MUI_BUTTON_PROPERTIES

		Invoke MUIButtonCreate, hWin, Addr szOptionsMenu2Text, 1, 160, 220, 45, IDC_OPTIONSMENUITEM2, MUIBS_LEFT + MUIBS_HAND
		mov hOptionsMenu2, eax
		Invoke MUIButtonSetProperty, hOptionsMenu2, @ButtonDllInstance, hInstance
		Invoke MUIButtonLoadImages, hOptionsMenu2, MUIBIT_ICO, ICO_OPTIONS_FORMATSTYLE, ICO_OPTIONS_FORMATSTYLE, ICO_OPTIONS_FORMATSTYLE, ICO_OPTIONS_FORMATSTYLE, ICO_OPTIONS_FORMATSTYLE
        Invoke MUIButtonSetAllProperties, hOptionsMenu2, Addr MUI_MENUITEM_DARK_THEME_2, SIZEOF MUI_BUTTON_PROPERTIES

		Invoke MUIButtonCreate, hWin, Addr szOptionsMenu3Text, 1, 205, 220, 45, IDC_OPTIONSMENUITEM3, MUIBS_LEFT + MUIBS_HAND
		mov hOptionsMenu3, eax
		Invoke MUIButtonSetProperty, hOptionsMenu3, @ButtonDllInstance, hInstance
		Invoke MUIButtonLoadImages, hOptionsMenu3, MUIBIT_ICO, ICO_OPTIONS_EXIT, ICO_OPTIONS_EXIT, ICO_OPTIONS_EXIT, ICO_OPTIONS_EXIT, ICO_OPTIONS_EXIT
        Invoke MUIButtonSetAllProperties, hOptionsMenu3, Addr MUI_MENUITEM_DARK_THEME_2, SIZEOF MUI_BUTTON_PROPERTIES

		Invoke MUIButtonCreate, hWin, Addr szOptionsMenu4Text, 1, 250, 220, 45, IDC_OPTIONSMENUITEM4, MUIBS_LEFT ;+ MUIBS_HAND
		mov hOptionsMenu4, eax
        Invoke MUIButtonSetAllProperties, hOptionsMenu4, Addr MUI_MENUITEM_DARK_THEME_BLANK_2, SIZEOF MUI_BUTTON_PROPERTIES

        
        Invoke MUIButtonSetState, hOptionsMenu0, TRUE
        
    	; smart panel container
    	Invoke MUISmartPanelCreate, hWin, 221, 70, 387, 215, IDC_SP1, MUISPS_NORMAL ;327
    	mov hSP1, eax
    	
    	Invoke MUISmartPanelSetProperty, hSP1, @SmartPanelDllInstance, hInstance
    	;Invoke SmartPanelSetIsDlgMsgVar, hSP1, Addr hCurrentPanel
    	Invoke MUISmartPanelRegisterPanel, hSP1, IDD_OptionsPanel0, Addr OptionsPanel0Proc
    	mov hOptionsPanel0, eax
    	Invoke MUISmartPanelRegisterPanel, hSP1, IDD_OptionsPanel1, Addr OptionsPanel1Proc
    	mov hOptionsPanel1, eax
    	Invoke MUISmartPanelRegisterPanel, hSP1, IDD_OptionsPanel2, Addr OptionsPanel2Proc
    	mov hOptionsPanel2, eax
    	Invoke MUISmartPanelSetCurrentPanel, hSP1, 0, FALSE
    	;Invoke SendMessage, hSP1, MUISPM_SETCURRENTPANEL, 0, FALSE    
        

        
	;---------------------------------------------------------------------------------------------------------------
	; Handle painting of our dialog with our specified background and border color to mimic new Modern style UI feel
	;---------------------------------------------------------------------------------------------------------------
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

	.ELSEIF eax == WM_PAINT
		invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(240,240,240), MUI_RGBCOLOR(51,51,51) ;MUI_RGBCOLOR(27,161,226) 240,240,240
		mov eax, 0
		ret
    ;---------------------------------------------------------------------------------------------------------------


	.ELSEIF eax == WM_CLOSE
        Invoke EndDialog, hWin, NULL
        
	.ELSEIF eax == WM_COMMAND
        mov eax, wParam
        and eax, 0FFFFh
        .IF eax == IDC_OPTIONSMENUITEM0
	        Invoke MUIButtonSetState, hOptionsMenu0, TRUE
	        Invoke MUIButtonSetState, hOptionsMenu1, FALSE
	        Invoke MUIButtonSetState, hOptionsMenu2, FALSE
	        Invoke MUISmartPanelSetCurrentPanel, hSP1, 0, TRUE
	        Invoke SetWindowText, hMenuText, Addr szOptionsMenu0Text
	        
	    .ELSEIF eax == IDC_OPTIONSMENUITEM1
	        Invoke MUIButtonSetState, hOptionsMenu0, FALSE
	        Invoke MUIButtonSetState, hOptionsMenu1, TRUE
	        Invoke MUIButtonSetState, hOptionsMenu2, FALSE
	        Invoke MUISmartPanelSetCurrentPanel, hSP1, 1, TRUE
	        Invoke SetWindowText, hMenuText, Addr szOptionsMenu1Text
	    
	    .ELSEIF eax == IDC_OPTIONSMENUITEM2
	        Invoke MUIButtonSetState, hOptionsMenu0, FALSE
	        Invoke MUIButtonSetState, hOptionsMenu1, FALSE
	        Invoke MUIButtonSetState, hOptionsMenu2, TRUE
	        Invoke MUISmartPanelSetCurrentPanel, hSP1, 2, TRUE
	        Invoke SetWindowText, hMenuText, Addr szOptionsMenu2Text

        .ELSEIF eax == IDC_OPTIONSMENUITEM3
            Invoke SendMessage, hWin, WM_CLOSE, NULL, NULL

        .ENDIF
    .ELSE
        mov eax, FALSE
        ret
	.ENDIF
    mov eax, TRUE
    ret
OptionsDlgProc ENDP


;------------------------------------------------------------------------------
; OptionsPanel0Proc
;------------------------------------------------------------------------------
OptionsPanel0Proc PROC USES EBX hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	mov eax, uMsg
	.IF eax==WM_INITDIALOG
        IFDEF DEBUG32
        ;PrintText 'OptionsPanel1Proc:WM_INITDIALOG'
        ENDIF

        Invoke MUICheckboxCreate, hWin, Addr szCheckbox1Text, 20, 11, 350, 24, IDC_CHECKBOX1, MUICS_HAND
        mov hChk1, eax
        Invoke MUICheckboxSetProperty, hChk1, @CheckboxDllInstance, hInstance
        Invoke MUICheckboxLoadImages, hChk1, MUICIT_ICO, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK

        Invoke MUICheckboxCreate, hWin, Addr szCheckbox2Text, 20, 48, 350, 24, IDC_CHECKBOX2, MUICS_HAND
        mov hChk2, eax
        Invoke MUICheckboxSetProperty, hChk2, @CheckboxDllInstance, hInstance
        Invoke MUICheckboxLoadImages, hChk2, MUICIT_ICO, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK

        Invoke MUICheckboxCreate, hWin, Addr szCheckbox3Text, 20, 85, 350, 24, IDC_CHECKBOX3, MUICS_HAND
        mov hChk3, eax
        Invoke MUICheckboxSetProperty, hChk3, @CheckboxDllInstance, hInstance
        Invoke MUICheckboxLoadImages, hChk3, MUICIT_ICO, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK

        Invoke MUICheckboxCreate, hWin, Addr szCheckbox4Text, 20, 122, 350, 24, IDC_CHECKBOX4, MUICS_HAND
        mov hChk4, eax
        Invoke MUICheckboxSetProperty, hChk4, @CheckboxDllInstance, hInstance
        Invoke MUICheckboxLoadImages, hChk4, MUICIT_ICO, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK


        .IF g_LblUseAddress == 1
            Invoke MUICheckboxSetState, hChk1, TRUE
        .ENDIF
        .IF g_LblUseLabel == 1
            Invoke MUICheckboxSetState, hChk2, TRUE
        .ENDIF
        .IF g_OutsideRangeLabels == 1
            Invoke MUICheckboxSetState, hChk3, TRUE
        .ENDIF
        .IF g_LblUsex64dbgLabels == 1
            Invoke MUICheckboxSetState, hChk4, TRUE
        .ENDIF      

	.ELSEIF eax == WM_COMMAND
		mov	eax,wParam
		and	eax,0FFFFh
        .IF eax == IDC_CHECKBOX1
            Invoke MUICheckboxGetState, hChk1
            .IF eax == TRUE
                mov g_LblUseAddress, 1
                Invoke IniSetLblUseAddress, 1
            .ELSE
                mov g_LblUseAddress, 0
                Invoke IniSetLblUseAddress, 0
            .ENDIF

        .ELSEIF eax == IDC_CHECKBOX2
            Invoke MUICheckboxGetState, hChk2
            .IF eax == TRUE
                mov g_LblUseLabel, 1
                Invoke IniSetLblUseLabel, 1
            .ELSE
                mov g_LblUseLabel, 0
                Invoke IniSetLblUseLabel, 0
            .ENDIF

        .ELSEIF eax == IDC_CHECKBOX3
            Invoke MUICheckboxGetState, hChk3
            .IF eax == TRUE
                mov g_OutsideRangeLabels, 1
                Invoke IniSetOutsideRangeLabels, 1
            .ELSE
                mov g_OutsideRangeLabels, 0
                Invoke IniSetOutsideRangeLabels, 0
            .ENDIF
            
        .ELSEIF eax == IDC_CHECKBOX4
            Invoke MUICheckboxGetState, hChk4
            .IF eax == TRUE
                mov g_LblUsex64dbgLabels, 1
                Invoke IniSetLblUsex64dbgLabels, 1
            .ELSE
                mov g_LblUsex64dbgLabels, 0
                Invoke IniSetLblUsex64dbgLabels, 0
            .ENDIF
        .ENDIF


    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

	.ELSEIF eax == WM_PAINT
		invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(240,240,240), 0
		
	.ELSEIF eax==WM_CLOSE
	    invoke DestroyWindow, hWin
	.ELSE
      	mov eax,FALSE
		ret
	.ENDIF
	mov  eax,TRUE
	ret

OptionsPanel0Proc ENDP


;------------------------------------------------------------------------------
; OptionsPanel1Proc
;------------------------------------------------------------------------------
OptionsPanel1Proc PROC hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	mov eax, uMsg
	.IF eax==WM_INITDIALOG
        Invoke MUICheckboxCreate, hWin, Addr szCheckbox5Text, 20, 11, 350, 24, IDC_CHECKBOX5, MUICS_HAND
        mov hChk5, eax
        Invoke MUICheckboxSetProperty, hChk5, @CheckboxDllInstance, hInstance
        Invoke MUICheckboxLoadImages, hChk5, MUICIT_ICO, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK

        Invoke MUICheckboxCreate, hWin, Addr szCheckbox6Text, 20, 48, 350, 24, IDC_CHECKBOX6, MUICS_HAND
        mov hChk6, eax
        Invoke MUICheckboxSetProperty, hChk6, @CheckboxDllInstance, hInstance
        Invoke MUICheckboxLoadImages, hChk6, MUICIT_ICO, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK

        Invoke MUICheckboxCreate, hWin, Addr szCheckbox7Text, 20, 85, 350, 24, IDC_CHECKBOX7, MUICS_HAND
        mov hChk7, eax
        Invoke MUICheckboxSetProperty, hChk7, @CheckboxDllInstance, hInstance
        Invoke MUICheckboxLoadImages, hChk7, MUICIT_ICO, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_CHECKMARK, ICO_MUI_NOCHECKMARK, ICO_MUI_NOCHECKMARK

        .IF g_CmntJumpDest == 1
            Invoke MUICheckboxSetState, hChk5, TRUE
        .ENDIF
        .IF g_CmntCallDest == 1
            Invoke MUICheckboxSetState, hChk6, TRUE
        .ENDIF
        .IF g_CmntOutsideRange == 1
            Invoke MUICheckboxSetState, hChk7, TRUE
        .ENDIF

	.ELSEIF eax == WM_COMMAND
		mov	eax,wParam
		and	eax,0FFFFh
        .IF eax == IDC_CHECKBOX5
            Invoke MUICheckboxGetState, hChk5
            .IF eax == TRUE
                mov g_CmntJumpDest, 1
                Invoke IniSetCmntJumpDest, 1
            .ELSE
                mov g_CmntJumpDest, 0
                Invoke IniSetCmntJumpDest, 0
            .ENDIF
            ;Invoke CS_GenExampleFilename, g_ImageType
            ;Invoke SetWindowText, hBtnFileGen, Addr CODESHOT_EXAMPLEFILE            

        .ELSEIF eax == IDC_CHECKBOX6
            Invoke MUICheckboxGetState, hChk6
            .IF eax == TRUE
                mov g_CmntCallDest, 1
                Invoke IniSetCmntCallDest, 1
            .ELSE
                mov g_CmntCallDest, 0
                Invoke IniSetCmntCallDest, 0
            .ENDIF
            ;Invoke CS_GenExampleFilename, g_ImageType
            ;Invoke SetWindowText, hBtnFileGen, Addr CODESHOT_EXAMPLEFILE              

        .ELSEIF eax == IDC_CHECKBOX7
            Invoke MUICheckboxGetState, hChk7
            .IF eax == TRUE
                mov g_CmntOutsideRange, 1
                Invoke IniSetCmntOutsideRange, 1
            .ELSE
                mov g_CmntOutsideRange, 0
                Invoke IniSetCmntOutsideRange, 0
            .ENDIF
            ;Invoke CS_GenExampleFilename, g_ImageType
            ;Invoke SetWindowText, hBtnFileGen, Addr CODESHOT_EXAMPLEFILE  

        .ENDIF

    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

	.ELSEIF eax == WM_PAINT
		invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(240,240,240), 0
		
	.ELSEIF eax==WM_CLOSE
	    invoke DestroyWindow, hWin
	.ELSE
      	mov eax,FALSE
		ret
	.ENDIF
	mov  eax,TRUE
	ret

OptionsPanel1Proc ENDP


;------------------------------------------------------------------------------
; OptionsPanel2Proc
;------------------------------------------------------------------------------
OptionsPanel2Proc PROC hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	mov eax, uMsg
	.IF eax==WM_INITDIALOG

        Invoke MUIButtonCreate, hWin, Addr szFormatStyle, 20, 11, 350, 24, IDC_INFOFORMATSTYLE, MUIBS_LEFT
        mov hBtnFormatStyle, eax
        Invoke MUIButtonSetProperty, hBtnFormatStyle, @ButtonTextColor, MUI_RGBCOLOR(51,51,51)
        Invoke MUIButtonSetProperty, hBtnFormatStyle, @ButtonTextColorAlt, MUI_RGBCOLOR(51,51,51)
        Invoke MUIButtonSetProperty, hBtnFormatStyle, @ButtonBackColor, MUI_RGBCOLOR(240,240,240)
        Invoke MUIButtonSetProperty, hBtnFormatStyle, @ButtonBackColorAlt, MUI_RGBCOLOR(240,240,240)
        Invoke MUIButtonSetProperty, hBtnFormatStyle, @ButtonBorderStyle, MUIBBS_NONE
        
        Invoke MUICheckboxCreate, hWin, Addr szRadio1Text, 20, 48, 350, 24, IDC_RADIO1, MUICS_HAND
        mov hRadio1, eax
        Invoke MUICheckboxSetProperty, hRadio1, @CheckboxDllInstance, hInstance
        Invoke MUICheckboxLoadImages, hRadio1, MUICIT_ICO, ICO_MUI_NOSETRADIO, ICO_MUI_NOSETRADIO, ICO_MUI_RADIO, ICO_MUI_RADIO, ICO_MUI_RADIO, ICO_MUI_RADIO

        Invoke MUICheckboxCreate, hWin, Addr szRadio2Text, 20, 85, 350, 24, IDC_RADIO2, MUICS_HAND
        mov hRadio2, eax
        Invoke MUICheckboxSetProperty, hRadio2, @CheckboxDllInstance, hInstance
        Invoke MUICheckboxLoadImages, hRadio2, MUICIT_ICO, ICO_MUI_NOSETRADIO, ICO_MUI_NOSETRADIO, ICO_MUI_RADIO, ICO_MUI_RADIO, ICO_MUI_RADIO, ICO_MUI_RADIO

        mov eax, g_FormatType
        .IF eax == 0
            Invoke MUICheckboxSetState, hRadio1, TRUE
            Invoke MUICheckboxSetState, hRadio2, FALSE
        .ELSEIF eax == 1
            Invoke MUICheckboxSetState, hRadio1, FALSE
            Invoke MUICheckboxSetState, hRadio2, TRUE
        .ENDIF

	.ELSEIF eax == WM_COMMAND
		mov	eax,wParam
		and	eax,0FFFFh
        .IF eax == IDC_RADIO1
            Invoke MUICheckboxSetState, hRadio1, TRUE
            Invoke MUICheckboxSetState, hRadio2, FALSE
            mov g_FormatType, 0
            Invoke IniSetFormatType, 0

        .ELSEIF eax == IDC_RADIO2
            Invoke MUICheckboxSetState, hRadio1, FALSE
            Invoke MUICheckboxSetState, hRadio2, TRUE
            mov g_FormatType, 1
            Invoke IniSetFormatType, 1

        .ENDIF


    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

	.ELSEIF eax == WM_PAINT
		invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(240,240,240), 0
		
	.ELSEIF eax==WM_CLOSE
	    invoke DestroyWindow, hWin
	.ELSE
      	mov eax,FALSE
		ret
	.ENDIF
	mov  eax,TRUE
	ret

OptionsPanel2Proc ENDP

























