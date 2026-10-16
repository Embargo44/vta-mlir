//                                IMPLEMENTS PASSES. CALLED FROM VTA-OPT AND VTA-TRANSLATE
//======================================================================================================================//

// Order matters:
//   1. mlir/Pass/Pass.h brings OperationPass into scope.
//   2. `using namespace mlir` is required because the generated VTAPasses.h.inc refers to `ModuleOp` unqualified.
//   3. GEN_PASS_CLASSES must be defined before the .inc, because the .inc gates the base-class block on it.


//custom description file for hardware
#include "VTA/CustomHardwareDescription.h"

// Standard MLIR infrastructure.
#include "mlir/IR/BuiltinOps.h"           
#include "mlir/Pass/Pass.h"               
#include "mlir/Pass/PassManager.h"        
#include "mlir/Dialect/Func/IR/FuncOps.h" 

// Generated from VTAOps.td 
#include "VTA/VTADialect.h"               
#include "VTA/VTAOps.h"              

using namespace mlir;

#define GEN_PASS_CLASSES
#include "VTA/VTAPasses.h.inc"

#include "VTA/Passes.h"  // factory declarations for the passes



namespace mlir { namespace vta { namespace {

//========================================================================================================================//
//                                        //PASS DECLARATIONS
//========================================================================================================================//





//Checks program shape: one function, VTA ops inside it, one finish last, at least one load.
struct CheckStructurePass : public CheckStructureBase<CheckStructurePass> {
    void runOnOperation() override;};    
//========================================================================================================================//
//Everything tied to the ucode op: first op is ucode, exactly one, UopEnd fits size.
struct CheckUcodePass : public CheckUcodeBase<CheckUcodePass> {
    void runOnOperation() override;
};
    


//========================================================================================================================//
//Inserts a vta.load that copies the ucode records into uop SRAM.
struct TransformUcodeToLoadOpPass : public TransformUcodeToLoadOpBase<TransformUcodeToLoadOpPass> {
    void runOnOperation() override;}; 
//========================================================================================================================//
//Rewrites load_noop / store_noop into real zero-size LoadOp / StoreOp.
struct TransformNoOpsPass : public TransformNoOpsBase<TransformNoOpsPass> {
    void runOnOperation() override;};


//========================================================================================================================//
//Scans the token queues for balance, dead flags, and unreachable finish.
struct CheckDependancyPass : public CheckDependancyBase<CheckDependancyPass> {
    void runOnOperation() override;};   

//========================================================================================================================//
//Merges duplicate ucodes, moves ucode to top of body, trims ops after finish.
struct TransformGeneralStructurePass : public TransformGeneralStructureBase<TransformGeneralStructurePass> {
    void runOnOperation() override;};
   



//========================================================================================================================//
//                                        //PASSES FUNCTIONALITY
//========================================================================================================================//


//Checks program shape: one function, VTA ops inside it, one finish last, at least one load.
void CheckStructurePass::runOnOperation() {
    ModuleOp module = getOperation();

    //walk
    llvm::SmallVector<Operation*> opSnapshot;  //vector snapshot never gets updated
    module.walk([&](Operation *op) {
    if (isa<vta::UcodeOp, vta::LoadOp, vta::StoreOp,
            vta::GemmOp, vta::AluOp, vta::FinishOp>(op))
        opSnapshot.push_back(op); 
    });



    if (opSnapshot.empty()) {
        module.emitError("module contains no VTA ops");
        signalPassFailure();
        return;
    }

    // Exactly one func.func.
    llvm::SmallVector<func::FuncOp> funcs;
    module.walk([&](func::FuncOp f) { funcs.push_back(f); });
    if (funcs.size() != 1) {
        module.emitError("expected exactly one func.func, found ")
            << funcs.size();
        signalPassFailure();
        return;
    }
    func::FuncOp func = funcs[0];


    // Every VTA op inside a func.func.
    for (Operation *op : opSnapshot) {
        if (!op->getParentOfType<func::FuncOp>()) {
            op->emitOpError("VTA op must be inside a func.func");
            signalPassFailure();
            return;
        }
    }

    // No non-VTA ops inside the function body.
    Block &body = func.getBody().front();
    for (Operation &op : body) {
        if (isa<vta::UcodeOp, vta::LoadOp, vta::StoreOp,
                vta::GemmOp, vta::AluOp, vta::FinishOp,
                vta::LoadNoOp, vta::StoreNoOp>(&op))
            continue;
        if (op.hasTrait<OpTrait::IsTerminator>())
            continue;
        op.emitOpError("unexpected non-VTA op inside VTA function");
        signalPassFailure();
        return;
    }

    // Exactly one vta.finish.
    int finishCount = 0;
    for (Operation *op : opSnapshot)
        if (isa<vta::FinishOp>(op)) finishCount++;
    if (finishCount != 1) {
        module.emitError("expected exactly one vta.finish, found ")
            << finishCount;
        signalPassFailure();
        return;
    }

    // Last VTA op must be vta.finish.
    if (!isa<vta::FinishOp>(opSnapshot.back())) {
        opSnapshot.back()->emitOpError("last VTA op must be vta.finish");
        signalPassFailure();
        return;
    }

     // At least one vta.load.
    bool hasLoad = false;
    for (Operation *op : opSnapshot)
        if (isa<vta::LoadOp>(op)) { hasLoad = true; break; }
    if (!hasLoad) {
        module.emitError("module must contain at least one vta.load");
        signalPassFailure();
        return;
    }

    // Nested call to CheckUcode. Because also part of the Gen Struct
    PassManager inner(module.getContext());
    inner.addPass(createCheckUcodePass());
    if (failed(inner.run(module)))
        signalPassFailure();
}
//===============================================================================//
//Everything that has to do with the ucode op.
void CheckUcodePass::runOnOperation() {
    ModuleOp module = getOperation();

    //walk
    llvm::SmallVector<Operation*> opSnapshot; //Just a snapshot
    module.walk([&](Operation *op) {
        if (isa<vta::UcodeOp, vta::LoadOp, vta::StoreOp,
                vta::GemmOp, vta::AluOp, vta::FinishOp>(op))
            opSnapshot.push_back(op);
    });

    if (opSnapshot.empty()) {
        module.emitError("module contains no VTA ops");
        signalPassFailure();
        return;
    }

    // First VTA op must be ucode.
    if (!isa<vta::UcodeOp>(opSnapshot[0])) {
        opSnapshot[0]->emitOpError("first VTA op must be vta.ucode");
        signalPassFailure();
        return;
    }

    // Exactly one ucode.
    int ucodeCount = 0;
    vta::UcodeOp theUcode;
    for (Operation *op : opSnapshot) {
        if (auto u = dyn_cast<vta::UcodeOp>(op)) {
            ucodeCount++;
            theUcode = u;
        }
    }
    if (ucodeCount != 1) {
        module.emitError("expected exactly one vta.ucode, found ")
            << ucodeCount;
        signalPassFailure();
        return;
    }

    // Every gemm/alu's UopEnd fits the ucode size.
    unsigned n = theUcode.getRecords().size();
    for (Operation *op : opSnapshot) {
        if (auto g = dyn_cast<vta::GemmOp>(op)) {
            if (g.getUopEnd() > n) {
                g.emitOpError("UopEnd exceeds ucode record count");
                signalPassFailure();
                return;
            }
        }
        if (auto a = dyn_cast<vta::AluOp>(op)) {
            if (a.getUopEnd() > n) {
                a.emitOpError("UopEnd exceeds ucode record count");
                signalPassFailure();
                return;
            }
        }
    }
}


//===============================================================================//
 //CHECK_DEPENDANCY_PASS
    // OpKind: what pipeline role an op plays. Flag: the four dependency bits.
    // Queue: the four token queues between stages.
    enum class OpKind { Load, Compute, Store, Finish, None };
    enum class Flag   { WaitPrev, WaitNext, SignalPrev, SignalNext, None };
    enum class Queue  { LoadToCompute, ComputeToLoad, ComputeToStore, StoreToCompute, None };

    
    // Map an op to its pipeline role
    static OpKind kindOf(Operation *op) {
        if (isa<vta::LoadOp>(op))   return OpKind::Load;
        if (isa<vta::StoreOp>(op))  return OpKind::Store;
        if (isa<vta::GemmOp>(op))   return OpKind::Compute;
        if (isa<vta::AluOp>(op))    return OpKind::Compute;
        if (isa<vta::FinishOp>(op)) return OpKind::Finish;
        return OpKind::None;
    }

