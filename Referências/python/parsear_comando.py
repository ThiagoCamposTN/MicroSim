import re

def parsear(linha):
    enderecamento_pos_indexado = re.match(r'([A-Z]{3}) \[(.+?),(.+?)\]', linha)
    if enderecamento_pos_indexado:
        # Endereçamento pós-indexado
        return ["pos_indexado"] + [x.strip() for x in enderecamento_pos_indexado.groups()]

    enderecamento_pre_indexado = re.match(r'([A-Z]{3}) \[(.+?)\]', linha)
    if enderecamento_pre_indexado:
        # Endereçamento pré-indexado
        return ["pre_indexado"] + [x.strip() for x in enderecamento_pre_indexado.groups()]

    enderecamento_indireto = re.match(r'([A-Z]{3}) (.+?),(.+)', linha)
    if enderecamento_indireto:
        # Endereçamento indireto
        return ["indireto"] + [x.strip() for x in enderecamento_indireto.groups()]

    enderecamento_imediato = re.match(r'([A-Z]{3}) #(.+)', linha)
    if enderecamento_imediato:
        # Endereçamento imediato
        return ["imediato"] + [x.strip() for x in enderecamento_imediato.groups()]

    enderecamento_direto = re.match(r'([A-Z]{3}) (.+)', linha)
    if enderecamento_direto:
        # Endereçamento direto
        return ["direto"] + [x.strip() for x in enderecamento_direto.groups()]

    enderecamento_implicito = re.match(r'([A-Z]{3})', linha)
    if enderecamento_implicito:
        # Endereçamento implicito
        return ["implicito"] + [x.strip() for x in enderecamento_implicito.groups()]
    
    return None

print(parsear("LDA # 10"))      # imediato
print(parsear("LDA 0001"))      # direto
print(parsear("LDA 3000, 56"))  # indireto
print(parsear("LDA [3000]"))    # pré-indexado
print(parsear("LDA [3000,56]")) # pós-indexado
print(parsear("ABA"))           # implícito
print(parsear("67"))            # invalido (não definido)
print(parsear("CAL EXIT"))      # direto