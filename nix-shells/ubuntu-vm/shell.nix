{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Core QEMU/KVM packages
    qemu
    qemu_kvm
    libvirt
    virt-manager

    # GUI management tools
    virt-manager
    virt-viewer
    spice-gtk
    spice-protocol
    
    # Firmware and utilities
    OVMF  # UEFI firmware
    bridge-utils
    iptables
    dnsmasq
    
    # Additional useful tools
    virtiofsd  # For better shared folder performance
    swtpm  # Virtual TPM emulator if needed

    # Networking
    iproute2
    iptables
    openssl
    dnsmasq
  ];

  # Environment variables
  shellHook = ''
    # Ensure libvirtd socket is accessible if running
    export LIBVIRT_DEFAULT_URI="qemu:///system"
  
    # Define VM directory
    VM_DIR=''${VM_DIR:-"$HOME/.local/share/qemu-vms"}
    mkdir -p "$VM_DIR"
    
    # Create disk if it doesn't exist
    VM_DISK="$VM_DIR/ubuntu-disk.qcow2"
    if [ ! -f "$VM_DISK" ]; then
      echo "Creating new VM disk at $VM_DISK"
      qemu-img create -f qcow2 "$VM_DISK" 30G
    fi
    
    # Create shared directory
    VM_SHARED="$VM_DIR/shared"
    mkdir -p "$VM_SHARED"
    
    # Function to start VM
    start_ubuntu_vm() {
      local iso_path="$1"
      local cdrom_option=""
      
      # If ISO path provided, add cdrom option
      if [ -n "$iso_path" ]; then
        if [ -f "$iso_path" ]; then
          cdrom_option="-cdrom $iso_path"
          echo "Booting with ISO: $iso_path"
        else
          echo "Warning: ISO file not found at $iso_path"
          return 1
        fi
      fi

      # Find the wireless interface that has the default route
      WIFI_INTERFACE=$(ip -o -4 route show to default | awk '{print $5}' | head -n1)
      echo "Using host wireless interface: $WIFI_INTERFACE"

      qemu-system-x86_64 \
        -m 4G \
        -smp 2 \
        -enable-kvm \
        -drive file="$VM_DISK",format=qcow2 \
        $cdrom_option \
        -device virtio-net-pci,netdev=net0 \
        -netdev user,id=net0,hostfwd=tcp::2222-:22,dns=8.8.8.8 \
        -virtfs local,path="$VM_SHARED",mount_tag=shared,security_model=mapped-file,id=shared
    }
  
    echo "VM environment ready!"
    echo "To launch VM without ISO: run 'start_ubuntu_vm'"
    echo "To launch VM with ISO: run 'start_ubuntu_vm /path/to/ubuntu.iso'"
    echo "VM data stored at: $VM_DIR"
    echo "Shared folder available at: $VM_SHARED"
  '';
}
