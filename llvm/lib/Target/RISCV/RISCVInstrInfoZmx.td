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
class MatrixLoadM<bits<3> funct6, bits<3> width, string opcodestr>
    : RVInstMLM<funct6, width,
                (outs TRR:$td),
                (ins GPR:$rs1, GPR:$rs2, MopiOp:$mopi), opcodestr,
                "$td, (${rs1}), $rs2, $mopi">;

class MatrixLoadV<bits<3> funct6, bits<3> width, string opcodestr>
    : RVInstMLV<funct6, width,
                (outs TRR:$td),
                (ins GPR:$rs1, MopiOp:$mopi), opcodestr,
                "$td, (${rs1}), $mopi">;

class MatrixLoadS<bits<6> funct6, bits<3> width, string opcodestr>
    : RVInstMLS<funct6, width,
                (outs TRR:$td),
                (ins GPR:$rs1), opcodestr,
                "$td, (${rs1})">;

class MatrixUFLoad<bits<4> funct6, bits<3> width, string opcodestr>
    : RVInstUFML<funct6, width,
                (outs TRR:$td),
                (ins GPR:$rs1, GPR:$rs2, MopiOp:$mopi), opcodestr,
                "$td, (${rs1}), $rs2, $mopi">;
} // hasSideEffects = 0, mayLoad = 1, mayStore = 0

let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in {
// store vd, ts3, (rs1), rs2
class MatrixStoreM<bits<3> funct6, bits<3> width, string opcodestr>
    : RVInstMSM<funct6, width, (outs),
                (ins TRR:$ts3, GPR:$rs1, GPR:$rs2, MopiOp:$mopi),
                opcodestr, "$ts3, (${rs1}), $rs2, $mopi">;

class MatrixStoreV<bits<3> funct6, bits<3> width, string opcodestr>
    : RVInstMSV<funct6, width, (outs),
                (ins TRR:$ts3, GPR:$rs1, MopiOp:$mopi),
                opcodestr, "$ts3, (${rs1}), $mopi">;

class MatrixStoreS<bits<6> funct6, bits<3> width, string opcodestr>
    : RVInstMSS<funct6, width, (outs),
                (ins TRR:$ts3, GPR:$rs1), opcodestr,
                "$ts3, (${rs1})">;

class MatrixUFStore<bits<4> funct6, bits<3> width, string opcodestr>
    : RVInstUFMS<funct6, width, (outs),
                (ins TRR:$ts3, GPR:$rs1, GPR:$rs2, MopiOp:$mopi),
                opcodestr, "$ts3, (${rs1}), $rs2, $mopi">;
} // hasSideEffects = 0, mayLoad = 0, mayStore = 1

// Matrix Arithmetic
let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
// op td, ts1, ts2
class MALUMM<bits<6> funct6, bit fp, string opcodestr>
    : RVInstMM<funct6, fp, (outs TRR:$td),
                (ins TRR:$ts1, TRR:$ts2),
                opcodestr, "$td, $ts1, $ts2">;

class ADDSUBMM<bits<6> funct6, bit fp, string opcodestr>
    : RVInstADDSUB<funct6, fp, 0b110, (outs TRR:$td),
                  (ins TRR:$ts1, TRR:$ts2),
                  opcodestr, "$td, $ts1, $ts2">;

class ADDSUBMVR<bits<6> funct6, bit fp, string opcodestr>
    : RVInstADDSUB<funct6, fp, 0b101, (outs TRR:$td),
                (ins TRR:$ts1, TRR:$ts2),
                opcodestr, "$td, $ts1, $ts2">;

class ADDSUBMVC<bits<6> funct6, bit fp, string opcodestr>
    : RVInstADDSUB<funct6, fp, 0b100, (outs TRR:$td),
                (ins TRR:$ts1, TRR:$ts2),
                opcodestr, "$td, $ts1, $ts2">;

class ADDSUBMX<bits<6> funct6, bit fp, string opcodestr>
    : RVInstADDSUBMX<funct6, fp, 0b011, (outs TRR:$td),
                (ins TRR:$ts1, GPR:$rs2),
                opcodestr, "$td, $ts1, $rs2">;

