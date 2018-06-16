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

  <!-- ================================================================== -->
  <!-- mode: component-diagram-td -->
  <!-- ================================================================== -->

  <!-- a TD is a table cell for a graphviz box -->
  <xsl:function name="f:qname-get-td">
    <xsl:param name="qname" as="xs:QName"/>
    <xsl:apply-templates select="f:qname-resolve($qname)"
                         mode="component-diagram-td"/>
  </xsl:function>

  <!-- a port is a place to link to on a graphviz diagram -->
  <xsl:function name="f:qname-get-td-with-port">
    <xsl:param name="qname" as="xs:QName"/>
    <xsl:param name="port" as="xs:string"/>
    <xsl:apply-templates select="f:qname-resolve($qname)"
                         mode="component-diagram-td">
      <xsl:with-param name="port" select="$port"/>
    </xsl:apply-templates>
  </xsl:function>

  <xsl:template match="/xs:schema/xs:complexType[@name]
                       | /xs:schema/xs:simpleType[@name]
                       | /xs:schema/xs:attribute[@name]
                       | /xs:schema/xs:attributeGroup[@name]"
                mode="component-diagram-td">
    <xsl:param name="port" as="xs:string" select="generate-id(.)"/>
    <xsl:variable name="qname" select="f:xs-component-get-qname(.)"/>
    <TD xmlns=""
        ALIGN="LEFT"
        HREF="{f:qname-get-href('../..', $qname)}"
        PORT="{$port}">
      <xsl:variable name="definition" as="xs:string"
                    select="f:safe-string(f:xs-component-get-definition(.))"/>
      <xsl:if test="string-length(normalize-space($definition)) gt 0">
        <xsl:attribute name="TOOLTIP" select="normalize-space($definition)"/>
      </xsl:if>
      <xsl:if test="self::xs:attribute">
        <xsl:text>@</xsl:text>
      </xsl:if>
      <xsl:value-of select="$qname"/>
    </TD>
  </xsl:template>

  <xsl:template match="xs:element[@ref]"
                mode="component-diagram-td"
                as="element(TD)" xmlns="">
    <xsl:variable name="element-qname" as="xs:QName"
                  select="f:attribute-get-qname(@ref)"/>
    <xsl:variable name="element" as="element()?"
                  select="f:qname-resolve-element($element-qname)"/>
    <xsl:choose>
      <xsl:when test="exists($element)">
        <xsl:variable name="td" as="element(TD)">
          <xsl:apply-templates select="$element" mode="#current"/>
        </xsl:variable>
        <TD>
          <xsl:copy-of select="$td/@*"/>
          <xsl:value-of select="$td/text()"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="f:element-use-get-cardinality(.)"/>
        </TD>
      </xsl:when>
      <xsl:otherwise>
        <TD xmlns=""
            ALIGN="LEFT">
          <xsl:value-of select="$element-qname"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="f:element-use-get-cardinality(.)"/>
        </TD>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xs:element[@name]"
                mode="component-diagram-td"
                as="element(TD)" xmlns="">
    <xsl:variable name="element-qname" as="xs:QName"
                  select="f:xs-component-get-qname(.)"/>
    <TD xmlns=""
        ALIGN="LEFT"
        HREF="{f:qname-get-href('../..', $element-qname)}"
        PORT="{generate-id(.)}">
      <xsl:variable name="definition" as="xs:string"
                    select="f:xs-component-get-definition(.)"/>
      <xsl:if test="string-length(normalize-space($definition)) gt 0">
        <xsl:attribute name="TOOLTIP" select="normalize-space($definition)"/>
      </xsl:if>
      <xsl:value-of select="$element-qname"/>
      <xsl:if test="exists(@type)">
        <xsl:variable name="type-qname" as="xs:QName"
                      select="f:attribute-get-qname(@type)"/>
        <xsl:text>: </xsl:text>
        <xsl:value-of select="$type-qname"/>
      </xsl:if>
    </TD>
  </xsl:template>

  <xsl:template match="@*|node" mode="component-diagram-td" priority="-1">
    <xsl:message terminate="yes">Unexpected content (mode=component-diagram-td; <xsl:value-of select="name()"/>)</xsl:message>
  </xsl:template>

</xsl:stylesheet>
