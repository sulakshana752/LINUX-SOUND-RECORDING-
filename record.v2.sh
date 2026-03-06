#!/usr/bin/env bash

# =========================================================
# Continuous Audio Recorder
# Author: Sula Jayasekara
#
# Description:
# Records audio in fixed-length segments using SoX (`rec`)
# and saves each segment with a timestamped filename.
#
# Features:
# - Continuous loop recording
# - Timestamp-based filenames
# - Output directory creation
# - Basic dependency check
# - Optional max file retention
# - Logging to file
# =========================================================

set -uo pipefail

# -----------------------------
# Configuration
# -----------------------------
OUTPUT_DIR="./recordings"
LOG_DIR="./logs"
LOG_FILE="$LOG_DIR/audio_recorder.log"

SAMPLE_RATE="22050"
CHANNELS="1"
SEGMENT_DURATION="15:00"

# Silence detection settings
SILENCE_START_COUNT="1"
SILENCE_START_DURATION="0"
SILENCE_START_THRESHOLD="8%"
SILENCE_END_COUNT="-1"
SILENCE_END_DURATION="00:00:05"
SILENCE_END_THRESHOLD="8%"

# Optional: keep only the newest N recordings
# Set to 0 to disable cleanup
RETENTION_COUNT=100

# -----------------------------
# Functions
# -----------------------------
log_message() {
    local message="$1"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[$timestamp] $message" | tee -a "$LOG_FILE"
}

check_dependencies() {
    if ! command -v rec >/dev/null 2>&1; then
        echo "ERROR: 'rec' command not found. Install SoX first."
        echo "Ubuntu/Debian: sudo apt install sox"
        echo "RHEL/CentOS: sudo yum install sox"
        exit 1
    fi
}

prepare_directories() {
    mkdir -p "$OUTPUT_DIR" "$LOG_DIR"
    touch "$LOG_FILE" || {
        echo "ERROR: Unable to create log file: $LOG_FILE"
        exit 1
    }
}

cleanup_old_recordings() {
    if [ "$RETENTION_COUNT" -le 0 ]; then
        return
    fi

    mapfile -t recordings < <(ls -1t "$OUTPUT_DIR"/recording_*.mp3 2>/dev/null || true)
    local total_files="${#recordings[@]}"

    if [ "$total_files" -le "$RETENTION_COUNT" ]; then
        return
    fi

    for ((i=RETENTION_COUNT; i<total_files; i++)); do
        if rm -f "${recordings[$i]}"; then
            log_message "Removed old recording: ${recordings[$i]}"
        else
            log_message "WARNING: Failed to remove old recording: ${recordings[$i]}"
        fi
    done
}

record_segment() {
    local timestamp file_name
    timestamp="$(date '+%Y-%m-%d_%H-%M-%S')"
    file_name="$OUTPUT_DIR/recording_${timestamp}.mp3"

    log_message "Starting recording: $file_name"

    if rec -c "$CHANNELS" -r "$SAMPLE_RATE" "$file_name" \
        trim 0 "$SEGMENT_DURATION" \
        silence "$SILENCE_START_COUNT" "$SILENCE_START_DURATION" "$SILENCE_START_THRESHOLD" \
                "$SILENCE_END_COUNT" "$SILENCE_END_DURATION" "$SILENCE_END_THRESHOLD"
    then
        log_message "Completed recording: $file_name"
    else
        log_message "ERROR: Recording failed for file: $file_name"
        return 1
    fi
}

handle_shutdown() {
    log_message "Received stop signal. Exiting audio recorder."
    exit 0
}

main() {
    trap handle_shutdown SIGINT SIGTERM

    check_dependencies
    prepare_directories

    log_message "========================================"
    log_message "Audio recorder started"
    log_message "Output directory: $OUTPUT_DIR"
    log_message "Segment duration: $SEGMENT_DURATION"
    log_message "Sample rate: $SAMPLE_RATE"
    log_message "Channels: $CHANNELS"
    log_message "========================================"

    while true; do
        record_segment
        cleanup_old_recordings
    done
}

main
