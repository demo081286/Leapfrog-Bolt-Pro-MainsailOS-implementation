#!/usr/bin/env python3
import RPi.GPIO as GPIO
import time
import subprocess
import signal
import sys

# -------- Pins (BOARD numbering) --------
BUTTON_PIN = 16   # Button (BCM23)
PSU_PIN    = 11   # PSU relay (BCM17)
LED_PIN    = 22   # Blue ring LED (BCM25) - may be owned by touch overlay

# -------- Behaviour --------
BOUNCE_MS        = 50        # poll/debounce period
SHORT_PRESS_MAX  = 15.0      # seconds -> treat as normal shutdown

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BOARD)

# PSU on
GPIO.setup(PSU_PIN, GPIO.OUT, initial=GPIO.HIGH)

# LED on (ignore if the touchscreen overlay owns BCM25)
_led_ok = True
try:
    GPIO.setup(LED_PIN, GPIO.OUT, initial=GPIO.HIGH)
except Exception as e:
    _led_ok = False
    print(f"[warn] LED on pin {LED_PIN} not controlled (probably claimed by LCD): {e}")

# Button input with pull-down
GPIO.setup(BUTTON_PIN, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)

print("PSU relay is ON and (if free) LED is ON. Monitoring button (polling)…")

# Graceful exit from systemd stop / Ctrl+C
def _exit_clean(*_):
    try:
        GPIO.output(LED_PIN, GPIO.LOW) if _led_ok else None
    finally:
        GPIO.cleanup()
    sys.exit(0)

signal.signal(signal.SIGINT, _exit_clean)
signal.signal(signal.SIGTERM, _exit_clean)

pressed = False
t_start = None
sleep_s = BOUNCE_MS / 1000.0

def do_shutdown():
    print("Shutdown initiated…")
    # Let journal flush a moment and LED indicate action
    if _led_ok:
        GPIO.output(LED_PIN, GPIO.LOW)
    time.sleep(0.2)
    subprocess.call(["sudo", "shutdown", "-h", "now"])

try:
    while True:
        level = GPIO.input(BUTTON_PIN)

        if level and not pressed:
            # rising edge
            pressed = True
            t_start = time.monotonic()
            print("Button press detected; timing…")

        elif not level and pressed:
            # falling edge
            pressed = False
            if t_start is not None:
                dur = time.monotonic() - t_start
                print(f"Button released after {dur:.2f}s")
                if dur <= SHORT_PRESS_MAX:
                    do_shutdown()
                    # If shutdown returns (rare), keep looping
                t_start = None

        time.sleep(sleep_s)

except KeyboardInterrupt:
    pass
finally:
    _exit_clean()
