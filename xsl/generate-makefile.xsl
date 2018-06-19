<xsl:stylesheet 
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog"   
  xmlns:f="http://example.org/functions"
  xmlns:ns="http://example.org/namespaces"
  xmlns:appinfo="http://release.niem.gov/niem/appinfo/4.0/"
  xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xsl:include href="common.xsl"/>

  <xsl:output method="text" encoding="US-ASCII"/>

  <xsl:template match="/catalog:catalog">
    <xsl:variable name="components" as="xs:QName*">
      <xsl:apply-templates select="." mode="components"/>
    </xsl:variable>
    <xsl:variable name="components-sorted" as="xs:QName*">
      <xsl:for-each select="distinct-values($components)">
        <xsl:sort select="string(.)"/>
        <xsl:sequence select="."/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="prefixes" as="xs:string*">
      <xsl:for-each-group select="$components-sorted"
                          group-by="prefix-from-QName(.)">
        <xsl:value-of select="current-grouping-key()"/>
      </xsl:for-each-group>
    </xsl:variable>

    <xsl:text>namespaces = \&#10;</xsl:text>
    <xsl:for-each select="$prefixes">
      <xsl:text>  </xsl:text>
      <xsl:value-of select="."/>
      <xsl:text> \&#10;</xsl:text>
    </xsl:for-each>
    <xsl:text>&#10;</xsl:text>
    
    <xsl:text>components = \&#10;</xsl:text>
    <xsl:for-each select="$components-sorted">
      <xsl:text>  </xsl:text>
      <xsl:value-of select="prefix-from-QName(.)"/>
      <xsl:text>/</xsl:text>
      <xsl:value-of select="local-name-from-QName(.)"/>
      <xsl:text> \&#10;</xsl:text>
    </xsl:for-each>
    <xsl:text>&#10;</xsl:text>
    
    <!--
    <xsl:text>namespaces = \&#10;</xsl:text>
    <xsl:apply-templates mode="namespaces" select="."/>
    <xsl:text>&#10;</xsl:text>
    -->
    
  </xsl:template>

  <!-- ============================================================================= -->
  <!-- mode: namespaces -->

  <xsl:template mode="namespaces"
                match="catalog:catalog">
    <xsl:apply-templates select="*" mode="#current"/>
  </xsl:template>
  
  <!-- ============================================================================= -->
  <!-- mode: components -->

  <xsl:template match="catalog:catalog" as="xs:QName*"
                mode="components">
    <xsl:apply-templates select="*" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="catalog:uri[@name and ends-with(@uri, '.xsd')]" as="xs:QName*"
                mode="components">
    <xsl:apply-templates 
      select="doc(resolve-uri(@uri, base-uri(.)))/*"
      mode="#current"/>
  </xsl:template>

  <xsl:template mode="components"
                match="xs:schema" as="xs:QName*">
    <xsl:apply-templates mode="#current"
                         select="xs:*"/>
  </xsl:template>

  <xsl:template match="xs:import" mode="components"/>

  <xsl:template match="
                       xs:attribute/@name |
                       xs:attributeGroup/@name |
                       xs:complexType/@name |
                       xs:element/@name |
                       xs:simpleType/@name
                       " mode="components">
    <xsl:sequence select="f:xs-component-get-qname(..)"/>
  </xsl:template>

  <xsl:template match="
                       xs:attribute/@type |
                       xs:attribute/@ref |
                       xs:attributeGroup/@ref |
                       xs:element/@ref |
                       xs:element/@type |
                       xs:element/@substitutionGroup |
                       xs:extension/@base |
                       xs:list/@itemType |
                       xs:restriction/@base
                       " mode="components">
    <xsl:sequence select="f:attribute-get-qname(.)"/>
  </xsl:template>

  <xsl:template match="
                       xs:element/@appinfo:appliesToTypes |
                       xs:union/@memberTypes
                       " mode="components">
    <xsl:variable name="context" as="element()" select=".."/>
    <xsl:for-each select="tokenize(normalize-space(.), ' ')">
      <xsl:sequence select="f:ref-get-qname($context, .)"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="appinfo:LocalTerm |
                       xs:*/@value |
                       xs:anyAttribute/@namespace |
                       xs:anyAttribute/@processContents |
                       xs:attribute/@use |
                       xs:complexType/@abstract |
                       xs:complexType/@appinfo:externalAdapterTypeIndicator |
                       xs:element/@abstract |
                       xs:element/@form |
                       xs:element/@maxOccurs |
                       xs:element/@minOccurs |
                       xs:element/@nillable
                       " mode="components"/>

  <xsl:template match="catalog:uri" priority="-1" mode="components"/>

  <xsl:template match="xs:*" priority="-1" mode="components">
    <xsl:apply-templates select="@*|*" mode="#current"/>
  </xsl:template>

  <xsl:template match="@*" priority="-2" mode="components">
    <xsl:message terminate="yes">Unknown attribute <xsl:value-of select="name(..)"/>/@<xsl:value-of select="name()"/></xsl:message>
  </xsl:template>

  <xsl:template match="*" priority="-2" mode="components">
    <xsl:message terminate="yes">Unknown element <xsl:value-of select="name()"/> in <xsl:value-of select="base-uri(.)"/></xsl:message>
  </xsl:template>

  <xsl:template match="@*|node()" priority="-3" mode="components">
    <xsl:message terminate="yes">unexpected content in <xsl:value-of select="base-uri(.)"/></xsl:message>
  </xsl:template>

</xsl:stylesheet>
