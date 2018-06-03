<stylesheet 
   version="2.0"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:ns="http://example.org/namespaces"
   xmlns:catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog"   
   xmlns="http://www.w3.org/1999/XSL/Transform">

  <output method="text" encoding="US-ASCII"/>

  <template match="ns:namespace">
    <text>mkdir -p &quot;</text>
    <value-of select="@prefix"/>
    <text>&quot;&#10;</text>
  </template>

  <template match="text()"/>

</stylesheet>
