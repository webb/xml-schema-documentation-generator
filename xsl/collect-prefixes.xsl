<stylesheet 
   version="2.0"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:ns="http://example.org/namespaces"
   xmlns:catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog"   
   xmlns="http://www.w3.org/1999/XSL/Transform">

  <output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <template match="catalog:catalog">
    <!-- harvest namespaces from schemas -->
    <variable name="harvested" as="element(ns:namespace)+">
      <apply-templates select="catalog:uri"/>
    </variable>
    <!-- make sure every namespace <= 1 prefix -->
    <for-each-group select="$harvested" group-by="@uri">
      <if test="count(distinct-values(current-group())) gt 1">
        <message>Multiple prefixes for uri <value-of select="@uri"/>: <value-of select="distinct-values(current-group())"/>.</message>
      </if>
    </for-each-group>
    <!-- make sure every prefix has <= 1 namespace -->
    <for-each-group select="$harvested" group-by="@prefix">
      <if test="count(distinct-values(current-group())) gt 1">
        <message>Multiple prefixes for prefix <value-of select="@prefix"/>: <value-of select="distinct-values(current-group())"/>.</message>
      </if>
    </for-each-group>
    <!-- simplify list of prefixes -->
    <variable name="simplified" as="element(ns:namespace)+">
      <for-each-group select="$harvested" group-by="@prefix">
        <sequence select="."/>
      </for-each-group>
    </variable>
    <!--
    <for-each select="$simplified">
      <message>simplified name=<value-of select="name()"/> prefix=<value-of select="@prefix"/> namespace=<value-of select="@uri"/></message>
    </for-each>
    -->
    <!-- synthesize prefixes where needed -->
    <variable name="synthesized" as="element(ns:namespace)+">
      <sequence select="$simplified"/>
      <for-each select="catalog:uri/@name">
        <if test="empty($simplified[@uri = current()])">
          <choose>
            <when test=". = 'http://reference.niem.gov/niem/specification/code-lists/4.0/code-lists-instance/'">
              <ns:namespace prefix="cli" uri="{.}"/>
            </when>
            <otherwise>
              <message terminate="yes">No prefix for namespace <value-of select="."/></message>
            </otherwise>
          </choose>
        </if>
      </for-each>
    </variable>
    <!-- provide results -->
    <ns:namespaces>
      <for-each select="$synthesized">
        <sort select="@prefix"/>
        <copy-of select="."/>
      </for-each>
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
