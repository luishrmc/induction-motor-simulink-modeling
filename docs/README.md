# Documentação e Relatórios Técnicos

Esta pasta armazena o relatório acadêmico técnico final do projeto em formato Markdown estruturado e em PDF diagramado para impressão e entrega:

- [`RELATORIO_FINAL_SIMULACAO.md`](RELATORIO_FINAL_SIMULACAO.md): Relatório técnico final completo contendo fundamentação teórica, deduções matemáticas, tabelas comparativas e análise física dos resultados.
- [`RELATORIO_FINAL_SIMULACAO.pdf`](RELATORIO_FINAL_SIMULACAO.pdf): Documento PDF final compilado a partir do Markdown com formatação acadêmica e figuras em alta resolução.

Para compilar novamente o relatório em PDF (caso o Markdown seja modificado):
```bash
cd docs
pandoc RELATORIO_FINAL_SIMULACAO.md -o RELATORIO_FINAL_SIMULACAO.pdf --pdf-engine=xelatex -V geometry:margin=2cm
```
