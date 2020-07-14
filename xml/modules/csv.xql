xquery version "3.1";
module namespace csv = "http://exist-db.org/apps/readch/csv";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

(:~ This module transforms csv into xml.
 : It assumes a header.
 : @author Joe Wicentowski, Duncan Paterson
 : @see https://gist.github.com/joewiz/7581205ab5be46eaa25fe223acda42c3
 : @return csv data as xml fragment
 :)

declare variable $csv:seperator as xs:string := ',';

declare function csv:get-cells($row as xs:string) as xs:string* {
    (: workaround for lack of lookahead support: append seperator to end of row :)
    let $string-to-analyze := $row || $csv:seperator
    let $analyze := fn:analyze-string($string-to-analyze, '(("[^"]*")+|[^,]*),')
    for $group in $analyze//fn:group[@nr = 1]
    return
        if (matches($group, '^".+"$')) then
            replace($group, '^"([^"]+)"$', '$1')
        else
            $group/string()
};

declare function csv:csv-to-xml($path-to-file as xs:string) as node()* {
    let $csv := fn:unparsed-text($path-to-file)
    let $lines := tokenize($csv, '\n')
    let $header-row := fn:head($lines)
    let $body-rows := fn:tail($lines)
    let $headers := csv:get-cells($header-row) ! replace(., '\s+', '_')
    let $columns := count($headers)
    return
        element csv {
            for $row at $n in $body-rows
            let $cells := csv:get-cells($row)
            return
                if (count($cells) = $columns)
                then
                    (
                    element row {
                        attribute n {$n},
                        attribute test {'pass'},
                        for $cell at $count in $cells
                        return
                            element {$headers[$count]} {normalize-space($cell)}
                    })
                else
                    (element row {
                        attribute n {$n},
                        attribute test {'fail'},
                        for $cell at $count in $cells
                        return
                            element {$headers[$count]} {normalize-space($cell)}
                    })
        }
};

declare function csv:sanitize($nodes as node()*) {
    for $node in $nodes
        where $node ne 'NULL'
    return
        typeswitch ($node)
            (: filter empty attributes :)
            case attribute()
                return
                    $node[normalize-space(.)]
                    (: recreate elements :)
            case element()
                return
                    if (normalize-space($node) eq '') then
                        ()
                    else
                        (
                        element {node-name($node)} {

                            (: Sanitize all children :)
                            for $child in $node/(attribute(), node())
                            return
                                csv:sanitize($child)
                        })
                        (: neither element nor attribute :)
            default
                return
                    $node
};

(:~
 : helper function for processing edtf dates when dealing with native xml date datatypes
 : @return a sequence of attibute name and attribute value for further processing
:)
declare function csv:edtf ($value as xs:string*, $att as xs:string) {
let $custo := $att || '-custom'
return

if ($value castable as xs:gYear and $value ne '' )
then (map{$att: $value})
else (map{$custo: $value})
};
