<xsl:stylesheet 
  exclude-result-prefixes="xs f"
  version="2.0"
  xmlns:f="http://example.org/functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:include href="common.xsl"/>
  <xsl:include href="backlinks.xsl"/>
  <xsl:include href="mode-htmlify.xsl"/>
  <xsl:include href="mode-component-xml-schema.xsl"/>

  <xsl:param name="root-path" as="xs:string" required="yes"/>
  <xsl:param name="prefix" as="xs:string" required="yes"/>
  <xsl:param name="local-name" as="xs:string" required="yes"/>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>

  <xsl:template match="/" mode="component-diagram">
    <xsl:variable name="qname" as="xs:QName"
              select="f:get-qname($prefix, $local-name)"/>
    <xsl:variable name="component" as="element()"
                  select="f:qname-resolve($qname)"/>
    <xsl:apply-templates select="$component" mode="#current"/>
  </xsl:template>

  <xsl:template match="/xs:schema/xs:*[@name]" mode="component-page">
    <xsl:variable name="qname" select="f:xs-component-get-qname(.)"/>
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <meta charset="UTF-8"/>
        <title><xsl:value-of select="$qname"/></title>
        <style type="text/css"><xsl:value-of select="normalize-space(unparsed-text('../style.css'))"/></style>
      </head>
      <body>
        <h1>
          <a href="../index.html">
            <xsl:value-of select="prefix-from-QName($qname)"/>
          </a>
          <xsl:text>:</xsl:text>
          <xsl:value-of select="local-name-from-QName($qname)"/>
        </h1>

        <p><xsl:value-of select="local-name()"/><xsl:text> </xsl:text><xsl:value-of select="local-name-from-QName($qname)"/> in namespace <xsl:value-of select="namespace-uri-from-QName($qname)"/></p>
        
        <h2>Definition</h2>
        <p><xsl:value-of select="f:xs-component-get-definition(.)"/></p>
        <h2>Diagram</h2>
        <a name="diagram">
          <div style="text-align: center;">
            <img src="data:image/png;base64,{unparsed-text(concat($root-path, '/', prefix-from-QName($qname), '/', local-name-from-QName($qname), '/diagram.png.base64'))}" usemap="#diagram"/>
          </div>
        </a>
        <xsl:apply-templates
          mode="htmlify"
          select="doc(concat($root-path, '/', prefix-from-QName($qname),
                  '/', local-name-from-QName($qname), '/diagram.map'))"/>
        <h2>XML Schema</h2>
        <a name="xml-schema">
          <div class="xml-schema">
            <xsl:apply-templates select="."
                                 mode="component-xml-schema"/>
          </div>
        </a>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="*" mode="component-page" priority="-1">
    <xsl:message terminate="yes">Unexpected element <xsl:value-of select="name()"/></xsl:message>
  </xsl:template>

</xsl:stylesheet>
