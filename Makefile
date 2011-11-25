GO_EASY_ON_ME=1
SDKVERSION=5.0
FW_DEVICE_IP=apple-tv.local
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Streams
Streams_FILES = Classes/streams.mm Classes/CPlusFunctions.mm Classes/EngadgetMenu.m Classes/RevisionMenu.m

Streams_FILES += Classes/JSON/CDataScanner.m
Streams_FILES += Classes/JSON/CDataScanner_Extensions.m
Streams_FILES += Classes/JSON/CJSONDeserializer.m
Streams_FILES += Classes/JSON/CJSONScanner.m
Streams_FILES += Classes/JSON/CJSONSerializer.m
Streams_FILES += Classes/JSON/NSDictionary_JSONExtensions.m

Streams_INSTALL_PATH = /Applications/AppleTV.app/Appliances
Streams_BUNDLE_EXTENSION = frappliance
Streams_LDFLAGS = -undefined dynamic_lookup
Streams_OBJ_FILES = ../SMFramework/obj/SMFramework

include $(FW_MAKEDIR)/bundle.mk

after-install::
	ssh root@$(FW_DEVICE_IP) "rm ~/com.decaro.streams_*.deb; killall -9 AppleTV"