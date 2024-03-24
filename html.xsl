<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:doc="https://jaredkrinke.github.io/doc">
    <xsl:variable name="cover-file" select="'index.html'"/>
    <xsl:variable name="toc-file" select="'toc.html'"/>
    <xsl:template name="page-custom">
        <xsl:param name="title"/>
        <xsl:param name="file"/>
        <xsl:param name="body"/>
        <xsl:variable name="previous" select="$pages/page[following-sibling::page[1]/@file = $file]"/>
        <xsl:variable name="next" select="$pages/page[preceding-sibling::page[1]/@file = $file]"/>

            <xsl:result-document method="html" doctype-public="html" href="{$file}" indent="no">
<meta name="viewport" content="width=device-width, initial-scale=1" />
<html lang="en">
<head>
<title><xsl:value-of select="concat($brand, ' - ', $title)"/></title>
<script src="https://code.jquery.com/jquery-2.1.1.min.js"></script>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap-theme.min.css" />
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/js/bootstrap.min.js"></script>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css" />

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/4.8.0/codemirror.min.css" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/4.8.0/codemirror.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/4.8.0/mode/scheme/scheme.min.js"></script>

<script src="jsLisp.js"></script>
<script src="editor.js"></script>
<link rel="stylesheet" href="editor.css" />
</head>
<body>


<div class="container">

<nav class="navbar navbar-default">
  <div class="navbar-header">
    <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#top-bar">
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
    </button>
    <a class="navbar-brand" href="{$cover-file}"><xsl:value-of select="$brand"/></a>
  </div>

  <div class="collapse navbar-collapse" id="top-bar">
    <ul class="nav navbar-nav">
      <xsl:if test="count($previous) > 0">
        <li><a href="{$previous/@file}"><xsl:text disable-output-escaping="yes"><![CDATA[&laquo;]]></xsl:text> Previous</a></li>
      </xsl:if>
      <li class="{if ($toc-file = $file) then ('active') else ('')}"><a href="{$toc-file}">Contents</a></li>
      <xsl:if test="count($next) > 0">
        <li><a href="{$next/@file}">Next <xsl:text disable-output-escaping="yes"><![CDATA[&raquo;]]></xsl:text></a></li>
      </xsl:if>
    </ul>
    <form class="navbar-form navbar-right">
      <button id="launchEditor" type="button" class="btn btn-default">Launch Editor</button>
    </form>
  </div>
</nav>

<xsl:copy-of select="$body"/>

<nav>
  <ul class="pager">
    <xsl:if test="count($previous) > 0">
      <li><a href="{$previous/@file}"><span><xsl:text disable-output-escaping="yes"><![CDATA[&laquo;]]></xsl:text> Previous</span></a></li>
    </xsl:if>
    <li><a href="{$toc-file}">Contents</a></li>
    <xsl:if test="count($next) > 0">
      <li><a href="{$next/@file}"><span>Next <xsl:text disable-output-escaping="yes"><![CDATA[&raquo;]]></xsl:text></span></a></li>
    </xsl:if>
  </ul>
</nav>

<button id="tryItButton" class="hidden btn btn-info btn-xs pull-right">Try it</button>
</div>

<div id="editorModal" class="modal fade" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true"><xsl:text disable-output-escaping="yes"><![CDATA[&times;]]></xsl:text></span></button>
                <h4 class="modal-title">Scheme Interpreter</h4>
            </div>
            <div class="modal-body">
                <label for="editorInput">Input</label>
                <textarea id="editorInput" class="form-control"></textarea>
            </div>
            <div class="modal-body">
                <label for="editorOutput">Output</label>
                <textarea id="editorOutput" class="form-control"></textarea>
            </div>
            <div class="modal-footer">
                <button id="editorExecute" type="button" class="btn btn-primary">Evaluate</button>
                <button id="editorDismiss" type="button" class="btn btn-default" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>
