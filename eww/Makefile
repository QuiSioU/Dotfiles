CC = gcc
FLAGS = -Wall -Wextra -std=c17
INCLUDES = ./include
SRC = ./src
BUILD = ./.build
OBJDIR = $(BUILD)/obj
DEPDIR = $(BUILD)/dep
EXEC_NAME = eww-bar
SOURCES = $(wildcard $(SRC)/*.c)
OBJECTS = $(patsubst $(SRC)/%c,$(OBJDIR)/%.o,$(SOURCES))
DEPS = $(patsubst $(SRC)/%c,$(DEPDIR)/%.d,$(SOURCES))

ifeq ($(OS),Windows_NT)
    TARGET = $(BUILD)/$(EXEC_NAME).exe
    MKDIR_CMD = @if not exist build mkdir build && if not exist $(OBJDIR) mkdir $(OBJDIR) && if not exist $(DEPDIR) mkdir $(DEPDIR)
    LDFLAGS = -lws2_32
else
    TARGET = $(BUILD)/$(EXEC_NAME)
    MKDIR_CMD = @mkdir -p $(OBJDIR) $(DEPDIR)
    LDFLAGS =
endif

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(FLAGS) -o $@ $^ $(LDFLAGS)

$(OBJDIR)/%.o: $(SRC)/%c
	$(MKDIR_CMD)
	$(CC) $(FLAGS) -I$(INCLUDES) -MMD -MP -c $< -o $@ -MF $(DEPDIR)/$*.d

-include $(DEPS)

run: $(TARGET)
	$(TARGET)

clean:
	rm -rf $(BUILD) compile_commands.json

