#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}===== FramePack Fixer for macOS =====${NC}"

# Current directory should be FramePack
PROJECT_DIR=$(pwd)
echo -e "${YELLOW}Current directory: ${PROJECT_DIR}${NC}"

# Check if we're in the FramePack directory
if [[ $(basename "$PROJECT_DIR") != "FramePack" ]]; then
    echo -e "${RED}Error: This script should be run from the FramePack directory${NC}"
    exit 1
fi

# Check for any trash/old versions of FramePack that might be interfering
TRASH_DIR="/Users/ukaoma/Library/Mobile Documents/.Trash/FramePack"
if [ -d "$TRASH_DIR" ]; then
    echo -e "${RED}Found FramePack in Trash which may be causing conflicts.${NC}"
    echo -e "${YELLOW}Consider removing it with: rm -rf \"$TRASH_DIR\"${NC}"
    echo
fi

# Make sure Python can find the right modules
echo -e "${YELLOW}Setting up Python path to ensure correct modules are loaded...${NC}"
export PYTHONPATH="$PROJECT_DIR:$PYTHONPATH"

# Check for virtual environment
if [ -d "framepack_venv" ]; then
    echo -e "${GREEN}Found virtual environment, activating...${NC}"
    source framepack_venv/bin/activate
fi

# Set PyTorch MPS configuration
export PYTORCH_ENABLE_MPS_FALLBACK=1

# Create outputs directory if it doesn't exist
mkdir -p outputs

# Detect Mac processor type for optimal settings
MAC_CHIP=$(sysctl -n machdep.cpu.brand_string)

# Run FramePack with explicit path and appropriate flags for Silicon generation
echo -e "${YELLOW}Running FramePack with full path to avoid any confusion...${NC}"

if [[ "$MAC_CHIP" == *"M1"* ]] || [[ "$MAC_CHIP" == *"M2"* ]]; then
    # M1/M2 Macs may need fp32 for stability
    echo -e "${YELLOW}Detected M1/M2 Mac: Using fp32 mode for better compatibility...${NC}"
    echo "Command: python3.10 $PROJECT_DIR/demo_gradio.py --fp32 --inbrowser"
    python3.10 "$PROJECT_DIR/demo_gradio.py" --fp32 --inbrowser
else
    # M3/M4/M5 Macs perform better without fp32
    echo -e "${YELLOW}Detected newer Apple Silicon: Using optimized settings...${NC}"
    echo "Command: python3.10 $PROJECT_DIR/demo_gradio.py --inbrowser"
    python3.10 "$PROJECT_DIR/demo_gradio.py" --inbrowser
fi
