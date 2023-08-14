//===-- RISCVInstrFormatsZmx.td - RISCV Zmx Instruction Formats --*- tablegen -*-=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//  This file describes the RISC-V Zmx extension instruction formats.
//
//===----------------------------------------------------------------------===//

class RVInstSetMTypei<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> rd;
  bits<13> mtypei;

  let Inst{31-28} = 0b0000;
  let Inst{27-15} = mtypei;
  let Inst{14-12} = 0b111;
  let Inst{11-7} = rd;
  let Opcode = OPC_OP_M.Value;

  let Defs = [MTYPE];
}

class RVInstSetMType<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> rs1;
  bits<5> rd;

  let Inst{31-28} = 0b0001;
  let Inst{27-20} = 0;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b111;
  let Inst{11-7} = rd;
  let Opcode = OPC_OP_M.Value;

  let Defs = [MTYPE];
}

class RVInstSetTilei<bits<4> mit, dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> rd;
  bits<13> mleni;

  let Inst{31-28} = mit;
  let Inst{27-15} = mleni;
  let Inst{14-12} = 0b111;
  let Inst{11-7} = rd;
  let Opcode = OPC_OP_M.Value;

  let Defs = [TILEM];
}

class RVInstSetTile<bits<4> mit, dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> rs1;
  bits<5> rd;

  let Inst{31-28} = mit;
  let Inst{27-20} = 0;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b111;
  let Inst{11-7} = rd;
  let Opcode = OPC_OP_M.Value;

  let Defs = [TILEM];
}

class RVInstSetConvi<bits<2> mit, dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> rd;
  bits<5> rs1;
  bits<8> mconvi;

  let Inst{31} = 1;
  let Inst{30-29} = mit;
  let Inst{28} = 0;
  let Inst{27-20} = mconvi;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b111;
  let Inst{11-7} = rd;
  let Opcode = OPC_OP_M.Value;

  let Defs = [TILEM];
}

class RVInstSetIm2col<bits<4> mit, dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> rs1;
  bits<5> rs2;
  bits<5> rd;

  let Inst{31-28} = mit;
  let Inst{27-25} = 0;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b111;
  let Inst{11-7} = rd;
  let Opcode = OPC_OP_M.Value;

  let Defs = [MINSH];
}

