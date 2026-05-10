/*
 * Sensing Elbow Sleeve — ESP32 Firmware (Final Stable Build)

 * Wiring:
 *   Flex Sensor  → GPIO33 (D33) to GND
 *   32 kΩ Resistor → 3.3 V to GPIO33
 *   Capacitor    → GPIO33 to GND  (noise filter)
 *
 * Board   : ESP32 Dev Module
 * Baud    : 115200
 * Pin     : D33
 *
 * Output  : Smoothed 12-bit ADC count printed over UART every ~30 ms.
 *           Open Arduino Serial Monitor OR connect MATLAB to the COM port.
 */

const int FLEX_PIN   = 33;
const int windowSize = 20;   // Moving-average window (samples)

int  readings[windowSize];
int  readIndex = 0;
long total     = 0;

void setup() {
  Serial.begin(115200);
  pinMode(FLEX_PIN, INPUT);

  // Initialise circular buffer to zero
  for (int i = 0; i < windowSize; i++) readings[i] = 0;
}

void loop() {
  // --- Moving Average Filter ---
  total               = total - readings[readIndex];  // Remove oldest sample
  readings[readIndex] = analogRead(FLEX_PIN);          // Read new sample
  total               = total + readings[readIndex];  // Add new sample
  readIndex           = (readIndex + 1) % windowSize; // Advance circular pointer

  int averageRaw = total / windowSize;

  // Transmit smoothed ADC value over UART to MATLAB
  Serial.println(averageRaw);

  delay(30);   // ~33 Hz sampling rate
}
