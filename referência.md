# MIPRO
Baseado em Micro3

![](Referências/image75.png "Endereçamento e Códigos")

## Maneiras de se incrementar um valor a um comando

### Endereço Imediato

Utiliza-se o sinal `#` na frente do comando seguido do valor desejado.

Exemplo:

```
LDA # x
```

Em que:

| Comando | Sinal | Valor |
|:--------|:-----:|:-----:|
|   LDA   |   #   |   x   |

### Endereço Direto

Indica-se o endereço de memória desejado na frente do comando. O valor carregado para execução do comando será aquele encontrado dentro do endereço indicado.

Exemplo:

```
LDA 0001
```

Em que:

| Comando | Valor |
|:-------:|:-----:|
|   LDA   |  0001 |

E na memória:

| Endereço | Valor |
|:--------:|:-----:|
| ...      |       |
|   0001   |   x   |
| ...      |       |

Onde `x` é o valor a ser considerado (carregado) e é o conteúdo do endereço de memória `0001`.

### Endereço Indexado

Indica-se um endereço de memória e um registro `X`. O valor carregado é aquele que está no endereço de memória formado pela soma do endereço indicado e o conteúdo do registro.

Exemplo:

```
LDA 3000, X
```

Em que:

| Comando | Endereço | Registro |
|:-------:|:--------:|:--------:|
|   LDA   |   3000   |    X     |

E na ULA

| Registro | Valor |
|:--------:|:-----:|
|    IX    |  0021 |

Onde `0021` é o endereço contido no registro `IX`.

O valor à ser carrregado será aquele que está no endereço de memória `3000` + `0021`, ou seja, o `0321`, logo, na mémoria:

| Endereço | Valor |
|:--------:|:-----:|
| ...      |       |
|   0321   |   42  |
| ...      |       |

### Endereço Indireto

Indica-se um endereço de memória entre colchetes. O valor carregado é aquele que está no endereço de memória formado pela concatenação do conteúdo do endereço indicado e o conteúdo de seu sucessor.

Exemplo:

```
LDA [3000]
```

Na memória:

| Endereço | Valor |
|:--------:|:-----:|
| ...      |       |
|   0102   |   4F  |
| ...      |       |
|   3000   |   01  |
|   3001   |   02  |
| ...      |       |

Logo, no registro `A`:

| Registro | Valor |
|:--------:|:-----:|
|    A     |   4F  |


O valor carregado é `4F`.

### Endereço Indireto Pré-Indexado

Indica-se um endereço de memória seguido de um registro, ambos entre colchetes. Soma-se o endereço de memória indicado com o conteúdo do registro; faz-se então a concatenação do conteúdo deste novo endereço formado com o conteúdo do seu sucessor. O valor carregado é o conteúdo deste último endereço.

Exemplo:

```
LDA [3000, X]
```

Logo, no registro `IX`:

| Registro | Valor |
|:--------:|:-----:|
|    IX    |   42  |


Na memória:

| Endereço | Valor |
|:--------:|:-----:|
| ...      |       |
|   3042   |   AF  |
|   3043   |   46  |
| ...      |       |
|   AF46   |   3   |
| ...      |       |

O valor carregado é `3` (três).

### Endereço Indireto Pós-Indexado

Indica-se um endereço de memória entre colchetes seguido de um registro. Faz-se a concatenação do conteúdo deste endereço de memória e o conteúdo de seu sucessor. Soma-se então o valor desta concatenação com o conteúdo do registro indicado. O valor do resultado encontrado é o endereço do valor a ser carregado.

Exemplo:

```
LDA [3000], X
```

Logo, no registro `IX`:

| Registro | Valor |
|:--------:|:-----:|
|    IX    |   46  |


Na memória:

| Endereço | Valor |
|:--------:|:-----:|
| ...      |       |
|   0146   |   26  |
| ...      |       |
|   3000   |   01  |
|   3001   |   00  |
| ...      |       |

