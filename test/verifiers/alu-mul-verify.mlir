// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: UopBgn must be <= UopEnd

module {
  vta.func @test() {
  vta.alu_MUL uop 2 to 1
  vta.finish
}
}
