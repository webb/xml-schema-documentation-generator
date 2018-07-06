
# XML Schema documentation generator

The home for this package is on GitHub:
- Repository home: <https://github.com/webb/xml-schema-documentation-generator>
- Bugs, feature addtions, and other things to be changes are being tracked in the GitHub issue tracker: <https://github.com/webb/xml-schema-documentation-generator/issues>.
- Workflow is being managed in the issue status project board on GitHub: <https://github.com/webb/xml-schema-documentation-generator/projects/1>


## Building

1. `./configure`

  Set up the build process for your local environment.  Variables you can set include:
  
  * `install_dir`: directory to where files will be copied for `make install`
  * `xml_catalog`: an XML catalog file identifying the schemas to be processed.
  * `build_json`: has value <q>true</q> if you want JSON Schema to be generated in the output.
  
  Command-line would look like:
  
  ```
  $ ./configure install_dir=$PWD/../publish xml_catalog=$PWD/../NIEM-Releases/niem/xml-catalog.xml
  ```

2. `make`

  Process the schema files to produce indexes, diagrams, and pages for
  components. Results are put into diretory `build`.

3. `make install`

  Copy result files into directory for publication. You may want to set variable
  `install_dir` to be the directory for a git repository.

## What this software does

1. Produce a single set of XML namespace prefixes.
1. Produce a list of namesapces and components.
1. Generate directories for all of the output content.
1. Produce a list of relationships between components ("back links").
1. Produce diagram descriptions (dot files) for all the components.
1. Process the diagram descriptions into images and HTML link maps.
1. Produce all the HTML pages.
1. Install files into publication directory.

## Strategies

1. One prefix per namespace, and one namespace per prefix.
1. Only handle reference schemas & stuff from NIEM subsets.
1. Name the folders. HTML files are all `index.html`.
1. URI for a component looks like `${root}/${prefix}/${component-local-name}/index.html`
1. Provide anchors for the class of info being displayed:
    - `#diagram`
    - `#xml-schema`
    - `#json-schema`
1. Each component is a single page. What we put on each page is TBD, as much detail as is useful, but no more.
1. Graphviz images use maps for hotlinks to other component pages.

## Additional software

- Processing is run on **Java**.

- The **Saxon** XSLT processor does most of the processing for this package. The
  Saxon XSLT processor jar file is included in `/lib/jars`. See
  <http://saxon.sourceforge.net/#F9.8HE> for more info on Saxon.

- *Apache XML Commons Resolver* handles XML Catalog resolution for working with
   XML Catalogs offline. The jar file is included in `/lib/jars`. The jar may be
   obtained as part of Xerces, available from
   <http://xerces.apache.org/mirrors.cgi>.

- JSON is pretty-printed with *jq*, which is available from package
   managers such as [MacPorts](https://www.macports.org) and
   [Apt](https://wiki.debian.org/Apt).

- Diagrams are generated using *graphviz*, which is available from package
  managers.

## Miscellaneous notes

### JSON Schema

JSON Schema Validation specification: <http://json-schema.org/latest/json-schema-validation.html>

### XML Schema specification

Documentation for xs:string <https://www.w3.org/TR/xmlschema-2/#string>

### Graphviz

HTML labels: <https://graphviz.gitlab.io/_pages/doc/info/shapes.html#html>

### XML representation of JSON

This package uses an extended version of the JSON representation defined by XSLT 3.0. The package refers to the namespace "http://www.w3.org/2005/xpath-functions" with the prefix "j".

Extensions:

* Existing elements j:map, j:string, etc:
  * @key-style: if value is "qname", then the value of @key is interprted as a
    xs:QName that refers to a component.
* New element j:ref:
  * @key: works like above, using @key-style
  * @qname: the content of the value
  * @ref-style: interprets the above:
    - "definition": ref to #/definitions/$component-name, with the component name as an href.
    - otherwise, href to the named component.
* New element j:note: Contains HTML content that describes something about the result. Does not affect the resulting JSON, but provides a note that is displayed with the JSON.
