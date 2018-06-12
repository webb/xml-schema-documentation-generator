
install_dir=../repo
build_dir=build

include build/definitions.mk

all_files = ${build_dir}/index.html ${namespaces:%=${build_dir}/%/index.html} ${components:%=${build_dir}/%/index.html}
install_files = ${all_files:${build_dir}/%=${install_dir}/%}

all: ${all_files}

install: ${install_files}

diagrams: ${components:%=${build_dir}/%/diagram.png.base64} ${components:%=${build_dir}/%/diagram.map}

dirs:
	mkdir -p ${components}

${build_dir}/%/diagram.png.base64: ${build_dir}/%/diagram.png
	base64 --wrap=0 $< > $@

${build_dir}/%/diagram.png ${build_dir}/%/diagram.map: ${build_dir}/%/diagram.dot
	dot -Tpng -o${build_dir}/$*/diagram.png -Tcmapx -o${build_dir}/$*/diagram.map $<

${install_dir}/%: ${build_dir}/%
	mkdir -p ${dir $@}
	cp $< $@



