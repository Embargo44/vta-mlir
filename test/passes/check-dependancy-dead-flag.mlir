// RUN: %vta-opt %s --vta-check-dependancy 2>&1 | %FileCheck %s
// CHECK: this flag has no effect for this op kind

module {
  vta.func @dead_flag() {
    vta.load_INP sram 0, dram 0, size 1 x 1, stride 1, pad 0, 0, 0, 0 {PopPrevDep = true}
    vta.finish
  }
}
