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

  <xsl:param name="prefix" as="xs:string" required="yes"/>

  <xsl:output method="xml" version="1.0" encoding="UTF-8"/>

  <!-- ================================================================== -->
  <!-- default mode -->
  <!-- ================================================================== -->

  <xsl:template match="/">
    <xsl:variable name="uri" as="xs:anyURI" select="f:prefix-get-uri($prefix)"/>
    <xsl:apply-templates select="$schema" mode="namespace-index"/>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- mode: namespace-index -->
  <!-- ================================================================== -->

  <xsl:template match="xs:schema" mode="namespace-index">
    <html>
      <head>
        <title>Index for namespace <code><xsl:value-of select="f:get-target-namespace(.)"/></code></title>
        <style type="text/css"><xsl:value-of select="normalize-space(unparsed-text('../style.css'))"/></style>
      </head>
      <body>
        <p><a href="../index.html">All namespaces</a></p>
        <ul>
          <xsl:apply-templates select="xs:*[@name]" mode="#current">
            <xsl:sort select="@name"/>
          </xsl:apply-templates>
        </ul>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="/xs:schema/xs:*[@name]" mode="namespace-index">
    <li><a href="{@name}/index.html"><xsl:value-of select="@name"/> (<xsl:value-of select="local-name()"/>)</a></li>
  </xsl:template>

  <xsl:template match="*" mode="namespace-index" priority="-1">
    <xsl:message terminate="yes">Unexpected element <xsl:value-of select="name()"/></xsl:message>
  </xsl:template>

</xsl:stylesheet>