class ADDSUBMF<bits<6> funct6, bit fp, string opcodestr>
    : RVInstADDSUBMX<funct6, fp, 0b011, (outs TRR:$td),
                (ins TRR:$ts1, FPR32:$rs2),
                opcodestr, "$td, $ts1, $rs2">;



class MREDUCEMS<bits<6> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstReduce<funct6, fp, mode, 0b011,
                (outs TRR:$td), (ins TRR:$ts1),
                opcodestr, "$td, $ts1">;

class MREDUCEMVR<bits<6> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstReduce<funct6, fp, mode, 0b101,
                (outs TRR:$td), (ins TRR:$ts1),
                opcodestr, "$td, $ts1">;

class MREDUCEMVC<bits<6> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstReduce<funct6, fp, mode, 0b100,
                (outs TRR:$td), (ins TRR:$ts1),
                opcodestr, "$td, $ts1">;


class MCVTMM<bits<6> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstReduce<funct6, fp, mode, 0b110,
                (outs TRR:$td), (ins TRR:$ts1),
                opcodestr, "$td, $ts1">;

class MMoveI<bits<6> funct6, bits<5> mode, string opcodestr>
    : RVInstMoveMI<funct6, mode,
                (outs TRR:$td), (ins uimm5:$mimm5),
                opcodestr, "$td, $mimm5">;

class MMoveX<bits<6> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstMoveMX<funct6, fp, mode,
                (outs TRR:$td), (ins GPR:$rs1),
                opcodestr, "$td, $rs1">;

class MMoveF<bits<6> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstMoveMX<funct6, fp, mode,
                (outs TRR:$td), (ins FPR32:$rs1),
                opcodestr, "$td, $rs1">;

class MMoveM<bits<6> funct6, bits<5> mode, bit fp, string opcodestr>
    : RVInstMoveMM<funct6, fp, mode,
                (outs TRR:$td), (ins TRR:$ts1),
                opcodestr, "$td, $ts1">;

} // hasSideEffects = 0, mayLoad = 0, mayStore = 0


//===----------------------------------------------------------------------===//
// Instructions
//===----------------------------------------------------------------------===//
let Predicates = [HasStdExtM] in {
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

def MSETTILEMI : RVInstSetTilei<0b0010, (outs GPR:$rd), (ins uimm13:$mleni),
                         "msettilemi", "$rd, $mleni">;
def MSETTILEKI : RVInstSetTilei<0b0100, (outs GPR:$rd), (ins uimm13:$mleni),
                         "msettileki", "$rd, $mleni">;
def MSETTILENI : RVInstSetTilei<0b0110, (outs GPR:$rd), (ins uimm13:$mleni),
                         "msettileni", "$rd, $mleni">;


def MSETSK     : RVInstSetIm2col<0b1010, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                         "msetsk", "$rd, $rs1, $rs2">;
def MSETOUTSH  : RVInstSetIm2col<0b1000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                         "msetoutsh", "$rd, $rs1, $rs2">;
def MSETINSH   : RVInstSetIm2col<0b1001, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                         "msetinsh", "$rd, $rs1, $rs2">;
} // hasSideEffects = 1, mayLoad = 0, mayStore = 0

// Load Store Instructions
def MLE8_M        : MatrixLoadM<0b000,   0x0, "mle8.m">,   VLSSchedMC<8>;
def MLE16_M       : MatrixLoadM<0b000,   0x1, "mle16.m">,  VLSSchedMC<8>;
def MLE32_M       : MatrixLoadM<0b000,   0x2, "mle32.m">,  VLSSchedMC<8>;

def MLE8_V        : MatrixLoadV<0b001,   0x0, "mle8.v">,   VLSSchedMC<8>;
def MLE16_V       : MatrixLoadV<0b001,   0x1, "mle16.v">,  VLSSchedMC<8>;
def MLE32_V       : MatrixLoadV<0b001,   0x2, "mle32.v">,  VLSSchedMC<8>;

