port = 2000
output = "{"
for x in range(20, 250):
    output += "\"192.168.1." + str(x) + "\"=\"" + str(port) + "\", "
    # print("\"192.168.1." + str(x) + "\"=\"" + str(port) + "\", ", end='')
    port += 1

output = output[:-2] + "}"
print(output)