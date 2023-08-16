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

class MatrixLoadVF<bits<3> funct6, bits<3> width, string opcodestr>
    : RVInstMLVF<funct6, width,
                (outs TRR:$td),
                (ins GPR:$rs1, MopiOp:$mopi), opcodestr,
                "$td, (${rs1}), $mopi">;

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

class MatrixStoreVF<bits<3> funct6, bits<3> width, string opcodestr>
    : RVInstMSVF<funct6, width, (outs),
                (ins TRR:$tr3, GPR:$rs1, MopiOp:$mopi),
                opcodestr, "$tr3, (${rs1}), $mopi">;

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

class ADDSUBMM<bits<4> funct6, bit fp, string opcodestr>
    : RVInstADDSUB<funct6, fp, 0b110, (outs TRR:$td),
                  (ins TRR:$ts1, TRR:$ts2, MopiOp:$mopi),
                  opcodestr, "$td, $ts1, $ts2, $mopi">;

class ADDSUBMVR<bits<4> funct6, bit fp, string opcodestr>
    : RVInstADDSUB<funct6, fp, 0b101, (outs TRR:$td),
                (ins TRR:$ts1, TRR:$ts2, MopiOp:$mopi),
                opcodestr, "$td, $ts1, $ts2, $mopi">;

class ADDSUBMVC<bits<4> funct6, bit fp, string opcodestr>
    : RVInstADDSUB<funct6, fp, 0b100, (outs TRR:$td),
                (ins TRR:$ts1, TRR:$ts2, MopiOp:$mopi),
                opcodestr, "$td, $ts1, $ts2, $mopi">;

class ADDSUBMX<bits<4> funct6, bit fp, string opcodestr>
    : RVInstADDSUBMX<funct6, fp, 0b011, (outs TRR:$td),
                (ins TRR:$ts1, FPR32:$rs2, MopiOp:$mopi),
                opcodestr, "$td, $ts1, $rs2, $mopi">;

class ADDSUBMF<bits<4> funct6, bit fp, string opcodestr>
    : RVInstADDSUBMX<funct6, fp, 0b011, (outs TRR:$td),
                (ins TRR:$ts1, FPR32:$rs2, MopiOp:$mopi),
                opcodestr, "$td, $ts1, $rs2, $mopi">;

class WADDSUBMM<bits<4> funct6, bit fp, string opcodestr>
    : RVInstWidenADDSUB<funct6, fp, 0b110, (outs TRR:$td),
                      (ins TRR:$ts1, TRR:$ts2, MopiOp:$mopi),
                      opcodestr, "$td, $ts1, $ts2, $mopi">;

class WADDSUBMVR<bits<4> funct6, bit fp, string opcodestr>
    : RVInstWidenADDSUB<funct6, fp, 0b101, (outs TRR:$td),
                (ins TRR:$ts1, TRR:$ts2, MopiOp:$mopi),
                opcodestr, "$td, $ts1, $ts2, $mopi">;

class WADDSUBMVC<bits<4> funct6, bit fp, string opcodestr>
    : RVInstWidenADDSUB<funct6, fp, 0b100, (outs TRR:$td),
                (ins TRR:$ts1, TRR:$ts2, MopiOp:$mopi),
                opcodestr, "$td, $ts1, $ts2, $mopi">;

class WADDSUBMX<bits<4> funct6, bit fp, string opcodestr>
    : RVInstWidenADDSUBMX<funct6, fp, 0b011, (outs TRR:$td),
                (ins TRR:$ts1, FPR32:$rs2, MopiOp:$mopi),
                opcodestr, "$td, $ts1, $rs2, $mopi">;

class WADDSUBMF<bits<4> funct6, bit fp, string opcodestr>
    : RVInstWidenADDSUBMX<funct6, fp, 0b011, (outs TRR:$td),
                (ins TRR:$ts1, FPR32:$rs2, MopiOp:$mopi),
                opcodestr, "$td, $ts1, $rs2, $mopi">;


class MREDUCEMS<bits<4> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstReduce<funct6, fp, mode, 0b011, (outs TRR:$td),
                (ins TRR:$ts1, MopiOp:$mopi),
                opcodestr, "$td, $ts1, $mopi">;

