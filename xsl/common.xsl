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

  <xsl:param name="xml-catalog-file" required="yes"/>

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

  <xsl:function name="f:resolve-type" as="element()">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="ref" as="xs:string"/>
    <xsl:variable name="qname" as="xs:QName"
                  select="resolve-QName($ref, $context)"/>
    <xsl:variable name="schema" as="element(xs:schema)"
                  select="f:resolve-namespace(namespace-uri-from-QName($qname))"/>
    <xsl:sequence select="$schema/xs:complexType[@name = local-name-from-QName($qname)]
                          | $schema/xs:simpleType[@name = local-name-from-QName($qname)]"/>
  </xsl:function>

  <xsl:function name="f:resolve-element" as="element()">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="ref" as="xs:string"/>
    <xsl:variable name="qname" as="xs:QName"
                  select="resolve-QName($ref, $context)"/>
    <xsl:variable name="schema" as="element(xs:schema)"
                  select="f:resolve-namespace(namespace-uri-from-QName($qname))"/>
    <xsl:sequence select="$schema/xs:element[@name = local-name-from-QName($qname)]"/>
  </xsl:function>

  <xsl:function name="f:resolve-namespace" as="element(xs:schema)">
    <xsl:param name="namespace" as="xs:string"/>
    <xsl:variable name="catalog-uri" as="element(catalog:uri)"
                  select="$xml-catalog-file/catalog:catalog/catalog:uri[@name = $namespace]"/>
    <xsl:sequence select="doc(resolve-uri($catalog-uri/@uri, base-uri($catalog-uri)))/xs:schema"/>
  </xsl:function>

  <xsl:function name="f:xs-component-get-qname" as="xs:QName">
    <xsl:param name="context" as="element()"/>
    <xsl:variable name="prefix" select="f:get-prefix($context)"/>
    <xsl:variable name="uri" select="f:get-target-namespace($context)"/>
    <xsl:variable name="local-name" as="xs:string"
                  select="$context/@name"/>
    <xsl:sequence select="QName($uri, concat($prefix, ':', $local-name))"/>
  </xsl:function>

  <xsl:function name="f:xs-component-get-relative-path" as="xs:string">
    <xsl:param name="context" as="element()"/>
    <xsl:variable name="qname" as="xs:QName" select="f:xs-component-get-qname($context)"/>
    <xsl:value-of select="concat(prefix-from-QName($qname), '/', local-name-from-QName($qname))"/>
  </xsl:function>

</xsl:stylesheet>