#ifndef M28W160ECT_INCLUDED
#define M28W160ECT_INCLUDED

enum
{
    ProgramCommand = 0x40,
    Reset = 0xff
} ;

enum
{
    ReadyBit = 1<<7,
    EraseSuspendBit = 1<<6,
    EraseErrorBit = 1<<5,
    ProgramErrorBit = 1<<4,
    VppErrorBit = 1<<3,
    ProgramSuspendBit = 1<<2,
    BlockProtectionErrorBit = 1<<1,
    ReservedBit = 1
} ;

enum
{
    CommandRegister = 0x0,
    StatusRegister = 0x0
} ;


#endif
