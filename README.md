# Sensing Elbow Joint Sleeve
### Real-Time Angle Measurement Using Flex Sensor & ESP32
---

## Overview

A low-cost wearable elbow sleeve that measures joint flexion angle in real time using a resistive flex sensor, an ESP32 microcontroller, and a MATLAB signal-processing dashboard.

The project is motivated by the need for affordable, comfortable, out-of-clinic rehabilitation monitoring for stroke survivors, arthritis patients, and athletes — without the bulk or discomfort of conventional rigid exoskeletons.

---

## Repository Contents

| File | Description |
|------|-------------|
| `phase1_manual_angle.m` | Phase 1 – Manual 3-point MATLAB angle measurement using PoseNet landmarks |
| `phase2_auto_hough.m` | Phase 2 – Automated Hough-transform line detection and angle calculation |
| `esp32_flex_sensor.ino` | ESP32 Arduino firmware – moving-average filtered ADC readout over UART |
| `matlab_realtime_tracker.m` | MATLAB real-time serial dashboard – filtering, regression mapping, live plot |
| `calibration_log.csv` | Per-session calibration values (straightVal, bentVal, maxAngle) |

---

## Hardware Required

| Component | Specification |
|-----------|--------------|
| Elbow sleeve | Spandex/nylon compression sleeve |
| Flex sensor | 3.5" resistive flex sensor |
| Microcontroller | ESP32 Dev Module |
| Resistor | 32 kΩ (pull-up to 3.3 V) |
| Capacitor | Small (noise filter, D33 to GND) |
| Wires | Long lead wires with heat-shrink |
| Fastening | Velcro bands |

---

## Circuit Wiring

```
3.3 V ──── 32 kΩ ──┬──── D33 (ESP32 GPIO33)
                   │
              Flex Sensor
                   │
                  GND
                   │
              Capacitor (D33 to GND)
```

- The flex sensor resistance increases from ~25 kΩ (straight) to ~125 kΩ (fully bent).
- Output voltage at D33 decreases as the elbow bends → lower ADC count.

---

## Software Setup

### 1. Flash the ESP32

1. Install [Arduino IDE](https://www.arduino.cc/en/software) and the ESP32 board package.
2. Open `esp32_flex_sensor.ino`.
3. Select **Board:** ESP32 Dev Module, **Port:** your COM port.
4. Upload the sketch.

### 2. Calibrate

1. Open **Arduino IDE Serial Monitor** at **115200 baud**.
2. Hold elbow **fully straight** → note the stable ADC value → `straightVal`.
3. Bend elbow to **maximum (~90°)** → note the ADC value → `bentVal`.
4. Close the Serial Monitor.

### 3. Run the MATLAB Dashboard

1. Open `matlab_realtime_tracker.m`.
2. Update `portName` to your COM port (e.g. `"COM3"` or `"/dev/ttyUSB0"`).
3. Update `straightVal` and `bentVal` from your calibration step.
4. Run the script — the live angle-vs-time plot will appear.

---

## Calibration Procedure (Quick Reference)

| Step | Action |
|------|--------|
| 1 | Don sleeve; position flex sensor over elbow crease; secure with Velcro |
| 2 | Connect ESP32 via USB; open Serial Monitor at 115200 baud |
| 3 | Hold arm straight → record ADC → `straightVal` |
| 4 | Bend to max → record ADC → `bentVal` |
| 5 | Close Serial Monitor; update MATLAB script; run |
| 6 | Verify: straight ≈ 0°, bent ≈ 90° |

> **Note:** Recalibrate at the start of each session due to resistive sensor drift.

---

## System Architecture

```
SENSE          PROCESS         TRANSMIT        VISUALIZE
Flex Sensor → ESP32 ADC  →  UART Serial  →  MATLAB Dashboard
(bend angle)  (12-bit, D33)  (115200 baud)   (live angle plot)
```

### Signal Processing Pipeline (MATLAB)
1. **Moving Average (n=20):** rolling buffer flattens noise spikes.
2. **Regression Mapping:** `angle = ((raw − straightVal) / (bentVal − straightVal)) × maxAngle`
3. **Angle Clamping:** hard clamp to `[0°, 90°]` prevents impossible readings.
4. **Rolling X-axis:** last 10 seconds always in view.

---

## Phase Study Results

### Phase 1 – Manual (PoseNet + MATLAB)

| Target | Measured Angle |
|--------|---------------|
| Near straight | 176.08° |
| Moderate bend | 124.81° |
| ~90° bend | 99.84° |
| Increased flex | 67.63° |
| High flexion | 37.66° |

### Phase 2 – Automated (Hough Transform)

Automated detection matched manual accuracy within **±3–5°** across all tested poses, eliminating operator variability.

---

## Limitations

- Sensor drift requires per-session recalibration.
- Single-axis measurement (flexion/extension only).
- USB-tethered; no wireless in current build.
- Velcro repositioning introduces inter-session variability.

---

## Future Scope

- Origami soft pneumatic actuators for assistive force
- IMU integration for multi-axis (supination/pronation) tracking
- BLE/WiFi wireless communication using ESP32 built-in radio
- LSTM-based ML model for personalized assistance prediction
- Textile-integrated sewn-in flex sensor (no Velcro)
- Formal clinical validation (stroke/arthritis patients)

---

## References

1. Campioni et al. (2025). *Soft Wearable Robot for Shoulder Movement Assistance.* IEEE TMRB.
2. Zhou et al. (2019). *Soft Robotic Glove for Grasping Assistance.* IEEE ICORR.
3. Proietti et al. (2022). *Soft Upper-Limb Wearable Robotic Devices.* IEEE Access.
4. Cao et al. (2019). *OpenPose: Realtime Multi-Person 2D Pose Estimation.* IEEE TPAMI.

---

# sensing-elbow-sleeve
Wearable elbow joint sleeve for real-time flexion angle measurement using a resistive flex sensor and ESP32. Features two-phase software validation (PoseNet + Hough Transform in MATLAB) and a live signal-processing dashboard.