    // Load only talks to compute (next side), store only on prev. Compute touches all four.
    static bool isFlagLive(OpKind k, Flag f) {
        switch (k) {
        case OpKind::Load:
            return f == Flag::WaitNext || f == Flag::SignalNext;
        case OpKind::Compute:
            return true;
        case OpKind::Store:
            return f == Flag::WaitPrev || f == Flag::SignalPrev;
        case OpKind::Finish:
        case OpKind::None:
            return false;
        }
        return false;
    }

    
    // Read a flag from an op, whatever its concrete type.
    template <typename OpT>
    static bool readFlagFor(OpT o, Flag f) {
        switch (f) {
        case Flag::WaitPrev:   return o.getPopPrevDep();
        case Flag::WaitNext:   return o.getPopNextDep();
        case Flag::SignalPrev: return o.getPushPrevDep();
        case Flag::SignalNext: return o.getPushNextDep();
        default: return false;
        }
    }

    static bool readFlag(Operation *op, Flag f) {
        if (auto o = dyn_cast<vta::LoadOp>(op))  return readFlagFor(o, f);
        if (auto o = dyn_cast<vta::StoreOp>(op)) return readFlagFor(o, f);
        if (auto o = dyn_cast<vta::GemmOp>(op))  return readFlagFor(o, f);
        if (auto o = dyn_cast<vta::AluOp>(op))   return readFlagFor(o, f);
        return false;
    }

    
    // Which queue a flag touches for an op kind. Dead flags return None.
    static Queue queueOf(OpKind k, Flag f) {
        if (!isFlagLive(k, f)) return Queue::None;

        if (k == OpKind::Load) {
            if (f == Flag::WaitNext)   return Queue::ComputeToLoad;
            if (f == Flag::SignalNext) return Queue::LoadToCompute;
        }
        if (k == OpKind::Compute) {
            if (f == Flag::WaitPrev)   return Queue::LoadToCompute;
            if (f == Flag::WaitNext)   return Queue::StoreToCompute;
            if (f == Flag::SignalPrev) return Queue::ComputeToLoad;
            if (f == Flag::SignalNext) return Queue::ComputeToStore;
        }
        if (k == OpKind::Store) {
            if (f == Flag::WaitPrev)   return Queue::ComputeToStore;
            if (f == Flag::SignalPrev) return Queue::StoreToCompute;
        }
        return Queue::None;
    }

