#!/bin/bash

echo "========== SYSTEM SPECIFICATIONS =========="

# OS & Kernel
echo "OS: $(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2)"
echo "Kernel: $(uname -r) ($(uname -m))"

# CPU
CPU_MODEL=$(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)
CORES=$(lscpu -p 2>/dev/null | grep -v '^#' | sort -u -t, -k 2 | wc -l)
THREADS=$(nproc)
echo "CPU: ${CPU_MODEL}"
echo "Cores/Threads: ${CORES} / ${THREADS}"

# Memory with Method 1 (dmidecode)
MEM_TOTAL=$(free -h 2>/dev/null | awk '/^Mem:/ {print $2}' | sed 's/i//g')
MEM_SPEED=""

if command -v dmidecode &> /dev/null; then
    # Method 1: Get configured speed (XMP/DOCP profile) or standard speed
    MEM_SPEED=$(sudo dmidecode -t memory 2>/dev/null | grep -E "Configured Clock Speed:|Speed:" | grep -v "Unknown" | head -1 | awk '{print $2 " " $3}' | sed 's/ *$//')
    
    # Clean up: if we got "MHz" or "MT/s" alone, try alternate parsing
    if [ -z "$MEM_SPEED" ] || [[ "$MEM_SPEED" == *"Unknown"* ]]; then
        MEM_SPEED=$(sudo dmidecode -t memory 2>/dev/null | grep "Speed:" | head -1 | awk '{print $2 " " $3}' | sed 's/ *$//')
    fi
fi

if [ -n "$MEM_SPEED" ] && [[ ! "$MEM_SPEED" == *"Unknown"* ]]; then
    echo "Memory: ${MEM_TOTAL} (${MEM_SPEED})"
else
    echo "Memory: ${MEM_TOTAL}"
fi

# Motherboard
MB_VENDOR=$(cat /sys/class/dmi/id/board_vendor 2>/dev/null | xargs)
MB_NAME=$(cat /sys/class/dmi/id/board_name 2>/dev/null | xargs)
MB_VER=$(cat /sys/class/dmi/id/board_version 2>/dev/null | xargs)
echo "Motherboard: ${MB_VENDOR} ${MB_NAME} ${MB_VER:+($MB_VER)}"

# GPU
GPU=$(lspci 2>/dev/null | grep -i vga | sed 's/^.*: //' | xargs)
GPU_VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1 | xargs)
echo "GPU: ${GPU} ${GPU_VRAM:+(${GPU_VRAM} GB VRAM)}"

# Storage
STORAGE=$(lsblk -d -o SIZE,MODEL,ROTA 2>/dev/null | awk 'NR==2{type=$3==1?"HDD":"SSD"; printf "%s %s (%s)", $1, $2, type}')
echo "Storage: ${STORAGE}"

echo "==========================================="