Visita o endereço de memória `3000` e o seguinte (`3001`); concatena seus respectivos valores `01` e `00`, resultando em `0100`; soma `0100` com o valor `46` presente no registro, resultando em `0146` e; carrega o valor presente no endereço `0146`.

O valor carregado é `26` (vinte e seis).

### Endereço Implícito

Não é necessária a indicação de nenhum endereço de memória.

## Relatório dos Comandos do MICRO3

### ABA

* Add A to B
* Adição de A em B

| Código de Operação |  Tipo de Endereçamento  |
|:------------------:|:------------------------|
|         48         | Endereçamento implícito |

Soma o valor do registrador A com o registrador B e armazena o resultado em A.

[A] + [B] -> A

### ADA

* Add in A
* Adição em A

| Código de Operação |        Tipo de Endereçamento        |
|:------------------:|:------------------------------------|
|         24         | Endereçamento imediato              |
|         14         | Endereçamento direto                |
|         34         | Endereçamento indexado              |
|         94         | Endereçamento indireto              |
|         C4         | Endereçamento indireto pré-indexado |
|         B4         | Endereçamento indireto pós-indexado |

Adiciona ao registrador A o valor de um operando, e armazena o resultado nele mesmo (A).

[A] + operando -> A

### ADB

* Add in B
* Adição em B

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 64      | Endereçamento imediato |
| 54      | Endereçamento direto |
| 74      | Endereçamento indexado |
| D4  | Endereçamento indireto |
| F4      | Endereçamento indireto pré-indexado |
| E4      | Endereçamento indireto pós-indexado |

Adiciona ao registrador B o valor de um operando, e armazena o resultado nele mesmo (B).

[B] + operando -> B

   
### ANA

* And in A
* Função E lógico com A




| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 22      | Endereçamento imediato |
| 12      | Endereçamento direto |
| 32      | Endereçamento indexado |
| 92      | Endereçamento indireto |
| C2      | Endereçamento indireto pré-indexado |
| B2      | Endereçamento indireto pós-indexado |

Faz a função E lógico entre o registrador A e o operando, e armazena o resultado em A

[A] E operando -> A


### ANB

* And in B
* Função E lógico com B




| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 62      | Endereçamento imediato |
| 52      | Endereçamento direto |
| 72      | Endereçamento indexado |
| D2     | Endereçamento indireto |
| F2     | Endereçamento indireto pré-indexado |
| E2      | Endereçamento indireto pós-indexado |

Faz a função E lógico entre o registrador B e o operando e armazena o resultado em B.

[B] E operando -> B



### ARA

* Add carry in A
* Adição de carry em A




| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 26      | Endereçamento imediato |
| 16      | Endereçamento direto |
| 36      | Endereçamento indexado |
| 96      | Endereçamento indireto |
| C6     | Endereçamento indireto pré-indexado |
| B6      | Endereçamento indireto pós-indexado |

Adiciona ao registrador A o valor do operando e se o flag R (carry) estiver valendo 1 ele adiciona mais uma unidade ao registrador. Ao final armazena o resultado em A.
    
[A] + [R] + operando --> A


### ARB

* Add carry in B
* Adição de carry em B



| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 66      | Endereçamento imediato |
| 56      | Endereçamento direto |
| 76      | Endereçamento indexado |
| D6     | Endereçamento indireto |
| F6     | Endereçamento indireto pré-indexado |
| E6      | Endereçamento indireto pós-indexado |

Adiciona ao registrador B o valor do operando e se o flag R (carry) estiver valendo 1 ele adiciona mais uma unidade ao registrador. Ao final armazena o resultado em B.
    
[B] + [R] + operando -> B



### BRA

* Branch
* Desvio incondicional




| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 59      | Endereçamento direto |
| 79      | Endereçamento indexado |
| D9  | Endereçamento indireto |
| F9     | Endereçamento indireto pré-indexado |
| E9      | Endereçamento indireto pós-indexado |

