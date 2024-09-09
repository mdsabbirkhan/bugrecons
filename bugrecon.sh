#!/bin/bash

# BugRecon Interface
function bugrecon_interface() {
    # Prompt user for domain
    DOMAIN=$(zenity --entry --title="BugRecon" --text="Enter Domain (e.g., example.com):")

    if [ -z "$DOMAIN" ]; then
        zenity --error --text="No domain entered. Exiting..."
        exit 1
    fi

    # Prompt user to select a task
    OPTION=$(zenity --list --radiolist \
        --title="BugRecon" \
        --column="Select" --column="Task" \
        TRUE "Sub-Domain Discovery" \
        FALSE "HTTP Probing (httpx)" \
        FALSE "Extract URLs (WayBackUrls)" \
        FALSE "Subdomain TakeOver Check" \
        FALSE "Vulnerability Scan (Nuclei)" \
        FALSE "Vulnerability Scan with WayBackUrls")

    if [ -z "$OPTION" ]; then
        zenity --error --text="No option selected. Exiting..."
        exit 1
    fi

    # Execute the selected task
    case $OPTION in
        "Sub-Domain Discovery")
            # Run subfinder for subdomain discovery
            subfinder -d "$DOMAIN" -o subdomains.txt
            zenity --info --text="Subdomain discovery completed."
            zenity --text-info --title="Sub-Domain Results" --filename=subdomains.txt
            ;;
        "HTTP Probing (httpx)")
            # Run httpx for HTTP probing
            if [ ! -f subdomains.txt ]; then
                zenity --error --text="subdomains.txt not found. Please run 'Sub-Domain Discovery' option first."
                exit 1
            fi
            httpx -l subdomains.txt -o httpx_results.txt
            zenity --info --text="HTTP probing completed."
            zenity --text-info --title="Httpx Results" --filename=httpx_results.txt
            ;;
        "Extract URLs (WayBackUrls)")
            # Run WayBackUrls to get historical URLs
            echo "$DOMAIN" | waybackurls > waybackurls.txt
            zenity --info --text="URL extraction from Wayback Machine completed."
            zenity --text-info --title="WayBackUrls Results" --filename=waybackurls.txt
            ;;
        "Subdomain TakeOver Check")
            # Run subdomain takeover script
            python3 can-i-take-over-xyz/can-i-take-over-xyz.py -d "$DOMAIN" > takeover_results.txt
            zenity --info --text="Subdomain takeover check completed."
            zenity --text-info --title="Subdomain TakeOver Results" --filename=takeover_results.txt
            ;;
        "Vulnerability Scan (Nuclei)")
            # Run Nuclei vulnerability scanning
            if [ ! -f subdomains.txt ]; then
                zenity --error --text="subdomains.txt not found. Please run 'Sub-Domain Discovery' option first."
                exit 1
            fi
            nuclei -l subdomains.txt -o nuclei_results.txt
            zenity --info --text="Nuclei vulnerability scan completed."
            zenity --text-info --title="Nuclei Results" --filename=nuclei_results.txt
            ;;
        "Vulnerability Scan with WayBackUrls")
            # Run WayBackUrls and Nuclei scanning
            echo "$DOMAIN" | waybackurls | nuclei -l - -o nuclei_wayback_results.txt
            zenity --info --text="Nuclei vulnerability scan with Wayback URLs completed."
            zenity --text-info --title="Nuclei + WayBackUrls Results" --filename=nuclei_wayback_results.txt
            ;;
    esac
}

# Run the interface
bugrecon_interface
