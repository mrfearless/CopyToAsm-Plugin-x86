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

IniGetLblUseAddress             PROTO
IniSetLblUseAddress             PROTO :DWORD
IniGetLblUseLabel               PROTO
IniSetLblUseLabel               PROTO :DWORD


.CODE



;**************************************************************************
;
;**************************************************************************
IniGetFormatType PROC
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szIniFormatType, 1, Addr CopyToAsmIni
    ret
IniGetFormatType ENDP


;**************************************************************************
;
;**************************************************************************
IniSetFormatType PROC dwValue:DWORD
    .IF dwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniFormatType, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniFormatType, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetFormatType ENDP


;**************************************************************************
;
;**************************************************************************
IniGetOutsideRangeLabels PROC
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szIniOutsideRangeLabels, 1, Addr CopyToAsmIni
    ret
IniGetOutsideRangeLabels ENDP


;**************************************************************************
;
;**************************************************************************
IniSetOutsideRangeLabels PROC dwValue:DWORD
    .IF dwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniOutsideRangeLabels, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniOutsideRangeLabels, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetOutsideRangeLabels ENDP



;**************************************************************************
;
;**************************************************************************
IniGetCmntOutsideRange PROC
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szIniCmntOutsideRange, 1, Addr CopyToAsmIni
    ret
IniGetCmntOutsideRange ENDP


;**************************************************************************
;
;**************************************************************************
IniSetCmntOutsideRange PROC dwValue:DWORD
    .IF dwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniCmntOutsideRange, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniCmntOutsideRange, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetCmntOutsideRange ENDP



;**************************************************************************
;
;**************************************************************************
IniGetCmntJumpDest PROC
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szIniCmntJumpDest, 1, Addr CopyToAsmIni
    ret
IniGetCmntJumpDest ENDP


;**************************************************************************
;
;**************************************************************************
IniSetCmntJumpDest PROC dwValue:DWORD
    .IF dwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniCmntJumpDest, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniCmntJumpDest, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetCmntJumpDest ENDP


;**************************************************************************
;
;**************************************************************************
IniGetCmntCallDest PROC
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szIniCmntCallDest, 1, Addr CopyToAsmIni
    ret
IniGetCmntCallDest ENDP


;**************************************************************************
;
;**************************************************************************
IniSetCmntCallDest PROC dwValue:DWORD
    .IF dwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniCmntCallDest, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniCmntCallDest, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetCmntCallDest ENDP


;**************************************************************************
;
;**************************************************************************
IniGetLblUseAddress PROC
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szIniLblUseAddress, 1, Addr CopyToAsmIni
    ret
IniGetLblUseAddress ENDP


;**************************************************************************
;
;**************************************************************************
IniSetLblUseAddress PROC dwValue:DWORD
    .IF dwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniLblUseAddress, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniLblUseAddress, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetLblUseAddress ENDP


;**************************************************************************
;
;**************************************************************************
IniGetLblUseLabel PROC
    Invoke GetPrivateProfileInt, Addr szCopyToAsm, Addr szIniLblUseLabel, 1, Addr CopyToAsmIni
    ret
IniGetLblUseLabel ENDP


;**************************************************************************
;
;**************************************************************************
IniSetLblUseLabel PROC dwValue:DWORD
    .IF dwValue == 0
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniLblUseLabel, Addr szZero, Addr CopyToAsmIni
    .ELSE
        Invoke WritePrivateProfileString, Addr szCopyToAsm, Addr szIniLblUseLabel, Addr szOne, Addr CopyToAsmIni
    .ENDIF
    ret
IniSetLblUseLabel ENDP




