Ocorre um desvio para a instrução cujo endereço é indicado (qualquer tipo de endereçamento), criando assim um loop.

CO (código de operação) <- AE (endereço indicado)



### BGE

* Branch if greater or equal
* Desvio se supeior ou igual



| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| A5      | Endereçamento direto |

Ocorre o desvio para a instrução indicada enquanto o valor chega for positivo, ou seja se o flag  N = 0. O endereçamento deve ser direto.

se [N] = 0 então CO <- AE



### BLE

* Branch if less or equal
* Desvio se inferior ou igual




| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| A3      | Endereçamento direto |

Ocorre o desvio para a instrução indicada enquanto o valor for zero ou negativo, ou seja se o flag  N = 1 ou Z = 1. O endereçamento deve ser direto.

se [N] = 1 ou [Z] = 1 então CO <- AE


### BNE

* Brance if not equal
* Desvio se diferente de zero





| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| A1      | Endereçamento direto |

Ocorre o desvio para a instrução indicada enquanto o valor for diferente de zero, ou seja se o flag Z = 0. O endereçamento deve ser direto.

se [Z] = 0 então CO <- AE


### BRD

* Branch if overflow
* Desvio se ultrapassada capacidade


| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| A7      | Endereçamento direto |

Ocorre o desvio para a instrução indicada se houver overflow, ou seja se o flag D = 1. O endereçamento deve ser direto.

se [D] = 1 então CO <- AE


### BRE

* Branch if equal
* Desvio se igual a zero

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| A0      | Endereçamento direto |

Ocorre o desvio para a instrução indicada se o valor for igual a zero, ou seja se o flag Z = 1. O endereçamento deve ser direto.

se [Z] = 1 então CO <- AE


### BRG

* Branch if greater
* Desvio se superior

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| A4      | Endereçamento direto |

Ocorre o desvio para a instrução indicada se o valor for positivo e diferente de zero, ou seja se o flag Z = 0 e N = 0. O endereçamento deve ser direto.

se [Z] = 0 e [N] = 0 então CO <- AE


### BRL

* Branch if less
* Desvio se inferior

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| A2      | Endereçamento direto |

Ocorre o desvio para a instrução indicada se o valor for negativo, ou seja se o flag N = 1. O endereçamento deve ser direto.

se  [N] = 1 então CO <- AE


### BRR

* Branch if carry
* Desvio se "vai 1"

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| A6      | Endereçamento direto |

Ocorre o desvio para a instrução indicada se houver o “carry”, ou seja se o flag R = 1. O endereçamento deve ser direto.

se  [R] = 1 então CO <- AE


### CAL

* Call
* Chama um sub-programa

|   Código de Operação  | Tipo de Endereçamento               |
|:---------------------:|:------------------------------------|
| 58                    | Endereçamento direto                |
| 78                    | Endereçamento indexado              |
| D8                    | Endereçamento indireto              |
| F8                    | Endereçamento indireto pré-indexado |
| E8                    | Endereçamento indireto pós-indexado |

Interrompe a execução do programa atual e chama um sub-programa, o qual tem seu início no endereço indicado.
O código da operação (CO) onde ocorre a interrupção é armazenado em dois endereços da pilha (PP).

[PP] - 1 <- ( [CO] ) 15-8     ;    [PP] <- ( [CO] + 3 ) 7-0 

O endereço na pilha (PP) passa para dois endereços anteriores. E o código de operação recebe o endereço indicado na instrução.

[PP] <- [PP] - 2    ;    CO <- AE

Frequentemente esse comando é acompanhado por `EXIT`, formando o mneumônico `CAL EXIT`, que equivale aos hexadecimais `58 12 00`.

### CLD

* Clear overflow
* Imprime zero no flag D

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 0D     | Endereçamento implícito |

Faz com que o flag D passe a valer zero (limpa o valor do flag).


