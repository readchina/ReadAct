xquery version "3.1";
import module namespace csv = "http://exist-db.org/apps/readch/csv" at "csv.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

declare variable $agent := csv:csv-to-xml('../../csv/data/Agent.csv') => csv:sanitize();
declare variable $institution := csv:csv-to-xml('../../csv/data/Institution.csv') => csv:sanitize();
declare variable $membership := csv:csv-to-xml('../../csv/data/Membership.csv') => csv:sanitize();


(:~
 : turn institution.csv and related into tei:org
 : @param $groups sanitized xml representation of original csv table
 : @return listOrg
:)
declare function local:listOrg($groups as node()*) as item()* {
    element {fn:QName('http://www.tei-c.org/ns/1.0', 'listOrg')} {
        
        for $grp in distinct-values($groups//inst_id)
        let $path := $groups//inst_id[. = $grp]
        let $wikidataid := $agent//agent_id[. = $grp]/../wikidata_id/text()
        let $fictionality := upper-case($agent//agent_id[. =$grp]/../fictionality/text())
        return
            element {fn:QName('http://www.tei-c.org/ns/1.0', 'org')} {
                attribute xml:id {$grp},
                if ($fictionality eq 'F') then (attribute type {'fictional'}) else (),
                for $name in distinct-values($path/../inst_name)
                let $hit := $path/../inst_name[. = $name]
                
                return
                    element {fn:QName('http://www.tei-c.org/ns/1.0', 'orgName')} {
                        attribute xml:lang {distinct-values($hit/../language)},
                        attribute type {'main'},
                        let $start := distinct-values($hit/../start)
                        let $map1 := csv:edtf($start, 'from')
                        return
                            if ($hit/../start)
                            then
                                (attribute {map:keys($map1)} {$map1(map:keys($map1))})
                            else
                                (),
                        let $end := distinct-values($hit/../end)
                        let $map2 := csv:edtf($end, 'to')
                        return
                            if ($hit/../end)
                            then
                                (attribute {map:keys($map2)} {$map2(map:keys($map2))})
                            else
                                (),
                        $name
                    },
                
                for $al in distinct-values($path/../inst_alt_name)
                let $hit := $path/../inst_alt_name[. = $al]
                return
                    element {fn:QName('http://www.tei-c.org/ns/1.0', 'orgName')} {
                        attribute xml:lang {distinct-values($hit/../language)},
                        attribute type {'alias'},
                        let $start := distinct-values($hit/../alt_start)
                        let $map3 := csv:edtf($start, 'from')
                        return
                            if ($hit/../alt_start)
                            then
                                (attribute {map:keys($map3)} {$map3(map:keys($map3))})
                            else
                                (),
                        let $end := distinct-values($hit/../alt_end)
                        let $map4 := csv:edtf($end, 'to')
                        return
                            if ($hit/../alt_end)
                            then
                                (attribute {map:keys($map4)} {$map4(map:keys($map4))})
                            else
                                (),
                        $al
                    },
                for $p in distinct-values($path/../place)
                return
                    element {fn:QName('http://www.tei-c.org/ns/1.0', 'placeName')} {attribute ref {'#' || $p}},
                (: external IDs :)
                if ($wikidataid ne '')
                then (element {fn:QName('http://www.tei-c.org/ns/1.0', 'idno')} { attribute type {'wikidata'}, $wikidataid })
                else (),
                (: note :)
                if ($agent//agent_id[. = $grp]/../commentary)
                then
                    (element {fn:QName('http://www.tei-c.org/ns/1.0', 'note')} {$agent//agent_id[. = $grp]/../commentary/string()})
                else
                    (),
                (: Bibl :)
                for $src in $path[1]/../source
                return
                    element {fn:QName('http://www.tei-c.org/ns/1.0', 'listBibl')} {
                        if (starts-with($src, 'W'))
                        then
                            (element {fn:QName('http://www.tei-c.org/ns/1.0', 'bibl')} {
                                attribute source {'#' || distinct-values($src/text())},
                                if ($src/../page)
                                then
                                    (element {fn:QName('http://www.tei-c.org/ns/1.0', 'biblScope')} {
                                        attribute unit {'page'},
                                        distinct-values($src/../page/text())
                                    })
                                else
                                    ()
                            }
                            )
                        else
                            (element {fn:QName('http://www.tei-c.org/ns/1.0', 'bibl')} {attribute source {distinct-values($src/text())}})
                    }
                    (: /listBibl :)
            }
            (: /org :)
    }
    (: /listOrg :)
};


local:listOrg($institution)
