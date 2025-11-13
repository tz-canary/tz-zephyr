# SPDX-License-Identifier: Apache-2.0

if(CONFIG_BUILD_WITH_TFM)
  # West runners should flash the merged BL2 + TF-M + Zephyr image.
  set_property(TARGET runners_yaml_props_target PROPERTY hex_file tfm_merged.hex)

  if(DEFINED ZEPHYR_HAL_RPI_PICO_MODULE_DIR)
    if("$ENV{PICO_SDK_PATH}" STREQUAL "")
      set(ENV{PICO_SDK_PATH} ${ZEPHYR_HAL_RPI_PICO_MODULE_DIR})
    endif()

    if(NOT DEFINED PICO_SDK_PATH)
      set(PICO_SDK_PATH ${ZEPHYR_HAL_RPI_PICO_MODULE_DIR})
    endif()

  endif()

  set(RPI_PICO2_XIP_BASE 0x10000000)

  if(CONFIG_HAS_FLASH_LOAD_OFFSET)
    MATH(EXPR TFM_HEX_BASE_ADDRESS_NS "${RPI_PICO2_XIP_BASE}+${CONFIG_FLASH_LOAD_OFFSET}")
  else()
    set(TFM_HEX_BASE_ADDRESS_NS ${RPI_PICO2_XIP_BASE})
  endif()

  # Secure image base (BL2 header lives at 0x10011000 for TF-M rp2350 layout).
  set(TFM_HEX_BASE_ADDRESS_S 0x10011000)
endif()

if("${RPI_PICO_DEBUG_ADAPTER}" STREQUAL "")
  set(RPI_PICO_DEBUG_ADAPTER "cmsis-dap")
endif()

board_runner_args(openocd --cmd-pre-init "source [find interface/${RPI_PICO_DEBUG_ADAPTER}.cfg]")
if(CONFIG_ARM)
  board_runner_args(openocd --cmd-pre-init "source [find target/rp2350.cfg]")
else()
  board_runner_args(openocd --cmd-pre-init "source [find target/rp2350-riscv.cfg]")
endif()

# The adapter speed is expected to be set by interface configuration.
# The Raspberry Pi's OpenOCD fork doesn't, so match their documentation at
# https://www.raspberrypi.com/documentation/microcontrollers/debug-probe.html#debugging-with-swd
board_runner_args(openocd --cmd-pre-init "set_adapter_speed_if_not_set 5000")

board_runner_args(probe-rs "--chip=RP235x")

board_runner_args(jlink "--device=RP2350_M33_0")
board_runner_args(uf2 "--board-id=RP2350")

include(${ZEPHYR_BASE}/boards/common/openocd.board.cmake)
include(${ZEPHYR_BASE}/boards/common/probe-rs.board.cmake)
include(${ZEPHYR_BASE}/boards/common/jlink.board.cmake)
include(${ZEPHYR_BASE}/boards/common/uf2.board.cmake)
