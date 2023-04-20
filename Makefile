NAME = bakepale

SRC = $(shell pwd)
DEP = /usr/local/lib
# CC ?= gcc
CFLAGS += -I$(SRC)/include -I$(SRC)
CFLAGS += -Wall -Wextra -DPALERAIN_VERSION=\"2.0.0\" -Wall -Wextra -Wno-unused-parameter
CFLAGS += -Wno-unused-variable -I$(SRC)/src -std=c99 -pedantic-errors -D_C99_SOURCE -D_POSIX_C_SOURCE=200112L
LIBS += -L$(DEP) -limobiledevice-1.0 -lirecovery-1.0 -lusbmuxd-2.0
LIBS += -limobiledevice-glue-1.0 -lplist-2.0 -lssl -lcrypto -lm -lrt -ldl -lpthread
ifeq ($(TARGET_OS),)
TARGET_OS = $(shell uname -s)
endif
ifeq ($(TARGET_OS),Darwin)
CFLAGS += -Wno-nullability-extension
ifeq (,$(findstring version-min=, $(CFLAGS)))
CFLAGS += -mmacosx-version-min=10.8
endif
LDFLAGS += -Wl,-dead_strip
LIBS += -framework CoreFoundation -framework IOKit
else
CFLAGS += -fdata-sections -ffunction-sections
LDFLAGS += -no-pie -Wl,--gc-sections
endif

LIBS += -lmbedtls -lmbedcrypto -lmbedx509 -lreadline

ifeq ($(TUI),1)
LIBS += -lnewt -lpopt -lslang
ifeq ($(TARGET_OS),Linux)
LIBS += -lgpm
endif
endif
ifeq ($(DEV_BUILD),1)
CFLAGS += -O0 -g -DDEV_BUILD -fno-omit-frame-pointer
ifeq ($(ASAN),1)
BUILD_STYLE=ASAN
CFLAGS += -fsanitize=address,undefined -fsanitize-address-use-after-return=runtime
else ifeq ($(TSAN),1)
BUILD_STYLE=TSAN
CFLAGS += -fsanitize=thread,undefined
else
BUILD_STYLE = DEVELOPMENT
endif
else
CFLAGS += -Os -g
BUILD_STYLE = RELEASE
endif
LIBS += -lc

ifneq ($(BAKERAIN_DEVELOPE_R),)
CFLAGS += -DBAKERAIN_DEVELOPE_R="\"$(BAKERAIN_DEVELOPE_R)\""
endif

BUILD_DATE := $(shell LANG=C date)
BUILD_NUMBER := $(shell git rev-list --count HEAD)
BUILD_TAG := $(shell git describe --dirty --tags --abbrev=7)
BUILD_WHOAMI := $(shell whoami)
BUILD_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
BUILD_COMMIT := $(shell git rev-parse HEAD)

CFLAGS += -DBUILD_STYLE="\"$(BUILD_STYLE)\"" -DBUILD_DATE="\"$(BUILD_DATE)\""
CFLAGS += -DBUILD_WHOAMI="\"$(BUILD_WHOAMI)\"" -DBUILD_TAG="\"$(BUILD_TAG)\""
CFLAGS += -DBUILD_NUMBER="\"$(BUILD_NUMBER)\"" -DBUILD_BRANCH="\"$(BUILD_BRANCH)\""
CFLAGS += -DBUILD_COMMIT="\"$(BUILD_COMMIT)\""

export SRC DEP CFLAGS LDFLAGS LIBS TARGET_OS DEV_BUILD BUILD_DATE BUILD_TAG BUILD_WHOAMI BUILD_STYLE BUILD_NUMBER BUILD_BRANCH

all: palera1n

palera1n: download-deps
	$(MAKE) -C src

clean:
	$(MAKE) -C src clean
	$(MAKE) -C docs clean

download-deps:
	$(MAKE) -C src checkra1n-macos checkra1n-linux-arm64 checkra1n-linux-armel checkra1n-linux-x86 checkra1n-linux-x86_64 checkra1n_kpf_pongo ramdisk.dmg binpack.dmg Pongo.bin

docs:
	$(MAKE) -C docs

distclean: clean
	rm -rf palera1n-* palera1n*.dSYM src/checkra1n-* src/checkra1n_kpf_pongo src/ramdisk.dmg src/binpack.dmg src/Pongo.bin

.PHONY: all palera1n clean docs distclean

