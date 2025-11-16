#!/bin/bash

WATCH_INTERVAL=60  # 1 minute in seconds

print_progress() {
  # Get current date information
  current_day=$(date +%d)
  current_hour=$(date +%H)
  current_minute=$(date +%M)
  current_month=$(date +%m)
  current_year=$(date +%Y)
  current_yday=$(date +%j)

  # Calculate days in current month
  days_in_month=$(date -d "$current_year-$current_month-01 + 1 month - 1 day" +%d)

  # Calculate total minutes in the month
  total_minutes=$((days_in_month * 24 * 60))

  # Calculate minutes elapsed
  minutes_elapsed=$(( (10#$current_day - 1) * 24 * 60 + 10#$current_hour * 60 + 10#$current_minute ))

  # Calculate percentage (using bash arithmetic with 3 decimal places)
  percentage=$(( minutes_elapsed * 100000 / total_minutes ))
  percentage_display=$(printf "%.3f" $(echo "$percentage" | awk '{print $1/1000}'))

  # Create bar graph (50 characters wide)
  bar_length=50
  filled_chars=$(( percentage * bar_length / 100000 ))

  # Build the bar
  bar=""
  for ((i=1; i<=bar_length; i++)); do
    if (( i <= filled_chars )); then
      bar+="█"
    else
      bar+="░"
    fi
  done

  printf "\n"
  printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
  printf "|                                                        |\n"
  # Display results for full month
  printf ":  Month Progress: %s%%\n" "$percentage_display"
  printf "|  [%s]  |\n" "$bar"
  printf ":  Minutes elapsed: %d / %d\n" $minutes_elapsed $total_minutes
  printf ":  Hours elapsed: %d / %d\n" $((minutes_elapsed / 60)) $((total_minutes / 60))
  printf ":  Day %d of %d days\n" $((10#$current_day)) $days_in_month

  printf "|                                                        |\n"
  printf "|……………………………………………………………………………………………………………………………………………………|\n"
  printf "|                                                        |\n"

  # Calculate business days in the month
  business_days=0
  for ((d=1; d<=days_in_month; d++)); do
    dow=$(date -d "$current_year-$current_month-$d" +%u)
    if (( dow >=1 && dow <=5 )); then
      ((business_days++))
    fi
  done

  # Calculate business days elapsed
  current_dow=$(date +%u)
  business_days_elapsed=0
  for ((d=1; d<current_day; d++)); do
    dow=$(date -d "$current_year-$current_month-$d" +%u)
    if (( dow >=1 && dow <=5 )); then
      ((business_days_elapsed++))
    fi
  done

  # Calculate business minutes elapsed
  if (( current_dow >=1 && current_dow <=5 )); then
    minutes_elapsed_business=$(( business_days_elapsed * 24 * 60 + 10#$current_hour * 60 + 10#$current_minute ))
  else
    minutes_elapsed_business=$(( business_days_elapsed * 24 * 60 ))
  fi

  # Calculate total business minutes
  total_business_minutes=$((business_days * 24 * 60))

  # Calculate business percentage
  if (( total_business_minutes > 0 )); then
    percentage_business=$(( minutes_elapsed_business * 100000 / total_business_minutes ))
    percentage_business_display=$(printf "%.3f" $(echo "$percentage_business" | awk '{print $1/1000}'))
  else
    percentage_business_display="0.000"
  fi

  # Create business bar graph
  filled_chars_business=$(( percentage_business * bar_length / 100000 ))

  # Build the business bar
  bar_business=""
  for ((i=1; i<=bar_length; i++)); do
    if (( i <= filled_chars_business )); then
      bar_business+="█"
    else
      bar_business+="░"
    fi
  done

  # Display results for business days
  printf ":  Business Days Progress: %s%%\n" "$percentage_business_display"
  printf "|  [%s]  |\n" "$bar_business"
  printf ":  Business minutes elapsed: %d / %d\n" $minutes_elapsed_business $total_business_minutes
  printf ":  Business hours elapsed: %d / %d\n" $((minutes_elapsed_business / 60)) $((total_business_minutes / 60))
  printf ":  Business day %d of %d business days\n" $((business_days_elapsed + (current_dow >=1 && current_dow <=5 ? 1 : 0))) $business_days
  printf "|                                                        |\n"
  printf "|……………………………………………………………………………………………………………………………………………………|\n"
  printf "|                                                        |\n"

  # --- YEAR PROGRESS SECTION ---
  # Calculate if leap year
  if (( (current_year % 4 == 0 && current_year % 100 != 0) || (current_year % 400 == 0) )); then
    days_in_year=366
  else
    days_in_year=365
  fi

  # Minutes, hours, days, weeks elapsed in year
  minutes_elapsed_year=$(( (10#$current_yday - 1) * 24 * 60 + 10#$current_hour * 60 + 10#$current_minute ))
  hours_elapsed_year=$(( minutes_elapsed_year / 60 ))
  days_elapsed_year=$((10#$current_yday))
  weeks_elapsed_year=$(printf "%.2f" "$(awk "BEGIN {print $days_elapsed_year/7}")")

  total_minutes_year=$((days_in_year * 24 * 60))
  total_hours_year=$((days_in_year * 24))
  total_days_year=$days_in_year
  total_weeks_year=$(printf "%.2f" "$(awk "BEGIN {print $days_in_year/7}")")

  percentage_year=$(( minutes_elapsed_year * 100000 / total_minutes_year ))
  percentage_year_display=$(printf "%.3f" $(echo "$percentage_year" | awk '{print $1/1000}'))

  filled_chars_year=$(( percentage_year * bar_length / 100000 ))
  bar_year=""
  for ((i=1; i<=bar_length; i++)); do
    if (( i <= filled_chars_year )); then
      bar_year+="█"
    else
      bar_year+="░"
    fi
  done

  # Display year progress
  printf ":  Year Progress: %s%%\n" "$percentage_year_display"
  printf "|  [%s]  |\n" "$bar_year"
  printf ":  Minutes elapsed: %d / %d\n" $minutes_elapsed_year $total_minutes_year
  printf ":  Hours elapsed: %d / %d\n" $hours_elapsed_year $total_hours_year
  printf ":  Days elapsed: %d / %d\n" $days_elapsed_year $total_days_year
  printf ":  Weeks elapsed: %s / %s\n" "$weeks_elapsed_year" "$total_weeks_year"
  printf "|                                                        |\n"
  printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
  printf "\n"
}

if [[ "$1" == "--watch" ]]; then
  while true; do
    clear
    print_progress
    sleep $WATCH_INTERVAL
  done
else
  print_progress
fi