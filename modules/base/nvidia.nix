{ config, lib, pkgs, ... }:

{
  # Bootloader kernel parameters for NVIDIA
  boot.kernelParams = [
    "nvidia-drm.fbdev=1"  # Enable kernel mode setting for Wayland
  ];

  # Enable OpenGL/graphics hardware acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Support for 32-bit applications
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is required for Wayland compositors
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    # RTX 3080 is Ampere architecture, so this should work
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (recommended for RTX 30 series)
    # Support is available for Turing and later architectures including RTX 3080
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    open = true;

    # Enable the Nvidia settings menu, accessible via `nvidia-settings`
    nvidiaSettings = true;

    # Use the production driver package
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  # NVIDIA Container Toolkit for Docker/Podman GPU support
  hardware.nvidia-container-toolkit.enable = true;

  # Add useful NVIDIA-related packages
  environment.systemPackages = with pkgs; [
    config.hardware.nvidia.package.settings  # NVIDIA control panel
    nvtopPackages.nvidia  # GPU monitoring tool
    cudatoolkit       # CUDA development toolkit (optional)
    nvidia-vaapi-driver  # VAAPI driver for hardware video acceleration
  ];

  # Ensure proper GPU access for users
  users.users.luffy.extraGroups = [ "video" ];

  # Essential environment variables for NVIDIA + Hyprland
  environment.sessionVariables = {
    # NVIDIA driver for libva
    LIBVA_DRIVER_NAME = "nvidia";
    # NVIDIA driver for GLX
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # VA-API hardware video acceleration
    NVD_BACKEND = "direct";
    # Use NVIDIA DRM backend for GBM
    GBM_BACKEND = "nvidia-drm";
  };
}