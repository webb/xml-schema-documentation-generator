<xsl:stylesheet 
  exclude-result-prefixes="f xs"
  version="2.0"
  xmlns:f="http://example.org/functions"
  xmlns:j="http://www.w3.org/2005/xpath-functions"
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
      <j:map key="{$this-qname}" key-style="qname">
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

  <xsl:template match="xs:element[@ref]"
                mode="component-json-schema-properties">
    <xsl:variable name="element-qname" as="xs:QName" select="f:attribute-get-qname(@ref)"/>
    <xsl:variable name="element" as="element(xs:element)?"
                  select="f:qname-resolve-element($element-qname)"/>
    <xsl:variable name="element-type-qname" as="xs:QName?"
                  select="if (exists($element/@type)) 
                          then f:attribute-get-qname($element/@type) 
                          else ()"/>
    <xsl:variable name="element-type" as="element(xs:element)?"
                  select="if (exists($element-type-qname)) 
                          then f:qname-resolve-type($element-type-qname)
                          else ()"/>
    <j:map key="{$element-qname}" key-style="qname">
      <xsl:namespace name="{prefix-from-QName($element-qname)}"
                     select="namespace-uri-from-QName($element-qname)"/>
      <xsl:variable name="min" select="f:element-use-get-min-occurs(.)" as="xs:integer"/>
      <xsl:variable name="max" select="f:element-use-get-max-occurs(.)"/>
      <xsl:choose>
        <!-- arrays -->
        <xsl:when test="$max = 'n' or ($max cast as xs:integer) gt 1">
          <j:string key="type">array</j:string>
          <xsl:if test="exists($element-type)">
            <j:map key="items">
              <j:ref-to-definition key="$ref" qname="{$element-type-qname}">
                <xsl:namespace name="{prefix-from-QName($element-type-qname)}"
                               select="namespace-uri-from-QName($element-type-qname)"/>
              </j:ref-to-definition>
            </j:map>
          </xsl:if>
          <xsl:if test="($min cast as xs:integer) gt 0">
            <j:number key="minItems">
              <xsl:value-of select="$min"/>
            </j:number>
          </xsl:if>
          <xsl:if test="$max != 'n'">
            <j:number key="maxItems">
              <xsl:value-of select="$max"/>
            </j:number>
          </xsl:if>
        </xsl:when>
        <!-- single item -->
        <xsl:otherwise>
          <xsl:if test="exists($element/@type)">
            <j:ref-to-definition key="$ref" qname="{$element-type-qname}">
              <xsl:namespace name="{prefix-from-QName($element-type-qname)}"
                             select="namespace-uri-from-QName($element-type-qname)"/>
            </j:ref-to-definition>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </j:map>
  </xsl:template>

  <xsl:template match="xs:attribute[@ref]"
                mode="component-json-schema-properties">
    <xsl:variable name="ref-qname" as="xs:QName" select="f:attribute-get-qname(@ref)"/>
    <j:map key="{$ref-qname}" key-style="qname">
      <xsl:namespace name="{prefix-from-QName($ref-qname)}"
                     select="namespace-uri-from-QName($ref-qname)"/>
      <xsl:variable name="attribute" as="element(xs:attribute)?"
                    select="f:qname-resolve-attribute($ref-qname)"/>
      <xsl:if test="exists($attribute/@type)">
        <xsl:variable name="attribute-type-qname" as="xs:QName"
                      select="f:attribute-get-qname($attribute/@type)"/>
        <j:ref-to-definition key="$ref" qname="{$attribute-type-qname}">
          <xsl:namespace name="{prefix-from-QName($attribute-type-qname)}"
                         select="namespace-uri-from-QName($attribute-type-qname)"/>
        </j:ref-to-definition>
      </xsl:if>
    </j:map>
  </xsl:template>


  <xsl:template match="
                       xs:complexContent |
                       xs:simpleContent |
                       xs:sequence |
                       xs:attributeGroup |
                       xs:extension"
                mode="component-json-schema-properties"
                priority="-1">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="text() | comment() |
                       xs:annotation"
                mode="component-json-schema-properties"
                priority="-1"/>

  <xsl:template match="@*|node()"
                mode="component-json-schema-properties"
                priority="-2">
    <xsl:message terminate="yes">Unexpected content (mode=component-json-schema-properties; name()=<xsl:value-of select="name()"/>)</xsl:message>
  </xsl:template>

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

  <xsl:function name="f:json-key-to-html">
    <xsl:param name="context" as="element()"/>
    <xsl:if test="exists($context/@key)">
      <xsl:text>&quot;</xsl:text>
      <xsl:choose>
        <xsl:when test="$context/@key-style = 'qname'">
          <xsl:variable name="key-qname" select="f:attribute-get-qname($context/@key)"/>
          <a href="{f:qname-get-href('../..', $key-qname)}#json-schema">
            <xsl:value-of select="$key-qname"/>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$context/@key"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>&quot;: </xsl:text>
    </xsl:if>
  </xsl:function>

  <xsl:function name="f:json-put-comma">
    <xsl:param name="context" as="element()"/>
    <xsl:if test="exists($context/following-sibling::*)">,</xsl:if>
  </xsl:function>

  <xsl:template match="j:map"
                mode="json-to-html">

    <div class="block">
      <div class="line">
        <xsl:sequence select="f:json-key-to-html(.)"/>
        <xsl:text>{</xsl:text>
      </div>
      <xsl:apply-templates mode="#current"/>
      <div class="line">
        <xs:text>}</xs:text>
        <xsl:value-of select="f:json-put-comma(.)"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="j:array"
                mode="json-to-html">
    <div class="block">
      <div class="line">
        <xsl:sequence select="f:json-key-to-html(.)"/>
        <xsl:text>[</xsl:text>
      </div>
      <xsl:apply-templates mode="#current"/>
      <div class="line">
        <xsl:text>]</xsl:text>
        <xsl:value-of select="f:json-put-comma(.)"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="j:string"
                mode="json-to-html">
    <div class="block">
      <div class="line">
        <xsl:sequence select="f:json-key-to-html(.)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="f:json-put-comma(.)"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="j:ref-to-definition"
                mode="json-to-html">
    <xsl:variable name="qname" select="f:attribute-get-qname(@qname)"/>
    <div class="block">
      <div class="line">
        <xsl:sequence select="f:json-key-to-html(.)"/>
        <xsl:text>&quot;#/definitions/</xsl:text>
        <a href="{f:qname-get-href('../..', $qname)}#json-schema">
          <xsl:value-of select="$qname"/>
        </a>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="f:json-put-comma(.)"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template
    match="@*|node()"
    mode="json-to-html"
    priority="-2">
    <xsl:message terminate="yes">Unexpected content (mode=json-to-html; name()=<xsl:value-of select="name()"/>)</xsl:message>
  </xsl:template>
  

</xsl:stylesheet>
