.PHONY: clean run msx

day1_test.rom: day1_test.asm day1.asm
	zasm -uy day1_test.asm

msx: day1_msx.rom
day1_msx.rom: day1_msx.asm day1.asm
	zasm -uy day1_msx.asm

clean:
	rm *.rom *.lst

run: day1_msx.rom
	openmsx day1_msx.rom
