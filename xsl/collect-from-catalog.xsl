<stylesheet 
   version="2.0"
   xmlns:i="http://example.org/xml-catalog-info/"
   xmlns:catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog"   
   xmlns="http://www.w3.org/1999/XSL/Transform">

  <output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <template match="/">
    <i:info>
      <apply-templates/>
    </i:info>
  </template>

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
    <!-- synthesize prefixes where needed -->
    <variable name="synthesized" as="element(ns:namespace)+">
      <sequence select="$simplified"/>
      <for-each select="catalog:uri[ends-with(@uri, '.xsd')]/@name">
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

  <template match="catalog:uri[@name and @uri]">
    <choose>
      <when test="ends-with(@uri, '.xsd')">
        <variable name="resource-path" as="xs:anyURI"
                  select="resolve-uri(@uri, base-uri(.))"/>
        <if test="not(doc-available($resource-path))">
          <message terminate="yes">doc not avalable: <value-of select="$resource-path"/></message>
        </if>
        <variable name="resource" as="document-node()"
                  select="exactly-one(doc($resource-path))"/>
        <if test="not($resource/xs:schema)">
          <message terminate="yes">Doc should be XML Schema but isn't (name is <value-of select="@uri"/>, path is <value-of select="$resource-path"/>)</message>
        </if>
        <apply-templates select="$resource"/>
      </when>
      <when test="ends-with(@uri, '.csv')"/>
      <otherwise>
        <message terminate="yes">Found catalog:uri with bad uri (<value-of select="@uri"/>)</message>
      </otherwise>
    </choose>
  </template>

  <template match="/xs:schema">
    <apply-templates select="." mode="prefixes"/>
  </template>

  <!-- #############################################################################
       mode: prefixes

       Collect all namespace prefix declarations

       -->

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
