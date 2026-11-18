// RUN: not %vta-opt %s 2>&1 | %FileCheck %s

// CHECK: 'vta.func' op expects a non-empty block

module {
  vta.func @empty() {
    // Intentionally empty: FuncOp requires a non-empty body.
  }
}
