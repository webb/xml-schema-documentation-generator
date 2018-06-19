<xsl:stylesheet 
   exclude-result-prefixes="xs f"
   version="2.0"
   xmlns:f="http://example.org/functions"
   xmlns:xml="http://www.w3.org/XML/1998/namespace"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- input is any XML -->
  <!-- outputs a Graphviz DOT file -->

  <xsl:include href="common.xsl"/>
  <xsl:include href="backlinks.xsl"/>
  <xsl:include href="mode-to-dot-html.xsl"/>
  <xsl:include href="mode-component-diagram-td.xsl"/>

  <xsl:param name="root-path" as="xs:string" required="yes"/>
  <xsl:param name="prefix" as="xs:string" required="yes"/>
  <xsl:param name="local-name" as="xs:string" required="yes"/>

  <xsl:output method="text" encoding="UTF-8"/>

  <!-- ================================================================== -->
  <!-- mode: component-diagram -->
  <!-- ================================================================== -->

  <xsl:template match="/" mode="component-diagram">
    <xsl:variable name="qname" as="xs:QName"
              select="f:get-qname($prefix, $local-name)"/>
    <xsl:variable name="component" as="element()"
                  select="f:qname-resolve($qname)"/>
    <xsl:apply-templates select="$component" mode="#current"/>
  </xsl:template>

  <xsl:template match="/xs:schema/xs:complexType[@name]" mode="component-diagram">
    <xsl:variable name="qname" as="xs:QName" select="f:xs-component-get-qname(.)"/>
    <xsl:variable name="object" as="item()*" xmlns="">
      <TABLE BORDER="5" CELLBORDER="0" CELLPADDING="0" CELLSPACING="0" COLOR="RED">
        <TR>
          <TD ALIGN="LEFT" PORT="top">
            <B><xsl:value-of select="$qname"/></B>
          </TD>
        </TR>
        <HR/>
        <xsl:apply-templates mode="component-diagram-type-table"/>
      </TABLE>
    </xsl:variable>

    <xsl:text>digraph graphic {&#10;</xsl:text>
    <xsl:text>edge [fontname = "Helvetica", fontsize = 12, dir = forward];&#10;</xsl:text>
    <xsl:text>node [fontname = "Helvetica", fontsize = 12, shape = plain];&#10;</xsl:text>
    <xsl:text>rankdir=LR;&#10;</xsl:text>

    <xsl:value-of select="f:enquote(string($qname))"/> [shape=plain, label=<xsl:value-of select="f:to-dot-html($object)"/>];

    <xsl:for-each select="f:backlinks-get-elements-had-by-type($qname)">
      <xsl:variable name="element-qname" as="xs:QName" select="."/>
      <xsl:variable name="substitutable-elements" as="xs:QName*"
                    select="f:backlinks-get-substitutable-elements($element-qname)"/>
      <xsl:if test="exists($substitutable-elements)">
        <xsl:variable name="element" as="element(xs:element)"
                      select="f:qname-resolve-element($element-qname)"/>
        <xsl:variable name="substitutable-elements">
          <TABLE BORDER="1" CELLBORDER="0" CELLPADDING="0" CELLSPACING="0" xmlns="">
            <TR>
              <TD ALIGN="LEFT" PORT="top"
                  HREF="{f:qname-get-href('../..', $element-qname)}#diagram">
                <B>Substitution group <xsl:value-of select="$element-qname"/></B>
              </TD>
            </TR>
            <HR/>
            <xsl:for-each select="$substitutable-elements">
              <TR><xsl:sequence select="f:qname-get-td(.)"/></TR>
            </xsl:for-each>
          </TABLE>
        </xsl:variable>

        <xsl:text>subst_</xsl:text>
        <xsl:value-of select="generate-id($element)"/>
        <xsl:text> [shape=plain, label=</xsl:text>
        <xsl:value-of select="f:to-dot-html($substitutable-elements)"/>
        <xsl:text>];</xsl:text>

        <xsl:value-of select="f:enquote(string($qname))"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="generate-id($element)"/>
        <xsl:text>:e -&gt; subst_</xsl:text>
        <xsl:value-of select="generate-id($element)"/>
        <xsl:text>:top:w [dir=back];</xsl:text>

      </xsl:if>
    </xsl:for-each>

    <xsl:variable name="elements-of-this-type" as="xs:QName*"
                  select="f:backlinks-get-elements-of-type($qname)"/>
    <xsl:variable name="attributes-of-this-type" as="xs:QName*"
                  select="f:backlinks-get-attributes-of-type($qname)"/>
    <xsl:if test="exists($elements-of-this-type) or exists($attributes-of-this-type)">
      <xsl:variable name="properties-object">
        <TABLE BORDER="1" CELLBORDER="0" CELLPADDING="0" CELLSPACING="0" xmlns="">
          <TR>
            <TD ALIGN="LEFT" PORT="top">
              <B>Properties</B>
            </TD>
          </TR>
          <HR/>
          <xsl:for-each select="$attributes-of-this-type">
            <TR><xsl:sequence select="f:qname-get-td(.)"/></TR>
          </xsl:for-each>
          <xsl:for-each select="$elements-of-this-type">
            <TR><xsl:sequence select="f:qname-get-td(.)"/></TR>
          </xsl:for-each>
        </TABLE>
      </xsl:variable>

      <xsl:text>Properties [shape=plain, label=</xsl:text>
      <xsl:value-of select="f:to-dot-html($properties-object)"/>
      <xsl:text>];&#10;</xsl:text>
      
      <xsl:text>Properties:top -&gt; </xsl:text>
      <xsl:value-of select="f:enquote(string($qname))"/>
      <xsl:text>:top [label="type"];&#10;</xsl:text>
    </xsl:if>

    <xsl:variable name="derived-types" as="xs:QName*"
                  select="f:backlinks-get-types-derived-from-type($qname)"/>
    <xsl:if test="exists($derived-types)">
      <xsl:variable name="derived-types-object">
        <TABLE BORDER="1" CELLBORDER="0" CELLPADDING="0" CELLSPACING="0" xmlns="">
          <TR>
            <TD ALIGN="LEFT">
              <B>Derived types</B>
            </TD>
          </TR>
          <HR/>
          <xsl:for-each select="$derived-types">
            <TR><xsl:sequence select="f:qname-get-td(.)"/></TR>
          </xsl:for-each>
        </TABLE>
      </xsl:variable>

      <xsl:text>DerivedTypes [shape=plain, label=</xsl:text>
      <xsl:value-of select="f:to-dot-html($derived-types-object)"/>
      <xsl:text>];</xsl:text>

      <xsl:text>{ rank = same; DerivedTypes; </xsl:text>
      <xsl:value-of select="f:enquote(string($qname))"/>
      <xsl:text>; }&#10;</xsl:text>
      
      <xsl:value-of select="f:enquote(string($qname))"/>  -&gt; DerivedTypes [label="derived"];
    </xsl:if>
    
    <xsl:apply-templates select=".//xs:*[@base]/@base" mode="component-diagram-base-type"/>

    <xsl:text>}&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="/xs:schema/xs:element[@name]" mode="component-diagram">
    <xsl:variable name="qname" as="xs:QName" select="f:xs-component-get-qname(.)"/>
    <xsl:variable name="element" as="item()*" xmlns="">
      <TABLE BORDER="5" COLOR="red" CELLBORDER="0" CELLPADDING="0" CELLSPACING="0">
        <TR>
          <TD ALIGN="LEFT">
            <B><xsl:value-of select="$qname"/></B>
          </TD>
        </TR>
      </TABLE>
    </xsl:variable>
    <xsl:text>
      digraph graphic {
      edge [fontname = "Helvetica", fontsize = 12, dir = forward];
      node [fontname = "Helvetica", fontsize = 12, shape = plain];
      rankdir=LR;
    </xsl:text>
    
    <xsl:value-of select="f:enquote(string($qname))"/>
    <xsl:text>[shape=plain, label = </xsl:text>
    <xsl:value-of select="f:to-dot-html($element)"/>
    <xsl:text>];&#10;</xsl:text>

    <xsl:variable name="types-having-this-element" as="xs:QName*"
                  select="f:backlinks-get-types-having-element($qname)"/>
    <xsl:if test="exists($types-having-this-element)">
      <xsl:variable name="types-having-this-element-object">
        <TABLE BORDER="1" CELLBORDER="0" CELLPADDING="0" CELLSPACING="0" xmlns="">
          <TR>
            <TD ALIGN="LEFT" PORT="top">
              <B>Types</B>
            </TD>
          </TR>
          <HR/>
          <xsl:for-each select="$types-having-this-element">
            <TR><xsl:sequence select="f:qname-get-td(.)"/></TR>
          </xsl:for-each>
        </TABLE>
      </xsl:variable>

      Types [shape=plain, label=<xsl:value-of select="f:to-dot-html($types-having-this-element-object)"/>];
      Types:top -&gt; <xsl:value-of select="f:enquote(string($qname))"/> [label="has-a"];
    </xsl:if>
    
    <xsl:if test="exists(@substitutionGroup)">
      <xsl:variable name="subst">
        <TABLE BORDER="1" CELLBORDER="0" CELLPADDING="0" CELLSPACING="0" xmlns="">
          <TR>
            <xsl:sequence select="f:qname-get-td(f:attribute-get-qname(@substitutionGroup))"/>
          </TR>
        </TABLE>
      </xsl:variable>

      SubstitutionGroup [shape=plain, label=<xsl:value-of select="f:to-dot-html($subst)"/>];
      SubstitutionGroup -&gt; <xsl:value-of select="f:enquote(string($qname))"/> [label="substitution group", dir=back];
      { rank=same; SubstitutionGroup; <xsl:value-of select="f:enquote(string($qname))"/>; }
    </xsl:if>

    <xsl:variable name="substitutable-elements" as="xs:QName*"
                  select="f:backlinks-get-substitutable-elements($qname)"/>
    <xsl:if test="exists($substitutable-elements)">
      <xsl:variable name="substitutable-elements">
        <TABLE BORDER="1" CELLBORDER="0" CELLPADDING="0" CELLSPACING="0" xmlns="">
          <TR>
            <TD ALIGN="LEFT" PORT="top">
              <B>Substitutable elements</B>
            </TD>
          </TR>
          <HR/>
          <xsl:for-each select="$substitutable-elements">
            <TR><xsl:sequence select="f:qname-get-td(.)"/></TR>
          </xsl:for-each>
        </TABLE>
      </xsl:variable>

      SubstitutableElements [shape=plain, label=<xsl:value-of select="f:to-dot-html($substitutable-elements)"/>];
      <xsl:value-of select="f:enquote(string($qname))"/> -&gt; SubstitutableElements [label="substitutable for", dir=back];
      { rank=same; SubstitutableElements; <xsl:value-of select="f:enquote(string($qname))"/>; }
    </xsl:if>

    <xsl:apply-templates select="@type" mode="#current"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="xs:element/@type" mode="component-diagram">
    <xsl:variable name="element-qname" as="xs:QName"
                  select="f:xs-component-get-qname(..)"/>
    <xsl:variable name="type-qname" as="xs:QName"
                  select="f:attribute-get-qname(.)"/>
    <xsl:variable name="type-object">
      <TABLE BORDER="1" CELLBORDER="0" CELLPADDING="0" CELLSPACING="0" xmlns="">
        <TR><xsl:sequence select="f:qname-get-td($type-qname)"/></TR>
      </TABLE>
    </xsl:variable>

    <xsl:value-of select="f:enquote(string($type-qname))"/>
    <xsl:text> [shape=plain, label=</xsl:text>
    <xsl:value-of select="f:to-dot-html($type-object)"/>
    <xsl:text>];&#10;</xsl:text>

    <xsl:value-of select="f:enquote(string($element-qname))"/>
    <xsl:text> -&gt; </xsl:text>
    <xsl:value-of select="f:enquote(string($type-qname))"/>
    <xsl:text> [label="type"];&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="@*|node()" priority="-1" mode="component-diagram">
    <xsl:message terminate="yes">Unexpected content (mode=component-diagram)</xsl:message>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- mode: component-diagram-type-table -->
  <!-- ================================================================== -->

  <xsl:template mode="component-diagram-type-table"
                match="text()">
  </xsl:template>

  <xsl:template mode="component-diagram-type-table"
                match="xs:annotation
                       |xs:documentation
                       |xs:complexContent
                       |xs:simpleContent
                       |xs:sequence
                       |xs:extension">
    <xsl:apply-templates select="*" mode="#current"/>
  </xsl:template>

  <xsl:template match="xs:sequence/xs:element[@ref]" mode="component-diagram-type-table">
    <TR xmlns="">
      <xsl:apply-templates select="." mode="component-diagram-td"/>
    </TR>
  </xsl:template>

  <xsl:template match="xs:attribute[@ref]" mode="component-diagram-type-table">
    <xsl:variable name="attribute-qname" as="xs:QName"
                  select="f:attribute-get-qname(@ref)"/>
    <xsl:variable name="attribute" as="element(xs:attribute)?"
                  select="f:qname-resolve-attribute($attribute-qname)"/>
    <TR xmlns="">
      <xsl:sequence select="f:qname-get-td($attribute-qname)"/>
      <TD>
        <xsl:choose>
          <xsl:when test="@use = 'required'">1</xsl:when>
          <xsl:when test="@use = 'prohibited'">0</xsl:when>
          <xsl:when test="@use = 'optional'">0-1</xsl:when>
          <xsl:otherwise>0-1</xsl:otherwise>
        </xsl:choose>
      </TD>
      <xsl:choose>
        <xsl:when test="exists($attribute)">
          <xsl:sequence select="f:qname-get-td(f:attribute-get-qname($attribute/@type))"/>
        </xsl:when>
        <xsl:otherwise>
          <TD><xsl:value-of select="$attribute-qname"/></TD>
        </xsl:otherwise>
      </xsl:choose>
    </TR>
  </xsl:template>

  <xsl:template match="xs:anyAttribute" mode="component-diagram-type-table">
    <TR xmlns="">
      <TD ALIGN="LEFT">anyAttribute</TD>
      <TD></TD>
      <TD></TD>
    </TR>
  </xsl:template>

  <xsl:template match="xs:attributeGroup[@ref]" mode="component-diagram-type-table">
    <TR xmlns="">
      <TD ALIGN="LEFT">attributeGroup <xsl:value-of select="@ref"/></TD>
      <TD></TD>
      <TD></TD>
    </TR>
  </xsl:template>

  <xsl:template match="*" priority="-1" mode="component-diagram-type-table">
    <xsl:message terminate="yes">
      <xsl:text>Unexpected element (mode=component-diagram-type-table, location=</xsl:text>
      <xsl:value-of select="base-uri(.)"/>
      <xsl:text>, name=</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:if test="exists(ancestor::xs:*/@name)">
        <xsl:text>, in @name=</xsl:text>
        <xsl:value-of select="ancestor::xs:*[@name][1]/@name"/>
      </xsl:if>
      <xsl:if test="exists(@name)">
        <xsl:text>, @name=</xsl:text>
        <xsl:value-of select="@name"/>
      </xsl:if>
      <xsl:if test="exists(@ref)">
        <xsl:text>, @ref=</xsl:text>
        <xsl:value-of select="@ref"/>
      </xsl:if>
      <xsl:text>)</xsl:text>
    </xsl:message>
  </xsl:template>
  
  <xsl:template match="text()" priority="-1" mode="component-diagram-type-table">
    <xsl:message terminate="yes">Unexpected text (mode=component-diagram, text=<xsl:value-of select="."/>)</xsl:message>
  </xsl:template>
  
  <xsl:template match="@*|node()" priority="-2" mode="component-diagram-type-table">
    <xsl:message terminate="yes">Unexpected content (mode=component-diagram-type-table)</xsl:message>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- mode: component-diagram-base-type -->
  <!-- ================================================================== -->

  <xsl:template mode="component-diagram-base-type"
                match="@base">
    <!-- could be restriction... -->
    <xsl:variable name="extension" as="element()"
                  select=".."/>
    <xsl:variable name="this" as="element()"
                  select="ancestor::xs:*[@name][1]"/>
    <xsl:variable name="this-qname" as="xs:QName"
                  select="f:xs-component-get-qname($this)"/>

    <xsl:variable name="base-qname" as="xs:QName" select="f:attribute-get-qname(.)"/>

    <xsl:value-of select="f:enquote(string($base-qname))"/>
    <xsl:text> -&gt; </xsl:text>
    <xsl:value-of select="f:enquote(string($this-qname))"/>
    <xsl:text> [label=&quot;</xsl:text>
    <xsl:value-of select="local-name($extension)"/>
    <xsl:text>&quot;];&#10;</xsl:text>

    <xsl:text>{ rank = same; </xsl:text>
    <xsl:value-of select="f:enquote(string($this-qname))"/>
    <xsl:text>; </xsl:text>
    <xsl:value-of select="f:enquote(string($base-qname))"/>
    <xsl:text>; }&#10;</xsl:text>
    
    <xsl:variable name="base" as="element()?" select="f:qname-resolve-type($base-qname)"/>

    <xsl:choose>
      <xsl:when test="exists($base)">
        <xsl:apply-templates select="$base" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="object">
          <TABLE BORDER="1" CELLBORDER="0" CELLPADDING="0" CELLSPACING="0" xmlns="">
            <TR>
              <TD ALIGN="LEFT" HREF="{f:qname-get-href('../..', $base-qname)}#diagram">
                <xsl:value-of select="$base-qname"/>
              </TD>
            </TR>
          </TABLE>
        </xsl:variable>
        <xsl:value-of select="f:enquote(string($base-qname))"/>
        <xsl:text> [shape=plain, label=</xsl:text>
        <xsl:value-of select="f:to-dot-html($object)"/>
        <xsl:text>];</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="component-diagram-base-type"
                match="xs:complexType|xs:simpleType">
    <xsl:variable name="qname" as="xs:QName"
                  select="f:xs-component-get-qname(.)"/>
    <xsl:variable name="object">
      <TABLE BORDER="1" CELLBORDER="0" CELLPADDING="0" CELLSPACING="0" xmlns="">
        <TR><xsl:sequence select="f:qname-get-td($qname)"/></TR>
      </TABLE>
    </xsl:variable>
    <xsl:value-of select="f:enquote(string($qname))"/>
    <xsl:text> [label = </xsl:text>
    <xsl:value-of select="f:to-dot-html($object)"/>
    <xsl:text>];&#10;</xsl:text>
    <xsl:apply-templates select=".//xs:*[@base]/@base" mode="#current"/>
  </xsl:template>

  <xsl:template match="*" mode="component-diagram-base-type" priority="-1">
    <xsl:message terminate="yes">Unexpected content: mode component-diagram-base-type
      name = <xsl:value-of select="name()"/>
    </xsl:message>
  </xsl:template>

  <xsl:template mode="component-diagram-base-type"
                match="@*|node()" priority="-2">
    <xsl:message terminate="yes">Unexpected content: mode component-diagram-base-type</xsl:message>
  </xsl:template>

</xsl:stylesheet>
