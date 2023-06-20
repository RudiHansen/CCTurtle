foo = string.format( "%-10s", "ABCDEABCDE" )
foo = string.sub(foo,1,10)
print(foo:len(), foo..":")

foo = string.format( "%-10s", "ABCDEABCDEABCDEABCDE" )
foo = string.sub(foo,1,10)
print(foo:len(), foo..":")

foo = string.format("%-20s %05d","here is a string", 12)
print(foo:len(), foo)
