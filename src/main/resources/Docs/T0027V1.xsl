<?xml version="1.0"?>                    

<xsl:stylesheet version="1.0" 
    xmlns:abc="http://www.safersys.org/namespaces/T0027V1"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="abc">

  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1"/>
  <xsl:param name="DATETIME"/>

  <xsl:template match="/">
<T0027>
  <INTERFACE>
    <NAME>SAFER</NAME>
    <VERSION>04.03</VERSION>
  </INTERFACE>
  <TRANSACTION>
    <VERSION>01.00</VERSION>
    <OPERATION>REPLACE</OPERATION>
    <DATE_TIME><xsl:value-of select="$DATETIME"/></DATE_TIME>
    <TZ>ED</TZ>
  </TRANSACTION>
    <xsl:for-each select="abc:T0027/abc:ROW">
      <FLEET_ACCOUNT>
        <IRP_ACCOUNT_NUMBER><xsl:value-of select="abc:IRP_ACCOUNT_NUMBER"/></IRP_ACCOUNT_NUMBER>
        <IRP_BASE_COUNTRY><xsl:value-of select="abc:IRP_BASE_COUNTRY"/></IRP_BASE_COUNTRY>
        <IRP_BASE_STATE><xsl:value-of select="abc:IRP_BASE_STATE"/></IRP_BASE_STATE>
	<xsl:if test="abc:SENDING_STATE"><SENDING_STATE><xsl:value-of select="abc:SENDING_STATE"/></SENDING_STATE></xsl:if>
        <FLEET_NUMBER><xsl:value-of select="abc:FLEET_NUMBER"/></FLEET_NUMBER>
        <FLEET_STATUS_CODE><xsl:value-of select="abc:FLEET_STATUS_CODE"/></FLEET_STATUS_CODE>
        <FLEET_STATUS_DATE><xsl:value-of select="abc:FLEET_STATUS_DATE"/></FLEET_STATUS_DATE>
        <FLEET_EXPIRE_DATE><xsl:value-of select="abc:FLEET_EXPIRE_DATE"/></FLEET_EXPIRE_DATE>
        <FLEET_UPDATE_DATE><xsl:value-of select="abc:FLEET_UPDATE_DATE"/></FLEET_UPDATE_DATE>
        <xsl:for-each select="abc:NAMES/abc:NAMES_ROW">
          <FLEET_NAME>
            <NAME_TYPE><xsl:value-of select="abc:NAME_TYPE"/></NAME_TYPE>
            <NAME><xsl:value-of select="abc:NAME"/></NAME>
	    <xsl:for-each select="abc:ADDRESSES/abc:ADDRESSES_ROW">
	        <FLEET_ADDRESS>
	          <ADDRESS_TYPE><xsl:value-of select="abc:ADDRESS_TYPE"/></ADDRESS_TYPE>
		  <xsl:if test="abc:STREET_LINE_1"><STREET_LINE_1><xsl:value-of select="abc:STREET_LINE_1"/></STREET_LINE_1></xsl:if>
		  <xsl:if test="abc:STREET_LINE_2"><STREET_LINE_2><xsl:value-of select="abc:STREET_LINE_2"/></STREET_LINE_2></xsl:if>
	          <xsl:if test="abc:PO_BOX"><PO_BOX><xsl:value-of select="abc:PO_BOX"/></PO_BOX></xsl:if>
	          <CITY><xsl:value-of select="abc:CITY"/></CITY>
	          <STATE><xsl:value-of select="abc:STATE"/></STATE>
	          <ZIP_CODE><xsl:value-of select="abc:ZIP_CODE"/></ZIP_CODE>
		  <xsl:if test="abc:COUNTY"><COUNTY><xsl:value-of select="abc:COUNTY"/></COUNTY></xsl:if>
		  <xsl:if test="abc:COLONIA"><COLONIA><xsl:value-of select="abc:COLONIA"/></COLONIA></xsl:if>
		  <xsl:if test="abc:COUNTRY"><COUNTRY><xsl:value-of select="abc:COUNTRY"/></COUNTRY></xsl:if>
		</FLEET_ADDRESS>
	    </xsl:for-each>
          </FLEET_NAME>
        </xsl:for-each>
      </FLEET_ACCOUNT>
    </xsl:for-each>
    </T0027>
  </xsl:template>

</xsl:stylesheet>
