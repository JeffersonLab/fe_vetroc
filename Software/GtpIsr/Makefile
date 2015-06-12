#
# File:
#    Makefile
#
# Description:
#    Makefile for the TID Library using a VME Controller running Linux
#
# SVN: $Rev: 66 $
#
# Uncomment DEBUG line, to include some debugging info ( -g and -Wall)
DEBUG=1
NIOS=1
#

# Defs and build for Linux
LINUXVME_LIB		?= $CODA/extensions/linuxvme/libs
LINUXVME_INC		?= $CODA/extensions/linuxvme/include

ifdef NIOS
CC			= nios2-linux-gnu-gcc
AR                      = nios2-linux-gnu-ar
RANLIB                  = nios2-linux-gnu-ranlib
else
CC			= gcc
AR                      = ar
RANLIB                  = ranlib
endif
CFLAGS			= -I. -L.
LIBS			= -lrt -lpthread

ifdef DEBUG
CFLAGS			+= -Wall -g
else
CFLAGS			+= -O2
endif
PROGS			= GtpIsr
SRC			= GtpIsr.c
HEADERS			= $(wildcard *.h)
OBJS			= $(SRC:.C=.o)

all: $(PROGS) $(HEADERS)

clean distclean:
	@rm -f $(PROGS) *~ *.o

%.o: %.C Makefile
	@echo "aBuilding $@"
	$(CC) $(CFLAGS) -c $<

$(PROGS): $(OBJS) $(SRC) $(HEADERS) Makefile
	@echo "Building $@"
	$(CC) $(CFLAGS) -o $@ $(LIBS) $(OBJS)

.PHONY: all clean distclean
