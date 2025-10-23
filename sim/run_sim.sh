#!/bin/bash
set -e
cd "$(dirname "$0")"

BUILD_DIR="build"
mkdir -p $BUILD_DIR

SRC_DIR="../src"
TB="../test/cpu_tb.v"

iverilog -o $BUILD_DIR/cpu_tb $SRC_DIR/cpu_top.v $TB
vvp $BUILD_DIR/cpu_tb

if command -v gtkwave &> /dev/null; then
  gtkwave cpu_tb.vcd &
else
  echo "GTKWave not installed — skipping waveform view."
fi
