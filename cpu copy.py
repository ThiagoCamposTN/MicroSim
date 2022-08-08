class CPU:
    # registradores
    registrador_a   = 0x00      # Registrador de 8 bits
    registrador_b   = 0x08      # Registrador de 8 bits
    registrador_co  = 0x0000    # Registrador de 16 bits
    registrador_ix  = 0x6E35    # Registrador de 16 bits
    registrador_pp  = 0x0FFF    # Registrador de 16 bits
    registrador_don = None      # Registrador de 8 bits
    registrador_aux = None      # Registrador de 8 bits
    registrador_rad = None      # Registrador de 16 bits
    registrador_z   = 0x0       # Registrador de 1 bit
    registrador_n   = 0x0       # Registrador de 1 bit
    registrador_r   = 0x0       # Registrador de 1 bit
    registrador_d   = 0x1       # Registrador de 1 bit

    # unidade de controle
    registrador_dcod= None  # Registrador de 1 bit

    # unidade lógica e aritmética
    ual_entrada_a   = None  # Registrador de 16 bits
    ual_entrada_b   = None  # Registrador de 16 bits
    ual_saida       = None  # Registrador de 16 bits

    # na documentação, memória teria 65536 Kib,
    # mas na prática a memória possui 4096 Kib
    memoria = [0] * 4096


def escrever_na_memoria(endereco_inicial, comandos):
    for k, dado in enumerate(comandos):
        CPU.memoria[endereco_inicial + k] = dado

# def executar_comando(endereço):
#     # Transferência do CO (Contador Ordinal) para o RAD (Registrador de Endereço);
#     CPU.registrador_rad = CPU.registrador_co

#     # Transferência do RAD para o Endereço de Memória via o BUS (Barramento) de Endereço;
#     endereco = CPU.registrador_rad

#     # O conteúdo da memória no endereço fornecido é lido;
#     dado = CPU.memoria[endereco]

#     # O valor é transferido ao DON (Registrador de Dados) via o BUS de Dados;
#     CPU.registrador_don = dado

#     # O valor é transferido ao DCOD (Decodificador de instrução);
#     CPU.registrador_dcod = CPU.registrador_don

#     # O CO é incrementado em 1;
#     CPU.registrador_co += 1

#     # Fase de execução da instrução presente no DCOD;
#     return decodificar_instrucao(CPU.registrador_dcod)

#     # Fim da execução.

def decodificar_instrucao(instrucao):
    # LDA - endereçamento direto
    if instrucao == 0x20:
        # Transferência do CO para o RAD
        CPU.registrador_rad = CPU.registrador_co

        # O CO é incrementado em 1
        CPU.registrador_co += 1

        # Transferência do RAD para o Endereço de Memória via o BUS de Endereço
        endereco = CPU.registrador_rad
    
        # O conteúdo da memória no endereço fornecido é lido
        dado = CPU.memoria[endereco]

        # O valor é transferido ao DON via o BUS de Dados
        CPU.registrador_don = dado

        # O valor é transferido do DON para o Registrador A
        CPU.registrador_a   = CPU.registrador_don

        # A flag Z (zero) é verificada
        # calcular_z()

        # A flag N (negativo) é verificada
        # calcular_n()
    
    # LDB - endereçamento direto
    if instrucao == 0x60:
        # Transferência do CO para o RAD
        CPU.registrador_rad = CPU.registrador_co

        # O CO é incrementado em 1
        CPU.registrador_co += 1

        # Transferência do RAD para o Endereço de Memória via o BUS de Endereço
        endereco = CPU.registrador_rad
    
        # O conteúdo da memória no endereço fornecido é lido
        dado = CPU.memoria[endereco]

        # O valor é transferido ao DON via o BUS de Dados
        CPU.registrador_don = dado

        # O valor é transferido do DON para o Registrador A
        CPU.registrador_b   = CPU.registrador_don

        # A flag Z (zero) é verificada
        # calcular_z()

        # A flag N (negativo) é verificada
        # calcular_n()
    
    # TODO: CAL EXIT - Consulta ao sistema, execução passo-a-passo impossível. Retorno ao monitor com CO = 0102
    if instrucao == 0x58:
        # Transferência do CO para o RAD
        CPU.registrador_rad = CPU.registrador_co

        # Transferência do RAD para o Endereço de Memória via o BUS de Endereço
        endereco = CPU.registrador_rad

        # O conteúdo da memória no endereço fornecido é lido
        dado = CPU.memoria[endereco]

        # O valor é transferido ao AUX via o BUS de Dados
        CPU.registrador_aux = dado

        # O RAD é incrementado em 1
        CPU.registrador_rad += 1

        # Transferência do RAD para o Endereço de Memória via o BUS de Endereço
        endereco = CPU.registrador_rad

        # O conteúdo da memória no endereço fornecido é lido
        dado = CPU.memoria[endereco]

        # O valor é transferido ao DON via o BUS de Dados
        CPU.registrador_don = dado

        # Os valores de DON e AUX são unidos e enviados ao registrador 16 bits RAD
        CPU.registrador_rad = (CPU.registrador_aux << 8) + CPU.registrador_don

        # O CO é incrementado em 2
        CPU.registrador_co += 2

        # Decrementação do registrador PP
        CPU.registrador_pp -= 1

        # Transferência do PP para o RAD
        CPU.registrador_rad = CPU.registrador_pp

        # Transferência do RAD para o Endereço de Memória via o BUS de Endereço
        endereco = CPU.registrador_rad

        # O conteúdo da memória no endereço fornecido é lido
        dado = CPU.memoria[endereco]

        # Transferência do CO para os registradores DON e AUX
        CPU.registrador_don = CPU.registrador_co & 0xff
        CPU.registrador_aux = CPU.registrador_co >> 8

        # O RAD é incrementado em 1
        CPU.registrador_rad += 1

        # Transferência do RAD para o Endereço de Memória via o BUS de Endereço
        endereco = CPU.registrador_rad

        # DON é transferido para a memória no endereço indicado
        CPU.memoria[endereco] = CPU.registrador_don

        # Decrementação do registrador PP
        CPU.registrador_pp -= 1

        # Transferência do RAD para o PP
        CPU.registrador_pp = CPU.registrador_rad

        return False
    
    return True

def executar_programa(endereço):
    em_execução = True

    # Inicia-se a fase de acesso à instrução;
    CPU.registrador_co = endereço

    while em_execução:
        # Transferência do CO (Contador Ordinal) para o RAD (Registrador de Endereço);
        CPU.registrador_rad = CPU.registrador_co

        # Transferência do RAD para o Endereço de Memória via o BUS (Barramento) de Endereço;
        endereco = CPU.registrador_rad

        # O conteúdo da memória no endereço fornecido é lido;
        dado = CPU.memoria[endereco]

        # O valor é transferido ao DON (Registrador de Dados) via o BUS de Dados;
        CPU.registrador_don = dado

        # O valor é transferido ao DCOD (Decodificador de instrução);
        CPU.registrador_dcod = CPU.registrador_don

        # O CO é incrementado em 1;
        CPU.registrador_co += 1

        em_execução = decodificar_instrucao(CPU.registrador_dcod)
    
        # Fim da instrução.
    
    # Fim da execução
