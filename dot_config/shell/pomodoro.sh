#!/bin/bash

# Pomodoro timer with worklog functionality
# Uses XDG Base Directory specification for data storage

# Main pomodoro function
pomodoro() {
    local minutes=${1:-25}
    local task="${2:-Focused work}"
    local logfile="$HOME/.pomodoro_log"
    local date=$(date '+%Y-%m-%d')
    local start_time=$(date '+%H:%M')
    local total_seconds=$((minutes * 60))
    
    echo "🍅 Starting ${minutes}-min pomodoro: $task"
    
    # Progress bar countdown
    for ((i=total_seconds; i>=0; i--)); do
        local percent=$(((total_seconds - i) * 100 / total_seconds))
        local bars=$((percent / 2))
        local spaces=$((50 - bars))
        
        printf "\r[%s%s] %d%% - %02d:%02d remaining" \
            "$(printf '%*s' "$bars" | tr ' ' '=')" \
            "$(printf '%*s' "$spaces")" \
            "$percent" \
            "$((i / 60))" \
            "$((i % 60))"
        
        sleep 1
    done
    
    echo ""
    local end_time=$(date '+%H:%M')
    
    # Log the completed pomodoro
    echo "$date,$start_time,$end_time,$minutes,$task" >> "$logfile"
    
    # Play sound and notify
    paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null &
    notify-send -u critical "🍅 Pomodoro Complete" "$task finished!"
}

# Daily summary
pomodoro_summary() {
    local data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/pomodoro"
    local logfile="$data_dir/pomodoro.log"
    local date=${1:-$(date '+%Y-%m-%d')}
    
    if [[ ! -f "$logfile" ]]; then
        echo "No pomodoro log found."
        return
    fi
    
    echo "📊 Pomodoro Summary for $date"
    echo "================================"
    
    # Filter today's entries and calculate stats
    local today_entries=$(grep "^$date," "$logfile")
    
    if [[ -z "$today_entries" ]]; then
        echo "No pomodoros completed today."
        return
    fi
    
    local total_pomodoros=$(echo "$today_entries" | wc -l)
    local total_minutes=$(echo "$today_entries" | cut -d',' -f4 | awk '{sum+=$1} END {print sum}')
    
    echo "Total pomodoros: $total_pomodoros"
    echo "Total time: $total_minutes minutes ($(echo "scale=1; $total_minutes/60" | bc 2>/dev/null || echo "$((total_minutes/60))")h)"
    echo ""
    echo "Tasks completed:"
    echo "$today_entries" | while IFS=',' read -r date start end mins task; do
        echo "  • $start-$end ($mins min): $task"
    done
}

# View log for any date
pomodoro_log() {
    local data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/pomodoro"
    local logfile="$data_dir/pomodoro.log"
    local date=${1:-$(date '+%Y-%m-%d')}
    
    if [[ ! -f "$logfile" ]]; then
        echo "No pomodoro log found."
        return
    fi
    
    echo "📋 Pomodoro Log for $date"
    echo "========================"
    local entries=$(grep "^$date," "$logfile")
    
    if [[ -z "$entries" ]]; then
        echo "No entries found for $date"
        return
    fi
    
    printf "%-8s %-8s %-8s %s\n" "Start" "End" "Minutes" "Task"
    printf "%-8s %-8s %-8s %s\n" "-----" "---" "-------" "----"
    echo "$entries" | while IFS=',' read -r date start end mins task; do
        printf "%-8s %-8s %-8s %s\n" "$start" "$end" "$mins" "$task"
    done
}

# Weekly summary
pomodoro_week() {
    local data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/pomodoro"
    local logfile="$data_dir/pomodoro.log"
    local start_date=${1:-$(date -d 'monday' '+%Y-%m-%d' 2>/dev/null || date -v-monday '+%Y-%m-%d' 2>/dev/null || date '+%Y-%m-%d')}
    
    if [[ ! -f "$logfile" ]]; then
        echo "No pomodoro log found."
        return
    fi
    
    echo "📈 Weekly Summary starting $start_date"
    echo "======================================"
    
    local total_week_pomodoros=0
    local total_week_minutes=0
    
    for i in {0..6}; do
        local check_date
        if command -v gdate >/dev/null 2>&1; then
            # macOS with GNU date
            check_date=$(gdate -d "$start_date + $i days" '+%Y-%m-%d' 2>/dev/null)
        elif date -d "$start_date + $i days" '+%Y-%m-%d' >/dev/null 2>&1; then
            # GNU date (Linux)
            check_date=$(date -d "$start_date + $i days" '+%Y-%m-%d')
        else
            # BSD date (macOS default) - fallback
            check_date=$(date -j -v+${i}d -f "%Y-%m-%d" "$start_date" '+%Y-%m-%d' 2>/dev/null || echo "$start_date")
        fi
        
        local day_name=$(date -d "$check_date" '+%A' 2>/dev/null || date -j -f "%Y-%m-%d" "$check_date" '+%A' 2>/dev/null || echo "Day$i")
        local count=$(grep "^$check_date," "$logfile" 2>/dev/null | wc -l | tr -d ' ')
        local minutes=$(grep "^$check_date," "$logfile" 2>/dev/null | cut -d',' -f4 | awk '{sum+=$1} END {print sum+0}')
        
        printf "%-10s: %2d pomodoros (%3d min)\n" "$day_name" "$count" "$minutes"
        
        total_week_pomodoros=$((total_week_pomodoros + count))
        total_week_minutes=$((total_week_minutes + minutes))
    done
    
    echo "======================================"
    printf "%-10s: %2d pomodoros (%3d min)\n" "Total" "$total_week_pomodoros" "$total_week_minutes"
}

# Show all available pomodoro commands
pomodoro_help() {
    echo "🍅 Pomodoro Timer Commands"
    echo "========================="
    echo "pomodoro [minutes] [task]    - Start a pomodoro timer"
    echo "pomodoro_summary [date]      - Show daily summary"
    echo "pomodoro_log [date]          - View formatted log for date"
    echo "pomodoro_week [start_date]   - Show weekly summary"
    echo "pomodoro_help                - Show this help"
    echo ""
    echo "Examples:"
    echo "  pomodoro                   # 25-minute default timer"
    echo "  pomodoro 15 'Code review'  # 15-minute timer with task"
    echo "  pomodoro_summary           # Today's summary"
    echo "  pomodoro_summary 2025-07-20  # Specific date"
    echo "  pomodoro_week              # This week's summary"
    echo ""
    echo "Log location: ${XDG_DATA_HOME:-$HOME/.local/share}/pomodoro/pomodoro.log"
}
