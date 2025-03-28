#!/bin/bash

echo -ne "Enter file path for email list(\033[31mAll mails shoud be in seperate lines\033[0m):"
read path

if [ -e "$path" ]; then
    echo "The path exists."
else
    echo "The path does not exist."
    exit 1 
fi


echo " "

# Input file containing email list (one email per line)
EMAIL_LIST="$path"

# Output files for valid and invalid emails
VALID_OUTPUT="valid_gmails.txt"
INVALID_OUTPUT="invalid_gmails.txt"

# Clear previous results
> "$VALID_OUTPUT"
> "$INVALID_OUTPUT"

# Function to validate an email
check_email() {
    local email="$1"

    # Basic format check for Gmail addresses
    if ! [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@gmail\.com$ ]]; then
        echo "$email" >> "$INVALID_OUTPUT"
        return 0
    fi

    # SMTP check (Connect to Gmail's mail server and check email)
    SMTP_RESPONSE=$(echo -e "HELO test.com\nMAIL FROM:<test@gmail.com>\nRCPT TO:<$email>\nQUIT" | nc -w 2 gmail-smtp-in.l.google.com 25 2>/dev/null)
    
    # If the response contains "250 2.1.5 OK", the email is valid
    if echo "$SMTP_RESPONSE" | grep -q "250 2.1.5 OK"; then
        echo "$email" >> "$VALID_OUTPUT"
    else
        echo "$email" >> "$INVALID_OUTPUT"
    fi

    return 0  # Ensure function always returns normally
}

# Process each email one by one
while IFS= read -r email; do
    check_email "$email" || true
done < "$EMAIL_LIST"

echo "✅ Valid emails saved to: $VALID_OUTPUT"
echo "❌ Invalid emails saved to: $INVALID_OUTPUT"




