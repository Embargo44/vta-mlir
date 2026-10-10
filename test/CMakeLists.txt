configure_lit_site_cfg(
  ${CMAKE_CURRENT_SOURCE_DIR}/lit.site.cfg.py.in
  ${CMAKE_CURRENT_BINARY_DIR}/lit.site.cfg.py
  MAIN_CONFIG
  ${CMAKE_CURRENT_SOURCE_DIR}/lit.cfg.py
)

set(VTA_TEST_DEPENDS
  vta-opt
  vta-translate
)

add_lit_testsuite(check-vta "Running the VTA tests"
  ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS ${VTA_TEST_DEPENDS}
)
