{ config, pkgs, lib, ... }: {
  programs.btop = {
    enable = true;
    package = pkgs.btop.override { rocmSupport = true; };
      settings = {
        # ---- theme / appearance ----
        color_theme = "monokai";        # theme name, or "Default"/"TTY"
        theme_background = true;        # false = use terminal background
        truecolor = true;              # 24-bit colour; false = 256-colour
        force_tty = false;             # force 16-colour TTY mode
        vim_keys = false;              # hjkl navigation
        rounded_corners = true;

        # ---- graph symbols (per box: "default"|"braille"|"block"|"tty") ----
        graph_symbol = "braille";      # global default: braille|block|tty
        graph_symbol_cpu = "default";
        graph_symbol_gpu = "default";
        graph_symbol_mem = "default";
        graph_symbol_net = "default";
        graph_symbol_proc = "default";

        # ---- boxes / layout ----
        shown_boxes = "cpu gpu0 mem net proc";  # add gpu0..gpu5 to show GPUs
        presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
        update_ms = 2000;              # refresh interval (ms)

        # ---- process box ----
        proc_sorting = "cpu lazy";     # pid|program|arguments|threads|user|memory|cpu lazy|cpu direct
        proc_reversed = false;
        proc_tree = false;
        proc_colors = true;
        proc_gradient = true;
        proc_per_core = false;
        proc_mem_bytes = true;
        proc_cpu_graphs = true;
        proc_info_smaps = false;       # detailed mem via smaps (slower)
        proc_left = false;             # process box on left side
        proc_filter_kernel = false;    # hide kernel threads
        proc_aggregate = false;        # sum child threads into parent

        # ---- cpu box ----
        cpu_graph_upper = "Auto";      # Auto|total|user|system|iowait|...
        cpu_graph_lower = "Auto";
        cpu_invert_lower = true;
        cpu_single_graph = false;
        cpu_bottom = false;            # cpu box at bottom
        show_uptime = true;
        check_temp = true;
        cpu_sensor = "Auto";           # "Auto" or a specific hwmon sensor
        show_coretemp = true;
        cpu_core_map = "";             # remap core order, e.g. "0:0 1:2"
        temp_scale = "celsius";        # celsius|fahrenheit|kelvin|rankine
        base_10_sizes = false;         # KB=1000 vs 1024
        show_cpu_freq = true;
        clock_format = "%X";           # strftime; "" to disable
        background_update = true;
        custom_cpu_name = "";

        # ---- mem / disks box ----
        mem_graphs = true;
        mem_below_net = false;
        zfs_arc_cached = true;
        show_swap = true;
        swap_disk = true;
        show_disks = true;
        only_physical = true;
        use_fstab = true;              # mountpoints from /etc/fstab
        zfs_hidden = false;
        disk_free_priv = false;
        show_io_stat = true;
        io_mode = false;               # dedicated disk-IO view
        io_graph_combined = false;
        io_graph_speeds = "";          # e.g. "sda:100,nvme0n1:800"
        disks_filter = "";             # e.g. "exclude=/boot" or "/ /home"

        # ---- net box ----
        net_download = 100;            # fixed scale (Mib) if net_auto=false
        net_upload = 100;
        net_auto = true;               # auto-scale graphs
        net_sync = true;               # same scale up/down
        net_iface = "";                # "" = auto-detect

        # ---- battery ----
        show_battery = true;
        selected_battery = "Auto";
        show_battery_watt = true;

        # ---- GPU (needs rocmSupport build; AMD via ROCm SMI) ----
        show_gpu_info = "Auto";           # Auto|On|Off
        gpu_mirror_graph = true;          # mirror up/down GPU graph
        nvml_measure_pcie_speeds = true;  # NVIDIA only; harmless on AMD
        rsmi_measure_pcie_speeds = true;  # AMD/ROCm PCIe-speed measurement
        custom_gpu_name0 = "";            # override name (name0..name5)

        # ---- misc ----
        log_level = "WARNING";         # ERROR|WARNING|INFO|DEBUG
  };
};
}