def MLE8_S        : MatrixLoadS<0b010000,   0x0, "mle8.s">,   VLSSchedMC<8>;
def MLE16_S       : MatrixLoadS<0b010000,   0x1, "mle16.s">,  VLSSchedMC<8>;
def MLE32_S       : MatrixLoadS<0b010000,   0x2, "mle32.s">,  VLSSchedMC<8>;

def MSE8_M        : MatrixStoreM<0b000,  0x0, "mse8.m">,   VLSSchedMC<8>;
def MSE16_M       : MatrixStoreM<0b000,  0x1, "mse16.m">,  VLSSchedMC<8>;
def MSE32_M       : MatrixStoreM<0b000,  0x2, "mse32.m">,  VLSSchedMC<8>;

def MSE8_V        : MatrixStoreV<0b001,  0x0, "mse8.v">,   VLSSchedMC<8>;
def MSE16_V       : MatrixStoreV<0b001,  0x1, "mse16.v">,  VLSSchedMC<8>;
def MSE32_V       : MatrixStoreV<0b001,  0x2, "mse32.v">,  VLSSchedMC<8>;

def MSE8_S        : MatrixStoreS<0b010000,  0x0, "mse8.s">,   VLSSchedMC<8>;
def MSE16_S       : MatrixStoreS<0b010000,  0x1, "mse16.s">,  VLSSchedMC<8>;
def MSE32_S       : MatrixStoreS<0b010000,  0x2, "mse32.s">,  VLSSchedMC<8>;

// unfloder load
def MLUFE8_M      : MatrixUFLoad<0b1100,   0x0, "mlufe8.m">,   VLSSchedMC<8>;
def MLUFE16_M     : MatrixUFLoad<0b1100,   0x1, "mlufe16.m">,  VLSSchedMC<8>;
def MLUFE32_M     : MatrixUFLoad<0b1100,   0x2, "mlufe32.m">,  VLSSchedMC<8>;

def MSUFE8_M    : MatrixUFStore<0x0b1100,   0x0, "msufe8.m">,   VLSSchedMC<8>;
def MSUFE16_M   : MatrixUFStore<0x0b1100,   0x1, "msufe16.m">,  VLSSchedMC<8>;
def MSUFE32_M   : MatrixUFStore<0x0b1100,   0x2, "msufe32.m">,  VLSSchedMC<8>;


// compute inst
def MMA_MM   : MALUMM<0b111101, 0, "mma.mm">;
def MFMA_MM  : MALUMM<0b111101, 1, "mfma.mm">;
def MWMA_MM  : MALUMM<0b111110, 0, "mwma.mm">;
def MFWMA_MM : MALUMM<0b111110, 1, "mfwma.mm">;
def MQMA_MM  : MALUMM<0b111111, 0, "mqma.mm">;


def MADD_MM      :  ADDSUBMM<0b000000, 0, "madd.mm">;
def MSUB_MM      :  ADDSUBMM<0b000001, 0, "msub.mm">;
def MRSUB_MM     :  ADDSUBMM<0b000010, 0, "mrsub.mm">;
def MEMUL_MM     :  ADDSUBMM<0b000011, 0, "memul.mm">;
def MMACC_MM     :  ADDSUBMM<0b000100, 0, "mmacc.mm">;
def MMSAC_MM     :  ADDSUBMM<0b000101, 0, "mmsac.mm">;
def MNMACC_MM    :  ADDSUBMM<0b000110, 0, "mnmacc.mm">;
def MNMSAC_MM    :  ADDSUBMM<0b000111, 0, "mnmsac.mm">;
def MDIV_MM      :  ADDSUBMM<0b001000, 0, "mdiv.mm">;
def MREM_MM      :  ADDSUBMM<0b001001, 0, "mrem.mm">;
def MMAX_MM      :  ADDSUBMM<0b001010, 0, "mmax.mm">;
def MMIN_MM      :  ADDSUBMM<0b001011, 0, "mmin.mm">;
def MFADD_MM     :  ADDSUBMM<0b000000, 1, "mfadd.mm">;
def MFSUB_MM     :  ADDSUBMM<0b000001, 1, "mfsub.mm">;
def MFRSUB_MM    :  ADDSUBMM<0b000010, 1, "mfrsub.mm">;
def MFEMUL_MM    :  ADDSUBMM<0b000011, 1, "mfemul.mm">;
def MFMACC_MM    :  ADDSUBMM<0b000100, 1, "mfmacc.mm">;
def MFMSAC_MM    :  ADDSUBMM<0b000101, 1, "mfmsac.mm">;
def MFNMACC_MM   :  ADDSUBMM<0b000110, 1, "mfnmacc.mm">;
def MFNMSAC_MM   :  ADDSUBMM<0b000111, 1, "mfnmsac.mm">;
def MFDIV_MM     :  ADDSUBMM<0b001000, 1, "mfdiv.mm">;
def MFMAX_MM     :  ADDSUBMM<0b001010, 1, "mfmax.mm">;
def MFMIN_MM     :  ADDSUBMM<0b001011, 1, "mfmin.mm">;


