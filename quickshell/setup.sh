#!/bin/sh


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build
