<xsl:stylesheet 
   version="2.0"
   xmlns:catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog"   
   xmlns:ns="http://example.org/namespaces"
   xmlns:xml="http://www.w3.org/XML/1998/namespace"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns="http://www.w3.org/1999/xhtml">

  <!-- context is an XML Catalog -->
  <xsl:param name="prefixes" as="document()" required="yes"/>

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

  <xsl:template match="ns:namespaces">
    <html>
      <head>
        <title>Index</title>
      </head>
      <body>
        <ul>
          <xsl:apply-templates select="ns:namespace"/>
        </ul>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="ns:namespace">
    <li>
      <a href="{@prefix}">
        <xsl:value-of select="@prefix"/>
      </a>
    </li>
  </xsl:template>

</xsl:stylesheet>
