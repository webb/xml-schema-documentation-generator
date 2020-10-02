<xsl:stylesheet 
  exclude-result-prefixes="xs f"
  version="2.0"
  xmlns:f="http://example.org/functions"
  xmlns:j="http://www.w3.org/2005/xpath-functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:include href="common.xsl"/>
  <xsl:include href="backlinks.xsl"/>
  <xsl:include href="mode-htmlify.xsl"/>
  <xsl:include href="mode-component-xml-schema.xsl"/>
  <xsl:include href="mode-component-json-schema.xsl"/>

  <xsl:param name="root-path" as="xs:string" required="yes"/>
  <xsl:param name="prefix" as="xs:string" required="yes"/>
  <xsl:param name="local-name" as="xs:string" required="yes"/>
  <xsl:param name="build_json" as="xs:boolean" select="true()"/>

  <xsl:output method="xhtml" html-version="5.0" encoding="UTF-8" indent="no"/>

  <xsl:template match="/" mode="component-page">
    <xsl:variable name="qname" as="xs:QName"
                  select="f:get-qname($prefix, $local-name)"/>
    <xsl:variable name="component" as="element()?"
                  select="f:qname-resolve($qname)"/>
    <xsl:choose>
      <xsl:when test="exists($component)">
        <xsl:apply-templates select="$component" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="component-page-with-no-component">
          <xsl:with-param name="qname" as="xs:QName" select="$qname"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="component-page-with-no-component">
    <xsl:param name="qname" as="xs:QName" required="yes"/>
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <meta charset="UTF-8"/>
        <title><xsl:value-of select="$qname"/></title>
        <style type="text/css"><xsl:value-of select="normalize-space(unparsed-text('../style.css'))"/></style>
      </head>
      <body>
        <div id="page">
          <div id="content">
        <h1>
          <a href="..{$maybe-index.html}">
            <xsl:value-of select="prefix-from-QName($qname)"/>
          </a>
          <xsl:text>:</xsl:text>
          <xsl:value-of select="local-name-from-QName($qname)"/>
        </h1>

        <p>Component <xsl:value-of select="local-name-from-QName($qname)"/> in namespace <xsl:value-of select="namespace-uri-from-QName($qname)"/></p>

        <xsl:if test="namespace-uri-from-QName($qname) = 'http://www.w3.org/2001/XMLSchema'">
          <h2>Definition</h2>
          <p>
            <xsl:text>Simple type </xsl:text>
            <xsl:value-of select="$qname"/>
            <xsl:text> is documented by </xsl:text>
            <a href="{concat('https://www.w3.org/TR/xmlschema-2/#', 
                     local-name-from-QName($qname))}">
              <xsl:text>the XML Schema specification</xsl:text>
            </a>
            <xsl:text>.</xsl:text>
          </p>
        </xsl:if>
        <h2>Diagram</h2>
        <a name="diagram">
          <div style="text-align: center;">
            <object type="image/svg+xml" data="diagram.svg"/>
          </div>
        </a>

        <xsl:if test="$build_json">
          <h2>JSON Schema</h2>
          <xsl:variable name="json-schema-results"
                        select="f:qname-get-json-schema($qname)"/>
          <a name="json-schema">
            <div class="json-schema">
              <xsl:sequence select="f:json-xml-to-html($json-schema-results)"/>
            </div>
          </a>
          <xsl:if test="$json-schema-results//j:note">
            <h3>Notes</h3>
            <xsl:copy-of select="$json-schema-results//j:note/*"/>
          </xsl:if>
        </xsl:if>
          </div>
        </div>
      </body>
    </html>
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
        <div id="page">
          <div id="content">
            <h1>
              <a href="..{$maybe-index.html}">
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
                <object type="image/svg+xml" data="diagram.svg"/>
              </div>
            </a>

            <xsl:if test="self::xs:simpleType[@name]//xs:enumeration">
              <h2>Enumerations</h2>
              <a name="enumerations">
                <table>
                  <thead>
                    <tr>
                      <td>Value</td>
                      <td>Definition</td>
                    </tr>
                  </thead>
                  <tbody>
                    <xsl:for-each select=".//xs:enumeration[@value]">
                      <tr>
                        <td>
                          <xsl:value-of select="@value"/>
                        </td>
                        <td>
                          <xsl:value-of select="f:xs-component-get-definition(.)"/>
                        </td>
                      </tr>
                    </xsl:for-each>
                  </tbody>
                </table>
              </a>
            </xsl:if>

            <h2>XML Schema</h2>
            <a name="xml-schema">
              <div class="xml-schema">
                <xsl:apply-templates select="."
                                     mode="component-xml-schema"/>
              </div>
            </a>

            <xsl:if test="$build_json">
              <h2>JSON Schema</h2>
              <xsl:variable name="json-schema-results"
                            select="f:qname-get-json-schema($qname)"/>
              <a name="json-schema">
                <div class="json-schema">
                  <xsl:sequence select="f:json-xml-to-html($json-schema-results)"/>
                </div>
              </a>
              <xsl:if test="$json-schema-results//j:note">
                <h3>Notes</h3>
                <xsl:copy-of select="$json-schema-results//j:note/*"/>
              </xsl:if>
            </xsl:if>
          </div>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="*" mode="component-page" priority="-1">
    <xsl:message terminate="yes">Unexpected element <xsl:value-of select="name()"/></xsl:message>
  </xsl:template>

</xsl:stylesheet>
