pandoc -f markdown-implicit_figures  --listings -H listings-setup.tex --toc -V geometry:"margin=1in" -V fontsize=12pt \
--resource-path="title:interface" \
title/README.md interface/README.md \
-o ofasm_interface.pdf

