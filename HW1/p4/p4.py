# Write a program that consumes pixel values and creates an image.
from PIL import Image
import ast

input_text_file = open("HW1/outputs/smiley2_text.txt", "r")

lines = input_text_file.readlines()
height, width = len(lines), lines[0].count(" ")

img = Image.new(mode="RGB", size=(height, width), color=(0, 0, 0))

for y in range(height):
    pixels = lines[y].split()

    for x in range(width):
        pixel = ast.literal_eval(pixels[x])
        img.putpixel((x, y), pixel)
        img.save("HW1/outputs/smiley2_recreate.png")
