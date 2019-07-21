from PIL import Image

image = Image.open("test8Bits.png")
pixels = image.load()

out_file = open("image.mif", "w")

out_file.write("DEPTH = 8192;\nWIDTH = 8;\n\nADDRESS_RADIX = UNS;\nDATA_RADIX = HEX;\n\nCONTENT BEGIN\n")

for y in range(60):
    for x in range(80):
        out_file.write(str(x+y*80) + ": " + '{:x}'.format(pixels[x, y]) + ";\n")

out_file.write("[4800..8191]: 0;\nEND;")