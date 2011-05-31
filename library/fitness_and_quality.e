note
	description: "Summary description for {FITNESS_AND_QUALITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FITNESS_AND_QUALITY

inherit
	COMPARABLE

create
	make

feature -- Initialization
	make ( a_fitness : INTEGER; a_quality : REAL_64)
		do
			fitness := a_fitness
			quality := a_quality
		end

feature -- Access
	 fitness : INTEGER
     quality : REAL_64
	 mime_type : STRING
		-- optionally used

feature -- Element Change
	set_mime_type (a_mime_type : STRING)
		do
			mime_type := a_mime_type
		ensure
			mime_type_assigned : mime_type ~ a_mime_type
		end

feature -- Comparision

	is_less alias "<" (other: like Current): BOOLEAN
			-- Is current object less than `other'?
		do
			if Current.fitness = other.fitness then
				if Current.quality.is_equal (other.quality) then
					Result := false;
				else
					Result := Current.quality < other.quality
				end
			else
			   Result := Current.fitness < other.fitness
			end
		end
end
