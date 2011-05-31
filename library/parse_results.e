note
	description: "Summary description for {PARSE_RESULTS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PARSE_RESULTS
inherit
	ANY
		redefine
			out
		end
create
	make
feature -- Initialization
	make
		do
			create params.make (10)
		end

feature -- Access
	type : STRING
	sub_type : STRING

	item (a_key : STRING) : STRING
		do
			Result := params.item (a_key)
		end

	keys : LIST[STRING]
		-- arrays of currents keys
		local
			res : ARRAYED_LIST[STRING]
		do
			create res.make_from_array (params.current_keys)
			Result := res
		end

	has_key (a_key : STRING) : BOOLEAN
		do
			Result := params.has_key (a_key)
		end

feature -- Element change
	set_type (a_type : STRING)
		do
			type := a_type
		ensure
			type_assigned : type ~ a_type
		end


	set_sub_type (a_sub_type : STRING)
		do
			sub_type := a_sub_type
		ensure
			sub_type : sub_type ~ a_sub_type
		end


    put (new: STRING; key: STRING)
		do
			if params.has_key (key) then
				params.replace (new, key)
			else
				params.put (new, key)
			end

		end



feature -- Status Report
	out : STRING
    	do
    		create Result.make_from_string ("('" + type + "', '" + sub_type  + "', {")
			from
				params.start
			until
				params.after
			loop
				Result.append("'" + params.key_for_iteration + "':'" + params.item_for_iteration + "',");
				params.forth
			end
			Result.append("})")
    	end


feature {NONE} -- Implementation
	params : HASH_TABLE[STRING,STRING]
		--dictionary of all the parameters for the media range

end
