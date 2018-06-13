
# XML Schema documentation generator

## Building

1. `./configure`

  Set up the build process for your local environment.  Variables you can set include:
  
  * `install_dir`: directory to where files will be copied for `make install`
  * `xml_catalog`: An XML catalog file identifying the schemas to be processed.
  
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

## Future work

### To do

1. Format the pages to look good.
1. Provide JSON Schema
1. Provide RDF Schema
1. Create landing pages for XML Schema types
    - right now the XSD types just point into the XSD specification.
    - We need to be able to see, e.g.,
        - What attributes are of type xs:boolean?
        - What simple types are extended from xs:string?
1. Clarify (to the user) the difference between open and closed JSON schema.

### Someday Maybe

1. Include a set of files that augment the documentation for components. This might include, for example, specific examples of use of a component. That would be in a page within the hierarchy for the component, with a given name.
1. Provide XML instance example
1. Provide RDF instance example
1. Provide JSON instance example

## Miscellaneous notes

### XML Schema specification

Documentation for xs:string <https://www.w3.org/TR/xmlschema-2/#string>

### Graphviz

HTML labels: <https://graphviz.gitlab.io/_pages/doc/info/shapes.html#html>
