# Compiler and flags
CXX = g++

# Source files
SRCS = src/main.cpp src/lib.cpp
TARGET = place.exe

# Default target
all: $(TARGET)

$(TARGET): $(SRCS)
	$(CXX) -o $(TARGET) $(SRCS)

# Run the program with input and output files
run: $(TARGET)
	./$(TARGET) input.txt output.txt

# Runs the program statistics
stats: $(TARGET)
	./$(TARGET) -s stats.txt input.txt

# Clean up build files
clean:
	rm -f $(TARGET) *.o