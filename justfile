set dotenv-load := true

current_os := os()

# Inject STM32Cube bundles (Ninja, Clang) to PATH if present
cube_bundles := if current_os == "macos" {
    env_var_or_default("HOME", "") + "/Library/Application Support/stm32cube/bundles"
} else {
    env_var_or_default("HOME", "") + "/.stm32cube/bundles"
}
local_share_bundles := env_var_or_default("HOME", "") + "/.local/share/stm32cube/bundles"
export PATH := env_var_or_default("PATH", "") + ":" + cube_bundles + "/ninja/1.13.2+st.1/bin:" + cube_bundles + "/st-arm-clang/21.1.1+st.7/bin:" + local_share_bundles + "/ninja/1.13.2+st.1/bin:" + local_share_bundles + "/st-arm-clang/21.1.1+st.7/bin:" + env_var_or_default("HOME", "") + "/.local/bin:" + env_var_or_default("HOME", "") + "/.stm32cube/bin"

# Default recipe: list all available commands
default:
    @just --list

# Default settings (can be overridden on command line: just target=g491 build)
target := "f401"
build_type := "Debug"
cmsis := "true"

# Resolve CMSIS-RTOS2 flag
_cmsis_flag := if cmsis == "true" { "-DENABLE_CMSIS_OS2=ON" } else { "-DENABLE_CMSIS_OS2=OFF" }

# Resolve CMake preset from target and build type
_preset := if target == "g491" {
    "G491RE-" + build_type
} else {
    "F401RE-" + build_type
}

# Resolve chip model for probe-rs / OpenOCD
_chip := if target == "g491" {
    "STM32G491RETx"
} else {
    "STM32F401RETx"
}

_elf := "build/" + _preset + "/sandbox.elf"

# Configure CMake preset
configure target=target build_type=build_type cmsis=cmsis:
    cmake --preset {{_preset}} {{_cmsis_flag}}

# Build firmware binary (sandbox.elf), auto-configuring if needed
build target=target build_type=build_type cmsis=cmsis:
    #!/usr/bin/env bash
    set -euo pipefail
    CACHE="build/{{_preset}}/CMakeCache.txt"
    WANT_CMSIS="{{if cmsis == "true" { "ENABLE_CMSIS_OS2:BOOL=ON" } else { "ENABLE_CMSIS_OS2:BOOL=OFF" }}}"
    if [ ! -f "build/{{_preset}}/build.ninja" ] || ! grep -q "$WANT_CMSIS" "$CACHE" 2>/dev/null; then
        echo "Target {{_preset}} (cmsis={{cmsis}}) not configured or settings changed. Configuring..."
        cmake --preset {{_preset}} {{_cmsis_flag}}
    fi
    cmake --build --preset {{_preset}}

# Flash firmware to the microcontroller (auto-builds & auto-configures if needed)
flash target=target build_type=build_type cmsis=cmsis: (build target build_type cmsis)
    @echo "Flashing {{_chip}} with {{_elf}}..."
    @if command -v probe-rs >/dev/null 2>&1; then \
        probe-rs download --chip {{_chip}} {{_elf}} && \
        probe-rs reset --chip {{_chip}}; \
    elif command -v openocd >/dev/null 2>&1; then \
        openocd -f interface/stlink.cfg -f target/{{if target == "g491" { "stm32g4x.cfg" } else { "stm32f4x.cfg" }}} \
            -c "program {{_elf}} verify reset exit"; \
    elif command -v STM32_Programmer_CLI >/dev/null 2>&1; then \
        STM32_Programmer_CLI -c port=SWD -w {{_elf}} -v -rst; \
    else \
        echo "Error: No supported flasher found (probe-rs, openocd, or STM32_Programmer_CLI)."; \
        exit 1; \
    fi

# Flash and stream logs / RTT output
run target=target build_type=build_type cmsis=cmsis: (build target build_type cmsis)
    probe-rs run --chip {{_chip}} {{_elf}}

# Reset connected MCU
reset target=target:
    @if command -v probe-rs >/dev/null 2>&1; then \
        probe-rs reset --chip {{_chip}}; \
    elif command -v openocd >/dev/null 2>&1; then \
        openocd -f interface/stlink.cfg -f target/{{if target == "g491" { "stm32g4x.cfg" } else { "stm32f4x.cfg" }}} \
            -c "init; reset; exit"; \
    fi

# Show memory footprint of binary
size target=target build_type=build_type:
    #!/usr/bin/env bash
    if [ ! -f "{{_elf}}" ]; then
        echo "Binary not found at {{_elf}}. Run 'just build' first."
        exit 1
    fi
    if command -v starm-size >/dev/null 2>&1; then
        starm-size "{{_elf}}"
    elif command -v arm-none-eabi-size >/dev/null 2>&1; then
        arm-none-eabi-size "{{_elf}}"
    elif command -v llvm-size >/dev/null 2>&1; then
        llvm-size "{{_elf}}"
    else
        size "{{_elf}}"
    fi

# Run clang-tidy static analysis on application source files
tidy target=target build_type=build_type:
    #!/usr/bin/env bash
    if command -v clang-tidy >/dev/null 2>&1; then
        FILES=$(find Src -name "*.c" ! -name "sys*.c")
        clang-tidy $FILES -p "build/{{_preset}}"
    else
        echo "clang-tidy command not found. (Install via 'brew install llvm' or 'apt install clang-tidy')"
    fi

# Clean build artifacts
clean target="":
    #!/usr/bin/env bash
    if [ -n "{{target}}" ]; then
        rm -rf build/{{_preset}}
        echo "Cleaned build/{{_preset}}"
    else
        rm -rf build/
        echo "Cleaned all build directories"
    fi

# Clean and rebuild from scratch
rebuild target=target build_type=build_type cmsis=cmsis: (clean target) (build target build_type cmsis)
