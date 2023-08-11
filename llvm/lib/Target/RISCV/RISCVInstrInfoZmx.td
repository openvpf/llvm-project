//===-- RISCVInstrInfoZmx.td - RISC-V 'Zmx' instructions -------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// This file describes the RISC-V instructions from the company of UMX 'Zmx' Matrix
/// extension, version 0.10.
/// This version is still experimental as the 'V' extension hasn't been
/// ratified yet.
///
//===----------------------------------------------------------------------===//

include "RISCVInstrFormatsZmx.td"

//===----------------------------------------------------------------------===//
// Operand and SDNode transformation definitions.
//===----------------------------------------------------------------------===//

def MTypeIAsmOperand : AsmOperandClass {
  let Name = "MTypeI";
  let ParserMethod = "parseMTypeI";
  let DiagnosticType = "InvalidMTypeI";
}

def MTypeIOp : Operand<XLenVT> {
  let ParserMatchClass = MTypeIAsmOperand;
  let PrintMethod = "printMTypeI";
  let DecoderMethod = "decodeUImmOperand<13>";
}

def MopiAsmOperand : AsmOperandClass {
  let Name = "Mopi";
  let ParserMethod = "parseMopi";
  let DiagnosticType = "InvalidMopi";
}

def MopiOp : Operand<XLenVT> { 
  let ParserMatchClass = MopiAsmOperand;
  let PrintMethod = "printMopi";
  let DecoderMethod = "decodeUImmOperand<3>";
}


//===----------------------------------------------------------------------===//
// Instruction class templates
//===----------------------------------------------------------------------===//

let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in {
// load td, (rs1), rs2
class MatrixLoad<bits<3> funct6, bits<3> width, string opcodestr>
    : RVInstML<funct6, width,
                (outs TRR:$td),
                (ins GPR:$rs1, GPR:$rs2, MopiOp:$mopi), opcodestr,
                "$td, (${rs1}), $rs2, $mopi">;

class MatrixUFLoad<bits<4> funct6, bits<3> width, string opcodestr>
    : RVInstUFML<funct6, width,
                (outs TRR:$td),
                (ins GPR:$rs1, GPR:$rs2, MopiOp:$mopi), opcodestr,
                "$td, (${rs1}), $rs2, $mopi">;
} // hasSideEffects = 0, mayLoad = 1, mayStore = 0

let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in {
// store vd, ts3, (rs1), rs2
class MatrixStore<bits<3> funct6, bits<3> width, string opcodestr>
    : RVInstMS<funct6, width, (outs),
                (ins TRR:$tr3, GPR:$rs1, GPR:$rs2, MopiOp:$mopi),
                opcodestr, "$tr3, (${rs1}), $rs2, $mopi">;

class MatrixUFStore<bits<4> funct6, bits<3> width, string opcodestr>
    : RVInstUFMS<funct6, width, (outs),
                (ins TRR:$tr3, GPR:$rs1, GPR:$rs2, MopiOp:$mopi),
                opcodestr, "$tr3, (${rs1}), $rs2, $mopi">;
} // hasSideEffects = 0, mayLoad = 0, mayStore = 1

// Matrix Arithmetic
let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
// op td, ts1, ts2
class MALUMM<bits<6> funct6, bit fp, string opcodestr>
    : RVInstMM<funct6, fp, (outs TRR:$td),
                (ins TRR:$ts1, TRR:$ts2),
                opcodestr, "$td, $ts1, $ts2">;

class ADDSUB<bits<4> funct6, bit fp, string opcodestr>
    : RVInstADDSUB<funct6, fp, (outs TRR:$td),
                (ins TRR:$ts1, TRR:$ts2, MopiOp:$mopi),
                opcodestr, "$td, $ts1, $ts2, $mopi">;

class MREDUCE<bits<4> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstReduce<funct6, fp, mode, (outs TRR:$td),
                (ins TRR:$ts1, MopiOp:$mopi),
                opcodestr, "$td, $ts1, $mopi">;

