// RUN: not %vta-opt %s --vta-check-structure 2>&1 | %FileCheck %s
// CHECK: expected exactly one vta.func, found 2

module {
  vta.func @first() { vta.finish }
  vta.func @second() { vta.finish }
}
