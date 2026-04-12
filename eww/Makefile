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


# For volume-related, link these libs
$(BUILD)/get_volume: LDFLAGS += -lasound -lm
$(BUILD)/set_volume: LDFLAGS += -lasound -lm

# For network-related binaries, link libnm
$(BUILD)/get_netinfo: LDFLAGS += $(shell pkg-config --libs libnm)
$(OBJDIR)/get_netinfo.o: FLAGS += $(shell pkg-config --cflags libnm)
$(BUILD)/get_netlist: LDFLAGS += $(shell pkg-config --libs libnm)
$(OBJDIR)/get_netlist.o: FLAGS += $(shell pkg-config --cflags libnm)


all: $(TARGETS)

$(BUILD)/%: $(OBJDIR)/%.o
	$(CC) $(FLAGS) -o $@ $< $(LDFLAGS)


$(OBJDIR)/%.o: $(SRC)/%.c
	@mkdir -p $(OBJDIR) $(DEPDIR)
	$(CC) $(FLAGS) -I$(INCLUDES) -MMD -MP -c $< -o $@ -MF $(DEPDIR)/$*.d

-include $(wildcard $(DEPDIR)/*.d)


clean:
	rm -rf $(BUILD) .cache
