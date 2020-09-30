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

  <xsl:include href="common.xsl"/>
  <xsl:include href="mode-components.xsl"/>

  <xsl:param name="prefix" as="xs:string" required="yes"/>

  <xsl:output method="html" version="5.0" encoding="UTF-8" indent="no"/>

  <!-- ================================================================== -->
  <!-- default mode -->
  <!-- ================================================================== -->

  <xsl:template match="/"> 
    <xsl:variable name="uri" as="xs:anyURI"
                  select="f:prefix-get-uri($prefix)"/>
    <xsl:variable name="schema" as="element(xs:schema)?"
                  select="f:resolve-namespace($uri)"/>
     <head>
        <title>Index for prefix <code><xsl:value-of select="$prefix"/></code></title>
        <style type="text/css"><xsl:value-of select="normalize-space(unparsed-text('../style.css'))"/></style>
      </head>
      <body>
        <p><a href="..{$maybe-index.html}">All namespaces</a></p>
        <ul>
          <xsl:for-each select="f:get-components-with-prefix($prefix)">
            <li>
              <a href="{local-name-from-QName(.)}{$maybe-index.html}">
                <xsl:value-of select="."/>
                <xsl:variable name="component" as="element()?" select="f:qname-resolve(.)"/>
                <xsl:if test="exists($component)">
                  <xsl:text> (</xsl:text>
                  <xsl:value-of select="local-name($component)"/>
                  <xsl:text>)</xsl:text>
                </xsl:if>
                
              </a>
            </li>
          </xsl:for-each>
        </ul>
      </body>
  </xsl:template>

</xsl:stylesheet>
