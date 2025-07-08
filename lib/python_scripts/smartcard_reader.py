

from smartcard.System import readers
from smartcard.util import toHexString

def get_response(connection, sw2):
    GET_RESPONSE = [0x00, 0xC0, 0x00, 0x00, sw2]
    return connection.transmit(GET_RESPONSE)

def read_record(connection, sfi, record, le=0x00):
    READ_RECORD = [0x00, 0xB2, record, (sfi << 3) | 0x04, le]
    response, sw1, sw2 = connection.transmit(READ_RECORD)
    if sw1 == 0x6C:  # Wrong Le, retry with correct length
        READ_RECORD[4] = sw2
        response, sw1, sw2 = connection.transmit(READ_RECORD)
    if sw1 == 0x90:
        print(f"Record {record} (SFI={sfi}):", toHexString(response))
        return response
    else:
        print(f"Failed to read record {record}: SW1={hex(sw1)} SW2={hex(sw2)}")
        return None

# Main script
r = readers()
connection = r[0].createConnection()
connection.connect()

# 1. Select PSE
SELECT_PSE = [0x00, 0xA4, 0x04, 0x00, 0x0E] + [0x31, 0x50, 0x41, 0x59, 0x2E, 0x53, 0x59, 0x53, 0x2E, 0x44, 0x44, 0xDF, 0x30, 0x31]
response, sw1, sw2 = connection.transmit(SELECT_PSE)
if sw1 == 0x61:
    response, sw1, sw2 = get_response(connection, sw2)
print("PSE Data:", toHexString(response))

# 2. Select Visa AID
SELECT_AID = [0x00, 0xA4, 0x04, 0x00, 0x07] + [0xA0, 0x00, 0x00, 0x00, 0x03, 0x10, 0x10]
response, sw1, sw2 = connection.transmit(SELECT_AID)
if sw1 == 0x61:
    response, sw1, sw2 = get_response(connection, sw2)

print("AID Data:", toHexString(response))

# ✅ Extract Application Label (tag 0x50) for Card Name
try:
    label_index = response.index(0x50)
    label_length = response[label_index + 1]
    label_bytes = response[label_index + 2 : label_index + 2 + label_length]
    card_name = ''.join(chr(b) for b in label_bytes)
    print(f"Card Name: {card_name}")
except ValueError:
    print("Card Name (tag 0x50) not found in AID response.")


# 3. Get Processing Options (GPO)
GPO = [0x80, 0xA8, 0x00, 0x00, 0x02, 0x83, 0x00, 0x00]
response, sw1, sw2 = connection.transmit(GPO)
if sw1 == 0x61:
    gpo_data, sw1, sw2 = get_response(connection, sw2)
    print("GPO Data:", toHexString(gpo_data))

# 4. Read Record 1 (SFI=1) - Track 2 Data
record_data = read_record(connection, sfi=1, record=1)

# 5. Extract PAN and Expiry (MM/YY)
if record_data:
    track2_start = record_data.index(0x57) if 0x57 in record_data else -1
    if track2_start != -1:
        length = record_data[track2_start + 1]  # length of Track 2 data
        track2_data = record_data[track2_start + 2 : track2_start + 2 + length]

        # Convert Track 2 binary to string
        track2_str = ''.join(f"{b:02X}" for b in track2_data)

        if 'D' in track2_str:
            pan, rest = track2_str.split('D', 1)
            expiry_yy = rest[:2]
            expiry_mm = rest[2:4]

            formatted_pan = ' '.join([pan[i:i+4] for i in range(0, len(pan), 4)])
            formatted_expiry = f"{expiry_mm}/{expiry_yy}"

            print(f"Card Number: {formatted_pan}")
            print(f"Expiry Date: {formatted_expiry}")



        name_start = record_data.index(0x4E) if 0x4E in record_data else -1
        if name_start != -1:
            name_bytes = record_data[name_start : name_start + 20]
            raw_name = ''.join([chr(b) for b in name_bytes if b not in [0x20, 0x5F]])
            name_parts = raw_name.split('/')
            formatted_name = f"{name_parts[1].title()} {name_parts[0].title()}" 
            print(f"Cardholder Name: {formatted_name}")