</body>
</html>

        </xsl:result-document>
    </xsl:template>

    <xsl:template name="page">
        <xsl:param name="title"/>
        <xsl:param name="file"/>
        <xsl:param name="body"/>
        <xsl:call-template name="page-custom">
            <xsl:with-param name="title" select="$title"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="body">
                <h1><xsl:value-of select="$title"/></h1>
                <xsl:copy-of select="$body"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="footnote" mode="footnotes">
        <small>
            <p>
                <sup><a name="{concat('footnote_', @number)}"></a><xsl:value-of select="@number"/> </sup>
                <xsl:apply-templates select="./node()[1]/node()"/>
            </p>
            <xsl:apply-templates select="./node()[position() != 1]"/>
        </small>
    </xsl:template>

    <xsl:template name="footnotes">
        <xsl:if test="count(./*[name() != 'section']//footnote) > 0">
            <hr />
            <xsl:apply-templates select="./*[name() != 'section']//footnote" mode="footnotes"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="exercise">
        <u>Exercise <xsl:value-of select="@number"/></u>
        <xsl:apply-templates select="./node()"/>
    </xsl:template>

    <xsl:template match="figure">
        <div class=".pull-left"><p>
            <xsl:if test="count(@image) > 0">
                <img src="{@image}" /><br />
            </xsl:if>
            <xsl:if test="count(content) > 0">
                <xsl:apply-templates select="content/node()"/>
            </xsl:if>
            <small><u>Figure <xsl:value-of select="@number"/></u>:
                <xsl:apply-templates select="caption/node()"/>
            </small>
        </p></div>
    </xsl:template>

    <xsl:template match="image">
        <div class=".pull-left"><img src="{@path}" /></div>
    </xsl:template>

    <!-- Annotate body sections with numbers -->
    <xsl:template match="node()|@*" mode="annotate">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="annotate"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="footnote" mode="annotate">
        <xsl:variable name="number" select="count(preceding::footnote) + 1"/>
        <xsl:copy>
            <xsl:attribute name="number"><xsl:value-of select="$number"/></xsl:attribute>
            <xsl:apply-templates select="node()|@*" mode="annotate"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="exercise" mode="annotate">
        <xsl:variable name="section" select="ancestor::section[last()]"/>
        <xsl:variable name="sectionNumber" select="count($section/preceding-sibling::section) + 1"/>
        <!-- Count just the exercises in this section -->
        <xsl:variable name="sectionExercises" select="$section//exercise"/>
        <xsl:variable name="precedingExercises" select="preceding::exercise"/>
        <xsl:variable name="exerciseNumber" select="count($sectionExercises[count($precedingExercises) = count(. | $precedingExercises)]) + 1"/>
        <xsl:copy>
            <xsl:attribute name="number"><xsl:value-of select="concat($sectionNumber, '.', $exerciseNumber)"/></xsl:attribute>
            <xsl:apply-templates select="node()|@*" mode="annotate"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="figure" mode="annotate">
        <xsl:variable name="section" select="ancestor::section[last()]"/>
        <xsl:variable name="sectionNumber" select="count($section/preceding-sibling::section) + 1"/>
        <xsl:variable name="sectionFigures" select="$section//figure"/>
        <xsl:variable name="precedingFigures" select="preceding::figure"/>
        <xsl:variable name="figureNumber" select="count($sectionFigures[count($precedingFigures) = count(. | $precedingFigures)]) + 1"/>
        <xsl:copy>
            <xsl:attribute name="number"><xsl:value-of select="concat($sectionNumber, '.', $figureNumber)"/></xsl:attribute>
            <xsl:apply-templates select="node()|@*" mode="annotate"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/content/body//section" mode="annotate">
        <xsl:param name="doc:prefix" select="''"/>
        <xsl:variable name="position" select="count(preceding-sibling::section) + 1"/>
        <xsl:variable name="prefix" select="if (string-length($doc:prefix) > 0) then (concat($doc:prefix, '.', $position)) else (string($position))"/>
        <xsl:copy>
            <xsl:attribute name="number"><xsl:value-of select="$prefix"/></xsl:attribute>
            <xsl:apply-templates select="node()|@*" mode="annotate">
                <xsl:with-param name="doc:prefix" select="$prefix"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:variable name="lower-case" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="upper-case" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:variable name="file-characters" select="concat($lower-case, $upper-case, '0123456789')"/>

    <xsl:function name="doc:canonize">
        <xsl:param name="text"/>
        <xsl:value-of select="translate(translate($text, translate($text, $file-characters, ''), '-'), $upper-case, $lower-case)"/>
    </xsl:function>

    <xsl:function name="doc:file-name">
        <xsl:param name="text"/>
        <xsl:value-of select="concat(substring(doc:canonize($text), 1, 20), '.html')"/>
    </xsl:function>

    <xsl:function name="doc:numbered-title">
        <xsl:param name="section"/>
        <xsl:value-of select="if (count($section/@number) > 0) then (concat($section/@number, '. ', $section/@title)) else ($section/@title)"/>
    </xsl:function>

    <xsl:function name="doc:section-file">
        <xsl:param name="section"/>
        <xsl:value-of select="doc:file-name(doc:numbered-title($section))"/>
    </xsl:function>

    <xsl:variable name="annotated">
        <xsl:apply-templates select="/" mode="annotate"/>
    </xsl:variable>

    <!-- Set up navigation -->
    <xsl:variable name="pages">
        <page file="{$cover-file}"/>
        <page file="{$toc-file}"/>
        <xsl:for-each select="$annotated//section">
            <page file="{doc:section-file(.)}"/>
        </xsl:for-each>
    </xsl:variable>

    <!-- Cover -->
    <xsl:template name="cover">
        <xsl:call-template name="page-custom">
            <xsl:with-param name="title" select="//cover/@title"/>
            <xsl:with-param name="file" select="$cover-file"/>
            <xsl:with-param name="body">
                <xsl:apply-templates select="//cover/*"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- Table of contents -->
    <xsl:template name="table-of-contents-item">
        <xsl:variable name="title" select="doc:numbered-title(.)"/>
        <xsl:variable name="file" select="doc:section-file(.)"/>
        <li>
            <a href="{$file}"><xsl:value-of select="$title"/></a>
        </li>
        <xsl:if test="count(section) > 0">
            <ul>
                <xsl:for-each select="section">
                    <xsl:call-template name="table-of-contents-item"/>
                </xsl:for-each>
            </ul>
        </xsl:if>
    </xsl:template>

    <xsl:template name="table-of-contents">
        <xsl:call-template name="page">
            <xsl:with-param name="title" select="'Contents'"/>
            <xsl:with-param name="file" select="$toc-file"/>
            <xsl:with-param name="body">
                <ul class="toc">
                    <xsl:for-each select="$annotated/content/(front|body|back)/section">
                        <xsl:call-template name="table-of-contents-item"/>
                    </xsl:for-each>
                </ul>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- Content pages -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <!-- Convert line breaks to "br" elements -->
    <xsl:template match="text()" mode="break-lines" name="break-lines">
        <xsl:param name="text" select="."/>

        <xsl:choose>
          <xsl:when test="not(contains($text, '&#xA;'))">
            <xsl:copy-of select="$text"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="substring-before($text, '&#xA;')"/>
            <br />
            <xsl:call-template name="break-lines">
              <xsl:with-param name="text" select="substring-after($text, '&#xA;')"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="subsection">
        <h2><xsl:value-of select="@title"/></h2>
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="lead">
        <p class="lead"><xsl:apply-templates select="node()"/></p>
    </xsl:template>
    <xsl:template match="quote">
        <blockquote>
            <xsl:apply-templates select="node()"/>
            <footer><xsl:value-of select="@source"/></footer>
        </blockquote>
    </xsl:template>
    <xsl:template match="term">
        <strong><xsl:apply-templates select="node()"/></strong>
    </xsl:template>
    <xsl:template match="code">
        <xsl:if test="count(hidden) > 0"><div class="hidden hidden-code"><xsl:copy-of select="hidden/text()"/></div></xsl:if>
        <xsl:element name="pre"><xsl:if test="@valid = 'false'"><xsl:attribute name="class">code-invalid</xsl:attribute></xsl:if><xsl:copy-of select="text()"/></xsl:element>
    </xsl:template>
    <xsl:template match="p//code[count(parent::footnote) = 0] | figure/caption/code | ul//code">
        <code><xsl:apply-templates select="node()"/></code>
    </xsl:template>
    <xsl:template match="result">
        <blockquote><xsl:apply-templates select="text()" mode="break-lines"/></blockquote>
    </xsl:template>
    <xsl:template match="brand">
        <strong><xsl:value-of select="$brand"/></strong>
    </xsl:template>
    <xsl:template match="footnote">
        <sup><a href="{concat('#footnote_', @number)}"><xsl:value-of select="@number"/></a></sup>
    </xsl:template>

    <xsl:template match="/content//section"/>

    <xsl:template name="content-page">
        <xsl:call-template name="page">
            <xsl:with-param name="title" select="@title"/>
            <xsl:with-param name="file" select="doc:section-file(.)"/>
            <xsl:with-param name="body">
                <xsl:apply-templates select="./node()"/>
                <xsl:call-template name="footnotes"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="content-pages">
        <xsl:for-each select="$annotated/content//section">
            <xsl:call-template name="content-page"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="/">
        <xsl:call-template name="cover"/>
        <xsl:call-template name="table-of-contents"/>
        <xsl:call-template name="content-pages"/>
    </xsl:template>

    <xsl:variable name="brand" select="/content/@title"/>
</xsl:stylesheet>
