# STM32 FreeRTOS Template (F401RE & G491RE)

[![CI](https://github.com/zephyrcodesstuff/stm32-rtos-template/actions/workflows/ci.yml/badge.svg)](https://github.com/zephyrcodesstuff/stm32-rtos-template/actions/workflows/ci.yml)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](LICENSE)

A lightweight, modern STM32 + FreeRTOS boilerplate powered by **CMake FetchContent** and **`just`**.

> [!NOTE]
> Dependencies (CMSIS, HAL drivers, FreeRTOS-Kernel) are downloaded automatically during CMake configuration.

---

## Prerequisites

### On Ubuntu / Debian Linux:

```bash
# 1. Build tools & compiler utilities
sudo apt update
sudo apt install -y cmake ninja-build gcc-arm-none-eabi just

# 2. Flasher (probe-rs installer)
curl -L --proto '=https' --tlsv1.2 -sSf https://probe.rs/install.sh | sh

# 3. USB permissions (udev rules for ST-Link / probe-rs)
# Required on Linux so non-root users can access the ST-Link USB programmer
curl -fsSL https://probe.rs/files/69-probe-rs.rules | sudo tee /etc/udev/rules.d/69-probe-rs.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

### On macOS (Homebrew):

```bash
# Build system & command runner
brew install cmake ninja just

# Flasher / Debugger
brew install probe-rs/probe-rs/probe-rs

# Memory footprint utility (optional)
brew install arm-none-eabi-gcc
```

> [!NOTE]
> This project uses the **ST-Arm-Clang** toolchain. On both Linux (`~/.stm32cube/bundles`) and macOS (`~/Library/Application Support/stm32cube/bundles`), it is automatically provisioned when opening the workspace in VS Code with the **STM32Cube for VS Code extension**. The [`justfile`](justfile) automatically injects these toolchain paths on both operating systems.

---

## Quickstart

Build and flash using [`just`](https://github.com/casey/just):

```bash
# 1. Build firmware (defaults to STM32F401RE Debug)
just build

# 2. Flash to connected board & reset
just flash

# 3. Flash and stream live logs / RTT output
just run
```

---

## Target Switching

The project seamlessly supports both **STM32F401RE** and **STM32G491RE**:

### Via `just` CLI
```bash
# Build & flash STM32F401RE
just target=f401 build
just target=f401 flash

# Build & flash STM32G491RE
just target=g491 build
just target=g491 flash

# Release builds
just build_type=Release build
just target=g491 build_type=Release flash
```

### Via VS Code
Click the **CMake Preset** in the bottom status bar and select:
- `STM32F401RE Debug` / `Release`
- `STM32G491RE Debug` / `Release`

---

## Handy Commands

| Command | Action |
| :--- | :--- |
| `just` / `just --list` | List all available recipes |
| `just build` | Compile the project |
| `just flash` | Build, download to chip, and reset |
| `just run` | Flash and attach RTT / console monitor |
| `just reset` | Hard reset connected MCU |
| `just size` | Show Flash / RAM memory breakdown |
| `just clean` | Remove build artifacts |
| `just rebuild` | Clean build from scratch |

---

## Adding a New Board

The project uses a modular `boards/` architecture. To add any new STM32 board:

1. Create `boards/<BOARD_NAME>/` (e.g. `boards/STM32L476RG/`):
   - `board.cmake` (specifies MCU model, family, core, and tags)
   - `stm32<family>xx_hal_conf.h` (peripheral configuration)
   - `flash.ld` (board linker script)
2. Add a preset to `CMakePresets.json` (optional, for IDE / shorthand access).
3. Build immediately: `just target=<BOARD_NAME> build`.

---

## Project Structure

```text
├── CMakeLists.txt              # Root build configuration
├── CMakePresets.json           # Target presets (F401RE / G491RE, Debug / Release)
├── justfile                    # Clean task runner (~100 lines)
├── boards/                     # Modular board configurations
│   ├── STM32F401RE/
│   │   ├── board.cmake         # MCU model, family (f4), core, tags, debugger
│   │   ├── stm32f4xx_hal_conf.h
│   │   └── flash.ld
│   └── STM32G491RE/
│       ├── board.cmake         # MCU model, family (g4), core, tags, debugger
│       ├── stm32g4xx_hal_conf.h
│       └── flash.ld
├── cmake/
│   ├── hal.cmake               # Universal family-based FetchContent HAL driver
│   ├── freertos.cmake          # FreeRTOS-Kernel fetch rules
│   ├── freertos-cmsis.cmake    # CMSIS-RTOS2 wrapper fetch rules
│   └── starm-clang.cmake       # ST-Arm-Clang toolchain configuration
├── Inc/
│   ├── stm32_hal.h             # Universal HAL wrapper (#include STM32_HAL_HEADER)
│   ├── FreeRTOSConfig.h        # FreeRTOS kernel configuration
│   └── RTE_Components.h        # CMSIS stub header
└── Src/
    ├── main.c                  # FreeRTOS blink task & SysTick hook
    ├── syscall.c               # POSIX stubs
    └── sysmem.c                # Dynamic memory allocator stubs
```