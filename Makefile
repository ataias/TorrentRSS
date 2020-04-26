SOURCES = $(wildcard Sources/**/*.swift)
BUILD = $(shell swift build --show-bin-path -c release)
TARGET=trss
RELEASE_BIN = $(BUILD)/$(TARGET)
PREFIX=~/.local/bin/

.PHONY: all
all: $(RELEASE_BIN)

$(RELEASE_BIN): $(SOURCES)
	@echo $(RELEASE_BIN)
	swift build -c release

.PHONY: uninstall
uninstall: $(PREFIX)/$(TARGET)
	rm $(PREFIX)/$(TARGET)

.PHONY: install
install: $(RELEASE_BIN)
	cp $(RELEASE_BIN) $(PREFIX)

# .PHONY: debug
# debug: $(BIN)
# 	lldb -s debug.lldb $(BIN)
