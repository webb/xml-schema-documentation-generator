
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

