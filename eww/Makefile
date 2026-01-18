CC = gcc
FLAGS = -Wall -Wextra -std=c17 -O3 -march=native -s
INCLUDES = ./include
SRC = ./src
BUILD = ./bin
OBJDIR = $(BUILD)/obj
DEPDIR = $(BUILD)/dep

SOURCES = $(wildcard $(SRC)/*.c)

TARGETS = $(patsubst $(SRC)/%.c,$(BUILD)/%,$(SOURCES))

ifeq ($(OS),Windows_NT)
    MKDIR_CMD = @if not exist $(OBJDIR) mkdir $(OBJDIR) && if not exist $(DEPDIR) mkdir $(DEPDIR)
    LDFLAGS = -lws2_32
else
    MKDIR_CMD = @mkdir -p $(OBJDIR) $(DEPDIR)
    LDFLAGS =
endif

all: $(TARGETS)

$(BUILD)/%: $(OBJDIR)/%.o
	$(CC) $(FLAGS) -o $@ $< $(LDFLAGS)

$(OBJDIR)/%.o: $(SRC)/%.c
	$(MKDIR_CMD)
	$(CC) $(FLAGS) -I$(INCLUDES) -MMD -MP -c $< -o $@ -MF $(DEPDIR)/$*.d

-include $(wildcard $(DEPDIR)/*.d)

clean:
	rm -rf $(BUILD)
