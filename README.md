

To build:

    1. Start in a build directory

       You will raise an error if you try to build in the source directory.

    2. Run "configure", providing:

       - output_dir=$dir: where to put resulting web pages

       - xml_catalog=$file.xml: an XML catalog file that conveys namespaces and
         locations of schema documents.

       $ ../source/configure output_dir=../repo/4.0 xml_catalog=../niem/xml-catalog.xml

    3. Build the files:

       $ make

    4. Install the files to the output directory.

       $ make install

This package doesn't need to know about what versions the schema pile is, or
even if it's a NIEM release or subset.

# notes

Documentation for a string is at:

https://www.w3.org/TR/xmlschema-2/#string

# todo

- replace resolve-component with attribute-get-qname
- rename f:get-href() to f:qname-get-href()
- eliminate use of f:xs-component-get-relative path
  - instead, use f:qname-get-href()
- Need landing pages for XML Schema types
  - right now the XSD types just point into the XSD specification.
  - We need to be able to see, e.g.,
    - What attributes are of type xs:boolean?
    - What simple types are extended from xs:string?


* Order

1. develop makefile dependencies
   1. get a list of namespaces
      1. one prefix per namespace
      2. one schemalocation per namespace

* Strategy:

1. One prefix per namespace.
2. Only reference schemas (for now) & profiles of reference schemas.
3. URI for a component looks like:

   ${root}/${prefix}/${component-local-name}

4. Each component is a single page. What we put on each page is TBD, as much detail as is useful, but no more.
5. Each page is a folder containing an index.md
6. Everything in Markdown, with images as PNGs via Graphviz.
7. Graphviz images use maps for hotlinks to other component pages.
8. Use Makefiles dependencies to build everything in parallel without rebuilding everything every time.
9. Every anchor needs to be semantically-based, not built with generate-id(), to be consistent across builds.

* Someday Maybe items:

1. Include in the source dir, or another dir, a set of pages that augment the documentation for a given component. This could be a pile of markdown and images that is somehow integrated with the generated pages. This might include, for example, specific examples of use of a component. That would be in a page within the hierarchy for the component, with a given name.
2. Provide sample JSON schema for a component as it appears in the XML schema.

* Issues
- How to narrow down visibility of components when viewing the full model? For example, PersonType has (1) a ton of properties, and (2) is the type of a ton of properties.
- Do we distinguish between attributes and elements?

* Page conventions

** Fonts
CSS fonts: https://www.w3.org/TR/css-fonts-3/
 ‘serif’, ‘sans-serif’, ‘cursive’, ‘fantasy’, and ‘monospace’

http://code.stephenmorley.org/html-and-css/the-myth-of-web-safe-fonts/

- sans-serif: font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;
- mono: font-family:'Courier New',Courier,monospace;

* Graph conventions
** Lists
- e.g., lists of elements, lists of types, etc.
- order
  - structures
  - nc
  - everything else, in alphabetical order
** Cardinality examples

- 1 
- 0-1
- 0-n
- 1-n
- 2-n
- 3-5
- 4-n

* Resources

- see ~/working/test-gen-xsd-diagrams/
- see /Users/wr/r/by-topic/graphviz/graphics-nc-PersonType.gv
