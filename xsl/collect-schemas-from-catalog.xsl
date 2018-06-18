<stylesheet 
   version="2.0"
   xmlns:catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog"   
   xmlns:i="http://example.org/schemas-list/"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns="http://www.w3.org/1999/XSL/Transform">

  <output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <template match="/">
    <message>match /<value-of select="base-uri(.)"/></message>
    <i:list>
      <apply-templates mode="list"/>
    </i:list>
  </template>

  <template match="catalog:catalog" mode="list">
    <message>match catalog:catalog<value-of select="base-uri(.)"/></message>
    <apply-templates select="*[1]" mode="#current"/>
  </template>

  <template match="catalog:uri[@name and @uri[ends-with(., '.xsd')]]" mode="list">
    <param name="namespaces-seen" tunnel="yes" as="xs:anyURI*" select="()"/>
    <variable name="this-name" as="xs:anyURI" select="@name"/>
    <message>match catalog:uri[@name...<value-of select="base-uri(.)"/>,
    namespaces-seen=<value-of select="$namespaces-seen"/></message>
    <if test="not($this-name = $namespaces-seen)">
      <variable name="reference" as="xs:anyURI" select="resolve-uri(@uri, base-uri(.))"/>
      <if test="not(doc-available($reference))">
        <message terminate="yes">Catalog <value-of select="base-uri(.)"/> uri references <value-of select="@uri"/>, which resolves to <value-of select="$reference"/>, which is not available.</message>
      </if>
      <apply-templates select="doc($reference)" mode="#current">
        <with-param name="namespace" tunnel="yes"
                    select="@name cast as xs:anyURI"/>
      </apply-templates>
      <apply-templates select="following-sibling::*[1]" mode="#current">
        <with-param name="namespaces-seen" tunnel="yes"
                    select="$namespaces-seen, $this-name"/>
      </apply-templates>
    </if>
  </template>

  <template match="/xs:schema" mode="list">
    <!-- expected namespace provided via catalog or import or include -->
    <param name="namespace" as="xs:anyURI" tunnel="yes"
           select="xs:anyURI('https://example.org/bogus')"/>
    <!-- true if we got to the schema via an include into the expected namespace -->
    <param name="via-include" as="xs:boolean" select="false()"/>
    <param name="schemas-seen" as="xs:anyURI*" tunnel="yes" select="()"/>
    <message>match /xs:schema[@name...<value-of select="base-uri(.)"/>.
    schemas-seen = <value-of select="$schemas-seen"/></message>
    <choose>
      <when test="exists(@targetNamespace)">
        <if test="(@targetNamespace cast as xs:anyURI) != $namespace">
          <message terminate="yes">In schema <value-of select="base-uri(.)"/>, @targetNamespace is not the expected namespace (<value-of select="$namespace"/>).</message>
        </if>
      </when>
      <when test="$via-include"/>
      <otherwise>
        <if test="$namespace != ('' cast as xs:anyURI)">
          <message terminate="yes">Schema <value-of select="base-uri(.)"/> has no @targetNamespace, but expected namespace (<value-of select="$namespace"/>).</message>
        </if>
      </otherwise>
    </choose>
    <message>schemas-seen=<value-of select="$schemas-seen"/></message>
    <if test="not(base-uri(.) = $schemas-seen)">
      <i:schema namespace="{$namespace}" location="{base-uri(.)}"/>
      <apply-templates select="xs:include | xs:import" mode="#current">
        <with-param name="schemas-seen" as="xs:anyURI*" tunnel="yes"
                    select="$schemas-seen, base-uri(.)"/>
      </apply-templates>
    </if>
  </template>

  <template match="xs:include[@schemaLocation]" mode="list">
    <message>match xs:include <value-of select="base-uri(.)"/></message>
    <variable name="reference" as="xs:anyURI"
              select="resolve-uri(@schemaLocation, base-uri(.))"/>
    <if test="not(doc-available($reference))">
      <message terminate="yes">Schema <value-of select="base-uri(.)"/> includes <value-of select="@schemaLocation"/>, which resolves to <value-of select="$reference"/>, which is not available.</message>
    </if>
    <apply-templates select="doc($reference)" mode="#current">
      <with-param name="via-include" select="true()"/>
    </apply-templates>
  </template>

  <template match="xs:import[@schemaLocation]" mode="list">
    <message>match xs:import doc=<value-of select="base-uri(.)"/>, schemaLocation=<value-of select="@schemaLocation"/></message>
    <variable name="reference" as="xs:anyURI"
              select="resolve-uri(@schemaLocation, base-uri(.))"/>
    <if test="not(doc-available($reference))">
      <message terminate="yes">Schema <value-of select="base-uri(.)"/> imports <value-of select="@schemaLocation"/>, which resolves to <value-of select="$reference"/>, which is not available.</message>
    </if>
    <apply-templates select="doc($reference)" mode="#current">
      <with-param name="namespace" as="xs:anyURI" tunnel="yes"
                     select="if (exists(@namespace)) 
                             then (@namespace cast as xs:anyURI)
                             else ('' cast as xs:anyURI)"/>
    </apply-templates>
  </template>

  <template match="text()" mode="list"/>
  <template match="comment()" mode="list"/>
  <template match="processing-instruction()" mode="list"/>
  
  <template match="catalog:uri" mode="list" priority="-1">
  </template>

  <template match="@*|node()" mode="list" priority="-2">
    <message terminate="yes">Unexpected content (mode=list, name()=<value-of select="name()"/>)</message>
  </template>

</stylesheet>
