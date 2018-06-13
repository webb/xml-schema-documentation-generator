
# input variables: ###############################################################
# install_dir: where content gets published
# build_dir: temporary directory for creating content
# definitions_mk: dynamically generated makefile definitions listing namespaces
#     and components

include ${definitions_mk}

all_files = \
  ${build_dir}/index.html \
  ${namespaces:%=${build_dir}/%/index.html} \
  ${components:%=${build_dir}/%/index.html}

install_files = ${all_files:${build_dir}/%=${install_dir}/%}

#############################################################################
.PHONY: dirs
dirs:
	mkdir -p ${components}

#############################################################################
.PHONY: diagrams
diagrams: ${components:%=${build_dir}/%/diagram.png.base64} ${components:%=${build_dir}/%/diagram.map}

${build_dir}/%/diagram.png.base64: ${build_dir}/%/diagram.png
	base64 --wrap=0 $< > $@

${build_dir}/%/diagram.png ${build_dir}/%/diagram.map: ${build_dir}/%/diagram.dot
	dot -Tpng -o${build_dir}/$*/diagram.png -Tcmapx -o${build_dir}/$*/diagram.map $<

#############################################################################
.PHONY: install
install: ${install_files}

${install_dir}/%: ${build_dir}/%
	mkdir -p ${dir $@}
	cp $< $@




