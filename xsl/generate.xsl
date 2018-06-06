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
    <xsl:apply-templates select="xs:complexType"/>
  </xsl:template>

  <xsl:template match="/xs:schema/xs:complexType[@name]">
    <xsl:apply-templates select="." mode="component-page"/>
  </xsl:template>

  <xsl:template match="@*|node()" priority="-2">
    <xsl:message terminate="yes">unexpected content (default mode)</xsl:message>
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
    <xsl:variable name="prefix" select="f:get-prefix(.)"/>
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
      href="{f:get-prefix(.)}/index.html"
      method="xml" version="1.0" encoding="UTF-8" indent="yes">
      <html>
        <head>
          <title>Index for namespace <code><xsl:value-of select="f:get-target-namespace(.)"/></code></title>
        </head>
        <body>
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

  <xsl:template match="/xs:schema/xs:complexType[@name]" mode="component-page">
    <xsl:variable name="prefix" select="f:get-prefix(.)"/>
    <xsl:variable name="qname" select="f:xs-component-get-qname(.)"/>
    <xsl:variable name="path" select="f:xs-component-get-relative-path(.)"/>
    <xsl:result-document href="{$root-path}/{$path}/index.html"
      method="xml" version="1.0" encoding="UTF-8" indent="yes">
      <html>
        <head>
          <title><xsl:value-of select="$qname"/></title>
        </head>
        <body>
          <p class="title">
            <a href="../index.html">
              <xsl:value-of select="$prefix"/>
            </a>
            <xsl:text>:</xsl:text>
            <xsl:value-of select="local-name-from-QName($qname)"/>
          </p>
          <h1>Definition</h1>
          <p><xsl:value-of select="f:xs-component-get-definition(.)"/></p>
          <h1>Diagram</h1>
          <img src="diagram.png" usemap="#diagram"/>
          <xsl:apply-templates
            mode="htmlify"
            select="doc(concat($root-path,'/',$path,'/diagram.map'))"/>
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
                         select="xs:complexType"/>
  </xsl:template>

  <xsl:template match="/xs:schema/xs:complexType[@name]" mode="component-diagram">
    <xsl:variable name="prefix" select="f:get-prefix(.)"/>
    <xsl:variable name="qname" as="xs:QName" select="f:xs-component-get-qname(.)"/>
    <xsl:variable name="path" as="xs:string" select="f:xs-component-get-relative-path(.)"/>
    <xsl:result-document href="{$root-path}/{$path}/diagram.dot"
                         method="text" encoding="US-ASCII">
      <xsl:variable name="object" as="item()*" xmlns="">
        <TABLE BORDER="1" CELLBORDER="0" CELLPADDING="0" CELLSPACING="0">
          <TR>
            <TD ALIGN="LEFT">
              <B><xsl:value-of select="$qname"/></B>
            </TD>
            <TD>#</TD>
            <TD ALIGN="LEFT">Type</TD>
          </TR>
          <HR/>
          <xsl:apply-templates mode="component-diagram-type-table"/>
        </TABLE>
      </xsl:variable>
      
      digraph diagram {
        edge [fontname = "Helvetica", fontsize = 12, dir = forward];
        node [fontname = "Helvetica", fontsize = 12, shape = plain];
        rankdir=LR;

      &quot;<xsl:value-of select="$qname"/>&quot; [shape=plain, label = <xsl:value-of select="f:to-dot-html($object)"/>];
      }
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="@*|node()" priority="-1" mode="component-diagram">
    <xsl:message terminate="yes">Unexpected content (mode=component-diagram)</xsl:message>
  </xsl:template>

  <xsl:function name="f:to-dot-html" as="xs:string">
    <xsl:param name="item" as="item()*"/>
    <xsl:variable name="html" as="xs:string">
      <xsl:value-of>
        <xsl:text>&lt;</xsl:text>
        <xsl:apply-templates select="$item" mode="to-dot-html"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:value-of>
    </xsl:variable>
    <xsl:value-of select="$html"/>
  </xsl:function>

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

  <xsl:template match="xs:sequence/xs:element[@ref]" mode="component-diagram-type-table"
                xmlns="">
    <xsl:variable name="element" as="element(xs:element)"
                  select="f:resolve-element(., @ref)"/>
    <xsl:variable name="element-qname" as="xs:QName"
                  select="f:xs-component-get-qname($element)"/>
    <xsl:variable name="element-path" as="xs:string"
                  select="f:xs-component-get-relative-path($element)"/>
    <TR>
      <TD ALIGN="LEFT" HREF="../../{$element-path}/index.html">
        <xsl:value-of select="$element-qname"/>
      </TD>
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
      <TD>
        <xsl:if test="$element/@type">
          <xsl:variable name="type" select="f:resolve-type($element, $element/@type)"/>
          <xsl:attribute name="ALIGN" select="'LEFT'"/>
          <xsl:attribute name="HREF" select="concat('../../', f:xs-component-get-relative-path($type), '/index.html')"/>
          <xsl:value-of select="f:xs-component-get-qname($type)"/>
        </xsl:if>
      </TD>
    </TR>
  </xsl:template>

  <xsl:template match="xs:attribute[@ref]" mode="component-diagram-type-table">
    <TR>
      <TD ALIGN="LEFT">@<xsl:value-of select="@ref"/></TD>
      <TD>
        <xsl:choose>
          <xsl:when test="@use = 'required'">1</xsl:when>
          <xsl:when test="@use = 'prohibited'">0</xsl:when>
          <xsl:when test="@use = 'optional'">0-1</xsl:when>
          <xsl:otherwise>0-1</xsl:otherwise>
        </xsl:choose>
      </TD>
      <TD>unknown</TD>
    </TR>
  </xsl:template>

  <xsl:template match="xs:anyAttribute" mode="component-diagram-type-table">
    <TR>
      <TD ALIGN="LEFT">anyAttribute</TD>
      <TD></TD>
      <TD></TD>
    </TR>
  </xsl:template>

  <xsl:template match="xs:attributeGroup[@ref]" mode="component-diagram-type-table">
    <TR>
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
  

  <!-- ============================================================================= -->
  <!-- mode to-dot-html -->
  <!-- ============================================================================= -->

  <xsl:template match="HR" xmlns="" mode="to-dot-html">
    <xsl:choose>
      <xsl:when test="following-sibling::*">&lt;HR/&gt;</xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*" priority="-1" mode="to-dot-html">
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:apply-templates select="@*" mode="#current"/>
    <xsl:text>&gt;</xsl:text>
    <xsl:apply-templates select="node()" mode="#current"/>
    <xsl:text>&lt;/</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>

  <xsl:template match="@*" priority="-1" mode="to-dot-html">
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>=&quot;</xsl:text>
    <xsl:value-of select="replace(., '&quot;', '&amp;&quot;')"/>
    <xsl:text>&quot;</xsl:text>
  </xsl:template>

  <xsl:template match="text()" priority="-1" mode="to-dot-html">
    <xsl:value-of select="replace(., '&lt;', '&amp;&lt;')"/>
  </xsl:template>

  <xsl:template match="@*|node()" priority="-2" mode="to-dot-html">
    <xsl:message terminate="yes">Unexpected content (mode=to-dot-html)</xsl:message>
  </xsl:template>

  <!-- ============================================================================= -->
  <!-- mode htmlify -->
  <!-- convert un-namespaced content to html content -->
  <!-- ============================================================================= -->

  <xsl:template mode="htmlify"
                match="*"
                xmlns="">
    <xsl:element
      name="{local-name()}"
      namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <xsl:template mode="htmlify"
                match="@*|node()"
                priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>



</xsl:stylesheet>