### CRL

* Clear carry
* Imprime zero no flag R

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 0E      | Endereçamento implícito |

Faz com que o flag R passe a valer zero (limpa o valor do flag).


### CPA

* Compare A
* Comparação de A

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 27      | Endereçamento imediato |
| 17     | Endereçamento direto |
| 37      | Endereçamento indexado |
| 97      | Endereçamento indireto |
| C7     | Endereçamento indireto pré-indexado |
| B7      | Endereçamento indireto pós-indexado |

Subtrai um operando do valor do conteúdo de A, porém não armazena o resultado. A comparação é feita a medida que o usuário compara os flags anteriores com os atuais (após a execução do comando).

[A] - Operando


### CPB

* Compare B
* Comparação de B

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 67      | Endereçamento imediato |
| 57     | Endereçamento direto |
| 77      | Endereçamento indexado |
| D7  | Endereçamento indireto |
| F7     | Endereçamento indireto pré-indexado |
| E7      | Endereçamento indireto pós-indexado |

Subtrai um operando do valor do conteúdo de B, porém não armazena o resultado. A comparação é feita a medida que o usuário compara os flags anteriores com os atuais (após a execução do comando).

[B] - Operando

### CPX

* Compare IX
* Comparação de IX

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 2A  | Endereçamento imediato |
| 1A     | Endereçamento direto |
| 3A  | Endereçamento indexado |
| 9A     | Endereçamento indireto |
| CA     | Endereçamento indireto pré-indexado |
| BA     | Endereçamento indireto pós-indexado |

Subtrai um operando do valor do conteúdo de IX, porém não armazena o resultado. A comparação é feita a medida que o usuário compara os flags anteriores com os atuais (após a execução do comando).

[IX] - Operando


### DBN

* Decrement and branch
* Decrementação no desvio

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 5A     | Endereçamento direto |
| 7A  | Endereçamento indexado |
| DA     | Endereçamento indireto |
| FA     | Endereçamento indireto pré-indexado |
| EA     | Endereçamento indireto pós-indexado |

Decrementa o registrador IX e se o resultado for diferente de zero, então ocorre um desvio para o endereço indicado.

se [IX] ≠ 0 então CO <- AE senão CO <- [CO]+3


### DEA

* Decrement de A
* Decrementação de A

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 07     | Endereçamento implícito |

Subtrai uma unidade do conteúdo do registrador A.

A <- [A] -1


### DEB

* Decrement de B
* Decrementação de B

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 47     | Endereçamento implícito |

Subtrai uma unidade do conteúdo do registrador B.

B <- [B] -1


### DEP

* Decerment de PP
* Decrementação de PP

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 89     | Endereçamento implícito |

Subtrai uma unidade do conteúdo do registro PP.

PP <- [PP] -1


### DEX

* Decrement de IX
* Decrementação de IX

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 09     | Endereçamento implícito |

Subtrai uma unidade do conteúdo de IX.

IX <- [IX] -1


### DIV

* Divide
* Divisão inteira

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 6C      | Endereçamento imediato |
| 5C     | Endereçamento direto |
| 7C      | Endereçamento indexado |
| DC     | Endereçamento indireto |
| FC     | Endereçamento indireto pré-indexado |
| EC     | Endereçamento indireto pós-indexado |

Divisão inteira do conteúdo dos registradores B e A no modo de 16 bits (concatenação dos dois valores na base 2) pelo operando. O resultado é armazenado em A e o resto em B.

[B] : [A] ÷ operando

exemplo:
8
Se *A = 172<sub>(10)8</sub>* = *10101100<sub>(2)</sub>* e B = 180<sub>(10)</sub> = *10110100<sub>(2)</sub>* e operando = *2<sub>(10)</sub>*

|1|0|1|0|1|1|0|0|1|0|1|1|0|1|0|0|

|-----------*A<sub>(2)</sub>*----------|------------*B<sub>(2)</sub>*----------|

