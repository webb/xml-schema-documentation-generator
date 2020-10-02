
# XML Schema documentation generator

The home for this package is on GitHub:
- Repository home: <https://github.com/webb/xml-schema-documentation-generator>
- Bugs, feature addtions, and other things to be changes are being tracked in the GitHub issue tracker: <https://github.com/webb/xml-schema-documentation-generator/issues>.
- Workflow is being managed in the issue status project board on GitHub: <https://github.com/webb/xml-schema-documentation-generator/projects/1>


## Building

1. `./configure`

  Set up the build process for your local environment.  Variables you can set include:
  
  * `publish_dir` : (required) directory to where files will be published
  * `xml_catalog`: an XML catalog file identifying the schemas to be processed.
  * `build_json`: "true" if you want JSON Schema to be generated in the output, "false" otherwise.
  * `link_to_dirs`: "true" if you want references to go to directories (for hosting on a website), "false" if you want to link directly to HTML files (for browsing locally). 
  
  Command-line would look like:
  
  ```
  $ ./configure publish_dir=$PWD/../publish xml_catalog=$PWD/../NIEM-Releases/niem/xml-catalog.xml
  ```

2. `make`

  Process the schema files to produce indexes, diagrams, and pages for
  components. Results are put into diretory `build`.

3. `make install`

  Copy result files into directory for publication. You may want to set variable
  `publish_dir` to be the directory for a git repository.

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
  
  Saxon is downloaded from <https://iweb.dl.sourceforge.net/project/saxon/Saxon-HE/10/Java/SaxonHE10-2J.zip>

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

Validation is being run with <q>AJV</q>. Current version of AJV does not support
format "iri-reference".

### XML Schema specification

XML Schema built-in datatypes: <https://www.w3.org/TR/xmlschema-2/#built-in-datatypes>

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

## JSON Schema rendering of NIEM content as reusable components

We're producing JSON Schema that is intended to be *reusable* at the component
level. That means that additional JSON Schema definitions will add to & reuse
these JSON Schema definitions. This means that these definitions *must* validate
all valid instances.

Express type derivation with 'allOf'. 

There's no expression for element derivation.

Substitutable elements nerf `required`:

* You don't know what the substitutable elements will be.
* To serialize, you need to know what the substitable elements are.
* Even when an element is required, it is just a slot, which may be filled by
  another element that is substitutable for that element.
* So, because of substitutable elements, you can't make any elements *required*.

Substitutable elements make arrays weak:

* suppose you have an element A with m-n required occurrences.
* you might think you could represent this with a property A with a value of an
  array of m-n occurrences.
* However, you may substitute element B for A.
* This means that there may be 0-n occurrences of A, and may be 0-n occurences
  of B.
* Minimum array size does not indicate anything
* There's no way for a JSON Schema to indicate minimum cardinality of a
  property.

Typeless elements cause problems:

* We use typeless, abstract elements to define slots for substitutable elements.
* Typeless elements allow any content
* This isn't very useful.

# Using SVG instead of PNG

We can use SVG instead of PNG.

1. They handle the big diagrams (like `xs:token`), which break when Graphviz tries to render big bitmaps.
1. They're much smaller than PNGs.
1. This obviates maps; the SVGs have HREFs embedded in them. Also, Graphviz has an issue where maps don't align with SVG graphics, and that problem goes away.
1. To make HREFs work in SVG, you have to include them as `<object>` instead of `<img>`. If you make them `<img>`, then they're just static images with no hot links. Use:

   `<object type="image/svg+xml" data="diagram.svg"/>`
   
   (via [W3](https://www.w3.org/Graphics/SVG/IG/resources/svgprimer.html#SVG_in_HTML))
1. When links in SVG are clicked, they load the target page into the *object*'s frame instead of the entire page. To get the right behavior, you need to add `TARGET="_top"` to your Graphviz file:

   ```
<TD ALIGN="LEFT" 
    TARGET="_top" 
    HREF="../../cbrn/unitsText#diagram" 
    PORT="d11e3668" 
    TOOLTIP="A unit of measure for a value element. If used, the unit of 
             measure shall be as stated in the documentation for the element."     
    BGCOLOR="gray92">@cbrn:unitsText</TD>
```
1. You can't use data URIs with SVG, so no more embedding. The HREFs don't link to the right pages. I'm guessing something about the data URIs means the linker isn't starting from the location of the page.
1. As long as we're breaking the "page is a thing you can drag & drop" thing, we might as well link to the CSS instead of embedding it.
1. I can't get compressed SVG (`*.svgz`) to work. There's talk on the internet of setting MIME types in browsers to get it to work, but I can't get it to work *locally* in any browser.
