// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: MemoryType must be 4 (OUT)

module {
  vta.func @test() {
  vta.store_NoOp {MemoryType = 3 : i8}
  vta.finish
}
}