def MADD_MVR     : ADDSUBMVR<0b000000, 0, "madd.mvr">;
def MSUB_MVR     : ADDSUBMVR<0b000001, 0, "msub.mvr">;
def MRSUB_MVR    : ADDSUBMVR<0b000010, 0, "mrsub.mvr">;
def MEMUL_MVR    : ADDSUBMVR<0b000011, 0, "memul.mvr">;
def MMACC_MVR    : ADDSUBMVR<0b000100, 0, "mmacc.mvr">;
def MMSAC_MVR    : ADDSUBMVR<0b000101, 0, "mmsac.mvr">;
def MNMACC_MVR   : ADDSUBMVR<0b000110, 0, "mnmacc.mvr">;
def MNMSAC_MVR   : ADDSUBMVR<0b000111, 0, "mnmsac.mvr">;
def MDIV_MVR     : ADDSUBMVR<0b001000, 0, "mdiv.mvr">;
def MREM_MVR     : ADDSUBMVR<0b001001, 0, "mrem.mvr">;
def MMAX_MVR     : ADDSUBMVR<0b001010, 0, "mmax.mvr">;
def MMIN_MVR     : ADDSUBMVR<0b001011, 0, "mmin.mvr">;
def MFADD_MVR    : ADDSUBMVR<0b000000, 1, "mfadd.mvr">;
def MFSUB_MVR    : ADDSUBMVR<0b000001, 1, "mfsub.mvr">;
def MFRSUB_MVR   : ADDSUBMVR<0b000010, 1, "mfrsub.mvr">;
def MFEMUL_MVR   : ADDSUBMVR<0b000011, 1, "mfemul.mvr">;
def MFMACC_MVR   : ADDSUBMVR<0b000100, 1, "mfmacc.mvr">;
def MFMSAC_MVR   : ADDSUBMVR<0b000101, 1, "mfmsac.mvr">;
def MFNMACC_MVR  : ADDSUBMVR<0b000110, 1, "mfnmacc.mvr">;
def MFNMSAC_MVR  : ADDSUBMVR<0b000111, 1, "mfnmsac.mvr">;
def MFDIV_MVR    : ADDSUBMVR<0b001000, 1, "mfdiv.mvr">;
def MFMAX_MVR    : ADDSUBMVR<0b001010, 1, "mfmax.mvr">;
def MFMIN_MVR    : ADDSUBMVR<0b001011, 1, "mfmin.mvr">;

