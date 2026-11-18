// RUN: %vta-opt %s --vta-check-dependancy 2>&1 | %FileCheck %s
// CHECK: no dependency flags set anywhere

module {
  vta.func @no_flags() {
    vta.load_INP sram 0, dram 0, size 1 x 1, stride 1, pad 0, 0, 0, 0
    vta.finish
  }
}
