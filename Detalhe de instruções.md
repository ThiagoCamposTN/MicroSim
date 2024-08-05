# Micro 3.41

## DOSBOX

```bash
mount c ./
c:
MICRO3~1.EXE
```

Para digitar o caractere `/` basta pressionar a tecla `;`

Para digitar `:` basta pressionar as teclas `shift+ç`.

Após executar o comando `c:`, é possível pressionar apenas `tab` que o executável aparecerá na linha de comando. Daí basta apertar `enter` para executar o software.

Ou pode rodar o seguinte comando no cmd (presumindo que está no diretório do executável):

```bash
dosbox -c "mount c ./" -c "c:" -c "MICRO3~1.EXE"
```

## Execução de alguns comandos

A seguir o passo a passo da execução de algumas instruções. Cada passo possui à sua esquerda ou um `número`, que indica em que passo do processador ele está, ou `-`, que indica que não é um passo mas que iniciou-se uma nova fase, ou `*` que mostra o resultado de uma modificação em algum registrador ou resultado de cálculos. Tanto as linhas com `*` quanto `-` não existem nos logs do MICRO3 original. A numeração em si também não aparece nos logs, apenas o texto.

### LDA #30

No micro3 padrão (sem modificações na  memória) existe um `LDA #30` no endereço `620`.

```
0620 : 20 30 LDA #30
```

|   #   | Passo a passo                                                         |
|:-----:| --------------------------------------------------------------------- |
|   *   | (Z=0; N=0; R=0; D=0)                                                  |
|   -   | Fase de acesso a instrução                                            |
|   1   | Em curso: Transferência em seguidaContador CO vers RAD                |
|   2   | Em curso: Transferência em seguidaRAD vers Endereço de Memória        |
|   3   | Em curso: Endereçamento de memoria                                    |
|   4   | Em curso: Leitura do conteudo do endereço de                          |
|   5   | Em curso: Transferência em seguidaDado de Memoria vers DON            |
|   6   | Em curso: Transferência em seguidaDON vers DCOD                       |
|   7   | Em curso: Incrementação Contador Ordinal CO                           |
|   -   | Fase de pesquisa e endereço operando                                  |
|   8   | Em curso: Transferência em seguidaContador Ordinal CO vers seguidaRAD |
|   9   | Em curso: Incrementação Contador Ordinal CO                           |
|   -   | Fase de execução LDA                                                  |
|   10  | Em curso: Transferência em seguidaRAD vers Endereço de Memória        |
|   11  | Em curso: Endereçamento de memoria                                    |
|   12  | Em curso: Leitura do conteudo do endereço de                          |
|   13  | Em curso: Transferência em seguidaDado de Memoria vers DON            |
|   14  | Em curso: Transferência em seguidaDON vers A                          |
|   15  | Em curso: Pondo no lugardos flags Zero e se Negativo                  |
|   *   | (Z=0; N=0; R=0; D=0)                                                  |
|   -   | Fim da execução gráfica, retorne ao menu                              |

### ADB #FC

No micro3 padrão (sem modificações na  memória) existe um `ADB #FC` no endereço `530`.

```
0530 : 64 FC ADB #FC
```

|   #   | Passo a passo                                                         |
|:-----:| --------------------------------------------------------------------- |
|   *   | (Z=0; N=0; R=0; D=0)                                                  |
|   *   | Registrador B: 08                                                     |
|   -   | Fase de acesso a instrução                                            |
|   1   | Em curso: Transferência em seguidaContador CO vers RAD                |
|   2   | Em curso: Transferência em seguidaRAD vers Endereço de Memória        |
|   3   | Em curso: Endereçamento de memoria                                    |
|   4   | Em curso: Leitura do conteudo do endereço de                          |
|   5   | Em curso: Transferência em seguidaDado de Memoria vers DON            |
|   6   | Em curso: Transferência em seguidaDON vers DCOD                       |
|   7   | Em curso: Incrementação Contador Ordinal CO                           |
|   -   | Fase de pesquisa e endereço operando                                  |
|   8   | Em curso: Transferência em seguidaContador Ordinal CO vers seguidaRAD |
|   9   | Em curso: Incrementação Contador Ordinal CO                           |
|   -   | Fase de execução ADB                                                  |
|   10  | Em curso: Transferência em seguidaRAD vers Endereço de Memória        |
|   11  | Em curso: Endereçamento de memoria                                    |
|   12  | Em curso: Leitura do conteudo do endereço de                          |
|   13  | Em curso: Transferência em seguidaDado de Memoria vers DON            |
|   14  | Em curso: Transferência em seguidaB vers UALA                         |
|   15  | Em curso: Transferência em seguidaDON vers UALB                       |
|   16  | Em curso: Operação de adição de 8 bits                                |
|   *   | 08 + FC = 104                                                         |
|   17  | Em curso: Transferência em seguidaUALS vers B                         |
|   *   | Registrador B: 04                                                     |
|   18  | Em curso: Pondo no lugarde todos os flags                             |
|   *   | (Z=0; N=0; R=1; D=0)                                                  |
|   -   | Fim da execução gráfica, retorne ao menu                              |


