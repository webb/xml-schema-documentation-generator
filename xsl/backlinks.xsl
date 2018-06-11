<xsl:stylesheet 
   exclude-result-prefixes="xs f bl"
   version="2.0"
   xmlns:bl="http://example.org/backlinks"
   xmlns:f="http://example.org/functions"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="backlinks-file" required="yes"/>
  <xsl:variable name="backlinks" as="element(bl:backlinks)"
                select="$backlinks-file/bl:backlinks"/>

  <xsl:function name="f:backlinks-get-elements-of-type" as="xs:QName*">
    <xsl:param name="type" as="xs:QName"/>
    <xsl:for-each
       select="$backlinks/bl:element-of-type[f:attribute-get-qname(@type) = $type]">
      <xsl:sequence select="f:attribute-get-qname(@element)"/>
    </xsl:for-each>
  </xsl:function>

  <xsl:function name="f:backlinks-get-attributes-of-type" as="xs:QName*">
    <xsl:param name="type" as="xs:QName"/>
    <xsl:for-each
       select="$backlinks/bl:attribute-of-type[f:attribute-get-qname(@type) = $type]">
      <xsl:sequence select="f:attribute-get-qname(@attribute)"/>
    </xsl:for-each>
  </xsl:function>

</xsl:stylesheet>
