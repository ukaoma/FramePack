#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}===== FramePack for macOS (Apple Silicon) Setup =====${NC}"
echo "This script will set up FramePack on your Mac with Apple Silicon."

# Check if Python 3.10 is installed
if command -v python3.10 &>/dev/null; then
    echo -e "${GREEN}✓ Python 3.10 found${NC}"
    PYTHON=python3.10
else
    # Try python3, but check version
    PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    if [[ "$PYTHON_VERSION" == "3.10" ]]; then
        echo -e "${GREEN}✓ Python 3.10 found${NC}"
        PYTHON=python3
    else
        echo -e "${RED}✗ Python 3.10 not found. Please install Python 3.10 before continuing.${NC}"
        echo "You can install it using homebrew: brew install python@3.10"
        exit 1
    fi
fi

# Check if virtualenv is installed
if ! $PYTHON -m pip show virtualenv &>/dev/null; then
    echo -e "${YELLOW}Installing virtualenv...${NC}"
    $PYTHON -m pip install virtualenv
fi

# Create virtual environment if it doesn't exist
if [ ! -d "framepack_venv" ]; then
    echo -e "${YELLOW}Creating virtual environment...${NC}"
    $PYTHON -m virtualenv framepack_venv
    echo -e "${GREEN}✓ Virtual environment created${NC}"
else
    echo -e "${GREEN}✓ Virtual environment already exists${NC}"
fi

# Activate virtual environment
echo -e "${YELLOW}Activating virtual environment...${NC}"
source framepack_venv/bin/activate

# Set PyTorch MPS configuration
export PYTORCH_ENABLE_MPS_FALLBACK=1

# Install dependencies
echo -e "${YELLOW}Installing PyTorch for MPS...${NC}"
pip install torch torchvision torchaudio
echo -e "${YELLOW}Installing dependencies...${NC}"
pip install -r requirements.txt

# Create outputs directory if it doesn't exist
mkdir -p outputs

echo -e "${GREEN}===== Installation Complete =====${NC}"
echo -e "${YELLOW}Starting FramePack...${NC}"
echo -e "${YELLOW}Note: First run will download models (~30GB)${NC}"

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