### SUA #23

No micro3 padrão (sem modificações na  memória) existe um `SUA #23` no endereço `459`.

```
0459 : 25 23 SUA #23
```

|   #   | Passo a passo                                                         |
|:-----:| --------------------------------------------------------------------- |
|   *   | (Z=0; N=0; R=0; D=0)                                                  |
|   *   | Registrador A: 00                                                     |
|   -   | Fase de acesso a instrução                                            |
|   1   | Em curso: Transferência em seguidaContador CO vers RAD                |
|   2   | Em curso: Transferência em seguidaRAD vers Endereço de Memória        |
|   3   | Em curso: Endereçamento de memoria                                    |
|   4   | Em curso: Leitura do conteudo do endereço de                          |
|   5   | Em curso: Transferência em seguidaDado de Memoria vers DON            |
|   6   | Em curso: Transferência em seguidaDON vers DCOD                       |
|   7   | Em curso: Incrementação Contador Ordinal CO                           |
|   -   | Fase de pesquisa e endereço operando                                  |
|   8   | Em curso: Transferência em seguidaContador Ordinal CO vers seguidaRAD |
|   9   | Em curso: Incrementação Contador Ordinal CO                           |
|   -   | Fase de execução SUA                                                  |
|   10  | Em curso: Transferência em seguidaRAD vers Endereço de Memória        |
|   11  | Em curso: Endereçamento de memoria                                    |
|   12  | Em curso: Leitura do conteudo do endereço de                          |
|   13  | Em curso: Transferência em seguidaDado de Memoria vers DON            |
|   14  | Em curso: Transferência em seguidaDON vers UALA                       |
|   *   | Registrador DON : 23                                                  |
|   15  | Em curso: Operação unaria complemento a2                              |
|   *   | Registrador UALS : DD                                                 |
|   16  | Em curso: Transferência em seguidaUALS vers DON                       |
|   17  | Em curso: Transferência em seguidaA vers UALA                         |
|   18  | Em curso: Transferência em seguidaDON vers UALB                       |
|   19  | Em curso: Operação de adição de 8 bits                                |
|   *   | 0 + 23 = DD                                                           |
|   20  | Em curso: Transferência em seguidaUALS vers A                         |
|   21  | Em curso: Pondo no lugarde todos os flags                             |
|   *   | (Z=0; N=1; R=0; D=0)                                                  |
|   -   | Fim da execução gráfica, retorne ao menu                              |

### ABA

No micro3 padrão (sem modificações na  memória) existe um `ABA` no endereço `026B`.

```
026B : 48 ABA
```

|   #   | Passo a passo                                                         |
|:-----:| --------------------------------------------------------------------- |
|   *   | (Z=0; N=0; R=0; D=0)                                                  |
|   *   | Registrador A: 00                                                     |
|   *   | Registrador B: 08                                                     |
|   -   | Fase de acesso a instrução                                            |
|   1   | Em curso: Transferência em seguidaContador CO vers RAD                |
|   2   | Em curso: Transferência em seguidaRAD vers Endereço de Memória        |
|   3   | Em curso: Endereçamento de memoria                                    |
|   4   | Em curso: Leitura do conteudo do endereço de                          |
|   5   | Em curso: Transferência em seguidaDado de Memoria vers DON            |
|   6   | Em curso: Transferência em seguidaDON vers DCOD                       |
|   7   | Em curso: Incrementação Contador Ordinal CO                           |
|   -   | Fase de execução ABA                                                  |
|   8   | Em curso: Transferência em seguidaA vers UALA                         |
|   9   | Em curso: Transferência em seguidaB vers UALB                         |
|   10  | Em curso: Operação de adição de 8 bits                                |
|   *   | 00 + 08 = 08                                                          |
|   11  | Em curso: Transferência em seguidaUALS vers A                         |
|   *   | Registrador A: 08                                                     |
|   12  | Em curso: Pondo no lugarde todos os flags                             |
|   *   | (Z=0; N=0; R=1; D=0)                                                  |
|   -   | Fim da execução gráfica, retorne ao menu                              |

### STA

No micro3 padrão (sem modificações na  memória) existe um `STA` no endereço `006E`.

```
006E : 11 0F 31 STA 0F31
```

