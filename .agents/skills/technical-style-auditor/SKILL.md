---
name: technical-style-auditor
description: Guidelines and inspection rules for formal academic engineering prose, impersonal third-person passive voice, elimination of LLM filler/tautologies, non-breaking spaces, and mandatory 3-step physical causality reasoning.
---

# SKILL: Technical Style Auditor (`technical-style-auditor`)

## 1. Contexto e Finalidade
Esta skill define as diretrizes de redação e os critérios de auditoria editorial para relatórios acadêmicos de engenharia elétrica da UFMG. Ela combate ativamente a prosa genérica e desestruturada gerada por modelos de linguagem, assegurando densidade conceitual, impessoalidade rigorosa e primazia da causalidade física em cada parágrafo.

---

## 2. Princípios de Redação Acadêmica (Referência Canônica `lab9`)

### 2.1. Impessoalidade e Voz Passiva Sintética
A narrativa técnica deve ser conduzida exclusivamente em terceira pessoa, recorrendo preferencialmente à voz passiva pronominal com a partícula "se":
- *Correto:* "Verifica-se a elevação da corrente...", "Determinou-se experimentalmente o conjugado...", "Deduzem-se as equações nodais...", "Observa-se o predomínio do ramo magnetizante...".
- *Incorreto:* "Nós calculamos...", "Como vimos na seção anterior...", "Podemos notar que a máquina desacelera...", "Eu medi...".

### 2.2. O Modelo de Raciocínio Físico em Três Etapas
Nenhum resultado numérico, gráfico ou equação deve ser introduzido sem a articulação do raciocínio físico correspondente:
1. **Condição Operacional Imposta:** Identificar a perturbação externa (ex.: aplicação de degrau de torque $T_L = \SI{20,6020}{\Nm}$ em $t = \SI{2,0}{\second}$).
2. **Causalidade Eletromecânica Interna:** Explicar o que ocorre no entreferro e nos enrolamentos (ex.: o rotor desacelera $\rightarrow$ o escorregamento relativo $s$ aumenta $\rightarrow$ a taxa de variação de fluxo cortando as barras da gaiola se eleva $\rightarrow$ correntes rotóricas são induzidas com maior amplitude $\rightarrow$ o conjugado eletromagnético cresce para restabelecer o equilíbrio dinâmico).
3. **Quantificação e Confronto:** Expressar a relação analítica exata, indicar o valor numérico simulado e demonstrar o desvio relativo percentual frente à tolerância ($\le \pm 2{,}0\%$).

### 2.3. Banlist Lexical Anti-IA (Clichês e Tautologias Proibidos)
São terminantemente proibidos os seguintes termos e construções artificiais comuns em LLMs:
- *"Desempenha um papel crucial / vital / fundamental"* $\rightarrow$ Substituir pela causa física direta ("Determina a amplitude do fluxo...", "Governa as perdas no cobre...").
- *"É interessante notar / Vale a pena destacar"* $\rightarrow$ Eliminar e afirmar o fato diretamente ("Evidencia-se que...", "Constata-se...").
- *"Uma sinfonia / Um balé de forças"* $\rightarrow$ Proibido em registro acadêmico formal.
- *"Como podemos observar claramente"* $\rightarrow$ Substituir por "A \Cref{...} ilustra...".
- *"Em conclusão, este trabalho foi de grande valia"* $\rightarrow$ Substituir por síntese objetiva dos resultados quantitativos obtidos.

### 2.4. Espaçamento Tipográfico e Não-Quebrabilidade
1. **Espaço Não-Quebrável (`~`):** Empregar o caractere `~` antes de citações (`\cite{...}`) e chamadas inline de valores e símbolos para prevenir quebras órfãs de linha (ex.: `$t = 5{,}0~\mathrm{s}$`, `$n = 1715~\mathrm{rpm}$`, `\cite{chapman2013fundamentos}`).
2. **Vírgulas Decimais:** Em equações fora do `siunitx`, isolar a vírgula decimal entre chaves (`$3{,}7\text{ kW}$`) para evitar que o compilador TeX interprete a vírgula como pontuação frasal com espaçamento aberto.
