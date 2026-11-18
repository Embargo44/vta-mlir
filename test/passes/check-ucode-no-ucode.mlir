// RUN: not %vta-opt %s --vta-check-ucode 2>&1 | %FileCheck %s
// CHECK: first VTA op must be vta.ucode

module {
  vta.func @no_ucode() {
    vta.finish
  }
}
