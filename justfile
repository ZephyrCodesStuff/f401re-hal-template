set dotenv-load := true

# Inject STM32Cube bundles (Ninja, Clang) to PATH if present
cube_bundles := env_var_or_default("HOME", "") + "/Library/Application Support/stm32cube/bundles"
export PATH := env_var_or_default("PATH", "") + ":" + cube_bundles + "/ninja/1.13.2+st.1/bin:" + cube_bundles + "/st-arm-clang/21.1.1+st.7/bin"

# Default recipe: list all available commands
default:
    @just --list

# Default settings (can be overridden on command line: just target=g491 build)
target := "f401"
build_type := "Debug"

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
configure target=target build_type=build_type:
    cmake --preset {{_preset}}

# Build firmware binary (sandbox.elf), auto-configuring if needed
build target=target build_type=build_type:
    #!/usr/bin/env bash
    if [ ! -f "build/{{_preset}}/build.ninja" ]; then
        echo "Configuring preset {{_preset}}..."
        cmake --preset {{_preset}}
    fi
    cmake --build --preset {{_preset}}

# Flash firmware to the microcontroller (auto-builds if needed)
flash target=target build_type=build_type: (build target build_type)
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
run target=target build_type=build_type: (build target build_type)
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
    if command -v arm-none-eabi-size >/dev/null 2>&1; then
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
        clang-tidy Src/*.c -p "build/{{_preset}}"
    else
        echo "clang-tidy command not found. (Install via 'brew install llvm')"
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
rebuild target=target build_type=build_type: (clean target) (build target build_type)
