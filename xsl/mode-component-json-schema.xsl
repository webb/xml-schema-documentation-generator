<xsl:stylesheet 
  version="2.0"
  exclude-result-prefixes="f xs"
  xmlns:f="http://example.org/functions"
  xmlns:xml="http://www.w3.org/XML/1998/namespace"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">

  <!-- ============================================================================= 

       mode component-json-schema 

       convert an XML Schema component to viewable/clickable JSON Schema

    -->

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
