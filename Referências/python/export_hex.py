def is_char_graphic(character):
    if (character > 31 and character < 127) or (character > 160):
        return True
    return False

def main():
    memoria = None

    with open("MEMORIA.MEM", "rb") as f:
        memoria = f.read()

    intervals = int(len(memoria) / 16)

    final_row = []

    for i in range(intervals):
        text = f"{i*16:08X}\t"

        row = memoria[i*16:i*16+16]

        for i in row:
            text += f"{i:02X} "
        
        text = text[:-1]

        text += "\t\t"

        yote = [chr(x) if is_char_graphic(x) else "." for x in row]
        
        for j in yote:
            text += f"{j} "

        text = text[:-1]
        text += "\n"
        
        final_row.append(text)
        
    with open("MEMORIA.TXT", "w") as f:
        for i in final_row:
            f.writelines(i)


if __name__ == '__main__':
    main()
