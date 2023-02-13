
; flat assembler DLL interface for Win32
; Copyright (c) 1999-2015, Tomasz Grysztar.
; All rights reserved.

format PE DLL GUI 4.0
entry DLLEntryPoint

include 'win32a.inc'
include 'fasm.ash'

section '.data' data readable writeable

include 'variable.inc'

state dd ?
esp_save dd ?
source dd ?
source_position dd ?
first_write dd ?
first_write_length dd ?
second_write dd ?
second_write_length dd ?
display_pipe dd ?

systime SYSTEMTIME

tmp dd ?
buffer rb 1000h

section '.text' code readable executable

DLLEntryPoint:
	mov	eax,TRUE
	ret	12

fasm_GetVersion:
	mov	eax,VERSION_MAJOR + VERSION_MINOR shl 16
	ret

fasm_AssembleFile:

	mov	eax,[lpSource]
	mov	[input_file],eax
	mov	[output_file],null_byte

	jmp	setup_assembler

fasm_Assemble:

  virtual at esp+4
    lpSource dd ?
    lpMemory dd ?
    cbMemorySize dd ?
    nPassesLimit dd ?
    hDisplayPipe dd ?
  end virtual

	mov	eax,[lpSource]
	mov	[source],eax
	mov	[source_position],0

	mov	[input_file],null_byte
	mov	[output_file],null_byte

  setup_assembler:

	mov	eax,[nPassesLimit]
	cmp	eax,10000h
	ja	invalid_parameter
	or	eax,eax
	jz	invalid_parameter
	mov	[passes_limit],ax

	mov	eax,[lpMemory]
	mov	ecx,[cbMemorySize]
	mov	[state],eax
	mov	[eax+FASM_STATE.condition],FASM_WORKING
	sub	ecx,sizeof.FASM_STATE
	jbe	out_of_memory
	add	eax,sizeof.FASM_STATE
	mov	[memory_start],eax
	mov	edx,ecx
	shr	edx,2
	sub	ecx,edx
	add	eax,ecx
	mov	[memory_end],eax
	mov	[additional_memory],eax
	add	eax,edx
	mov	[additional_memory_end],eax

	xor	eax,eax
	mov	[initial_definitions],eax

	mov	[first_write],eax
	mov	[second_write],eax

	mov	eax,[hDisplayPipe]
	mov	[display_pipe],eax

	push	ebp ebx esi edi
	mov	eax,esp
	mov	[esp_save],eax
	and	eax,not 0FFFh
	add	eax,1000h-10000h
	mov	[stack_limit],eax

	call	preprocessor
	call	parser
	call	assembler
	call	formatter

	mov	ebx,[state]
	mov	[ebx+FASM_STATE.condition],FASM_OK

  done:
	mov	eax,[ebx+FASM_STATE.condition]
	pop	edi esi ebx ebp
	ret	20

  general_error:
	mov	esp,[esp_save]
	mov	ebx,[state]
	mov	[ebx+FASM_STATE.condition],eax
	jmp	done

  assembler_error:
	mov	esp,[esp_save]
	mov	ebx,[state]
	mov	[ebx+FASM_STATE.error_code],eax
	mov	eax,[current_line]
	mov	[ebx+FASM_STATE.error_line],eax
	mov	eax,FASM_ERROR
	jmp	general_error

  get_environment_variable:
	invoke	GetEnvironmentVariable,esi,buffer,1000h
	retn

  open:
	cmp	byte [edx],0
	je	open_memory
	invoke	CreateFile,edx,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,0,0
	cmp	eax,-1
	je	file_error
	mov	ebx,eax
	clc
	retn
    file_error:
	stc
	retn
    open_memory:
	xor	ebx,ebx
	retn
  read:
	or	ebx,ebx
	jz	read_memory
	mov	ebp,ecx
	invoke	ReadFile,ebx,edx,ecx,tmp,0
	or	eax,eax
	jz	file_error
	cmp	ebp,[tmp]
	jne	file_error
	clc
	retn
    read_memory:
	push	esi edi
	mov	esi,[source]
	add	esi,[source_position]
	mov	edi,edx
	call	move_block
	pop	edi esi
	clc
	retn
    move_block:
	mov	al,cl
	shr	ecx,2
	rep	movsd
	mov	cl,al
	and	cl,11b
	rep	movsb
	retn
  lseek:
	or	ebx,ebx
	jz	seek_memory
	movzx	eax,al
	invoke	SetFilePointer,ebx,edx,0,eax
	cmp	eax,-1
	je	file_error
	retn
    seek_memory:
	push	esi
	mov	esi,[source]
	mov	ecx,edx
	or	al,al
	jz	seek_forward
	add	esi,[source_position]
	cmp	al,2
	je	seek_source_end
    seek_forward:
	sub	ecx,1
	jc	seek_complete
    seek_in_source:
	lodsb
	or	al,al
	loopnz	seek_in_source
	jnz	seek_complete
	dec	esi
    seek_complete:
	mov	eax,esi
	sub	eax,[source]
	mov	[source_position],eax
	pop	esi
	retn
    seek_source_end:
	lodsb
	or	al,al
	jnz	seek_source_end
	dec	esi
	sub	esi,edx
	cmp	esi,[source]
	jae	seek_complete
	mov	esi,[source]
	jmp	seek_complete
  create:
	or	ebx,-1
	clc
	retn
  write:
	cmp	[first_write],0
	jne	make_second_write
	mov	[first_write],edx
	mov	[first_write_length],ecx
	clc
	retn
    make_second_write:
	cmp	[second_write],0
	jne	cannot_write
	mov	[second_write],edx
	mov	[second_write_length],ecx
	clc
	retn
    cannot_write:
	stc
	retn
  close:
	or	ebx,ebx
	jz	file_closed
	cmp	ebx,-1
	je	output_ready
	invoke	CloseHandle,ebx
    file_closed:
	retn
    output_ready:
	mov	ebx,[state]
	cmp	[second_write],0
	jne	two_part_output
	mov	eax,[first_write]
	mov	[ebx+FASM_STATE.output_data],eax
	mov	eax,[first_write_length]
	mov	[ebx+FASM_STATE.output_length],eax
	retn
    two_part_output:
	mov	eax,[second_write]
	mov	[ebx+FASM_STATE.output_data],eax
    shuffle_output:
	mov	ecx,[first_write_length]
	cmp	ecx,[second_write_length]
	ja	small_second_part
	sub	[second_write_length],ecx
	mov	esi,[first_write]
	mov	edi,[second_write]
	call	xchg_block
	mov	[second_write],edi
	jmp	shuffle_output
    xchg_block:
	shr	ecx,1
	jnc	xchgb_ok
	mov	al,[edi]
	xchg	al,[esi]
	stosb
	inc	esi
      xchgb_ok:
	shr	ecx,1
	jnc	xchgw_ok
	mov	ax,[edi]
	xchg	ax,[esi]
	stosw
	add	esi,2
      xchgw_ok:
	jz	xchgd_ok
      xchgd:
	mov	eax,[edi]
	xchg	eax,[esi]
	stosd
	add	esi,4
	loop	xchgd
      xchgd_ok:
	retn
    small_second_part:
	mov	edi,[second_write]
	mov	esi,edi
	add	edi,[first_write_length]
	cmp	edi,[first_write]
	jbe	move_second_part
	mov	edi,[first_write]
	add	edi,[first_write_length]
    move_second_part:
	push	edi
	mov	ecx,[second_write_length]
	lea	eax,[edi+ecx]
	cmp	eax,[tagged_blocks]
	ja	out_of_memory
	call	move_block
	mov	edi,[second_write]
	mov	esi,[first_write]
	mov	ecx,[first_write_length]
	call	move_block
	pop	esi
	mov	ecx,[second_write_length]
	call	move_block
	mov	ecx,edi
	sub	ecx,[ebx+FASM_STATE.output_data]
	mov	[ebx+FASM_STATE.output_length],ecx
	retn

  display_block:
	mov	eax,[display_pipe]
	or	eax,eax
	jz	display_ok
	invoke	WriteFile,eax,esi,ecx,tmp,NULL
    display_ok:
	retn

  make_timestamp:
	invoke	GetSystemTime,systime
	movzx	ecx,[systime.wYear]
	mov	eax,ecx
	sub	eax,1970
	mov	ebx,365
	mul	ebx
	mov	ebp,eax
	mov	eax,ecx
	sub	eax,1969
	shr	eax,2
	add	ebp,eax
	mov	eax,ecx
	sub	eax,1901
	mov	ebx,100
	div	ebx
	sub	ebp,eax
	mov	eax,ecx
	xor	edx,edx
	sub	eax,1601
	mov	ebx,400
	div	ebx
	add	ebp,eax
	movzx	ecx,[systime.wMonth]
	mov	eax,ecx
	dec	eax
	mov	ebx,30
	mul	ebx
	add	ebp,eax
	cmp	ecx,8
	jbe	months_correction
	mov	eax,ecx
	sub	eax,7
	shr	eax,1
	add	ebp,eax
	mov	ecx,8
      months_correction:
	mov	eax,ecx
	shr	eax,1
	add	ebp,eax
	cmp	ecx,2
	jbe	day_correction_ok
	sub	ebp,2
	movzx	ecx,word [systime.wYear]
	test	ecx,11b
	jnz	day_correction_ok
	xor	edx,edx
	mov	eax,ecx
	mov	ebx,100
	div	ebx
	or	edx,edx
	jnz	day_correction
	mov	eax,ecx
	mov	ebx,400
	div	ebx
	or	edx,edx
	jnz	day_correction_ok
      day_correction:
	inc	ebp
      day_correction_ok:
	movzx	eax,[systime.wDay]
	dec	eax
	add	eax,ebp
	mov	ebx,24
	mul	ebx
	movzx	ecx,[systime.wHour]
	add	eax,ecx
	mov	ebx,60
	mul	ebx
	movzx	ecx,[systime.wMinute]
	add	eax,ecx
	mov	ebx,60
	mul	ebx
	movzx	ecx,[systime.wSecond]
	add	eax,ecx
	retn