class MREDUCEMVR<bits<4> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstReduce<funct6, fp, mode, 0b101, (outs TRR:$td),
                (ins TRR:$ts1, MopiOp:$mopi),
                opcodestr, "$td, $ts1, $mopi">;

class MREDUCEMVC<bits<4> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstReduce<funct6, fp, mode, 0b100, (outs TRR:$td), 
                (ins TRR:$ts1, MopiOp:$mopi),
                opcodestr, "$td, $ts1, $mopi">;

class MCVTMM<bits<4> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstReduce<funct6, fp, mode, 0b110, (outs TRR:$td),
                (ins TRR:$ts1, MopiOp:$mopi),
                opcodestr, "$td, $ts1, $mopi">;

class MMoveI<bits<4> funct6, bits<5> mode, string opcodestr>
    : RVInstMoveMI<funct6, mode, (outs TRR:$td),
                (ins uimm5:$mimm5, MopiOp:$mopi),
                opcodestr, "$td, $mimm5, $mopi">;

class MMoveWidenI<bits<4> funct6, bits<5> mode, string opcodestr>
    : RVInstMoveWidenMI<funct6, mode, (outs TRR:$td),
                        (ins uimm5:$mimm5, MopiOp:$mopi),
                        opcodestr, "$td, $mimm5, $mopi">;

class MMoveX<bits<4> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstMoveMX<funct6, fp, mode, (outs TRR:$td),
                (ins GPR:$rs1, MopiOp:$mopi),
                opcodestr, "$td, $rs1, $mopi">;

class MMoveWidenX<bits<4> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstMoveWidenMX<funct6, fp, mode, (outs TRR:$td),
                (ins GPR:$rs1, MopiOp:$mopi),
                opcodestr, "$td, $rs1, $mopi">;

class MMoveF<bits<4> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstMoveMX<funct6, fp, mode, (outs TRR:$td),
                (ins FPR32:$rs1, MopiOp:$mopi),
                opcodestr, "$td, $rs1, $mopi">;

class MMoveWidenF<bits<4> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstMoveWidenMX<funct6, fp, mode, (outs TRR:$td),
                (ins FPR32:$rs1, MopiOp:$mopi),
                opcodestr, "$td, $rs1, $mopi">;

class MMoveWidenMM<bits<4> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstMoveWidenMM<funct6, fp, mode, (outs TRR:$td),
                (ins FPR32:$rs1, MopiOp:$mopi),
                opcodestr, "$td, $rs1, $mopi">;

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

def MLE8_V        : MatrixLoadVF<0b001,   0x0, "mle8.v">,   VLSSched<8>;
def MLE16_V       : MatrixLoadVF<0b001,   0x1, "mle16.v">,  VLSSched<8>;
def MLE32_V       : MatrixLoadVF<0b001,   0x2, "mle32.v">,  VLSSched<8>;

def MLE8_S        : MatrixLoadVF<0b010,   0x0, "mle8.s">,   VLSSched<8>;
def MLE16_S       : MatrixLoadVF<0b010,   0x1, "mle16.s">,  VLSSched<8>;
def MLE32_S       : MatrixLoadVF<0b010,   0x2, "mle32.s">,  VLSSched<8>;

def MSE8_M        : MatrixStore<0b000,  0x0, "mse8.m">,   VLSSched<8>;
def MSE16_M       : MatrixStore<0b000,  0x1, "mse16.m">,  VLSSched<8>;
def MSE32_M       : MatrixStore<0b000,  0x2, "mse32.m">,  VLSSched<8>;

def MSE8_V        : MatrixStoreVF<0b001,  0x0, "mse8.v">,   VLSSched<8>;
def MSE16_V       : MatrixStoreVF<0b001,  0x1, "mse16.v">,  VLSSched<8>;
def MSE32_V       : MatrixStoreVF<0b001,  0x2, "mse32.v">,  VLSSched<8>;

def MSE8_S        : MatrixStoreVF<0b010,  0x0, "mse8.s">,   VLSSched<8>;
def MSE16_S       : MatrixStoreVF<0b010,  0x1, "mse16.s">,  VLSSched<8>;
def MSE32_S       : MatrixStoreVF<0b010,  0x2, "mse32.s">,  VLSSched<8>;

