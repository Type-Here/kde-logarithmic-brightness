from math import log10

import sys
import subprocess


def get_backlight():
    return float(subprocess.check_output(["qdbus",
                                          "org.kde.Solid.PowerManagement",
                                          "/org/kde/Solid/PowerManagement/Actions/BrightnessControl",
                                          "org.kde.Solid.PowerManagement.Actions.BrightnessControl.brightness"]))


def set_backlight(backlight):
    value = "int32:%d" % backlight
    subprocess.run(["dbus-send", "--print-reply", "--gitgit dest=org.kde.Solid.PowerManagement",
                    "/org/kde/Solid/PowerManagement/Actions/BrightnessControl",
                    "org.kde.Solid.PowerManagement.Actions.BrightnessControl.setBrightness",
                    value])


def calculate_step(backlight: float, log_min: float, log_max: float, tot_steps: int) -> int:
    return round(log10(backlight) / (log_max - log_min) * tot_steps)


def get_new_backlight(cur_backlight: float, min_backlight: int,
                      max_backlight: int, tot_steps: int, increase=True) -> int:

    x_min = 0 if min_backlight <= 1 else log10(min_backlight)
    x_max = log10(max_backlight)

    current_step = calculate_step(cur_backlight, x_min, x_max, tot_steps)
    new_step = current_step + 1 if increase else current_step - 1
    print("Values: ", new_step, min_backlight, max_backlight, tot_steps)

    if new_step == 0:
        return min_backlight

    x = new_step / tot_steps * (x_max - x_min)
    backlight = round(max(min(10 ** x, max_backlight), min_backlight))

    return backlight


if __name__ == "__main__":

    backlight_min = 0
    backlight_max = 255

    steps = 20

    if len(sys.argv) < 2 or sys.argv[1] not in ["-i", "-d"]:
        print("usage:\n\t{0} -i / -d".format(sys.argv[0]))
        sys.exit(0)

    current_backlight = get_backlight()

    action = sys.argv[1]
    if action == "-i":
        new_backlight = get_new_backlight(current_backlight, backlight_min, backlight_max, steps, True)
    elif action == "-d":
        new_backlight = get_new_backlight(current_backlight, backlight_min, backlight_max, steps, False)
    else:
        print("usage:\n\t{0} -i / -d".format(sys.argv[0]))
        sys.exit(0)

    print("Current backlight: {0}\nChanging to: {1}".format(current_backlight, new_backlight))
    set_backlight(new_backlight)
