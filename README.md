# MIPRO

O Mipro (nome provisório, vem de MIcro PROcessador) é um simulador de processador de uma arquitetura customizada simples.

## Extensões de arquivos

### .prg

[WIP]

É um arquivo de texto simples onde cada linha possui uma instrução num formato suportado pela aplicação (por exemplo, `LDA #10`).

### .sta

[WIP]

É um arquivo de estado. Sua estrutura segue o padrão de arquivos de inicialização (*.ini*) e configuração (*.cfg*). Ele suporta duas seções: `inicio` e `fim`. A seção "inicio" é sempre obrigatória, ela descreve qual será o estado inicial que o simulador deve ter e pode substituir o estado atual se desejado. O simulador irá carregar todos os seus dados com as informações dessa seção. Já a seção "fim" é opcional, pois é usada apenas em casos de teste. 

Todos os campos **devem** ser preenchidos com algum valor válido para garantir estabilidade da aplicação. Existe, porém, um campo opcional que é o "memoria.substituicoes" que é tratado caso não seja definido; outros campos são inicializados com um "0", mas o "memoria.base", por exemplo, ao não ser definido, não permitirá a execução do programa da forma esperada.

Como mencionado anteriormente, arquivos de estado também são usados em testes, que começa com o estado inicial definido pela seção "inicio", e o estado final do simulador é comparado com os valores da seção "fim".

## Notas

* No MICRO3, apesar da execução da instrução `CAL` produzir o resultado correto, a seção de que realiza a demonstração da simulação da execução da instrução não está correta. A implementação dos passos da simulação não levou ao mesmo resultado da execução. Logo, foi necessário o desenvolvimento do zero dos microcódigos referentes à essa instrução em particular.

* Talvez trocar "transferir_ix_para_a", "transferir_ix_para_b" para ser apenas uma operação. Vai depender se houver outros casos em que só um é utilizado.

* Alguns registradores e flags foram renomeados. As flags eram chamadas de `z` (zero), `n` (negativo), `r` (carry, ou 'vai um') e `d` (descontinuidade ou excedente). Nesse projeto, as flags `r` e `d` foram alteradas para `c` (carry) e `o` (overflow) para assim ficarem com os nomes conhecidos na literatura inglesa. Esse tema se extendeu aos registradores: o `DON` se tornou `MBR` (memory buffer register), o `RAD` se tornou o `MAR` (memory address register), o `CO` (contador ordinal) se tornou `PC` (program counter) e o `DCOD` (decoficador) se tornou `IR` (instruction register).
A flag de overflow (também conhecido como "transbordo" e "estouro") é chamada de `v` em algumas literaturas. Stallings chama de `OF`.
Seria bom rever as menções nos recursos das instruções os nomes das flags e registradores. Também, os mnemônicos das instruções em si são referências aos nomes antigos das operações. Seria bom analisar se é necessário renomeá-los para nomes mais usados em literaturas ou se já estão a seguindo.

* A descrição da instrução `DIV` não faz sentido, muito menos sua execução visual. É explicitado que os registradores `A` e `B` são concatenados e enviados à `ULA entrada A` para ser o dividendo. Logo, nela terá um número de 2 bytes composto pela concatenação dos dois registradores mencionados. O parâmetro da instrução é enviado à `ULA entrada B` como o divisor. E o resultado seria armazenado em `A` e o resto em `B`. Mas não é garantido que o resultado será um número de 1 byte e caberá no registrador `A`. Ao realizar a execução visual, ela pára antes da realização da divisão, não mostrando o que realmente ocorre. Assim como no caso de `CAL`, será necessário presumir baseado no resultado da execução direta sem usar a inspeção visual como ferramenta.

## Referências
* [Documentação dos comandos do Micro3](referência.md), uma das maiores referências e inspirações pro projeto. As instruções desse simulador são baseadas nas existentes desse outro projeto.