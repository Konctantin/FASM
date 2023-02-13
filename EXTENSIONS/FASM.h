#pragma once

enum class FasmCondition : int
{
    OK                          = 00,
    WORKING                     = 01,
    FERROR                      = 02,
    INVALID_PARAMETER           = -1,
    OUT_OF_MEMORY               = -2,
    STACK_OVERFLOW              = -3,
    SOURCE_NOT_FOUND            = -4,
    UNEXPECTED_END_OF_SOURCE    = -5,
    CANNOT_GENERATE_CODE        = -6,
    FORMAT_LIMITATIONS_EXCEDDED = -7,
    WRITE_FAILED                = -8,
};

enum class FasmError : int
{
    FILE_NOT_FOUND                      = -101,
    ERROR_READING_FILE                  = -102,
    INVALID_FILE_FORMAT                 = -103,
    INVALID_MACRO_ARGUMENTS             = -104,
    INCOMPLETE_MACRO                    = -105,
    UNEXPECTED_CHARACTERS               = -106,
    INVALID_ARGUMENT                    = -107,
    ILLEGAL_INSTRUCTION                 = -108,
    INVALID_OPERAND                     = -109,
    INVALID_OPERAND_SIZE                = -110,
    OPERAND_SIZE_NOT_SPECIFIED          = -111,
    OPERAND_SIZES_DO_NOT_MATCH          = -112,
    INVALID_ADDRESS_SIZE                = -113,
    ADDRESS_SIZES_DO_NOT_AGREE          = -114,
    DISALLOWED_COMBINATION_OF_REGISTERS = -115,
    LONG_IMMEDIATE_NOT_ENCODABLE        = -116,
    RELATIVE_JUMP_OUT_OF_RANGE          = -117,
    INVALID_EXPRESSION                  = -118,
    INVALID_ADDRESS                     = -119,
    INVALID_VALUE                       = -120,
    VALUE_OUT_OF_RANGE                  = -121,
    UNDEFINED_SYMBOL                    = -122,
    INVALID_USE_OF_SYMBOL               = -123,
    NAME_TOO_LONG                       = -124,
    INVALID_NAME                        = -125,
    RESERVED_WORD_USED_AS_SYMBOL        = -126,
    SYMBOL_ALREADY_DEFINED              = -127,
    MISSING_END_QUOTE                   = -128,
    MISSING_END_DIRECTIVE               = -129,
    UNEXPECTED_INSTRUCTION              = -130,
    EXTRA_CHARACTERS_ON_LINE            = -131,
    SECTION_NOT_ALIGNED_ENOUGH          = -132,
    SETTING_ALREADY_SPECIFIED           = -133,
    DATA_ALREADY_DEFINED                = -134,
    TOO_MANY_REPEATS                    = -135,
    SYMBOL_OUT_OF_SCOPE                 = -136,
    USER_ERROR                          = -140,
    ASSERTION_FAILED                    = -141,
};

typedef struct _FasmLineHeader {
    char* file_path;
    int line_number;
    union {
        int file_offset;
        int macro_offset_line;
    };
    _FasmLineHeader* macro_line;
} FASM_LINE_HEADER;

typedef struct _FasmState {
    FasmCondition condition;
    union {
        FasmError error_code;
        int output_length;
    };
    union {
        __int8* output_data;
        _FasmLineHeader* error_data;
    };
} FASM_STATE;

extern "C" int __cdecl fasm_Assemble(char* szSource, __int8* lpMemory, int nSize, int nPassesLimit, int hDisplayPipe);
extern "C" int __cdecl fasm_GetVersion();