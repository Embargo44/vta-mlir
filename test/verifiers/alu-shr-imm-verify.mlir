// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: IterIn must be >= 1

module {
  vta.func @test() {
  vta.alu_SHR_imm imm 0, uop 0 to 1 {IterIn = 0 : i16}
  vta.finish
}
}