// unfloder load
def MLUFE8_M      : MatrixUFLoad<0b1100,   0x0, "mlufe8.m">,   VLSSched<8>;
def MLUFE16_M     : MatrixUFLoad<0b1100,   0x1, "mlufe16.m">,  VLSSched<8>;
def MLUFE32_M     : MatrixUFLoad<0b1100,   0x2, "mlufe32.m">,  VLSSched<8>;

def MSUFE8_M    : MatrixUFStore<0x0b1100,   0x0, "msufe8.m">,   VLSSched<8>;
def MSUFE16_M   : MatrixUFStore<0x0b1100,   0x1, "msufe16.m">,  VLSSched<8>;
def MSUFE32_M   : MatrixUFStore<0x0b1100,   0x2, "msufe32.m">,  VLSSched<8>;


// compute inst
def MMA_MM   : MALUMM<0b100011, 0, "mma.mm">;
def MWMA_MM  : MALUMM<0b100111, 0, "mwma.mm">;
def MQMA_MM  : MALUMM<0b101011, 0, "mqma.mm">;
def MFMA_MM  : MALUMM<0b100011, 1, "mfma.mm">;
def MFWMA_MM : MALUMM<0b100111, 1, "mfwma.mm">;

def MADD_MM     :  ADDSUBMM<0b0000, 0, "madd.mm">;
def MSUB_MM     :  ADDSUBMM<0b0001, 0, "msub.mm">;
def MRSUB_MM    :  ADDSUBMM<0b0010, 0, "mrsub.mm">;
def MEMUL_MM    :  ADDSUBMM<0b0011, 0, "memul.mm">;
def MMACC_MM    :  ADDSUBMM<0b0100, 0, "mmacc.mm">;
def MMSAC_MM    :  ADDSUBMM<0b0101, 0, "mmsac.mm">;
def MNMACC_MM   :  ADDSUBMM<0b0110, 0, "mnmacc.mm">;
def MNMSAC_MM   :  ADDSUBMM<0b0111, 0, "mnmsac.mm">;
def MWADD_MM    : WADDSUBMM<0b0000, 0, "mwadd.mm">;
def MWSUB_MM    : WADDSUBMM<0b0001, 0, "mwsub.mm">;
def MWRSUB_MM   : WADDSUBMM<0b0010, 0, "mwrsub.mm">;
def MWEMUL_MM   : WADDSUBMM<0b0011, 0, "mwemul.mm">;
def MWMACC_MM   : WADDSUBMM<0b0100, 0, "mwmacc.mm">;
def MWMSAC_MM   : WADDSUBMM<0b0101, 0, "mwmsac.mm">;
def MWNMACC_MM  : WADDSUBMM<0b0110, 0, "mwnmacc.mm">;
def MWNMSAC_MM  : WADDSUBMM<0b0111, 0, "mwnmsac.mm">;
def MDIV_MM     :  ADDSUBMM<0b1000, 0, "mdiv.mm">;
def MREM_MM     :  ADDSUBMM<0b1001, 0, "mrem.mm">;
def MMAX_MM     :  ADDSUBMM<0b1010, 0, "mmax.mm">;
def MMIN_MM     :  ADDSUBMM<0b1011, 0, "mmin.mm">;
def MFADD_MM    :  ADDSUBMM<0b0000, 1, "mfadd.mm">;
def MFSUB_MM    :  ADDSUBMM<0b0001, 1, "mfsub.mm">;
def MFRSUB_MM   :  ADDSUBMM<0b0010, 1, "mfrsub.mm">;
def MFEMUL_MM   :  ADDSUBMM<0b0011, 1, "mfemul.mm">;
def MFMACC_MM   :  ADDSUBMM<0b0100, 1, "mfmacc.mm">;
def MFMSAC_MM   :  ADDSUBMM<0b0101, 1, "mfmsac.mm">;
def MFNMACC_MM  :  ADDSUBMM<0b0110, 1, "mfnmacc.mm">;
def MFNMSAC_MM  :  ADDSUBMM<0b0111, 1, "mfnmsac.mm">;
def MFWADD_MM   : WADDSUBMM<0b0000, 1, "mfwadd.mm">;
def MFWSUB_MM   : WADDSUBMM<0b0001, 1, "mfwsub.mm">;
def MFWRSUB_MM  : WADDSUBMM<0b0010, 1, "mfwrsub.mm">;
def MFWEMUL_MM  : WADDSUBMM<0b0011, 1, "mfwemul.mm">;
def MFWMACC_MM  : WADDSUBMM<0b0100, 1, "mfwmacc.mm">;
def MFWMSAC_MM  : WADDSUBMM<0b0101, 1, "mfwmsac.mm">;
def MFWNMACC_MM : WADDSUBMM<0b0110, 1, "mfwnmacc.mm">;
def MFWNMSAC_MM : WADDSUBMM<0b0111, 1, "mfwnmsac.mm">;
def MFDIV_MM    :  ADDSUBMM<0b1000, 1, "mfdiv.mm">;
def MFMAX_MM    :  ADDSUBMM<0b1010, 1, "mfmax.mm">;
def MFMIN_MM    :  ADDSUBMM<0b1011, 1, "mfmin.mm">;


