AS = /usr/bin/nasm
LD = /usr/bin/ld

ASFLAGS = -g -f elf64
LDFLAGS = -static

ifeq ($(MODE), REVERSE)
	ASFLAGS += -D REVERSE
endif

#lab2.s
SRCS = operations_with_matrix.s
OBJS = $(SRCS:.s=.o)

EXE = operations_with_matrix

all: $(SRCS) $(EXE)

clean:
	rm -rf $(EXE) $(OBJS)

$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

.s.o:
	$(AS) $(ASFLAGS) $< -o $@
