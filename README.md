# WiFi Voucher Sender

**WiFi Voucher Sender** is a Termux-based automation script that monitors M-PESA payment SMS messages and automatically sends prepaid WiFi voucher codes to customers based on the amount received.

## Features

- Monitors SMS in real-time using `termux-sms-list`
- Detects M-PESA payment messages
- Extracts payment code, amount, and phone number
- Sends a matching voucher to the sender
- Removes used vouchers from inventory
- Logs all processed payments
- Beautifully color-coded terminal output

## Requirements

- [Termux](https://f-droid.org/en/packages/com.termux/)
- `jq` (for parsing JSON)
- SMS permissions
- An active SIM card that receives M-PESA SMS
- A list of vouchers in `vouchers.txt` in the format:

10:abc123 20:def456 50:ghi789

## Usage

1. Clone the repository:
 ```bash
 git clone https://github.com/Hoodmaster2/Wifi-Voucher-sender.git
 cd Wifi-Voucher-sender

2. Make the script executable:

chmod +x 4.sh


3. Run the script:

./4.sh


4. Sit back and relax as it handles your voucher sending automatically.



Example Output

[22:49:46] M-PESA SMS detected.
[22:49:46] Extracted Data -> Code: TEL9OPB4L9 | Amount: Ksh10.00 | Phone: 0111338206
[22:49:46] Sending voucher: abc123 to 0111338206...
[22:49:48] Voucher sent. Logging and updating voucher list...

Customizable

You can change the response SMS content in the script. Current version sends:

Here is your WiFi access voucher code. Tap "Sign in to network" to use this voucher. THANK YOU AND ENJOY.

License

MIT License


---

Developed with hustle by hoodmaster