def MADD_MVC     :  ADDSUBMVC<0b000000, 0, "madd.mvc">;
def MSUB_MVC     :  ADDSUBMVC<0b000001, 0, "msub.mvc">;
def MRSUB_MVC    :  ADDSUBMVC<0b000010, 0, "mrsub.mvc">;
def MEMUL_MVC    :  ADDSUBMVC<0b000011, 0, "memul.mvc">;
def MMACC_MVC    :  ADDSUBMVC<0b000100, 0, "mmacc.mvc">;
def MMSAC_MVC    :  ADDSUBMVC<0b000101, 0, "mmsac.mvc">;
def MNMACC_MVC   :  ADDSUBMVC<0b000110, 0, "mnmacc.mvc">;
def MNMSAC_MVC   :  ADDSUBMVC<0b000111, 0, "mnmsac.mvc">;
def MDIV_MVC     :  ADDSUBMVC<0b001000, 0, "mdiv.mvc">;
def MREM_MVC     :  ADDSUBMVC<0b001001, 0, "mrem.mvc">;
def MMAX_MVC     :  ADDSUBMVC<0b001010, 0, "mmax.mvc">;
def MMIN_MVC     :  ADDSUBMVC<0b001011, 0, "mmin.mvc">;
def MFADD_MVC    :  ADDSUBMVC<0b000000, 1, "mfadd.mvc">;
def MFSUB_MVC    :  ADDSUBMVC<0b000001, 1, "mfsub.mvc">;
def MFRSUB_MVC   :  ADDSUBMVC<0b000010, 1, "mfrsub.mvc">;
def MFEMUL_MVC   :  ADDSUBMVC<0b000011, 1, "mfemul.mvc">;
def MFMACC_MVC   :  ADDSUBMVC<0b000100, 1, "mfmacc.mvc">;
def MFMSAC_MVC   :  ADDSUBMVC<0b000101, 1, "mfmsac.mvc">;
def MFNMACC_MVC  :  ADDSUBMVC<0b000110, 1, "mfnmacc.mvc">;
def MFNMSAC_MVC  :  ADDSUBMVC<0b000111, 1, "mfnmsac.mvc">;
def MFDIV_MVC    :  ADDSUBMVC<0b001000, 1, "mfdiv.mvc">;
def MFMAX_MVC    :  ADDSUBMVC<0b001010, 1, "mfmax.mvc">;
def MFMIN_MVC    :  ADDSUBMVC<0b001011, 1, "mfmin.mvc">;

def MADD_MX      :  ADDSUBMX<0b000000, 0, "madd.mx">;
def MSUB_MX      :  ADDSUBMX<0b000001, 0, "msub.mx">;
def MRSUB_MX     :  ADDSUBMX<0b000010, 0, "mrsub.mx">;
def MEMUL_MX     :  ADDSUBMX<0b000011, 0, "memul.mx">;
def MMACC_MX     :  ADDSUBMX<0b000100, 0, "mmacc.mx">;
def MMSAC_MX     :  ADDSUBMX<0b000101, 0, "mmsac.mx">;
def MNMACC_MX    :  ADDSUBMX<0b000110, 0, "mnmacc.mx">;
def MNMSAC_MX    :  ADDSUBMX<0b000111, 0, "mnmsac.mx">;
def MDIV_MX      :  ADDSUBMX<0b001000, 0, "mdiv.mx">;
def MREM_MX      :  ADDSUBMX<0b001001, 0, "mrem.mx">;
def MMAX_MX      :  ADDSUBMX<0b001010, 0, "mmax.mx">;
def MMIN_MX      :  ADDSUBMX<0b001011, 0, "mmin.mx">;
def MFADD_MF     :  ADDSUBMF<0b000000, 1, "mfadd.mf">;
def MFSUB_MF     :  ADDSUBMF<0b000001, 1, "mfsub.mf">;
def MFRSUB_MF    :  ADDSUBMF<0b000010, 1, "mfrsub.mf">;
def MFEMUL_MF    :  ADDSUBMF<0b000011, 1, "mfemul.mf">;
def MFMACC_MF    :  ADDSUBMF<0b000100, 1, "mfmacc.mf">;
def MFMSAC_MF    :  ADDSUBMF<0b000101, 1, "mfmsac.mf">;
def MFNMACC_MF   :  ADDSUBMF<0b000110, 1, "mfnmacc.mf">;
def MFNMSAC_MF   :  ADDSUBMF<0b000111, 1, "mfnmsac.mf">;
def MFDIV_MF     :  ADDSUBMF<0b001000, 1, "mfdiv.mf">;
def MFMAX_MF     :  ADDSUBMF<0b001010, 1, "mfmax.mf">;
def MFMIN_MF     :  ADDSUBMF<0b001011, 1, "mfmin.mf">;


