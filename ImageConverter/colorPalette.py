R = [0, 36, 72, 108, 144, 180, 216, 255]
G = [0, 36, 72, 108, 144, 180, 216, 255]
B = [0, 85, 170, 255]

out_file = open("pallette.css", 'w')

for i in range(8):
    for y in range(8):
        for z in range(4):
            out_file.write(".Sanstitre { color: rgb(" + str(R[i]) + ", " + str(G[y]) + ", " + str(B[z]) + ") }\n")