Logo *A* e *B* = *44212<sub>(10)</sub>* que dividido por *2* é igual a *22106<sub>(10)</sub>*

A <- quocient       ;     B <- resto


### INA

* Increment A
* Incrementação de A


| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 06  | Endereçamento implícito |

Soma uma unidade ao valor do registrador A.

A <- [A] +1


### INB

* Increment B
* Incrementação de B

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 46  | Endereçamento implícito |

Soma uma unidade ao valor do registrador B.

B <- [B] +1


### INP

* Increment PP
* Incrementação de PP

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 88  | Endereçamento implícito |

B

Soma uma unidade ao valor do registrador PP.

PP <- [PP] +1


### INX

* Increment IX
* Incrementação de IX

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 08      | Endereçamento implícito |

Soma uma unidade ao valor do registrador IX.

IX <- [IX] +1


### LDA

* Load A
* Carregamento de A

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 20      | Endereçamento imediato |
| 10     | Endereçamento direto |
| 30      | Endereçamento indexado |
| 90     | Endereçamento indireto |
| C0   | Endereçamento indireto pré-indexado |
| B0     | Endereçamento indireto pós-indexado |

Armazena em A o conteúdo do endereço de memória indicado.

A <- M [AE]


### LDB

* Load B
* Carregamento de B

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 60      | Endereçamento imediato |
| 50     | Endereçamento direto |
| 70      | Endereçamento indexado |
| D0     | Endereçamento indireto |
| F0   | Endereçamento indireto pré-indexado |
| E0     | Endereçamento indireto pós-indexado |

Armazena em B o conteúdo do endereço de memória indicado.

B <- M [AE]


### LDP

* Load PP
* Carregamento de PP

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 2B      | Endereçamento imediato |
| 1B     | Endereçamento direto |
| 3B      | Endereçamento indexado |
| 9B     | Endereçamento indireto |
| CB   | Endereçamento indireto pré-indexado |
| BB     | Endereçamento indireto pós-indexado |

Armazena em PP o conteúdo do endereço de memória indicado.

PP <- M [AE]


### LDX

* Load IX
* Carregamento de IX

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 28      | Endereçamento imediato |
| 18     | Endereçamento direto |
| 38      | Endereçamento indexado |
| 98     | Endereçamento indireto |
| C8   | Endereçamento indireto pré-indexado |
| B8     | Endereçamento indireto pós-indexado |

Armazena em IX o conteúdo do endereço de memória indicado.

IX <- M [AE]


### MUL

* Multiply
* Multiplicação

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 6B      | Endereçamento imediato |
| 5B  | Endereçamento direto |
| 7B      | Endereçamento indexado |
| DB     | Endereçamento indireto |
| FB  | Endereçamento indireto pré-indexado |
| EB     | Endereçamento indireto pós-indexado |

Multiplicação dos registradores B e A no modo de 16 bits (concatenação dos dois valores na base 2) pelo operando. A primeira metade do resultado (os primeiros 8 bits - peso fraco) é armazenado em A e a segunda metade (também 8 bits - peso forte) em B.

[B] : [A] * operando,    A <- peso fraco,     B <- peso forte


### NOA

* No A
* Não A

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 0F   | Endereçamento implícito |

Faz o complemento lógico do conteúdo de A.

A <- Não [A]


### NOB

* No B
* Não B

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 4F   | Endereçamento implícito |

Faz o complemento lógico do conteúdo de B.

B <- Não [B]


### NOP

* No Operation
* Instrução nula

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 00  | Endereçamento implícito |

Instrução sem efeito. Incrementa o valor do contador ordinal de 1 byte.


### ORA

* Or A
* OU A

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 23      | Endereçamento imediato |
| 13      | Endereçamento direto |
| 33      | Endereçamento indexado |
| 93      | Endereçamento indireto |
| C3      | Endereçamento indireto pré-indexado |
| B3      | Endereçamento indireto pós-indexado |