def MREDSUM_MS     : MREDUCEMS<0b011101, 0b00000, 0, "mredsum.ms">;
def MREDMAX_MS     : MREDUCEMS<0b011101, 0b00001, 0, "mredmax.ms">;
def MREDMIN_MS     : MREDUCEMS<0b011101, 0b00010, 0, "mredmin.ms">;
def MREDAND_MS     : MREDUCEMS<0b011101, 0b00011, 0, "mredand.ms">;
def MREDOR_MS      : MREDUCEMS<0b011101, 0b00100, 0, "mredor.ms">;
def MREDXOR_MS     : MREDUCEMS<0b011101, 0b00101, 0, "mredxor.ms">;
def MFREDSUM_MS    : MREDUCEMS<0b011101, 0b00000, 1, "mfredsum.ms">;
def MFREDMAX_MS    : MREDUCEMS<0b011101, 0b00001, 1, "mfredmax.ms">;
def MFREDMIN_MS    : MREDUCEMS<0b011101, 0b00010, 1, "mfredmin.ms">;
def MWREDSUM_MS    : MREDUCEMS<0b011101, 0b10000, 0, "mwredsum.ms">;
def MQREDSUM_MS    : MREDUCEMS<0b011101, 0b10001, 0, "mqredsum.ms">;
def MFWREDSUM_MS   : MREDUCEMS<0b011101, 0b10000, 1, "mfwredsum.ms">;

def MREDSUM_MVR    : MREDUCEMVR<0b011101, 0b00000, 0, "mredsum.mvr">;
def MREDMAX_MVR    : MREDUCEMVR<0b011101, 0b00001, 0, "mredmax.mvr">;
def MREDMIN_MVR    : MREDUCEMVR<0b011101, 0b00010, 0, "mredmin.mvr">;
def MREDAND_MVR    : MREDUCEMVR<0b011101, 0b00011, 0, "mredand.mvr">;
def MREDOR_MVR     : MREDUCEMVR<0b011101, 0b00100, 0, "mredor.mvr">;
def MREDXOR_MVR    : MREDUCEMVR<0b011101, 0b00101, 0, "mredxor.mvr">;
def MFREDSUM_MVR   : MREDUCEMVR<0b011101, 0b00000, 1, "mfredsum.mvr">;
def MFREDMAX_MVR   : MREDUCEMVR<0b011101, 0b00001, 1, "mfredmax.mvr">;
def MFREDMIN_MVR   : MREDUCEMVR<0b011101, 0b00010, 1, "mfredmin.mvr">;
def MWREDSUM_MVR   : MREDUCEMVR<0b011101, 0b10000, 0, "mwredsum.mvr">;
def MQREDSUM_MVR   : MREDUCEMVR<0b011101, 0b10001, 0, "mqredsum.mvr">;
def MFWREDSUM_MVR  : MREDUCEMVR<0b011101, 0b10000, 1, "mfwredsum.mvr">;

def MREDSUM_MVC    : MREDUCEMVC<0b011101, 0b00000, 0, "mredsum.mvc">;
def MREDMAX_MVC    : MREDUCEMVC<0b011101, 0b00001, 0, "mredmax.mvc">;
def MREDMIN_MVC    : MREDUCEMVC<0b011101, 0b00010, 0, "mredmin.mvc">;
def MREDAND_MVC    : MREDUCEMVC<0b011101, 0b00011, 0, "mredand.mvc">;
def MREDOR_MVC     : MREDUCEMVC<0b011101, 0b00100, 0, "mredor.mvc">;
def MREDXOR_MVC    : MREDUCEMVC<0b011101, 0b00101, 0, "mredxor.mvc">;
def MFREDSUM_MVC   : MREDUCEMVC<0b011101, 0b00000, 1, "mfredsum.mvc">;
def MFREDMAX_MVC   : MREDUCEMVC<0b011101, 0b00001, 1, "mfredmax.mvc">;
def MFREDMIN_MVC   : MREDUCEMVC<0b011101, 0b00010, 1, "mfredmin.mvc">;
def MWREDSUM_MVC   : MREDUCEMVC<0b011101, 0b10000, 0, "mwredsum.mvc">;
def MQREDSUM_MVC   : MREDUCEMVC<0b011101, 0b10001, 0, "mqredsum.mvc">;
def MFWREDSUM_MVC  : MREDUCEMVC<0b011101, 0b10000, 1, "mfwredsum.mvc">;


