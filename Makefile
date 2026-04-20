AS = /usr/bin/nasm
LD = /usr/bin/ld

ASFLAGS = -g -f elf64
LDFLAGS = -static

SRCS = ass_lab3.s
OBJS = $(SRCS:.s=.o)

EXE = ass_lab3

TEST_OUT = result.txt

all: $(SRCS) $(EXE)


$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@
%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

run: $(EXE)
	@echo "Запуск программы с выводом в $(TEST_OUT)..."
	./$(EXE) $(TEST_OUT)

clean:
	rm -rf $(EXE) $(OBJS)

# .s.o:
# 	$(AS) $(ASFLAGS) $< -o $@
