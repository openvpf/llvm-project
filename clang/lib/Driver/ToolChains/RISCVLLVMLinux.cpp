//===--- RISCVToolchain.cpp - RISC-V ToolChain Implementations --*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "RISCVLLVMLinux.h"
#include "CommonArgs.h"
#include "clang/Driver/Compilation.h"
#include "clang/Driver/InputInfo.h"
#include "clang/Driver/Options.h"
#include "llvm/Option/ArgList.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/raw_ostream.h"

using namespace clang::driver;
using namespace clang::driver::toolchains;
using namespace clang::driver::tools;
using namespace clang;
using namespace llvm::opt;

ToolChain::RuntimeLibType
RISCVLLVMLinuxToolChain::GetDefaultRuntimeLibType() const {
  return ToolChain::RLT_None;
}

ToolChain::UnwindLibType RISCVLLVMLinuxToolChain::GetUnwindLibType(
    const llvm::opt::ArgList &Args) const {
  return ToolChain::UNW_None;
}

std::string RISCVLLVMLinuxToolChain::computeSysRoot() const {
  if (!getDriver().SysRoot.empty())
    return getDriver().SysRoot;

  SmallString<128> SysRootDir;

  llvm::sys::path::append(SysRootDir, getDriver().Dir, "..");

  if (!llvm::sys::fs::exists(SysRootDir))
    return std::string();

  return std::string(SysRootDir.str());
}

Tool *RISCVLLVMLinuxToolChain::buildLinker() const {
  return new tools::RISCV::LLVMLinker(*this);
}

void RISCV::LLVMLinker::ConstructJob(Compilation &C, const JobAction &JA,
                                     const InputInfo &Output,
                                     const InputInfoList &Inputs,
                                     const ArgList &Args,
                                     const char *LinkingOutput) const {
  const ToolChain &ToolChain = getToolChain();
  const Driver &D = ToolChain.getDriver();
  ArgStringList CmdArgs;

  if (!D.SysRoot.empty())
    CmdArgs.push_back(Args.MakeArgString("--sysroot=" + D.SysRoot));

  bool IsRV64 = ToolChain.getArch() == llvm::Triple::riscv64;
  CmdArgs.push_back("-m");
  if (IsRV64) {
    CmdArgs.push_back("elf64lriscv");
  } else {
    CmdArgs.push_back("elf32lriscv");
  }
  CmdArgs.push_back("-X");

  std::string Linker = getToolChain().GetLinkerPath();

  CmdArgs.push_back(Args.MakeArgString(ToolChain.GetFilePath("crt1.o")));
  CmdArgs.push_back(Args.MakeArgString(ToolChain.GetFilePath("crti.o")));

  AddLinkerInputs(ToolChain, Inputs, Args, CmdArgs, JA);

  Args.AddAllArgs(CmdArgs, options::OPT_L);
  Args.AddAllArgs(CmdArgs, options::OPT_u);
  ToolChain.AddFilePathLibArgs(Args, CmdArgs);
  Args.AddAllArgs(CmdArgs,
                  {options::OPT_T_Group, options::OPT_s, options::OPT_t,
                   options::OPT_Z_Flag, options::OPT_r});

  // TODO: add C++ includes and libs if compiling C++.

  if (!Args.hasArg(options::OPT_nostdlib) &&
      !Args.hasArg(options::OPT_nodefaultlibs)) {
    if (D.CCCIsCXX()) {
      if (ToolChain.ShouldLinkCXXStdlib(Args))
        ToolChain.AddCXXStdlibLibArgs(Args, CmdArgs);
      CmdArgs.push_back("-lm");
    }
    CmdArgs.push_back("--start-group");
    CmdArgs.push_back("-lc");
    CmdArgs.push_back("--end-group");
  }

  CmdArgs.push_back(Args.MakeArgString(ToolChain.GetFilePath("crtn.o")));

  CmdArgs.push_back("-o");
  CmdArgs.push_back(Output.getFilename());
  C.addCommand(std::make_unique<Command>(
      JA, *this, ResponseFileSupport::AtFileCurCP(), Args.MakeArgString(Linker),
      CmdArgs, Inputs, Output));
}

// RISCV tools end.
