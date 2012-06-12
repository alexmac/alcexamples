ALCHEMY=/path/to/alchemy/sdk
ALCEXTRA=/path/to/alcextra
GLS3D=/path/to/GLS3D

BUILD=$(PWD)/libs/build
INSTALL=$(PWD)/libs/install
SRCROOT=$(PWD)/libs

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
