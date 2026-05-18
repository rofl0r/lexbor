TOPSRC ?= $(CURDIR)

PREFIX ?= /usr/local
DESTDIR ?=
LIBDIR ?= $(PREFIX)/lib
INCLUDEDIR ?= $(PREFIX)/include

CC ?= cc
AR ?= ar
RANLIB ?= ranlib
CFLAGS ?= -O2
CPPFLAGS ?=
LDFLAGS ?=

ifeq ($(OS),Windows_NT)
OS_PORT ?= windows_nt
else
OS_PORT ?= posix
endif

BUILD_DIR ?= $(CURDIR)/build/make
OBJDIR := $(BUILD_DIR)/obj
BUILD_LIBDIR := $(BUILD_DIR)/lib

SOURCE_ROOT := $(TOPSRC)/source
LEXBOR_ROOT := $(SOURCE_ROOT)/lexbor
PORT_ROOT := $(LEXBOR_ROOT)/ports/$(OS_PORT)/lexbor

CPPFLAGS += -I$(SOURCE_ROOT)

MODULES := core css dom encoding engine html ns punycode selectors style tag unicode url utils

MOD_DEPS_core :=
MOD_DEPS_css := core
MOD_DEPS_dom := core tag ns
MOD_DEPS_encoding := core
MOD_DEPS_engine := html css selectors encoding style url unicode
MOD_DEPS_html := core dom ns tag
MOD_DEPS_ns := core
MOD_DEPS_punycode := core encoding
MOD_DEPS_selectors := core dom css tag ns
MOD_DEPS_style := dom html css selectors
MOD_DEPS_tag := core
MOD_DEPS_unicode := core encoding punycode
MOD_DEPS_url := core encoding unicode punycode
MOD_DEPS_utils := core

module_lib = $(BUILD_LIBDIR)/liblexbor-$(1).a
to_obj = $(OBJDIR)/$(patsubst $(TOPSRC)/%,%,$(1:.c=.o))

define collect_sources
$(sort $(shell find "$(LEXBOR_ROOT)/$(1)" -type f -name '*.c' -print) \
       $(shell if [ -d "$(PORT_ROOT)/$(1)" ]; then find "$(PORT_ROOT)/$(1)" -type f -name '*.c' -print; fi))
endef

$(foreach m,$(MODULES),$(eval MODULE_$(m)_SRCS := $(call collect_sources,$(m))))
$(foreach m,$(MODULES),$(eval MODULE_$(m)_OBJS := $(foreach s,$(MODULE_$(m)_SRCS),$(call to_obj,$(s)))))
$(foreach m,$(MODULES),$(eval MODULE_$(m)_LIB := $(call module_lib,$(m))))

ALL_LIBS := $(foreach m,$(MODULES),$(MODULE_$(m)_LIB))
ALL_OBJS := $(foreach m,$(MODULES),$(MODULE_$(m)_OBJS))
ALL_DEPS := $(ALL_OBJS:.o=.d)

.PHONY: all clean install install-headers install-libs test tests examples benchmarks project-utils
.PHONY: $(MODULES)

all: $(ALL_LIBS)

$(MODULES):
	@$(MAKE) --no-print-directory $(MODULE_$@_LIB)

define module_rule
$$(MODULE_$(1)_LIB): $$(MODULE_$(1)_OBJS) $$(foreach d,$$(MOD_DEPS_$(1)),$$(MODULE_$$(d)_LIB))
	@mkdir -p "$$(dir $$@)"
	$$(AR) rcs "$$@" $$(MODULE_$(1)_OBJS)
	$$(RANLIB) "$$@"
endef

$(foreach m,$(MODULES),$(eval $(call module_rule,$(m))))

$(OBJDIR)/%.o: $(TOPSRC)/%.c
	@mkdir -p "$(dir $@)"
	$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -c "$<" -o "$@"

install: all install-headers install-libs

install-libs: $(ALL_LIBS)
	@mkdir -p "$(DESTDIR)$(LIBDIR)"
	install -m 644 $(ALL_LIBS) "$(DESTDIR)$(LIBDIR)/"

install-headers:
	@cd "$(SOURCE_ROOT)" && \
	find lexbor -type f -name '*.h' -print | \
	while read -r hdr; do \
		dst_dir="$(DESTDIR)$(INCLUDEDIR)/$$(dirname "$$hdr")"; \
		mkdir -p "$$dst_dir"; \
		install -m 644 "$$hdr" "$$dst_dir/"; \
	done

clean:
	rm -rf "$(OBJDIR)" "$(BUILD_LIBDIR)"

tests test:
	cmake -S "$(TOPSRC)" -B "$(BUILD_DIR)/cmake-tests" \
		-DLEXBOR_BUILD_TESTS=ON \
		-DLEXBOR_BUILD_EXAMPLES=OFF \
		-DLEXBOR_BUILD_BENCHMARKS=OFF \
		-DLEXBOR_BUILD_UTILS=OFF \
		-DCMAKE_C_FLAGS="$(CFLAGS)" \
		-DCMAKE_EXE_LINKER_FLAGS="$(LDFLAGS)"
	cmake --build "$(BUILD_DIR)/cmake-tests"

examples:
	cmake -S "$(TOPSRC)" -B "$(BUILD_DIR)/cmake-examples" \
		-DLEXBOR_BUILD_TESTS=OFF \
		-DLEXBOR_BUILD_EXAMPLES=ON \
		-DLEXBOR_BUILD_BENCHMARKS=OFF \
		-DLEXBOR_BUILD_UTILS=OFF \
		-DCMAKE_C_FLAGS="$(CFLAGS)" \
		-DCMAKE_EXE_LINKER_FLAGS="$(LDFLAGS)"
	cmake --build "$(BUILD_DIR)/cmake-examples"

benchmarks:
	cmake -S "$(TOPSRC)" -B "$(BUILD_DIR)/cmake-benchmarks" \
		-DLEXBOR_BUILD_TESTS=OFF \
		-DLEXBOR_BUILD_EXAMPLES=OFF \
		-DLEXBOR_BUILD_BENCHMARKS=ON \
		-DLEXBOR_BUILD_UTILS=OFF \
		-DCMAKE_C_FLAGS="$(CFLAGS)" \
		-DCMAKE_EXE_LINKER_FLAGS="$(LDFLAGS)"
	cmake --build "$(BUILD_DIR)/cmake-benchmarks"

project-utils:
	cmake -S "$(TOPSRC)" -B "$(BUILD_DIR)/cmake-utils" \
		-DLEXBOR_BUILD_TESTS=OFF \
		-DLEXBOR_BUILD_EXAMPLES=OFF \
		-DLEXBOR_BUILD_BENCHMARKS=OFF \
		-DLEXBOR_BUILD_UTILS=ON \
		-DCMAKE_C_FLAGS="$(CFLAGS)" \
		-DCMAKE_EXE_LINKER_FLAGS="$(LDFLAGS)"
	cmake --build "$(BUILD_DIR)/cmake-utils"

-include $(ALL_DEPS)