Faz a função OU inclusivo entre o registrador A e o operando, e armazena o resultado em A
[A] OU operando -> A


### ORB

* Or B
* OU B

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 63      | Endereçamento imediato |
| 53      | Endereçamento direto |
| 73      | Endereçamento indexado |
| D3      | Endereçamento indireto |
| F3      | Endereçamento indireto pré-indexado |
| E3      | Endereçamento indireto pós-indexado |

Faz a função OU inclusivo entre o registrador B e o operando e armazena o resultado em B.


[B] OU operando -> B


### PHA

* Push A
* Empilhar A

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 03   | Endereçamento implícito |

Armazena o conteúdo do registrador A no endereço de pilha PP.

 [PP] <- A    ;    PP <- [PP] - 1


### PHB

* Push B
* Empilhar B

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 43      | Endereçamento implícito |

Armazena o conteúdo do registrador B no endereço de pilha PP.

 [PP] <- B    ;    PP <- [PP] - 1


### PHF

* Push flags
* Empilhar os indicares

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 4E   | Endereçamento implícito |

Armazena o conteúdo do registrador de flag na pilha.

[PP] <- byte R0 D0 N0 Z0    ;    PP <- [PP] - 1


### PHX

* Push IX
* Empilhar IX

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 83  | Endereçamento implícito |

Armazena o conteúdo do registrador IX (2 bytes) em um endereço de pilha PP (1 byte) e no seu sucessor (1 byte).

[PP] - 1 <- [IX] 15-8    ;    [PP] <- [IX] 0-7

PP <- [PP] -2


### PPA

* Pop A
* Depilhar A

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 04  | Endereçamento implícito |

Retira o conteúdo do endereço de pilha PP e armazena no registrador A.

PP <- [PP] + 1 ; [A] <- M[[PP]]


### PPB

* Pop B
* Depilhar B

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 44  | Endereçamento implícito |

Retira o conteúdo do endereço de pilha PP e armazena no registrador B.

PP <- [PP] + 1 ; [B] <- M[[PP]]


### PPF

* Pop flags
* Depilhar os indicadores

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 4D     | Endereçamento implícito |

Retira o conteúdo do registrador de flag contido na pilha e armazena no microprocessador.
PP <- [PP] + 1

