// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: MemoryType must be 0-3

func.func @test() {
  vta.ucode {Records = [[0, 0, 0]]}
  vta.load mem 7, sram 0, dram 0, size 1 x 1, stride 1, pad 0, 0, 0, 0
  vta.finish
  return
}
