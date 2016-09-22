genbib.sh >temp.bib &&
uvozovky proposal.pandoc | pandoc -sS --bibliography=temp.bib -o document.tex --latex-engine=xelatex -V lang="czech" --template ./template.tex &&
xelatex document.tex &&
xelatex document.tex

# uvozovky final_IS2014.pandoc | pandoc --template pandoc_template.tex -o document.tex &&
# xelatex
