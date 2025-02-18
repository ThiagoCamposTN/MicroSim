# MIPRO

O Mipro (nome provisório, vem de MIcro PROcessador) é um simulador de processador de uma arquitetura customizada simples.

## Extensões de arquivos

### .prg

[WIP]

É um arquivo de texto simples onde cada linha possui uma instrução num formato suportado pela aplicação (por exemplo, `LDA #10`).

### .sta

[WIP]

É um arquivo de estado. Sua estrutura segue o padrão de arquivos de inicialização (*.ini*) e configuração (*.cfg*). Ele suporta duas seções: `inicio` e `fim`. A seção "inicio" é sempre obrgatória, ela descreve qual será o estado inicial que o simulador deve ter e pode substituir o estado atual se desejado. O simulador irá carregar todos os seus dados com as informações dessa seção. Já a seção "fim" é opcional, pois é usada apenas em casos de teste. 

Todos os campos **devem** ser preenchidos com algum valor válido para garantir estabilidade da aplicação. Existe, porém, um campo opcional que é o "memoria.substituicoes" que é tratado caso não seja definido; outros campos são inicializados com um "0", mas o "memoria.base", por exemplo, ao não ser definido, não permitirá a execução do programa da forma esperada.

Como mencionado anteriormente, arquivos de estado também são usados em testes, que começa com o estado inicial definido pela seção "inicio", e o estado final do simulador é comparado com os valores da seção "fim".

## Referências
* [Documentação dos comandos do Micro3](referência.md), uma das maiores referências e inspirações pro projeto. As instruções desse simulador são baseadas nas existentes desse outro projeto.