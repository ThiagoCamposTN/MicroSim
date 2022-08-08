from cpu import CPU, escrever_na_memoria

def incrementar_contador(valor):
    CPU.registrador_co += valor

def decodificar_instrucao(instrucao):

    # LDA - endereçamento direto
    if instrucao == 0x20:
        incrementar_contador(1)
        CPU.registrador_rad = CPU.registrador_co
        incrementar_contador(1)
        endereco            = CPU.registrador_rad
        dado                = CPU.memoria[endereco]
        CPU.registrador_don = dado
        CPU.registrador_a   = CPU.registrador_don
        # calcular_z()
        # calcular_n()
    if instrucao == 0x60:
        incrementar_contador(1)
        CPU.registrador_rad = CPU.registrador_co
        incrementar_contador(1)
        endereco            = CPU.registrador_rad
        dado                = CPU.memoria[endereco]
        CPU.registrador_don = dado
        CPU.registrador_b   = CPU.registrador_don
        # calcular_z()
        # calcular_n()

def main():
    # estado inicial
    comandos = [0x20, 8,            # LDA # 8
                0x60, 6,            # LDB # 6
                0x48,               # ABA
                0x58, 0x12, 0x00]   # CAL EXIT

    escrever_na_memoria(0x200, comandos)

    CPU.registrador_co = 0x200

    # inicio da simulação

    CPU.registrador_rad     = CPU.registrador_co
    endereco                = CPU.registrador_rad
    dado                    = CPU.memoria[endereco]
    CPU.registrador_don     = dado
    CPU.registrador_dcod    = CPU.registrador_don

    decodificar_instrucao(CPU.registrador_dcod)
    
    print(f"B:{CPU.registrador_b:02X} A:{CPU.registrador_a:02X} IX:{CPU.registrador_ix:04X} PP:{CPU.registrador_pp:04X} CO:{CPU.registrador_co:04X} CC: z={CPU.registrador_z} n={CPU.registrador_n} r={CPU.registrador_r} d={CPU.registrador_d}")

if __name__ == '__main__':
    main()
