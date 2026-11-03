# Roteiro por falas — Cata-vento Seletivo

**Como usar:** o que está em negrito está escrito na lâmina. Encontre o trecho na
tela e fale o que vem depois dele. O resto da lâmina não precisa ser lido.

**Siglas:** o significado aparece entre parênteses na primeira vez que cada uma de
vocês fala a sigla. Depois de decorar, diga só a sigla, se o tempo apertar.

**Para passar a lâmina:** botão **Apresentar** ou tecla **F** para começar. Clique
para avançar, clique no quarto esquerdo da tela para voltar, ou role o mouse. As
setas do teclado também funcionam, e **Esc** sai.

---

# LUISA · lâminas 1 a 4

## 1 · Cata-vento Seletivo

- **Robô de day trade no Mini Índice:** Nosso trabalho é a proposta do Cata-vento Seletivo, um robô de day trade no Mini Índice, escrito em MQL5 (MetaQuotes Language 5, a linguagem do MetaTrader).
- **A regra do DMI/ADX propõe a entrada:** A regra do DMI (Directional Movement Index, índice de movimento direcional) e do ADX (Average Directional Index, índice direcional médio) propõe a entrada, e uma floresta de 100 árvores, treinada dentro do MetaTrader 5, estima se ela vale a pena.

## 2 · A mesma regra acerta num dia e erra no outro

- **Um sinal de DI com ADX forte às 10h:** Um sinal às 10h, logo depois de um gap, não é o mesmo sinal às 16h num dia parado. A regra fixa trata os dois igual.
- **O objetivo é um robô:** Nosso objetivo é um robô que aprende em que contexto o sinal funciona e só opera esses casos.
- **vantagem competitiva:** A vantagem é operar menos e melhor, descartando os sinais de baixa probabilidade.
- **A base ainda precisa ser provada:** A regra do Trabalho 01 fez 1,36 no WINV26 (Mini Índice com vencimento em outubro de 2026), em 77 pregões, e 1,11 no WIN$ (série contínua do Mini Índice) em 2026, sem custos. Com custos, seriam 1,13 e 0,92. A margem é fina.

## 3 · A regra propõe. A floresta decide.

- **mais permissiva de propósito:** A regra é a do Trabalho 01, com ADX mínimo de 20, e não 25, para gerar candidatos em excesso.
- **Candidato de compra:** O DI (Directional Indicator, indicador direcional) mostra quem está ganhando, e o ADX mostra se a disputa tem força. A compra pede DI+ (força da alta) acima do DI− (força da baixa), com ADX de pelo menos 20 e subindo. A venda é o espelho.
- **Filtro do modelo:** Depois, o modelo: só entra se P (a estimativa do modelo, de 0 a 1) for maior ou igual ao limiar p* ("p estrela", o valor mínimo para entrar).

## 4 · Quatro saídas, todas medidas em ATR

- **Stop loss:** As saídas usam o ATR (Average True Range, amplitude média verdadeira), o tamanho médio do movimento: stop em 1,5 ATR e alvo em 3 ATR. Depois de 1,5 ATR a favor, o stop vai para a entrada. Às 17h30, fecha tudo.
- **contratos =:** O tamanho da posição depende do risco, de 0,25% ou 0,50%, conforme a confiança do modelo.
- **Com R$ 20 mil:** Na prática, com R$ 20 mil e ATR mediano de 380 pontos, a fórmula dá 1 contrato quase sempre.
- **trava do dia:** São no máximo 4 operações por dia. O robô para após perder 1,5% do capital ou depois de 3 stops seguidos.

**Passe a palavra:** A Raíssa explica o modelo.

---

# RAÍSSA · lâminas 5 a 10

## 5 · Por que Random Forest

- **O problema é de classificação:** Dado o contexto no momento do sinal, a operação bate o alvo antes do stop, sim ou não?
- **meta-rotulagem:** É a meta-rotulagem de López de Prado: a regra escolhe o lado, e a floresta decide se entra.
- **Seis meses dão cerca de 1.700 candidatos:** Com cerca de 1.700 candidatos parecidos entre si, a floresta lida bem, e uma LSTM (Long Short-Term Memory, um tipo de rede neural) decoraria ruído. O genético não usa o contexto de cada operação, e a fuzzy (lógica difusa) depende de regras à mão.
- **Já existe no MetaTrader 5:** A ALGLIB (biblioteca de cálculo numérico), que vem com o MT5 (MetaTrader 5), tem o Random Forest. O robô treina e prevê em MQL5 (MetaQuotes Language 5), sem Python.

