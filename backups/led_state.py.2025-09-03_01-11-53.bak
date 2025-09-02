import time
import board
import busio
import digitalio
import adafruit_tlc5947
import argparse
from math import sin, pi

# --- CONSTANTS ---
NUM_CHANNELS = 24
BRIGHTNESS = 0.8
SPI_FREQ = 1000000  # 1 MHz SPI
CYCLE_TIME = 40.0

# --- SETUP SPI & TLC5947 ---
spi = busio.SPI(clock=board.SCK, MOSI=board.MOSI)
latch = digitalio.DigitalInOut(board.D8)
tlc = adafruit_tlc5947.TLC5947(spi, latch)

CHANNELS = {
    "right": {"r": 0, "g": 1, "b": 2, "w": 3},
    "left":  {"r": 6, "g": 7, "b": 8, "w": 9}
}

def set_all_rgb(r, g, b):
    for side in CHANNELS:
        tlc[CHANNELS[side]["r"]] = int(r * 4095)
        tlc[CHANNELS[side]["g"]] = int(g * 4095)
        tlc[CHANNELS[side]["b"]] = int(b * 4095)

def set_all_white(level=BRIGHTNESS):
    for side in CHANNELS:
        tlc[CHANNELS[side]["w"]] = int(level * 4095)

def clear_all():
    for ch in range(NUM_CHANNELS):
        tlc[ch] = 0

def pulse_color(r, g, b, period, duration=5):
    """Pulse a color for a set duration (seconds)."""
    start_time = time.time()
    step = 0
    while time.time() - start_time < duration:
        brightness = (sin(step) + 1) / 2
        set_all_rgb(r * brightness, g * brightness, b * brightness)
        set_all_white(0.8)
        tlc.write()
        step += (2 * pi) / (period * 20)
        time.sleep(0.05)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Control Leapfrog Bolt Pro LEDs")
    parser.add_argument("state", choices=["idle", "printing", "success", "error"], help="LED mode to activate")
    args = parser.parse_args()

    try:
        if args.state == "idle":
            set_all_rgb(BRIGHTNESS, BRIGHTNESS, BRIGHTNESS)
            set_all_white(0.8)
            tlc.write()

        elif args.state == "printing":
            set_all_rgb(BRIGHTNESS, BRIGHTNESS, BRIGHTNESS)
            set_all_white(0.8)
            tlc.write()

        elif args.state == "success":
            pulse_color(0, BRIGHTNESS, 0, period=3.0)

        elif args.state == "error":
            pulse_color(BRIGHTNESS, 0, 0, period=1.0)

    except KeyboardInterrupt:
        clear_all()
        tlc.write()
