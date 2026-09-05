# Build a number-base converter supporting binary, decimal, octal, and hexadecimal.

while True:
    try:
        string_val = input("Enter a number in any base: ")

        decimal = int(string_val,0)
        decimal &= 0xFFFFFFFF #Constrain to 32 bits
        binary = bin(decimal)
        octal = oct(decimal)
        hexadecimal = hex(decimal)

        print(f"bin: {binary}")
        print(f"oct: {octal}")
        print(f"dec: {decimal}")
        print(f"hex: {hexadecimal}\n")
    except Exception as e:
        print(e)
