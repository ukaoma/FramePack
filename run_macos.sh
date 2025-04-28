#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}===== Starting FramePack for macOS =====${NC}"

# Activate virtual environment
echo -e "${YELLOW}Activating virtual environment...${NC}"
source framepack_venv/bin/activate

# Set PyTorch MPS configuration
export PYTORCH_ENABLE_MPS_FALLBACK=1

# Create outputs directory if it doesn't exist
mkdir -p outputs

# Detect Mac processor type for optimal settings
MAC_CHIP=$(sysctl -n machdep.cpu.brand_string)
if [[ "$MAC_CHIP" == *"M1"* ]] || [[ "$MAC_CHIP" == *"M2"* ]]; then
    # M1/M2 Macs may need fp32 for stability
    echo -e "${YELLOW}Detected M1/M2 Mac: Using fp32 mode for better compatibility...${NC}"
    python demo_gradio.py --fp32 --inbrowser
else
    # M3/M4/M5 Macs perform better without fp32
    echo -e "${YELLOW}Detected newer Apple Silicon: Using optimized settings...${NC}"
    python demo_gradio.py --inbrowser
fi

# Keep terminal open
echo -e "${GREEN}FramePack has finished running. Press any key to exit...${NC}"
read -n 1