|   #   | Passo a passo                                                             |
|:-----:| ---------------------------------------------------------------------     |
|   *   | (Z=0; N=0; R=0; D=0)                                                      |
|   *   | Registrador A: 00                                                         |
|   *   | Registrador B: 08                                                         |
|   -   | Fase de acesso a instrução                                                |
|   1   | Em curso: Transferência em seguidaContador CO vers RAD                    |
|   2   | Em curso: Transferência em seguidaRAD vers Endereço de Memória            |
|   3   | Em curso: Endereçamento de memoria                                        |
|   4   | Em curso: Leitura do conteudo do endereço de                              |
|   5   | Em curso: Transferência em seguidaDado de Memoria vers DON                |
|   6   | Em curso: Transferência em seguidaDON vers DCOD                           |
|   7   | Em curso: Incrementação Contador Ordinal CO                               |
|   -   | Fase de pesquisa e endereço operando                                      |
|   8   | Em curso: Transferência em seguidaContador Ordinal CO vers RAD            |
|   9   | Em curso: Transferência em seguidaRAD vers Endereço de Memória            |
|   10  | Em curso: Endereçamento de memoria                                        |
|   11  | Em curso: Leitura do conteudo do endereço de                              |
|   12  | Em curso: Transferência em seguidaDado de Memoria vers AUX                |
|   13  | Em curso: Incrementação RAD                                               |
|   14  | Em curso: Transferência em seguidaRAD vers Endereço de Memória            |
|   15  | Em curso: Endereçamento de memoria                                        |
|   16  | Em curso: Leitura do conteudo do endereço de                              |
|   17  | Em curso: Transferência em seguidaDado de Memoria vers DON                |
|   18  | Em curso: Transferência em seguidaregistrador 16 bits DON até AUX vers RAD|
|   19  | Em curso: Incrementação Contador Ordinal CO                               |
|   -   | Fase de execução STA                                                      |
|   20  | Em curso: Transferência em seguidaRAD vers Endereço de Memória            |
|   21  | Em curso: Endereçamento de memoria                                        |
|   22  | Em curso: Transferência em seguidaA vers DON                              |
|   23  | Em curso: Transferência em seguidaDON vers Dado de Memória                |
|   24  | Em curso: Escritura de octeto em memoria                                  |
|   *   | (Z=0; N=0; R=1; D=0)                                                      |
|   -   | Fim da execução gráfica, retorne ao menu                                  |

### LDA 0955

No micro3 padrão (sem modificações na  memória) existe um `LDA 0955` no endereço `C70`.

```
0C70 : 10 09 55 LDA 0955
```

|   #   | Passo a passo                                                         |
|:-----:| --------------------------------------------------------------------- |
|   *   | (Z=0; N=0; R=0; D=0)                                                  |
|   -   | Fase de acesso a instrução                                            |
|   1   | Em curso: Transferência em seguidaContador CO vers RAD                |
|   2   | Em curso: Transferência em seguidaRAD vers Endereço de Memória        |
|   3   | Em curso: Endereçamento de memoria                                    |
|   4   | Em curso: Leitura do conteudo do endereço de                          |
|   5   | Em curso: Transferência em seguidaDado de Memoria vers DON            |
|   6   | Em curso: Transferência em seguidaDON vers DCOD                       |
|   7   | Em curso: Incrementação Contador Ordinal CO                           |
|   -   | Fase de pesquisa e endereço operando                                  |
|   8   | Em curso: Transferência em seguidaContador Ordinal CO vers RAD        |
|   9   | Em curso: Transferência em seguidaRAD vers Endereço de Memória        |
|   10  | Em curso: Endereçamento de memoria                                    |
|   11  | Em curso: Leitura do conteudo do endereço de                          |
|   12  | Em curso: Transferência em seguidaDado de Memoria vers AUX            |
|   13  | Em curso: Incrementação RAD                                           |
|   14  | Em curso: Transferência em seguidaRAD vers Endereço de Memória        |
|   15  | Em curso: Endereçamento de memoria                                    |
|   16  | Em curso: Leitura do conteudo do endereço de                          |
|   17  | Em curso: Transferência em seguidaDado de Memoria vers DON            |
|   18  | Em curso: Transferência em seguidaregistrador 16 bits DON até AUX ver RAD |
|   19  | Em curso: Incrementação Contador Ordinal CO                           |
|   20  | Em curso: Incrementação Contador Ordinal CO                           |
|   -   | Fase de execução LDA                                                  |
|   10  | Em curso: Transferência em seguidaRAD vers Endereço de Memória        |
|   11  | Em curso: Endereçamento de memoria                                    |
|   12  | Em curso: Leitura do conteudo do endereço de                          |
|   13  | Em curso: Transferência em seguidaDado de Memoria vers DON            |
|   14  | Em curso: Transferência em seguidaDON vers A                          |
|   15  | Em curso: Pondo no lugardos flags Zero e se Negativo                  |
|   *   | (Z=0; N=0; R=0; D=0)                                                  |
|   -   | Fim da execução gráfica, retorne ao menu                              |