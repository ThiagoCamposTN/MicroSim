def ler_pbm(caminho_imagem):
    """Lê um arquivo PBM e retorna os pixels como uma lista de bits (1 para preto, 0 para branco)."""
    with open(caminho_imagem, "r") as arquivo:
        # Lê o cabeçalho
        formato = arquivo.readline().strip()  # P1 (ASCII) ou P4 (binário)
        if formato != "P1":
            raise ValueError("Apenas PBM no modo ASCII (P1) é suportado.")

        # Ignora comentários
        while True:
            linha = arquivo.readline().strip()
            if not linha.startswith("#"):
                break

        # Lê largura e altura
        largura, altura = map(int, linha.split())

        # Lê os pixels
        pixels = []
        for _ in range(altura):
            linha = arquivo.readline().strip()
            for i in linha:
                pixels.append(int(i))

    return pixels, largura, altura

def bits_para_bytes(bits):
    """Agrupa os bits em grupos de 8 e converte cada grupo em um byte (inteiro)."""
    bytes_inteiros = []
    for i in range(0, len(bits), 8):
        grupo = bits[i:i+8]  # Pega 8 bits
        byte = int("".join(map(str, grupo)), 2)  # Converte para inteiro
        bytes_inteiros.append(byte)
    return bytes_inteiros

def bytes_para_hexes(bytes_inteiros):
    """Converte os bytes inteiros em strings hexadecimais."""
    return [f'{byte:x}' for byte in bytes_inteiros]

def bytes_para_dict(bytes_inteiros, comeco=0):
    """Converte os bytes inteiros em um dicionário."""
    return {f'{i:x}': f'{byte:x}' for i, byte in enumerate(bytes_inteiros, start=comeco)}

def main(caminho_imagem):
    # Lê o PBM e extrai os pixels
    pixels, largura, altura = ler_pbm(caminho_imagem)

    # inverte os valores dos pixels para 1 ser branco e 0 ser preto
    pixels_invertidos = []
    for i in pixels:
        pixels_invertidos.append(1 - i)

    # agrupa os pixels em grupos de 8 (como bits) e os converte em um byte (inteiro)
    bytes_inteiros = bits_para_bytes(pixels_invertidos)

    # Converte os bytes inteiros em strings hexadecimais
    bytes_em_hexes = bytes_para_hexes(bytes_inteiros)

    # Converte os bytes inteiros em um dicionário
    bytes_em_dict = bytes_para_dict(bytes_inteiros, 0x0F00)

    # Exibe os resultados
    # print("Array de bits:", pixels_invertidos)
    # print("Array de inteiros:", bytes_inteiros)
    # print("Array em hexadecimal:", bytes_em_hexes)
    print("Array como dict:", bytes_em_dict)

# Exemplo de uso
caminho_imagem = "../miau.pbm"
main(caminho_imagem)