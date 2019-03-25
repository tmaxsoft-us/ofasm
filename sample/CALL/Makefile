target = CALL01

OFASM = $(OFASM_HOME)/bin/ofasm

LDFLAGS += -L$(OFASM_HOME)/lib -lofasmVM -L$(TMAXDIR)/lib -lcli
CFLAGS += -g

result=OUT

all: $(target)

$(target): main.cpp CALL01.asmo CALL01.so CALL01_01.so CALL01_01_OFASM_VM_EXIT.so
	g++ $(CFLAGS) -o $@ main.cpp CALL01.so $(LDFLAGS)

CALL01.asmo: CALL01.asm
	$(OFASM) CALL01.asm

CALL01.so: CALL01.json
	ofasmif -i CALL01.json
	g++ -shared -fPIC $(CFLAGS) -o $@ CALL01_OFASM_VM_ENTRY.cpp

CALL01_01_OFASM_VM_EXIT.so: CALL01_01_OFASM_VM_EXIT.cpp CALL01_01.so
	gcc -shared -fPIC $(CFLAGS) -o $@ CALL01_01_OFASM_VM_EXIT.cpp CALL01_01.so

CALL01_01.so: CALL01_01.cpp
	gcc -shared -fPIC $(CFLAGS) -o $@ CALL01_01.cpp

clean:
	$(RM) $(target) $(result) *.so  *.asmi *.asmo  *_OFASM_VM_ENTRY.cpp 

test:
	@./$(target) > $(result)
	@diff $(result) $(result).result	
