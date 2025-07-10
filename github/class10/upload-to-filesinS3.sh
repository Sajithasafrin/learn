#!/bin/bash

# Define the S3 bucket name
S3_BUCKET="trial-demo-1234"

# Define years, months, and number of files per date
YEARS=(2023 2024 2025)
MONTHS=(10 11 12)
FILES_PER_DATE=1

# Function to check if date is valid
is_valid_date() {
    local year=$1
    local month=$2
    local day=$3
    
    # Check if date command can parse it (works on most systems)
    if date -d "$year-$month-$day" >/dev/null 2>&1; then
        return 0
    elif date -j -f "%Y-%m-%d" "$year-$month-$day" >/dev/null 2>&1; then
        # macOS date command
        return 0
    else
        return 1
    fi
}

# Function to get days in month
get_days_in_month() {
    local year=$1
    local month=$2
    
    # Get last day of month
    if command -v date >/dev/null 2>&1; then
        if date -d "$year-$month-01 +1 month -1 day" >/dev/null 2>&1 2>/dev/null; then
            # GNU date (Linux)
            date -d "$year-$month-01 +1 month -1 day" +%d
        else
            # macOS date or other systems - use cal command as fallback
            cal $month $year | awk 'NF {DAYS = $NF} END {print DAYS}'
        fi
    else
        # Fallback: assume common days
        case $month in
            02) if (( year % 4 == 0 && (year % 100 != 0 || year % 400 == 0) )); then echo 29; else echo 28; fi ;;
            04|06|09|11) echo 30 ;;
            *) echo 31 ;;
        esac
    fi
}

echo "Starting multi-date file upload to S3..."
echo "Bucket: $S3_BUCKET"
echo "Years: ${YEARS[*]}"
echo "Months: ${MONTHS[*]}"
echo "Files per date: $FILES_PER_DATE"
echo ""

TOTAL_FILES=0

# Loop through years
for YEAR in "${YEARS[@]}"; do
    echo "Processing year: $YEAR"
    
    # Loop through months
    for MONTH in "${MONTHS[@]}"; do
        echo "  Processing month: $YEAR-$MONTH"
        
        # Get number of days in this month
        DAYS_IN_MONTH=$(get_days_in_month $YEAR $MONTH)
        
        # Generate random dates for this month (5-10 dates per month)
        NUM_DATES=$((5 + RANDOM % 6))
        
        # Create array of random days
        SELECTED_DAYS=()
        for ((i=1; i<=NUM_DATES; i++)); do
            DAY=$((1 + RANDOM % DAYS_IN_MONTH))
            DAY=$(printf "%02d" $DAY)  # Format with leading zero
            SELECTED_DAYS+=($DAY)
        done
        
        # Remove duplicates and sort
        SELECTED_DAYS=($(printf '%s\n' "${SELECTED_DAYS[@]}" | sort -u))
        
        # Process each selected day
        for DAY in "${SELECTED_DAYS[@]}"; do
            DATE_STR="$YEAR-$MONTH-$DAY"
            
            # Validate date
            if ! is_valid_date $YEAR $MONTH $DAY; then
                echo "    Skipping invalid date: $DATE_STR"
                continue
            fi
            
            echo "    Creating files for date: $DATE_STR"
            
            # Create multiple files for this date
            for ((j=1; j<=FILES_PER_DATE; j++)); do
                RANDOM_NUMBER=$((1000 + RANDOM % 9000))  # 4-digit random number
                FILENAME="filename-$RANDOM_NUMBER-$DATE_STR.txt"
                
                # Create file with some dummy content
                cat > $FILENAME << EOF
This is dummy file number $j for date $DATE_STR
Generated on: $(date)
Random number: $RANDOM_NUMBER
File path: incoming/$FILENAME
Batch upload script execution
EOF
                
                # Upload to S3
                if aws s3 cp $FILENAME s3://$S3_BUCKET/files/; then
                    echo "      ✓ Uploaded: $FILENAME"
                    TOTAL_FILES=$((TOTAL_FILES + 1))
                else
                    echo "      ✗ Failed to upload: $FILENAME"
                fi
                
                # Clean up local file
                rm -f $FILENAME
            done
        done
    done
    echo ""
done

echo "Upload completed!"
echo "Total files uploaded: $TOTAL_FILES"
echo ""
echo "You can verify the uploads with:"
echo "aws s3 ls s3://$S3_BUCKET/files/ --recursive"