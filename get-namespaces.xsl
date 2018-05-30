<?xml version="1.0" encoding="UTF-8"?>
<stylesheet 
  version="2.0">
  xmlns:catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog"
  xmlns:f="https://webb.github.io/niem-model-source/get-namespaces"
  xmlns="http://www.w3.org/1999/XSL/Transform" 

  <!-- walk through the catalogs, finding files and writing out namespace entries with file names. Keep it simple. Don't plan for anything not needed. -->


  <function name="get-namespaces" as="element(f:namespace)*">
    <param name="catalogs" as="document-node(element(catalog:catalog))*"/>
    
  </function>

</stylesheet>
