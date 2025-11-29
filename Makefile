ARCHS ?= armv7 arm64
MIN_IOS ?= 8.0

default: build sign

build:
	@for arch in $(ARCHS); do \
		echo "Building $$arch for iOS $(MIN_IOS)..."; \
		clang -arch $$arch \
		  -isysroot $$(xcrun --sdk iphoneos --show-sdk-path) \
		  -mios-version-min=$(MIN_IOS) \
		  -Os -fobjc-arc \
		  -framework Foundation \
		  -o pseudo_unsigned_$$arch \
		  pseudo.m; \
	done
	@lipo -create pseudo_unsigned_* -output pseudo_unsigned 2>/dev/null || mv pseudo_unsigned_$(firstword $(ARCHS)) pseudo_unsigned

sign:
	ldid -Spseudo.entitlements pseudo_unsigned
	~/ct_bypass -i pseudo_unsigned -o pseudo 2>/dev/null || echo "ct_bypass skipped (32-bit ok with ldid only)"

clean:
	rm -f pseudo_unsigned pseudo_unsigned_* pseudo
