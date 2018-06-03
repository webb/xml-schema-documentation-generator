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

  <!-- context is an XML Catalog -->
  <xsl:param name="prefixes-file" required="yes"/>
  <xsl:variable name="prefixes" as="element(ns:namespace)+"
                select="$prefixes-file/ns:namespaces/ns:namespace"/>

  <xsl:param name="root-path" as="xs:string" required="yes"/>

  <xsl:output method="text" encoding="us-ascii"/>

  <!-- ================================================================== -->
  <!-- functions -->
  <!-- ================================================================== -->

  <xsl:function name="f:get-prefix" as="xs:string">
    <xsl:param name="context" as="element()"/>
    <xsl:variable name="target-namespace" as="xs:string"
                  select="root($context)/@targetNamespace"/>
    <xsl:variable name="prefix" as="xs:string"
                  select="$prefixes/ns:namespace[@uri=$target-namespace]/@prefix"/>
    <xsl:sequence select="$prefix"/>
  </xsl:function>
  
  <!-- ================================================================== -->
  <!-- templates, in order of appearance -->
  <!-- ================================================================== -->

  <xsl:template match="catalog:catalog">
    <xsl:result-document
       href="{$root-path}/index.html"
       method="xml" version="1.0" encoding="UTF-8" indent="yes">
      <html>
        <head>
          <title>Index</title>
        </head>
        <body>
          <ul>
            <xsl:apply-templates select="$prefixes" mode="index-of-namespaces"/>
          </ul>
        </body>
      </html>
    </xsl:result-document>
    <!-- <xsl:apply-templates select="xsl:uri[ends-with(@uri, '.xsd')]"/> -->
  </xsl:template>

  <xsl:template match="ns:namespace" mode="index-of-namespaces">
    <li>
      <a href="{@prefix}">
        <xsl:value-of select="@prefix"/>
      </a>
    </li>
  </xsl:template>

<!-- 
  <xsl:template match="catalog:uri">
    <xsl:apply-templates select="resolve-uri(@uri, base-uri(.))"/>
  </xsl:template>

  <xsl:template match="xs:schema">
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
    <xsl:apply-templates select="xs:complexType|xs:element"/>
  </xsl:template>

  <xsl:template match="xs:complexType">
    <xsl:variable name="target-namespace" select="/xs:schema/@targetNamespace"/>
    <xsl:variable name="prefix" as="xs:string"
                  select="$prefixes/ns:namespace[@uri=$target-namespace]/@prefix"/>
    
    <xsl:result-document
       href="{f:get-prefix(.)}/{@name}"
       method="xml" version="1.0" encoding="UTF-8" indent="yes">
      <xsl:apply-templates select="." mode="page"/>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="xs:complexType" mode="page">
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

  -->

</xsl:stylesheet>