    //===============================================================================//
    void CheckDependancyPass::runOnOperation() {
        ModuleOp module = getOperation();

        //walk
        llvm::SmallVector<Operation*> opSnapshot;//// Snapshot of VTA ops in program order.
        module.walk([&](Operation *op) {
            if (isa<vta::UcodeOp, vta::LoadOp, vta::StoreOp,
                    vta::GemmOp, vta::AluOp, vta::FinishOp>(op))
                opSnapshot.push_back(op);
        });

        
        const Flag flags[] = { Flag::WaitPrev, Flag::WaitNext,
                            Flag::SignalPrev, Flag::SignalNext };

        // Check 1: warn on any flag that has no effect for its op kind.
        for (Operation *op : opSnapshot) {
            OpKind k = kindOf(op);
            if (k == OpKind::None || k == OpKind::Finish) continue;
            for (int i = 0; i < 4; i++) {
                if (readFlag(op, flags[i]) && !isFlagLive(k, flags[i]))
                    op->emitWarning("this flag has no effect for this op kind");
            }
        }

        // One counter per queue. Signals increment, waits decrement.
        int loadToCompute  = 0;
        int computeToLoad  = 0;
        int computeToStore = 0;
        int storeToCompute = 0;

        bool anyFlagSet = false;
        Operation *firstStuckOp = nullptr;
        Operation *finishOp = nullptr;

        // Decrement. False if the counter would go negative, i.e. a wait has no matching signal earlier in program order.
        auto dec = [&](Queue q, Operation *op) -> bool {
            switch (q) {
            case Queue::LoadToCompute:
                if (loadToCompute == 0) return false;
                loadToCompute--; return true;
            case Queue::ComputeToLoad:
                if (computeToLoad == 0) return false;
                computeToLoad--; return true;
            case Queue::ComputeToStore:
                if (computeToStore == 0) return false;
                computeToStore--; return true;
            case Queue::StoreToCompute:
                if (storeToCompute == 0) return false;
                storeToCompute--; return true;
            default: return true;
            }
        };

        auto inc = [&](Queue q) {
            switch (q) {
            case Queue::LoadToCompute:  loadToCompute++;  break;
            case Queue::ComputeToLoad:  computeToLoad++;  break;
            case Queue::ComputeToStore: computeToStore++; break;
            case Queue::StoreToCompute: storeToCompute++; break;
            default: break;
            }
        };

        // Walk in program order, updating counters. Record first stuck op and first finish op.
        for (Operation *op : opSnapshot) {
            OpKind k = kindOf(op);

            if (k == OpKind::Finish) {
                if (!finishOp) finishOp = op;
                continue;
            }
            if (k == OpKind::None) continue;

            for (int i = 0; i < 4; i++) {
                Flag f = flags[i];
                if (!readFlag(op, f)) continue;
                anyFlagSet = true;

                Queue q = queueOf(k, f);
                if (q == Queue::None) continue;  // dead flag, already warned in check 1

                bool isWait = (f == Flag::WaitPrev || f == Flag::WaitNext);
                if (isWait) {
                    if (!dec(q, op) && !firstStuckOp)
                        firstStuckOp = op;
                } else {
                    inc(q);
                }
            }
        }

        // no flags anywhere.
        if (!anyFlagSet) {
            module.emitWarning("no dependency flags set anywhere; "
                            "this program will likely hang in the simulator");
        }

        // end balance. Positive -> extra signals, warn. Negative -> extra waits, they block, error.
        auto reportQueue = [&](const char *name, int value) -> LogicalResult {
            if (value > 0) {
                module.emitWarning() << name << " has " << value
                                    << " unconsumed token(s)";
                return success();
            }
            if (value < 0) {
                module.emitError() << name << " has " << -value
                                << " unconsumed wait(s); simulator will block";
                return failure();
            }
            return success();
        };

        bool balanceOk = true;
        balanceOk &= succeeded(reportQueue("LoadToCompute",  loadToCompute));
        balanceOk &= succeeded(reportQueue("ComputeToLoad",  computeToLoad));
        balanceOk &= succeeded(reportQueue("ComputeToStore", computeToStore));
        balanceOk &= succeeded(reportQueue("StoreToCompute", storeToCompute));

        // stuck op before finish means finish is unreachable.
        if (firstStuckOp && finishOp && firstStuckOp->isBeforeInBlock(finishOp)) {
            module.emitWarning("execution cannot reach vta.finish: "
                            "an earlier op waits on a queue that is never signaled");
        }

        if (!balanceOk)
            signalPassFailure();
    
}


//===============================================================================//
//Ucode has to be loaded. This does that
void TransformUcodeToLoadOpPass::runOnOperation() {
    ModuleOp module = getOperation();

    module.walk([&](vta::UcodeOp ucodeOp) {                                  
    OpBuilder builder(ucodeOp);                                          
    builder.setInsertionPointAfter(ucodeOp);                             
    unsigned int n = ucodeOp.getRecords().size();                       

    builder.create<vta::LoadOp>(
                ucodeOp.getLoc(),
                (bool)false, (bool)false, (bool)false, (bool)false,
                (uint8_t)0, (uint16_t)0, (uint32_t)0,
                (uint16_t)1, (uint16_t)n, (uint16_t)n,
                (uint8_t)0, (uint8_t)0, (uint8_t)0, (uint8_t)0);  
                //cast everiething for safet. If not problems (change at your own peril)
    });                                                                     
}

//===============================================================================//
//Rewrites load_noop / store_noop into real zero-size LoadOp / StoreOp.
 void TransformNoOpsPass::runOnOperation() {
    ModuleOp module = getOperation();

    llvm::SmallVector<Operation*> noopSnapshot;
    module.walk([&](Operation *op) {
        if (isa<vta::LoadNoOp, vta::StoreNoOp>(op))
            noopSnapshot.push_back(op);
    });

    for (Operation *op : noopSnapshot) {
        OpBuilder builder(op);

        if (auto ln = dyn_cast<vta::LoadNoOp>(op)) {
            builder.create<vta::LoadOp>(
                ln.getLoc(),
                ln.getPopPrevDep(), ln.getPopNextDep(),
                ln.getPushPrevDep(), ln.getPushNextDep(),
                (uint8_t)VTA_MEM_INP,
                (uint16_t)0, (uint32_t)0,
                (uint16_t)0, (uint16_t)0, (uint16_t)0,
                (uint8_t)0, (uint8_t)0, (uint8_t)0, (uint8_t)0);
        } else if (auto sn = dyn_cast<vta::StoreNoOp>(op)) {
            builder.create<vta::StoreOp>(
                sn.getLoc(),
                sn.getPopPrevDep(), sn.getPopNextDep(),
                sn.getPushPrevDep(), sn.getPushNextDep(),
                (uint8_t)VTA_MEM_OUT,
                (uint16_t)0, (uint32_t)0,
                (uint16_t)0, (uint16_t)0, (uint16_t)0,
                (uint8_t)0, (uint8_t)0, (uint8_t)0, (uint8_t)0);
        }

        op->erase();
    
    }
}  




//===============================================================================//
//Minor Transformations on the General Structure 
//(kinda useless. Might get turned into the actual merge ucode)
void TransformGeneralStructurePass::runOnOperation() {
    ModuleOp module = getOperation();

    llvm::SmallVector<Operation*> opSnapshot; 
    module.walk([&](Operation *op) {
        if (isa<vta::UcodeOp, vta::LoadOp, vta::StoreOp,
                vta::GemmOp, vta::AluOp, vta::FinishOp,
                vta::LoadNoOp, vta::StoreNoOp>(op))
            opSnapshot.push_back(op);
    });

        //  Merge duplicate ucodes. If records differ, error.
        //  Keep the first one, erase the rest if identical.
        llvm::SmallVector<vta::UcodeOp> ucodeSnapshot;
        for (Operation *op : opSnapshot)
            if (auto u = dyn_cast<vta::UcodeOp>(op))
                ucodeSnapshot.push_back(u);

        if (ucodeSnapshot.size() > 1) {
            Attribute reference = ucodeSnapshot[0].getRecordsAttr();
            for (size_t i = 1; i < ucodeSnapshot.size(); i++) {
                vta::UcodeOp op = ucodeSnapshot[i];
                if (op.getRecordsAttr() == reference) {
                    op.erase();
                } else {
                    op.emitOpError("different micro: cannot merge ucodes with different Records");
                    signalPassFailure();
                    return;
                }
            }
        }

        // Move ucode to top of the function body, if not already there.
        func::FuncOp func;
        module.walk([&](func::FuncOp f) { func = f; });
        if (!func) {
            module.emitError("no func.func found");
            signalPassFailure();
            return;
        }

        Block &body = func.getBody().front();
        vta::UcodeOp theUcode;
        for (Operation &op : body)
            if (auto u = dyn_cast<vta::UcodeOp>(&op))
                theUcode = u;

        if (theUcode) {
            Operation *firstOp = &body.front();
            if (firstOp != theUcode.getOperation())
                theUcode->moveBefore(firstOp);
        }

        // Find the first vta.finish. Erase everything after it.
        // If none exists, insert one before the terminator.
        bool foundFinish = false;
        for (auto it = body.begin(); it != body.end(); ) {
            if (isa<vta::FinishOp>(*it)) {
                foundFinish = true;
                ++it;
                while (it != body.end()) {
                    if (it->hasTrait<OpTrait::IsTerminator>())
                        break;
                    Operation *toErase = &*it;
                    ++it;
                    toErase->erase();
                        }
                break;
            }
            ++it;
        }

        if (!foundFinish) {
            // Insert a finish before the function's terminator (func.return).
            Operation *terminator = body.getTerminator();
            OpBuilder builder(terminator);
            builder.create<vta::FinishOp>(terminator->getLoc());
        }

        // Call the ucode-load pass.
        PassManager inner(module.getContext());
        inner.addPass(createTransformUcodeToLoadOpPass());
        if (failed(inner.run(module)))
            signalPassFailure();
}







} // close anonymous namespace





//========================================================================================================================//
//                                        //PASSES POINTERS
//========================================================================================================================//


//===============================================================================//
std::unique_ptr<::mlir::Pass> createCheckStructurePass() {
    CheckStructurePass *pass = new CheckStructurePass();
    return std::unique_ptr<Pass>(pass);}
 //===============================================================================//
std::unique_ptr<::mlir::Pass> createCheckUcodePass() {
    CheckUcodePass *pass = new CheckUcodePass();
    return std::unique_ptr<Pass>(pass);}


//===============================================================================//
std::unique_ptr<::mlir::Pass> createCheckDependancyPass() {
    CheckDependancyPass *pass = new CheckDependancyPass();
    return std::unique_ptr<Pass>(pass);}


//===============================================================================//
std::unique_ptr<::mlir::Pass> createTransformNoOpsPass() {
    TransformNoOpsPass *pass = new TransformNoOpsPass();
    return std::unique_ptr<Pass>(pass);}
//===============================================================================//
std::unique_ptr<::mlir::Pass> createTransformUcodeToLoadOpPass() {
    TransformUcodeToLoadOpPass *pass = new TransformUcodeToLoadOpPass();
    return std::unique_ptr<Pass>(pass);}



//===============================================================================//
std::unique_ptr<::mlir::Pass> createTransformGeneralStructurePass() {
    TransformGeneralStructurePass *pass = new TransformGeneralStructurePass();
    return std::unique_ptr<Pass>(pass);}








//========================================================================================================//                                                   
}                                                                            // close mlir::vta
}                                                                            // close mlir