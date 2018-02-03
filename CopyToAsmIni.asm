include advapi32.inc
includelib advapi32.lib

IniGetFormatType                PROTO
IniSetFormatType                PROTO :DWORD

IniGetOutsideRangeLabels        PROTO
IniSetOutsideRangeLabels        PROTO :DWORD
IniGetCmntOutsideRange          PROTO
IniSetCmntOutsideRange          PROTO :DWORD
IniGetCmntJumpDest              PROTO
IniSetCmntJumpDest              PROTO :DWORD
IniGetCmntCallDest              PROTO
IniSetCmntCallDest              PROTO :DWORD

.CODE



;**************************************************************************
;
;**************************************************************************
IniGetFormatType PROC
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szFormatType, 1, Addr CopyToAsmIni
    ret
IniGetFormatType ENDP


;**************************************************************************
;
;**************************************************************************
IniSetFormatType PROC dwValue:DWORD
    .IF dwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szFormatType, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szFormatType, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetFormatType ENDP


;**************************************************************************
;
;**************************************************************************
IniGetOutsideRangeLabels PROC
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szOutsideRangeLabels, 1, Addr CopyToAsmIni
    ret
IniGetOutsideRangeLabels ENDP


;**************************************************************************
;
;**************************************************************************
IniSetOutsideRangeLabels PROC dwValue:DWORD
    .IF dwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szOutsideRangeLabels, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szOutsideRangeLabels, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetOutsideRangeLabels ENDP



;**************************************************************************
;
;**************************************************************************
IniGetCmntOutsideRange PROC
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szCmntOutsideRange, 1, Addr CopyToAsmIni
    ret
IniGetCmntOutsideRange ENDP


;**************************************************************************
;
;**************************************************************************
IniSetCmntOutsideRange PROC dwValue:DWORD
    .IF dwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szCmntOutsideRange, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szCmntOutsideRange, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetCmntOutsideRange ENDP



;**************************************************************************
;
;**************************************************************************
IniGetCmntJumpDest PROC
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szCmntJumpDest, 1, Addr CopyToAsmIni
    ret
IniGetCmntJumpDest ENDP


;**************************************************************************
;
;**************************************************************************
IniSetCmntJumpDest PROC dwValue:DWORD
    .IF dwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szCmntJumpDest, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szCmntJumpDest, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetCmntJumpDest ENDP


;**************************************************************************
;
;**************************************************************************
IniGetCmntCallDest PROC
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szCmntCallDest, 1, Addr CopyToAsmIni
    ret
IniGetCmntCallDest ENDP


;**************************************************************************
;
;**************************************************************************
IniSetCmntCallDest PROC dwValue:DWORD
    .IF dwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szCmntCallDest, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szCmntCallDest, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetCmntCallDest ENDP



