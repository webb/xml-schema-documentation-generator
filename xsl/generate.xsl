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

  <xsl:include href="common.xsl"/>
  <xsl:include href="backlinks.xsl"/>
  <xsl:include href="mode-htmlify.xsl"/>
  <xsl:include href="mode-to-dot-html.xsl"/>
  <xsl:include href="mode-component-diagram-td.xsl"/>
  <xsl:include href="mode-component-xml-schema.xsl"/>

  <xsl:param name="root-path" as="xs:string" required="yes"/>

  <xsl:output method="text" encoding="us-ascii"/>

  <!-- ================================================================== -->
  <!-- templates, in order of appearance -->
  <!-- ================================================================== -->

  <!-- ================================================================== -->
  <!-- default mode -->
  <!-- ================================================================== -->

  <xsl:template match="catalog:catalog">
    <xsl:apply-templates select="." mode="root-index"/>
    <xsl:apply-templates select="catalog:uri[ends-with(@uri, '.xsd')]"/>
  </xsl:template>

  <xsl:template match="catalog:uri">
    <xsl:apply-templates select="doc(resolve-uri(@uri, base-uri(.)))"/>
  </xsl:template>

  <xsl:template match="xs:schema">
    <xsl:apply-templates select="." mode="namespace-index"/>
    <xsl:apply-templates select="xs:complexType|xs:element"/>
  </xsl:template>

  <xsl:template match="/xs:schema/xs:complexType[@name]
                       |/xs:schema/xs:element[@name]">
    <xsl:apply-templates select="." mode="component-page"/>
  </xsl:template>

  <xsl:template match="*" priority="-1">
    <xsl:message terminate="yes">unexpected element: mode=default
      name=<xsl:value-of select="name()"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="@*|node()" priority="-2">
    <xsl:message terminate="yes">unexpected content: mode=default
      name=
    </xsl:message>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- mode: root-index -->
  <!-- ================================================================== -->

  <xsl:template match="catalog:catalog" mode="root-index">
    <xsl:result-document
       href="{$root-path}/index.html"
       method="xml" version="1.0" encoding="UTF-8" indent="yes">
      <html>
        <head>
          <title>Index</title>
        </head>
        <body>
          <ul>
            <xsl:variable name="context" as="element(catalog:catalog)"
                          select="."/>
            <xsl:for-each select="$prefixes">
              <xsl:variable name="namespace" select="@uri" as="xs:string"/>
              <xsl:variable name="catalog-uri" as="element(catalog:uri)?"
                            select="$context/catalog:uri[@name = $namespace]"/>
              <xsl:if test="exists($catalog-uri)">
                <xsl:apply-templates mode="#current"
                                     select="doc(resolve-uri($catalog-uri/@uri, base-uri($catalog-uri)))"/>
              </xsl:if>
            </xsl:for-each>
          </ul>
        </body>
      </html>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="xs:schema" mode="root-index">
    <xsl:variable name="prefix" select="f:xs-get-prefix(.)"/>
    <li>
      <p>
      <a href="{$prefix}/index.html">
        <xsl:value-of select="$prefix"/>
      </a>
      <xsl:text>: </xsl:text>
      <xsl:value-of select="@targetNamespace"/>
      </p>
      <div style="margin-left: 1em;">
        <p>
          <xsl:value-of select="f:xs-component-get-definition(.)"/>
        </p>
      </div>
    </li>
  </xsl:template>

  <xsl:template match="*" priority="-2" mode="root-index">
    <xsl:message terminate="yes">Unexpected element (mode = root-index, name= <xsl:value-of select="name()"/>).</xsl:message>
  </xsl:template>

  <xsl:template match="@*|node()" priority="-3" mode="root-index">
    <xsl:message terminate="yes">Unexpected content (mode = root-index).</xsl:message>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- mode: namespace-index -->
  <!-- ================================================================== -->

  <xsl:template match="xs:schema" mode="namespace-index">
    <xsl:result-document
      href="{f:xs-get-prefix(.)}/index.html"
      method="xml" version="1.0" encoding="UTF-8" indent="yes">
      <html>
        <head>
          <title>Index for namespace <code><xsl:value-of select="f:get-target-namespace(.)"/></code></title>
        </head>
        <body>
          <p><a href="../index.html">All namespaces</a></p>
          <ul>
            <xsl:apply-templates select="xs:*[@name]" mode="#current">
              <xsl:sort select="@name"/>
            </xsl:apply-templates>
          </ul>
        </body>
      </html>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="/xs:schema/xs:*[@name]" mode="namespace-index">
    <li><a href="{@name}/index.html"><xsl:value-of select="@name"/> (<xsl:value-of select="local-name()"/>)</a></li>
  </xsl:template>

  <xsl:template match="*" mode="namespace-index" priority="-1">
    <xsl:message terminate="yes">Unexpected element <xsl:value-of select="name()"/></xsl:message>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- mode: component-page -->
  <!-- ================================================================== -->

  <xsl:template match="/xs:schema/xs:*[@name]" mode="component-page">
    <xsl:variable name="qname" select="f:xs-component-get-qname(.)"/>
    <xsl:result-document href="{f:qname-get-href($root-path, $qname)}"
                         method="xml" version="1.0" encoding="UTF-8" indent="no">
      <html>
        <head>
          <title><xsl:value-of select="$qname"/></title>
        </head>
        <body>
          <p class="title">
            <a href="../index.html">
              <xsl:value-of select="prefix-from-QName($qname)"/>
            </a>
            <xsl:text>:</xsl:text>
            <xsl:value-of select="local-name-from-QName($qname)"/>
          </p>
          <h1>Definition</h1>
          <p><xsl:value-of select="f:xs-component-get-definition(.)"/></p>
          <h1>Diagram</h1>
          <a name="diagram">
            <div style="text-align: center;">
              <img src="data:image/png;base64,{unparsed-text(concat($root-path, '/', prefix-from-QName($qname), '/', local-name-from-QName($qname), '/diagram.png.base64'))}" usemap="#diagram"/>
            </div>
          </a>
          <xsl:apply-templates
            mode="htmlify"
            select="doc(concat($root-path, '/', prefix-from-QName($qname),
                    '/', local-name-from-QName($qname), '/diagram.map'))"/>
          <h1>XML Schema</h1>
          <a name="xml-schema">
            <xsl:apply-templates select="."
                                 mode="component-xml-schema"/>
          </a>
        </body>
      </html>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="*" mode="component-page" priority="-1">
    <xsl:message terminate="yes">Unexpected element <xsl:value-of select="name()"/></xsl:message>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- mode: component-diagram -->
  <!-- ================================================================== -->

  <xsl:template match="catalog:catalog" mode="component-diagram">
    <xsl:apply-templates mode="#current"
                         select="catalog:uri[ends-with(@uri, '.xsd')]"/>
  </xsl:template>

  <xsl:template match="catalog:uri" mode="component-diagram">
    <xsl:apply-templates mode="#current"
                         select="doc(resolve-uri(@uri, base-uri(.)))"/>
  </xsl:template>

  <xsl:template match="xs:schema" mode="component-diagram">
    <xsl:apply-templates mode="#current"
                         select="xs:complexType|xs:element"/>
  </xsl:template>

  <xsl:template match="/xs:schema/xs:complexType[@name]" mode="component-diagram">
    <xsl:variable name="qname" as="xs:QName" select="f:xs-component-get-qname(.)"/>
    <xsl:result-document href="{$root-path}/{prefix-from-QName($qname)}/{local-name-from-QName($qname)}/diagram.dot"
                         method="text" encoding="US-ASCII">
      <xsl:variable name="object" as="item()*" xmlns="">
        <TABLE BORDER="5" CELLBORDER="0" CELLPADDING="0" CELLSPACING="0" COLOR="RED">
          <TR>
            <TD ALIGN="LEFT" PORT="top">
              <B><xsl:value-of select="$qname"/></B>
            </TD>
            <TD>#</TD>
            <TD ALIGN="LEFT">Type</TD>
          </TR>
          <HR/>
          <xsl:apply-templates mode="component-diagram-type-table"/>
        </TABLE>
      </xsl:variable>

      <xsl:text>digraph diagram {&#10;</xsl:text>
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

          <xsl:text>subst_</xsl:text>
          <xsl:value-of select="generate-id($element)"/>
          <xsl:text> [shape=plain, label=</xsl:text>
          <xsl:value-of select="f:to-dot-html($substitutable-elements)"/>
          <xsl:text>];</xsl:text>

          <xsl:value-of select="f:enquote(string($qname))"/>
          <xsl:text>:type_of_</xsl:text>
          <xsl:value-of select="generate-id($element)"/>
          <xsl:text>:e -&gt; subst_</xsl:text>
          <xsl:value-of select="generate-id($element)"/>
          <xsl:text>:top:w [label="substitutable for", dir=back];</xsl:text>

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
        <xsl:text> [label="type"];&#10;</xsl:text>
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
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="/xs:schema/xs:element[@name]" mode="component-diagram">
    <xsl:variable name="qname" as="xs:QName" select="f:xs-component-get-qname(.)"/>
    <xsl:result-document href="{$root-path}/{prefix-from-QName($qname)}/{local-name-from-QName($qname)}/diagram.dot"
                         method="text" encoding="US-ASCII">
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
      digraph diagram {
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
    </xsl:result-document>
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
    <xsl:variable name="element-qname" as="xs:QName"
                  select="f:attribute-get-qname(@ref)"/>
    <xsl:variable name="element" as="element(xs:element)"
                  select="f:qname-resolve-element($element-qname)"/>
    <xsl:variable name="element-type-port" as="xs:string"
                  select="concat('type_of_', generate-id($element))"/>
    <TR xmlns="">
      <xsl:sequence select="f:qname-get-td($element-qname)"/>
      <TD>
        <xsl:variable name="min" select="if (@minOccurs) then @minOccurs else '1'"/>
        <xsl:variable name="max" select="if (@maxOccurs) 
                                         then (if (@maxOccurs = 'unbounded')
                                              then 'n'
                                              else @maxOccurs)
                                         else '1'"/>
        <xsl:value-of select="if ($min = $max)
                              then $min
                              else concat($min, '-', $max)"/>
      </TD>
      <xsl:choose>
        <xsl:when test="$element/@type">
          <xsl:sequence select="f:qname-get-td-with-port(
                                  f:attribute-get-qname($element/@type), 
                                  $element-type-port)"/>
        </xsl:when>
        <xsl:otherwise>
          <TD PORT="{$element-type-port}"/>
        </xsl:otherwise>
      </xsl:choose>
    </TR>
  </xsl:template>

  <xsl:template match="xs:attribute[@ref]" mode="component-diagram-type-table">
    <xsl:variable name="attribute-qname" as="xs:QName"
                  select="f:attribute-get-qname(@ref)"/>
    <xsl:variable name="attribute" as="element(xs:attribute)"
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
      <xsl:sequence select="f:qname-get-td(f:attribute-get-qname($attribute/@type))"/>
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
              <TD ALIGN="LEFT" HREF="{f:qname-get-href('../..', $base-qname)}">
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
