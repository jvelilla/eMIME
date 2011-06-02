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
		-- Item associated with `a_key', if present
		-- otherwise default value of type `STRING'
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
		-- Is there an item in the table with key `a_key'?
		do
			Result := params.has_key (a_key)
		end

feature -- Element change
	set_type (a_type : STRING)
		-- Set type with `a_type'
		do
			type := a_type
		ensure
			type_assigned : type.same_string (a_type)
		end


	set_sub_type (a_sub_type : STRING)
		-- Set sub_type with `a_sub_type'
		do
			sub_type := a_sub_type
		ensure
			sub_type_assigned : sub_type.same_string(a_sub_type)
		end


    put (new: STRING; key: STRING)
    	-- Insert `new' with `key' if there is no other item
		-- associated with the same key. If present, replace
		-- the old value with `new'
		do
			if params.has_key (key) then
				params.replace (new, key)
			else
				params.put (new, key)
			end
		ensure
			has_key :  params.has_key (key)
			has_item : params.has_item (new)
		end



feature -- Status Report
	out : STRING
		-- Representation of the current object
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
