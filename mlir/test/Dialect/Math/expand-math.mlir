// RUN: mlir-opt %s --split-input-file -test-expand-math | FileCheck %s

// CHECK-LABEL: func @tanh
func.func @tanh(%arg: f32) -> f32 {
  %res = math.tanh %arg : f32
  return %res : f32
}
// CHECK-DAG: %[[ZERO:.+]] = arith.constant 0.000000e+00 : f32
// CHECK-DAG: %[[ONE:.+]] = arith.constant 1.000000e+00 : f32
// CHECK-DAG: %[[TWO:.+]] = arith.constant 2.000000e+00 : f32
// CHECK: %[[DOUBLEDX:.+]] = arith.mulf %arg0, %[[TWO]] : f32
// CHECK: %[[NEGDOUBLEDX:.+]] = arith.negf %[[DOUBLEDX]] : f32
// CHECK: %[[EXP1:.+]] = math.exp %[[NEGDOUBLEDX]] : f32
// CHECK: %[[DIVIDEND1:.+]] = arith.subf %[[ONE]], %[[EXP1]] : f32
// CHECK: %[[DIVISOR1:.+]] = arith.addf %[[EXP1]], %[[ONE]] : f32
// CHECK: %[[RES1:.+]] = arith.divf %[[DIVIDEND1]], %[[DIVISOR1]] : f32
// CHECK: %[[EXP2:.+]] = math.exp %[[DOUBLEDX]] : f32
// CHECK: %[[DIVIDEND2:.+]] = arith.subf %[[EXP2]], %[[ONE]] : f32
// CHECK: %[[DIVISOR2:.+]] = arith.addf %[[EXP2]], %[[ONE]] : f32
// CHECK: %[[RES2:.+]] = arith.divf %[[DIVIDEND2]], %[[DIVISOR2]] : f32
// CHECK: %[[COND:.+]] = arith.cmpf oge, %arg0, %[[ZERO]] : f32
// CHECK: %[[RESULT:.+]] = arith.select %[[COND]], %[[RES1]], %[[RES2]] : f32
// CHECK: return %[[RESULT]]

// -----


// CHECK-LABEL: func @vector_tanh
func.func @vector_tanh(%arg: vector<4xf32>) -> vector<4xf32> {
  // CHECK-NOT: math.tanh
  %res = math.tanh %arg : vector<4xf32>
  return %res : vector<4xf32>
}

// -----

// CHECK-LABEL: func @tan
func.func @tan(%arg: f32) -> f32 {
  %res = math.tan %arg : f32
  return %res : f32
}

// CHECK-SAME: %[[ARG0:.+]]: f32
// CHECK: %[[SIN:.+]] = math.sin %[[ARG0]]
// CHECK: %[[COS:.+]] = math.cos %[[ARG0]]
// CHECK: %[[DIV:.+]] = arith.divf %[[SIN]], %[[COS]]


// -----

// CHECK-LABEL: func @vector_tan
func.func @vector_tan(%arg: vector<4xf32>) -> vector<4xf32> {
  %res = math.tan %arg : vector<4xf32>
  return %res : vector<4xf32>
}

// CHECK-NOT: math.tan

// -----

func.func @ctlz(%arg: i32) -> i32 {
  %res = math.ctlz %arg : i32
  return %res : i32
}

// CHECK-LABEL: @ctlz
// CHECK-SAME: %[[ARG0:.+]]: i32
// CHECK-DAG: %[[C0:.+]] = arith.constant 0
// CHECK-DAG: %[[C16:.+]] = arith.constant 16
// CHECK-DAG: %[[C65535:.+]] = arith.constant 65535
// CHECK-DAG: %[[C8:.+]] = arith.constant 8
// CHECK-DAG: %[[C16777215:.+]] = arith.constant 16777215
// CHECK-DAG: %[[C4:.+]] = arith.constant 4
// CHECK-DAG: %[[C268435455:.+]] = arith.constant 268435455
// CHECK-DAG: %[[C2:.+]] = arith.constant 2
// CHECK-DAG: %[[C1073741823:.+]] = arith.constant 1073741823
// CHECK-DAG: %[[C1:.+]] = arith.constant 1
// CHECK-DAG: %[[C2147483647:.+]] = arith.constant 2147483647
// CHECK-DAG: %[[C32:.+]] = arith.constant 32

// CHECK: %[[PRED:.+]] = arith.cmpi ule, %[[ARG0]], %[[C65535]]
// CHECK: %[[SHL:.+]] = arith.shli %[[ARG0]], %[[C16]]
// CHECK: %[[SELX0:.+]] = arith.select %[[PRED]], %[[SHL]], %[[ARG0]]
// CHECK: %[[SELY0:.+]] = arith.select %[[PRED]], %[[C16]], %[[C0]]

