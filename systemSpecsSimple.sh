cat << 'EOF' | bash
#!/bin/bash
echo "========== SYSTEM SPECIFICATIONS =========="
echo "OS: $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
echo "Kernel: $(uname -r) ($(uname -m))"
echo "CPU: $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)"
echo "Cores/Threads: $(lscpu -p | grep -v '^#' | sort -u -t, -k 2 | wc -l) / $(nproc)"
echo "Architecture: $(uname -m)"

# RAM with speed detection (requires sudo for dmidecode)
MEM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}' | sed 's/i//g')
MEM_SPEED=$(sudo dmidecode -t memory 2>/dev/null | awk '/Speed: [0-9]+ MHz/{print $2" MHz"; exit}')
MEM_TYPE=$(sudo dmidecode -t memory 2>/dev/null | awk '/Type: DDR/{print $2; exit}')
echo "Memory: ${MEM_TOTAL} ${MEM_SPEED:+($MEM_SPEED ${MEM_TYPE})}"

# Motherboard (usually readable without sudo)
BOARD_VENDOR=$(cat /sys/class/dmi/id/board_vendor 2>/dev/null | xargs)
BOARD_NAME=$(cat /sys/class/dmi/id/board_name 2>/dev/null | xargs)
BOARD_VER=$(cat /sys/class/dmi/id/board_version 2>/dev/null | xargs)
echo "Motherboard: ${BOARD_VENDOR} ${BOARD_NAME} ${BOARD_VER:+($BOARD_VER)}"

# GPU with VRAM detection
GPU_MODEL=$(lspci | grep -i vga | sed 's/^.*: //' | xargs)
GPU_VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1 | xargs)
echo "GPU: ${GPU_MODEL} ${GPU_VRAM:+(${GPU_VRAM} GB VRAM)}"

# Primary storage (size, model, type)
lsblk -d -o SIZE,MODEL,ROTA | awk 'NR==2{type=$3==1?"HDD":"SSD"; printf "Storage: %s %s (%s)\n", $1, $2, type}'
echo "==========================================="
EOF


