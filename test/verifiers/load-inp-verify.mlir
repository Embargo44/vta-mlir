// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: YPad0 must be 0-15

module {
  vta.func @test() {
  vta.load_INP sram 0, dram 0, size 1 x 1, stride 1, pad 16, 0, 0, 0
  vta.finish
}
}
