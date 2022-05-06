xquery version "3.1";
import module namespace csv = "http://exist-db.org/apps/readch/csv" at "csv.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

declare variable $space := csv:csv-to-xml('../../csv/data/Space.csv') => csv:sanitize();


(:~
 : turn space.csv and related into tei:place
 : @param $groups sanitized xml representation of original csv table
 : @return listOrg
:)

declare function local:listPlace($places as node()*) as item()* {
    element {fn:QName('http://www.tei-c.org/ns/1.0', 'listPlace')} {

        for $pl in $places//space_id
        let $type := $pl/../space_type
        let $wikidataid := lower-case($pl/../wikidata_id)
            order by $pl
        return
            element {fn:QName('http://www.tei-c.org/ns/1.0', 'place')} {
                attribute xml:id {$pl},
                attribute type {$type},
                element {fn:QName('http://www.tei-c.org/ns/1.0', 'placeName')} {$pl/../space_name/text()},
                if ($type eq 'PL')
                then
                    (element {fn:QName('http://www.tei-c.org/ns/1.0', 'location')} {
                        element {fn:QName('http://www.tei-c.org/ns/1.0', 'geo')} {$pl/../lat/text() || ' ' || $pl/../long}
                    })
                else
                    (),
                (: external IDs :)
                if ($pl/../wikidata_id)
                then (element {fn:QName('http://www.tei-c.org/ns/1.0', 'idno')} { attribute type {'wikidata'}, $wikidataid })
                else (),
                if ($pl/../note)
                then
                    (element {fn:QName('http://www.tei-c.org/ns/1.0', 'note')} {$pl/../note/text()})
                else
                    ()
            }
    }
};

local:listPlace($space)
