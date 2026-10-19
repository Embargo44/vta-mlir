// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: load exceeds SRAM buffer bounds

vta.func @test() {
  vta.ucode {Records = [[0, 0, 0]]}
  vta.load mem INP, sram 60000, dram 0, size 1 x 1, stride 1, pad 0, 0, 0, 0
  vta.finish
  
}
