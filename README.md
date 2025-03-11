# MIPRO

O Mipro (nome provisório, vem de MIcro PROcessador) é um simulador de processador de uma arquitetura customizada simples.

## Tela

A tela é uma ferramenta de visualização dos dados da memória. Ela tem dimensões 64x32 e a fim de reduzir espaço ocupado de memória, ela é monocromática e utiliza 1 bit para representar cada pixel, resultando num total de 2048 bits que equivalem à 256 bytes. Por causa disso, o espaço total livre da memória passa de 4096 bytes para 3840 bytes no caso em que ela for utilizada.
Vale lembrar também que a stack começa no endereço 0xFFF (4095) por padrão, então se a tela for utilizada, deve-se trocar o ponto inicial da stack para começar antes da tela no endereço 0xEFF (3839) usando a instrução LDP no programa, por exemplo.
Se não é desejado utilizar a tela, pode-se apenas a ignorar, não precisando realizar nenhuma operação pois a tela é passiva e só reflete os dados guardados na memória.

## Extensões de arquivos

### .prg

[WIP]

É um arquivo de texto simples onde cada linha possui uma instrução num formato suportado pela aplicação (por exemplo, `LDA #10`).

### .sta

[WIP]

É um arquivo de estado. Sua estrutura segue o padrão de arquivos de inicialização (*.ini*) e configuração (*.cfg*). Ele suporta duas seções: `inicio` e `fim`. A seção "inicio" é sempre obrigatória, ela descreve qual será o estado inicial que o simulador deve ter e pode substituir o estado atual se desejado. O simulador irá carregar todos os seus dados com as informações dessa seção. Já a seção "fim" é opcional, pois é usada apenas em casos de teste. 

Todos os campos **devem** ser preenchidos com algum valor válido para garantir estabilidade da aplicação. Existe, porém, um campo opcional que é o "memoria.substituicoes" que é tratado caso não seja definido; outros campos são inicializados com um "0", mas o "memoria.base", por exemplo, ao não ser definido, não permitirá a execução do programa da forma esperada.

Como mencionado anteriormente, arquivos de estado também são usados em testes, que começa com o estado inicial definido pela seção "inicio", e o estado final do simulador é comparado com os valores da seção "fim".

## Incrementação/Decrementação

As operações de incremento e decremento foram modificadas e funcionam de forma diferente do que o MICRO3. Todas as operações relacionadas são sempre enviadas à `ULA`, ao contrário do que era feita anteriormente, que ocasionava incrementação diretamente no próprio registrador. Isso também causa mudança no cálculo de flags, que vai ser mais abordado na seção sobre `Flags`. Para que essa mudança funcione, todas as instruções devem ser alteradas para que não existam microoperações do tipo `incrementar_registrador_??` para se tornarem microoperações na `ULA`, por exemplo: `"transferir_??_para_alu_a", "incrementar_um_na_alu_a_16_bits", "transferir_alu_saida_para_??"`. A mesma coisa ocorre na operação de decrementação.

## Flags

O comportamento de quando as flags são atualizadas foi alterado: as flags só são atualizadas quando uma operação na `ULA` é performada. A operação em si dita quais flags são atualizadas. No trabalho de Kleber e Lucas ele dizem que:

```
Um diferencial da arquitetura MICRO3 é que as instruções de carregamento também atualizam as flags. Essa funcionalidade foi implementada em VHDL ao direcionar
a instrução de carregamento para passar pela ULA, a qual é responsável por modificar as flags. Para garantir que o operando permaneça inalterado, realiza-se uma operação de soma com zero.
```

