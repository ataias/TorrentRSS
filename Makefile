SOURCES = $(wildcard Sources/**/*.swift)
BUILD = $(shell swift build --show-bin-path -c release)
DBUILD = $(shell swift build --show-bin-path -c debug)
TARGET=trss
RELEASE_BIN = $(BUILD)/$(TARGET)
DEBUG_BIN = $(DBUILD)/$(TARGET)
PREFIX=~/.local/bin/

.PHONY: all
all: $(RELEASE_BIN)

.PHONY: debug
debug: $(DEBUG_BIN)

$(RELEASE_BIN): $(SOURCES)
	@echo $(RELEASE_BIN)
	swift build -c release

$(DEBUG_BIN): $(SOURCES)
	@echo $(DEBUG_BIN)
	swift build

.PHONY: uninstall
uninstall: $(PREFIX)/$(TARGET)
	rm $(PREFIX)/$(TARGET)

.PHONY: install
install: $(RELEASE_BIN)
	cp $(RELEASE_BIN) $(PREFIX)

.PHONY: install_debug
install_debug: $(DEBUG_BIN)
	cp $(DEBUG_BIN) $(PREFIX)

# .PHONY: debug
# debug: $(BIN)
# 	lldb -s debug.lldb $(BIN)