def MADD_MVR     :  ADDSUBMVR<0b0000, 0, "madd.mvr">;
def MSUB_MVR     :  ADDSUBMVR<0b0001, 0, "msub.mvr">;
def MRSUB_MVR    :  ADDSUBMVR<0b0010, 0, "mrsub.mvr">;
def MEMUL_MVR    :  ADDSUBMVR<0b0011, 0, "memul.mvr">;
def MMACC_MVR    :  ADDSUBMVR<0b0100, 0, "mmacc.mvr">;
def MMSAC_MVR    :  ADDSUBMVR<0b0101, 0, "mmsac.mvr">;
def MNMACC_MVR   :  ADDSUBMVR<0b0110, 0, "mnmacc.mvr">;
def MNMSAC_MVR   :  ADDSUBMVR<0b0111, 0, "mnmsac.mvr">;
def MWADD_MVR    : WADDSUBMVR<0b0000, 0, "mwadd.mvr">;
def MWSUB_MVR    : WADDSUBMVR<0b0001, 0, "mwsub.mvr">;
def MWRSUB_MVR   : WADDSUBMVR<0b0010, 0, "mwrsub.mvr">;
def MWEMUL_MVR   : WADDSUBMVR<0b0011, 0, "mwemul.mvr">;
def MWMACC_MVR   : WADDSUBMVR<0b0100, 0, "mwmacc.mvr">;
def MWMSAC_MVR   : WADDSUBMVR<0b0101, 0, "mwmsac.mvr">;
def MWNMACC_MVR  : WADDSUBMVR<0b0110, 0, "mwnmacc.mvr">;
def MWNMSAC_MVR  : WADDSUBMVR<0b0111, 0, "mwnmsac.mvr">;
def MDIV_MVR     :  ADDSUBMVR<0b1000, 0, "mdiv.mvr">;
def MREM_MVR     :  ADDSUBMVR<0b1001, 0, "mrem.mvr">;
def MMAX_MVR     :  ADDSUBMVR<0b1010, 0, "mmax.mvr">;
def MMIN_MVR     :  ADDSUBMVR<0b1011, 0, "mmin.mvr">;
def MFADD_MVR    :  ADDSUBMVR<0b0000, 1, "mfadd.mvr">;
def MFSUB_MVR    :  ADDSUBMVR<0b0001, 1, "mfsub.mvr">;
def MFRSUB_MVR   :  ADDSUBMVR<0b0010, 1, "mfrsub.mvr">;
def MFEMUL_MVR   :  ADDSUBMVR<0b0011, 1, "mfemul.mvr">;
def MFMACC_MVR   :  ADDSUBMVR<0b0100, 1, "mfmacc.mvr">;
def MFMSAC_MVR   :  ADDSUBMVR<0b0101, 1, "mfmsac.mvr">;
def MFNMACC_MVR  :  ADDSUBMVR<0b0110, 1, "mfnmacc.mvr">;
def MFNMSAC_MVR  :  ADDSUBMVR<0b0111, 1, "mfnmsac.mvr">;
def MFWADD_MVR   : WADDSUBMVR<0b0000, 1, "mfwadd.mvr">;
def MFWSUB_MVR   : WADDSUBMVR<0b0001, 1, "mfwsub.mvr">;
def MFWRSUB_MVR  : WADDSUBMVR<0b0010, 1, "mfwrsub.mvr">;
def MFWEMUL_MVR  : WADDSUBMVR<0b0011, 1, "mfwemul.mvr">;
def MFWMACC_MVR  : WADDSUBMVR<0b0100, 1, "mfwmacc.mvr">;
def MFWMSAC_MVR  : WADDSUBMVR<0b0101, 1, "mfwmsac.mvr">;
def MFWNMACC_MVR : WADDSUBMVR<0b0110, 1, "mfwnmacc.mvr">;
def MFWNMSAC_MVR : WADDSUBMVR<0b0111, 1, "mfwnmsac.mvr">;
def MFDIV_MVR    :  ADDSUBMVR<0b1000, 1, "mfdiv.mvr">;
def MFMAX_MVR    :  ADDSUBMVR<0b1010, 1, "mfmax.mvr">;
def MFMIN_MVR    :  ADDSUBMVR<0b1011, 1, "mfmin.mvr">;