class RVInstML<bits<3> funct6, bits<3> width,
                dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> rs2;
  bits<5> rs1;
  bits<5> td;
  bits<3> mopi;

  let Inst{31-29} = funct6;
  let Inst{28-26} = mopi;
  let Inst{25} = 0; // load
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = width;
  let Inst{11-7} = td;
  let Opcode = OPC_OP_M.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMLVF<bits<3> funct6, bits<3> width,
                dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> rs1;
  bits<5> td;
  bits<3> mopi;

  let Inst{31-29} = funct6;
  let Inst{28-26} = mopi;
  let Inst{25} = 0; // load
  let Inst{24-20} = 0;
  let Inst{19-15} = rs1;
  let Inst{14-12} = width;
  let Inst{11-7} = td;
  let Opcode = OPC_OP_M.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstUFML<bits<4> funct6, bits<3> width,
                dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> rs2;
  bits<5> rs1;
  bits<5> td;
  bits<2> mopi;

  let Inst{31-28} = funct6;
  let Inst{27-26} = mopi;
  let Inst{25} = 0; // load
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = width;
  let Inst{11-7} = td;
  let Opcode = OPC_OP_M.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMS<bits<3> funct6, bits<3> width,
                dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> rs2;
  bits<5> rs1;
  bits<5> ts3;
  bits<3> mopi;

  let Inst{31-29} = funct6;
  let Inst{28-26} = mopi;
  let Inst{25} = 1; // store
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = width;
  let Inst{11-7} = ts3;
  let Opcode = OPC_OP_M.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMSVF<bits<3> funct6, bits<3> width,
                dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> rs1;
  bits<5> ts3;
  bits<3> mopi;

  let Inst{31-29} = funct6;
  let Inst{28-26} = mopi;
  let Inst{25} = 1; // store
  let Inst{24-20} = 0;
  let Inst{19-15} = rs1;
  let Inst{14-12} = width;
  let Inst{11-7} = ts3;
  let Opcode = OPC_OP_M.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstUFMS<bits<4> funct6, bits<3> width,
                dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> rs2;
  bits<5> rs1;
  bits<5> ts3;
  bits<2> mopi;

  let Inst{31-28} = funct6;
  let Inst{27-26} = mopi;
  let Inst{25} = 1; // store
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = width;
  let Inst{11-7} = ts3;
  let Opcode = OPC_OP_M.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMM<bits<6> funct6, bit fp, dag outs, dag ins,
               string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> ts2;
  bits<5> ts1;
  bits<5> td;

  let Inst{31-26} = funct6;
  let Inst{25} = fp;
  let Inst{24-20} = ts2;
  let Inst{19-15} = ts1;
  let Inst{14-12} = 0b110;
  let Inst{11-7} = td;
  let Opcode = OPC_OP_M.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstReduce<bits<4> funct6, bit fp, bits<5> mode, bits<3> tt, dag outs, dag ins,
               string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> ts1;
  bits<5> td;
  bits<2> mopi;

  let Inst{31-28} = funct6;
  let Inst{27-26} = mopi;
  let Inst{25} = fp;
  let Inst{24-20} = mode;
  let Inst{19-15} = ts1;
  let Inst{14-12} = tt;
  let Inst{11-7} = td;
  let Opcode = OPC_OP_M.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstADDSUB<bits<4> funct6, bit fp, bits<3> tt, dag outs, dag ins,
               string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> ts1;
  bits<5> ts2;
  bits<5> td;
  bits<2> mopi;

  let Inst{31-28} = funct6;
  let Inst{27-26} = mopi;
  let Inst{25} = fp;
  let Inst{24-20} = ts2;
  let Inst{19-15} = ts1;
  let Inst{14-12} = tt;
  let Inst{11-7} = td;
  let Opcode = OPC_OP_M.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstWidenADDSUB<bits<4> funct6, bit fp, bits<3> tt, dag outs, dag ins,
               string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> ts1;
  bits<5> ts2;
  bits<5> td;

  let Inst{31-28} = funct6;
  let Inst{27-26} = 11;
  let Inst{25} = fp;
  let Inst{24-20} = ts2;
  let Inst{19-15} = ts1;
  let Inst{14-12} = tt;
  let Inst{11-7} = td;
  let Opcode = OPC_OP_M.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstADDSUBMX<bits<4> funct6, bit fp, bits<3> tt, dag outs, dag ins,
               string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> ts1;
  bits<5> rs2;
  bits<5> td;
  bits<2> mopi;

  let Inst{31-28} = funct6;
  let Inst{27-26} = mopi;
  let Inst{25} = fp;
  let Inst{24-20} = rs2;
  let Inst{19-15} = ts1;
  let Inst{14-12} = tt;
  let Inst{11-7} = td;
  let Opcode = OPC_OP_M.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstWidenADDSUBMX<bits<4> funct6, bit fp, bits<3> tt, dag outs, dag ins,
               string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> ts1;
  bits<5> rs2;
  bits<5> td;

  let Inst{31-28} = funct6;
  let Inst{27-26} = 11;
  let Inst{25} = fp;
  let Inst{24-20} = rs2;
  let Inst{19-15} = ts1;
  let Inst{14-12} = tt;
  let Inst{11-7} = td;
  let Opcode = OPC_OP_M.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}


class RVInstMoveMI<bits<4> funct6, bits<5> mode, dag outs, dag ins,
                string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> td;
  bits<5> mimm5;
  bits<2> mopi;

  let Inst{31-28} = funct6;
  let Inst{27-26} = mopi;
  let Inst{25} = 0;
  let Inst{24-20} = mode;
  let Inst{19-15} = mimm5;
  let Inst{14-12} = 0b110;
  let Inst{11-7} = td;
  let Opcode = OPC_OP_M.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMoveWidenMI<bits<4> funct6, bits<5> mode, dag outs, dag ins,
                string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> td;
  bits<5> mimm5;

  let Inst{31-28} = funct6;
  let Inst{27-26} = 0b11;
  let Inst{25} = 0;
  let Inst{24-20} = mode;
  let Inst{19-15} = mimm5;
  let Inst{14-12} = 0b110;
  let Inst{11-7} = td;
  let Opcode = OPC_OP_M.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMoveMX<bits<4> funct6, bit fp, bits<5> mode, dag outs, dag ins,
                string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> td;
  bits<5> rs1;
  bits<2> mopi;

  let Inst{31-28} = funct6;
  let Inst{27-26} = mopi;
  let Inst{25} = fp;
  let Inst{24-20} = mode;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b110;
  let Inst{11-7} = td;
  let Opcode = OPC_OP_M.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}



class RVInstMoveWidenMX<bits<4> funct6, bit fp, bits<5> mode, dag outs, dag ins,
                string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> td;
  bits<5> rs1;

  let Inst{31-28} = funct6;
  let Inst{27-26} = 0b11;
  let Inst{25} = fp;
  let Inst{24-20} = mode;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b110;
  let Inst{11-7} = td;
  let Opcode = OPC_OP_M.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}


class RVInstMoveWidenMM<bits<4> funct6, bit fp, bits<5> mode, dag outs, dag ins,
                string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> td;
  bits<5> ts1;

  let Inst{31-28} = funct6;
  let Inst{27-26} = 0b11;
  let Inst{25} = fp;
  let Inst{24-20} = mode;
  let Inst{19-15} = ts1;
  let Inst{14-12} = 0b110;
  let Inst{11-7} = td;
  let Opcode = OPC_OP_M.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}