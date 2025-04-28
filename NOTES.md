# 📜 gui-kiosk — Project Notes

**gui-kiosk** is a strong foundation for running graphical Linux apps in the browser.

Rather than chasing flashy features, gui-kiosk focuses on **clarity**, **stability**, and **future flexibility**.

This project was built with three core principles:

---

### 1. 🎯 Precision Over Mutation

> "Each instance should be launched with a clear purpose — not morphed on demand."

- Applications are chosen deliberately (at build time or with a clean setting), not changed at runtime.
- This prevents chaos, improves security, and ensures a reliable user experience.
- Like forging a blade for a specific strike, not a shapeshifting tool you can’t trust.

---

### 2. 🌱 Simplicity First, Scaling Later

> "Build the first container clean. Clone it when ready."

- gui-kiosk runs **one app cleanly** inside **one container**.
- Later phases (codename: **kage_bunshin_no_jutsu**) will introduce scaling by replication — not by mutating containers on demand.

---

### 3. 🛡️ Controlled Growth

> "Add features only when they serve the core experience — not because they sound exciting."

- Features like runtime URL payloads, real-time user multiplexing, and embedded dashboards were intentionally deferred.
- gui-kiosk focuses first on getting the essentials right:
  - Secure browser access
  - Stable GUI streaming
  - Clean, reproducible builds

---

# 🌀 Future Growth

In future versions, gui-kiosk will evolve into a Kubernetes-native deployment under the codename **kage_bunshin_no_jutsu**:
- Each app instance will be a lightweight pod.
- Resources and traffic will be cleanly controlled by the platform.
- The same philosophy — **clarity, precision, simplicity** — will be preserved.

---

# 🛡️ Closing

gui-kiosk isn't just a tech stack —  
it's a deliberate, thoughtful foundation for future expansion.

Every piece was chosen with care, not haste.
