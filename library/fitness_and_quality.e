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

	make (a_fitness: INTEGER; a_quality: REAL_64)
		do
			fitness := a_fitness
			quality := a_quality
			create mime_type.make_empty
		ensure
			fitness_assigned : fitness = a_fitness
			quality_assigned : quality = a_quality
		end

feature -- Access

	fitness: INTEGER

	quality: REAL_64

	mime_type: STRING
			-- optionally used
			-- empty by default

feature -- Element Change

	set_mime_type (a_mime_type: STRING)
			-- set mime_type with `a_mime_type'	
		do
			mime_type := a_mime_type
		ensure
			mime_type_assigned : mime_type.same_string (a_mime_type)
		end

feature -- Comparision

	is_less alias "<" (other: like Current): BOOLEAN
			-- Is current object less than `other'?
		do
			if fitness = other.fitness then
				if quality.is_equal (other.quality) then
					Result := False
				else
					Result := quality < other.quality
				end
			else
			   Result := fitness < other.fitness
			end
		end
end
