import json

def main():
    memoria = None

    with open("/home/thiago/Documentos/Godot/Mipro/MEMORIA.MEM", "rb") as f:
        memoria = f.read()

    structure = {}
    for endereço, valor in enumerate(memoria):
        structure[f"{endereço:02X}"] = f"{valor:02X}"
    
    with open("/home/thiago/Documentos/Godot/Mipro/MEMORIA.TXT", 'w') as f:
        json.dump(structure, f)


if __name__ == '__main__':
    main()
