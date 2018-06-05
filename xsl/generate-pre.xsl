<xsl:stylesheet 
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog"   
  xmlns:f="http://example.org/functions"
  xmlns:ns="http://example.org/namespaces"
  xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xsl:include href="common.xsl"/>

  <xsl:output method="text" encoding="US-ASCII"/>

  <xsl:template match="catalog:catalog">
    <xsl:variable name="context" as="element()" select="."/>
    <xsl:for-each select="$prefixes">
      <xsl:variable name="namespace" select="@uri" as="xs:string"/>
      <xsl:variable name="catalog-uri" as="element(catalog:uri)?"
                    select="$context/catalog:uri[@name = $namespace]"/>
      <xsl:if test="exists($catalog-uri)">
        <xsl:apply-templates select="doc(resolve-uri($catalog-uri/@uri, base-uri($catalog-uri)))"/>
      </xsl:if>
    </xsl:for-each>
    <xsl:apply-templates select="$prefixes" mode="index-of-namespaces"/>
  </xsl:template>

  <xsl:template match="xs:schema">
    <xsl:value-of>mkdir -p &quot;<xsl:value-of select="f:get-prefix(.)"/>&quot;&#10;</xsl:value-of>
    <xsl:apply-templates select="xs:complexType|xs:element|xs:attribute|xs:simpleType|xs:attributeGroup">
      <xsl:sort select="@name"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="xs:*[@name]">
    <xsl:value-of>mkdir -p &quot;<xsl:value-of select="f:get-prefix(.)"/>/<xsl:value-of select="@name"/>&quot;&#10;</xsl:value-of>
  </xsl:template>

  <xsl:template match="text()" priority="-1"/>

  <xsl:template match="@*|node()" priority="-2">
    <xsl:message>failed.</xsl:message>
  </xsl:template>

<!--

  <template match="ns:namespace">
    <text>mkdir -p &quot;</text>
    <value-of select="@prefix"/>
    <text>&quot;&#10;</text>
  </template>

  <template match="ns:namespace">
    <text>mkdir -p &quot;</text>
    <value-of select="@prefix"/>
    <text>&quot;&#10;</text>
  </template>

-->

</xsl:stylesheet>
