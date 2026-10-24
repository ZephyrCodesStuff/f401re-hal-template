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

## Project Structure

> [!TIP]
> Configure your board's peripherals and settings in the `Inc/*.h` files.

```text
├── CMakeLists.txt              # Root build configuration
├── CMakePresets.json           # Target presets (F401RE / G491RE, Debug / Release)
├── justfile                    # Build, flash, and utility shortcuts
├── cmake/
│   ├── hal.cmake               # FetchContent rules for CMSIS Core, Device & HAL
│   ├── freertos.cmake          # FetchContent rules for FreeRTOS-Kernel (ARM_CM4F)
│   └── starm-clang.cmake       # ST-Arm-Clang toolchain configuration
├── Inc/
│   ├── stm32_hal.h             # Portable HAL wrapper header (auto-includes F4 or G4 HAL)
│   ├── stm32f4xx_hal_conf.h    # HAL module configuration for F4
│   ├── stm32g4xx_hal_conf.h    # HAL module configuration for G4
│   └── FreeRTOSConfig.h        # FreeRTOS kernel configuration
└── Src/
    └── main.c                  # FreeRTOS LED blink task & SysTick hook
```