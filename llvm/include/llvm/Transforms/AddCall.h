#ifndef ADDCALL_H
#define ADDCALL_H
namespace llvm{
    class ModulePass;
    extern ModulePass *createAddCallPass();
} 
#endif // !ADDCALL_H