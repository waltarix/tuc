ifeq ($(RUST_TARGET),)
	TARGET :=
	RELEASE_SUFFIX :=
else
	TARGET := $(RUST_TARGET)
	RELEASE_SUFFIX := -$(TARGET)
	export CARGO_BUILD_TARGET = $(RUST_TARGET)
endif

PROJECT_NAME := tuc

VERSION := $(subst $\",,$(word 3,$(shell grep -m1 "^version" Cargo.toml)))
RELEASE := $(PROJECT_NAME)-$(VERSION)$(RELEASE_SUFFIX)

DIST_DIR := dist
RELEASE_DIR := $(DIST_DIR)/$(RELEASE)
MANUAL_DIR := $(RELEASE_DIR)/man

BINARY := target/$(TARGET)/release/$(PROJECT_NAME)
MANUAL := doc/$(PROJECT_NAME).1
MANUAL_SRC := doc/$(PROJECT_NAME).1.md

RELEASE_BINARY := $(RELEASE_DIR)/$(PROJECT_NAME)
RELEASE_MANUAL := $(MANUAL_DIR)/$(notdir $(MANUAL))

ARTIFACT := $(RELEASE).tar.xz

.PHONY: all
all: $(ARTIFACT)

.PHONY: doc
doc: clean-doc $(MANUAL)

.PHONY: clean-doc
clean-doc:
	$(RM) $(MANUAL)

$(BINARY):
	cargo build --locked --release

$(MANUAL): $(MANUAL_SRC)
	pandoc -s -t man $< -o $@

$(DIST_DIR) $(RELEASE_DIR) $(MANUAL_DIR):
	mkdir -p $@

$(RELEASE_BINARY): $(BINARY) | $(RELEASE_DIR)
	cp -f $< $@
$(RELEASE_MANUAL): $(MANUAL) | $(MANUAL_DIR)
	cp -f $< $@

$(ARTIFACT): $(RELEASE_BINARY) $(RELEASE_MANUAL)
	tar -C $(DIST_DIR) -Jcvf $@ $(RELEASE)

.PHONY: clean
clean:
	$(RM) -r $(ARTIFACT) $(DIST_DIR)
