# Write a program that reads an image and prints its pixel values.

from PIL import Image

image = Image.open("HW1/assets/smiley2.png").convert("RGB")
output_text_file = open("HW1/outputs/smiley2_text.txt", "w")

for y in range(image.height):
    for x in range(image.width):
        r, g, b = image.getpixel((x,y))
        pixel = f"{r},{g},{b}"

        print(f"({pixel})", end=" ")
        output_text_file.write(f"({pixel})")
        output_text_file.write(" ")

    print()
    output_text_file.write("\n")

output_text_file.close()