// CHECK: %[[PRED:.+]] = arith.cmpi ule, %[[SELX0]], %[[C16777215]]
// CHECK: %[[ADD:.+]] = arith.addi %[[SELY0]], %[[C8]]
// CHECK: %[[SHL:.+]] = arith.shli %[[SELX0]], %[[C8]]
// CHECK: %[[SELX1:.+]] = arith.select %[[PRED]], %[[SHL]], %[[SELX0]]
// CHECK: %[[SELY1:.+]] = arith.select %[[PRED]], %[[ADD]], %[[SELY0]]

// CHECK: %[[PRED:.+]] = arith.cmpi ule, %[[SELX1]], %[[C268435455]] : i32
// CHECK: %[[ADD:.+]] = arith.addi %[[SELY1]], %[[C4]]
// CHECK: %[[SHL:.+]] = arith.shli %[[SELX1]], %[[C4]]
// CHECK: %[[SELX2:.+]] = arith.select %[[PRED]], %[[SHL]], %[[SELX1]]
// CHECK: %[[SELY2:.+]] = arith.select %[[PRED]], %[[ADD]], %[[SELY1]]


// CHECK: %[[PRED:.+]] = arith.cmpi ule, %[[SELX2]], %[[C1073741823]] : i32
// CHECK: %[[ADD:.+]] = arith.addi %[[SELY2]], %[[C2]]
// CHECK: %[[SHL:.+]] = arith.shli %[[SELX2]], %[[C2]]
// CHECK: %[[SELX3:.+]] = arith.select %[[PRED]], %[[SHL]], %[[SELX2]]
// CHECK: %[[SELY3:.+]] = arith.select %[[PRED]], %[[ADD]], %[[SELY2]]

// CHECK: %[[PRED:.+]] = arith.cmpi ule, %[[SELX3]], %[[C2147483647]] : i32
// CHECK: %[[ADD:.+]] = arith.addi %[[SELY3]], %[[C1]]
// CHECK: %[[SELY4:.+]] = arith.select %[[PRED]], %[[ADD]], %[[SELY3]]

// CHECK: %[[PRED:.+]] = arith.cmpi eq, %[[ARG0]], %[[C0]] : i32
// CHECK: %[[SEL:.+]] = arith.select %[[PRED]], %[[C32]], %[[SELY4]] : i32
// CHECK: return %[[SEL]]

// -----

func.func @ctlz_vector(%arg: vector<4xi32>) -> vector<4xi32> {
  %res = math.ctlz %arg : vector<4xi32>
  return %res : vector<4xi32>
}

// CHECK-LABEL: @ctlz_vector
// CHECK-NOT: math.ctlz

// -----

// CHECK-LABEL:    func @fmaf_func
// CHECK-SAME:     ([[ARG0:%.+]]: f64, [[ARG1:%.+]]: f64, [[ARG2:%.+]]: f64) -> f64
func.func @fmaf_func(%a: f64, %b: f64, %c: f64) -> f64 {
  // CHECK-NEXT:     [[MULF:%.+]] = arith.mulf [[ARG0]], [[ARG1]]
  // CHECK-NEXT:     [[ADDF:%.+]] = arith.addf [[MULF]], [[ARG2]]
  // CHECK-NEXT:     return [[ADDF]]
  %ret = math.fma %a, %b, %c : f64
  return %ret : f64
}

// -----

// CHECK-LABEL:     func @floorf_func
// CHECK-SAME:      ([[ARG0:%.+]]: f64) -> f64
func.func @floorf_func(%a: f64) -> f64 {
  // CHECK-DAG:   [[CST:%.+]] = arith.constant 0.000
  // CHECK-DAG:   [[CST_0:%.+]] = arith.constant -1.000
  // CHECK-NEXT:   [[CVTI:%.+]] = arith.fptosi [[ARG0]]
  // CHECK-NEXT:   [[CVTF:%.+]] = arith.sitofp [[CVTI]]
  // CHECK-NEXT:   [[COPYSIGN:%.+]] = math.copysign [[CVTF]], [[ARG0]]
  // CHECK-NEXT:   [[COMP:%.+]] = arith.cmpf olt, [[ARG0]], [[CST]]
  // CHECK-NEXT:   [[INCR:%.+]] = arith.select [[COMP]], [[CST_0]], [[CST]]
  // CHECK-NEXT:   [[ADDF:%.+]] = arith.addf [[COPYSIGN]], [[INCR]]
  // CHECK-NEXT:   return [[ADDF]]
  %ret = math.floor %a : f64
  return %ret : f64
}

// -----

