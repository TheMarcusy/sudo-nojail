default: build sign

build:
	clang -o pseudo_unsigned -arch arm -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk -Os -fmodules -mios-version-min=10.0 -target arm-apple-ios pseudo.m

sign:
	ldid -Spseudo.entitlements pseudo_unsigned
	~/ChOma/output/tests/ct_bypass -i ./pseudo_unsigned -o ./pseudo

clean:
	rm -f pseudo_unsigned pseudo