## 6 · Só vira ordem o que sobrevive às quatro etapas

- **DI dominante:** O sinal passa por quatro etapas: direção, força, filtros operacionais e, por fim, a floresta.
- **Cada árvore é um voto:** Cada árvore termina numa classe: bate o alvo ou não. P (a estimativa do modelo) é a fração de votos das 100 árvores.
- **sinal de compra às 10:45:** Por exemplo, 71 das 100 árvores votam em bater o alvo, então P é 0,71. O limiar do mês é 0,60, então o robô entra.

## 7 · Variáveis de entrada e rótulo

- **só com o passado:** O modelo vê 17 variáveis, em seis grupos, todas calculadas só com o passado.
- **Tudo que tem direção:** Tudo que tem direção é multiplicado pelo sentido. Assim, um único modelo serve para compra e venda.
- **método das três barreiras:** O rótulo vem das três barreiras: alvo, stop e 17h30. Cada sinal é simulado em barras de 1 minuto, com as mesmas saídas do robô.
- **y = 1:** O rótulo é 1 se sai no alvo, e 0 se sai no stop, no zero a zero ou às 17h30.

## 8 · Acurácia não paga conta. Fator de recuperação, sim.

- **78 combinações por ciclo:** Otimizamos o limiar p* ("p estrela", o valor mínimo para entrar) e dois hiperparâmetros, em 78 combinações por ciclo. A grade é pequena de propósito: quanto mais se testa, maior a chance de a melhor ser sorte.
- **F = Lucro ÷ Rebaixamento:** A função objetivo é o fator de recuperação, na validação e com custos, porque um modelo pode acertar muito e ainda perder dinheiro.
- **Mínimo de 20 operações:** A combinação precisa de pelo menos 20 operações e fator de lucro de 1,05. Se nenhuma passar, o robô não opera no ciclo seguinte.
- **As regras de DMI/ADX:** A regra e as saídas ficam fixas, para não multiplicar o risco de sobreajuste.

## 9 · Treina no passado, opera o mês seguinte, repete

- **treino · 90 pregões:** Cada ciclo treina em 90 pregões, valida nos 30 seguintes e opera 20 que o modelo nunca viu. Depois, a janela anda 20 pregões.
- **ciclos fora da amostra:** De 2023 a 2026, são cerca de 40 ciclos fora da amostra.
- **No Trabalho 01:** O Trabalho 01 não tinha um período fora da amostra planejado. Aqui, cada mês operado é um mês que o modelo nunca viu.

## 10 · Cada janela tem um motivo e uma referência

- **Nem curta, nem longa:** Janela curta tem poucos exemplos, e janela longa mistura regimes que já passaram. É o dilema do concept drift (quando o padrão dos dados muda com o tempo).
- **Nunca embaralhar o tempo:** A validação vem sempre depois do treino. Sem filtro, 30 pregões deram de 70 a 97 operações.
- **Walk-forward:** As execuções não se sobrepõem e formam uma só curva fora da amostra.
- **relatar, não escolher:** Também rodamos 60 e 250 pregões, só para relatar. Escolher a melhor depois seria sobreajuste à janela.

**Passe a palavra:** A Luisa mostra como isso roda no MetaTrader.

---

# LUISA · lâminas 11 a 14

## 11 · Tudo roda dentro do MetaTrader 5

- **Nenhuma etapa roda fora da plataforma:** Esse foi o ponto que o professor pediu para detalhar. Regra, variáveis, rótulos, treino e ordens estão no mesmo robô.
- **Primeiro tick do pregão:** A cada 20 pregões, o robô retreina, testa as combinações na validação e grava o modelo vencedor.
- **Cada barra de 15 minutos fechada:** A cada barra fechada, aplica a regra, calcula as 17 variáveis e obtém P. Se P for maior ou igual a p*, manda a ordem já com stop e alvo.
- **DFBuilderCreate:** À direita está o treino com a ALGLIB (biblioteca de cálculo numérico), sem biblioteca externa. DF é de Decision Forest (floresta de decisão).

## 12 · O mesmo robô no Testador e na conta

