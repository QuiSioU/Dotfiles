#!/bin/bash
# bash/bash_functions.sh


# Import auto completions for personal functions
[[ -f "$HOME/.bash_completions" ]] && . "$HOME/.bash_completions"


_ask_yes_or_no() {
    if [[ $# -ne 1 ]]; then
        echo "Error: Too many arguments."
        return -1
    fi

    local msg="$1"
    declare key
    while true; do
        read -s -n 1 -rp "$msg [Y/n] " key
        echo
        case "$key" in
            [Yy]* ) return 1 ;;  # success (yes)
            [Nn]* ) return 0 ;;  # failure (no)
        esac
    done
}


# C/C++ project set-up
makecxx() {
    # Flags and vars
    declare project_name
    local flag_name=0

    declare executable_name
    local flag_executable=0

    local flag_help=0
    local read_args=0

    local flag_headers=0
    local header_files=()

    local flag_main=0

    local flag_vscode=0

    local flag_c=0

    local flag_version=0

    declare version
    local original_c_ver=17
    local original_cpp_ver=20

    local file_ext="cpp"
    local compiler="g++"
    declare compiler_loc

	if [[ $# -eq 0 ]]; then
		flag_help=1
	fi

    while [[ $# -gt 0 ]]; do
        if [[ flag_help -eq 1 ]]; then
            break
        fi

        read_args=$((read_args+1))

        case "$1" in
            -h|--help)
                flag_help=1
                shift
                ;;
            -n|--name)
                shift
                if [[ $# -eq 0 || $1 =~ ^- ]]; then
                    echo "Error: No value provided after --name."
                    return 1
                fi
                flag_name=1
                project_name="$1"
                shift
                ;;
            -e|--exec)
                shift
                if [[ $# -eq 0 || $1 =~ ^- ]]; then
                    echo "Error: No value provided after --exec."
                    return 1
                fi
                flag_executable=1
                executable_name="$1"
                shift
                ;;
            -v|--version)
                shift
                if [[ $# -eq 0 || $1 =~ ^- ]]; then
                    echo "Error: No value provided after --version."
                    return 1
                fi
                version="$1"
                flag_version=1
                shift
                ;;
            -H|--headers)
                flag_headers=1
                shift

                # collect filenames until next flag or end
                while [[ $# -gt 0 && ! "$1" =~ ^- ]]; do
                    header_files+=("$1")
                    shift
                done
                ;;
            -m|--main)
                flag_main=1
                shift
                ;;
            -vs|--vscode)
                flag_vscode=1
                shift
                ;;
            -c|--c-files)
                flag_c=1
                shift
                ;;
            *) # unknown option
                echo "Unknown option: $1" >&2
                return 1
                ;;
        esac
    done

    if [[ $flag_help -eq 1 ]]; then
        if [[ $# -gt 0 || read_args -gt 1 ]]; then
            echo "Error: --help must be used alone, with no other arguments."
            return 1
        else
            cat <<'EOF'
Usage: makecxx -n PROJECT_NAME [OPTIONS] [FILES]
Creates a new C/C++ project environment.
Required:
    -c,     --c-files                           Create a pure C project instead of C++
    -n,     --name          PROJECT_NAME        Provide the project's name

Options:
    -e,     --exec          EXECUTABLE_NAME     Set the name for the executable (project name as default)
    -h,     --help                              Display this help message
    -H,     --headers       FILE1 FILE2 ...     Create header files together with the respective source files
    -m,     --main                              Create a main source file
    -v,     --version       VERSION             Determine the C/C++ version when compiling
    -vs,    --vscode                            Compatibility with Visual Studio Code

Examples:
    makecxx -H file1 file2 -m -n my_project
EOF
            return 0
        fi
    fi

    if [[ $flag_name -eq 0 ]]; then
        echo "Error: No project name (-n / --name) was provided."
        return 1
    fi

    if [[ $flag_executable -eq 0 ]]; then
        executable_name="$project_name"
    fi

    mkdir $project_name
    cd $project_name

    mkdir src
    mkdir include

    if [[ flag_c -eq 0 ]]; then
        if [[ flag_version -eq 0 ]]; then
            version="++$original_cpp_ver"
        else
            original_cpp_ver="$version"
            version="++$version"
        fi
    else
        file_ext="c"
        compiler="gcc"
        if [[ flag_version -eq 0 ]]; then
            version="$original_c_ver"
        else
            original_c_ver="$version"
        fi
    fi

    
    # MakeFile
    cat > "Makefile" <<EOF
CC = ${compiler}
FLAGS = -Wall -Wextra -std=c${version} -g -fsanitize=address -fPIC -O2

LOCAL_INCLUDE = ./include
SYSTEM_INCLUDE = /home/QuiSioU/.local/include
SYSTEM_LIB = /home/QuiSioU/.local/lib

INCLUDE = -I\$(LOCAL_INCLUDE) -I\$(SYSTEM_INCLUDE)
SRC = ./src
BUILD = ./.build
OBJDIR = \$(BUILD)/obj
DEPDIR = \$(BUILD)/dep
EXEC_NAME = ${executable_name}
SOURCES = \$(wildcard \$(SRC)/*.${file_ext})
OBJECTS = \$(patsubst \$(SRC)/%.${file_ext},\$(OBJDIR)/%o,\$(SOURCES))
DEPS = \$(patsubst \$(SRC)/%.${file_ext},\$(DEPDIR)/%d,\$(SOURCES))

ifeq (\$(OS),Windows_NT)
    TARGET = \$(BUILD)/\$(EXEC_NAME).exe
    MKDIR_CMD = @if not exist build mkdir build && if not exist \$(OBJDIR) mkdir \$(OBJDIR) && if not exist \$(DEPDIR) mkdir \$(DEPDIR)
    LDFLAGS = -lws2_32
else
    TARGET = \$(BUILD)/\$(EXEC_NAME)
    MKDIR_CMD = @mkdir -p \$(OBJDIR) \$(DEPDIR)
    LDFLAGS = -L\$(SYSTEM_LIB)
endif

all: \$(TARGET)

\$(TARGET): \$(OBJECTS)
	\$(CC) \$(FLAGS) -o \$@ \$^ \$(LDFLAGS)

\$(OBJDIR)/%o: \$(SRC)/%.${file_ext}
	\$(MKDIR_CMD)
	\$(CC) \$(FLAGS) \$(INCLUDE) -MMD -MP -c \$< -o \$@ -MF \$(DEPDIR)/\$*d

-include \$(DEPS)

run: \$(TARGET)
	\$(TARGET)

clean:
	rm -rf \$(BUILD)

EOF

    
    # Visual Studio Code configuration
    if [[ $flag_vscode -eq 1 ]]; then
        mkdir .vscode

        cat > ".vscode/c_cpp_properties.json" <<EOF
{
    "configurations": [
        {
            "name": "Linux",
            "includePath": [
                "/usr/lib/gcc/x86_64-linux-gnu/14/include",
                "\${workspaceFolder}/include"
            ],
            "defines": [],
            "cStandard": "c${original_c_ver}",
            "cppStandard": "gnu++${original_cpp_ver}",
            "intelliSenseMode": "linux-gcc-x64",
            "compilerPath": "/usr/bin/${compiler}"
        }
    ],
    "version": 4
}
EOF
    fi


    # Execute flags

    # Create header files
    if [[ $flag_headers -eq 1 ]]; then
        if [[ ${#header_files[@]} -eq 0 ]]; then
            echo "No header files specified" >&2
            return 1
        fi

        for fname in "${header_files[@]}"; do
            # Header file
            cat > "include/${fname}.h" <<EOF
#ifndef ${fname^^}_H
#define ${fname^^}_H

// Code here

#endif
EOF

            # Source file
            cat > "src/${fname}.${file_ext}" <<EOF
#include "${fname}.h"

// Code here
EOF
        done
    fi

    
    if [[ $flag_main -eq 1 ]]; then
        if [[ flag_c -eq 0 ]]; then
            cat > "src/main.cpp" <<'EOF'
#include <iostream>

int main(int argc, char** argv) {
	std::cout << "Num args: " << argc - 1 << "; Args: " << argv << '\n';

    return 0;
}
EOF
        else
            cat > "src/main.c" <<'EOF'
#include <stdio.h>

int main(int argc, char** argv) {
	printf("Num args: %d; Args:", argc - 1);
	for (int i = 1; i < argc; i++) {
		printf(" %s", argv[i]);
	}
	printf("\n");

    return 0;
}
EOF
        fi
    fi

# Add clangd support
if [[ $flag_main -eq 1 ]] && command -v bear &> /dev/null; then
    echo "Generating compile_commands.json for clangd..."
    bear -- make
else
    echo "Skipping compile_commands.json generation (bear not found)."
fi

}


# Change directory to the symbolic link pointer
cdl() {
    if [[ $# -gt 1 ]]; then
        echo "Error: Too many arguments"
        return 1
    fi

    cd "$(readlink -f "$1")"
}


# Scan document to image or pdf
scandoc() {
    local flag_help=0
    local flag_format=0
    local flag_mode=0
    local flag_device=0
    local flag_name=0
    local flag_resolution=0

    local format="png"
    local mode="Color"
    # Matches the exact string found by scanimage -L
    local device="hpaio:/net/ENVY_5640_series?ip=192.168.50.5"
    local name="scan_$(date +%F_%H-%M-%S)"
    local resolution="300"
    local read_args=0

    while [[ $# -gt 0 ]]; do
        ((read_args++))
        case "$1" in
            -h|--help)
                flag_help=1; shift; break ;;
            -m|--mode)
                [[ flag_mode -eq 1 ]] && { echo "Error: Option '$1' used twice."; return 1; }
                shift
                # SANE modes are case-sensitive; usually 'Color', 'Gray', or 'Lineart'
                flag_mode=1; mode="$1"; shift ;;
            -d|--device)
                [[ flag_device -eq 1 ]] && { echo "Error: Option '$1' used twice."; return 1; }
                flag_device=1; shift; device="$1"; shift ;;
            -f|--format)
                [[ flag_format -eq 1 ]] && { echo "Error: Option '$1' used twice."; return 1; }
                flag_format=1; shift; format="$1"; shift ;;
            -n|--name)
                [[ flag_name -eq 1 ]] && { echo "Error: Option '$1' used twice."; return 1; }
                flag_name=1; shift; name="$1"; shift ;;
            -r|--resolution)
                [[ flag_resolution -eq 1 ]] && { echo "Error: Option '$1' used twice."; return 1; }
                flag_resolution=1; shift; resolution="$1"; shift ;;
            *)
                echo "Error: Unknown option '$1'. Use --help."
                return 1 ;;
        esac
    done

    if [[ $flag_help -eq 1 ]]; then
        cat <<EOF
Usage: scandoc [OPTIONS]
Options:
    -d, --device      Device URI (Current: $device)
    -f, --format      png, tiff, pdf (Default: png)
    -m, --mode        Color, Gray, Lineart (Default: Color)
    -n, --name        Output filename (No extension)
    -r, --resolution  DPI (Default: 300)
EOF
        return 0
    fi

    echo "Scanning from HP ENVY (hpaio)..."

    if [[ "$format" == "pdf" ]]; then
        # For PDF, we scan to TIFF (lossless) then convert via img2pdf
        scanimage --resolution "$resolution" --mode "$mode" -d "$device" --format=tiff | img2pdf -o "$name.pdf"
    else
        scanimage --resolution "$resolution" --mode "$mode" -d "$device" --format="$format" > "$name.$format"
    fi
    
    echo "Done! Saved as $name.$format"
}


htb() {
    local flag_help=0
    local flag_boot_only=0
    local flag_clean_only=0
    local flag_proxy=0
    local flag_ssh_only=0
    local flag_running=0
    local read_args=()
    local port_number=2222
    local socks_port=1080

    while [[ $# -gt 0 ]]; do
        
        read_args=$((read_args+1))

        case "$1" in
            -h|--help)
                flag_help=1
                shift
                break
                ;;
            -b|--boot-only)
                flag_boot_only=1
                shift
                ;;
            -c|--clean-only)
                flag_clean_only=1
                shift
                ;;
            -p|--proxy)
                flag_proxy=1
                shift
                # If next argument is a number, use it as port
                if [[ $# -gt 0 && "$1" =~ ^[0-9]+$ ]]; then
                    socks_port="$1"
                    shift
                fi
                ;;
            -r|--running)
                flag_running=1
                shift
                break
                ;;
            -s|--ssh-only)
                flag_ssh_only=1
                shift
                ;;
            *) # Unknown option
                echo "Unknown option: $1" >&2
                return 1
                ;;
        esac
    done

    if [[ $flag_help -eq 1 ]]; then
        if [[ $# -gt 0 || read_args -gt 1 ]]; then
            echo "Error: --help must be used alone, with no other arguments."
            return 1
        else
            cat <<'EOF'
Usage: htb [OPTIONS]
Boots up Ubuntu Server VM with a Hack The Box setup.
Options:
    -b,     --boot-only                     Only boot up VM, don't ssh into it after
    -c,     --clean-only                    Only clean up VM process (useful if it didn't terminate by itself)
    -h,     --help                          Display this help message
    -p,     --proxy         [PORT-NUMBER]   Start SOCKS5 proxy on localhost on this terminal (port 1080 by default)
    -r,     --running                       Checks whether the VM and the proxy are running
    -s,     --ssh-only                      Only SSH into VM, don't have to boot it up (it is already up)
EOF
        fi
	    return 0
    fi

    if [[ $flag_running -eq 1 ]]; then
        if [[ $# -gt 0 || read_args -gt 1 ]]; then
            echo "Error: --running must be used alone, with no other arguments."
            return 1
        else
            if [[ -f /tmp/qemu-htb.pid ]]; then
                QEMU_PID=$(cat /tmp/qemu-htb.pid)
                if kill -0 "$QEMU_PID" 2>/dev/null; then
                    echo "[+] VM is running (PID $QEMU_PID)."
                else
                    echo "[-] VM PID file exists but process not running."
                fi
            else
                echo "[-] VM is not running."
            fi

            if [[ -f /tmp/qemu-htb-proxy.running ]]; then
                echo "[+] Proxy seems to be running."
            else
                echo "[-] Proxy is not running."
            fi
        fi
        return 0
    fi

    if [[ $flag_proxy -eq 1 ]]; then
        # Check if only flag
        if [[ $# -gt 0 || read_args -gt 1 ]]; then
            echo "Error: --proxy must be used alone, with no other arguments."
            return 1
        fi

        # Check if VM running
        if [[ ! -f /tmp/qemu-htb.pid ]]; then
            echo "[-] Cannot start proxy: VM is not running."
            return 1
        fi

        # Check if port is free
        if nc -z localhost "$socks_port" >/dev/null 2>&1; then
            echo "[-] Proxy not started: port $socks_port already in use (maybe by proxy itself)."
            return 1
        fi

        echo "[+] Starting SOCKS5 proxy on localhost:$socks_port..."
        echo "[!] Proxy will run in foreground. Keep this terminal open to maintain it."
        
        touch /tmp/qemu-htb-proxy.running
        trap 'rm -f /tmp/qemu-htb-proxy.running; exit' INT TERM EXIT

        ssh -N -D "$socks_port" -p "$port_number" kali@localhost

        rm -f /tmp/qemu-htb-proxy.running
        trap - INT TERM EXIT

        return 0
    fi

    if [[ $flag_clean_only -eq 1 && ($flag_boot_only -eq 1 || $flag_ssh_only -eq 1) ]]; then
        echo "Error: --clean-only cannot be combined with other flags"
        return 1
    fi

    if [[ $flag_boot_only -eq 1 && $flag_ssh_only -eq 1 ]]; then
        echo "Error: --boot-only and --ssh-only cannot be used together"
        return 1
    fi

    if [[ "$socks_port" -lt 1024 || "$socks_port" -gt 65535 ]]; then
        echo "[-] Invalid proxy port $socks_port. Must be 1024-65535."
        return 1
    fi

    if [[ $flag_clean_only -eq 0 ]]; then
        # Boot up VM
        if [[ $flag_ssh_only -eq 0 ]]; then
            qemu-system-x86_64 \
                -enable-kvm \
                -m 4096 \
                -smp 4 \
                -cpu host \
                -drive file=/home/QuiSioU/VirtualMachine/kali.qcow2,format=qcow2,if=virtio,aio=io_uring,cache=writeback \
                -netdev user,id=net0,hostfwd=tcp::"$port_number"-:22 \
				-device virtio-net-pci,netdev=net0 \
				-device virtio-vga \
                -daemonize \
                -display none \
                -pidfile /tmp/qemu-htb.pid
            
            echo "[+] VM booted up correctly"
        fi

        # If boot-only, exit here
        if [[ $flag_boot_only -eq 1 ]]; then
            return 0
        fi

        # Wait for SSH only if booted VM in this same function execution
        if [[ $flag_ssh_only -eq 0 ]]; then
            echo "[*] Trying to SSH into VM..."
            until nc -z localhost "$port_number" >/dev/null 2>&1; do
                sleep 0.5
            done
        fi

        # SSH into VM
        ssh -X -p "$port_number" kali@localhost
    fi

	# Clean up process stuff (if we ssh to it; no reason to only boot and then instantly clean up)
    if [[ $flag_boot_only -eq 0 && $flag_ssh_only -eq 0 ]]; then
        echo "[*] Cleaning up VM resources..."

        # Kill VM if running
        if [[ -f /tmp/qemu-htb.pid ]]; then
            QEMU_PID=$(cat /tmp/qemu-htb.pid)
            if kill -0 "$QEMU_PID" 2>/dev/null; then
                kill "$QEMU_PID" 2>/dev/null || true
            fi
            rm -f /tmp/qemu-htb.pid
            echo "  [+] Successfully killed VM."
        else
            echo "  [-] Could not kill VM (not running)."
        fi
    fi
}


bthconn() {
    local flag_help=0
    local flag_address=0
    local mac_address="04:52:C7:5F:C7:42"
    local read_args=()
    declare connected

    while [[ $# -gt 0 ]]; do

        read_args=$((read_args+1))

        case "$1" in
            -h|--help)
                flag_help=1
                shift
                break
                ;;
            *) # Treat as MAC address
                flag_address=1
                mac_address="$1"
                shift
                ;;
        esac
    done

    if [[ $flag_help -eq 1 ]]; then
        if [[ $# -gt 0 || read_args -gt 1 ]]; then
            echo "Error: --help must be used alone, with no other arguments."
            return 1
        else
            cat <<'EOF'
Usage: bthconn <MAC ADDRESS>
Connects / disconnects bluetooth device depending on its actual state.
Options:
    -h,     --help      Display this help message

Examples:
    bthconn 00:00:00:00:00:00

EOF
        fi
    return 1
    fi


    if [[ ! "$mac_address" =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]]; then
        echo "Error: Incorrect MAC address format." >&2
        return 1
    fi

    connected=$(bluetoothctl info "$mac_address" | awk -F': ' '/Connected/ {print $2}')
    if [[ "$connected" == "yes" ]]; then
        _ask_yes_or_no "Disconnect device $mac_address?"
        if [[ $? -eq 1 ]]; then
            bluetoothctl disconnect $mac_address
        else
            echo "Operation cancelled."
        fi
    else
        bluetoothctl connect $mac_address
    fi

}
complete -F _bthdevs_auto_completions bthconn


bthinfo() {
    local flag_help=0
    local flag_address=0
    local mac_address="04:52:C7:5F:C7:42"
    local read_args=()

    while [[ $# -gt 0 ]]; do

        read_args=$((read_args+1))

        case "$1" in
            -h|--help)
                flag_help=1
                shift
                break
                ;;
            *) # Treat as MAC address
                flag_address=1
                mac_address="$1"
                shift
                ;;
        esac
    done

    if [[ $flag_help -eq 1 ]]; then
        if [[ $# -gt 0 || read_args -gt 1 ]]; then
            echo "Error: --help must be used alone, with no other arguments."
            return 1
        else
            cat <<'EOF'
Usage: bthinfo <MAC ADDRESS>
Displays information on the device.
Options:
    -h,     --help      Display this help message

Examples:
    bthinfo 00:00:00:00:00:00

EOF
        fi
    return 1
    fi


    if [[ ! "$mac_address" =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]]; then
        echo "Error: Incorrect MAC address format." >&2
        return 1
    fi

    bluetoothctl info $mac_address
    echo

}
complete -F _bthdevs_auto_completions bthinfo
