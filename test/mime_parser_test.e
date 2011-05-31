note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	MIME_PARSER_TEST

inherit
	EQA_TEST_SET
		redefine
			on_prepare
		end

feature
	on_prepare
			-- Called after all initializations in `default_create'.
		do
			create parser
		end

feature -- Test routines

	test_parse_media_range
		do
			assert ("Expected ('application', 'xml', {'q':'1',})", "('application', 'xml', {'q':'1',})" ~ parser.parse_media_range("application/xml;q=1").out )
			assert ("Expected ('application', 'xml', {'q':'1',})", "('application', 'xml', {'q':'1',})" ~ parser.parse_media_range("application/xml").out )
			assert ("Expected ('application', 'xml', {'q':'1',})", "('application', 'xml', {'q':'1',})" ~ parser.parse_media_range("application/xml;q=").out )
			assert ("Expected ('application', 'xml', {'q':'1',})", "('application', 'xml', {'q':'1',})" ~ parser.parse_media_range("application/xml ; q=").out )
			assert ("Expected ('application', 'xml', {'q':'1','b':'other',})", "('application', 'xml', {'q':'1','b':'other',})" ~ parser.parse_media_range("application/xml ; q=1;b=other").out )
			assert ("Expected ('application', 'xml', {'q':'1','b':'other',})", "('application', 'xml', {'q':'1','b':'other',})" ~ parser.parse_media_range("application/xml ; q=2;b=other").out )
			-- Accept header that includes *
			assert ("Expected ('*', '*', {'q':'.2',})","('*', '*', {'q':'.2',})" ~ parser.parse_media_range(" *; q=.2").out)
		end


	test_RFC2616_example
		local
			accept : STRING
		do
			accept := "text/*;q=0.3, text/html;q=0.7, text/html;level=1, text/html;level=2;q=0.4, */*;q=0.5";
			assert ("Expected 1.0", 1.0 ~ parser.quality ("text/html;level=1", accept))
			assert ("Expected 0.7", 0.7 ~ parser.quality ("text/html", accept))
			assert ("Expected 0.3", 0.3 ~ parser.quality ("text/plain", accept))
			assert ("Expected 0.5", 0.5 ~ parser.quality ("image/jpeg", accept))
			assert ("Expected 0.4", 0.4 ~ parser.quality ("text/html;level=2", accept))
			assert ("Expected 0.7", 0.7 ~ parser.quality ("text/html;level=3", accept))
		end


	test_best_match
		local
			mime_types_supported : LIST[STRING]
			l_types : STRING
		do
			l_types := "application/xbel+xml,application/xml"
			mime_types_supported := l_types.split(',')
			assert ("Expected application/xbel+xml",parser.best_match (mime_types_supported, "application/xbel+xml") ~ "application/xbel+xml")
			assert ("Direct match with a q parameter",parser.best_match (mime_types_supported, "application/xbel+xml;q=1") ~ "application/xbel+xml")
			assert ("Direct match second choice with a q parameter",parser.best_match (mime_types_supported, "application/xml;q=1") ~ "application/xml")
--			assert ("Direct match using a subtype wildcard",parser.best_match (mime_types_supported, "application/*;q=1") ~ "application/xml")
--			assert ("Match using a type wildcard",parser.best_match (mime_types_supported, "*/*") ~ "application/xml")

			l_types := "application/xbel+xml,text/xml"
			mime_types_supported := l_types.split(',')
			assert ("Match using a type versus a lower weighted subtype",parser.best_match (mime_types_supported, "text/*;q=0.5,*/*;q=0.1") ~ "text/xml")
			assert ("Fail to match anything",parser.best_match (mime_types_supported, "text/html,application/atom+xml; q=0.9") ~ "")

			l_types := "application/json,text/html"
			mime_types_supported := l_types.split(',')
			assert ("Common Ajax scenario",parser.best_match (mime_types_supported, "application/json,text/javascript, */*") ~ "application/json")
			assert ("Common Ajax scenario,verify fitness ordering",parser.best_match (mime_types_supported, "application/json,text/javascript, */*") ~ "application/json")

		end


	test_support_wildcard
		local
			mime_types_supported : LIST[STRING]
			l_types : STRING
		do
			l_types := "image/*,application/xml"
			mime_types_supported := l_types.split(',')
			assert ("match using a type wildcard",parser.best_match (mime_types_supported, "image/png") ~ "image/*")
			assert (" match using a wildcard for both requested and supported",parser.best_match (mime_types_supported, "image/*") ~ "image/*")
		end




	parser : MIME_PARSE

end