def MADD_MVC     :  ADDSUBMVC<0b0000, 0, "madd.mvc">;
def MSUB_MVC     :  ADDSUBMVC<0b0001, 0, "msub.mvc">;
def MRSUB_MVC    :  ADDSUBMVC<0b0010, 0, "mrsub.mvc">;
def MEMUL_MVC    :  ADDSUBMVC<0b0011, 0, "memul.mvc">;
def MMACC_MVC    :  ADDSUBMVC<0b0100, 0, "mmacc.mvc">;
def MMSAC_MVC    :  ADDSUBMVC<0b0101, 0, "mmsac.mvc">;
def MNMACC_MVC   :  ADDSUBMVC<0b0110, 0, "mnmacc.mvc">;
def MNMSAC_MVC   :  ADDSUBMVC<0b0111, 0, "mnmsac.mvc">;
def MWADD_MVC    : WADDSUBMVC<0b0000, 0, "mwadd.mvc">;
def MWSUB_MVC    : WADDSUBMVC<0b0001, 0, "mwsub.mvc">;
def MWRSUB_MVC   : WADDSUBMVC<0b0010, 0, "mwrsub.mvc">;
def MWEMUL_MVC   : WADDSUBMVC<0b0011, 0, "mwemul.mvc">;
def MWMACC_MVC   : WADDSUBMVC<0b0100, 0, "mwmacc.mvc">;
def MWMSAC_MVC   : WADDSUBMVC<0b0101, 0, "mwmsac.mvc">;
def MWNMACC_MVC  : WADDSUBMVC<0b0110, 0, "mwnmacc.mvc">;
def MWNMSAC_MVC  : WADDSUBMVC<0b0111, 0, "mwnmsac.mvc">;
def MDIV_MVC     :  ADDSUBMVC<0b1000, 0, "mdiv.mvc">;
def MREM_MVC     :  ADDSUBMVC<0b1001, 0, "mrem.mvc">;
def MMAX_MVC     :  ADDSUBMVC<0b1010, 0, "mmax.mvc">;
def MMIN_MVC     :  ADDSUBMVC<0b1011, 0, "mmin.mvc">;
def MFADD_MVC    :  ADDSUBMVC<0b0000, 1, "mfadd.mvc">;
def MFSUB_MVC    :  ADDSUBMVC<0b0001, 1, "mfsub.mvc">;
def MFRSUB_MVC   :  ADDSUBMVC<0b0010, 1, "mfrsub.mvc">;
def MFEMUL_MVC   :  ADDSUBMVC<0b0011, 1, "mfemul.mvc">;
def MFMACC_MVC   :  ADDSUBMVC<0b0100, 1, "mfmacc.mvc">;
def MFMSAC_MVC   :  ADDSUBMVC<0b0101, 1, "mfmsac.mvc">;
def MFNMACC_MVC  :  ADDSUBMVC<0b0110, 1, "mfnmacc.mvc">;
def MFNMSAC_MVC  :  ADDSUBMVC<0b0111, 1, "mfnmsac.mvc">;
def MFWADD_MVC   : WADDSUBMVC<0b0000, 1, "mfwadd.mvc">;
def MFWSUB_MVC   : WADDSUBMVC<0b0001, 1, "mfwsub.mvc">;
def MFWRSUB_MVC  : WADDSUBMVC<0b0010, 1, "mfwrsub.mvc">;
def MFWEMUL_MVC  : WADDSUBMVC<0b0011, 1, "mfwemul.mvc">;
def MFWMACC_MVC  : WADDSUBMVC<0b0100, 1, "mfwmacc.mvc">;
def MFWMSAC_MVC  : WADDSUBMVC<0b0101, 1, "mfwmsac.mvc">;
def MFWNMACC_MVC : WADDSUBMVC<0b0110, 1, "mfwnmacc.mvc">;
def MFWNMSAC_MVC : WADDSUBMVC<0b0111, 1, "mfwnmsac.mvc">;
def MFDIV_MVC    :  ADDSUBMVC<0b1000, 1, "mfdiv.mvc">;
def MFMAX_MVC    :  ADDSUBMVC<0b1010, 1, "mfmax.mvc">;
def MFMIN_MVC    :  ADDSUBMVC<0b1011, 1, "mfmin.mvc">;


