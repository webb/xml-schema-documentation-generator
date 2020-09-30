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

  <xsl:param name="link-to-dirs" as="xs:boolean" select="true()"/>
  <xsl:variable name="maybe-index.html">
    <xsl:choose>
      <xsl:when test="$link-to-dirs"></xsl:when>
      <xsl:otherwise>/index.html</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  

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

  <xsl:function name="f:prefix-get-uri" as="xs:anyURI">
    <xsl:param name="prefix" as="xs:string"/>
    <xsl:sequence select="exactly-one($prefixes[@prefix = $prefix]/@uri) cast as xs:anyURI"/>
  </xsl:function>

  <xsl:function name="f:get-qname" as="xs:QName">
    <xsl:param name="prefix" as="xs:string"/>
    <xsl:param name="local-name" as="xs:string"/>
    <xsl:sequence select="QName(f:prefix-get-uri($prefix), concat($prefix, ':', $local-name))"/>
  </xsl:function>

  <xsl:function name="f:xs-get-prefix" as="xs:string">
    <xsl:param name="context" as="element()"/>
    <xsl:variable name="target-namespace" select="f:get-target-namespace($context)"/>
    <xsl:variable name="prefix" as="xs:string?"
                  select="$prefixes[@uri = f:get-target-namespace($context)]/@prefix"/>
    <xsl:if test="empty($prefix)">
      <xsl:message terminate="yes">f:xs-get-prefix can't find prefix for <xsl:value-of select="base-uri($context)"/></xsl:message>
    </xsl:if>
    <xsl:sequence select="exactly-one($prefix)"/>
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
    <xsl:value-of select="concat($path-to-root, '/', prefix-from-QName($qname), '/', 
                          local-name-from-QName($qname), $maybe-index.html)"/>
  </xsl:function>

  <xsl:function name="f:safe-string" as="xs:string">
    <xsl:param name="string" as="xs:string"/>
    <xsl:variable name="v1" as="xs:string"
                  select="replace($string, '&amp;', '&amp;amp;')"/>
    <xsl:variable name="v2" as="xs:string"
                  select="replace($v1, '&quot;', '&amp;&quot;')"/>
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

  <xsl:function name="f:element-use-get-min-occurs" as="xs:integer">
    <xsl:param name="context" as="element(xs:element)"/>
    <xsl:value-of select="if ($context/@minOccurs) 
                          then $context/@minOccurs cast as xs:integer
                          else 1"/>
  </xsl:function>

  <xsl:function name="f:element-use-get-max-occurs">
    <xsl:param name="context" as="element(xs:element)"/>
    <xsl:value-of select="if ($context/@maxOccurs)
                          then (if ($context/@maxOccurs = 'unbounded')
                                then 'n'
                                else $context/@maxOccurs cast as xs:integer)
                          else 1"/>
  </xsl:function>

  <xsl:function name="f:element-use-get-cardinality" as="xs:string">
    <xsl:param name="context" as="element(xs:element)"/>
    <xsl:variable name="min" select="string(f:element-use-get-min-occurs($context))"/>
    <xsl:variable name="max" select="string(f:element-use-get-max-occurs($context))"/>
    <xsl:value-of select="if ($min = '1' and $max = '1')
                          then ''
                          else (if ($min = $max)
                                then concat(' [', $min, ']')
                                else concat(' [', $min, '-', $max, ']'))"/>
  </xsl:function>

  <!-- attribute use -->

  <!-- attribute use cardinality:
       empty, 'optional': 0-1
       'prohibited': 0
       'required': 1
    -->

  <xsl:function name="f:attribute-use-get-min-occurs" as="xs:integer">
    <xsl:param name="context" as="element(xs:attribute)"/>
    <xsl:sequence select="if ($context/@use = 'required') then 1 else 0"/>
  </xsl:function>

  <xsl:function name="f:attribute-use-get-max-occurs" as="xs:integer">
    <xsl:param name="context" as="element(xs:attribute)"/>
    <xsl:sequence select="if ($context/@use = 'prohibited') then 0 else 1"/>
  </xsl:function>

  <xsl:function name="f:attribute-use-get-cardinality" as="xs:string">
    <xsl:param name="context" as="element(xs:attribute)"/>
    <xsl:variable name="min" select="string(f:attribute-use-get-min-occurs($context))"/>
    <xsl:variable name="max" select="string(f:attribute-use-get-max-occurs($context))"/>
    <xsl:value-of select="if ($min = '1' and $max = '1')
                          then ''
                          else (if ($min = $max)
                                then concat(' [', $min, ']')
                                else concat(' [', $min, '-', $max, ']'))"/>
  </xsl:function>

  <!-- sequence -->

  <xsl:function name="f:sequence-as-text-list" as="xs:string">
    <xsl:param name="list"/>
    <xsl:param name="conjunction" as="xs:string"/>
    <xsl:variable name="list-length" as="xs:integer" select="count($list)"/>
    <xsl:value-of>
      <xsl:choose>
        <xsl:when test="$list-length eq 0"/>
        <xsl:when test="$list-length eq 1">
          <xsl:value-of select="$list"/>
        </xsl:when>
        <xsl:when test="$list-length eq 2">
          <xsl:value-of select="$list[1]"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$conjunction"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$list[2]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="subsequence($list, 1, $list-length - 1)">
            <xsl:value-of select="."/>
            <xsl:text>, </xsl:text>
          </xsl:for-each>
          <xsl:value-of select="$conjunction"/>
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$list[$list-length]"/>>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:value-of>
  </xsl:function>

</xsl:stylesheet>
