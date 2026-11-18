// RUN: %vta-opt %s --vta-check-dependancy 2>&1 | %FileCheck %s
// CHECK: execution cannot reach vta.finish

module {
  vta.func @unmatched_wait() {
    vta.gemm_NoOp {ResetReg = true, PopPrevDep = true}
    vta.finish
  }
}
