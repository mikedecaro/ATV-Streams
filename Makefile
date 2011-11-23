GO_EASY_ON_ME=1
SDKVERSION=4.1
FW_DEVICE_IP=apple-tv.local
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Streams
Streams_FILES = Classes/streams.mm Classes/CPlusFunctions.mm Classes/EngadgetMenu.m
Streams_INSTALL_PATH = /Applications/Lowtide.app/Appliances
Streams_BUNDLE_EXTENSION = frappliance
Streams_FRAMEWORKS = Foundation CoreGraphics CFNetwork SystemConfiguration AudioToolbox Security MediaPlayer
Streams_LDFLAGS = -undefined dynamic_lookup
Streams_OTHER_LDFLAGS = -all_load -ObjC
Streams_OBJ_FILES = ../SMFramework/obj/SMFramework

include $(FW_MAKEDIR)/bundle.mk
include $(FW_MAKEDIR)/aggregate.mk
after-Streams-stage::
	mkdir -p $(FW_STAGING_DIR)/Applications/AppleTV.app/Appliances; 
	ln -f -s /Applications/Lowtide.app/Appliances/Streams.frappliance $(FW_STAGING_DIR)/Applications/AppleTV.app/Appliances/
after-install::
	ssh root@$(FW_DEVICE_IP) "rm ~/com.decaro.streams_*.deb; killall -9 AppleTV"