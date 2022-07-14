###############################################################################
#                                                                             #
# Makefile for flang_extras                                                   #
#                                                                             #
#  Copyright 2022 -  The University of Western Australia                      #
#                                                                             #
###############################################################################

OSTYPE=$(shell uname -s)

objdir=obj
srcdir=src
moddir=mod
libdir=lib

FFLAGS=-module ${moddir}
ifeq (${WITH_CHECKS},true)
    FFLAGS+=-Mbounds
endif
FFLAGS+=-r8


OBJS=${objdir}/iso_c_bind.o      \
     ${objdir}/iso_fortran_env.o \
     ${objdir}/ieee_exceptions.o \
     ${objdir}/ieee_features.o   \
     ${objdir}/ieee_arithmetic.o

all: ${libdir}/libflang_extra.a

${libdir}/libflang_extra.a: ${objdir} ${moddir} ${libdir} ${OBJS}
	ar rv $@ ${OBJS}
	ranlib $@

clean: ${objdir} ${moddir} ${libdir}
	@/usr/bin/touch ${objdir}/1.o
	@/usr/bin/touch ${libdir}/1.a
	@/bin/rm ${objdir}/*.o

distclean: clean
	@/bin/rm -rf ${objdir} ${moddir} ${libdir}

${objdir}:
	@mkdir ${objdir}

${moddir}:
	@mkdir ${moddir}

${libdir}:
	@mkdir ${libdir}

${objdir}/%.o: ${srcdir}/%.F95
	flang ${FFLAGS} ${EXTRA_FLAGS} -c $< -o $@

${objdir}/%.o: ${srcdir}/%.f90
	flang ${FFLAGS} ${EXTRA_FLAGS} -c $< -o $@
