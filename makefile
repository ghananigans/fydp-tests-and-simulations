CC = gcc
CCHEADER_SEARCH = -I./lib
CFLAGS = -g -Wall
OBJECT_DIR = obj
SOURCE_DIR = src
LIB_DIR = lib

.PHONY: default all clean

default: main
all: default

HEADERS = $(wildcard $(SOURCE_DIR)/*.h)

GENERATE_OBJECTS = $(OBJECT_DIR)/main.o $(OBJECT_DIR)/fft.o

$(OBJECT_DIR)/%.o: $(SOURCE_DIR)/%.c $(HEADERS)
	$(CC) $(CFLAGS) $(CCHEADER_SEARCH) -c $< -o $@

$(OBJECT_DIR)/fft.o: $(LIB_DIR)/fft/fft.c $(HEADERS)
	$(CC) $(CFLAGS) $(CCHEADER_SEARCH) -c $< -o $@

.PRECIOUS: $(TARGET) $(OBJECTS)

main: $(GENERATE_OBJECTS)
	$(CC) $(CFLAGS) $(CCHEADER_SEARCH) $(GENERATE_OBJECTS) -o $@

clean:
	-rm -f $(OBJECT_DIR)/*.o
	-rm -f main
