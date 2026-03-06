# Linux Continuous Audio Recorder

A Bash-based Linux audio recording automation script that captures audio in fixed-length segments using SoX (`rec`) and saves each file with a timestamped name.

## Features

- Continuous audio recording in loop mode
- Timestamped `.mp3` file naming
- Automatic output directory creation
- Logging for each recording cycle
- Optional retention cleanup for old recordings
- Graceful shutdown handling
- Uses SoX silence detection options

## Use Case

This project is useful for:

- Continuous audio monitoring
- Recording timed audio segments
- Logging microphone input over long periods
- Basic automation demonstrations for Linux/Bash portfolios

## Requirements

This script requires:

- Linux
- Bash
- SoX (`rec` command)

## Install SoX

### Ubuntu / Debian
```bash
sudo apt update
sudo apt install sox
