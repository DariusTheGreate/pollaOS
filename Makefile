
GCCPARAMS = -m32 -nostdlib -fno-builtin  -fno-exceptions -fno-leading-underscore
ASPARAMS = --32
LDPARAMS = -melf_i386

objects = loader.o vga.o ports.o kernel.o gdt.o 

%.o: %.c
	gcc $(GCCPARAMS) -c -o  $@ $< 

%.o: %.s
	as $(ASPARAMS) -o $@ $<

cockOSkernel.bin: linker.ld $(objects)
	ld $(LDPARAMS) -T $< -o $@ $(objects)

install: cockOSkernel.bin
	sudo cp $< /boot/cockOSkernel.bin

cockOSkernel.iso: cockOSkernel.bin
	mkdir -p iso
	mkdir -p iso/boot
	mkdir -p iso/boot/grub
	cp cockOSkernel.bin iso/boot/cockOSkernel.bin
	echo 'set timeout=0'                      > iso/boot/grub/grub.cfg
	echo 'set default=0'                     >> iso/boot/grub/grub.cfg
	echo ''                                  >> iso/boot/grub/grub.cfg
	echo 'menuentry "cockOS" {' >> iso/boot/grub/grub.cfg
	echo '  multiboot /boot/cockOSkernel.bin'    >> iso/boot/grub/grub.cfg
	echo '  boot'                            >> iso/boot/grub/grub.cfg
	echo '}'                                 >> iso/boot/grub/grub.cfg
	grub-mkrescue --output=cockOSkernel.iso iso

run: cockOSkernel.iso
	(killall VirtualBox && sleep 1) || true
	vboxmanage startvm 'cockOS' &

install: cockOSkernel.bin
	sudo cp $< /boot/cockOSkernel.bin

start: 
	make kernel.o
	make cockOSkernel.bin
	make cockOSkernel.iso
	make run
