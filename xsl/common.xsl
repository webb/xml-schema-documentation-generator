<xsl:stylesheet 
   exclude-result-prefixes="catalog ns xs f"
   version="2.0"
   xmlns:catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog"   
   xmlns:f="http://example.org/functions"
   xmlns:ns="http://example.org/namespaces"
   xmlns:xml="http://www.w3.org/XML/1998/namespace"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns="http://www.w3.org/1999/xhtml">

  <!-- context is an XML Catalog -->
  <xsl:param name="prefixes-file" required="yes"/>
  <xsl:variable name="prefixes" as="element(ns:namespace)+"
                select="$prefixes-file/ns:namespaces/ns:namespace"/>

  <!-- ================================================================== -->
  <!-- functions -->
  <!-- ================================================================== -->

  <xsl:function name="f:get-target-namespace" as="xs:string">
    <xsl:param name="context" as="element()"/>
    <xsl:variable name="target-namespace" as="xs:string"
                  select="root($context)/xs:schema/@targetNamespace"/>
    <xsl:sequence select="$target-namespace"/>
  </xsl:function>
  
  <xsl:function name="f:get-prefix" as="xs:string">
    <xsl:param name="context" as="element()"/>
    <xsl:variable name="target-namespace" select="f:get-target-namespace($context)"/>
    <xsl:variable name="prefix" as="xs:string"
                  select="$prefixes[@uri = f:get-target-namespace($context)]/@prefix"/>
    <xsl:sequence select="$prefix"/>
  </xsl:function>

  <xsl:function name="f:xs-component-get-definition" as="xs:string">
    <xsl:param name="context" as="element()"/>
    <xsl:value-of select="$context/xs:annotation[1]/xs:documentation[1]"/>
  </xsl:function>

</xsl:stylesheet>
