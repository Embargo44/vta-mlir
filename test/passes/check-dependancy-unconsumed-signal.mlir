// RUN: %vta-opt %s --vta-check-dependancy 2>&1 | %FileCheck %s
// CHECK: LoadToCompute has 1 unconsumed token(s)

module {
  vta.func @unconsumed_signal() {
    vta.load_INP sram 0, dram 0, size 1 x 1, stride 1, pad 0, 0, 0, 0 {PushNextDep = true}
    vta.finish
  }
}
