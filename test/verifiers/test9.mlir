// RUN: not %vta-opt %s --vta-check-structure 2>&1 | %FileCheck %s

// CHECK: expected vta.finish as terminator

vta.func @test() {
  vta.ucode {Records = [[0, 0, 0]]}
  vta.load mem INP, sram 0, dram 0, size 1 x 1, stride 1, pad 0, 0, 0, 0
  
}
