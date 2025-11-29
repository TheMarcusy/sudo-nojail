ARCHS ?= armv7
MIN_IOS_VERSION ?= 8.0
NO_ARC ?= 0  # Default เปิด ARC แต่ถ้า error ให้ set=1

default: build sign

build:
	@for arch in $(ARCHS); do \
		echo "Building $$arch for iOS $(MIN_IOS_VERSION) (ARC: $(if $(NO_ARC),disabled,enabled))..."; \
		clang -arch $$arch \
		  -isysroot $(shell xcrun --sdk iphoneos --show-sdk-path) \
		  -mios-version-min=$(MIN_IOS_VERSION) \
		  -Os \
		  $(if $(NO_ARC),-fno-objc-arc,-fobjc-arc) \
		  $(if $(NO_ARC),,-fmodules) \
		  -o pseudo_unsigned \
		  pseudo.m; \
	done

sign:
	ldid -Spseudo.entitlements pseudo_unsigned || echo "ldid failed, check entitlements"
	~/ct_bypass -i pseudo_unsigned -o pseudo 2>/dev/null || echo "ct_bypass skipped for 32-bit – use ldid only"

clean:
	rm -f pseudo_unsigned pseudo
