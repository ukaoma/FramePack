#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}===== FramePack macOS Setup Script =====${NC}"

# Current directory should be FramePack
PROJECT_DIR=$(pwd)
echo -e "${YELLOW}Current directory: ${PROJECT_DIR}${NC}"

# Check if we're in the FramePack directory
if [[ $(basename "$PROJECT_DIR") != "FramePack" ]]; then
    echo -e "${RED}Error: This script should be run from the FramePack directory${NC}"
    exit 1
fi

# Step 1: Clean up any trash versions that might be causing conflicts
TRASH_DIR="/Users/ukaoma/Library/Mobile Documents/.Trash/FramePack"
if [ -d "$TRASH_DIR" ]; then
    echo -e "${YELLOW}Found FramePack in Trash. This may be causing conflicts.${NC}"
    echo -e "${YELLOW}Would you like to remove it? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        rm -rf "$TRASH_DIR"
        echo -e "${GREEN}Removed FramePack from Trash.${NC}"
    else
        echo -e "${YELLOW}Skipping Trash cleanup. Note that this may cause issues.${NC}"
    fi
fi

# Step 2: Setup Python virtual environment
echo -e "${YELLOW}Setting up Python virtual environment...${NC}"

if [ -d "framepack_venv" ]; then
    echo -e "${YELLOW}Virtual environment already exists. Would you like to recreate it? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        rm -rf framepack_venv
        echo -e "${GREEN}Removed existing virtual environment.${NC}"
        python3.10 -m venv framepack_venv
        echo -e "${GREEN}Created new virtual environment.${NC}"
    else
        echo -e "${YELLOW}Using existing virtual environment.${NC}"
    fi
else
    python3.10 -m venv framepack_venv
    echo -e "${GREEN}Created new virtual environment.${NC}"
fi

# Step 3: Activate virtual environment and install dependencies
echo -e "${YELLOW}Activating virtual environment and installing dependencies...${NC}"
source framepack_venv/bin/activate

# Set PyTorch MPS configuration
export PYTORCH_ENABLE_MPS_FALLBACK=1

# Install PyTorch for MPS
echo -e "${YELLOW}Installing PyTorch with MPS support...${NC}"
pip install torch torchvision torchaudio
echo -e "${GREEN}PyTorch installed.${NC}"

# Install requirements
echo -e "${YELLOW}Installing other dependencies...${NC}"
pip install -r requirements.txt
echo -e "${GREEN}Dependencies installed.${NC}"

# Step 4: Create outputs directory
mkdir -p outputs
echo -e "${GREEN}Created outputs directory.${NC}"

# Step 5: Run FramePack
echo -e "${GREEN}===== Setup Complete! =====${NC}"
echo -e "${YELLOW}Would you like to run FramePack now? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${YELLOW}Note: First run will download models (~30GB)${NC}"
    
    # Detect Mac processor type for optimal settings
    MAC_CHIP=$(sysctl -n machdep.cpu.brand_string)
    if [[ "$MAC_CHIP" == *"M1"* ]] || [[ "$MAC_CHIP" == *"M2"* ]]; then
        # M1/M2 Macs may need fp32 for stability
        echo -e "${YELLOW}Detected M1/M2 Mac: Using fp32 mode for better compatibility...${NC}"
        python3.10 "$PROJECT_DIR/demo_gradio.py" --fp32 --inbrowser
    else
        # M3/M4/M5 Macs perform better without fp32
        echo -e "${YELLOW}Detected newer Apple Silicon: Using optimized settings...${NC}"
        python3.10 "$PROJECT_DIR/demo_gradio.py" --inbrowser
    fi
else
    echo -e "${GREEN}To run FramePack later, use:${NC}"
    echo -e "    ${YELLOW}./fix_framepack.sh${NC}"
    echo -e "${GREEN}or:${NC}"
    
    # Show different command based on chip detection
    MAC_CHIP=$(sysctl -n machdep.cpu.brand_string)
    if [[ "$MAC_CHIP" == *"M1"* ]] || [[ "$MAC_CHIP" == *"M2"* ]]; then
        echo -e "    ${YELLOW}source framepack_venv/bin/activate${NC}"
        echo -e "    ${YELLOW}python3.10 demo_gradio.py --fp32 --inbrowser${NC}"
    else
        echo -e "    ${YELLOW}source framepack_venv/bin/activate${NC}"
        echo -e "    ${YELLOW}python3.10 demo_gradio.py --inbrowser${NC}"
    fi
fi
