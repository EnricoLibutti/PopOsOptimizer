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
    "accent": "bright_blue",
    "muted": "dim white"
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
        table.add_column("Metric", style="accent", min_width=15)
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
            title="[accent]📊 System Metrics[/accent]",
            title_align="left",
            border_style="accent"
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
        table.add_column("Feature", style="accent", min_width=18)
        table.add_column("Status", style="white", min_width=15)
        table.add_column("Details", style="muted", min_width=20)
        
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
            title="[accent]⚙️ Optimization Status[/accent]",
            title_align="left",
            border_style="accent"
        )
    
    def create_top_processes_panel(self) -> Panel:
        """Create top processes panel"""
        table = Table(show_header=True, box=box.ROUNDED, padding=(0, 1))
        table.add_column("PID", style="muted", width=8)
        table.add_column("Process", style="white", width=20)
        table.add_column("CPU%", style="yellow", width=8)
        table.add_column("Memory%", style="cyan", width=8)
        table.add_column("Status", style="muted", width=10)
        
        processes = []
        for proc in psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_percent', 'status']):
            try:
                info = proc.info
                if info['cpu_percent'] is not None and info['cpu_percent'] > 0:
                    processes.append(info)
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                pass
        
        # Sort by CPU usage
        processes.sort(key=lambda x: x['cpu_percent'] or 0, reverse=True)
        
        for proc in processes[:8]:  # Top 8 processes
            name = proc['name'][:18] + "..." if len(proc['name']) > 18 else proc['name']
            cpu_pct = proc['cpu_percent'] or 0
            mem_pct = proc['memory_percent'] or 0
            
            cpu_color = "error" if cpu_pct > 50 else "warning" if cpu_pct > 20 else "success"
            mem_color = "error" if mem_pct > 10 else "warning" if mem_pct > 5 else "success"
            
            table.add_row(
                str(proc['pid']),
                name,
                f"[{cpu_color}]{cpu_pct:.1f}[/{cpu_color}]",
                f"[{mem_color}]{mem_pct:.1f}[/{mem_color}]",
                proc['status'] or "unknown"
            )
        
        return Panel(
            table,
            title="[accent]🔍 Top Processes[/accent]",
            title_align="left",
            border_style="accent"
        )
    
    @property
    def metrics(self):
        """Get current metrics"""
        return self.monitor.metrics
    
    def create_dashboard_layout(self) -> Layout:
        """Create the main dashboard layout"""
        layout = Layout()
        
        layout.split_column(
            Layout(name="header", size=3),
            Layout(name="main"),
            Layout(name="footer", size=3)
        )
        
        layout["main"].split_row(
            Layout(name="left", ratio=2),
            Layout(name="right", ratio=1)
        )
        
        layout["left"].split_column(
            Layout(name="metrics"),
            Layout(name="optimization")
        )
        
        layout["right"].update(Layout(name="processes"))
        
        return layout
    
    def create_header(self) -> Panel:
        """Create dashboard header"""
        title = Text("🚀 Pop-OS Optimizer Dashboard", style="bold accent")
        subtitle = Text("Professional System Optimization Suite", style="muted")
        
        content = Align.center(
            Text.assemble(title, "\n", subtitle)
        )
        
        return Panel(
            content,
            style="accent",
            box=box.HEAVY
        )
    
    def create_footer(self) -> Panel:
        """Create dashboard footer with controls"""
        controls = [
            "[bold cyan]Q[/bold cyan] Quit",
            "[bold green]O[/bold green] Optimize",
            "[bold yellow]B[/bold yellow] Backup",
            "[bold magenta]M[/bold magenta] Menu",
            "[bold blue]R[/bold blue] Refresh"
        ]
        
        content = Align.center(" │ ".join(controls))
        
        return Panel(
            content,
            style="muted",
            box=box.SIMPLE
        )
    
    def run_live_dashboard(self):
        """Run the live dashboard"""
        layout = self.create_dashboard_layout()
        
        # Set static elements
        layout["header"].update(self.create_header())
        layout["footer"].update(self.create_footer())
        
        with Live(layout, refresh_per_second=1, screen=True) as live:
            while self.running:
                try:
                    # Update dynamic panels
                    layout["metrics"].update(self.create_system_metrics_panel())
                    layout["optimization"].update(self.create_optimization_status_panel())
                    layout["processes"].update(self.create_top_processes_panel())
                    
                    # Simple key detection (would need proper async handling in production)
                    time.sleep(self.refresh_rate)
                    
                except KeyboardInterrupt:
                    break
                except Exception as e:
                    logger.error(f"Dashboard error: {e}")
    
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
        with Status("Optimizing CPU settings...", spinner="dots", console=console):
            time.sleep(1)  # Simulation delay
            try:
                # Enable CPU boost if available
                boost_path = Path("/sys/devices/system/cpu/cpufreq/boost")
                if boost_path.exists():
                    try:
                        self.run_command(["sudo", "sh", "-c", "echo 1 > /sys/devices/system/cpu/cpufreq/boost"])
                        console.print("[success]✅ CPU boost enabled[/success]")
                    except:
                        console.print("[warning]⚠️ CPU boost not supported[/warning]")
                
                # Set performance governor
                gov_files = list(Path("/sys/devices/system/cpu").glob("cpu*/cpufreq/scaling_governor"))
                success_count = 0
                for gov_file in gov_files:
                    try:
                        self.run_command(["sudo", "sh", "-c", f"echo performance > {gov_file}"])
                        success_count += 1
                    except:
                        pass
                
                console.print(f"[success]✅ Performance governor set for {success_count}/{len(gov_files)} cores[/success]")
                return True
                
            except Exception as e:
                console.print(f"[error]❌ CPU optimization failed: {e}[/error]")
                return False
    
    def optimize_memory_with_progress(self) -> bool:
        """Optimize memory with progress indication"""
        sysctl_settings = [
            "vm.swappiness=10",
            "vm.vfs_cache_pressure=50",
            "vm.dirty_ratio=20",
            "vm.dirty_background_ratio=10",
            "vm.page-cluster=0"
        ]
        
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            BarColumn(),
            TaskProgressColumn(),
            console=console
        ) as progress:
            
            task = progress.add_task("Optimizing memory...", total=len(sysctl_settings))
            
            for setting in sysctl_settings:
                progress.update(task, description=f"Applying {setting}")
                try:
                    self.run_command(["sudo", "sysctl", "-w", setting])
                    console.print(f"[success]✅ Applied: {setting}[/success]")
                except Exception as e:
                    console.print(f"[warning]⚠️ Failed to apply {setting}: {e}[/warning]")
                
                progress.advance(task)
                time.sleep(0.1)
        
        return True
    
    def interactive_menu(self):
        """Modern interactive menu"""
        while True:
            console.clear()
            
            # Header
            console.print(Panel.fit(
                "[bold accent]🚀 Pop-OS Optimizer Dashboard[/bold accent]\n"
                "[muted]Professional System Optimization Suite[/muted]",
                border_style="accent"
            ))
            
            # Quick status overview
            self.monitor.update_metrics()
            self.check_optimization_status()
            
            metrics = self.metrics
            status = self.optimization_status
            
            # Create quick status table
            status_table = Table(show_header=False, box=None, padding=(0, 2))
            status_table.add_column("", style="accent")
            status_table.add_column("", style="white")
            
            cpu_status = f"[success]{metrics.cpu_percent:.1f}%[/success]" if metrics.cpu_percent < 80 else f"[error]{metrics.cpu_percent:.1f}%[/error]"
            mem_status = f"[success]{metrics.memory_percent:.1f}%[/success]" if metrics.memory_percent < 80 else f"[error]{metrics.memory_percent:.1f}%[/error]"
            
            status_table.add_row("🔥 CPU:", cpu_status)
            status_table.add_row("💾 Memory:", mem_status)
            status_table.add_row("⚡ Governor:", status.cpu_governor)
            status_table.add_row("⏰ Uptime:", metrics.uptime)
            
            console.print(Panel(status_table, title="[accent]Quick Status[/accent]", title_align="left"))
            
            # Menu options
            console.print("\n[bold accent]📋 MENU OPTIONS:[/bold accent]")
            
            menu_options = [
                ("1", "🔴 Live Dashboard", "Real-time system monitoring"),
                ("2", "📁 Create Backup", "Backup system configurations"),
                ("3", "🔥 Optimize CPU", "CPU boost and governor settings"),
                ("4", "💾 Optimize Memory", "Memory and swap optimization"),
                ("5", "⚡ Full Optimization", "Complete system optimization"),
                ("6", "📊 Hardware Validation", "Check hardware compatibility"),
                ("7", "🔍 System Information", "Detailed system information"),
                ("0", "👋 Exit", "Exit the application")
            ]
            
            for key, title, desc in menu_options:
                console.print(f"  [{key}] [bold]{title}[/bold] - [muted]{desc}[/muted]")
            
            choice = Prompt.ask("\n[bold cyan]Select option[/bold cyan]", default="1")
            
            if choice == "1":
                console.print("[info]Starting live dashboard... Press Ctrl+C to return[/info]")
                try:
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
                if Confirm.ask("[warning]Run full optimization? This will modify system settings[/warning]"):
                    console.print("[info]Running full optimization...[/info]")
                    self.create_backup_with_progress()
                    self.optimize_cpu_with_progress()
                    self.optimize_memory_with_progress()
                    console.print("[success]✅ Full optimization completed![/success]")
                Prompt.ask("\nPress Enter to continue")
                
            elif choice == "6":
                console.print("[info]Running hardware validation...[/info]")
                subprocess.run(["bash", "scripts/hardware_validator.sh"])
                Prompt.ask("\nPress Enter to continue")
                
            elif choice == "7":
                self.show_detailed_system_info()
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
        info_table.add_column("Property", style="accent", min_width=20)
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
            console.print(Panel(info_table, title="[accent]💻 System Information[/accent]"))
            console.print(Panel(disk_info.stdout, title="[accent]💿 Storage Devices[/accent]"))
        except:
            console.print(Panel(info_table, title="[accent]💻 System Information[/accent]"))

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
        console.print(f"[error]❌ Fatal error: {e}[/error]")
        sys.exit(1) 