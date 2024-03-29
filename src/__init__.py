import sys
import subprocess
from curve_calculator import LogarithmicCalc
from curve_calculator import ExponentialCalc


"""
For KDE and DBUS:
Use of dbus instead of directly use /sys/class/backlight/<dev_name> node 
because dbus doesn't need sudo privileges
"""


def get_max_brightness():
    return int(subprocess.check_output(["qdbus",
                                        "org.kde.Solid.PowerManagement",
                                        "/org/kde/Solid/PowerManagement/Actions/BrightnessControl",
                                        "org.kde.Solid.PowerManagement.Actions.BrightnessControl.brightnessMax"]))


def get_backlight():
    """Get brightness value with qdbus"""
    return float(subprocess.check_output(["qdbus",
                                          "org.kde.Solid.PowerManagement",
                                          "/org/kde/Solid/PowerManagement/Actions/BrightnessControl",
                                          "org.kde.Solid.PowerManagement.Actions.BrightnessControl.brightness"]))


def set_backlight(backlight):
    """Set New Brightness value using dbus-send"""
    value = "int32:%d" % backlight
    subprocess.run(["dbus-send", "--print-reply", "--dest=org.kde.Solid.PowerManagement",
                    "/org/kde/Solid/PowerManagement/Actions/BrightnessControl",
                    "org.kde.Solid.PowerManagement.Actions.BrightnessControl.setBrightness",
                    value])


if __name__ == "__main__":
    backlight_min = 0
    backlight_max = get_max_brightness()
    steps = 20

    if len(sys.argv) < 2 or sys.argv[1] not in ["-i", "-d"]:
        print("usage:\n\t{0} -i / -d [method]".format(sys.argv[0]))
        print("method: optional; values: exp or log")
        sys.exit(0)

    method = sys.argv[2] if len(sys.argv) == 3 else None
    Method = LogarithmicCalc if method == "log" else ExponentialCalc

    current_backlight = get_backlight()

    action = sys.argv[1]
    if action == "-i":
        if current_backlight == backlight_max:
            sys.exit(0)
        new_backlight = Method.get_new_backlight(current_backlight, backlight_min, backlight_max, steps, increase=True)
    elif action == "-d":
        if current_backlight == 0 or current_backlight == backlight_min:
            sys.exit(0)
        new_backlight = Method.get_new_backlight(current_backlight, backlight_min, backlight_max, steps, increase=False)
    else:
        print("usage:\n\t{0} -i / -d".format(sys.argv[0]))
        sys.exit(0)

    print("Current backlight: {0}\nChanging to: {1}".format(current_backlight, new_backlight))
    set_backlight(new_backlight)
