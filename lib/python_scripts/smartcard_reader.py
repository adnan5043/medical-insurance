from smartcard.System import readers
from smartcard.util import toHexString

def transmit_apdu(connection, apdu, description=""):
    print(f"> {description}: {' '.join(f'{x:02X}' for x in apdu)}")
    response, sw1, sw2 = connection.transmit(apdu)
    print(f"< SW1=0x{sw1:02X}, SW2=0x{sw2:02X}, Response: {toHexString(response)}\n")
    return response, sw1, sw2

def main():
    r = readers()
    if not r:
        print("No smart card readers found.")
        return

    connection = r[0].createConnection()
    connection.connect()
    print(f"Using reader: {r[0]}\n")

    # Step 1: Select Master File (3F00)
    transmit_apdu(connection, [0x00, 0xA4, 0x00, 0x0C, 0x02, 0x3F, 0x00], "Select MF (3F00)")

    # Step 2: Select ICA AID (UAE Emirates ID Application)
    ica_aid = [0xA0, 0x00, 0x00, 0x02, 0x47, 0x10, 0x01]
    transmit_apdu(connection, [0x00, 0xA4, 0x04, 0x0C, len(ica_aid)] + ica_aid, "Select ICA AID")

    # Step 3: Try selecting and reading from common EF file IDs
    file_ids_to_try = ["0001", "0002", "0003", "0101", "1001", "2001", "2F00", "3F01"]

    for file_id in file_ids_to_try:
        hi = int(file_id[:2], 16)
        lo = int(file_id[2:], 16)
        _, sw1, sw2 = transmit_apdu(connection, [0x00, 0xA4, 0x00, 0x0C, 0x02, hi, lo], f"Select EF {file_id}")
        if sw1 == 0x90:
            response, sw1, sw2 = transmit_apdu(connection, [0x00, 0xB0, 0x00, 0x00, 0xFF], f"Read Binary (EF {file_id})")
            if sw1 == 0x90:
                print(f"✅ Successfully read file {file_id} content:")
                print(toHexString(response))
                break
            else:
                print(f"❌ Read Binary failed for EF {file_id}")
        else:
            print(f"❌ EF {file_id} not found or not selectable.")

if __name__ == "__main__":
    main()
