#
# File:
#    Makefile
#
# Description:
#    Makefile for the TI (v3) Library using a VME Controller running Linux
#
# SVN: $Rev$
#
# Uncomment DEBUG line, to include some debugging info ( -g and -Wall)
DEBUG=1
#
#ARCH=Linux
ifndef ARCH
	ifdef LINUXVME_LIB
		ARCH=Linux
	else
		ARCH=VXWORKSPPC
	endif
endif

# Defs and build for VxWorks
ifeq ($(ARCH),VXWORKSPPC)
VXWORKS_ROOT = /site/vxworks/5.5/ppc/target

CC			= ccppc
LD			= ldppc
DEFS			= -mcpu=604 -DCPU=PPC604 -DVXWORKS -D_GNU_TOOL -mlongcall \
				-fno-for-scope -fno-builtin -fvolatile -DVXWORKSPPC
INCS			= -I. -I$(VXWORKS_ROOT)/h -I$(VXWORKS_ROOT)/h/rpc -I$(VXWORKS_ROOT)/h/net
CFLAGS			= $(INCS) $(DEFS)

endif #ARCH=VXWORKSPPC#

# Defs and build for Linux
ifeq ($(ARCH),Linux)
LINUXVME_LIB		?= ../lib
LINUXVME_INC		?= ../include

CC			= gcc
AR                      = ar
RANLIB                  = ranlib
CFLAGS			= -I. -I${LINUXVME_INC} -I/usr/include \
				-L${LINUXVME_LIB} -L.

LIBS			= libgtp.a
endif #ARCH=Linux#

ifdef DEBUG
CFLAGS			+= -Wall -g
else
CFLAGS			+= -O2
endif
SRC			= gtpVMELib.c gtpSocket.c gtpLib.c
HDRS			= $(SRC:.c=.h)
DEPS			= $(SRC:.c=.d)
OBJ			= $(SRC:.c=.o)

ifeq ($(ARCH),Linux)
all: echoarch $(LIBS) install
else
all: echoarch $(OBJ) copy
endif

%.o: %.c $(HDRS) Makefile
	$(CC) $(CFLAGS) -c -o $@ $<

$(LIBS): $(OBJ)
	$(CC) -fpic -shared $(CFLAGS) -o $(@:%.a=%.so) $(SRC)
	$(AR) ruv $@ $(OBJ)
	$(RANLIB) $@

ifeq ($(ARCH),Linux)
links: $(LIBS)
	@ln -vsf $(PWD)/$< $(LINUXVME_LIB)/$<
	@ln -vsf $(PWD)/$(<:%.a=%.so) $(LINUXVME_LIB)/$(<:%.a=%.so)
	@ln -vsf ${PWD}/*.h $(LINUXVME_INC)

install: $(LIBS)
	@cp -v $(PWD)/$< $(LINUXVME_LIB)/$<
	@cp -v $(PWD)/$(<:%.a=%.so) $(LINUXVME_LIB)/$(<:%.a=%.so)
	@cp -v ${PWD}/*.h $(LINUXVME_INC)

else
endif

%.d: %.c
	$(CC) -M $(CFLAGS) $< > $@

-include $(DEPS)

clean:
	@rm -vf *.{a,so,o}

echoarch:
	@echo "Make for $(ARCH)"

.PHONY: clean echoarch
