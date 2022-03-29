local p = {};     --All lua modules on Wikipedia must begin by defining a variable 
                    --that will hold their externally accessible functions.
                    --Such variables can have whatever name you want and may 
                    --also contain various data as well as functions.
p.hello = function( frame )     --Add a function to "p".  
                                        --Such functions are callable in Wikipedia
                                        --via the #invoke command.
                                        --"frame" will contain the data that Wikipedia
                                        --sends this function when it runs. 
                                 -- 'Hello' is a name of your choice. The same name needs to be referred to when the module is used.
    
    local str = "Hello World!"  --Declare a local variable and set it equal to
                                --"Hello World!".  
    
    return str    --This tells us to quit this function and send the information in
                  --"str" back to Wikipedia.
    
end  -- end of the function "hello"
function p.hello_to(frame)		-- Add another function
	local name = frame.args[1]  -- To access arguments passed to a module, use `frame.args`
							    -- `frame.args[1]` refers to the first unnamed parameter
							    -- given to the module
	return "Hello, " .. name .. "!"  -- `..` concatenates strings. This will return a customized
									 -- greeting depending on the name given, such as "Hello, Fred!"
end
function p.count_fruit(frame)
	local num_bananas = frame.args.bananas -- Named arguments ({{#invoke:Example|count_fruit|foo=bar}}) are likewise 
	local num_apples = frame.args.apples   -- accessed by indexing `frame.args` by name (`frame.args["bananas"]`, or)
										   -- equivalently `frame.args.bananas`.
	return 'I have ' .. num_bananas .. ' bananas and ' .. num_apples .. ' apples'
										   -- Like above, concatenate a bunch of strings together to produce
										   -- a sentence based on the arguments given.
end

return p    --All modules end by returning the variable containing their functions to Wikipedia.
-- Now we can use this module by calling {{#invoke: Example | hello }},
-- {{#invoke: Example | hello_to | foo }}, or {{#invoke:Example|count_fruit|bananas=5|apples=6}}
-- Note that the first part of the invoke is the name of the Module's wikipage,
-- and the second part is the name of one of the functions attached to the 
-- variable that you returned.

-- The "print" function is not allowed in Wikipedia.  All output is accomplished
-- via strings "returned" to Wikipedia.