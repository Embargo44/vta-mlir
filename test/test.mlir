func.func @test() {

  vta.ucode {Records = [[0, 0, 0]]}

  vta.alu reset false, uop 0 to 1, iter 1 x 1,
          dst 0, 0, src 0, 0, alu 2, imm true, 42
      {PushNextDep = true}

  vta.store mem OUT, sram 0, dram 16384, size 1 x 1, stride 1, pad 0, 0, 0, 0
      {PopPrevDep = true}

  vta.finish
  return
}