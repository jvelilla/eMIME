note
	description: "Summary description for {MIME_PARSE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MIME_PARSE

inherit
	REFACTORING_HELPER

feature -- Parser

	parse_mime_type (a_mime_type: STRING): PARSE_RESULTS
			-- Parses a mime-type into its component parts.
			-- For example, the media range 'application/xhtml;q=0.5' would get parsed
			-- into:
			-- ('application', 'xhtml', {'q', '0.5'})
		local
			l_parts: LIST [STRING]
			p: STRING
			sub_parts: LIST [STRING]
			i: INTEGER
			l_full_type: STRING
			l_types: LIST [STRING]
		do
			fixme ("Improve code!!!")
			create Result.make
			l_parts := a_mime_type.split (';')
			from
				i := 1
			until
				i > l_parts.count
			loop
				p := l_parts.at (i)
				sub_parts := p.split ('=')
				if sub_parts.count = 2 then
					Result.put (trim (sub_parts[2]), trim (sub_parts[1]))
				end
				i := i + 1
			end
			--Java URLConnection class sends an Accept header that includes a
			--single "*" - Turn it into a legal wildcard.

			l_full_type := trim (l_parts[1])
			if l_full_type.same_string ("*") then
				l_full_type := "*/*"
			end
			l_types := l_full_type.split ('/')
			Result.set_type (trim (l_types[1]))
			Result.set_sub_type (trim (l_types[2]))
		end

	parse_media_range (a_range: STRING): PARSE_RESULTS
			-- Media-ranges are mime-types with wild-cards and a 'q' quality parameter.
			-- For example, the media range 'application/*;q=0.5' would get parsed into:
			-- ('application', '*', {'q', '0.5'})
			-- In addition this function also guarantees that there is a value for 'q'
			-- in the params dictionary, filling it in with a proper default if
			-- necessary.
		local
			q : detachable STRING
			r : REAL_64
		do
			fixme ("Improve the code!!!")
			Result := parse_mime_type (a_range)
			q := Result.item ("q")
			if q /= Void and then (not q.is_empty) and then q.is_double then
				r := q.to_double
			else
				r := 1
			end

			if q = Void or else q.is_empty or else r < 0 or else r > 1 then
				Result.put ("1", "q")
			end
		end


	fitness_and_quality_parsed (a_mime_type: STRING; parsed_ranges: LIST [PARSE_RESULTS]): FITNESS_AND_QUALITY
			-- Find the best match for a given mimeType against a list of media_ranges
			-- that have already been parsed by parse_media_range. Returns a
			-- tuple of the fitness value and the value of the 'q' quality parameter of
			-- the best match, or (-1, 0) if no match was found. Just as for
			-- quality_parsed(), 'parsed_ranges' must be a list of parsed media ranges.
		local
			best_fitness: INTEGER
			best_fit_q: REAL_64
			target: PARSE_RESULTS
			range: PARSE_RESULTS
			keys: LIST [STRING]
			param_matches: INTEGER
			element: detachable STRING
			l_fitness: INTEGER
			t_item: detachable STRING
			r_item: detachable STRING
			l_target_type, l_target_sub_type: detachable STRING
		do
			best_fitness := -1
			best_fit_q := 0
			target := parse_media_range (a_mime_type)
			l_target_type := target.type
			l_target_sub_type := target.sub_type
			if l_target_type /= Void and l_target_sub_type /= Void then
				from
					parsed_ranges.start
				until
					parsed_ranges.after
				loop
					range := parsed_ranges.item_for_iteration
					if
						(attached range.type as l_range_type and then
							(l_target_type.same_string (l_range_type) or l_range_type.same_string ("*") or l_target_type.same_string ("*"))
						)
							and
						(attached range.sub_type as l_range_sub_type and then
							(l_target_sub_type.same_string (l_range_sub_type) or l_range_sub_type.same_string ("*") or l_target_sub_type.same_string ("*"))
						)
					then
						from
							keys := target.keys
							keys.start
						until
							keys.after
						loop
							param_matches := 0
							element := keys.item_for_iteration
							t_item := target.item (element)
							r_item := range.item (element)
							if
								not element.is_equal ("q") and then range.has_key (element) and then
								t_item /= Void and then r_item /= Void and then t_item.same_string (r_item)
							then
								param_matches := param_matches + 1
							end

							if l_range_type.same_string (l_target_type) then
								l_fitness := 100
							else
								l_fitness := 0
							end

							if l_range_sub_type.same_string (l_target_sub_type) then
								l_fitness := l_fitness + 10
							end
							l_fitness := l_fitness + param_matches

							if l_fitness > best_fitness then
								best_fitness := l_fitness
								element := range.item ("q")
								if attached element as elem then
									best_fit_q := elem.to_double
								else
									best_fit_q := 0
								end
							end
							keys.forth
						end
					end
					parsed_ranges.forth
				end
			end
			create Result.make (best_fitness, best_fit_q)
		end


	quality_parsed (a_mime_type: STRING; parsed_ranges: LIST [PARSE_RESULTS]): REAL_64
			--	Find the best match for a given mime-type against a list of ranges that
			--	have already been parsed by parseMediaRange(). Returns the 'q' quality
			--	parameter of the best match, 0 if no match was found. This function
			--	bahaves the same as quality() except that 'parsed_ranges' must be a list
			--	of parsed media ranges.
		do
			Result := fitness_and_quality_parsed (a_mime_type, parsed_ranges).quality
		end


	quality (a_mime_type: STRING; ranges: STRING): REAL_64
			-- Returns the quality 'q' of a mime-type when compared against the
			-- mediaRanges in ranges.
		local
			l_ranges : LIST [STRING]
			res : ARRAYED_LIST [PARSE_RESULTS]
			p_res : PARSE_RESULTS
		do
			l_ranges := ranges.split (',')
			from
				create res.make (10);
				l_ranges.start
			until
				l_ranges.after
			loop
				p_res := parse_media_range (l_ranges.item_for_iteration)
				res.put_left (p_res)
				l_ranges.forth
			end
			Result := quality_parsed (a_mime_type, res)
		end


	best_match (supported: LIST [STRING]; header: STRING): STRING
			-- Choose the mime-type with the highest fitness score and quality ('q') from a list of candidates.
		local
			l_parsed_result: LIST [PARSE_RESULTS]
			weighted_matches: SORTED_TWO_WAY_LIST [FITNESS_AND_QUALITY]
			l_res: LIST [STRING]
			p_res: PARSE_RESULTS
			fitness_and_quality, first_one: FITNESS_AND_QUALITY

		do
			create {LINKED_LIST [PARSE_RESULTS]} l_parsed_result.make
			create {SORTED_TWO_WAY_LIST [FITNESS_AND_QUALITY]} weighted_matches.make

			l_res := header.split (',')

			fixme("Extract method!!!")
			from
				l_res.start
			until
				l_res.after
			loop
				p_res := parse_media_range(l_res.item_for_iteration)
				l_parsed_result.force (p_res)
				l_res.forth
			end

			from
				supported.start
			until
				supported.after
			loop
				fitness_and_quality := fitness_and_quality_parsed(supported.item_for_iteration,l_parsed_result);
				fitness_and_quality.set_mime_type (supported.item_for_iteration)
				weighted_matches.extend (fitness_and_quality)
				supported.forth
			end

			weighted_matches.sort

			first_one := weighted_matches.last
			if attached first_one as first then
				if not first_one.quality.is_equal (0) then
					Result := first_one.mime_type
				else
					Result := ""
				end
			else
				Result := ""
			end
		end

feature {NONE} -- Implementation

	trim (a_string: STRING): STRING
			-- trim whitespace from the beginning and end of a stringo
		require
			valid_argument : a_string /= Void
		do
			a_string.left_adjust
			a_string.right_justify
			Result := a_string
		end

end
