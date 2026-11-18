// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: MemoryType must be 0-3

module {
  vta.func @test() {
  vta.load_NoOp {MemoryType = 7 : i8}
  vta.finish
}
}
