COMPONENT=SecureComunicationAppC
BUILD_EXTRA_DEPS = SecureKeyMsg.py SecureKeyMsg.class

SecureKeyMsg.py: SecureComunication.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=SecureKeyMsg SecureComunication.h SecureComunicationAesKeyMsg -o $@

SecureKeyMsg.class: SecureKeyMsg.java
	javac SecureKeyMsg.java

SecureKeyMsg.java: SecureComunication.h
	mig java -target=$(PLATFORM) $(CFLAGS) -java-classname=SecureKeyMsg SecureComunication.h SecureComunicationAesKeyMsg -o $@


include $(MAKERULES)