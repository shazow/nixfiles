" Vim syntax file
" Language: EVM Bytecode Dump
" Maintainer: Your Name
" Latest Revision: 25 February 2025

if exists("b:current_syntax")
  finish
endif

" Case sensitive
syntax case match

" Line structure
syntax match evmLineNumber  '^\s*\d\+' nextgroup=evmOffset skipwhite
syntax match evmOffset      '\<0x[0-9a-fA-F]\+\>' nextgroup=evmOpcode skipwhite contained

" Opcodes by category
" Stack operations
syntax keyword evmOpcode    PUSH1 PUSH2 PUSH3 PUSH4 PUSH5 PUSH6 PUSH7 PUSH8 PUSH9 PUSH10 PUSH11 PUSH12 PUSH13 PUSH14 PUSH15 PUSH16 PUSH17 PUSH18 PUSH19 PUSH20 PUSH21 PUSH22 PUSH23 PUSH24 PUSH25 PUSH26 PUSH27 PUSH28 PUSH29 PUSH30 PUSH31 PUSH32 contained
syntax keyword evmOpcode    POP DUP1 DUP2 DUP3 DUP4 DUP5 DUP6 DUP7 DUP8 DUP9 DUP10 DUP11 DUP12 DUP13 DUP14 DUP15 DUP16 contained
syntax keyword evmOpcode    SWAP1 SWAP2 SWAP3 SWAP4 SWAP5 SWAP6 SWAP7 SWAP8 SWAP9 SWAP10 SWAP11 SWAP12 SWAP13 SWAP14 SWAP15 SWAP16 contained

" Memory operations
syntax keyword evmOpcode    MLOAD MSTORE MSTORE8 MSIZE contained

" Storage operations
syntax keyword evmOpcode    SLOAD SSTORE contained

" Flow control
syntax keyword evmFlowOpcode JUMP JUMPI JUMPDEST STOP RETURN REVERT INVALID SELFDESTRUCT contained

" Arithmetic operations
syntax keyword evmOpcode    ADD MUL SUB DIV SDIV MOD SMOD ADDMOD MULMOD EXP SIGNEXTEND contained

" Comparison & Bitwise Logic
syntax keyword evmOpcode    LT GT SLT SGT EQ ISZERO AND OR XOR NOT BYTE SHL SHR SAR contained

" Environmental information
syntax keyword evmOpcode    ADDRESS BALANCE ORIGIN CALLER CALLVALUE CALLDATALOAD CALLDATASIZE CALLDATACOPY CODESIZE CODECOPY GASPRICE EXTCODESIZE EXTCODECOPY RETURNDATASIZE RETURNDATACOPY EXTCODEHASH contained

" Block information
syntax keyword evmOpcode    BLOCKHASH COINBASE TIMESTAMP NUMBER DIFFICULTY GASLIMIT CHAINID SELFBALANCE BASEFEE contained

" System operations
syntax keyword evmOpcode    CREATE CREATE2 CALL CALLCODE DELEGATECALL STATICCALL contained

" Logging operations
syntax keyword evmOpcode    LOG0 LOG1 LOG2 LOG3 LOG4 contained

" Gas
syntax keyword evmOpcode    GAS contained

" Hex values
syntax match evmHex         '\<0x[0-9a-fA-F]\+\>' contained

" Link groups to highlighting
highlight def link evmLineNumber      LineNr
highlight def link evmOffset          Identifier
highlight def link evmOpcode          Statement
highlight def link evmFlowOpcode      Special
highlight def link evmHex             Number

" Link opcode with its argument
syntax match evmPushArg     '\<0x[0-9a-fA-F]\+\>\s*$' contained containedin=ALL

highlight def link evmPushArg         Constant

let b:current_syntax = "evmbytecode"
