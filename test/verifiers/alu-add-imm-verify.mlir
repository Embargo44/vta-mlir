// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: UopEnd must be > UopBgn when ResetReg is false

module {
  vta.func @test() {
  vta.alu_ADD_imm imm 0, uop 1 to 1
  vta.finish
}
}
