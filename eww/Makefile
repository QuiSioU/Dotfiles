CC = gcc
FLAGS = -Wall -Wextra -std=c17 -O3 -march=native -s
INCLUDES = ./include
SRC = ./src
BUILD = ./bin
OBJDIR = $(BUILD)/obj
DEPDIR = $(BUILD)/dep
SOURCES = $(wildcard $(SRC)/*.c)
TARGETS = $(patsubst $(SRC)/%.c,$(BUILD)/%,$(SOURCES))
LDFLAGS =


# For get_volume.c, link these libs
$(BUILD)/get_volume: LDFLAGS += -lasound -lm

# For get_network.c, link libnm
# Using pkg-config is recommended to ensure paths are correct
$(BUILD)/get_network: LDFLAGS += $(shell pkg-config --libs libnm)
$(OBJDIR)/get_network.o: FLAGS += $(shell pkg-config --cflags libnm)


all: $(TARGETS)

$(BUILD)/%: $(OBJDIR)/%.o
	$(CC) $(FLAGS) -o $@ $< $(LDFLAGS)


$(OBJDIR)/%.o: $(SRC)/%.c
	@mkdir -p $(OBJDIR) $(DEPDIR)
	$(CC) $(FLAGS) -I$(INCLUDES) -MMD -MP -c $< -o $@ -MF $(DEPDIR)/$*.d

-include $(wildcard $(DEPDIR)/*.d)


clean:
	rm -rf $(BUILD)
