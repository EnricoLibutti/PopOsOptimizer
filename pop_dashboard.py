#!/usr/bin/env python3
"""
Pop-OS Optimizer Dashboard - Professional Edition
=================================================
Modern, interactive system optimization dashboard with professional UI/UX
"""

import os
import sys
import subprocess
import logging
import psutil
import time
from pathlib import Path
from typing import Dict, List, Optional
from dataclasses import dataclass
from datetime import datetime
import shutil
import argparse
import threading
from collections import deque
import re


# Rich imports for modern UI
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn, TaskProgressColumn
from rich.layout import Layout
from rich.live import Live
from rich.text import Text
from rich.align import Align
from rich.columns import Columns
from rich.tree import Tree
from rich.prompt import Prompt, Confirm
from rich.status import Status
from rich import box
from rich.theme import Theme

# Custom theme for professional look
custom_theme = Theme({
    "info": "cyan",
    "warning": "yellow", 
    "error": "bold red",
    "success": "bold green",
    "highlight": "magenta",
    "cyan": "bright_blue",
    "dim": "bright_black"
})

console = Console(theme=custom_theme)

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s: %(message)s',
    handlers=[
        logging.FileHandler('optimizer_dashboard.log'),
        logging.StreamHandler(sys.stderr)
    ]
)
logger = logging.getLogger(__name__)

@dataclass
class SystemMetrics:
    """System performance metrics"""
    cpu_percent: float = 0.0
    cpu_freq: float = 0.0
    cpu_cores: int = 0
    memory_percent: float = 0.0
    memory_available: float = 0.0
    memory_total: float = 0.0
    swap_percent: float = 0.0
    disk_usage: float = 0.0
    disk_read_speed: float = 0.0
    disk_write_speed: float = 0.0
    network_sent: float = 0.0
    network_recv: float = 0.0
    uptime: str = "Unknown"
    load_avg: List[float] = None
    temperature: Optional[float] = None
    
    def __post_init__(self):
        if self.load_avg is None:
            self.load_avg = [0.0, 0.0, 0.0]

@dataclass
class OptimizationStatus:
    """Status of optimization modules"""
    cpu_boost: bool = False
    cpu_governor: str = "unknown"
    memory_optimized: bool = False
    ssd_optimized: bool = False
    desktop_optimized: bool = False
    services_optimized: bool = False

class SystemMonitor:
    """Advanced system monitoring with real-time metrics"""
    
    def __init__(self):
        self.metrics = SystemMetrics()
        self.last_disk_io = psutil.disk_io_counters()
        self.last_net_io = psutil.net_io_counters()
        self.last_time = time.time()
        self.cpu_history = deque(maxlen=60)  # Keep 60 seconds of CPU history
        self.memory_history = deque(maxlen=60)
    
    def update_metrics(self):
        """Update all system metrics with advanced monitoring"""
        try:
            current_time = time.time()
            time_delta = current_time - self.last_time
            
            # CPU metrics
            cpu_percent = psutil.cpu_percent(interval=0.1)
            self.metrics.cpu_percent = cpu_percent
            self.cpu_history.append(cpu_percent)
            
            cpu_freq = psutil.cpu_freq()
            self.metrics.cpu_freq = cpu_freq.current if cpu_freq else 0
            self.metrics.cpu_cores = psutil.cpu_count()
            
            # Load average
            if hasattr(os, 'getloadavg'):
                self.metrics.load_avg = list(os.getloadavg())
            
            # Memory metrics
            memory = psutil.virtual_memory()
            self.metrics.memory_percent = memory.percent
            self.metrics.memory_available = memory.available / (1024**3)  # GB
            self.metrics.memory_total = memory.total / (1024**3)  # GB
            self.memory_history.append(memory.percent)
            
            swap = psutil.swap_memory()
            self.metrics.swap_percent = swap.percent
            
            # Disk metrics
            disk = psutil.disk_usage('/')
            self.metrics.disk_usage = disk.percent
            
            # Calculate disk I/O rates
            current_disk_io = psutil.disk_io_counters()
            if self.last_disk_io and time_delta > 0:
                read_bytes = (current_disk_io.read_bytes - self.last_disk_io.read_bytes) / time_delta
                write_bytes = (current_disk_io.write_bytes - self.last_disk_io.write_bytes) / time_delta
                self.metrics.disk_read_speed = read_bytes / (1024**2)  # MB/s
                self.metrics.disk_write_speed = write_bytes / (1024**2)  # MB/s
            
            # Network I/O rates
            current_net_io = psutil.net_io_counters()
            if self.last_net_io and time_delta > 0:
                sent_bytes = (current_net_io.bytes_sent - self.last_net_io.bytes_sent) / time_delta
                recv_bytes = (current_net_io.bytes_recv - self.last_net_io.bytes_recv) / time_delta
                self.metrics.network_sent = sent_bytes / (1024**2)  # MB/s
                self.metrics.network_recv = recv_bytes / (1024**2)  # MB/s
            
            # System uptime
            uptime_seconds = time.time() - psutil.boot_time()
            hours, remainder = divmod(uptime_seconds, 3600)
            minutes, _ = divmod(remainder, 60)
            self.metrics.uptime = f"{int(hours)}h {int(minutes)}m"
            
            # Temperature (if available)
            try:
                temps = psutil.sensors_temperatures()
                if temps:
                    # Try to find CPU temperature
                    for name, entries in temps.items():
                        if 'coretemp' in name.lower() or 'cpu' in name.lower():
                            if entries:
                                self.metrics.temperature = entries[0].current
                                break
            except:
                pass
            
            # Update reference values
            self.last_disk_io = current_disk_io
            self.last_net_io = current_net_io
            self.last_time = current_time
            
        except Exception as e:
            logger.error(f"Error updating metrics: {e}")

