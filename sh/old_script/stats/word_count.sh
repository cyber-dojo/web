find . -type f -name \*.rb -print0 | xargs -0 cat  | \
sed 's/test/ /g' | \
sed 's/assert_equal/ /g' | \
sed 's/end/ /g' | \
sed 's/def/ /g' | \
sed 's/do/ /g' | \
tr '0' ' ' | \
tr '1' ' ' | \
tr '2' ' ' | \
tr '3' ' ' | \
tr '4' ' ' | \
tr '5' ' ' | \
tr '6' ' ' | \
tr '7' ' ' | \
tr '8' ' ' | \
tr '9' ' ' | \
tr '.' ' ' | \
tr '(' ' ' | \
tr ')' ' ' | \
tr '[' ' ' | \
tr ']' ' ' | \
tr '{' ' ' | \
tr '}' ' ' | \
tr '!' ' ' | \
tr '@' ' ' | \
tr '#' ' ' | \
tr ':' ' ' | \
tr '=' ' ' | \
tr '-' ' ' | \
tr '+' ' ' | \
tr '>' ' ' | \
tr '<' ' ' | \
tr '?' ' ' | \
tr '|' ' ' | \
tr '"' ' ' | \
tr ',' ' ' | \
tr '/' ' ' | \
tr '\' ' ' | \
tr "'" ' ' | \
tr ' ' '\n' | \
tr 'A-Z' 'a-z' | \
sort | \
uniq -c | sort -rn | head -n 70 | more
