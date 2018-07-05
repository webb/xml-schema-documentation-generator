<xsl:stylesheet 
  exclude-result-prefixes="catalog ns xs f"
  version="3.0"
  xmlns:catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog"   
  xmlns:f="http://example.org/functions"
  xmlns:json="http://www.w3.org/2005/xpath-functions"
  xmlns:ns="http://example.org/namespaces"
  xmlns:xml="http://www.w3.org/XML/1998/namespace"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">

  <xsl:include href="common.xsl"/>
  <xsl:include href="backlinks.xsl"/>
  <xsl:include href="mode-component-json-schema.xsl"/>
  <xsl:include href="mode-components.xsl"/>

  <xsl:output method="text" encoding="UTF-8"/>

  <!-- ================================================================== -->
  <!-- default mode -->
  <!-- ================================================================== -->

  <xsl:template match="/">
    <xsl:variable name="json-xml-custom">
      <json:map>
        <xsl:for-each select="f:get-components()">
          <xsl:apply-templates select="f:qname-resolve(.)"
                               mode="component-json-schema"/>
        </xsl:for-each>
      </json:map>
    </xsl:variable>
    <xsl:variable name="json-xml-clean">
      <xsl:apply-templates select="$json-xml-custom" mode="json-xml-clean"/>
    </xsl:variable>
    <xsl:value-of select="xml-to-json($json-xml-clean, map{'indent': true()})"/>
  </xsl:template>

  <!-- ============================================================================= -->
  <!-- mode: json-xml-clean -->

  <xsl:template match="json:ref" mode="json-xml-clean">
    <json:string>
      <xsl:apply-templates select="@key" mode="#current"/>
      <xsl:if test="@ref-style = 'definition'">
        <xsl:text>#/definitions/</xsl:text>
      </xsl:if>
      <xsl:value-of select="@qname"/>
    </json:string>
  </xsl:template>

  <xsl:template match="@key-style" mode="json-xml-clean"/>

  <xsl:template match="json:note" mode="json-xml-clean"/>

  <xsl:template match="@*|node()" mode="json-xml-clean" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*" priority="-2" mode="json-xml-clean">
    <xsl:message terminate="yes">Unexpected element (mode = json-xml-clean, name= <xsl:value-of select="name()"/>).</xsl:message>
  </xsl:template>

  <xsl:template match="@*|node()" priority="-3" mode="json-xml-clean">
    <xsl:message terminate="yes">Unexpected content (mode = json-xml-clean).</xsl:message>
  </xsl:template>

</xsl:stylesheet>
