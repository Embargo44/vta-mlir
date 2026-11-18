// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: load exceeds SRAM buffer bounds

module {
  vta.func @test() {
  vta.load_ACC sram 65535, dram 0, size 1 x 1, stride 1
  vta.finish
}
}
