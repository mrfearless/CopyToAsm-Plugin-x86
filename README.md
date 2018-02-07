# CopyToAsm Plugin (x86) - A Plugin For x64dbg

![](https://github.com/mrfearless/CopyToAsm-Plugin-x86/blob/master/images/copytoasmlogo.png) [Current version: 1.0.0.2 - Last updated: 07/02/2018](https://github.com/mrfearless/CopyToAsm-Plugin-x86/releases/latest) For the x64 version of this plugin, visit [here](https://github.com/mrfearless/CopyToAsm-Plugin-x64)

## Overview

A plugin to copy a selected disassembly range in the x64dbg cpu view tab and convert to a masm compatible style assembler code and output to clipboard or the reference view tab.

## Features

* Copy selected range to  assembler style code.
* Outputs assembler code to clipboard or reference view.
* Adds labels for jump destinations.
* Adjusts jump instructions to point to added labels.
* Indicates if jump destinations are outside selection range.
* Code comments to indicate start/end and outside range.
* Options to adjust comments and label outputs.

## How to install

* If x32dbg (x64dbg 32bit) is currently running, stop and exit.
* Copy the `CopyToAsm.dp32` to your `x64dbg\x32\plugins` folder.
* Start x32dbg

## Information

* Written by [fearless](https://github.com/mrfearless)  - [www.LetTheLight.in](http://www.LetTheLight.in)
* Created with the [x64dbg Plugin SDK For x86 Assembler](https://github.com/mrfearless/x64dbg-Plugin-SDK-For-x86-Assembler)
* A RadASM project (.rap) is used to manage and compile the plugin. The RadASM IDE can be downloaded [here](http://www.softpedia.com/get/Programming/File-Editors/RadASM.shtml)
* Some plugins make use of the MASM32 SDK found [here](http://www.masm32.com/masmdl.htm)

## x64dbg
* [x64dbg website](http://x64dbg.com)
* [x64dbg github](https://github.com/x64dbg/x64dbg)
* [x64dbg gitter](https://gitter.im/x64dbg/x64dbg)