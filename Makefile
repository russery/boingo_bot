#####
# Makefile to build and load the boingo_bot
# author: R. Ussery
#####

PROJECT = boingo_bot

##### SOURCES AND INCLUDES
SPL_PATH = ../stm32_spl/STM32F30x_DSP_StdPeriph_Lib_V1.2.3
SPL_TEMPLATE_PATH = $(SPL_PATH)/Projects/STM32F30x_StdPeriph_Templates

SOURCE_FILES += \
$(wildcard src/*.c*) \
$(wildcard $(SPL_PATH)/Libraries/STM32F30x_StdPeriph_Driver/src/*.c*)

INCLUDES = \
src \
$(SPL_PATH)/Utilities/STM32_EVAL/STM32303C_EVAL \
$(SPL_PATH)/Utilities/STM32_EVAL/Common \
$(SPL_PATH)/Libraries/STM32F30x_StdPeriph_Driver/inc \
$(SPL_PATH)/Libraries/CMSIS/Include \
$(SPL_PATH)/Libraries/CMSIS/Device/ST/STM32F30x/Include \

STARTUP = $(SPL_PATH)/Libraries/CMSIS/Device/ST/STM32F30x/Source/Templates/gcc_ride7/startup_stm32f30x.s

OBJECT_DIRECTORY = _build/objs
LISTING_DIRECTORY = _build
OUTPUT_BINARY_DIRECTORY = _build

# Sorting removes duplicates
BUILD_DIRECTORIES = $(sort $(OBJECT_DIRECTORY) $(OUTPUT_BINARY_DIRECTORY) $(LISTING_DIRECTORY) )

##### BUILD FLAGS
CFLAGS  = -Wall -g -Os
CFLAGS += -mlittle-endian -mcpu=cortex-m4 -march=armv7e-m -mthumb
CFLAGS += -mfpu=fpv4-sp-d16 -mfloat-abi=hard
CFLAGS += -ffunction-sections -fdata-sections -fno-strict-aliasing
CFLAGS += -fno-builtin --short-enums
CFLAGS += $(addprefix -I, $(INCLUDES))
CFLAGS += -DSTM32F303xC -DUSE_STDPERIPH_DRIVER

LDFLAGS += -Wl,-Map=$(LISTING_DIRECTORY)/$(PROJECT).map
LDFLAGS += -Wl,--gc-sections
LDFLAGS += --specs=nano.specs -lc -lnosys

LINKER_SCRIPT = $(SPL_TEMPLATE_PATH)/TrueSTUDIO/STM32F303xC/STM32F303VC_FLASH.ld

# import all the non-project-specific stuff
include Makefile.generic

##### TARGETS
install:\
	build
	openocd -f board/stm32f0discovery.cfg -c "init; reset halt; \
	flash write_image erase $(PROJECT).bin 0x08000000; \
	reset run; shutdown"

erase:\
	clean
	openocd -f board/stm32f0discovery.cfg -c "init; reset halt; \
	flash erase_sector 0 0 last; \
	reset run; shutdown"
	

run-debug:
	$(JLINKD_GDB) $(JLINK_OPTS) $(JLINK_GDB_OPTS) -port $(GDB_PORT_NUMBER)

.PHONY: install erase run-debug