dump_symbols:
	retn

include 'errors.inc'

include 'preproce.inc'
include 'parser.inc'
include 'exprpars.inc'
include 'exprcalc.inc'
include 'assemble.inc'
include 'formats.inc'
include 'x86_64.inc'
include 'avx.inc'
include 'tables.inc'

include 'version.inc'

null_byte db 0

section '.idata' import data readable writeable

  library kernel32,'KERNEL32.DLL'

  include 'api\kernel32.inc'

section '.edata' export data readable

  export 'FASM.DLL',\
	 fasm_GetVersion,'fasm_GetVersion',\
	 fasm_Assemble,'fasm_Assemble',\
	 fasm_AssembleFile,'fasm_AssembleFile'

section '.reloc' fixups data readable discardable

section '.rsrc' resource data readable

  directory RT_VERSION,versions

  resource versions,\
	   1,LANG_NEUTRAL,version

  versioninfo version,VOS__WINDOWS32,VFT_APP,VFT2_UNKNOWN,LANG_ENGLISH+SUBLANG_DEFAULT,0,\
	      'FileDescription','flat assembler',\
	      'LegalCopyright',<'Copyright ',0A9h,' 2001-2015 Tomasz Grysztar.'>,\
	      'FileVersion',VERSION_STRING,\
	      'ProductVersion',VERSION_STRING,\
	      'OriginalFilename','FASM.DLL'
