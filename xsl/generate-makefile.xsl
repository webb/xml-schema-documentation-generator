<xsl:stylesheet 
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog"   
  xmlns:f="http://example.org/functions"
  xmlns:ns="http://example.org/namespaces"
  xmlns:appinfo="http://release.niem.gov/niem/appinfo/4.0/"
  xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xsl:include href="common.xsl"/>
  <xsl:include href="mode-components.xsl"/>

  <xsl:output method="text" encoding="US-ASCII"/>

  <xsl:template match="/">

    <xsl:text>namespaces = \&#10;</xsl:text>
    <xsl:for-each select="f:get-component-prefixes()">
      <xsl:text>  </xsl:text>
      <xsl:value-of select="."/>
      <xsl:text> \&#10;</xsl:text>
    </xsl:for-each>
    <xsl:text>&#10;</xsl:text>
    
    <xsl:for-each select="f:get-component-prefixes()">

      <xsl:text>${build_dir}/</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>/index.html</xsl:text>
      <xsl:text>:</xsl:text>
      <xsl:text>&#10;</xsl:text>
      
      <xsl:text>&#9;${call run_build_namespace_index,</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>}&#10;</xsl:text>

      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
    
    <xsl:text>components = \&#10;</xsl:text>
    <xsl:for-each select="f:get-components()">
      <xsl:text>  </xsl:text>
      <xsl:value-of select="prefix-from-QName(.)"/>
      <xsl:text>/</xsl:text>
      <xsl:value-of select="local-name-from-QName(.)"/>
      <xsl:text> \&#10;</xsl:text>
    </xsl:for-each>
    <xsl:text>&#10;</xsl:text>

    <xsl:for-each select="f:get-components()">
      <xsl:variable name="path" as="xs:string" select="concat(prefix-from-QName(.), '/', local-name-from-QName(.))"/>
      <xsl:text>${build_dir}/</xsl:text>
      <xsl:value-of select="$path"/>
      <xsl:text>/index.html</xsl:text>
      <xsl:text>: | ${build_dir}/</xsl:text>
      <xsl:value-of select="$path"/>
      <xsl:text>/diagram.svg&#10;</xsl:text>
      
      <xsl:text>&#9;${call run_build_component_index,</xsl:text>
      <xsl:value-of select="$path"/>
      <xsl:text>}&#10;</xsl:text>

      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
