# This is a sample defs.mk, based on one generated by configure. 
# If configure screws up or won't do what you want (it's not very flexible),
# copy this file over the defs.mk it generated and edit as necessary.

# 
# The purpose of this file is to hold all the makefile definitions
# needed to adjust the OS/161 build process to any particular
# environment. Hopefully, even if you need to use it and edit by hand,
# you still won't need to edit any of the other makefiles when changing
# environments. Do remember to make clean if you change environments 
# though.
#

#
# Initialize various variables that we set only with += in case some make
# has a default value we weren't expecting.
#
CFLAGS=
KCFLAGS=
HOST_CFLAGS=
LDFLAGS=
KLDFLAGS=
HOST_LDFLAGS=
LIBS=
HOST_LIBS=

#
# Location of installed runnable system tree.
#
# This must be an absolute path, because it is used from different
# levels of the source tree.
#
OSTREE=$(HOME)/ece344/root

#
# Name of the platform we're building OS/161 to run on.
#
PLATFORM=mips

#
# As of cs161-toolchain-1.2 the MIPS toolchain is a mips-linux one
# that generates more or less SVR4 ELF ABI compliant code. This means
# that by default all code is PIC (position-independent code), which
# is all very well but not what we want. So we use -fno-pic to turn
# this behavior off. It turns out you need -mno-abicalls too to turn
# it off completely.
#
# Comment this out if not on MIPS.
#
CFLAGS+=-mno-abicalls -fno-pic
KCFLAGS+=-mno-abicalls -fno-pic

# If using an older cs161 MIPS toolchain, you'll need this instead:
#LDFLAGS+=-Ttext 0x1000

#
# Because OS/161 runs on one architecture (probably MIPS or ANT32) and
# is compiled on another (probably Alpha or i386) it is important to
# make sure the right compiler (and assembler, linker, etc.) is used
# at every point.
#
# A compiler compiles *running on* one platform, and *generates code*
# that may run on a different platform. Thus, supposing that you are 
# building MIPS OS/161 on i386 Linux, there are four possible compilers.
# (If you are building some other OS/161 or building on some other
# platform, make the appropriate substitutions.) These four are:
#
#    (1) runs on i386 Linux, generates code for i386 Linux
#    (2) runs on i386 Linux, generates code for MIPS OS/161
#    (3) runs on MIPS OS/161, generates code for i386 Linux
#    (4) runs on MIPS OS/161, generates code for MIPS OS/161
#
# Note that when building on i386 Linux, there is no use for a
# compiler that runs on MIPS OS/161; you can't run it. Thus cases
# (3) and (4) do not interest us.
#
# However, in the course of the build, there are places where it is
# necessary to compile and run programs on the machine the build is
# happening on. Thus, the makefiles need to be able to access *both*
# compiler (1) and compiler (2).
#
# We do this by defining the make variable CC to be the common case,
# compiler (2), and the make variable HOST_CC to be compiler (1). 
# Similar variables are defined for the other bits of the toolchain,
# like AS (assembler), LD (linker), and SIZE (size program).
#
# Then, programs to be run during the build can be compiled with 
# HOST_CC, and components of the system can be built with CC.
#

# The default names are cs161-gcc, cs161-ld, etc. These are the ones
# installed in ~lib161/usr. If you compile your own copies, they may
# be named something else, such as sde-gcc, mips-linux-gcc, etc.
TOOL=cs161-

# CC: compiler, when compiling to object files
CC=$(TOOL)gcc 

# LDCC: compiler, when linking.
LDCC=$(TOOL)gcc

# AS: assembler.
AS=$(TOOL)as

# LD: linker
LD=$(TOOL)ld

# AR: archiver (librarian)
AR=$(TOOL)ar

# RANLIB: library postprocessor
RANLIB=$(TOOL)ranlib

# SIZE: prints size of binaries
SIZE=$(TOOL)size

# STRIP: strips debug info
STRIP=$(TOOL)strip


# compiler for host system
HOST_CC=gcc

# compiler for host system, when linking
HOST_LDCC=gcc

# assembler for host system
HOST_AS=as

# linker for host system
HOST_LD=ld

# archiver (librarian) for host system
HOST_AR=ar

# ranlib (library postprocessor) for host system... or "true" to skip it
HOST_RANLIB=ranlib

# size for host system
HOST_SIZE=size

# strip for host system
HOST_STRIP=strip



WARNINGS=-Wall -W -Wwrite-strings
# This will make the build stop on warnings, instead of letting them scroll
# by and get missed. Recommended, but turned off by default because it can
# be annoying.
#WARNINGS+=-Werror

# The HOST_... versions are for compiling/linking for the host system.
# The K... versions are for the kernel build. 

# Compile flags. 
# The kernel has its own debug/optimize setting in the kernel config, so
# we don't include -O2.
CFLAGS+=$(WARNINGS) -O2
KCFLAGS+=$(WARNINGS)
HOST_CFLAGS+=$(WARNINGS) -O2 -I$(OSTREE)/hostinclude

# Linker flags
LDFLAGS+=
KLDFLAGS+=
HOST_LDFLAGS+=

# Libraries
# 
LIBS+=
HOST_LIBS+=


# If your host system doesn't support the 4.4BSD <err.h> and its
# functions (err, errx, warn, warnx, verr, verrx, vwarn, vwarnx),
# uncomment the next two lines.
#COMPAT_CFLAGS+=-DNEED_ERR
#COMPAT_TARGETS+=install_errh


# When we compile OS/161 programs, we want to use the OS/161 header files
# and libraries. By default, gcc will look in some include directory and
# some lib directory that it was told to use when it was compiled. 
#
# If that directory isn't our OSTREE, leave these alone. If it is,
# you can comment them out.
TREE_CFLAGS=-nostdinc -I$(OSTREE)/include
TREE_LDFLAGS=-nostdlib -L$(OSTREE)/lib $(OSTREE)/lib/crt0.o
TREE_LIBS=-lc

