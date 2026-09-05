# Build an ASCII-to-decimal converter.

string_val = "Quang"
print("Input: " + string_val)

print("Output: ", end="")
for char in string_val:
    print(ord(char), end=" ")
