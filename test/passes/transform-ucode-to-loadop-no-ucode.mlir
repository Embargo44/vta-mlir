// RUN: %vta-opt %s --vta-transform-ucode-to-loadop | %FileCheck %s

module {
  vta.func @no_ucode() {
    vta.finish
  }
}
// CHECK-NOT: vta.load
// CHECK: vta.finish
// CHECK-NOT: vta.load
