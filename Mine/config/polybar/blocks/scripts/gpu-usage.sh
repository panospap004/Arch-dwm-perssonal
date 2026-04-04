#!/usr/bin/env bash

RESULT=""

# Try NVIDIA
if command -v nvidia-smi >/dev/null 2>&1; then
    NVIDIA_USAGE=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | awk '{print $1"%"}')
    if [ -n "$NVIDIA_USAGE" ]; then
        RESULT=$(echo "$NVIDIA_USAGE" | tr '\n' '/' | sed 's/\/$//')
    fi
fi

# Try AMD (radeontop)
if command -v radeontop >/dev/null 2>&1; then
    # Check for AMD GPUs
    GPU_COUNT=0
    for card in /sys/class/drm/card*/device/vendor; do
        if [ -f "$card" ]; then
            VENDOR=$(cat "$card")
            if [ "$VENDOR" = "0x1002" ]; then  # AMD vendor ID
                GPU_COUNT=$((GPU_COUNT + 1))
            fi
        fi
    done
    
    if [ "$GPU_COUNT" -gt 0 ]; then
        AMD_USAGE=$(timeout 1.5 radeontop -d - -l 1 2>/dev/null | grep -oP 'gpu \K[0-9.]+' | awk '{print int($1)"%"}')
        if [ -n "$AMD_USAGE" ]; then
            if [ -n "$RESULT" ]; then
                RESULT="$RESULT/$AMD_USAGE"
            else
                RESULT="$AMD_USAGE"
            fi
        fi
    fi
fi

# Try Intel - multiple methods
INTEL_USAGE=""

# Method 1: intel_gpu_top (most accurate but requires root or CAP_PERFMON)
if command -v intel_gpu_top >/dev/null 2>&1; then
    # Check for Intel GPUs
    HAS_INTEL=0
    for card in /sys/class/drm/card*/device/vendor; do
        if [ -f "$card" ]; then
            VENDOR=$(cat "$card")
            if [ "$VENDOR" = "0x8086" ]; then  # Intel vendor ID
                HAS_INTEL=1
                break
            fi
        fi
    done
    
    if [ "$HAS_INTEL" -eq 1 ]; then
        # Try intel_gpu_top with different output patterns
        INTEL_OUTPUT=$(timeout 1.5 intel_gpu_top -o - -s 100 2>/dev/null)
        
        # Pattern 1: Look for Render/3D usage
        INTEL_USAGE=$(echo "$INTEL_OUTPUT" | grep -oP 'Render/3D[^0-9]*\K[0-9.]+' | head -1 | awk '{print int($1)"%"}')
        
        # Pattern 2: Try different format
        if [ -z "$INTEL_USAGE" ]; then
            INTEL_USAGE=$(echo "$INTEL_OUTPUT" | grep "Render/3D" | grep -oP '[0-9.]+(?=%)' | head -1 | awk '{print int($1)"%"}')
        fi
        
        # Pattern 3: Look for any percentage after Render/3D
        if [ -z "$INTEL_USAGE" ]; then
            INTEL_USAGE=$(echo "$INTEL_OUTPUT" | awk '/Render\/3D/{for(i=1;i<=NF;i++)if($i~/^[0-9.]+$/){print int($i)"%"; exit}}')
        fi
    fi
fi

# Method 2: Read from sysfs (less accurate, shows engine busy)
if [ -z "$INTEL_USAGE" ]; then
    for card in /sys/class/drm/card*; do
        if [ -f "$card/device/vendor" ]; then
            VENDOR=$(cat "$card/device/vendor" 2>/dev/null)
            if [ "$VENDOR" = "0x8086" ]; then
                # Try gt_boost_freq_mhz as activity indicator
                if [ -f "$card/gt_boost_freq_mhz" ] && [ -f "$card/gt_cur_freq_mhz" ]; then
                    BOOST=$(cat "$card/gt_boost_freq_mhz" 2>/dev/null)
                    CURRENT=$(cat "$card/gt_cur_freq_mhz" 2>/dev/null)
                    if [ -n "$BOOST" ] && [ -n "$CURRENT" ] && [ "$BOOST" -gt 0 ]; then
                        USAGE=$((CURRENT * 100 / BOOST))
                        INTEL_USAGE="${USAGE}%"
                        break
                    fi
                fi
                
                # Alternative: check engine busy percentage
                for engine in "$card"/engine/*/busy; do
                    if [ -f "$engine" ]; then
                        BUSY=$(cat "$engine" 2>/dev/null)
                        if [ -n "$BUSY" ]; then
                            INTEL_USAGE="${BUSY}%"
                            break 2
                        fi
                    fi
                done
            fi
        fi
    done
fi

if [ -n "$INTEL_USAGE" ]; then
    if [ -n "$RESULT" ]; then
        RESULT="$RESULT/$INTEL_USAGE"
    else
        RESULT="$INTEL_USAGE"
    fi
fi

if [ -z "$RESULT" ]; then
    echo "N/A"
else
    echo "$RESULT"
fi
