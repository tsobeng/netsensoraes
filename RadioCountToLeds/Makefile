COMPONENT=RadioCountToLedsAppC
BUILD_EXTRA_DEPS = SecureKeyMsg.py

SecureKeyMsg.py: RadioCountToLeds.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=SecureKeyMsg RadioCountToLeds.h securekeymsg_msg -o $@

include $(MAKERULES)

