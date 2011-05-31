note
	description : "eMIME application root class"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS

create
	make

feature {NONE} -- Initialization

	make
		local
			mime_parse : MIME_PARSE
			parse_result : PARSE_RESULTS
		do
			create mime_parse
			parse_result := mime_parse.parse_mime_type ("application/xhtml;q=0.5")
			print ("%N"+parse_result.out)

			parse_result := mime_parse.parse_media_range ("application/xml;q=1")
			print ("%N"+parse_result.out)
			check
				"('application', 'xml', {'q':'1',})" ~ mime_parse.parse_media_range ("application/xml;q=1").out
			end

			parse_result := mime_parse.parse_media_range ("application/xml")
			print ("%N"+parse_result.out)
			check
				"('application', 'xml', {'q':'1',})" ~ mime_parse.parse_media_range ("application/xml;q=1").out
			end
--        assertEquals("('application', 'xml', {'q':'1',})", MIMEParse
--                .parseMediaRange("application/xml").toString());
--        assertEquals("('application', 'xml', {'q':'1',})", MIMEParse
--                .parseMediaRange("application/xml;q=").toString());
--        assertEquals("('application', 'xml', {'q':'1',})", MIMEParse
--                .parseMediaRange("application/xml ; q=").toString());
--        assertEquals("('application', 'xml', {'b':'other','q':'1',})",
--                MIMEParse.parseMediaRange("application/xml ; q=1;b=other")
--                        .toString());
--        assertEquals("('application', 'xml', {'b':'other','q':'1',})",
--                MIMEParse.parseMediaRange("application/xml ; q=2;b=other")
--                        .toString());
--        // Java URLConnection class sends an Accept header that includes a
--        // single *
--        assertEquals("('*', '*', {'q':'.2',})", MIMEParse.parseMediaRange(
--                " *; q=.2").toString());
		end

end
