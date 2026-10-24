# STM32 FreeRTOS Template (F401RE & G491RE)

A lightweight, modern STM32 + FreeRTOS boilerplate powered by **CMake FetchContent** and **`just`**. Dependencies (CMSIS, HAL drivers, FreeRTOS-Kernel) are downloaded automatically during CMake configuration—no Git submodules required.

---

## Prerequisites

Install the required tools (macOS via Homebrew):

```bash
# Build system & command runner
brew install cmake ninja just

# Flasher / Debugger (probe-rs recommended)
brew install probe-rs/probe-rs/probe-rs
# or via cargo: cargo install probe-rs-tools

# Memory footprint utility (optional)
brew install arm-none-eabi-gcc
```

> **Compiler Note**: This project uses the **ST-Arm-Clang** toolchain installed automatically by the **STM32Cube for VS Code extension** (located in `~/Library/Application Support/stm32cube/bundles`).

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
