---
name: latex-build-diagnoser
description: Prescribes patterns for parsing out/main.log, detecting fatal TeX errors, missing package dependencies, undefined citations/labels, and resolving overfull box issues.
---

# SKILL: LaTeX Build Diagnoser (`latex-build-diagnoser`)

## 1. Contexto e Finalidade
Esta skill prescreve as diretrizes determinísticas para execução headless de compilação LaTeX, parsing analítico do arquivo `out/main.log` e resolução de falhas estruturais, advertências de referências quebradas e estouros de margem tipográfica.

---

## 2. Padrão de Execução de Compilação
O ciclo de compilação homologado deve refletir exatamente as configurações do VS Code LaTeX Workshop em `.vscode/settings.json`:
```bash
cd docs/latex && latexmk -synctex=1 -interaction=nonstopmode -file-line-error -pdf -pdflatex="pdflatex %O %S --shell-escape" -outdir=out -auxdir=out main.tex
```

---

## 3. Matriz de Diagnóstico e Padrões de Busca no `main.log`

| Padrão Regex / Mensagem de Log | Categoria | Causa Raiz Típica | Ação de Remediação Mandatória |
|---|---|---|---|
| `^!\s*(.*)` | Erro Fatal | Sintaxe inválida, caractere UTF-8 não tratado no `listings`, comando inexistente | Localizar linha indicada no log e corrigir o código-fonte `.tex`. |
| `LaTeX Warning: Reference \`([^\']+)\' on page .* undefined` | Alerta Crítico | Rótulo (`\label`) ausente, grafado com erro ou não compilado | Inserir o `\label` correspondente ou sincronizar o nome do argumento. |
| `LaTeX Warning: Citation \`([^\']+)\' on page .* undefined` | Alerta Crítico | Chave BibTeX não encontrada em `02_referencias.bib` | Adicionar a entrada BibTeX e executar ciclo de compilação com bibtex. |
| `Overfull \\hbox \(([0-9\.]+)pt too wide\)` | Advertência Tipográfica | Tabela ultrapassando margem de texto ou equação em bloco indivisa | Envolver tabela em `\resizebox{\textwidth}{!}{...}` ou quebrar fórmula com `align`. |
| `LaTeX Error: File \'([^\']+)\' not found` | Erro de Asset | Imagem PNG ausente em `docs/latex/img/` ou pacote `.sty` faltando | Verificar cópia do arquivo para `img/` ou instalar pacote TeX Live. |

---

## 4. Runbook de Depuração de Falhas Frequentes

### 4.1. Caracteres Acentuados em `listings`
O ambiente `lstlisting` do LaTeX por padrão não decodifica bytes UTF-8 multi-byte (ex.: `ç`, `ã`, `é`) em comentários de código.
- *Solução:* Manter comentários de scripts em código-fonte ASCII puro (ex.: usar `carcaca`, `rotacao`, `tensao`) nas listagens de apêndice.

### 4.2. Estouro de Cabeçalho `fancyhdr`
Quando o título do documento ou cabeçalho de disciplina ocupa mais de uma linha:
- *Solução:* Configurar `\geometry{a4paper, margin=2.5cm, headheight=28pt}` no preâmbulo `00_config.tex`.

### 4.3. Conflito de Carregamento `hyperref` e `cleveref`
O pacote `cleveref` deve ser obrigatoriamente carregado **depois** do pacote `hyperref`.
- *Solução:* Preservar a ordem estrita no final de `00_config.tex`:
  ```latex
  \usepackage[colorlinks=true, allcolors=black]{hyperref}
  \usepackage[nameinlink, noabbrev, brazilian]{cleveref}
  ```
