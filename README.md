# Capsule

A minimal floating command launcher for macOS. Summon it, run a command, see the result — then get out of the way.

![Capsule screenshot](docs/write-command-screenshot.png)

---

## Features

- **Floating panel** — stays above all windows, quick and easy to invoke
- **Always-on-top input bar** — type a command and press Return
- **Live current directory** — shown above the prompt; updates when you `cd`
- **Collapsible output panel** — expands automatically after each command
- **Status strip** — green on success, red on failure; click to toggle output

## Requirements

- macOS 15.2 or later

## Building

```bash
xcodebuild -scheme capsule -configuration Debug build
```

Or open `capsule.xcodeproj` in Xcode and press ⌘R.

## Usage

| Action                  | Result                                         |
| ----------------------- | ---------------------------------------------- |
| Type a command + Return | Runs in your login shell, output appears below |
| `cd some/path`          | Navigates; the directory label updates         |
| Click the status strip  | Toggles the output panel open / closed         |
| Press Escape            | Quits the app                                  |

## How it works

Each command runs in a fresh login shell (`$SHELL -l -c`) inside the current directory.
After the command completes, the shell reports its new working directory back to the app so `cd` is tracked across runs.
stdout and stderr are merged into a single output view.
