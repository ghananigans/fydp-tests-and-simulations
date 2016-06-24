CC = gcc
CFLAGS = -g -Wall
OBJECT_DIR = obj
SOURCE_DIR = src

.PHONY: default all clean

default: main
all: default

HEADERS = $(wildcard $(SOURCE_DIR)/*.h)

GENERATE_OBJECTS = $(OBJECT_DIR)/main.o

$(OBJECT_DIR)/%.o: $(SOURCE_DIR)/%.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

.PRECIOUS: $(TARGET) $(OBJECTS)

main: $(GENERATE_OBJECTS)
	$(CC) $(CFLAGS) $(GENERATE_OBJECTS) -o $@

clean:
	-rm -f $(OBJECT_DIR)/*.o
	-rm -f main
