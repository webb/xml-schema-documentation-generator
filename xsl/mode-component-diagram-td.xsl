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
    <xsl:variable name="resolved" as="element()?" select="f:qname-resolve($qname)"/>
    <xsl:choose>
      <xsl:when test="exists($resolved)">
        <xsl:apply-templates select="$resolved" mode="component-diagram-td"/>
      </xsl:when>
      <xsl:otherwise>
        <TD xmlns="" ALIGN="LEFT" TARGET="_top"
            HREF="{f:qname-get-href('../..', $qname)}#diagram">
          <xsl:value-of select="$qname"/>
        </TD>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="f:qname-get-td-brief">
    <xsl:param name="qname" as="xs:QName"/>
    <xsl:apply-templates select="f:qname-resolve($qname)"
                         mode="component-diagram-td">
      <xsl:with-param name="brief" select="true()" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:function>

  <xsl:template match="/xs:schema/xs:complexType[@name]
                       | /xs:schema/xs:simpleType[@name]
                       | /xs:schema/xs:attribute[@name]
                       | /xs:schema/xs:attributeGroup[@name]"
                mode="component-diagram-td">
    <xsl:variable name="qname" select="f:xs-component-get-qname(.)"/>
    <TD xmlns="" ALIGN="LEFT" TARGET="_top"
        HREF="{f:qname-get-href('../..', $qname)}#diagram"
        PORT="{generate-id(.)}">
      <xsl:variable name="definition" as="xs:string"
                    select="f:xs-component-get-definition(.)"/>
      <xsl:if test="string-length(normalize-space($definition)) gt 0">
        <xsl:attribute name="TOOLTIP" select="$definition"/>
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
          <xsl:value-of select="f:element-use-get-cardinality(.)"/>
        </TD>
      </xsl:when>
      <xsl:otherwise>
        <TD xmlns=""
            ALIGN="LEFT">
          <xsl:value-of select="$element-qname"/>
          <xsl:value-of select="f:element-use-get-cardinality(.)"/>
        </TD>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xs:attribute[@ref]"
                mode="component-diagram-td"
                as="element(TD)" xmlns="">
    <xsl:variable name="attribute-qname" as="xs:QName"
                  select="f:attribute-get-qname(@ref)"/>
    <xsl:variable name="attribute" as="element()?"
                  select="f:qname-resolve-attribute($attribute-qname)"/>
    <xsl:choose>
      <xsl:when test="exists($attribute)">
        <xsl:variable name="td" as="element(TD)">
          <xsl:apply-templates select="$attribute" mode="#current"/>
        </xsl:variable>
        <TD>
          <xsl:copy-of select="$td/@*"/>
          <xsl:value-of select="$td/text()"/>
          <xsl:value-of select="f:attribute-use-get-cardinality(.)"/>
        </TD>
      </xsl:when>
      <xsl:otherwise>
        <TD xmlns=""
            ALIGN="LEFT">
          <xsl:value-of select="$attribute-qname"/>
          <xsl:value-of select="f:attribute-use-get-cardinality(.)"/>
        </TD>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xs:anyAttribute"
                mode="component-diagram-td"
                as="element(TD)" xmlns="">
    <xsl:variable name="documentation" as="xs:string">
      <xsl:value-of>
        <xsl:text>Allow any attribute</xsl:text>
        <xsl:if test="exists(@namespace)">
          <xsl:text> from namespace </xsl:text>
          <xsl:value-of select="f:sequence-as-text-list(tokenize(normalize-space(@namespace), ' '), 'or')"/>
        </xsl:if>
      </xsl:value-of>
    </xsl:variable>
    <TD xmlns="" ALIGN="LEFT" TARGET="_top" HREF="#diagram" TOOLTIP="{$documentation}">anyAttribute</TD>
  </xsl:template>

  <xsl:template match="xs:element[@name]"
                mode="component-diagram-td"
                as="element(TD)" xmlns="">
    <xsl:param name="brief" as="xs:boolean" select="false()" tunnel="yes"/>
    <xsl:variable name="element-qname" as="xs:QName"
                  select="f:xs-component-get-qname(.)"/>
    <TD xmlns="" ALIGN="LEFT" TARGET="_top"
        HREF="{f:qname-get-href('../..', $element-qname)}#diagram"
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
        <xsl:if test="not($brief)">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$type-qname"/>
        </xsl:if>
      </xsl:if>
    </TD>
  </xsl:template>

  <xsl:template match="@*|node" mode="component-diagram-td" priority="-1">
    <xsl:message terminate="yes">Unexpected content (mode=component-diagram-td; <xsl:value-of select="name()"/>)</xsl:message>
  </xsl:template>

</xsl:stylesheet>
