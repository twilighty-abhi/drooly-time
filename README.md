# Drooly time ⏳

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-11.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![GitHub release](https://img.shields.io/github/v/release/twilighty-abhi/drooly-time)](https://github.com/twilighty-abhi/drooly-timev/releases)

A sleek and efficient menubar timer for macOS that helps you stay productive without getting in your way.

[Features](#features) • [Installation](#installation) • [Usage](#usage) • [Contributing](#contributing) • [License](#license)



</div>

## ✨ Features

- **Quick Access**: Lives in your menubar, always ready but never intrusive
- **Smart Defaults**: Start a 25-minute focus session with a single click
- **Flexible Timing**: Choose from presets or set custom durations
- **Visual Feedback**: 
  - ⏳ Hourglass shows active timer
  - ⏸ Clear pause indication
  - Alternating display for better visibility
- **System Integration**:
  - Native macOS notifications
  - Audio alerts when timer completes

## 🚀 Installation


### Option 1: Run the .app file
Go to releases page --> Download the latest .zip file --> unzip --> Run the Drooly time app
### Option 2: Build from Source
```bash
# Clone the repository
git clone https://github.com/yourusername/menubar-timer.git

# Navigate to project directory
cd menubar-timer

# Open in Xcode
open MenuBarTimer.xcodeproj
```

Then build and run in Xcode (⌘B, ⌘R)

## Screenshots
<img width="291" alt="Screenshot 2025-02-19 at 19 04 09" src="https://github.com/user-attachments/assets/ff9f87e8-b683-43ad-8aa8-e7bdd71a5a27" />



## 💫 Usage

### Basic Controls
- **Left Click**: Start a 25-minute timer
- **Right Click**: Open menu with options
- **Menu Options**:
  - Set custom duration
  - Choose from presets (15, 25, 50, 60 minutes)
  - Pause/Resume timer
  - Reset current timer

### Timer States
| State | Display | Meaning |
|-------|---------|---------|
| ⏳ | Hourglass | Ready to start |
| ⏳25 | Hourglass + Number | Timer running |
| ⏸ PAUSED | Pause symbol | Timer paused |


## 🛠 Development

### Requirements
- macOS 11.0 or later
- Xcode 13.0 or later
- Swift 5.0



## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request




## ⚡️ Performance

MenuBar Timer is designed to be lightweight:
- Minimal CPU usage (<0.1% when idle)
- Small memory footprint (<10MB)
- Quick launch time (<1 second)

## 📋 Roadmap

- [ ] Multiple simultaneous timers
- [ ] Custom notification sounds
- [ ] Stats tracking
- [ ] Pomodoro mode

## 🙋 FAQ

**Q: Will this work on my Mac?**  
A: MenuBar Timer requires macOS 11.0 (Big Sur) or later.

**Q: How do I autostart the timer?**  
A: Right-click the menubar icon > System Preferences > Users & Groups > Login Items > Add MenuBar Timer.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙌 Acknowledgments

- Inspired by Gestimer
- Icons from [SF Symbols](https://developer.apple.com/sf-symbols/)
- Sound effects from [FreeSound](https://freesound.org/)

---

<div align="center">
Made with ❤️ by Abhiram

⭐️ Star us on GitHub — it helps!
</div>
