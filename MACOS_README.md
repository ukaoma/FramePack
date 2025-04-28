# FramePack on macOS (Apple Silicon)

This document provides instructions for running FramePack on macOS with Apple Silicon (M1, M2, M3, M4, etc.). The community fork includes specific optimizations for Apple Silicon that enable it to run efficiently on these platforms.

## System Requirements

- **macOS** running on Apple Silicon (M-series) Mac
- **RAM:** At least 16GB recommended, 32GB+ preferred for longer videos
- **Storage:** ~30GB for models plus additional space for videos
- **Python 3.10** (recommended)

## Installation Options

### Option 1: Use the Setup Script (Recommended)

This is the easiest way to get started:

1. Open Terminal and navigate to the FramePack directory
2. Run the setup script:
   ```bash
   ./setup_macos.sh
   ```
3. Follow the prompts to:
   - Clean up any conflicting Trash versions
   - Create a Python virtual environment
   - Install required dependencies
   - Run FramePack

### Option 2: Manual Installation

1. Install Python 3.10 using Homebrew:
   ```bash
   brew install python@3.10
   ```

2. Create a virtual environment (recommended):
   ```bash
   python3.10 -m venv framepack_venv
   source framepack_venv/bin/activate
   ```

3. Install dependencies:
   ```bash
   pip install torch torchvision torchaudio
   pip install -r requirements.txt
   ```

4. Run FramePack:
   - For M1/M2 Macs:
     ```bash
     python3.10 demo_gradio.py --fp32 --inbrowser
     ```
   - For M3/M4 and newer Macs:
     ```bash
     python3.10 demo_gradio.py --inbrowser
     ```

## Important Notes for Apple Silicon

- **M1/M2 Macs:** Use the `--fp32` flag for better compatibility (but will use more memory)
- **M3/M4+ Macs:** Do NOT use the `--fp32` flag (can cause memory issues and worse performance)
- **MPS Fallbacks:** Some PyTorch operations don't support MPS and will fall back to CPU. This is normal and will cause some warnings, but most of the processing still happens on the GPU.
- **Performance:** On an M3 Ultra Mac, expect around 2.5 minutes per second of video. Other Apple Silicon chips may be slower.
- **Memory Usage:** Monitor Activity Monitor to check resource usage during generation.

## Troubleshooting

1. **"avg_pool3d is not currently supported on the MPS backend" warning:**
   - This is a normal limitation of PyTorch's MPS implementation and can be safely ignored
   - The operation falls back to CPU but most processing still occurs on GPU

2. **Out of Memory (OOM) errors:**
   - Try decreasing video length
   - If using M3/M4, make sure you're NOT using the `--fp32` flag
   - If using M1/M2, try using the `--fp32` flag

3. **Slow Generation:**
   - This is expected - video generation is computationally intensive
   - M3 Ultra can process approximately 1 second of video in 2.5 minutes
   - Older or less powerful chips will be slower

4. **Application crashes:**
   - Ensure PYTORCH_ENABLE_MPS_FALLBACK=1 is set in your environment
   - Increase swap space if you're low on RAM

## Helper Scripts

- `fix_framepack.sh`: Quick script to ensure paths are correct and run FramePack properly
- `run_macos.sh`: Run FramePack after installation is complete
- `setup_macos.sh`: Complete setup script for fresh installations
