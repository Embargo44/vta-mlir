// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: MemoryType must be 0-3

func.func @test() {
  vta.load mem 7, sram 0, dram 0, size 1 x 16, stride 16, pad 0, 0, 0, 0 {PopPrevDep = false, PopNextDep = false, PushPrevDep = false, PushNextDep = false}
  vta.finish
  return
}
