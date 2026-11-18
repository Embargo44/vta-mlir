// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: store exceeds SRAM buffer bounds

module {
  vta.func @test() {
  vta.store_OUT dram 0, size 1 {SramBase = 65535 : i16}
  vta.finish
}
}