Atualmente, foi decidido por remover as atualizações de flags após carregamento. Uma das razões é que ainda não foi determinado se isso sempre é verdade, pois na instrução `XAB` não há atualização das flags; então teria que ser explorado se isso só ocorre especificamente durante o carregamento vindo da memória ou algo assim.
Outra razão da remoção foi por conta da decisão que apenas a `ULA` pode provocar a verificação das flags. Mas se for desejável manter o mesmo comportamento (após entendê-lo melhor), então seria possível usar a mesma abordagem do trabalho mencionado: adicionar microoperações nas intruções que provoque uma soma com zero na `ULA`, causando atualização nas flags que não cause nenhuma perturbação na execução.

## Notas

* No MICRO3, apesar da execução da instrução `CAL` produzir o resultado correto, a seção de que realiza a demonstração da simulação da execução da instrução não está correta. A implementação dos passos da simulação não levou ao mesmo resultado da execução. Logo, foi necessário o desenvolvimento do zero dos microcódigos referentes à essa instrução em particular.

* Talvez trocar "transferir_ix_para_a", "transferir_ix_para_b" para ser apenas uma operação. Vai depender se houver outros casos em que só um é utilizado.

* Alguns registradores e flags foram renomeados. As flags eram chamadas de `z` (zero), `n` (negativo), `r` (carry, ou 'vai um') e `d` (descontinuidade ou excedente). Nesse projeto, as flags `r` e `d` foram alteradas para `c` (carry) e `o` (overflow) para assim ficarem com os nomes conhecidos na literatura inglesa. Esse tema se extendeu aos registradores: o `DON` se tornou `MBR` (memory buffer register), o `RAD` se tornou o `MAR` (memory address register), o `CO` (contador ordinal) se tornou `PC` (program counter) e o `DCOD` (decoficador) se tornou `IR` (instruction register).
A flag de overflow (também conhecido como "transbordo" e "estouro") é chamada de `v` em algumas literaturas. Stallings chama de `OF`.
Seria bom rever as menções nos recursos das instruções os nomes das flags e registradores. Também, os mnemônicos das instruções em si são referências aos nomes antigos das operações. Seria bom analisar se é necessário renomeá-los para nomes mais usados em literaturas ou se já estão a seguindo.

* Na instrução `DIV` é explicitado que os registradores `A` e `B` são concatenados e enviados à `ULA entrada A` para formar o dividendo (ou seja, um número de 2 bytes), o parâmetro da instrução é enviado à `ULA entrada B` como o divisor, e a divisão ocorre. Na saída, apenas o nibble superior da divisão é mantido, enquanto o inferior é substituído pelo valor do resto. Esse número é então dividido e enviado para eventualmente popular os registradores `A` e `B`.
Após realizar alguns testes manuais e consultas, parece que o cálculo de divisão do Micro3 está incorreto. Então o cálculo desenvolvido nessa aplicação vai ser utilizada em seu lugar, logo, os resultados entre os simuladores serão diferentes.

## Fluxo de execução de um programa

Para executar um progama, primeiro é necessário digitar o código na caixa de Programa, em seguida, deve-se clicar no botão para salvar o código na memória. Quando isso acontece, começa uma rotina de compilação do código que irá linha a linha transformando os comandos de mnemônicos em bytes que serão salvos na memória.

### Compilação

O processo de compilação ocorre da seguinte forma: cada comando é passado por um regex que irá extrair informações daquela linha de código para criar um objeto `Instrução`. Pegando, por exemplo, a instrução `LDA#03`: o regex captura o mnemônico `LDA` e usa a estrutura da linha para determinar que o tipo de endereçamento é `imediato` por conta da `#`, por exemplo, e também capturar o parâmetro `03`. O objeto instrução será então populado da seguinte forma:

|                   |           |
|:-----------------:|:----------|
| Endereçamento     | imediato  |
| Mnemônico         | LDA       |
| Parâmetros        | 03        |

Esses dados são então convertidos para bytes 

### Descompilação

Já a descompilação 

## Referências
* [Documentação dos comandos do Micro3](referência.md), uma das maiores referências e inspirações pro projeto. As instruções desse simulador são baseadas nas existentes desse outro projeto.