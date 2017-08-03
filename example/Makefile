

targets = \
  nc/PersonType/diagram.svg \
  nc/PersonType/diagram.map \



default: ${targets}

%.svg %.map: %.dot
	dot -Tsvg -o$*.svg -Tcmapx -o$*.map $*.dot

%.svg.base64: %.svg
	base64 --wrap=0 $*.svg > $*.svg.base64

%/index.html: %/index.html.m4 %/diagram.map
	m4 --prefix-builtins --include=$* $< > $@

# %/index.md: %/index.md.m4 %/diagram.map
# 	m4 --prefix-builtins --include=$* $< > $@

# dot -Tsvg -o"$git_graphviz"/graph.svg -Tcmapx -o"$git_graphviz"/graph.map "$git_graphviz"/graph.dot
