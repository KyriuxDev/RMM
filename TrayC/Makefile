# Makefile — Cross-compile DataScan.exe from Debian via mingw
CC       = x86_64-w64-mingw32-gcc
WINDRES  = x86_64-w64-mingw32-windres
CFLAGS   = -O2 -s -mwindows -Isrc -Ideps -Wno-unused-function -Wno-deprecated-declarations
LDFLAGS  = -luser32 -lshell32 -ladvapi32 -lole32 -loleaut32 -lwbemuuid -liphlpapi -lws2_32 -lpdh -Wl,--subsystem,windows

SRCDIR   = src
BUILDDIR = build
TARGET   = DataScan.exe

SRCS     = $(SRCDIR)/main.c $(SRCDIR)/crypto.c $(SRCDIR)/hwinfo.c \
           $(SRCDIR)/qr_gen.c $(SRCDIR)/tray.c
DEPS_SRC = deps/qrcodegen.c deps/lodepng.c
OBJS     = $(patsubst $(SRCDIR)/%.c,$(BUILDDIR)/%.o,$(SRCS)) \
           $(BUILDDIR)/qrcodegen.o $(BUILDDIR)/lodepng.o \
           $(BUILDDIR)/datascan_res.o

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) -o $@ $^ $(LDFLAGS)

$(BUILDDIR)/%.o: $(SRCDIR)/%.c | $(BUILDDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILDDIR)/qrcodegen.o: deps/qrcodegen.c | $(BUILDDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILDDIR)/lodepng.o: deps/lodepng.c | $(BUILDDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILDDIR)/datascan_res.o: datascan.rc icono.ico | $(BUILDDIR)
	$(WINDRES) $< -o $@

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

clean:
	rm -rf $(BUILDDIR) $(TARGET)
