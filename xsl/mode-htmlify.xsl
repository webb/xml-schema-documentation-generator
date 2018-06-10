<xsl:stylesheet 
   version="2.0"
   xmlns:xml="http://www.w3.org/XML/1998/namespace"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns="http://www.w3.org/1999/xhtml">

  <!-- ============================================================================= -->
  <!-- mode htmlify -->
  <!-- convert un-namespaced content to html content -->
  <!-- ============================================================================= -->

  <xsl:template mode="htmlify"
                match="*"
                xmlns="">
    <xsl:element
      name="{local-name()}"
      namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <xsl:template mode="htmlify"
                match="@*|node()"
                priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
