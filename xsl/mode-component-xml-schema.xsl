<xsl:stylesheet 
  version="2.0"
  exclude-result-prefixes="f xs"
  xmlns:f="http://example.org/functions"
  xmlns:xml="http://www.w3.org/XML/1998/namespace"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">

  <!-- ============================================================================= 

       mode component-xml-schema 

       convert an XML Schema component to viewable/clickable XML Schema

    -->

  <xsl:template match="*"
                mode="component-xml-schema">
    <div style="margin-left: 1em;">
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:choose>
        <xsl:when test="exists(*) or exists(text()[string-length(normalize-space(.)) gt 0])">
          <xsl:text>&gt;</xsl:text>
          <xsl:apply-templates select="* | text()" mode="#current"/>
          <xsl:text>&lt;/</xsl:text>
          <xsl:value-of select="name()"/>
          <xsl:text>&gt;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>/&gt;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template match="xs:*/@base |
                       xs:*/@ref |
                       xs:*/@substitutionGroup |
                       xs:*/@type"
                mode="component-xml-schema">
    <xsl:variable name="base" as="xs:QName"
                  select="f:attribute-get-qname(.)"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>=&quot;</xsl:text>
    <a href="{f:qname-get-href('../..', $base)}#xml-schema">
      <xsl:value-of select="$base"/>
    </a>
    <xsl:text>&quot;</xsl:text>
  </xsl:template>

  <xsl:template mode="component-xml-schema"
                match="@*"
                priority="-1">
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>=&quot;</xsl:text>
    <xsl:value-of select="f:safe-string(.)"/>
    <xsl:text>&quot;</xsl:text>
  </xsl:template>

  <xsl:template match="text()" mode="component-xml-schema">
    <xsl:variable name="text" as="xs:string" select="."/>
    <xsl:if test="string-length(normalize-space($text)) gt 0">
      <xsl:value-of select="f:safe-string($text)"/>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="component-xml-schema"
                match="@*|node()"
                priority="-2">
    <xsl:message terminate="yes">
      <xsl:text>Unexpected content: name()=</xsl:text>
      <xsl:value-of select="name()"/>
    </xsl:message>
  </xsl:template>

</xsl:stylesheet>
