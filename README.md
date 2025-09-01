
# Leapfrog Bolt Pro – Klipper Firmware Setup

This guide documents how to run **Klipper firmware** on the **Leapfrog Bolt Pro** with custom scripts for **LED control**, **power button management**, and a **custom Klipper update script**.

---

## 1. Hardware & Environment

- **Printer:** Leapfrog Bolt Pro  
- **Controller:** Raspberry Pi (tested with Pi 3B and Pi 4)  
- **OS:** MainsailOS or OctoPi (Debian-based)  
- **Firmware:** [Klipper](https://www.klipper3d.org/) (latest master branch)  

---

## 2. Initial Setup

### 2.1 Flash Raspberry Pi
- Install **MainsailOS** or **OctoPi** onto the SD card.
- Boot and connect via SSH:

```bash
ssh pi@<printer-ip>
```

Default password: `raspberry`

---

## 3. Install Dependencies

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip python3-venv python3-dev                      git build-essential                      libopenblas-dev libatlas-base-dev                      python3-rpi.gpio
pip3 install adafruit-blinka adafruit-circuitpython-tlc5947
```

---

## 4. Klipper Installation

Follow the official Klipper instructions:

```bash
cd ~
git clone https://github.com/Klipper3d/klipper
./klipper/scripts/install-octopi.sh
```

---

## 5. Configuration

### 5.1 Printer Configuration

Your primary configuration file is `printer.cfg`.  
Place it in:

```
/home/pi/printer_data/config/
```

Example PT100 ADC calibration snippet:

```ini
#####################################################################
# ADC PT100 Calibration
#####################################################################
[adc_temperature pt100_leapfrog]
temperature1: 0
voltage1: 1.95
temperature2: 100
voltage2: 2.68
temperature3: 200
voltage3: 3.77
temperature4: 300
voltage4: 4.05
temperature5: 400
voltage5: 4.68
```

---

### 5.2 Macros

Create a `macros.cfg` in `/home/pi/printer_data/config/` and include it from `printer.cfg`:

```ini
[include macros.cfg]
```

This file can handle:
- `START_PRINT`, `END_PRINT`, `CANCEL_PRINT`
- LED states: `LED_IDLE`, `LED_PRINTING`, `LED_SUCCESS`, `LED_ERROR`

---

### 5.3 LED Control Script

Located at:

```
/home/pi/leapfrog/led_control/led_state.py
```

**Modes:**
- **Idle / Printing:** Solid white
- **Success:** Pulsing green
- **Error:** Fast pulsing red

**Manual Test:**

```bash
cd ~/leapfrog/led_control
python3 led_state.py idle
python3 led_state.py success
python3 led_state.py error
```

---

### 5.4 Start LED Script Automatically (systemd)

Create the service file:

```bash
sudo nano /etc/systemd/system/led_control.service
```

Paste:

```ini
[Unit]
Description=Leapfrog LED Controller
After=network.target

[Service]
ExecStart=/usr/bin/python3 /home/pi/leapfrog/led_control/led_state.py idle
Restart=always
User=pi
WorkingDirectory=/home/pi/leapfrog/led_control
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

**Enable and start the service:**

```bash
sudo systemctl daemon-reload
sudo systemctl enable led_control
sudo systemctl start led_control
```

**Check status:**

```bash
sudo systemctl status led_control
```

**Change LED Mode from Shell:**

```bash
sudo systemctl stop led_control
python3 /home/pi/leapfrog/led_control/led_state.py success
```

---

### 5.5 Power Button Script

Located at:

```
/home/pi/leapfrog/powerbutton.py
```

**Behavior:**
- Short press → Graceful shutdown  
- Controls PSU relay and optional LED ring

Create a service:

```bash
sudo nano /etc/systemd/system/powerbutton.service
```

```ini
[Unit]
Description=Leapfrog Power Button
After=multi-user.target

[Service]
ExecStart=/usr/bin/python3 /home/pi/leapfrog/powerbutton.py
Restart=always
User=pi

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable powerbutton
sudo systemctl start powerbutton
```

Check status:

```bash
sudo systemctl status powerbutton
```

---

### 5.6 Update Klipper Script

Located at:

```
/home/pi/update_klipper.sh
```

**Run manually:**

```bash
cd ~
./update_klipper.sh
```

Adjust `FLASH_DEVICE` in the script to match your USB serial ID:

```bash
ls /dev/serial/by-id/
```

---

## 6. Updating

```bash
cd ~
./update_klipper.sh
```

---

## 7. Troubleshooting

| Problem | Solution |
|----------|----------|
| LEDs not working | Check SPI wiring, pins, and that service is active |
| Button ignored | Check GPIO pin mapping and permissions |
| Update script fails | Verify `FLASH_DEVICE` path |
| Klipper errors | Check logs: `tail -f ~/printer_data/logs/klippy.log` |

---

## 8. To-Do

- Add pinout diagrams and wiring diagrams  
- Include known PID tuning values for dual extruders  
- Automate more macros for filament changes and maintenance  

---

## 9. Credits

- Base firmware: [Klipper](https://www.klipper3d.org/)  
- LED control: Based on Adafruit TLC5947 examples  
- Power button script: Inspired by standard GPIO control patterns  

---

## 10. License

MIT License – free to share and modify.
