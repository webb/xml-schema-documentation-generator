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
    <xsl:apply-templates select="$content" mode="json-to-html"/>
  </xsl:function>

  <!-- ============================================================================= 

       mode component-json-schema 

       convert an XML Schema component to viewable/clickable JSON Schema

    -->

  <xsl:template
    match="/xs:schema/xs:complexType[@name]"
    mode="component-json-schema">
    <xsl:variable name="this-qname" as="xs:QName" select="f:xs-component-get-qname(.)"/>
    <xsl:variable name="result">
      <j:map qkey="{$this-qname}">
        <xsl:namespace name="{prefix-from-QName($this-qname)}"
                       select="namespace-uri-from-QName($this-qname)"/>
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

  <!-- 
       =============================================================================       
       mode component-json-schema-properties
    -->

  <xsl:template match="@*|node()"
                mode="component-json-schema-properties"/>

  <!-- 
       =============================================================================       
       mode component-json-schema-required
    -->

  <xsl:template match="@*|node()"
                mode="component-json-schema-required"/>


  <!-- 
       ============================================================================= 
       mode json-to-html

       Convert JSON XML format to HTML
    -->

  <xsl:template match="j:map[exists(@qkey)]"
                mode="json-to-html">
    <xsl:variable name="key-qname" select="f:attribute-get-qname(@qkey)"/>
    <div class="block">
      <div class="line">
        <xsl:text>&quot;</xsl:text>
        <a href="{f:qname-get-href('../..', $key-qname)}#json-schema">
          <xsl:value-of select="$key-qname"/>
        </a>
        <xsl:text>&quot;: {</xsl:text>
      </div>
      <xsl:apply-templates mode="#current"/>
      <div class="line">
        <xsl:text>}</xsl:text>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="j:map[exists(@key)]"
                mode="json-to-html">
    <div class="block">
      <div class="line">
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="@key"/>
        <xsl:text>&quot;: {</xsl:text>
      </div>
      <xsl:apply-templates mode="#current"/>
      <div class="line">
        <xsl:text>}</xsl:text>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="j:array[exists(@key)]"
                mode="json-to-html">
    <div class="block">
      <div class="line">
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="@key"/>
        <xsl:text>&quot;: [</xsl:text>
      </div>
      <xsl:apply-templates mode="#current"/>
      <div class="line">
        <xsl:text>]</xsl:text>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="j:string[exists(@key)]"
                mode="json-to-html">
    <div class="block">
      <div class="line">
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="@key"/>
        <xsl:text>&quot;: </xsl:text>
        <xsl:apply-templates mode="#current"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="j:string/text()"
                mode="json-to-html">
    <xsl:text>&quot;</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>&quot;</xsl:text>
  </xsl:template>

  <xsl:template
    match="@*|node()"
    mode="json-to-html"
    priority="-2">
    <xsl:message terminate="yes">Unexpected content (mode=json-to-html; name()=<xsl:value-of select="name()"/>)</xsl:message>
  </xsl:template>
  

</xsl:stylesheet>
