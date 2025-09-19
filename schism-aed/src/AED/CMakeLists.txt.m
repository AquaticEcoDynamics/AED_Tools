if (USE_AED)
  if (WITH_AED_PLUS)
    message(STATUS "\n### Configuring AED+")
  else()
    message(STATUS "\n### Configuring AED")
  endif()

  set(schismmodlibs schism_aed ${schismmodlibs} PARENT_SCOPE)
  add_library(schism_aed schism_aed.F90)

  set(AED_ABASE /home/anonymous/libaed-api CACHE STRING "Path to AED API base")

  set(AED_WBASE /home/anonymous/libaed-water CACHE STRING "Path to AED main library base")
  set(AED_BBASE /home/anonymous/libaed-benthic CACHE STRING "Path to AED benthic base")
  set(AED_DBASE /home/anonymous/libaed-demo CACHE STRING "Path to AED demo base")

  set(AED_LIBRARIES -L${AED_ABASE}/lib -laed-api)
  list(APPEND AED_LIBRARIES -L${AED_WBASE}/lib -laed-water)
  list(APPEND AED_LIBRARIES -L${AED_BBASE}/lib -laed-benthic)
  list(APPEND AED_LIBRARIES -L${AED_DBASE}/lib -laed-demo)

  if (WITH_AED_PLUS)
    set(AED_RBASE /home/anonymous/libaed-riparian CACHE STRING "Path to AED riparian base")
    set(AED_LBASE /home/anonymous/libaed-light CACHE STRING "Path to AED light base")
    set(AED_VBASE /home/anonymous/libaed-dev CACHE STRING "Path to AED development base")
    set(AED_PBASE /home/anonymous/libplot CACHE STRING "Path to AED plotting base")
    set(AED_UBASE /home/anonymous/libutil CACHE STRING "Path to AED utils base")

    list(APPEND AED_LIBRARIES -L${AED_RBASE}/lib -laed-riparian)
    list(APPEND AED_LIBRARIES -L${AED_LBASE}/lib -laed-lighting)
    list(APPEND AED_LIBRARIES -L${AED_VBASE}/lib -laed-dev)
    list(APPEND AED_LIBRARIES -L${AED_UBASE}/lib -lutil)
    list(APPEND AED_LIBRARIES -L${AED_PBASE}/lib -lplot -lgd -lX11)
  else()
    list(APPEND AED_LIBRARIES ${AED_ABASE}/obj/aed_external.o)
  endif()

  message(STATUS "Adding AED library ${AED_LIBRARIES}")

# set(AED_INCLUDE_DIRS ${CMAKE_CURRENT_BINARY_DIR}/libaed/modules)
  list(APPEND AED_INCLUDE_DIRS ${CMAKE_CURRENT_BINARY_DIR}/../include)
  list(APPEND AED_INCLUDE_DIRS ${AED_ABASE}/include ${AED_ABASE}/mod)
  list(APPEND AED_INCLUDE_DIRS ${AED_WBASE}/include ${AED_WBASE}/mod)

  message(STATUS "Adding AED includes ${AED_INCLUDE_DIRS}")

  set_property(TARGET schism_aed APPEND PROPERTY INCLUDE_DIRECTORIES "${AED_INCLUDE_DIRS}")

##add_dependencies(schism_aed core)
  target_link_libraries(schism_aed ${AED_LIBRARIES} core)

  message(STATUS " ")
endif(USE_AED)
