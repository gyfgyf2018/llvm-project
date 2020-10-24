#include "llvm/Transforms/AddCall.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"

#define DEBUG_TYPE "ADD_CALL"
using namespace llvm;

namespace {
struct AddCall : public ModulePass {
  static char ID;
  AddCall() : ModulePass(ID) {}

  bool runOnModule(Module &M) override {
    for (auto &F : M) {
      errs() << F.getName() << "\n";
      if (F.getName() == "main") {
        errs() << "main detected\n";
      }
    }

    return false;
  }
};

} // namespace

char AddCall::ID = 0;
static RegisterPass<AddCall> X("addc", "Add an extern function call in main");

ModulePass *llvm::createAddCallPass() { return new AddCall(); }