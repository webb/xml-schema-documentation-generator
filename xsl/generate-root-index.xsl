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

  <xsl:output method="html" version="5.0" encoding="UTF-8" indent="no"/>

  <!-- ================================================================== -->
  <!-- default mode -->
  <!-- ================================================================== -->

  <xsl:template match="/">
    <html>
      <head>
        <title>Index</title>
        <style type="text/css"><xsl:value-of select="normalize-space(unparsed-text('../style.css'))"/></style>
      </head>
      <body>
        <ul>
          <xsl:for-each select="f:get-component-prefixes()">
            <xsl:variable name="uri" as="xs:anyURI"
                          select="f:prefix-get-uri(.)"/>
            <xsl:variable name="schema" as="element(xs:schema)?"
                          select="f:resolve-namespace($uri)"/>
            <xsl:choose>
              <xsl:when test="exists($schema)">
                <xsl:apply-templates select="$schema" mode="root-index"/>
              </xsl:when>
              <xsl:otherwise>
                <li>
                  <p>
                    <a href="{.}/index.html">
                      <xsl:value-of select="."/>
                    </a>
                    <xsl:text>: </xsl:text>
                    <xsl:value-of select="$uri"/>
                  </p>
                </li>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </ul>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="xs:schema" mode="root-index">
    <xsl:variable name="prefix" select="f:xs-get-prefix(.)"/>
    <li>
      <p>
        <a href="{$prefix}/index.html">
          <xsl:value-of select="$prefix"/>
        </a>
        <xsl:text>: </xsl:text>
        <xsl:value-of select="@targetNamespace"/>
      </p>
      <div class="ns-defn">
        <p>
          <xsl:value-of select="f:xs-component-get-definition(.)"/>
        </p>
      </div>
    </li>
  </xsl:template>

  <xsl:template match="*" priority="-2" mode="root-index">
    <xsl:message terminate="yes">Unexpected element (mode = root-index, name= <xsl:value-of select="name()"/>).</xsl:message>
  </xsl:template>

  <xsl:template match="@*|node()" priority="-3" mode="root-index">
    <xsl:message terminate="yes">Unexpected content (mode = root-index).</xsl:message>
  </xsl:template>

</xsl:stylesheet>