def MADD_MX     :  ADDSUBMX<0b0000, 0, "madd.mx">;
def MSUB_MX     :  ADDSUBMX<0b0001, 0, "msub.mx">;
def MRSUB_MX    :  ADDSUBMX<0b0010, 0, "mrsub.mx">;
def MEMUL_MX    :  ADDSUBMX<0b0011, 0, "memul.mx">;
def MMACC_MX    :  ADDSUBMX<0b0100, 0, "mmacc.mx">;
def MMSAC_MX    :  ADDSUBMX<0b0101, 0, "mmsac.mx">;
def MNMACC_MX   :  ADDSUBMX<0b0110, 0, "mnmacc.mx">;
def MNMSAC_MX   :  ADDSUBMX<0b0111, 0, "mnmsac.mx">;
def MWADD_MX    : WADDSUBMX<0b0000, 0, "mwadd.mx">;
def MWSUB_MX    : WADDSUBMX<0b0001, 0, "mwsub.mx">;
def MWRSUB_MX   : WADDSUBMX<0b0010, 0, "mwrsub.mx">;
def MWEMUL_MX   : WADDSUBMX<0b0011, 0, "mwemul.mx">;
def MWMACC_MX   : WADDSUBMX<0b0100, 0, "mwmacc.mx">;
def MWMSAC_MX   : WADDSUBMX<0b0101, 0, "mwmsac.mx">;
def MWNMACC_MX  : WADDSUBMX<0b0110, 0, "mwnmacc.mx">;
def MWNMSAC_MX  : WADDSUBMX<0b0111, 0, "mwnmsac.mx">;
def MDIV_MX     :  ADDSUBMX<0b1000, 0, "mdiv.mx">;
def MREM_MX     :  ADDSUBMX<0b1001, 0, "mrem.mx">;
def MMAX_MX     :  ADDSUBMX<0b1010, 0, "mmax.mx">;
def MMIN_MX     :  ADDSUBMX<0b1011, 0, "mmin.mx">;
def MFADD_MF    :  ADDSUBMF<0b0000, 1, "mfadd.mf">;
def MFSUB_MF    :  ADDSUBMF<0b0001, 1, "mfsub.mf">;
def MFRSUB_MF   :  ADDSUBMF<0b0010, 1, "mfrsub.mf">;
def MFEMUL_MF   :  ADDSUBMF<0b0011, 1, "mfemul.mf">;
def MFMACC_MF   :  ADDSUBMF<0b0100, 1, "mfmacc.mf">;
def MFMSAC_MF   :  ADDSUBMF<0b0101, 1, "mfmsac.mf">;
def MFNMACC_MF  :  ADDSUBMF<0b0110, 1, "mfnmacc.mf">;
def MFNMSAC_MF  :  ADDSUBMF<0b0111, 1, "mfnmsac.mf">;
def MFWADD_MF   : WADDSUBMF<0b0000, 1, "mfwadd.mf">;
def MFWSUB_MF   : WADDSUBMF<0b0001, 1, "mfwsub.mf">;
def MFWRSUB_MF  : WADDSUBMF<0b0010, 1, "mfwrsub.mf">;
def MFWEMUL_MF  : WADDSUBMF<0b0011, 1, "mfwemul.mf">;
def MFWMACC_MF  : WADDSUBMF<0b0100, 1, "mfwmacc.mf">;
def MFWMSAC_MF  : WADDSUBMF<0b0101, 1, "mfwmsac.mf">;
def MFWNMACC_MF : WADDSUBMF<0b0110, 1, "mfwnmacc.mf">;
def MFWNMSAC_MF : WADDSUBMF<0b0111, 1, "mfwnmsac.mf">;
def MFDIV_MF    :  ADDSUBMF<0b1000, 1, "mfdiv.mf">;
def MFMAX_MF    :  ADDSUBMF<0b1010, 1, "mfmax.mf">;
def MFMIN_MF    :  ADDSUBMF<0b1011, 1, "mfmin.mf">;


