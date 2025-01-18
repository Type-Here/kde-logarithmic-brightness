#!/bin/bash

# Variables
save_file="$(dirname "${0}")/save.cfg"
increase_val="Monitor Brightness Up,Monitor Brightness Up,Aumenta luminosità dello schermo"
decrease_val="Monitor Brightness Down,Monitor Brightness Down,Abbassa luminosità dello schermo"
down_group="python_BrDw.desktop"
up_group="python_BrUp.desktop"
desktop_path="${HOME}/.local/share/applications/"
set_default=false

# Show Help Menu
function show_help(){
    echo -e "\nRestore old Brightness Keys Behaviour"
    echo -e "More info: https://github.com/Type-Here/kde-logarithmic-brightness \n"
    echo "-h | --help : see this help"
    echo "-d | --default : don't read from 'save.cfg' file but use default values instead"
    echo ""
}

echo "Getting Plasma version..."

PLASMA_VERSION=$(plasmashell --version 2>/dev/null | grep -oE '[0-9]+' | head -1)

# Set commands based on version
if [[ "$PLASMA_VERSION" -ge 6 ]]; then
    KWRITECONFIG="kwriteconfig6"
    KREADCONFIG="kreadconfig6"
    KQUITAPP="kquitapp6"
    KGLOBALACCEL="kglobalaccel6"
    python_command_down="${python_command_down} -6"
    python_command_up="${python_command_up} -6"
    
elif [[ "$PLASMA_VERSION" -eq 5 ]]; then
    KWRITECONFIG="kwriteconfig5"
    KREADCONFIG="kreadconfig5"
    KQUITAPP="kquitapp5"
    KGLOBALACCEL="kglobalaccel5"
else
    echo "Plasma version non recognized."
    exit 1
fi


# ======= MAIN =========

# --- Menu ---
if [ $# -eq 0 ]; then
  echo "Executing Restore of Old Values";
elif [ "$1" == "-d" ] || [ "$1" == "--default" ]; then
    set_default=true
elif [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_help;
    exit 0;
else
    echo "Non valid Option.";
    show_help;
    exit 0;
fi


# Check if load old data from save file 'save.cfg' or using default set above
if [[ "${set_default}" == true ]]; then
    echo "Using default values";
elif [[ -f "${save_file}" ]]; then
        echo "Save File exists, reading old values from file"
        source "${save_file}"
else
  read -n 2 -r -p "No save file found, do you want to set default values? (Y/n) " response
  case $response in
      [yY'\n']) echo "Using default values";;
      [nN]) echo "Exiting..."; exit 0;;
      *) echo "Option non valid, exiting..."; exit 0;;
  esac
fi

# Print Chosen Values
echo "Dec: ${decrease_val}"
echo "Inc: ${increase_val}"

# Operating

echo "Removing Custom Values..."
$KWRITECONFIG --file kglobalshortcutsrc --group ${up_group} --key _k_friendly_name --delete
$KWRITECONFIG --file kglobalshortcutsrc --group ${up_group} --key _launch --delete

$KWRITECONFIG --file kglobalshortcutsrc --group ${down_group} --key _k_friendly_name --delete
$KWRITECONFIG --file kglobalshortcutsrc --group ${down_group} --key _launch --delete

rm "${desktop_path}${up_group}"
rm "${desktop_path}${down_group}"

echo "Add Old/Default Values..."
$KWRITECONFIG --file kglobalshortcutsrc --group org_kde_powerdevil --key "Decrease Screen Brightness" "${decrease_val}"
$KWRITECONFIG --file kglobalshortcutsrc --group org_kde_powerdevil --key "Increase Screen Brightness" "${increase_val}"

# Reload: in Arch (and maybe other distros) often fails: needed Reboot!
if [ "${XDG_SESSION_TYPE}" = "wayland" ]; then
  echo "Wayland Machine Detected: We'll try to reload shortcuts but you probably need a reboot" >&2
fi
echo "Reloading Shortcuts... Use CTRL+C if doesn't stop"
($KQUITAPP kglobalaccel && sleep 2s && $KGLOBALACCEL >/dev/null 2>&1 &) || >&2 echo "Error restarting kglobalaccel: Try rebooting to update shortcuts"