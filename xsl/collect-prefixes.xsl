<stylesheet 
   version="2.0"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:ns="http://example.org/namespaces"
   xmlns:catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog"   
   xmlns="http://www.w3.org/1999/XSL/Transform">

  <output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <template match="catalog:catalog">
    <variable name="namespaces" as="element(ns:namespace)+">
      <apply-templates select="catalog:uri"/>
    </variable>
    <for-each-group select="$namespaces" group-by="@uri">
      <if test="count(distinct-values(current-group())) gt 1">
        <message>Multiple prefixes for uri <value-of select="@uri"/>: <value-of select="distinct-values(current-group())"/>.</message>
      </if>
    </for-each-group>
    <for-each-group select="$namespaces" group-by="@prefix">
      <if test="count(distinct-values(current-group())) gt 1">
        <message>Multiple prefixes for prefix <value-of select="@prefix"/>: <value-of select="distinct-values(current-group())"/>.</message>
      </if>
    </for-each-group>
    <ns:namespaces>
      <for-each-group select="$namespaces" group-by="@prefix">
        <sort select="@prefix"/>
        <copy-of select="."/>
      </for-each-group>
    </ns:namespaces>
  </template>

  <template match="catalog:uri[@name and @uri[ends-with(., '.xsd')]]">
    <variable name="path" as="xs:anyURI"
              select="resolve-uri(@uri, base-uri(.))"/>
    <apply-templates select="doc($path)"/>
  </template>

  <template match="/xs:schema">
    <apply-templates select="." mode="prefixes"/>
  </template>

  <template match="*" mode="prefixes">
    <variable name="context" as="element()" select="."/>
    <for-each select="in-scope-prefixes($context)">
      <variable name="prefix" as="xs:string" select="."/>
      <variable name="namespace" as="xs:anyURI"
                select="namespace-uri-for-prefix($prefix, $context)"/>
      <variable name="parent" as="element()?" select="$context/parent::*"/>
      <choose>
        <when test="empty($parent)">
          <ns:namespace
             prefix="{$prefix}"
             uri="{$namespace}"/>
        </when>
        <when test="$namespace = namespace-uri-for-prefix($prefix, exactly-one($parent))"/>
        <otherwise>
          <ns:namespace
             prefix="{$prefix}"
             uri="{$namespace}"/>
        </otherwise>
      </choose>
    </for-each>
    <apply-templates select="*" mode="#current"/>
  </template>

</stylesheet>
