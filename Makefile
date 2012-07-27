ALCHEMY=/path/to/alchemy/sdk
ALCEXTRA=/path/to/alcextra
GLS3D=/path/to/GLS3D

BUILD=$(PWD)/libs/build
INSTALL=$(PWD)/libs/install
SRCROOT=$(PWD)/

all:
	mkdir -p $(BUILD)
	mkdir -p $(INSTALL)

.PHONY: quake3 cube2

clean:
	rm -rf $(BUILD)
	rm -rf neverball-1.5.4/vfs
	find neverball-1.5.4/ | grep "\.o$$" | xargs rm -f
	find neverball-1.5.4/ | grep "\.abc$$" | xargs rm -f
	find neverball-1.5.4/ | grep "\.swf$$" | xargs rm -f
	find cube2/ | grep "\.o$$" | xargs rm -f
	find cube2/ | grep "\.abc$$" | xargs rm -f
	find cube2/ | grep "\.swf$$" | xargs rm -f

neverball:
	cd neverball-1.5.4 && PATH=$(ALCHEMY)/usr/bin:$(ALCEXTRA)/usr/bin:$(PATH) make ALCHEMY=$(ALCHEMY) GLS3D=$(GLS3D) ALCEXTRA=$(ALCEXTRA) -j8

quake3:
	cd Quake3 && PATH=$(ALCHEMY)/usr/bin:$(ALCEXTRA)/usr/bin:$(PATH) make ALCHEMY=$(ALCHEMY) GLS3D=$(GLS3D) ALCEXTRA=$(ALCEXTRA) BASEQ3DIR=$(BASEQ3DIR) -j8

cube2:
	cd cube2 && PATH=$(ALCHEMY)/usr/bin:$(ALCEXTRA)/usr/bin:$(PATH) make ALCHEMY=$(ALCHEMY) GLS3D=$(GLS3D) ALCEXTRA=$(ALCEXTRA) BASEQ3DIR=$(BASEQ3DIR) -j8 client

dosbox:
	mkdir -p $(BUILD)/dosbox
	
	#cd $(BUILD)/dosbox/ && PATH=$(ALCHEMY)/usr/bin:$(ALCEXTRA)/usr/bin:$(PATH) CFLAGS="-O4" CXXFLAGS="-O4 -I$(ALCEXTRA)/usr/include" \
	#	$(SRCROOT)/dosbox-0.74/configure --disable-debug --disable-sdltest --disable-alsa-midi \
	#	--disable-alsatest --disable-dynamic-core --disable-dynrec --disable-fpu-x86 --disable-opengl
	#cd $(BUILD)/dosbox/ && PATH=$(ALCHEMY)/usr/bin:$(ALCEXTRA)/usr/bin:$(PATH) make

	cd $(BUILD)/dosbox && $(ALCHEMY)/usr/bin/genfs --type=embed $(SRCROOT)/dosbox-0.74/fs scorch
	cd $(BUILD)/dosbox && cat scorch*.as > dosboxvfs.as
	
	cd $(BUILD)/dosbox && java -Xmx4000M -classpath $(ALCHEMY)/usr/lib/asc.jar macromedia.asc.embedding.ScriptCompiler \
		-abcfuture -AS3 -strict \
		-import $(ALCHEMY)/usr/lib/builtin.abc \
		-import $(ALCHEMY)/usr/lib/playerglobal.abc \
		-import $(ALCHEMY)/usr/lib/BinaryData.abc \
		-import $(ALCHEMY)/usr/lib/ISpecialFile.abc \
		-import $(ALCHEMY)/usr/lib/IBackingStore.abc \
       		-import $(ALCHEMY)/usr/lib/IBackingStoreManager.abc \
       		-import $(ALCHEMY)/usr/lib/InMemoryBackingStore.abc \
       		dosboxvfs.as -outdir . -out dosboxvfs
	
	cd $(BUILD)/dosbox/ && java -classpath $(ALCHEMY)/usr/lib/asc.jar macromedia.asc.embedding.ScriptCompiler \
	-abcfuture -AS3 -strict -optimize \
	-import $(ALCHEMY)/usr/lib/builtin.abc \
	-import $(ALCHEMY)/usr/lib/playerglobal.abc \
	-import $(ALCHEMY)/usr/lib/ISpecialFile.abc \
	-import $(ALCHEMY)/usr/lib/IBackingStore.abc \
	-import $(ALCHEMY)/usr/lib/IBackingStoreManager.abc \
	-import $(ALCHEMY)/usr/lib/CModule.abc \
	-import $(ALCHEMY)/usr/lib/C_Run.abc \
	-import $(ALCHEMY)/usr/lib/BinaryData.abc \
	-import $(ALCHEMY)/usr/lib/PlayerPosix.abc \
	$(SRCROOT)/dosbox-0.74/Console.as -outdir . -out Console
	
	cd $(BUILD)/dosbox/ && $(ALCHEMY)/usr/bin/g++ -O4 -pthread dosboxvfs.abc \
		src/dosbox.o \
src/cpu/libcpu.a src/debug/libdebug.a src/dos/libdos.a src/fpu/libfpu.a  src/hardware/libhardware.a src/gui/libgui.a src/ints/libints.a src/misc/libmisc.a src/shell/libshell.a src/hardware/serialport/libserial.a src/libs/gui_tk/libgui_tk.a \
		-lSDL -lm -lvgl -lpng -lz \
		-swf-size=1024x768 \
		-symbol-abc=Console.abc \
		-emit-swf -swf-version=17 -no-swf-preloader -o dosbox.swf
