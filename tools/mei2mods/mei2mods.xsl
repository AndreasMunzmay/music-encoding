<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns="http://www.loc.gov/mods/v3" xmlns:mei="http://www.music-encoding.org/ns/mei"
  exclude-result-prefixes="mei">
  <xsl:output method="xml" encoding="UTF-8" indent="yes" media-type="text/xml"/>
  <xsl:strip-space elements="*"/>


  <!-- PARAM:mode
      This parameter determines which entity the generated MARC record is for:
        'file': the MEI file,
        'source': the source(s) of the MEI file,
        'work': the work the MEI file represents.
  -->
  <xsl:param name="mode">file</xsl:param>
  <xsl:param name="model_path">http://www.loc.gov/standards/mods/v3/mods-3-4.xsd</xsl:param>
  <!-- agency name -->
  <xsl:param name="agency">University of Virginia</xsl:param>
  <xsl:param name="agency_code">ViU</xsl:param>
  <!-- analog attributes -->
  <xsl:param name="analog">true</xsl:param>

  <!-- stylesheet name -->
  <xsl:variable name="progName">mei2mods.xsl</xsl:variable>
  <!-- stylesheet version -->
  <xsl:variable name="version">
    <xsl:text>1.0 ALPHA</xsl:text>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:apply-templates select="//mei:meiHead"/>
  </xsl:template>

  <xsl:template match="mei:meiHead">
    <xsl:if test="$model_path != ''">
      <xsl:processing-instruction name="xml-model">
        <xsl:value-of select="concat('&#32;href=&quot;', $model_path, '&quot;')"/>
      </xsl:processing-instruction>
    </xsl:if>
    <xsl:comment>
      <xsl:text>MARC record generated by mei2mods.xsl version </xsl:text>
      <xsl:value-of select="$version"/>
    </xsl:comment>
    <mods version="3.4">
      <xsl:choose>
        <xsl:when test="$mode = 'file'">
          <xsl:apply-templates select="mei:fileDesc"/>
        </xsl:when>
      </xsl:choose>
    </mods>
  </xsl:template>

  <xsl:template match="mei:fileDesc">
    <!-- Title and statement of responsibility -->
    <xsl:apply-templates select="mei:titleStmt"/>
    <!-- Publication info -->
    <xsl:apply-templates select="mei:pubStmt"/>
    <!-- Physical Description -->
    <xsl:call-template name="physicalDescription"/>
    <!-- Record info -->
    <xsl:call-template name="recordInfo"/>
    <!-- Notes -->
    <xsl:apply-templates select="mei:notesStmt/mei:annot[contains(@analog, 'marc:500')]"/>
    <!-- Subject -->
    <!-- Call number -->
  </xsl:template>

  <xsl:template match="mei:annot">
    <note>
      <xsl:value-of select="."/>
    </note>
  </xsl:template>

  <xsl:template name="physicalDescription">
    <physicalDescription>
      <form authority="marcform">electronic</form>
      <form authority="gmd">electronic resource</form>
      <form>Computer data and programs.</form>
    </physicalDescription>
  </xsl:template>

  <xsl:template name="recordInfo">
    <recordInfo>
      <recordContentSource authority="marcorg">
        <xsl:value-of select="$agency_code"/>
      </recordContentSource>
      <xsl:if test="ancestor::mei:meiHead/mei:altId">
        <recordIdentifier>
          <xsl:value-of select="ancestor::mei:meiHead/mei:altId"/>
        </recordIdentifier>
      </xsl:if>
      <recordOrigin><xsl:text>Converted from MEI to MODS version 3.4 using </xsl:text><xsl:value-of
          select="$progName"/>
        <xsl:text> (version </xsl:text><xsl:value-of select="$version"
          /><xsl:text> on </xsl:text><xsl:value-of select="format-date(current-date(),
          '[Y]-[M02]-[D02]')"/>)</recordOrigin>
    </recordInfo>
  </xsl:template>

  <xsl:template match="mei:titleStmt">
    <!-- Title Proper -->
    <titleInfo>
      <xsl:apply-templates select="mei:title"/>
    </titleInfo>

    <!-- Alternative Title(s) ? -->

    <!-- Names -->
    <xsl:apply-templates select="mei:respStmt/mei:*[local-name()='name' or local-name()='persName'
      or local-name()='corpName']"/>

  </xsl:template>

  <xsl:template match="mei:pubStmt">
    <originInfo>
      <xsl:if test="mei:respStmt/mei:*[local-name()='name' or local-name()='persName' or
        local-name()='corpName'][not(string-length()=0)]">
        <publisher>
          <xsl:value-of select="mei:respStmt/mei:*[local-name()='name' or
            local-name()='persName' or local-name()='corpName']"/>
        </publisher>
      </xsl:if>
      <xsl:if test="mei:address">
        <place>
          <xsl:apply-templates select="mei:address"/>
        </place>
      </xsl:if>
      <dateIssued>
        <xsl:value-of select="mei:date"/>
      </dateIssued>
      <issuance>monographic</issuance>
    </originInfo>
  </xsl:template>

  <xsl:template match="mei:address">
    <xsl:variable name="address">
      <xsl:for-each select="mei:addrLine">
        <xsl:value-of select="."/>
        <xsl:if test="position() != last()">
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <placeTerm type="text">
      <xsl:value-of select="normalize-space($address)"/>
    </placeTerm>
  </xsl:template>

  <xsl:template match="mei:title">
    <xsl:choose>
      <xsl:when test="@type='subtitle'">
        <subTitle>
          <xsl:value-of select="."/>
        </subTitle>
      </xsl:when>
      <xsl:otherwise>
        <title>
          <xsl:value-of select="."/>
        </title>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:persName">
    <name type="personal">
      <namePart>
        <xsl:value-of select="text()"/>
      </namePart>
      <xsl:if test="mei:date">
        <namePart type="date">
          <xsl:value-of select="mei:date"/>
        </namePart>
      </xsl:if>
    </name>
  </xsl:template>

  <xsl:template match="mei:corpName">
    <name type="corporate">
      <namePart>
        <xsl:value-of select="text()"/>
      </namePart>
      <xsl:if test="mei:date">
        <namePart type="date">
          <xsl:value-of select="mei:date"/>
        </namePart>
      </xsl:if>
    </name>
  </xsl:template>

  <!--<mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.loc.gov/mods/v3
    http://www.loc.gov/standards/mods/v3/mods-3-4.xsd" version="3.4">
    <titleInfo>
      <nonSort>The </nonSort>
      <title>American ballroom companion</title>
      <subTitle>dance instruction manuals, ca. 1600-1920</subTitle>
    </titleInfo>
    <titleInfo type="alternative">
      <title>Dance instruction manuals, ca. 1600-1920</title>
    </titleInfo>
    <name type="corporate">
      <namePart>Library of Congress</namePart>
      <namePart>Music Division.</namePart>
    </name>
    <name type="corporate">
      <namePart>Library of Congress</namePart>
      <namePart>National Digital Library Program.</namePart>
    </name>
    <typeOfResource>software, multimedia</typeOfResource>
    <originInfo>
      <place>
        <placeTerm type="code" authority="marccountry">dcu</placeTerm>
      </place>
      <place>
        <placeTerm type="text">Washington, D.C</placeTerm>
      </place>
      <publisher>Library of Congress</publisher>
      <dateIssued>1998-]</dateIssued>
      <dateIssued point="start" encoding="marc">1998</dateIssued>
      <dateIssued point="end" encoding="marc">9999</dateIssued>
      <issuance>monographic</issuance>
    </originInfo>
    <language>
      <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
    </language>
    <physicalDescription>
      <form authority="marcform">electronic</form>
      <form authority="gmd">electronic resource</form>
      <form>Computer data and programs.</form>
    </physicalDescription>
    <abstract>Presents over two hundred social dance manuals, pocket-sized books with diagrams used
      by itinerant dancing masters to teach the American gentry the latest dance steps. Includes
      anti-dance manuals as well as treatises on etiquette. Offered as part of the American Memory
      online resource compiled by the National Digital Library Program of the Library of
      Congress.</abstract>
    <note type="statement of responsibility" altRepGroup="00">Music Division, Library of
      Congress.</note>
    <note>Title from title screen dated Mar. 23, 1998.</note>
    <note type="system details">System requirements: World Wide Web (WWW) browser software.</note>
    <note type="system details">Mode of access: Internet.</note>
    <subject>
      <geographicCode authority="marcgac">n-us-\-\-</geographicCode>
    </subject>
    <subject authority="lcsh">
      <topic>Ballroom dancing</topic>
      <geographic>United States</geographic>
    </subject>
    <classification authority="lcc">GV1623</classification>
    <classification authority="ddc" edition="13">793.3</classification>
    <location>
      <url displayLabel="electronic resource" usage="primary display"
        >http://hdl.loc.gov/loc.music/collmus.mu000010</url>
    </location>
    <identifier type="lccn">98801326</identifier>
    <identifier type="hdl">hdl:loc.music/collmus.mu000010</identifier>
    <identifier type="hdl">hdl:loc.music/collmus.mu000010</identifier>
    <recordInfo>
      <descriptionStandard>aacr</descriptionStandard>
      <recordContentSource authority="marcorg">DLC</recordContentSource>
      <recordCreationDate encoding="marc">980323</recordCreationDate>
      <recordChangeDate encoding="iso8601">20060131154904.0</recordChangeDate>
      <recordIdentifier>5004836</recordIdentifier>
      <recordOrigin>Converted from MARCXML to MODS version 3.4 using MARC21slim2MODS3-4.xsl
        (Revision 1.85 2013/03/07)</recordOrigin>
    </recordInfo>
  </mods>-->

</xsl:stylesheet>
