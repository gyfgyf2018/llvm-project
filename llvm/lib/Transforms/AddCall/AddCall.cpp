#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

namespace {
  struct AddCall : public ModulePass {
    static char ID;
    AddCall() : ModulePass(ID) {}

    bool runOnModule(Module &M) override {
      errs() << "Not Implemented ";
      errs().write_escaped(M.getName()) << '\n';
      return false;
    }
  };
}

char AddCall::ID = 0;
static RegisterPass<AddCall> X("addc", "Add an extern function call in main");
