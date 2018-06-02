<stylesheet 
   version="2.0"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:ns="http://example.org/namespaces"
   xmlns:catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog"   
   xmlns="http://www.w3.org/1999/XSL/Transform">

  <output method="text" encoding="UTF-8"/>

  <template match="ns:namespaces">
    <text>---&#10;</text>
    <text>title: Index&#10;</text>
    <text>---&#10;</text>
    <text>&#10;</text>
    <apply-templates select="ns:namespace"/>
  </template>

  <template match="ns:namespace">
    <text>- [</text>
    <value-of select="@prefix"/>
    <text>](</text>
    <value-of select="@prefix"/>
    <text>)&#10;</text>
  </template>

</stylesheet>
