ARCHS ?= armv7 arm64
MIN_IOS ?= 11.0        # บังคับ 11.0 เพื่อหลบ libarclite error ถ้าอยาก 8.0 จริง ๆ ต้องปิด ARC

default: build sign

build:
	@for arch in $(ARCHS); do \
		echo "Building $$arch ..."; \
		clang -arch $$arch \
		  -isysroot $$(xcrun --sdk iphoneos --show-sdk-path) \
		  -miphoneos-version-min=$(MIN_IOS) \
		  -Os \
		  -fno-objc-arc \        # ปิด ARC = ไม่ต้อง libarclite
		  -framework Foundation \
		  -o pseudo_unsigned_$$arch \
		  pseudo.m; \
	done
	@lipo -create pseudo_unsigned_* -output pseudo_unsigned 2>/dev/null || mv pseudo_unsigned_arm64 pseudo_unsigned

sign:
	ldid -Spseudo.entitlements pseudo_unsigned 2>/dev/null || true
	~/ct_bypass -i pseudo_unsigned -o pseudo 2>/dev/null || echo "32-bit signed with ldid only"

clean:
	rm -f pseudo_unsigned pseudo_unsigned_* pseudo
