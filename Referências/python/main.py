import cpu
from cpu import CPU, escrever_na_memoria

def main():
    # estado inicial
    comandos = [0x20, 8,            # LDA # 8
                0x60, 6,            # LDB # 6
                0x48,               # ABA
                0x58, 0x12, 0x00]   # CAL EXIT

    escrever_na_memoria(0x100, comandos)

    # cpu.executar_comando(0x100)
    # cpu.executar_comando(0x102)
    
    # executar_comando(0x104)
    # executar_comando(0x105)

    cpu.executar_programa(0x100)
    
    print(f"B:{CPU.registrador_b:02X} A:{CPU.registrador_a:02X} IX:{CPU.registrador_ix:04X} PP:{CPU.registrador_pp:04X} CO:{CPU.registrador_co:04X} CC: z={CPU.registrador_z} n={CPU.registrador_n} r={CPU.registrador_r} d={CPU.registrador_d}")

if __name__ == '__main__':
    main()
