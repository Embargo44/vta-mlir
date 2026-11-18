// RUN: %vta-opt %s --vta-check-dependancy 2>&1 | %FileCheck %s
// CHECK-NOT: warning:
// CHECK-NOT: error:
// CHECK: vta.finish
// CHECK-NOT: warning:
// CHECK-NOT: error:

module {
  vta.func @balanced() {
    vta.load_INP sram 0, dram 0, size 1 x 1, stride 1, pad 0, 0, 0, 0 {PushNextDep = true}
    vta.gemm_NoOp {ResetReg = true, PopPrevDep = true}
    vta.finish
  }
}
