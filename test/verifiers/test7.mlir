// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: MUL immediate must fit in 8 bits

vta.func @test() {
  vta.ucode {Records = [[0, 0, 0]]}
  vta.alu reset false, uop 0 to 1, iter 1 x 1,
          dst 0, 0, src 0, 0, alu 4, imm true, 300
  vta.finish
  
}
