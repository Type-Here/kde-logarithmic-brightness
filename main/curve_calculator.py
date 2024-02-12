from abc import ABC, abstractmethod
from math import log10


class CurveCalc(ABC):
    @abstractmethod
    def calculate_step(self, *args):
        pass

    @abstractmethod
    def get_new_backlight(self, *args):
        pass


class LogarithmicCalc(CurveCalc):
    @staticmethod
    def calculate_step(backlight: float, log_min: float, log_max: float, tot_steps: int) -> int:
        if backlight <= 1:
            return round(backlight)
        return round(log10(backlight) / (log_max - log_min) * tot_steps)

    @staticmethod
    def get_new_backlight(cur_backlight: float, min_backlight: int,
                          max_backlight: int, tot_steps: int, increase=True) -> int:
        x_min = 0 if min_backlight <= 1 else log10(min_backlight)
        x_max = log10(max_backlight)

        current_step = LogarithmicCalc.calculate_step(cur_backlight, x_min, x_max, tot_steps)

        new_step = current_step + 1 if increase else current_step - 1
        print("Values: ", new_step, current_step, min_backlight, max_backlight, tot_steps)

        if new_step == 0:
            return min_backlight
        elif new_step == 1 or new_step == 2:
            return 1

        x = new_step / tot_steps * (x_max - x_min)
        backlight = round(max(min(10 ** x, max_backlight), min_backlight))

        return backlight
  
