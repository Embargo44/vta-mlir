// RUN: not %vta-opt %s --vta-transform-general-structure 2>&1 | %FileCheck %s
// CHECK: no vta.func found

module {}
