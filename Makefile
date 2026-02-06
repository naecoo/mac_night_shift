CC = clang
CFLAGS = -Wall -Wextra -O2 -framework Foundation
TARGET = nightshift
SRC = nightshift.c

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f $(TARGET)

install: $(TARGET)
	install -m 755 $(TARGET) /usr/local/bin/