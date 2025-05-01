#!/bin/bash

# Usage statement 
show_help() {
    echo
    echo "Usage: $0 [-i] [-r]"
    echo "Options:"
    echo "  -i    Backup existing config and install drivers"
    echo "  -r    Restore original config and remove drivers"
    echo "  -h    Show this help message"
    echo
}

# If no arguments were passed, show usage 
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# Set some default vars 
pwd=$(pwd)
ran_task=false

# Parse params passed to script
while getopts ":irh" opt; do
    case $opt in
        i)
	    echo
	    echo "Backing up existing boot config..."
            sudo cp /boot/config.txt $pwd/original_files/config.txt.bak
	    echo
            echo "Installing GPI Case2W Drivers..."
	    sudo cp $pwd/patch_files/config.txt /boot/config.txt
            sudo cp $pwd/patch_files/overlays/dpi24.dtbo /boot/overlays/dpi24.dtbo
            sudo cp $pwd/patch_files/overlays/pwm-audio-pi-zero.dtbo /boot/overlays/pwm-audio-pi-zero.dtbo
            ran_task=true
            task=installed
            ;;
        r)
            echo "Removing modified config and drivers, replacing with originals..."
            sudo cp $pwd/original_files/config.txt /boot/config.txt
	    sudo rm -rf /boot/overlays/dpi24.dtbo
	    sudo rm -rf /boot/overlays/pwm-audio-pi-zero.dtbo
            ran_task=true
 	    task=removed
            ;;
        h)
            show_help
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            show_help
            exit 1
            ;;
    esac
done

# Ask to reboot if a task was run
if [ "$ran_task" = true ]; then
    echo 
    echo "Patches successfully $task."
    read -p "Would you like to reboot now to apply changes? (y/n): " answer
    echo
    case "$answer" in
        [Yy]* ) echo "Rebooting..."; sudo reboot;;
        * ) echo "Done.";;
    esac
fi
