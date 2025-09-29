# System Monitoring Tools

Documentation for system monitoring tools configured in this Nix setup.

## Process & System Monitoring

### btop
**Location**: `users/luffy/common/toolbox.nix:49`
**Usage**: `btop`
Modern system monitor with interactive interface, colorful display, process management, and GPU monitoring capabilities. Replacement for top/htop.

### glances
**Location**: `users/luffy/common/toolbox.nix:50`
**Usage**: `glances` or `glances -w` (web interface)
Cross-platform system monitoring tool with web interface, plugins, and extensive metrics. Provides comprehensive system overview including CPU, memory, disk, network, and processes.

### procs
**Location**: `users/luffy/common/toolbox.nix:52`
**Usage**: `procs` or `procs pattern`
Modern replacement for ps with colorful output and additional information. Shows process tree, memory usage, and CPU usage in an easy-to-read format.

## GPU Monitoring

### nvtop
**Location**: `modules/base/nvidia.nix:51`
**Usage**: `nvtop`
Real-time GPU monitoring with detailed metrics for NVIDIA GPUs. Shows GPU utilization, memory usage, temperature, and running processes.

## Network Monitoring

### gping
**Location**: `users/luffy/common/toolbox.nix:37`
**Usage**: `gping google.com` or `gping host1 host2`
Ping tool with TUI graph interface. Visualizes ping response times and packet loss over time.

### nload
**Location**: `users/luffy/common/toolbox.nix:51`
**Usage**: `nload` or `nload eth0`
Real-time network traffic visualization showing incoming and outgoing bandwidth usage per network interface.

### mtr
**Location**: `modules/base/system-packages.nix:26`
**Usage**: `mtr google.com`
Network diagnostic tool combining ping and traceroute functionality. Shows network path and latency statistics.

### iperf3
**Location**: `modules/base/system-packages.nix:27`
**Usage**: `iperf3 -c server.example.com`
Network performance testing tool for measuring bandwidth, jitter, and packet loss between hosts.

## Disk Usage Monitoring

### duf
**Location**: `users/luffy/common/toolbox.nix:45`
**Usage**: `duf`
Modern disk usage utility with colorful output. Shows disk usage, available space, and filesystem information in a clean table format.

### du-dust
**Location**: `users/luffy/common/toolbox.nix:46`
**Usage**: `dust` or `dust /path/to/directory`
Interactive disk usage analyzer that shows directory sizes in a tree format with visual bars.

## File System Tools

### fd
**Location**: `users/luffy/common/toolbox.nix:24`
**Usage**: `fd pattern` or `fd -e .nix pattern`
Fast and user-friendly alternative to find. Supports regex patterns and file type filtering.

### ripgrep
**Location**: `users/luffy/common/toolbox.nix:26`
**Usage**: `rg pattern` or `rg -i pattern`
Extremely fast text search tool with PCRE2 support. Recursively searches directories for regex patterns.

## Performance Testing

### hyperfine
**Location**: `users/luffy/common/toolbox.nix:33`
**Usage**: `hyperfine 'command1' 'command2'`
Command-line benchmarking tool that runs commands multiple times and provides statistical analysis of execution times.

## Quick Reference

| Task | Command | Description |
|------|---------|-------------|
| System overview | `btop` | Interactive system monitor |
| Detailed system stats | `glances` | Comprehensive monitoring with web UI |
| Process list | `procs` | Modern colorful process viewer |
| GPU monitoring | `nvtop` | NVIDIA GPU statistics |
| Network connectivity | `gping google.com` | Visual ping with graphs |
| Network traffic | `nload` | Real-time bandwidth usage |
| Network path | `mtr google.com` | Traceroute with statistics |
| Disk usage overview | `duf` | Colorful disk space summary |
| Directory sizes | `dust` | Interactive disk usage tree |
| Find files | `fd pattern` | Fast file search |
| Search content | `rg pattern` | Fast text search |
| Benchmark commands | `hyperfine 'cmd'` | Performance testing |