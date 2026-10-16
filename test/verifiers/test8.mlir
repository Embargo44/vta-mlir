// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: each record must be a triple

func.func @test() {
  vta.ucode {Records = [[0, 0]]}
  vta.finish
  return
}