// CHECK-LABEL:     func @ceilf_func
// CHECK-SAME:      ([[ARG0:%.+]]: f64) -> f64
func.func @ceilf_func(%a: f64) -> f64 {
  // CHECK-DAG:   [[CST:%.+]] = arith.constant 0.000
  // CHECK-DAG:   [[CST_0:%.+]] = arith.constant 1.000
  // CHECK-NEXT:   [[CVTI:%.+]] = arith.fptosi [[ARG0]]
  // CHECK-NEXT:   [[CVTF:%.+]] = arith.sitofp [[CVTI]]
  // CHECK-NEXT:   [[COPYSIGN:%.+]] = math.copysign [[CVTF]], [[ARG0]]
  // CHECK-NEXT:   [[COMP:%.+]] = arith.cmpf ogt, [[ARG0]], [[COPYSIGN]]
  // CHECK-NEXT:   [[INCR:%.+]] = arith.select [[COMP]], [[CST_0]], [[CST]]
  // CHECK-NEXT:   [[ADDF:%.+]] = arith.addf [[COPYSIGN]], [[INCR]]
  // CHECK-NEXT:   return [[ADDF]]
  %ret = math.ceil %a : f64
  return %ret : f64
}

// -----

// CHECK-LABEL:     func @exp2f_func
// CHECK-SAME:      ([[ARG0:%.+]]: f64) -> f64
func.func @exp2f_func(%a: f64) -> f64 {
  // CHECK-DAG:     [[CST:%.+]]  = arith.constant 0.69314718055994529
  // CHECK:         [[MULF:%.+]] = arith.mulf [[ARG0]], [[CST]]
  // CHECK:         [[EXP:%.+]]  = math.exp [[MULF]]
  // CHECK:         return [[EXP]]
  %ret = math.exp2 %a : f64
  return %ret : f64
}

// CHECK-LABEL:     func @exp2f_func_tensor
// CHECK-SAME:      ([[ARG0:%.+]]: tensor<1xf32>) -> tensor<1xf32>
func.func @exp2f_func_tensor(%a: tensor<1xf32>) -> tensor<1xf32> {
  // CHECK-DAG:     [[CST:%.+]]  = arith.constant dense<0.693147182>
  // CHECK:         [[MULF:%.+]] = arith.mulf [[ARG0]], [[CST]]
  // CHECK:         [[EXP:%.+]]  = math.exp [[MULF]]
  // CHECK:         return [[EXP]]
  %ret = math.exp2 %a : tensor<1xf32>
  return %ret : tensor<1xf32>
}

// -----

// CHECK-LABEL:      func @roundf_func
// CHECK-SAME:      (%[[ARG0:.*]]: f32) -> f32
func.func @roundf_func(%a: f32) -> f32 {
  // CHECK-DAG:       %[[HALF:.*]] = arith.constant 5.000000e-01
  // CHECK-DAG:       %[[C23:.*]] = arith.constant 23
  // CHECK-DAG:       %[[C127:.*]] = arith.constant 127
  // CHECK-DAG:       %[[EXP_MASK:.*]] = arith.constant 255
  // CHECK-DAG:       %[[SHIFT:.*]] = math.copysign %[[HALF]], %[[ARG0]]
  // CHECK-DAG:       %[[ARG_SHIFTED:.*]] = arith.addf %[[ARG0]], %[[SHIFT]]
  // CHECK-DAG:       %[[FIXED_CONVERT:.*]] = arith.fptosi %[[ARG_SHIFTED]]
  // CHECK-DAG:       %[[FP_FIXED_CONVERT_0:.*]] = arith.sitofp %[[FIXED_CONVERT]]
  // CHECK-DAG:       %[[FP_FIXED_CONVERT_1:.*]] = math.copysign %[[FP_FIXED_CONVERT_0]], %[[ARG_SHIFTED]]
  // CHECK-DAG:       %[[ARG_BITCAST:.*]] = arith.bitcast %[[ARG0]] : f32 to i32
  // CHECK-DAG:       %[[ARG_BITCAST_SHIFTED:.*]] = arith.shrui %[[ARG_BITCAST]], %[[C23]]
  // CHECK-DAG:       %[[ARG_EXP:.*]] = arith.andi %[[ARG_BITCAST_SHIFTED]], %[[EXP_MASK]]
  // CHECK-DAG:       %[[ARG_BIASED_EXP:.*]] = arith.subi %[[ARG_EXP]], %[[C127]]
  // CHECK-DAG:       %[[IS_SPECIAL_VAL:.*]] = arith.cmpi sge, %[[ARG_BIASED_EXP]], %[[C23]]
  // CHECK-DAG:       %[[RESULT:.*]] = arith.select %[[IS_SPECIAL_VAL]], %[[ARG0]], %[[FP_FIXED_CONVERT_1]]
  // CHECK:           return %[[RESULT]]
  %ret = math.round %a : f32
  return %ret : f32
}

// -----

// CHECK-LABEL:   func @powf_func
// CHECK-SAME:    ([[ARG0:%.+]]: f64, [[ARG1:%.+]]: f64)
func.func @powf_func(%a: f64, %b: f64) ->f64 {
  // CHECK-DAG: [[LOG:%.+]] = math.log [[ARG0]]
  // CHECK-DAG: [[MULT:%.+]] = arith.mulf [[LOG]], [[ARG1]]
  // CHECK-DAG: [[EXPR:%.+]] = math.exp [[MULT]]
  // CHECK: return [[EXPR]]
  %ret = math.powf %a, %b : f64
  return %ret : f64
}
