# NeuroWire 🧠

A minimalist Progressive Web App (PWA) that helps you rewire yourself over time towards new,
healthy habits: tap a trigger button (e.g. Stress, Hunger, Tired) and work through its
checklist (e.g. Breathe, Drink water, ...). Next time you open it, the same checklist
reappears unchecked, but with your latest saved items and their order.

📱 Launch the app: [https://oliverbyte.github.io/neurowire/](https://oliverbyte.github.io/neurowire/)

## ✨ Features

- Create, rename, and delete your own trigger buttons – each one automatically gets its own
  color and icon.
- Freely edit each trigger's checklist: add, rename, delete, and drag-and-drop reorder items.
- The checked state is purely temporary – every time you open a checklist it starts unchecked,
  but with the same items in the same order.

## 🔐 Privacy

All data is stored exclusively locally in the user's browser (`shared_preferences` /
`localStorage`). There is no server communication, no cloud sync, and no data sharing with
third parties.

## 🚀 Install as a PWA

1. Open [https://oliverbyte.github.io/neurowire/](https://oliverbyte.github.io/neurowire/) in your browser.
2. **iOS:** Share icon (□↑) → "Add to Home Screen".
3. **Android/Desktop (Chrome/Edge):** "Install app" or the ⊕ icon in the address bar.

## 💻 Development

```bash
# Clone the repository
git clone https://github.com/oliverbyte/neurowire.git
cd neurowire

# Install dependencies
flutter pub get

# Run in Chrome
flutter run -d chrome

# Production build (output in build/web/)
flutter build web --release
```

Deployment to GitHub Pages happens automatically via GitHub Actions on every push to `main`
(see [.github/workflows/deploy.yml](.github/workflows/deploy.yml)).

