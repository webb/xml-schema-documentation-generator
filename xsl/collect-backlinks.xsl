<xsl:stylesheet 
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog"
  exclude-result-prefixes="catalog f ns xs"
  xmlns:f="http://example.org/functions"
  xmlns:bl="http://example.org/backlinks"
  xmlns:ns="http://example.org/namespaces"
  xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xsl:include href="common.xsl"/>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:template match="catalog:catalog">
    <bl:backlinks>
      <xsl:apply-templates select="catalog:uri[ends-with(@uri, '.xsd')]"/>
    </bl:backlinks>
  </xsl:template>

  <xsl:template match="catalog:uri">
    <xsl:apply-templates select="doc(resolve-uri(@uri, base-uri(.)))"/>
  </xsl:template>

  <xsl:template match="xs:schema">
    <xsl:apply-templates select="xs:complexType[@name]
                                 | xs:simpleType[@name]
                                 | xs:attribute[@name]
                                 | xs:attributeGroup[@name]
                                 | xs:element[@name]"/>
  </xsl:template>

  <xsl:template match="xs:complexType[@name]">
    <xsl:variable name="this" as="xs:QName" select="f:xs-component-get-qname(.)"/>
    <xsl:for-each select=".//xs:*[@base]">
      <xsl:variable name="base" as="xs:QName" select="f:ref-get-qname(., @base)"/>
      <bl:type-derivation derived-type="{$this}" base-type="{$base}">
        <xsl:namespace name="{prefix-from-QName($this)}"
                       select="namespace-uri-from-QName($this)"/>
        <xsl:namespace name="{prefix-from-QName($base)}"
                       select="namespace-uri-from-QName($base)"/>
      </bl:type-derivation>
    </xsl:for-each>
    <xsl:for-each select=".//xs:element[@ref]">
      <xsl:variable name="element" as="xs:QName" select="f:ref-get-qname(., @ref)"/>
      <bl:type-has-element type="{$this}" element="{$element}">
        <xsl:namespace name="{prefix-from-QName($this)}"
                       select="namespace-uri-from-QName($this)"/>
        <xsl:namespace name="{prefix-from-QName($element)}"
                       select="namespace-uri-from-QName($element)"/>
      </bl:type-has-element>
    </xsl:for-each>
    <xsl:for-each select=".//xs:attribute[@ref]">
      <xsl:variable name="attribute" as="xs:QName" select="f:ref-get-qname(., @ref)"/>
      <bl:type-has-attribute type="{$this}" attribute="{$attribute}">
        <xsl:namespace name="{prefix-from-QName($this)}"
                       select="namespace-uri-from-QName($this)"/>
        <xsl:namespace name="{prefix-from-QName($attribute)}"
                       select="namespace-uri-from-QName($attribute)"/>
      </bl:type-has-attribute>
    </xsl:for-each>
    <xsl:for-each select=".//xs:attributeGroup[@ref]">
      <xsl:variable name="attribute-group" as="xs:QName" select="f:ref-get-qname(., @ref)"/>
      <bl:type-has-attribute-group type="{$this}" attribute-group="{$attribute-group}">
        <xsl:namespace name="{prefix-from-QName($this)}"
                       select="namespace-uri-from-QName($this)"/>
        <xsl:namespace name="{prefix-from-QName($attribute-group)}"
                       select="namespace-uri-from-QName($attribute-group)"/>
      </bl:type-has-attribute-group>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="xs:simpleType[@name]">
    <xsl:variable name="this" as="xs:QName" select="f:xs-component-get-qname(.)"/>
    <xsl:for-each select=".//xs:*[@base]">
      <xsl:variable name="base" as="xs:QName" select="f:ref-get-qname(., @base)"/>
      <bl:type-derivation derived-type="{$this}" base-type="{$base}">
        <xsl:namespace name="{prefix-from-QName($this)}"
                       select="namespace-uri-from-QName($this)"/>
        <xsl:namespace name="{prefix-from-QName($base)}"
                       select="namespace-uri-from-QName($base)"/>
      </bl:type-derivation>
    </xsl:for-each>
    <xsl:for-each select=".//xs:attribute[@ref]">
      <xsl:variable name="attribute" as="xs:QName" select="f:ref-get-qname(., @ref)"/>
      <bl:type-has-attribute type="{$this}" attribute="{$attribute}">
        <xsl:namespace name="{prefix-from-QName($this)}"
                       select="namespace-uri-from-QName($this)"/>
        <xsl:namespace name="{prefix-from-QName($attribute)}"
                       select="namespace-uri-from-QName($attribute)"/>
      </bl:type-has-attribute>
    </xsl:for-each>
    <xsl:for-each select=".//xs:attributeGroup[@ref]">
      <xsl:variable name="attribute-group" as="xs:QName" select="f:ref-get-qname(., @ref)"/>
      <bl:type-has-attribute-group type="{$this}" attribute-group="{$attribute-group}">
        <xsl:namespace name="{prefix-from-QName($this)}"
                       select="namespace-uri-from-QName($this)"/>
        <xsl:namespace name="{prefix-from-QName($attribute-group)}"
                       select="namespace-uri-from-QName($attribute-group)"/>
      </bl:type-has-attribute-group>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="xs:element[@name]">
    <xsl:variable name="this" as="xs:QName" select="f:xs-component-get-qname(.)"/>
    <xsl:for-each select="self::*[@type]">
      <xsl:variable name="type" as="xs:QName" select="f:ref-get-qname(., @type)"/>
      <bl:element-of-type element="{$this}" type="{$type}">
        <xsl:namespace name="{prefix-from-QName($this)}"
                       select="namespace-uri-from-QName($this)"/>
        <xsl:namespace name="{prefix-from-QName($type)}"
                       select="namespace-uri-from-QName($type)"/>
      </bl:element-of-type>
    </xsl:for-each>
    <xsl:for-each select="self::*[@substitutionGroup]">
      <xsl:variable name="subst" as="xs:QName" select="f:ref-get-qname(., @substitutionGroup)"/>
      <bl:element-substitution-group element="{$this}" substitution-group="{$subst}">
        <xsl:namespace name="{prefix-from-QName($this)}"
                       select="namespace-uri-from-QName($this)"/>
        <xsl:namespace name="{prefix-from-QName($subst)}"
                       select="namespace-uri-from-QName($subst)"/>
      </bl:element-substitution-group>
    </xsl:for-each>

  </xsl:template>

  <xsl:template match="xs:attribute[@name]">
    <xsl:variable name="this" as="xs:QName" select="f:xs-component-get-qname(.)"/>
    <xsl:for-each select="self::*[@type]">
      <xsl:variable name="type" as="xs:QName" select="f:ref-get-qname(., @type)"/>
      <bl:attribute-of-type attribute="{$this}" type="{$type}">
        <xsl:namespace name="{prefix-from-QName($this)}"
                       select="namespace-uri-from-QName($this)"/>
        <xsl:namespace name="{prefix-from-QName($type)}"
                       select="namespace-uri-from-QName($type)"/>
      </bl:attribute-of-type>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="xs:attributeGroup[@name]">
    <xsl:variable name="this" as="xs:QName" select="f:xs-component-get-qname(.)"/>
    <xsl:for-each select="xs:attribute[@ref]">
      <xsl:variable name="attribute" as="xs:QName" select="f:ref-get-qname(., @ref)"/>
      <bl:attribute-group-has-attribute attribute-group="{$this}" attribute="{$attribute}">
        <xsl:namespace name="{prefix-from-QName($this)}"
                       select="namespace-uri-from-QName($this)"/>
        <xsl:namespace name="{prefix-from-QName($attribute)}"
                       select="namespace-uri-from-QName($attribute)"/>
      </bl:attribute-group-has-attribute>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