def MREDSUM_MS    : MREDUCEMS<0b1110, 0b00000, 0, "mredsum.ms">;
def MREDMAXU_MS   : MREDUCEMS<0b1110, 0b00001, 0, "mredmaxu.ms">;
def MREDMAX_MS    : MREDUCEMS<0b1110, 0b00010, 0, "mredmax.ms">;
def MREDMINU_MS   : MREDUCEMS<0b1110, 0b00011, 0, "mredminu.ms">;
def MREDMIN_MS    : MREDUCEMS<0b1110, 0b00100, 0, "mredmin.ms">;
def MREDAND_MS    : MREDUCEMS<0b1110, 0b00101, 0, "mredand.ms">;
def MREDOR_MS     : MREDUCEMS<0b1110, 0b00110, 0, "mredor.ms">;
def MREDXOR_MS    : MREDUCEMS<0b1110, 0b00111, 0, "mredxor.ms">;
def MFREDSUM_MS   : MREDUCEMS<0b1110, 0b00000, 1, "mfredsum.ms">;
def MFREDMAX_MS   : MREDUCEMS<0b1110, 0b00010, 1, "mfredmax.ms">;
def MFREDMIN_MS   : MREDUCEMS<0b1110, 0b00100, 1, "mfredmin.ms">;

def MREDSUM_MVR   : MREDUCEMVR<0b1110, 0b10000, 0, "mredsum.mvr">;
def MREDMAXU_MVR  : MREDUCEMVR<0b1110, 0b10001, 0, "mredmaxu.mvr">;
def MREDMAX_MVR   : MREDUCEMVR<0b1110, 0b10010, 0, "mredmax.mvr">;
def MREDMINU_MVR  : MREDUCEMVR<0b1110, 0b10011, 0, "mredminu.mvr">;
def MREDMIN_MVR   : MREDUCEMVR<0b1110, 0b10100, 0, "mredmin.mvr">;
def MREDAND_MVR   : MREDUCEMVR<0b1110, 0b10101, 0, "mredand.mvr">;
def MREDOR_MVR    : MREDUCEMVR<0b1110, 0b10110, 0, "mredor.mvr">;
def MREDXOR_MVR   : MREDUCEMVR<0b1110, 0b10111, 0, "mredxor.mvr">;
def MFREDSUM_MVR  : MREDUCEMVR<0b1110, 0b10000, 1, "mfredsum.mvr">;
def MFREDMAX_MVR  : MREDUCEMVR<0b1110, 0b10010, 1, "mfredmax.mvr">;
def MFREDMIN_MVR  : MREDUCEMVR<0b1110, 0b10100, 1, "mfredmin.mvr">;

