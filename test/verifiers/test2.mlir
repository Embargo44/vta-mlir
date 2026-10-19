// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: YPad0 must be 0-15

vta.func @test() {
  vta.ucode {Records = [[0, 0, 0]]}
  vta.load mem INP, sram 0, dram 0, size 1 x 1, stride 1, pad 20, 0, 0, 0
  vta.finish
  
}
