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

  <xsl:output method="xml" version="1.0" encoding="UTF-8"/>

  <!-- ================================================================== -->
  <!-- default mode -->
  <!-- ================================================================== -->

  <xsl:template match="/">
    <xsl:apply-templates select="$xml-catalog-file" mode="root-index"/>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- mode: root-index -->
  <!-- ================================================================== -->

  <xsl:template match="catalog:catalog" mode="root-index">
    <html>
      <head>
        <title>Index</title>
        <style type="text/css"><xsl:value-of select="normalize-space(unparsed-text('../style.css'))"/></style>
      </head>
      <body>
        <ul>
          <xsl:variable name="context" as="element(catalog:catalog)"
                        select="."/>
          <xsl:for-each select="$prefixes">
            <xsl:variable name="namespace" select="@uri" as="xs:string"/>
            <xsl:variable name="catalog-uri" as="element(catalog:uri)?"
                          select="$context/catalog:uri[@name = $namespace]"/>
            <xsl:if test="exists($catalog-uri)">
              <xsl:apply-templates mode="#current"
                                   select="doc(resolve-uri($catalog-uri/@uri, base-uri($catalog-uri)))"/>
            </xsl:if>
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
