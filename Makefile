default: build sign

build:
	clang -o pseudo_unsigned \
  -arch armv7 \
  -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
  -mios-version-min=8.0 \
  -Os -fobjc-arc -fmodules \
  pseudo.m

sign:
	ldid -Spseudo.entitlements pseudo_unsigned
	~/ChOma/output/tests/ct_bypass -i ./pseudo_unsigned -o ./pseudo

clean:
	rm -f pseudo_unsigned pseudo
