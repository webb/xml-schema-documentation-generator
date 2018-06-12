<xsl:stylesheet 
   version="2.0"
   xmlns:xml="http://www.w3.org/XML/1998/namespace"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns="http://www.w3.org/1999/xhtml">

  <!-- ============================================================================= 

       mode component-xml-schema 

       convert an XML Schema component to viewable/clickable XML Schema

    -->

  <xsl:template mode="component-xml-schema"
                match="*"
                xmlns="">
    <xsl:param 
      name="indent"
      as="xs:string"
      required="no"
      tunnel="yes"
      select="''"/>
    <xsl:value-of select="$indent"/>
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>&gt;&#10;</xsl:text>
    <xsl:apply-templates select="*" mode="#current">
      <xsl:with-param name="indent" tunnel="yes" select="concat($indent, '  ')"/>
    </xsl:apply-templates>
    <xsl:value-of select="$indent"/>
    <xsl:text>&lt;/</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>&gt;&#10;</xsl:text>
  </xsl:template>

  <xsl:template mode="component-xml-schema"
                match="@*|node()"
                priority="-1">
    <xsl:message terminate="yes">
      <xsl:text>Unexpected content: name()=</xsl:text>
      <xsl:value-of select="name()"/>
    </xsl:message>
  </xsl:template>

</xsl:stylesheet>
