ARCHS ?= armv7  # Default 32-bit สำหรับ iOS 8-10 (iPhone 4S-5c)
MIN_IOS_VERSION ?= 8.0

default: build sign

build:
	@if [ -z "$$SDKROOT" ]; then \
		echo "Error: Set SDKROOT env (e.g., xcrun --sdk iphoneos12.1 --show-sdk-path)"; \
		exit 1; \
	fi
	@for arch in $(ARCHS); do \
		echo "Building for $$arch (iOS $(MIN_IOS_VERSION))..."; \
		clang -c -arch $$arch \
		  -isysroot $$SDKROOT \
		  -mios-version-min=$(MIN_IOS_VERSION) \
		  -Os -fobjc-arc -fmodules \
		  pseudo.m -o pseudo_$$arch.o; \
		ld -arch $$arch \
		  -isysroot $$SDKROOT \
		  -ios_version_min $(MIN_IOS_VERSION) \
		  -o pseudo_unsigned_$$arch \
		  pseudo_$$arch.o -lobjc -framework Foundation; \
	done
	@if [ "$$(echo $(ARCHS) | wc -w)" -gt 1 ]; then \
		lipo -create pseudo_unsigned_* -output pseudo_unsigned; \
	else \
		cp pseudo_unsigned_$(firstword $(ARCHS)) pseudo_unsigned; \
	fi

sign:
	ldid -Spseudo.entitlements pseudo_unsigned
	~/ct_bypass -i ./pseudo_unsigned -o ./pseudo || echo "Sign skipped if ct_bypass fails on 32-bit"

clean:
	rm -f pseudo_*.o pseudo_unsigned_* pseudo pseudo_unsigned