- **Um teste único já é o walk-forward:** No Testador, o robô retreina sozinho conforme o tempo simulado anda. Os primeiros 120 pregões são só aquecimento.
- **Antes do dinheiro real:** Na conta, antes do dinheiro real, são 20 pregões em conta demo, comparados com o que o Testador faria.
- **como conferimos o código:** Com o filtro desligado e os parâmetros do Trabalho 01, o robô precisa reproduzir as operações no WINV26.

## 13 · Como vamos saber se funcionou

- **Regra sem filtro:** Só conta o resultado fora da amostra, comparado com a regra sem filtro e com o Cata-vento original.
- **A hipótese se confirma:** A hipótese se confirma se o filtro superar a regra sem filtro em fator de recuperação. Se não superar, isso também é resultado, e será relatado.
- **plano de implementação:** A próxima etapa é regra e variáveis, rótulos, modelo com walk-forward, e relatório com conta demo.

## 14 · Agradecemos a atenção

- **atenção:** Partimos de uma regra com margem fina e usamos o Random Forest para escolher os sinais. Tudo é avaliado fora da amostra. Agradecemos a atenção e ficamos à disposição para perguntas.

---

## Se perguntarem

| Pergunta | Resposta curta |
|---|---|
| O robô já existe? | Não. Testamos a ALGLIB e medimos a regra sem filtro em script; é preliminar |
| Por que manter regra de 0,92? | 0,92 é a antiga. A nova, sem filtro: **1,09** e **1,03** com custos |
| P = 0,71 é 71% de chance? | Não. O treino é balanceado; P ordena os sinais |
| Quantos batem o alvo? | Cerca de **12%** · stop 33% · zero 10% · 17h30 44% |
| Lucro às 17h30 conta como erro? | Sim, **27,7%** dos candidatos. Vamos comparar na implementação |
| De onde vêm R$ 100 e R$ 114? | R$ 100 é 0,50% de R$ 20 mil. R$ 114 é o stop de 1 contrato: 1,5 × 380 × R$ 0,20 |
| Por que o DMI 12 fica fixo? | De 8 a 20, o fator ficou entre **1,24 e 1,42**, no WINV26 e sem custos |
| E se vierem poucos candidatos? | Com menos de 200 na janela, o treino passa a 180 pregões. Hoje são cerca de **1.700** |
| Se a mesma barra toca alvo e stop? | Conta como stop |
| Por que replicar exemplos? | A ALGLIB não aceita peso por classe; só no treino |
| Por que sem out-of-bag? | As réplicas enganam: **7,5%** quando o real era 50% |
| Treina rápido? | Menos de **5 s** por floresta, até 5.000 linhas |
| Por que 100 árvores? | Acima de 64 a 128, o ganho é pequeno |
| Por que não ONNX? | Open Neural Network Exchange (formato de troca de modelos). Modelo congelado, sem retreino na plataforma |
| O que é AUC? | Area Under the Curve (área sob a curva): se os sinais bons ficam acima dos ruins; 0,5 é o acaso |
| De onde vem 1,26 → 1,34? | Anotações do Trabalho 01, sem relatório |

## Se perguntarem o que é

| Termo | Fala |
|---|---|
| DMI | Directional Movement Index (índice de movimento direcional): o conjunto de DI+, DI− e ADX |
| DI | Directional Indicator (indicador direcional): mostra quem está ganhando, compradores ou vendedores |
| ADX | Average Directional Index (índice direcional médio): mostra a força da tendência, sem dizer a direção |
| ATR | Average True Range (amplitude média verdadeira): o tamanho médio do movimento do preço |
| VWAP | Volume Weighted Average Price: o preço médio do dia, ponderado pelo volume |
| MQL5 | MetaQuotes Language 5: a linguagem do MetaTrader 5 |
| LSTM | Long Short-Term Memory: um tipo de rede neural para sequências |
| WIN$ | Série contínua do Mini Índice: emenda os contratos e não é negociável |
| WINV26 | Mini Índice com vencimento em outubro de 2026 (V = outubro) |
| p* | "p estrela": o valor mínimo de P para entrar, escolhido a cada ciclo |
| Gap | Quando o mercado abre longe de onde fechou no dia anterior |

## Não diga

- **"Já tem vantagem medida"**
- **1,36 sozinho:** sempre com "WINV26, 77 pregões, sem custos"
- **"50,84% de acerto":** o real foi 27,2%
- **"P é a chance de acertar"**
