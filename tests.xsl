<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:doc="http://jaredkrinke.github.io/doc">
    <xsl:template match="code|result">
        <xsl:if test="name() = 'code'">
            <test>
                <input>
                    <xsl:copy-of select="hidden/text()"/>
                    <xsl:copy-of select="text()"/>
                    <xsl:copy-of select="extra/text()"/>
                </input>
                <output>
                    <xsl:choose>
                        <xsl:when test="count(expected) > 0"><xsl:copy-of select="expected/text()"/></xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="next" select="following-sibling::*[name() = 'code' or name() = 'result'][1]"/>
                            <xsl:if test="name($next) = 'result'">
                                <xsl:copy-of select="$next/text()"/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </output>
            </test>
        </xsl:if>
    </xsl:template>
    <xsl:template match="p//code[count(parent::footnote) = 0] | figure/caption/code | ul//code" />
    <xsl:template match="content">
        <tests>
            <xsl:apply-templates select="//code[not(@valid = 'false')]|//result"/>
        </tests>
    </xsl:template>
</xsl:stylesheet>

