COMPONENT=SecureComunicationAppC
BUILD_EXTRA_DEPS = SecureKeyMsg.py

SecureKeyMsg.py: SecureComunication.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=SecureKeyMsg SecureComunication.h securekeymsg_msg -o $@
	
include $(MAKERULES)