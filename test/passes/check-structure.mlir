// RUN: %vta-opt %s --vta-check-structure 2>&1 | %FileCheck %s

// CHECK: module must contain at least one vta.load

// This currently emits an error diagnostic but does not signal pass failure.
module {
  vta.func @no_load() {
    vta.ucode {Records = [[0, 0, 0]]}
    vta.finish
  }
}
