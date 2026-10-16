import os
import lit.formats

config.name = "VTA"
config.test_format = lit.formats.ShTest(False)

config.suffixes = ['.mlir']

config.test_source_root = os.path.dirname(__file__)
config.test_exec_root = os.path.join(config.vta_obj_root, 'test')

config.substitutions.append(('%vta-opt', os.path.join(config.vta_tools_dir, 'vta-opt')))
config.substitutions.append(('%vta-translate', os.path.join(config.vta_tools_dir, 'vta-translate')))
config.substitutions.append(('%FileCheck', os.path.join(config.llvm_tools_dir, 'FileCheck')))
