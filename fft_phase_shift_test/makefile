CC = gcc
CCHEADER_SEARCH = -I./lib
CFLAGS = -g -Wall
OBJECT_DIR = obj
SOURCE_DIR = src
LIB_DIR = lib

.PHONY: default all clean

default: fft_phase_shift_test
all: default

HEADERS = $(wildcard $(SOURCE_DIR)/*.h)

TEST_PHASE_SHIFT_OBJECTS = $(OBJECT_DIR)/test_phase_shift.o $(OBJECT_DIR)/fft.o $(OBJECT_DIR)/phase_shift.o

$(OBJECT_DIR)/%.o: $(SOURCE_DIR)/%.c $(HEADERS)
	$(CC) $(CFLAGS) $(CCHEADER_SEARCH) -c $< -o $@

$(OBJECT_DIR)/fft.o: $(LIB_DIR)/fft/fft.c $(HEADERS)
	$(CC) $(CFLAGS) $(CCHEADER_SEARCH) -c $< -o $@

.PRECIOUS: $(TARGET) $(OBJECTS)

fft_phase_shift_test: $(TEST_PHASE_SHIFT_OBJECTS)
	$(CC) $(CFLAGS) $(CCHEADER_SEARCH) $(TEST_PHASE_SHIFT_OBJECTS) -o $@

clean:
	-rm -f $(OBJECT_DIR)/*.o
	-rm -f fft_phase_shift_test
