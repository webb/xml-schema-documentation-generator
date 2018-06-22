<xsl:stylesheet 
  exclude-result-prefixes="f xs"
  version="2.0"
  xmlns:f="http://example.org/functions"
  xmlns:j="http://example.org/json"
  xmlns:xml="http://www.w3.org/XML/1998/namespace"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">

  <xsl:function name="f:json-xml-to-html">
    <xsl:param name="content"/>
    <xsl:apply-templates select="$content" mode="component-json-schema-json-xml-to-html"/>
  </xsl:function>

  <!-- ============================================================================= 

       mode component-json-schema 

       convert an XML Schema component to viewable/clickable JSON Schema

    -->

  <xsl:template
    match="/xs:schema/xs:complexType[@name]"
    mode="component-json-schema">
    <xsl:variable name="result">
      <j:map qkey="{f:xs-component-get-qname(.)}">
        <j:string key="type">object</j:string>
        <j:map key="properties">
          <xsl:apply-templates mode="component-json-schema-properties"/>
        </j:map>
        <j:array key="required">
          <xsl:apply-templates mode="component-json-schema-required"/>
        </j:array>
      </j:map>
    </xsl:variable>
    <xsl:sequence select="f:json-xml-to-html($result)"/>
  </xsl:template>

  <xsl:template
    match="/xs:schema/xs:*[@name]"
    mode="component-json-schema"
    priority="-1">
    <p>JSON Schema for this component has not been defined.</p>
  </xsl:template>

  <xsl:template
    match="@*|node()"
    mode="component-xml-schema"
    priority="-2">
    <xsl:message terminate="yes">Unexpected content (mode=component-xml-schema; name()=<xsl:value-of select="name()"/>)</xsl:message>
  </xsl:template>

</xsl:stylesheet>