class MMoveI<bits<4> funct6, bits<5> mode, string opcodestr>
    : RVInstMoveMI<funct6, mode, (outs TRR:$td),
                (ins uimm5:$mimm5, MopiOp:$mopi),
                opcodestr, "$td, $mimm5, $mopi">;

class MMoveX<bits<4> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstMoveMX<funct6, fp, mode, (outs TRR:$td),
                (ins GPR:$rs1, MopiOp:$mopi),
                opcodestr, "$td, $rs1, $mopi">;

class MMoveF<bits<4> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstMoveMX<funct6, fp, mode, (outs TRR:$td),
                (ins FPR32:$rs1, MopiOp:$mopi),
                opcodestr, "$td, $rs1, $mopi">;

class MMoveV<bits<4> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstMoveMV<funct6, fp, mode, (outs TRR:$td),
                (ins VR:$vs1, MopiOp:$mopi),
                opcodestr, "$td, $vs1, $mopi">;

} // hasSideEffects = 0, mayLoad = 0, mayStore = 0


//===----------------------------------------------------------------------===//
// Instructions
//===----------------------------------------------------------------------===//
let Predicates = [HasStdExtV] in {
let hasSideEffects = 1, mayLoad = 0, mayStore = 0 in {

// config instruction
def MSETTYPEI : RVInstSetMTypei<(outs GPR:$rd), (ins MTypeIOp:$mtypei),
                           "msettypei", "$rd, $mtypei">;
def MSETTYPE : RVInstSetMType<(outs GPR:$rd), (ins GPR:$rs1),
                         "msettype", "$rd, $rs1">;

def MSETTILEM : RVInstSetTile<0b0011, (outs GPR:$rd), (ins GPR:$rs1),
                         "msettilem", "$rd, $rs1">;
def MSETTILEK : RVInstSetTile<0b0101, (outs GPR:$rd), (ins GPR:$rs1),
                         "msettilek", "$rd, $rs1">;
def MSETTILEN : RVInstSetTile<0b0111, (outs GPR:$rd), (ins GPR:$rs1),
                         "msettilen", "$rd, $rs1">;
def MSETTSIDX : RVInstSetTile<0b1001, (outs GPR:$rd), (ins GPR:$rs1),
                         "msettsidx", "$rd, $rs1">;


def MSETTILEMI : RVInstSetTilei<0b0010, (outs GPR:$rd), (ins uimm13:$mleni),
                         "msettilemi", "$rd, $mleni">;
def MSETTILEKI : RVInstSetTilei<0b0100, (outs GPR:$rd), (ins uimm13:$mleni),
                         "msettileki", "$rd, $mleni">;
def MSETTILENI : RVInstSetTilei<0b0110, (outs GPR:$rd), (ins uimm13:$mleni),
                         "msettileni", "$rd, $mleni">;
def MSETTSIDXI : RVInstSetTilei<0b1000, (outs GPR:$rd), (ins uimm13:$mleni),
                         "msettsidxi", "$rd, $mleni">;

def MSETSK     : RVInstSetIm2col<0b1010, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                         "msetsk", "$rd, $rs1, $rs2">;
def MSETOUTSH  : RVInstSetIm2col<0b1000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                         "msetoutsh", "$rd, $rs1, $rs2">;
def MSETINSH   : RVInstSetIm2col<0b1001, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                         "msetinsh", "$rd, $rs1, $rs2">;
} // hasSideEffects = 1, mayLoad = 0, mayStore = 0

// Load Store Instructions
def MLE8_M        : MatrixLoad<0b000,   0x0, "mle8.m">,   VLSSched<8>;
def MLE16_M       : MatrixLoad<0b000,   0x1, "mle16.m">,  VLSSched<8>;
def MLE32_M       : MatrixLoad<0b000,   0x2, "mle32.m">,  VLSSched<8>;
def MLE64_M       : MatrixLoad<0b000,   0x3, "mle64.m">,  VLSSched<8>;

def MSE8_M        : MatrixStore<0b000,  0x0, "mse8.m">,   VLSSched<8>;
def MSE16_M       : MatrixStore<0b000,  0x1, "mse16.m">,  VLSSched<8>;
def MSE32_M       : MatrixStore<0b000,  0x2, "mse32.m">,  VLSSched<8>;
def MSE64_M       : MatrixStore<0b000,  0x3, "mse64.m">,  VLSSched<8>;


def MLUFE8_M      : MatrixUFLoad<0b1100,   0x0, "mlufe8.m">,   VLSSched<8>;
def MLUFE16_M     : MatrixUFLoad<0b1100,   0x1, "mlufe16.m">,  VLSSched<8>;
def MLUFE32_M     : MatrixUFLoad<0b1100,   0x2, "mlufe32.m">,  VLSSched<8>;
def MLUFE64_M     : MatrixUFLoad<0b1100,   0x3, "mlufe64.m">,  VLSSched<8>;


def MSUFE8_M    : MatrixUFStore<0x0b1100,   0x0, "msufe8.m">,   VLSSched<8>;
def MSUFE16_M   : MatrixUFStore<0x0b1100,   0x1, "msufe16.m">,  VLSSched<8>;
def MSUFE32_M   : MatrixUFStore<0x0b1100,   0x2, "msufe32.m">,  VLSSched<8>;
def MSUFE64_M   : MatrixUFStore<0x0b1100,   0x3, "msufe64.m">,  VLSSched<8>;

def MMA_MM   : MALUMM<0b000000, 0, "mma.mm">;
def MWMA_MM  : MALUMM<0b000001, 0, "mwma.mm">;
def MQMA_MM  : MALUMM<0b000010, 0, "mqma.mm">;
def MFMA_MM  : MALUMM<0b000000, 1, "mfma.mm">;
def MFWMA_MM : MALUMM<0b000001, 1, "mfwma.mm">;

def MADD_MM    : ADDSUB<0b0001, 0, "madd.mm">;
def MSUB_MM    : ADDSUB<0b0010, 0, "msub.mm">;
def MRSUB_MM   : ADDSUB<0b0011, 0, "mrsub.mm">;
def MEMUL_MM   : ADDSUB<0b0100, 0, "memul.mm">;
def MMACC_MM   : ADDSUB<0b0101, 0, "mmacc.mm">;
def MMAX_MM    : ADDSUB<0b0110, 0, "mmax.mm">;
def MMIN_MM    : ADDSUB<0b0111, 0, "mmin.mm">;

def MFADD_MM   : ADDSUB<0b0001, 1, "mfadd.mm">;
def MFSUB_MM   : ADDSUB<0b0010, 1, "mfsub.mm">;
def MFRSUB_MM  : ADDSUB<0b0011, 1, "mfrsub.mm">;
def MFEMUL_MM  : ADDSUB<0b0100, 1, "mfemul.mm">;
def MFMACC_MM  : ADDSUB<0b0101, 1, "mfmacc.mm">;
def MFMAX_MM   : ADDSUB<0b0110, 1, "mfmax.mm">;
def MFMIN_MM   : ADDSUB<0b0111, 1, "mfmin.mm">;

def MWADD_MM   : ADDSUB<0b1001, 0, "mwadd.mm">;
def MWSUB_MM   : ADDSUB<0b1010, 0, "mwsub.mm">;
def MWRSUB_MM  : ADDSUB<0b1011, 0, "mwrsub.mm">;
def MWEMUL_MM  : ADDSUB<0b1100, 0, "mwemul.mm">;
def MWMACC_MM  : ADDSUB<0b1101, 0, "mwmacc.mm">;

def MFWADD_MM  : ADDSUB<0b1001, 1, "mfwadd.mm">;
def MFWSUB_MM  : ADDSUB<0b1010, 1, "mfwsub.mm">;
def MFWRSUB_MM : ADDSUB<0b1011, 1, "mfwrsub.mm">;
def MFWEMUL_MM : ADDSUB<0b1100, 1, "mfwemul.mm">;
def MFWMACC_MM : ADDSUB<0b1101, 1, "mfwmacc.mm">;

def MREDSUM_MS    : MREDUCE<0b1110, 0b00000, 0, "mredsum.ms">;
def MREDMAXU_MS   : MREDUCE<0b1110, 0b00001, 0, "mredmaxu.ms">;
def MREDMAX_MS    : MREDUCE<0b1110, 0b00010, 0, "mredmax.ms">;
def MREDMINU_MS   : MREDUCE<0b1110, 0b00011, 0, "mredminu.ms">;
def MREDMIN_MS    : MREDUCE<0b1110, 0b00100, 0, "mredmin.ms">;
def MREDAND_MS    : MREDUCE<0b1110, 0b00101, 0, "mredand.ms">;
def MREDOR_MS     : MREDUCE<0b1110, 0b00110, 0, "mredor.ms">;
def MREDXOR_MS    : MREDUCE<0b1110, 0b00111, 0, "mredxor.ms">;

def MFREDSUM_MS   : MREDUCE<0b1110, 0b00000, 1, "mfredsum.ms">;
def MFREDMAX_MS   : MREDUCE<0b1110, 0b00010, 1, "mfredmax.ms">;
def MFREDMIN_MS   : MREDUCE<0b1110, 0b00100, 1, "mfredmin.ms">;

def MREDSUM_MVR   : MREDUCE<0b1110, 0b10000, 0, "mredsum.mvr">;
def MREDMAXU_MVR  : MREDUCE<0b1110, 0b10001, 0, "mredmaxu.mvr">;
def MREDMAX_MVR   : MREDUCE<0b1110, 0b10010, 0, "mredmax.mvr">;
def MREDMINU_MVR  : MREDUCE<0b1110, 0b10011, 0, "mredminu.mvr">;
def MREDMIN_MVR   : MREDUCE<0b1110, 0b10100, 0, "mredmin.mvr">;
def MREDAND_MVR   : MREDUCE<0b1110, 0b10101, 0, "mredand.mvr">;
def MREDOR_MVR    : MREDUCE<0b1110, 0b10110, 0, "mredor.mvr">;
def MREDXOR_MVR   : MREDUCE<0b1110, 0b10111, 0, "mredxor.mvr">;

def MFREDSUM_MVR  : MREDUCE<0b1110, 0b10000, 1, "mfredsum.mvr">;
def MFREDMAX_MVR  : MREDUCE<0b1110, 0b10010, 1, "mfredmax.mvr">;
def MFREDMIN_MVR  : MREDUCE<0b1110, 0b10100, 1, "mfredmin.mvr">;

def MREDSUM_MVC   : MREDUCE<0b1110, 0b11000, 0, "mredsum.mvc">;
def MREDMAXU_MVC  : MREDUCE<0b1110, 0b11001, 0, "mredmaxu.mvc">;
def MREDMAX_MVC   : MREDUCE<0b1110, 0b11010, 0, "mredmax.mvc">;
def MREDMINU_MVC  : MREDUCE<0b1110, 0b11011, 0, "mredminu.mvc">;
def MREDMIN_MVC   : MREDUCE<0b1110, 0b11100, 0, "mredmin.mvc">;
def MREDAND_MVC   : MREDUCE<0b1110, 0b11101, 0, "mredand.mvc">;
def MREDOR_MVC    : MREDUCE<0b1110, 0b11110, 0, "mredor.mvc">;
def MREDXOR_MVC   : MREDUCE<0b1110, 0b11111, 0, "mredxor.mvc">;

def MFREDSUM_MVC  : MREDUCE<0b1110, 0b11000, 1, "mfredsum.mvc">;
def MFREDMAX_MVC  : MREDUCE<0b1110, 0b11010, 1, "mfredmax.mvc">;
def MFREDMIN_MVC  : MREDUCE<0b1110, 0b11100, 1, "mfredmin.mvc">;

def MWREDSUM_MS   : MREDUCE<0b1110, 0b01000, 0, "mwredsum.ms">;
def MWREDSUM_MVR  : MREDUCE<0b1110, 0b01001, 0, "mwredsum.mvr">;
def MWREDSUM_MVC  : MREDUCE<0b1110, 0b01010, 0, "mwredsum.mvc">;

def MQREDSUM_MS   : MREDUCE<0b1110, 0b01011, 0, "mqredsum.ms">;

def MFWREDSUM_MS  : MREDUCE<0b1110, 0b01000, 1, "mfwredsum.ms">;
def MFWREDSUM_MVR : MREDUCE<0b1110, 0b01001, 1, "mfwredsum.mvr">;
def MFWREDSUM_MVC : MREDUCE<0b1110, 0b01010, 1, "mfwredsum.mvc">;


 
def MFNCVT_F_FW_M : MREDUCE<0b1111, 0b00000, 1, "mfncvt.f.fw.m">;
def MFWCVT_FW_F_M : MREDUCE<0b1111, 0b00000, 0, "mfwcvt.fw.f.m">;
def MFCVT_F_X_M   : MREDUCE<0b1111, 0b00001, 1, "mfcvt.f.x.m">;
def MFCVT_X_F_M   : MREDUCE<0b1111, 0b00001, 0, "mfcvt.x.f.m">;
def MFNCVT_F_XW_M : MREDUCE<0b1111, 0b00010, 1, "mfncvt.f.xw.m">;
def MFWCVT_XW_F_M : MREDUCE<0b1111, 0b00010, 0, "mfwcvt.xw.f.m">;
def MFNCVT_F_XQ_M : MREDUCE<0b1111, 0b00011, 1, "mfncvt.f.xq.m">;
def MFWCVT_XQ_F_M : MREDUCE<0b1111, 0b00011, 0, "mfwcvt.xq.f.m">;
def MFWCVT_FW_X_M : MREDUCE<0b1111, 0b00100, 1, "mfwcvt.fw.x.m">;
def MFNCVT_X_FW_M : MREDUCE<0b1111, 0b00100, 0, "mfncvt.x.fw.m">;
def MFCVT_FW_XW_M : MREDUCE<0b1111, 0b00101, 1, "mfcvt.fw.xw.m">;
def MFCVT_XW_FW_M : MREDUCE<0b1111, 0b00101, 0, "mfcvt.xw.fw.m">;
def MFNCVT_FW_XQ_M: MREDUCE<0b1111, 0b00110, 1, "mfncvt.fw.xq.m">;
def MFWCVT_XQ_FW_M: MREDUCE<0b1111, 0b00110, 0, "mfwcvt.xq.fw.m">;

def MMV_M_I        : MMoveI<0b1111, 0b01000, "mmv.m.i">;
def MMV_M_X        : MMoveX<0b1111, 0b01001, 0, "mmv.m.x">;
def MMV_M_F        : MMoveF<0b1111, 0b01001, 1, "mmv.m.f">;
def MMV_M_V_R      : MMoveV<0b1111, 0b01010, 0, "mmv.m.v.r">;
def MMV_M_V_C      : MMoveV<0b1111, 0b01011, 0, "mmv.m.v.c">;
def MMV_M_M        : MREDUCE<0b1111, 0b01100, 0, "mmv.m.m">;

def MFEXP_M        : MREDUCE<0b1111, 0b10001, 1, "mfexp.m">;
def MFRSQRT_M      : MREDUCE<0b1111, 0b10010, 1, "mfrsqrt.m">;
}