def MFCVT_X_F_M    : MCVTMM<0b011100, 0b00000, 1, "mfcvt.x.f.m">;
def MFCVT_F_X_M    : MCVTMM<0b011100, 0b00001, 1, "mfcvt.f.x.m">;
def MFWCVT_XW_F_M  : MCVTMM<0b011100, 0b01000, 1, "mfwcvt.xw.f.m">;
def MFWCVT_FW_X_M  : MCVTMM<0b011100, 0b01001, 1, "mfwcvt.fw.x.m">;
def MFWCVT_FW_F_M  : MCVTMM<0b011100, 0b01010, 1, "mfwcvt.fw.f.m">;
def MFNCVT_X_FW_M  : MCVTMM<0b011100, 0b10000, 1, "mfncvt.x.fw.m">;
def MFNCVT_F_XW_M  : MCVTMM<0b011100, 0b10001, 1, "mfncvt.f.xw.m">;
def MFNCVT_F_FW_M  : MCVTMM<0b011100, 0b10010, 1, "mfncvt.f.fw.m">;



def MMV_M_I        : MMoveI<0b011011, 0b00000, "mmv.m.i">;
def MMV_M_X        : MMoveX<0b011011, 0b00001, 0, "mmv.m.x">;
def MMV_M_F        : MMoveF<0b011011, 0b00001, 1, "mmv.m.f">;
def MMV_M_V_R      : MMoveM<0b011011, 0b00010, 0, "mmv.m.v.r">;
def MMV_M_V_C      : MMoveM<0b011011, 0b00011, 0, "mmv.m.v.c">;
def MMV_M_M        : MMoveM<0b011011, 0b00100, 0, "mmv.m.m">;

def MWMV_M_I       : MMoveI<0b011011, 0b10000, "mwmv.m.i">;
def MWMV_M_X       : MMoveX<0b011011, 0b10001, 0, "mwmv.m.x">;
def MWMV_M_F       : MMoveF<0b011011, 0b10001, 1, "mwmv.m.f">;
def MWMV_M_V_R     : MMoveM<0b011011, 0b10010, 0, "mwmv.m.v.r">;
def MWMV_M_V_C     : MMoveM<0b011011, 0b10011, 0, "mwmv.m.v.c">;
def MWMV_M_M       : MMoveM<0b011011, 0b10100, 0, "mwmv.m.m">;

def MFEXP_M        : MCVTMM<0b011010, 0b00000, 1, "mfexp.m">;
def MFRSQRT_M      : MCVTMM<0b011010, 0b00001, 1, "mfrsqrt.m">;

def MFQUANT_MF     :  ADDSUBMF<0b011001, 1, "mfquant.mf">;
def MFDEQNT_MF     :  ADDSUBMF<0b011000, 1, "mfdeqnt.mf">;
def MFQUANT_MVC    : ADDSUBMVC<0b011001, 1, "mfquant.mvc">;
def MFDEQNT_MVC    : ADDSUBMVC<0b011000, 1, "mfdeqnt.mvc">;
def MFQUANT_MVR    : ADDSUBMVR<0b011001, 1, "mfquant.mvr">;
def MFDEANT_MVR    : ADDSUBMVR<0b011000, 1, "mfdeqnt.mvr">;
def MQMAQ_MM       :  ADDSUBMM<0b111100, 0, "mqmaq.mm">;
}
