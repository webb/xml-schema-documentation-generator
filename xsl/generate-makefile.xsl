<xsl:stylesheet 
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog"   
  xmlns:f="http://example.org/functions"
  xmlns:ns="http://example.org/namespaces"
  xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xsl:include href="common.xsl"/>

  <xsl:output method="text" encoding="US-ASCII"/>

  <xsl:template match="/catalog:catalog">
    <xsl:text>namespaces = \&#10;</xsl:text>
    <xsl:apply-templates mode="namespaces" select="."/>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>components = \&#10;</xsl:text>
    <xsl:apply-templates mode="components" select="."/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <!-- ============================================================================= -->
  <!-- mode: namespaces -->

  <xsl:template mode="namespaces"
                match="catalog:catalog">
    <xsl:variable name="context" as="element()" select="."/>
    <xsl:for-each select="$prefixes">
      <xsl:variable name="namespace" select="@uri" as="xs:string"/>
      <xsl:variable name="catalog-uri" as="element(catalog:uri)?"
                    select="$context/catalog:uri[@name = $namespace]"/>
      <xsl:if test="exists($catalog-uri)">
        <xsl:text>  </xsl:text>
        <xsl:value-of select="@prefix"/>
        <xsl:text> \&#10;</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <!-- ============================================================================= -->
  <!-- mode: components -->

  <xsl:template mode="components"
                match="catalog:catalog">
    <xsl:variable name="context" as="element()" select="."/>
    <xsl:for-each select="$prefixes">
      <xsl:variable name="namespace" select="@uri" as="xs:string"/>
      <xsl:variable name="catalog-uri" as="element(catalog:uri)?"
                    select="$context/catalog:uri[@name = $namespace]"/>
      <xsl:if test="exists($catalog-uri)">
        <xsl:apply-templates mode="#current"
                             select="doc(resolve-uri($catalog-uri/@uri, base-uri($catalog-uri)))"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template mode="components"
                match="xs:schema">
    <xsl:apply-templates mode="#current"
                         select="xs:complexType|xs:element">
      <xsl:sort select="@name"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="xs:schema/xs:*[@name]"
                mode="components">
    <xsl:variable name="qname" select="f:xs-component-get-qname(.)"/>
    <xsl:text>  </xsl:text>
    <xsl:value-of select="prefix-from-QName($qname)"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="local-name-from-QName($qname)"/>
    <xsl:text> \&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="@*|node()" priority="-2">
    <xsl:message>failed</xsl:message>
  </xsl:template>

</xsl:stylesheet>
