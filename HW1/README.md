# Assignment 1: Converter and Pixel System

### ASCII-to-Decimal Converter
This ASCII to Decimal Converter allows the user to input a string (for example, their name), and returns a space-delimited integer list of the ASCII Decimal values of each character in the input string.

### Number-base Converter
This Number-base Converter supports binary, decimal, octal, and hexadecimal where users can input a number in any of those 4 bases and it'll output the converted number for each of the 4 bases.
### Program reads an image and prints its pixel values
This program allows the user to input an image where it will use Pillow to extract the RGB values of each pixel in the image and then print it out for display and also saves it as a txt file for  the next program.
### Program consumes pixel values and creates an image
This program basically does the reverse of the previous program. It can take the same output txt file from the previous program and reconstruct it back into the original image.
### Test Cases
To thoroughly test the Number-base Converter, we include test cases such as boundary cases, including zero, the largest supported unsigned value, and at least one negative two's-complement value 