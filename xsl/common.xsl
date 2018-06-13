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
  
  <xsl:function name="f:uri-get-prefix" as="xs:string">
    <xsl:param name="uri" as="xs:string"/>
    <xsl:variable name="prefix" as="xs:string"
                  select="$prefixes[@uri = $uri]/@prefix"/>
    <xsl:sequence select="$prefix"/>
  </xsl:function>

  <xsl:function name="f:xs-get-prefix" as="xs:string">
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

  <xsl:function name="f:qname-resolve-type" as="element()?">
    <xsl:param name="qname" as="xs:QName"/>
    <xsl:variable name="schema" as="element(xs:schema)?"
                  select="f:resolve-namespace(namespace-uri-from-QName($qname))"/>
    <xsl:if test="exists($schema)">
      <xsl:sequence select="$schema/xs:complexType[@name = local-name-from-QName($qname)]
                            | $schema/xs:simpleType[@name = local-name-from-QName($qname)]"/>
    </xsl:if>
  </xsl:function>

  <xsl:function name="f:qname-resolve-attribute" as="element(xs:attribute)?">
    <xsl:param name="qname" as="xs:QName"/>
    <xsl:variable name="schema" as="element(xs:schema)?"
                  select="f:resolve-namespace(namespace-uri-from-QName($qname))"/>
    <xsl:if test="exists($schema)">
      <xsl:sequence select="$schema/xs:attribute[@name = local-name-from-QName($qname)]"/>
    </xsl:if>
  </xsl:function>

  <xsl:function name="f:qname-resolve-element" as="element(xs:element)?">
    <xsl:param name="qname" as="xs:QName"/>
    <xsl:variable name="schema" as="element(xs:schema)?"
                  select="f:resolve-namespace(namespace-uri-from-QName($qname))"/>
    <xsl:if test="exists($schema)">
      <xsl:sequence select="$schema/xs:element[@name = local-name-from-QName($qname)]"/>
    </xsl:if>
  </xsl:function>

  <xsl:function name="f:qname-resolve" as="element()?">
    <xsl:param name="qname" as="xs:QName"/>
    <xsl:variable name="schema" as="element(xs:schema)?"
                  select="f:resolve-namespace(namespace-uri-from-QName($qname))"/>
    <xsl:if test="exists($schema)">
      <xsl:sequence select="$schema/xs:*[@name = local-name-from-QName($qname)]"/>
    </xsl:if>
  </xsl:function>

  <xsl:function name="f:resolve-namespace" as="element(xs:schema)?">
    <xsl:param name="namespace" as="xs:anyURI"/>
    <xsl:variable name="catalog-uri" as="element(catalog:uri)?"
                  select="$xml-catalog-file/catalog:catalog/catalog:uri[@name = $namespace]"/>
    <xsl:if test="exists($catalog-uri)">
      <xsl:sequence select="doc(resolve-uri($catalog-uri/@uri, base-uri($catalog-uri)))/xs:schema"/>
    </xsl:if>
  </xsl:function>

  <xsl:function name="f:xs-component-get-qname" as="xs:QName">
    <xsl:param name="context" as="element()"/>
    <xsl:variable name="prefix" select="f:xs-get-prefix($context)"/>
    <xsl:variable name="uri" select="f:get-target-namespace($context)"/>
    <xsl:variable name="local-name" as="xs:string"
                  select="$context/@name"/>
    <xsl:sequence select="QName($uri, concat($prefix, ':', $local-name))"/>
  </xsl:function>

  <xsl:function name="f:ref-get-qname" as="xs:QName">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="ref" as="xs:string"/>
    <xsl:variable name="ref-qname" as="xs:QName"
                  select="resolve-QName($ref, $context)"/>
    <xsl:variable name="ref-uri" select="namespace-uri-from-QName($ref-qname)"/>
    <xsl:sequence select="QName(
                          $ref-uri,
                          concat(f:uri-get-prefix($ref-uri), 
                          ':', 
                          local-name-from-QName($ref-qname)))"/>
  </xsl:function>

  <xsl:function name="f:qname-get-href" as="xs:string">
    <!-- e.g., '../..' -->
    <xsl:param name="path-to-root" as="xs:string"/>
    <xsl:param name="qname" as="xs:QName"/>
    <xsl:choose>
      <xsl:when test="namespace-uri-from-QName($qname) = 'http://www.w3.org/2001/XMLSchema'">
        <xsl:value-of select="concat('https://www.w3.org/TR/xmlschema-2/#',
                              local-name-from-QName($qname))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($path-to-root, '/', prefix-from-QName($qname), '/', 
                              local-name-from-QName($qname), '/index.html')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="f:safe-string" as="xs:string">
    <xsl:param name="string" as="xs:string"/>
    <xsl:variable name="v1" as="xs:string"
                  select="replace($string, '&amp;', '&amp;amp;')"/>
    <xsl:variable name="v2" as="xs:string"
                  select="replace($v1, '&quot;', '\\&quot;')"/>
    <xsl:value-of select="$v2"/>
  </xsl:function>

  <xsl:function name="f:enquote" as="xs:string">
    <xsl:param name="string" as="xs:string"/>
    <xsl:value-of select="concat('&quot;', $string, '&quot;')"/>
  </xsl:function>

  <xsl:function name="f:attribute-get-qname" as="xs:QName">
    <xsl:param name="attribute" as="attribute()"/>
    <xsl:sequence select="f:ref-get-qname($attribute/.., $attribute)"/>
  </xsl:function>

</xsl:stylesheet>