R <- M[[PP]]7    ;    D <- M[[PP]5,

N <- M[[PP]]3    ;    Z<- M[[PP]]1


### PPX

* POP IX
* Depilhar IX

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 84      | Endereçamento implícito |

Retira o conteúdo do registrador IX (2 bytes) contido na pilha e armazena no microprocessador.
PP <- PP + 2

IX 15-8 <- M[[PP]-1]    ;    IX 0-7 <- M[[PP]]


### RET

* Return
* Retorno

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 05      | Endereçamento implícito |

Retira o conteúdo (2 bytes) contido na pilha e o atribui ao código de operação atual.

PP <- PP + 2

CO 15-8 <- M[[PP]-1]    ;    CO 0-7 <- M[[PP]]

#todo
### SBA

* Subtract B from A
* Substração de B de A

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 49  | Endereçamento implícito |

Subtrai o conteúdo de B do conteúdo de A e armazena o resultado em A.

<center>A <-  [A] - [B]</center>


### SAA

* Shift arithmetic A
* Deslocamento aritmético de A

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 0C      | Endereçamento implícito |

Deslocamento do registrador A de uma posição à direita, recopiando no primeiro bit à esquerda o bit de sinal, ou seja se o número era ímpar ele continuará sendo.
 O resultado é o mesmo que uma divisão inteira por 2.

<center>A <- [A] ÷ 2</center>

Ex: *01001101* => *00100110*


### SAD

* Shift arithmetic double
* Deslocamento aritmético duplo

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 4C   | Endereçamento implícito |

Deslocamento dos dois registradores B e A, considerados como um só grupo de 16 bits (concatenação na base 2) de uma posição à direita, recopiando à esquerda o bit de sinal. O resultado é o mesmo que uma divisão inteira por 2.

<center>B : A <- ( [B] : [A] ) ÷ 2</center>

Ex: *[B] 10010001* *[A] 01001101* ==> *[B : A] 1100100010100110*


### SED

* Set overflow
* Imprime 1 no flag de descontinuidade

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 8D  | Endereçamento implícito |

Atribui o valor 1 ao flag D.

<center>D <- 1</center>


### SER

* Set carry
* Imprime 1 no flag de carry

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 8E  | Endereçamento implícito |

Atribui o valor 1 ao flag de carry.

<center>R <- 1</center>


### SLA

* Shift left A
* Deslocamento à esquerda de A

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 0A      | Endereçamento implícito |

Deslocamento do registrador A de uma posição à esquerda, colocando no último bit à direita o valor zero. O resultado é o mesmo que uma multiplicação por 2.

<center>A <- [A] * 2</center>

Ex: *01001101* => *10011010*


### SLD

* Shift left double
* Deslocamento à esquerda duplo

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 4A   | Endereçamento implícito |

Deslocamento dos dois registradores B e A, considerados como um só grupo de 16 bits (concatenação na base 2) de uma posição à esquerda, colocando no último bit à direita o valor zero. O resultado é o mesmo que uma multiplicação por 2.

<center>B : A <- ( [B] : [A] ) * 2</center>


Ex: <i>[B] 10010001</i> <i>[A] 01001101</i> ==> <i>[B : A] 0010001010011010</i>


### SRA

* Shift right A
* Deslocamento à direita de A

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 0B      | Endereçamento implícito |

Deslocamento do registrador A de uma posição à direita, colocando no último bit à esquerda o valor zero.

<center>A <- deslocamento de [A]</center>

Ex: <i>01001101</i> => <i>00100110</i>


### SRD

* Shift right double
* Deslocamento à direita duplo

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 4B   | Endereçamento implícito |

Deslocamento dos dois registradores B e A, considerados como um só grupo de 16 bits (concatenação na base 2) de uma posição à direita, colocando no último bit à esquerda o valor zero.

<center>B : A <- deslocamento de ( [B] : [A] )</center>

Ex: <i>[B] 10010001</i> <i>[A] 01001101</i> ==> <i>[B : A] 0100100010100110</i>


### STA

* Store A
* Armazenamento de A

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 11      | Endereçamento direto |
| 31      | Endereçamento indexado |
| 91      | Endereçamento indireto |
| C1  | Endereçamento indireto pré-indexado |
| B1      | Endereçamento indireto pós-indexado |

Recopia o conteúdo do registrador A para o endereço de memória indicado.

<center>AE <- [A]</center>


### STB

* Store B
* Armazenamento de B

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 51      | Endereçamento direto |
| 71      | Endereçamento indexado |
| D1  | Endereçamento indireto |
| F1  | Endereçamento indireto pré-indexado |
| E1      | Endereçamento indireto pós-indexado |

Recopia o conteúdo do registrador B para o endereço de memória indicado.

<center>AE <- [B]</center>


### STP

* Store PP
* Armazenamento de PP

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 1C      | Endereçamento direto |
| 3C      | Endereçamento indexado |
| 9C      | Endereçamento indireto |
| CC  | Endereçamento indireto pré-indexado |
| BC     | Endereçamento indireto pós-indexado |

Recopia o conteúdo do registrador PP para o endereço de memória indicado.

<center>AE <- [PP]</center>


### STX

* Store IX
* Armazenamento de IX

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 19      | Endereçamento direto |
| 39      | Endereçamento indexado |
| 99      | Endereçamento indireto |
| C9  | Endereçamento indireto pré-indexado |
| B9      | Endereçamento indireto pós-indexado |

Recopia o conteúdo do registrador IX para o endereço de memória indicado.

<center>AE <- [IX]</center>


### SUA

* Subtract from A
* Subtração de A

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 25      | Endereçamento imediato |
| 15      | Endereçamento direto |
| 35      | Endereçamento indexado |
| 95      | Endereçamento indireto |
| C5  | Endereçamento indireto pré-indexado |
| B5      | Endereçamento indireto pós-indexado |

Subtrai o operando do conteúdo do registrador A e armazena o resultado em A.

<center>A <- [A] - Operando</center>


### SUB

* Subtract from B
* Subtração de B

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 65      | Endereçamento imediato |
| 55      | Endereçamento direto |
| 75      | Endereçamento indexado |
| D5  | Endereçamento indireto |
| F5  | Endereçamento indireto pré-indexado |
| E5      | Endereçamento indireto pós-indexado |

Subtrai o operando do conteúdo do registrador B e armazena o resultado em B.

<center>B <- [B] - Operando</center>


### TAB

* Transfer A to B
* Transferência de A em B

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 41  | Endereçamento implícito |

Recopia o conteúdo do registrador A no registrador B.

<center>B <- [A]</center>


### TBA

* Transfer B to A
* Transferência de B em A

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 42  | Endereçamento implícito |

Recopia o conteúdo do registrador B no registrador A.

<center>A <- [B]</center>


### TDX

* Transfer double to IX
* Transferência do duplo B:A no IX

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 80  | Endereçamento implícito |

Recopia o "registrador duplo" B:A e armazena no registrador IX.

<center>IX<sub>15-8</sub> <- [B] ; IX<sub>7-0</sub> <- [A]</center>


### TPX

* Transfer of PP to IX
* Transferência de PP no IX

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 82  | Endereçamento implícito |

Recopia o registrador PP para o registrador IX.

<center>IX <- [PP]</center>


### TXD

* Transfer of IX to double
* Transferência de IX no duplo B:A

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 81  | Endereçamento implícito |

Recopia o registrador IX para o "registrador duplo" B:A.

<center>B <- [IX]<sub>15-8</sub> ; A <- [IX]<sub>7-0</sub></center>


### XAB

* Exchange A and B
* Permuta de A e de B

| Código de Operação | Tipo de Endereçamento |
|:-----:|:-----|
| 40  | Endereçamento implícito |

Permuta os conteúdos dos registradores A e B.
  
<center>AUX <- [A] ; A <- B ; B <- [AUX]</center>


## Lista de Comandos:

Todos os 72 comandos existentes.

* ~~ABA~~
* ~~ADA~~
* ~~ADB~~
* ANA
* ANB
* ARA
* ARB
* BGE
* BLE
* BNE
* BRA
* BRD
* BRE
* BRG
* BRL
* BRR
* ~~CAL~~
* CLD
* CRL
* CPB
* CPA
* CPX
* DEB
* DEA
* DEX
* DBN
* DEP
* INB
* INP
* INA
* INX
* ~~LDA~~
* ~~LDB~~
* LDP
* LDX
* ~~NOA~~
* NOB
* ~~NOP~~
* ORA
* ORB
* TPX
* ~~PHB~~
* ~~PHF~~
* PPA
* PPB
* PPF
* ~~PHA~~
* ~~RET~~
* SBA
* SRD
* ~~SUA~~
* SUB
* SLD
* SLA
* SRA
* SAD
* SAA
* ~~STA~~
* ~~STB~~
* STP
* STX
* TAB
* TBA
* ~~XAB~~
* ~~PHX~~
* PPX
* MUL
* DIV
* SED
* SER
* TDX
* TXD

## Operações Ilegais

Quando o programa se depara com uma operação ilegal, o código não é executado, sendo ignorado totalmente e o contador de programa é incrementado, da mesma forma como funciona a operação `NOP`. O programa notifica que uma operação ilegal foi executada e diz que opcode foi chamado. Não é possível visualizar uma operação ilegal.
