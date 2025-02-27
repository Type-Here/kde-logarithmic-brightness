#!/bin/bash

# Show Help Menu
function show_help(){
    echo -e "\nSet new human-eye-friendly Brightness Keys Behaviour"
    echo -e "More info: https://github.com/Type-Here/kde-logarithmic-brightness \n"
    echo "-h | --help : see this help"
    echo "-l | log: force use logarithmic curve (exponential esp=0.4 is default)"
    echo ""
}

#Main Variables
script_dir="$(dirname "${0}")"
save_file="${script_dir}/save.cfg"
decrease_key="Decrease Screen Brightness"
increase_key="Increase Screen Brightness"

py_local_path="$(find "${script_dir}/.." -name __init__.py)"
py_abs_path="$(readlink -f "${py_local_path}")"
down_group="python_BrDw.desktop"
up_group="python_BrUp.desktop"
desktop_path="${HOME}/.local/share/applications/"
python_command_up="python ${py_abs_path} -i"
python_command_down="python ${py_abs_path} -d"

# ==== MAIN ====

# Get Plasma version
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
    echo "Plasma 6 detected"
elif [[ "$PLASMA_VERSION" -eq 5 ]]; then
    KWRITECONFIG="kwriteconfig5"
    KREADCONFIG="kreadconfig5"
    KQUITAPP="kquitapp5"
    KGLOBALACCEL="kglobalaccel5"
    echo "Plasma 5 detected"
else
    echo "Plasma version non recognized."
    exit 1
fi

# --- Menu ---
if [ $# -eq 0 ]; then
  echo "Setting New Values...";
elif [ "$1" == "log" ] || [ "$1" == "-l" ]; then
    # Set Logarithmic Mod instead of exponential
    echo "Log Mod is selected, setting parameters"
    python_command_up=" ${python_command_up} log"
    python_command_down="${python_command_down} log"
elif [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_help;
    exit 0;
else
    echo "Non valid Option.";
    show_help;
    exit 0;
fi


# Read Old Values
default_decrease="$($KREADCONFIG --file kglobalshortcutsrc --group org_kde_powerdevil --key "${decrease_key}")"
default_increase="$($KREADCONFIG --file kglobalshortcutsrc --group org_kde_powerdevil --key "${increase_key}")"

echo "Default/Old Increase Value: ${default_increase}"
echo "Default/Old Decrease Value: ${default_decrease}"

#Save old values if .cfg file doesn't exist
if [[ -f "${save_file}" ]]; then
        echo "Save File already exists, not overwriting"
else
  echo "Saving old config..."
  touch "${save_file}"
  echo "#[Default Values - Old]" > "${save_file}"
  echo "#${decrease_key}"
  echo "decrease_val=\"${default_decrease}\"" >> "${save_file}"
  echo "#${increase_key}"
  echo "increase_val=\"${default_increase}\"" >> "${save_file}"
fi

echo "Py File: ${py_abs_path}"
echo "Setting new Shortcut..."

# Remove Old/Default Values
echo "Removing Old Values..."
$KWRITECONFIG --file kglobalshortcutsrc --group org_kde_powerdevil --key "Decrease Screen Brightness" "none,Monitor Brightness Down,Abbassa luminosità dello schermo"
$KWRITECONFIG --file kglobalshortcutsrc --group org_kde_powerdevil --key "Increase Screen Brightness" "none,Monitor Brightness Up,Aumenta luminosità dello schermo"

# Instantiating New Shortcuts
echo "Writing New Shortcuts..."

# Creating .desktop files. They will be called when key is pressed
# Needed because some distros don't create file automatically when new entry is added in shortcuts-list file
echo -e "\n# Creating .desktop files in ${desktop_path}"

tee "${desktop_path}${up_group}" > /dev/null <<-EOT
[Desktop Entry]
Exec=${python_command_up}
Name=Screen Brightness Eye-Friendly Up
NoDisplay=true
StartupNotify=false
Type=Application
X-KDE-GlobalAccel-CommandShortcut=true
EOT

tee "${desktop_path}${down_group}" > /dev/null <<-EOT
[Desktop Entry]
Exec=${python_command_down}
Name=Screen Brightness Eye-Friendly Down
NoDisplay=true
StartupNotify=false
Type=Application
X-KDE-GlobalAccel-CommandShortcut=true
EOT

# Setting Entries in '$HOME/.config/kglobalshortcutsrc' file

$KWRITECONFIG --file kglobalshortcutsrc --group ${up_group} --key _k_friendly_name "HumanEye-Friendly Brightness Up"
$KWRITECONFIG --file kglobalshortcutsrc --group ${up_group} --key _launch "Monitor Brightness Up,none,${python_command_up}"

$KWRITECONFIG --file kglobalshortcutsrc --group ${down_group} --key _k_friendly_name "HumanEye-Friendly Brightness Down"
$KWRITECONFIG --file kglobalshortcutsrc --group ${down_group} --key _launch "Monitor Brightness Down,none,${python_command_down}"

# Reload: in Wayland (or some distro specific problem) often fails: needed Reboot!
if [ "${XDG_SESSION_TYPE}" = "wayland" ]; then
  echo "Wayland Machine Detected: We'll try to reload shortcuts but you probably need a reboot" >&2
fi

echo "Reloading Shortcuts... Use CTRL+C if doesn't stop"
($KQUITAPP kglobalaccel && sleep 2s && $KGLOBALACCEL >/dev/null 2>&1 &) || >&2 echo "Error restarting kglobalaccel: Try rebooting to update shortcuts"
