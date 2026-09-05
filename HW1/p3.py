# Write a program that reads an image and prints its pixel values.

from PIL import Image

def convert(pixel):
    if pixel == "(237, 28, 36)": return "R"

image = Image.open("HW1/assets/smiley2.png").convert("RGBA")
output_text_file = open("awersome_picture.txt", "w")

for y in range(image.height):
    for x in range(image.width):
        r, g, b, _ = image.getpixel((x,y))
        pixel = f"{r}, {g}, {b}"
        output_text_file.write(pixel)
        output_text_file.write(" ")
    output_text_file.write("\n")

output_text_file.close()