//===--- RISCVToolchain.h - RISC-V ToolChain Implementations ----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_RISCVLLVMLINUXTOOLCHAIN_H
#define LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_RISCVLLVMLINUXTOOLCHAIN_H

#include "RISCVToolchain.h"
#include "clang/Driver/ToolChain.h"

namespace clang {
namespace driver {
namespace toolchains {

class LLVM_LIBRARY_VISIBILITY RISCVLLVMLinuxToolChain : public RISCVToolChain {
public:
  RISCVLLVMLinuxToolChain(const Driver &D, const llvm::Triple &Triple,
                          const llvm::opt::ArgList &Args)
      : RISCVToolChain(D, Triple, Args) {
    getFilePaths().push_back(computeSysRoot() + "/lib");
  }

  RuntimeLibType GetDefaultRuntimeLibType() const override;
  UnwindLibType GetUnwindLibType(const llvm::opt::ArgList &Args) const override;

  const char *getDefaultLinker() const override { return "ld.lld"; }

protected:
  Tool *buildLinker() const override;

private:
  std::string computeSysRoot() const override;
};

} // end namespace toolchains

namespace tools {
namespace RISCV {
class LLVM_LIBRARY_VISIBILITY LLVMLinker : public Tool {
public:
  LLVMLinker(const ToolChain &TC) : Tool("RISCV::LLVMLinker", "ld.lld", TC) {}
  bool hasIntegratedCPP() const override { return false; }
  bool isLinkJob() const override { return true; }
  void ConstructJob(Compilation &C, const JobAction &JA,
                    const InputInfo &Output, const InputInfoList &Inputs,
                    const llvm::opt::ArgList &TCArgs,
                    const char *LinkingOutput) const override;
};
} // end namespace RISCV
} // end namespace tools

} // end namespace driver
} // end namespace clang

#endif // LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_RISCVLLVMLINUXTOOLCHAIN_H
