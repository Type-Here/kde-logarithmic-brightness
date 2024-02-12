from math import log10

max_v = 255
min_v = 0
steps = 20


def linear_curve(tot_steps: int):
    values = []
    for i in range(tot_steps, 0, -1):
        val = round(i / tot_steps * (max_v - min_v))
        values.append(val)
    print("Linear for comparison: ")
    print("Values: ", values)


def exponential_curve(esp: float, tot_steps: int):
    backlights = []
    inv_esp = []

    for i in range(tot_steps, 0, -1):
        inv = i / tot_steps * (max_v ** esp - min_v ** esp)
        inv_esp.append(round(inv, 2))
        value = round(inv ** (1/esp))
        backlights.append(value)
    print("Exponential factor of %.2f:" % esp)
    print("Values: ", backlights)
    print("Inv Esp: ", inv_esp)


def logarithmic_curve(tot_steps: int):
    log_min = log10(min_v) if min_v >= 1 else 0
    backlights = []
    inv_esp = []

    for i in range(tot_steps, 0, -1):
        inv = i / tot_steps * (log10(max_v) - log_min)
        inv_esp.append(round(inv, 2))
        value = round(10 ** inv)
        backlights.append(value)
    print("Logarithmic: ")
    print("Values: ", backlights)
    print("Inv Esp: ", inv_esp)


print("-- Sim Data for your use case -- \n")
linear_curve(steps)
print(" --- ")
exponential_curve(0.3, steps)
exponential_curve(0.4, steps)
logarithmic_curve(steps)
