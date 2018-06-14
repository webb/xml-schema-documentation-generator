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
  <xsl:include href="backlinks.xsl"/>
  <xsl:include href="mode-htmlify.xsl"/>
  <xsl:include href="mode-to-dot-html.xsl"/>
  <xsl:include href="mode-component-diagram-td.xsl"/>
  <xsl:include href="mode-component-xml-schema.xsl"/>

  <xsl:param name="root-path" as="xs:string" required="yes"/>

  <xsl:output method="text" encoding="us-ascii"/>

  <!-- ================================================================== -->
  <!-- templates, in order of appearance -->
  <!-- ================================================================== -->

  <!-- ================================================================== -->
  <!-- default mode -->
  <!-- ================================================================== -->

  <xsl:template match="catalog:catalog">
    <xsl:apply-templates select="." mode="root-index"/>
    <xsl:apply-templates select="catalog:uri[ends-with(@uri, '.xsd')]"/>
  </xsl:template>

  <xsl:template match="catalog:uri">
    <xsl:apply-templates select="doc(resolve-uri(@uri, base-uri(.)))"/>
  </xsl:template>

  <xsl:template match="xs:schema">
    <xsl:apply-templates select="." mode="namespace-index"/>
    <xsl:apply-templates select="xs:complexType|xs:element"/>
  </xsl:template>

  <xsl:template match="/xs:schema/xs:complexType[@name]
                       |/xs:schema/xs:element[@name]">
    <xsl:apply-templates select="." mode="component-page"/>
  </xsl:template>

  <xsl:template match="*" priority="-1">
    <xsl:message terminate="yes">unexpected element: mode=default
      name=<xsl:value-of select="name()"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="@*|node()" priority="-2">
    <xsl:message terminate="yes">unexpected content: mode=default
      name=
    </xsl:message>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- mode: root-index -->
  <!-- ================================================================== -->

  <xsl:template match="catalog:catalog" mode="root-index">
    <xsl:result-document
       href="{$root-path}/index.html"
       method="xml" version="1.0" encoding="UTF-8" indent="yes">
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
    </xsl:result-document>
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

  <!-- ================================================================== -->
  <!-- mode: namespace-index -->
  <!-- ================================================================== -->

  <xsl:template match="xs:schema" mode="namespace-index">
    <xsl:result-document
      href="{f:xs-get-prefix(.)}/index.html"
      method="xml" version="1.0" encoding="UTF-8" indent="yes">
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
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="/xs:schema/xs:*[@name]" mode="namespace-index">
    <li><a href="{@name}/index.html"><xsl:value-of select="@name"/> (<xsl:value-of select="local-name()"/>)</a></li>
  </xsl:template>

  <xsl:template match="*" mode="namespace-index" priority="-1">
    <xsl:message terminate="yes">Unexpected element <xsl:value-of select="name()"/></xsl:message>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- mode: component-page -->
  <!-- ================================================================== -->

  <xsl:template match="/xs:schema/xs:*[@name]" mode="component-page">
    <xsl:variable name="qname" select="f:xs-component-get-qname(.)"/>
    <xsl:result-document href="{f:qname-get-href($root-path, $qname)}"
                         method="xml" version="1.0" encoding="UTF-8" indent="no" omit-xml-declaration="no">
      <html>
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
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="*" mode="component-page" priority="-1">
    <xsl:message terminate="yes">Unexpected element <xsl:value-of select="name()"/></xsl:message>
  </xsl:template>

</xsl:stylesheet>