def MREDSUM_MVC   : MREDUCEMVC<0b1110, 0b11000, 0, "mredsum.mvc">;
def MREDMAXU_MVC  : MREDUCEMVC<0b1110, 0b11001, 0, "mredmaxu.mvc">;
def MREDMAX_MVC   : MREDUCEMVC<0b1110, 0b11010, 0, "mredmax.mvc">;
def MREDMINU_MVC  : MREDUCEMVC<0b1110, 0b11011, 0, "mredminu.mvc">;
def MREDMIN_MVC   : MREDUCEMVC<0b1110, 0b11100, 0, "mredmin.mvc">;
def MREDAND_MVC   : MREDUCEMVC<0b1110, 0b11101, 0, "mredand.mvc">;
def MREDOR_MVC    : MREDUCEMVC<0b1110, 0b11110, 0, "mredor.mvc">;
def MREDXOR_MVC   : MREDUCEMVC<0b1110, 0b11111, 0, "mredxor.mvc">;
def MFREDSUM_MVC  : MREDUCEMVC<0b1110, 0b11000, 1, "mfredsum.mvc">;
def MFREDMAX_MVC  : MREDUCEMVC<0b1110, 0b11010, 1, "mfredmax.mvc">;
def MFREDMIN_MVC  : MREDUCEMVC<0b1110, 0b11100, 1, "mfredmin.mvc">;



 
def MFNCVT_F_FW_M  : MCVTMM<0b1111, 0b00000, 1, "mfncvt.f.fw.m">;
def MFWCVT_FW_F_M  : MCVTMM<0b1111, 0b00000, 0, "mfwcvt.fw.f.m">;
def MFCVT_F_X_M    : MCVTMM<0b1111, 0b00001, 1, "mfcvt.f.x.m">;
def MFCVT_X_F_M    : MCVTMM<0b1111, 0b00001, 0, "mfcvt.x.f.m">;
def MFNCVT_F_XW_M  : MCVTMM<0b1111, 0b00010, 1, "mfncvt.f.xw.m">;
def MFWCVT_XW_F_M  : MCVTMM<0b1111, 0b00010, 0, "mfwcvt.xw.f.m">;
def MFNCVT_F_XQ_M  : MCVTMM<0b1111, 0b00011, 1, "mfncvt.f.xq.m">;
def MFWCVT_XQ_F_M  : MCVTMM<0b1111, 0b00011, 0, "mfwcvt.xq.f.m">;
def MFWCVT_FW_X_M  : MCVTMM<0b1111, 0b00100, 1, "mfwcvt.fw.x.m">;
def MFNCVT_X_FW_M  : MCVTMM<0b1111, 0b00100, 0, "mfncvt.x.fw.m">;
def MFCVT_FW_XW_M  : MCVTMM<0b1111, 0b00101, 1, "mfcvt.fw.xw.m">;
def MFCVT_XW_FW_M  : MCVTMM<0b1111, 0b00101, 0, "mfcvt.xw.fw.m">;
def MFNCVT_FW_XQ_M : MCVTMM<0b1111, 0b00110, 1, "mfncvt.fw.xq.m">;
def MFWCVT_XQ_FW_M : MCVTMM<0b1111, 0b00110, 0, "mfwcvt.xq.fw.m">;

def MMV_M_I        : MMoveI<0b1111, 0b01000, "mmv.m.i">;
def MMV_M_X        : MMoveX<0b1111, 0b01001, 0, "mmv.m.x">;
def MMV_M_F        : MMoveF<0b1111, 0b01001, 1, "mmv.m.f">;
def MMV_M_V_R      : MCVTMM<0b1111, 0b01010, 0, "mmv.m.v.r">;
def MMV_M_V_C      : MCVTMM<0b1111, 0b01011, 0, "mmv.m.v.c">;
def MMV_M_M        : MCVTMM<0b1111, 0b01100, 0, "mmv.m.m">;

def MWMV_M_I       : MMoveWidenI<0b1111, 0b01000, "mwmv.m.i">;
def MWMV_M_X       : MMoveWidenX<0b1111, 0b01001, 0, "mwmv.m.x">;
def MWMV_M_F       : MMoveWidenF<0b1111, 0b01001, 1, "mwmv.m.f">;
def MWMV_M_V_R     : MMoveWidenMM<0b1111, 0b01010, 0, "mwmv.m.v.r">;
def MWMV_M_V_C     : MMoveWidenMM<0b1111, 0b01011, 0, "mwmv.m.v.c">;
def MWMV_M_M       : MMoveWidenMM<0b1111, 0b01100, 0, "mwmv.m.m">;

def MFEXP_M        : MCVTMM<0b1111, 0b10001, 1, "mfexp.m">;
def MFRSQRT_M      : MCVTMM<0b1111, 0b10010, 1, "mfrsqrt.m">;

def MFQUANT_MF     :   ADDSUBMF<0b1111, 1, "mfquant.mf">;
def MFDEQNT_MF     :  WADDSUBMF<0b1111, 1, "mfdeqnt.mf">;
def MFQUANT_MVC    :  ADDSUBMVC<0b1111, 1, "mfquant.mvc">;
def MFDEANT_MVC    : WADDSUBMVC<0b1111, 1, "mfdeqnt.mvc">;
def MFQUANT_MVR    :  ADDSUBMVR<0b1111, 1, "mfquant.mvr">;
def MFDEANT_MVR    : WADDSUBMVR<0b1111, 1, "mfdeqnt.mvr">;
def MQMAQ_MM       :  WADDSUBMM<0b1110, 0, "mqmaq.mvr">;
}