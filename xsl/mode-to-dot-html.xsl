<xsl:stylesheet 
   version="2.0"
   xmlns:f="http://example.org/functions"
   xmlns:xml="http://www.w3.org/XML/1998/namespace"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- mode to-dot-html -->

  <!-- Convert un-namespaced XML content into text appropriate for GraphViz DOT HTML labels -->

  <xsl:function name="f:to-dot-html" as="xs:string">
    <xsl:param name="item" as="item()*"/>
    <xsl:variable name="html" as="xs:string">
      <xsl:value-of>
        <xsl:text>&lt;</xsl:text>
        <xsl:apply-templates select="$item" mode="to-dot-html"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:value-of>
    </xsl:variable>
    <xsl:value-of select="$html"/>
  </xsl:function>

  <!-- convert a data string (like documentation) to text that looks right to be in a DOT HTML label -->
  <xsl:function name="f:string-to-dot-html" as="xs:string">
    <xsl:param name="in" as="xs:string"/>
    <xsl:variable name="apos" as="xs:string">&apos;</xsl:variable>
    <xsl:value-of select="replace(replace(replace(replace(replace($in, '&amp;', '&amp;amp;'),
                          '&quot;', '&amp;quot;'),
                          '&lt;', '&amp;lt;'),
                          '&gt;', '&amp;gt;'),
                          $apos, '&amp;apos;')"/>
  </xsl:function>

  <xsl:template match="HR" xmlns="" mode="to-dot-html">
    <xsl:choose>
      <xsl:when test="following-sibling::*">&lt;HR/&gt;&#10;</xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="TABLE | TR" xmlns=""
                mode="to-dot-html">
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:apply-templates select="@*" mode="#current"/>
    <xsl:text>&gt;&#10;</xsl:text>
    <xsl:apply-templates select="node()" mode="#current"/>
    <xsl:text>&lt;/</xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text>&gt;&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="TD" xmlns=""
                mode="to-dot-html">
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:apply-templates select="@*" mode="#current"/>
    <xsl:choose>
      <xsl:when test="(count(parent::TR/preceding-sibling::TR) mod 2) = 1">
        <xsl:text> BGCOLOR="gray92"</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:text>&gt;</xsl:text>
    <xsl:apply-templates select="node()" mode="#current"/>
    <xsl:text>&lt;/</xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text>&gt;&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="*[namespace-uri(.) = '']"
                priority="-1"
                mode="to-dot-html">
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:apply-templates select="@*" mode="#current"/>
    <xsl:text>&gt;</xsl:text>
    <xsl:apply-templates select="node()" mode="#current"/>
    <xsl:text>&lt;/</xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>

  <xsl:template match="@*[namespace-uri(.) = '']" priority="-1" mode="to-dot-html">
    <xsl:text> </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text>=&quot;</xsl:text>
    <xsl:value-of select="f:string-to-dot-html(.)"/>
    <xsl:text>&quot;</xsl:text>
  </xsl:template>

  <xsl:template match="text()" priority="-1" mode="to-dot-html">
    <xsl:value-of select="f:string-to-dot-html(.)"/>
  </xsl:template>

  <xsl:template match="@*|node()" priority="-2" mode="to-dot-html">
    <xsl:message terminate="yes">Unexpected content (mode=to-dot-html, name=<xsl:value-of select="name()"/> (namespace=<xsl:value-of select="namespace-uri(.)"/>)</xsl:message>
  </xsl:template>

</xsl:stylesheet>
