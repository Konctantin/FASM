
; flat assembler core
; Copyright (c) 1999-2014, Tomasz Grysztar.
; All rights reserved.

invalid_parameter:
	mov	eax,FASM_INVALID_PARAMETER
	jmp	general_error
out_of_memory:
	mov	eax,FASM_OUT_OF_MEMORY
	jmp	general_error
stack_overflow:
	mov	eax,FASM_STACK_OVERFLOW
	jmp	general_error
main_file_not_found:
	mov	eax,FASM_SOURCE_NOT_FOUND
	jmp	general_error
unexpected_end_of_file:
	mov	eax,FASM_UNEXPECTED_END_OF_SOURCE
	jmp	general_error
code_cannot_be_generated:
	mov	eax,FASM_CANNOT_GENERATE_CODE
	jmp	general_error
format_limitations_exceeded:
	mov	eax,FASM_FORMAT_LIMITATIONS_EXCEDDED
	jmp	general_error
write_failed:
	mov	eax,FASM_WRITE_FAILED
	jmp	general_error

file_not_found:
	mov	eax,FASMERR_FILE_NOT_FOUND
	jmp	assembler_error
error_reading_file:
	mov	eax,FASMERR_ERROR_READING_FILE
	jmp	assembler_error
invalid_file_format:
	mov	eax,FASMERR_INVALID_FILE_FORMAT
	jmp	assembler_error
invalid_macro_arguments:
	mov	eax,FASMERR_INVALID_MACRO_ARGUMENTS
	jmp	assembler_error
incomplete_macro:
	mov	eax,FASMERR_INCOMPLETE_MACRO
	jmp	assembler_error
unexpected_characters:
	mov	eax,FASMERR_UNEXPECTED_CHARACTERS
	jmp	assembler_error
invalid_argument:
	mov	eax,FASMERR_INVALID_ARGUMENT
	jmp	assembler_error
illegal_instruction:
	mov	eax,FASMERR_ILLEGAL_INSTRUCTION
	jmp	assembler_error
invalid_operand:
	mov	eax,FASMERR_INVALID_OPERAND
	jmp	assembler_error
invalid_operand_size:
	mov	eax,FASMERR_INVALID_OPERAND_SIZE
	jmp	assembler_error
operand_size_not_specified:
	mov	eax,FASMERR_OPERAND_SIZE_NOT_SPECIFIED
	jmp	assembler_error
operand_sizes_do_not_match:
	mov	eax,FASMERR_OPERAND_SIZES_DO_NOT_MATCH
	jmp	assembler_error
invalid_address_size:
	mov	eax,FASMERR_INVALID_ADDRESS_SIZE
	jmp	assembler_error
address_sizes_do_not_agree:
	mov	eax,FASMERR_ADDRESS_SIZES_DO_NOT_AGREE
	jmp	assembler_error
disallowed_combination_of_registers:
	mov	eax,FASMERR_DISALLOWED_COMBINATION_OF_REGISTERS
	jmp	assembler_error
long_immediate_not_encodable:
	mov	eax,FASMERR_LONG_IMMEDIATE_NOT_ENCODABLE
	jmp	assembler_error
relative_jump_out_of_range:
	mov	eax,FASMERR_RELATIVE_JUMP_OUT_OF_RANGE
	jmp	assembler_error
invalid_expression:
	mov	eax,FASMERR_INVALID_EXPRESSION
	jmp	assembler_error
invalid_address:
	mov	eax,FASMERR_INVALID_ADDRESS
	jmp	assembler_error
invalid_value:
	mov	eax,FASMERR_INVALID_VALUE
	jmp	assembler_error
value_out_of_range:
	mov	eax,FASMERR_VALUE_OUT_OF_RANGE
	jmp	assembler_error
undefined_symbol:
	mov	eax,FASMERR_UNDEFINED_SYMBOL
	jmp	assembler_error
invalid_use_of_symbol:
	mov	eax,FASMERR_INVALID_USE_OF_SYMBOL
	jmp	assembler_error
name_too_long:
	mov	eax,FASMERR_NAME_TOO_LONG
	jmp	assembler_error
invalid_name:
	mov	eax,FASMERR_INVALID_NAME
	jmp	assembler_error
reserved_word_used_as_symbol:
	mov	eax,FASMERR_RESERVED_WORD_USED_AS_SYMBOL
	jmp	assembler_error
symbol_already_defined:
	mov	eax,FASMERR_SYMBOL_ALREADY_DEFINED
	jmp	assembler_error
symbol_out_of_scope:
	mov	eax,FASMERR_SYMBOL_OUT_OF_SCOPE
	jmp	assembler_error
missing_end_quote:
	mov	eax,FASMERR_MISSING_END_QUOTE
	jmp	assembler_error
missing_end_directive:
	mov	eax,FASMERR_MISSING_END_DIRECTIVE
	jmp	assembler_error
unexpected_instruction:
	mov	eax,FASMERR_UNEXPECTED_INSTRUCTION
	jmp	assembler_error
extra_characters_on_line:
	mov	eax,FASMERR_EXTRA_CHARACTERS_ON_LINE
	jmp	assembler_error
section_not_aligned_enough:
	mov	eax,FASMERR_SECTION_NOT_ALIGNED_ENOUGH
	jmp	assembler_error
setting_already_specified:
	mov	eax,FASMERR_SETTING_ALREADY_SPECIFIED
	jmp	assembler_error
data_already_defined:
	mov	eax,FASMERR_DATA_ALREADY_DEFINED
	jmp	assembler_error
too_many_repeats:
	mov	eax,FASMERR_TOO_MANY_REPEATS
	jmp	assembler_error
invoked_error:
	mov	eax,FASMERR_USER_ERROR
	jmp	assembler_error
assertion_failed:
	mov	eax,FASMERR_ASSERTION_FAILED
	jmp	assembler_error