class PopOsDashboard:
    """Professional Pop-OS Optimizer Dashboard"""
    
    def __init__(self):
        self.monitor = SystemMonitor()
        self.optimization_status = OptimizationStatus()
        self.backup_dir = Path("backups")
        self.backup_dir.mkdir(exist_ok=True)
        self.running = True
        self.refresh_rate = 2  # seconds
        

    
    def run_command(self, command: List[str], check: bool = True, capture_output: bool = True) -> subprocess.CompletedProcess:
        """Run command with error handling"""
        try:
            result = subprocess.run(
                command, 
                check=check, 
                capture_output=capture_output, 
                text=True,
                timeout=30
            )
            return result
        except subprocess.CalledProcessError as e:
            logger.error(f"Command failed: {' '.join(command)}")
            if e.stderr:
                logger.error(f"Error: {e.stderr}")
            raise
        except subprocess.TimeoutExpired:
            logger.error(f"Command timed out: {' '.join(command)}")
            raise
    
    def check_optimization_status(self):
        """Check current optimization status"""
        try:
            # Check CPU boost
            boost_path = Path("/sys/devices/system/cpu/cpufreq/boost")
            if boost_path.exists():
                self.optimization_status.cpu_boost = boost_path.read_text().strip() == "1"
            
            # Check CPU governor
            gov_path = Path("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor")
            if gov_path.exists():
                self.optimization_status.cpu_governor = gov_path.read_text().strip()
            
            # Check memory optimizations
            try:
                sysctl_output = self.run_command(["sysctl", "vm.swappiness"], capture_output=True)
                if "vm.swappiness = 10" in sysctl_output.stdout:
                    self.optimization_status.memory_optimized = True
            except:
                pass
            
            # Check SSD TRIM
            try:
                result = self.run_command(["systemctl", "is-enabled", "fstrim.timer"], capture_output=True)
                self.optimization_status.ssd_optimized = result.returncode == 0
            except:
                pass
                
            # Check desktop optimizations (simplified)
            try:
                result = self.run_command(["gsettings", "get", "org.gnome.desktop.interface", "enable-animations"], capture_output=True)
                self.optimization_status.desktop_optimized = "false" in result.stdout.lower()
            except:
                pass
            
        except Exception as e:
            logger.error(f"Error checking optimization status: {e}")
    
    def create_system_metrics_panel(self) -> Panel:
        """Create beautiful system metrics panel"""
        self.monitor.update_metrics()
        metrics = self.metrics
        
        # Create main table
        table = Table(show_header=False, box=box.ROUNDED, padding=(0, 1))
        table.add_column("Metric", style="cyan", min_width=15)
        table.add_column("Value", style="white", min_width=20)
        table.add_column("Status", style="white", min_width=15)
        
        # CPU Section
        cpu_color = "error" if metrics.cpu_percent > 80 else "warning" if metrics.cpu_percent > 60 else "success"
        cpu_bar = self.create_progress_bar(metrics.cpu_percent, 100)
        table.add_row(
            "🔥 CPU Usage", 
            f"[{cpu_color}]{metrics.cpu_percent:.1f}%[/{cpu_color}]",
            cpu_bar
        )
        
        table.add_row(
            "⚡ CPU Frequency", 
            f"{metrics.cpu_freq:.0f} MHz",
            f"({metrics.cpu_cores} cores)"
        )
        
        if metrics.load_avg:
            load_color = "error" if metrics.load_avg[0] > metrics.cpu_cores else "warning" if metrics.load_avg[0] > metrics.cpu_cores * 0.7 else "success"
            table.add_row(
                "📊 Load Average",
                f"[{load_color}]{metrics.load_avg[0]:.2f}[/{load_color}]",
                f"{metrics.load_avg[1]:.2f} {metrics.load_avg[2]:.2f}"
            )
        
        # Temperature
        if metrics.temperature:
            temp_color = "error" if metrics.temperature > 80 else "warning" if metrics.temperature > 65 else "success"
            table.add_row(
                "🌡️ Temperature",
                f"[{temp_color}]{metrics.temperature:.1f}°C[/{temp_color}]",
                ""
            )
        
        table.add_row("", "", "")  # Spacer
        
        # Memory Section
        mem_color = "error" if metrics.memory_percent > 80 else "warning" if metrics.memory_percent > 60 else "success"
        mem_bar = self.create_progress_bar(metrics.memory_percent, 100)
        table.add_row(
            "💾 Memory",
            f"[{mem_color}]{metrics.memory_percent:.1f}%[/{mem_color}]",
            mem_bar
        )
        
        table.add_row(
            "📏 Memory Size",
            f"{metrics.memory_available:.1f}GB free",
            f"/ {metrics.memory_total:.1f}GB total"
        )
        
        swap_color = "error" if metrics.swap_percent > 10 else "success"
        swap_bar = self.create_progress_bar(metrics.swap_percent, 100)
        table.add_row(
            "🔄 Swap Usage",
            f"[{swap_color}]{metrics.swap_percent:.1f}%[/{swap_color}]",
            swap_bar
        )
        
        table.add_row("", "", "")  # Spacer
        
        # Storage & Network
        disk_color = "error" if metrics.disk_usage > 90 else "warning" if metrics.disk_usage > 75 else "success"
        disk_bar = self.create_progress_bar(metrics.disk_usage, 100)
        table.add_row(
            "💿 Disk Usage",
            f"[{disk_color}]{metrics.disk_usage:.1f}%[/{disk_color}]",
            disk_bar
        )
        
        table.add_row(
            "📖 Disk I/O",
            f"R: {metrics.disk_read_speed:.1f} MB/s",
            f"W: {metrics.disk_write_speed:.1f} MB/s"
        )
        
        table.add_row(
            "🌐 Network I/O",
            f"↓ {metrics.network_recv:.1f} MB/s",
            f"↑ {metrics.network_sent:.1f} MB/s"
        )
        
        table.add_row(
            "⏰ Uptime",
            metrics.uptime,
            ""
        )
        
        return Panel(
            table,
                    title="[cyan]📊 System Metrics[/cyan]",
        title_align="left",
        border_style="cyan"
        )
    
    def create_progress_bar(self, value: float, max_value: float, width: int = 10) -> str:
        """Create a simple progress bar"""
        percentage = min(value / max_value, 1.0)
        filled = int(percentage * width)
        bar = "█" * filled + "░" * (width - filled)
        
        if percentage > 0.8:
            color = "error"
        elif percentage > 0.6:
            color = "warning"
        else:
            color = "success"
            
        return f"[{color}]{bar}[/{color}]"
    
    def create_optimization_status_panel(self) -> Panel:
        """Create optimization status panel"""
        self.check_optimization_status()
        status = self.optimization_status
        
        table = Table(show_header=False, box=box.ROUNDED, padding=(0, 1))
        table.add_column("Feature", style="cyan", min_width=18)
        table.add_column("Status", style="white", min_width=15)
        table.add_column("Details", style="dim", min_width=20)
        
        # CPU Optimizations
        boost_status = "[success]✅ Enabled[/success]" if status.cpu_boost else "[error]❌ Disabled[/error]"
        table.add_row("🔥 CPU Boost", boost_status, "Performance enhancement")
        
        gov_color = "success" if status.cpu_governor == "performance" else "warning"
        table.add_row("⚡ CPU Governor", f"[{gov_color}]{status.cpu_governor}[/{gov_color}]", "Frequency scaling")
        
        # Memory Optimization
        mem_status = "[success]✅ Optimized[/success]" if status.memory_optimized else "[error]❌ Default[/error]"
        table.add_row("💾 Memory", mem_status, "Swappiness & caching")
        
        # SSD Optimization
        ssd_status = "[success]✅ Enabled[/success]" if status.ssd_optimized else "[error]❌ Disabled[/error]"
        table.add_row("💿 SSD TRIM", ssd_status, "Weekly maintenance")
        
        # Desktop Optimization
        desktop_status = "[success]✅ Optimized[/success]" if status.desktop_optimized else "[warning]⚠️ Default[/warning]"
        table.add_row("🖥️ Desktop", desktop_status, "Animations & effects")
        
        return Panel(
            table,
                    title="[cyan]⚙️ Optimization Status[/cyan]",
        title_align="left", 
        border_style="cyan"
        )
    
    def create_top_processes_panel(self) -> Panel:
        """Create top processes panel"""
        table = Table(show_header=True, box=box.ROUNDED, padding=(0, 1))
        table.add_column("PID", style="dim", width=8)
        table.add_column("Process", style="white", width=20)
        table.add_column("CPU%", style="yellow", width=8)
        table.add_column("Memory%", style="cyan", width=8)
        table.add_column("Status", style="dim", width=10)
        
        try:
            processes = []
            for proc in psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_percent', 'status']):
                try:
                    info = proc.info
                    if info and info.get('cpu_percent') is not None and info.get('cpu_percent', 0) > 0:
                        processes.append(info)
                except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                    pass
            
            # Sort by CPU usage
            processes.sort(key=lambda x: x.get('cpu_percent', 0) or 0, reverse=True)
            
            # Add processes to table (limit to top 8)
            for proc in processes[:8]:
                try:
                    name = proc.get('name', 'Unknown')[:18] + "..." if len(proc.get('name', '')) > 18 else proc.get('name', 'Unknown')
                    cpu_pct = proc.get('cpu_percent', 0) or 0
                    mem_pct = proc.get('memory_percent', 0) or 0
                    
                    cpu_color = "error" if cpu_pct > 50 else "warning" if cpu_pct > 20 else "success"
                    mem_color = "error" if mem_pct > 10 else "warning" if mem_pct > 5 else "success"
                    
                    table.add_row(
                        str(proc.get('pid', 'N/A')),
                        name,
                        f"[{cpu_color}]{cpu_pct:.1f}[/{cpu_color}]",
                        f"[{mem_color}]{mem_pct:.1f}[/{mem_color}]",
                        proc.get('status', 'unknown')
                    )
                except Exception:
                    # Skip problematic processes
                    continue
                    
            # If no processes found, add a default row
            if len(processes) == 0:
                table.add_row("N/A", "No active processes", "0.0", "0.0", "idle")
                
        except Exception as e:
            # Fallback in case of major error
            table.add_row("ERROR", f"Process error: {str(e)[:15]}...", "0.0", "0.0", "error")
        
        return Panel(
            table,
            title="[cyan]🔍 Top Processes[/cyan]",
            title_align="left",
            border_style="cyan"
        )
    
    @property
    def metrics(self):
        """Get current metrics"""
        return self.monitor.metrics
    
    def create_dashboard_layout(self) -> Layout:
        """Create the main dashboard layout"""
        layout = Layout()
        
        # Create main split
        layout.split_column(
            Layout(name="header", size=3),
            Layout(name="main"),
            Layout(name="footer", size=3)
        )
        
        # Split main into left and right
        layout["main"].split_row(
            Layout(name="left", ratio=2),
            Layout(name="right", ratio=1)
        )
        
        # Split left into metrics and optimization
        layout["left"].split_column(
            Layout(name="metrics"),
            Layout(name="optimization")
        )
        
        # Set the right side as processes
        layout["right"].name = "processes"
        
        return layout
    
    def create_header(self) -> Panel:
        """Create dashboard header"""
        title = Text("🚀 Pop-OS Optimizer Dashboard", style="bold cyan")
        subtitle = Text("Professional System Optimization Suite", style="dim")
        
        content = Align.center(
            Text.assemble(title, "\n", subtitle)
        )
        
        return Panel(
            content,
            style="cyan",
            box=box.HEAVY
        )
    
    def create_footer(self) -> Panel:
        """Create dashboard footer with controls"""
        controls = [
            "[bold cyan]Ctrl+C[/bold cyan] Quit",
            "[bold dim]Updates every 2 seconds[/bold dim]"
        ]
        
        content = Align.center(" │ ".join(controls))
        
        return Panel(
            content,
            style="dim",
            box=box.SIMPLE
        )
    
    def run_live_dashboard(self):
        """Run the live dashboard"""
        try:
            layout = self.create_dashboard_layout()
            
            # Set static elements
            layout["header"].update(self.create_header())
            layout["footer"].update(self.create_footer())
            
            # Initial update of dynamic panels
            self.monitor.update_metrics()
            self.check_optimization_status()
            layout["metrics"].update(self.create_system_metrics_panel())
            layout["optimization"].update(self.create_optimization_status_panel())
            layout["processes"].update(self.create_top_processes_panel())
            
            with Live(layout, refresh_per_second=1, screen=True) as live:
                while self.running:
                    try:
                        # Update metrics first
                        self.monitor.update_metrics()
                        self.check_optimization_status()
                        
                        # Update dynamic panels
                        layout["metrics"].update(self.create_system_metrics_panel())
                        layout["optimization"].update(self.create_optimization_status_panel())
                        layout["processes"].update(self.create_top_processes_panel())
                        
                        # Sleep for refresh rate
                        time.sleep(self.refresh_rate)
                        
                    except KeyboardInterrupt:
                        self.running = False
                        break
                    except Exception as e:
                        logger.error(f"Dashboard update error: {e}")
                        # Continue running even with errors
                        time.sleep(self.refresh_rate)
        except Exception as e:
            logger.error(f"Dashboard initialization error: {e}")
            console.print(f"[error]❌ Dashboard error: {e}[/error]")
            console.print("[warning]Try using --status or menu mode instead[/warning]")
    
    def create_backup_with_progress(self) -> Path:
        """Create backup with progress indication"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_path = self.backup_dir / f"optimization_backup_{timestamp}"
        backup_path.mkdir(exist_ok=True)
        
        backup_files = [
            ("/etc/default/grub", "grub.backup"),
            ("/etc/fstab", "fstab.backup"),
            ("/etc/sysctl.conf", "sysctl.backup"),
            ("/etc/systemd/system/set-cpu-governor.service", "cpu-governor.backup"),
        ]
        
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            BarColumn(),
            TaskProgressColumn(),
            console=console
        ) as progress:
            
            task = progress.add_task("Creating backup...", total=len(backup_files))
            
            for src, dst in backup_files:
                progress.update(task, description=f"Backing up {src}")
                try:
                    src_path = Path(src)
                    if src_path.exists():
                        shutil.copy2(src_path, backup_path / dst)
                        console.print(f"[success]✅ Backed up {src}[/success]")
                    else:
                        console.print(f"[warning]⚠️ Skipped {src} (not found)[/warning]")
                except Exception as e:
                    console.print(f"[error]❌ Failed to backup {src}: {e}[/error]")
                
                progress.advance(task)
                time.sleep(0.1)  # Small delay for visual effect
        
        console.print(f"[success]✅ Backup completed: {backup_path}[/success]")
        return backup_path
    
    def optimize_cpu_with_progress(self) -> bool:
        """Optimize CPU with progress indication"""
        console.print("[info]🔐 This operation requires sudo privileges.[/info]")
        console.print("[dim]You may be prompted for your password...[/dim]")
        
        try:
            # Enable CPU boost if available
            boost_path = Path("/sys/devices/system/cpu/cpufreq/boost")
            if boost_path.exists():
                try:
                    # Use a simpler approach without subprocess timeout issues
                    console.print("[info]Setting CPU boost...[/info]")
                    result = subprocess.run(
                        ["sudo", "tee", str(boost_path)], 
                        input="1\n", 
                        text=True, 
                        capture_output=True, 
                        timeout=10
                    )
                    if result.returncode == 0:
                        console.print("[success]✅ CPU boost enabled[/success]")
                    else:
                        console.print("[warning]⚠️ CPU boost could not be enabled[/warning]")
                except subprocess.TimeoutExpired:
                    console.print("[warning]⚠️ CPU boost operation timed out[/warning]")
                except Exception:
                    console.print("[warning]⚠️ CPU boost not supported[/warning]")
            
            # Set performance governor
            console.print("[info]Setting CPU governor to performance...[/info]")
            gov_files = list(Path("/sys/devices/system/cpu").glob("cpu*/cpufreq/scaling_governor"))
            success_count = 0
            
            for gov_file in gov_files[:4]:  # Limit to first 4 cores to avoid too many prompts
                try:
                    result = subprocess.run(
                        ["sudo", "tee", str(gov_file)], 
                        input="performance\n", 
                        text=True, 
                        capture_output=True, 
                        timeout=10
                    )
                    if result.returncode == 0:
                        success_count += 1
                except subprocess.TimeoutExpired:
                    console.print(f"[warning]⚠️ Timeout setting governor for {gov_file.name}[/warning]")
                    break
                except Exception:
                    pass
            
            if success_count > 0:
                console.print(f"[success]✅ Performance governor set for {success_count} cores[/success]")
                console.print("[info]Note: Some cores may require manual configuration[/info]")
            else:
                console.print("[warning]⚠️ Could not set performance governor[/warning]")
                console.print("[info]Try using the bash script for full optimization[/info]")
            
            return success_count > 0
            
        except Exception as e:
            console.print(f"[error]❌ CPU optimization failed: {e}[/error]")
            return False
    
    def optimize_memory_with_progress(self) -> bool:
        """Optimize memory with progress indication"""
        console.print("[info]🔐 This operation requires sudo privileges.[/info]")
        console.print("[dim]You may be prompted for your password...[/dim]")
        
        sysctl_settings = [
            "vm.swappiness=10",
            "vm.vfs_cache_pressure=50",
            "vm.dirty_ratio=20",
            "vm.dirty_background_ratio=10",
            "vm.page-cluster=0"
        ]
        
        success_count = 0
        
        for setting in sysctl_settings:
            console.print(f"[info]Applying {setting}...[/info]")
            try:
                result = subprocess.run(
                    ["sudo", "sysctl", "-w", setting], 
                    capture_output=True, 
                    text=True, 
                    timeout=10
                )
                if result.returncode == 0:
                    console.print(f"[success]✅ Applied: {setting}[/success]")
                    success_count += 1
                else:
                    console.print(f"[warning]⚠️ Failed to apply {setting}: {result.stderr}[/warning]")
            except subprocess.TimeoutExpired:
                console.print(f"[warning]⚠️ Timeout applying {setting}[/warning]")
                break
            except Exception as e:
                console.print(f"[warning]⚠️ Failed to apply {setting}: {e}[/warning]")
        
        if success_count > 0:
            console.print(f"[success]✅ Applied {success_count}/{len(sysctl_settings)} memory optimizations[/success]")
        else:
            console.print("[warning]⚠️ No memory optimizations could be applied[/warning]")
        
        return success_count > 0
    
    def optimize_ssd_with_progress(self) -> bool:
        """Optimize SSD with progress indication"""
        console.print("[info]🔐 This operation requires sudo privileges.[/info]")
        console.print("[dim]Optimizing SSD performance and longevity...[/dim]")
        
        success_count = 0
        
        try:
            # Enable TRIM
            console.print("[info]Enabling automatic TRIM...[/info]")
            result = subprocess.run(
                ["sudo", "systemctl", "enable", "fstrim.timer"], 
                capture_output=True, 
                text=True, 
                timeout=10
            )
            if result.returncode == 0:
                console.print("[success]✅ Automatic TRIM enabled[/success]")
                success_count += 1
            else:
                console.print("[warning]⚠️ Could not enable TRIM[/warning]")
            
            # Set I/O scheduler for NVMe drives
            console.print("[info]Setting I/O scheduler for NVMe drives...[/info]")
            nvme_drives = list(Path("/sys/block").glob("nvme*"))
            for drive in nvme_drives:
                try:
                    scheduler_path = drive / "queue" / "scheduler"
                    if scheduler_path.exists():
                        result = subprocess.run(
                            ["sudo", "tee", str(scheduler_path)], 
                            input="mq-deadline\n", 
                            text=True, 
                            capture_output=True, 
                            timeout=5
                        )
                        if result.returncode == 0:
                            console.print(f"[success]✅ Set mq-deadline scheduler for {drive.name}[/success]")
                            success_count += 1
                except Exception:
                    pass
            
            console.print(f"[success]✅ SSD optimization completed ({success_count} operations)[/success]")
            return success_count > 0
            
        except Exception as e:
            console.print(f"[error]❌ SSD optimization failed: {e}[/error]")
            return False
    
    def optimize_desktop_with_progress(self) -> bool:
        """Optimize desktop with progress indication"""
        console.print("[info]Optimizing desktop environment...[/info]")
        
        success_count = 0
        
        try:
            # Disable animations
            console.print("[info]Disabling desktop animations...[/info]")
            result = subprocess.run(
                ["gsettings", "set", "org.gnome.desktop.interface", "enable-animations", "false"], 
                capture_output=True, 
                text=True, 
                timeout=5
            )
            if result.returncode == 0:
                console.print("[success]✅ Desktop animations disabled[/success]")
                success_count += 1
            
            # Set number of workspaces
            console.print("[info]Setting workspace configuration...[/info]")
            result = subprocess.run(
                ["gsettings", "set", "org.gnome.mutter", "dynamic-workspaces", "false"], 
                capture_output=True, 
                text=True, 
                timeout=5
            )
            if result.returncode == 0:
                result = subprocess.run(
                    ["gsettings", "set", "org.gnome.desktop.wm.preferences", "num-workspaces", "6"], 
                    capture_output=True, 
                    text=True, 
                    timeout=5
                )
                if result.returncode == 0:
                    console.print("[success]✅ Workspace configuration optimized[/success]")
                    success_count += 1
            
            console.print(f"[success]✅ Desktop optimization completed ({success_count} operations)[/success]")
            return success_count > 0
            
        except Exception as e:
            console.print(f"[error]❌ Desktop optimization failed: {e}[/error]")
            return False
    
    def optimize_services_with_progress(self) -> bool:
        """Optimize services with progress indication"""
        console.print("[info]🔐 This operation requires sudo privileges.[/info]")
        console.print("[dim]Disabling unnecessary services...[/dim]")
        
        services_to_disable = [
            "cups-browsed.service",
            "avahi-daemon.service"
        ]
        
        success_count = 0
        
        for service in services_to_disable:
            try:
                console.print(f"[info]Disabling {service}...[/info]")
                result = subprocess.run(
                    ["sudo", "systemctl", "disable", service], 
                    capture_output=True, 
                    text=True, 
                    timeout=10
                )
                if result.returncode == 0:
                    console.print(f"[success]✅ Disabled {service}[/success]")
                    success_count += 1
                else:
                    console.print(f"[warning]⚠️ Could not disable {service}[/warning]")
            except Exception:
                console.print(f"[warning]⚠️ Error disabling {service}[/warning]")
        
        console.print(f"[success]✅ Services optimization completed ({success_count} services)[/success]")
        return success_count > 0
    
    def run_script_with_progress(self, script_name: str, description: str) -> bool:
        """Run a bash script with progress indication"""
        console.print(f"[info]Running {description}...[/info]")
        console.print("[dim]This will execute the corresponding bash script[/dim]")
        
        try:
            result = subprocess.run(
                ["bash", f"scripts/{script_name}"], 
                cwd=Path.cwd(),
                timeout=300  # 5 minutes timeout
            )
            if result.returncode == 0:
                console.print(f"[success]✅ {description} completed successfully[/success]")
                return True
            else:
                console.print(f"[warning]⚠️ {description} completed with warnings[/warning]")
                return False
        except subprocess.TimeoutExpired:
            console.print(f"[error]❌ {description} timed out[/error]")
            return False
        except Exception as e:
            console.print(f"[error]❌ {description} failed: {e}[/error]")
            return False
    
    def interactive_menu(self):
        """Modern interactive menu"""
        while True:
            console.clear()
            
            # Header
            console.print(Panel.fit(
                "[bold cyan]🚀 Pop-OS Optimizer Dashboard[/bold cyan]\n"
                "[dim]Professional System Optimization Suite[/dim]",
                border_style="cyan"
            ))
            
            # Quick status overview
            self.monitor.update_metrics()
            self.check_optimization_status()
            
            metrics = self.metrics
            status = self.optimization_status
            
            # Create quick status table
            status_table = Table(show_header=False, box=None, padding=(0, 2))
            status_table.add_column("", style="cyan")
            status_table.add_column("", style="white")
            
            cpu_status = f"[success]{metrics.cpu_percent:.1f}%[/success]" if metrics.cpu_percent < 80 else f"[error]{metrics.cpu_percent:.1f}%[/error]"
            mem_status = f"[success]{metrics.memory_percent:.1f}%[/success]" if metrics.memory_percent < 80 else f"[error]{metrics.memory_percent:.1f}%[/error]"
            
            status_table.add_row("🔥 CPU:", cpu_status)
            status_table.add_row("💾 Memory:", mem_status)
            status_table.add_row("⚡ Governor:", status.cpu_governor)
            status_table.add_row("⏰ Uptime:", metrics.uptime)
            
            console.print(Panel(status_table, title="[cyan]Quick Status[/cyan]", title_align="left"))
            
            # Menu options
            console.print("\n[bold cyan]📋 MENU OPTIONS:[/bold cyan]")
            
            menu_options = [
                ("1", "🔴 Live Dashboard", "Real-time system monitoring"),
                ("2", "📁 Create Backup", "Backup system configurations"),
                ("3", "🔥 Optimize CPU", "CPU boost and governor settings"),
                ("4", "💾 Optimize Memory", "Memory and swap optimization"),
                ("5", "💿 Optimize SSD", "TRIM and I/O scheduler optimization"),
                ("6", "🖥️ Optimize Desktop", "Animations and desktop settings"),
                ("7", "⚙️ Optimize Services", "Disable unnecessary services"),
                ("8", "🚀 Optimize Boot", "GRUB and boot time optimization"),
                ("9", "📦 Install Software", "Install development tools"),
                ("10", "📊 Setup Monitoring", "Install monitoring tools"),
                ("11", "⚡ Full Optimization", "Complete system optimization"),
                ("12", "🔍 Hardware Validation", "Check hardware compatibility"),
                ("13", "📖 System Information", "Detailed system information"),
                ("14", "⚙️ Configuration Presets", "Select optimization presets"),
                ("15", "📚 View Documentation", "Show README and documentation"),
                ("16", "🔄 Restore Backup", "Restore from previous backup"),
                ("0", "👋 Exit", "Exit the application")
            ]
            
            for key, title, desc in menu_options:
                console.print(f"  [{key}] [bold]{title}[/bold] - [dim]{desc}[/dim]")
            
            choice = Prompt.ask("\n[bold cyan]Select option[/bold cyan]", default="1")
            
            if choice == "1":
                console.print("[info]Starting live dashboard... Press Ctrl+C to return[/info]")
                time.sleep(1)
                try:
                    self.running = True  # Reset running state
                    self.run_live_dashboard()
                except KeyboardInterrupt:
                    console.print("\n[info]Returning to menu...[/info]")
                    time.sleep(1)
                    
            elif choice == "2":
                self.create_backup_with_progress()
                Prompt.ask("\nPress Enter to continue")
                
            elif choice == "3":
                self.optimize_cpu_with_progress()
                Prompt.ask("\nPress Enter to continue")
                
            elif choice == "4":
                self.optimize_memory_with_progress()
                Prompt.ask("\nPress Enter to continue")
                
            elif choice == "5":
                self.optimize_ssd_with_progress()
                Prompt.ask("\nPress Enter to continue")
                
            elif choice == "6":
                self.optimize_desktop_with_progress()
                Prompt.ask("\nPress Enter to continue")
                
            elif choice == "7":
                self.optimize_services_with_progress()
                Prompt.ask("\nPress Enter to continue")
                
            elif choice == "8":
                self.run_script_with_progress("optimize_boot.sh", "Boot optimization")
                Prompt.ask("\nPress Enter to continue")
                
            elif choice == "9":
                self.run_script_with_progress("install_software_stack.sh", "Software installation")
                Prompt.ask("\nPress Enter to continue")
                
            elif choice == "10":
                self.run_script_with_progress("setup_monitoring.sh", "Monitoring tools setup")
                Prompt.ask("\nPress Enter to continue")
                
            elif choice == "11":
                if Confirm.ask("[warning]Run full optimization? This will modify system settings[/warning]"):
                    console.print("[info]Running full optimization...[/info]")
                    self.create_backup_with_progress()
                    self.optimize_cpu_with_progress()
                    self.optimize_memory_with_progress()
                    self.optimize_ssd_with_progress()
                    self.optimize_desktop_with_progress()
                    self.optimize_services_with_progress()
                    console.print("[success]✅ Full optimization completed![/success]")
                Prompt.ask("\nPress Enter to continue")
                
            elif choice == "12":
                console.print("[info]Running hardware validation...[/info]")
                subprocess.run(["bash", "scripts/hardware_validator.sh"])
                Prompt.ask("\nPress Enter to continue")
                
            elif choice == "13":
                self.show_detailed_system_info()
                Prompt.ask("\nPress Enter to continue")
                
            elif choice == "14":
                self.configuration_presets_menu()
                Prompt.ask("\nPress Enter to continue")
                
            elif choice == "15":
                self.show_documentation()
                Prompt.ask("\nPress Enter to continue")
                
            elif choice == "16":
                console.print("[info]Available backups:[/info]")
                try:
                    backup_dir = Path("backups")
                    if backup_dir.exists():
                        backups = list(backup_dir.glob("backup_*.tar.gz"))
                        if backups:
                            for i, backup in enumerate(sorted(backups)[-5:], 1):  # Show last 5
                                console.print(f"  [{i}] {backup.name}")
                            
                            backup_choice = Prompt.ask("\nSelect backup number to restore (or 0 to cancel)", default="0")
                            if backup_choice != "0" and backup_choice.isdigit():
                                idx = int(backup_choice) - 1
                                if 0 <= idx < len(backups):
                                    if Confirm.ask(f"[warning]Restore backup {backups[idx].name}?[/warning]"):
                                        self.run_script_with_progress("backup_safety.sh", f"Restore backup {backups[idx].name}")
                        else:
                            console.print("[warning]No backups found[/warning]")
                    else:
                        console.print("[warning]Backup directory not found[/warning]")
                except Exception as e:
                    console.print(f"[error]❌ Error listing backups: {e}[/error]")
                Prompt.ask("\nPress Enter to continue")
                
            elif choice == "0":
                console.print("[success]👋 Goodbye![/success]")
                break
                
            else:
                console.print("[error]❌ Invalid option[/error]")
                time.sleep(1)
    
    def show_detailed_system_info(self):
        """Show detailed system information"""
        console.clear()
        
        # System info
        info_table = Table(show_header=False, box=box.ROUNDED, padding=(0, 1))
        info_table.add_column("Property", style="cyan", min_width=20)
        info_table.add_column("Value", style="white")
        
        # CPU info
        try:
            cpu_info = self.run_command(["lscpu"], capture_output=True)
            for line in cpu_info.stdout.splitlines():
                if "Model name:" in line:
                    cpu_model = line.split(":", 1)[1].strip()
                    info_table.add_row("🔥 CPU Model", cpu_model)
                elif "CPU MHz:" in line:
                    cpu_mhz = line.split(":", 1)[1].strip()
                    info_table.add_row("⚡ CPU Frequency", f"{cpu_mhz} MHz")
        except:
            pass
        
        # Memory info
        memory = psutil.virtual_memory()
        info_table.add_row("💾 Total Memory", f"{memory.total / (1024**3):.1f} GB")
        info_table.add_row("💾 Available Memory", f"{memory.available / (1024**3):.1f} GB")
        
        # Disk info
        try:
            disk_info = self.run_command(["lsblk", "-d", "-o", "NAME,SIZE,MODEL"], capture_output=True)
            console.print(Panel(info_table, title="[cyan]💻 System Information[/cyan]"))
            console.print(Panel(disk_info.stdout, title="[cyan]💿 Storage Devices[/cyan]"))
        except:
            console.print(Panel(info_table, title="[cyan]💻 System Information[/cyan]"))

    def get_current_preset(self):
        """Get current preset from config file"""
        try:
            config_path = Path("scripts/config.sh")
            if config_path.exists():
                with open(config_path, 'r') as f:
                    for line in f:
                        if line.strip().startswith('PRESET='):
                            preset = line.split('=')[1].strip().strip('"')
                            return preset
        except:
            pass
        return "unknown"

    def set_preset(self, preset_name):
        """Set preset in config file"""
        try:
            config_path = Path("scripts/config.sh")
            if config_path.exists():
                with open(config_path, 'r') as f:
                    content = f.read()
                
                # Replace the PRESET line
                import re
                content = re.sub(r'^PRESET=.*$', f'PRESET="{preset_name}"', content, flags=re.MULTILINE)
                
                with open(config_path, 'w') as f:
                    f.write(content)
                return True
        except Exception as e:
            console.print(f"[error]❌ Error setting preset: {e}[/error]")
        return False

    def show_documentation(self):
        """Show documentation and README"""
        console.clear()
        
        try:
            readme_path = Path("README.md")
            if readme_path.exists():
                with open(readme_path, 'r') as f:
                    content = f.read()
                
                # Display README content
                console.print(Panel.fit(
                    "[bold cyan]📖 Documentation[/bold cyan]",
                    border_style="cyan"
                ))
                
                # Show first part of README
                lines = content.split('\n')[:30]  # First 30 lines
                readme_text = '\n'.join(lines)
                
                console.print(Panel(readme_text, title="[cyan]README.md[/cyan]"))
                
            changelog_path = Path("docs/CHANGELOG.md")
            if changelog_path.exists():
                with open(changelog_path, 'r') as f:
                    content = f.read()
                
                lines = content.split('\n')[:20]  # First 20 lines
                changelog_text = '\n'.join(lines)
                
                console.print(Panel(changelog_text, title="[cyan]CHANGELOG.md[/cyan]"))
                
        except Exception as e:
            console.print(f"[error]❌ Error reading documentation: {e}[/error]")

    def configuration_presets_menu(self):
        """Configuration presets management menu"""
        console.clear()
        
        current_preset = self.get_current_preset()
        
        # Header
        console.print(Panel.fit(
            "[bold cyan]⚙️ Configuration Presets[/bold cyan]\n"
            f"[dim]Current preset: {current_preset}[/dim]",
            border_style="cyan"
        ))
        
        # Preset descriptions
        presets = {
            "working": {
                "name": "🖥️  Working",
                "desc": "Optimized for development and office work",
                "details": [
                    "• Performance CPU governor",
                    "• Moderate memory settings", 
                    "• Development tools included",
                    "• Desktop animations disabled"
                ]
            },
            "gaming": {
                "name": "🎮 Gaming", 
                "desc": "Optimized for maximum gaming performance",
                "details": [
                    "• Performance CPU governor",
                    "• Aggressive memory settings",
                    "• Gaming tools included", 
                    "• Minimal background services"
                ]
            },
            "server": {
                "name": "🖥️  Server",
                "desc": "Optimized for server/headless environments",
                "details": [
                    "• Balanced CPU for server workloads",
                    "• Large network buffers",
                    "• Server tools included",
                    "• Desktop services disabled"
                ]
            },
            "conservative": {
                "name": "🛡️  Conservative",
                "desc": "Minimal, safe optimizations",
                "details": [
                    "• Safe CPU settings",
                    "• Minimal system changes",
                    "• Essential tools only",
                    "• Maximum compatibility"
                ]
            },
            "custom": {
                "name": "⚙️  Custom",
                "desc": "Manual configuration of all settings",
                "details": [
                    "• Configure each option manually",
                    "• Full control over optimizations",
                    "• Advanced users only"
                ]
            }
        }
        
        console.print("\n[bold cyan]📋 Available Presets:[/bold cyan]\n")
        
        for i, (preset_key, preset_info) in enumerate(presets.items(), 1):
            status = " [bold green](Current)[/bold green]" if preset_key == current_preset else ""
            console.print(f"[bold cyan]{i}.[/bold cyan] {preset_info['name']}{status}")
            console.print(f"   [dim]{preset_info['desc']}[/dim]")
            for detail in preset_info['details']:
                console.print(f"   [dim]{detail}[/dim]")
            console.print()
        
        console.print("[bold cyan]0.[/bold cyan] [bold]Return to main menu[/bold]")
        
        choice = Prompt.ask("\n[bold cyan]Select preset[/bold cyan]", default="0")
        
        preset_list = list(presets.keys())
        
        if choice == "0":
            return
        
        try:
            preset_index = int(choice) - 1
            if 0 <= preset_index < len(preset_list):
                selected_preset = preset_list[preset_index]
                
                if selected_preset == current_preset:
                    console.print(f"[info]ℹ️ Preset '{selected_preset}' is already selected[/info]")
                    return
                
                if Confirm.ask(f"[warning]Apply '{selected_preset}' preset?[/warning]"):
                    if self.set_preset(selected_preset):
                        console.print(f"[success]✅ Preset changed to '{selected_preset}'[/success]")
                        console.print("[info]ℹ️ Restart the application for changes to take effect[/info]")
                    else:
                        console.print("[error]❌ Failed to change preset[/error]")
            else:
                console.print("[error]❌ Invalid preset selection[/error]")
        except ValueError:
            console.print("[error]❌ Invalid input[/error]")

def main():
    """Main application entry point"""
    parser = argparse.ArgumentParser(description="Pop-OS Optimizer Dashboard - Professional Edition")
    parser.add_argument("--dashboard", action="store_true", help="Start live dashboard directly")
    parser.add_argument("--optimize", action="store_true", help="Run full optimization")
    parser.add_argument("--backup", action="store_true", help="Create backup only")
    parser.add_argument("--status", action="store_true", help="Show status only")
    
    args = parser.parse_args()
    
    dashboard = PopOsDashboard()
    
    if args.backup:
        dashboard.create_backup_with_progress()
    elif args.optimize:
        console.print("[info]🚀 Running full optimization...[/info]")
        dashboard.create_backup_with_progress()
        dashboard.optimize_cpu_with_progress()
        dashboard.optimize_memory_with_progress()
        console.print("[success]✅ Full optimization completed![/success]")
    elif args.status:
        dashboard.monitor.update_metrics()
        dashboard.check_optimization_status()
        console.print(dashboard.create_system_metrics_panel())
        console.print(dashboard.create_optimization_status_panel())
    elif args.dashboard:
        dashboard.run_live_dashboard()
    else:
        dashboard.interactive_menu()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        console.print("\n[info]👋 Interrupted by user[/info]")
        sys.exit(0)
    except Exception as e:
        logger.error(f"Fatal error: {e}")
        console.print("❌ Fatal error:", str(e))
        sys.exit(1) 