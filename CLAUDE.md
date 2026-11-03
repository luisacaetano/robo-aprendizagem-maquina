# Trabalho — Proposta de Robô com Aprendizado de Máquina

**Cata-vento Seletivo.** Disciplina *Modelagem e Projeto de Algoritmos para o
Mercado Financeiro*, Prof. Alexandre Pimenta. Grupo: Luisa Caetano Araujo e
Raíssa Faria Ferreira. Enunciado em `Documentacao/Enunciado.pdf`. Entrega em
03/11/2026.

**Etapa atual: só a proposta** (texto + apresentação), sem código do robô. A
implementação vem na etapa seguinte.

## A ideia em uma página

- Base: a regra do ADX Cata-vento (Trabalho 01, `../ADX-Cata-vento`),
  afrouxada para ADX ≥ 20, gera **candidatos**. DMI 12 fixo.
- **Random Forest** (escolha da Luisa: "traz resultado bom, implementa fácil,
  LSTM é chato") filtra: estima P(alvo 3 ATR antes do stop 1,5 ATR, antes das
  17:30) e só entra se P ≥ p*. Rótulo pelas três barreiras.
- Walk-forward: 120 pregões (90 treino + 30 validação) → opera 20 → avança 20.
  WIN$ M15 2023–2026, ~40 ciclos fora da amostra.
- Objetivo para escolher hiperparâmetros e p*: fator de recuperação nas
  operações filtradas da validação, com custos; N ≥ 20 e FL ≥ 1,05.
- Implementação planejada: um único robô em MQL5, que treina dentro do MT5 com
  a ALGLIB (100 árvores; fração da amostra e variáveis por divisão na grade).
  Python e ONNX foram descartados.

O Algoritmo Genético foi a primeira escolha e foi trocado — não voltar a ele.

## Auditoria de 02/11/2026

Scripts e resultados em `Documentacao/Auditoria/`. Medido na ALGLIB real e no
histórico local do WIN$; os números de operação são uma simulação simplificada
em barras de 1 minuto, não um backtest no Testador.

- Mesma regra do Trabalho 01: 1,36 no WINV26 (77 pregões), 1,11 no WIN$ em 2026,
  ambos sem custos; com R$ 3 por operação, 1,13 e 0,92. Não apresentar o 1,36
  sozinho.
- Regra da proposta, sem filtro, 2023–out/2026: 1,09 sem custos e 1,03 com
  custos, cerca de 1.700 candidatos por 120 pregões, y = 1 em 12%.
- A folha da ALGLIB guarda a classe, e P é a fração de votos. Com réplicas da
  classe minoritária, o erro out-of-bag não serve como evidência.

## Arquivos

```
Proposta/Proposta_CataVento_Seletivo.html|.pdf        texto (A4), tópicos 4.1–4.5
Apresentacao/Slides_CataVento_Seletivo.html|.pdf|.pptx 14 lâminas, modo Apresentar (F)
Apresentacao/Slides_CataVento_Seletivo_Enxuta.html|.pdf|.pptx 12 lâminas em tópicos, sem implementação
```

PDF: Chrome headless `--print-to-pdf` com `--no-pdf-header-footer`. O PPTX tem
uma imagem por lâmina e as notas de fala: mudou o HTML, refaça as imagens e as
notas.

## Identidade visual dos slides — "Floresta noturna" (escolhida em 28/10)

Escolhida entre 5 ideias. Os decks anteriores (Trabalho 01, RSI Sniper) foram
referência de clima, **não molde** — ela recusou a cópia. Tokens: fundo
`#08120E` com radial `#12261D`, cartões `#0E1D17`/`#122419`, menta `#5EE6A8`
(com brilho), âmbar `#F2B84B`, vermelho `#F0626B`. Schibsted Grotesk + IBM
Plex Mono. A árvore de decisão com o caminho aceso é a marca (capa e
encerramento); o progresso é uma trilha de nós no rodapé. HTML autocontido,
sem dependência dos decks antigos.

## Pendências

- Decisões de desenho em aberto: com R$ 20 mil a fórmula dá quase sempre 1
  contrato; e 27,7% dos candidatos fecham com lucro às 17:30, mas contam y = 0.
- "1,26 → 1,34" só aparece nas anotações do Trabalho 01, sem relatório.
