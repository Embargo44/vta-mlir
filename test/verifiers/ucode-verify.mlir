// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: Records must not be empty

module {
  vta.func @test() {
  vta.ucode {Records = []}
  vta.finish
}
}
