xquery version "3.1";
import module namespace csv = "http://exist-db.org/apps/readch/csv" at "csv.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";


declare variable $agent := csv:csv-to-xml('../../csv/data/Agent.csv') => csv:sanitize();
declare variable $person := csv:csv-to-xml('../../csv/data/Person.csv') => csv:sanitize();
declare variable $rustication := csv:csv-to-xml('../../csv/data/Rustication.csv') => csv:sanitize();
declare variable $social-position := csv:csv-to-xml('../../csv/data/SocialPosition.csv') => csv:sanitize();

(:~
 : turn person.csv and related into tei:persons
 : @param $persons sanitized xml representation of original csv table
 : @return listPerson
:)
declare function local:listPers($persons as node()*) as item()* {
    element {fn:QName('http://www.tei-c.org/ns/1.0', 'listPerson')} {
        let $distinct := distinct-values($persons//person_id)
        
        for $p in $distinct
        let $path := $persons//person_id[. = $p]
        let $sex := lower-case($path[1]/../sex)
        let $wikidataid := $agent//agent_id[. = $p]/../wikidata_id/text()
        let $fictionality := upper-case($agent//agent_id[. =$p]/../fictionality/text())
            order by $p
        
        return
            element {fn:QName('http://www.tei-c.org/ns/1.0', 'person')} {
                attribute xml:id {data($p)},
                (: TODO see https://github.com/TEIC/TEI/issues/2180 should be @type not @ana :)
                if ($fictionality eq 'F') then (attribute ana {'fictional'}) else (),
                switch ($sex)
                    case 'male'
                        return
                            attribute sex {'M'}
                    case 'female'
                        return
                            attribute sex {'F'}
                    case 'unknown'
                        return
                            attribute sex {'U'}
                    default return
                        attribute sex {'N'},
            for $nom in $path
            return
                (: Name :)
                element {fn:QName('http://www.tei-c.org/ns/1.0', 'persName')} {
                    attribute xml:lang {$nom/../language},
                    attribute type {'main'},
                    element {fn:QName('http://www.tei-c.org/ns/1.0', 'surname')} {$nom/../family_name/string()},
                    if ($nom/../first_name)
                    then
                        (element {fn:QName('http://www.tei-c.org/ns/1.0', 'forename')} {$nom/../first_name/string()})
                    else
                        ()
                },
            for $nym in $path
            return
                if ($nym/../alt_name) then
                    (element {fn:QName('http://www.tei-c.org/ns/1.0', 'persName')} {
                        attribute xml:lang {$nym/../language},
                        attribute type {'alias'},
                        $nym/../alt_name/string()
                    })
                else
                    (),
            (: external IDs :)
            if ($wikidataid ne '')
            then (element {fn:QName('http://www.tei-c.org/ns/1.0', 'idno')} { attribute type {'wikidata'}, $wikidataid })
            else (),
            (: Lifedates :)
            if ($path/../birthyear)
            then
                (element {fn:QName('http://www.tei-c.org/ns/1.0', 'birth')} {
                    let $n := distinct-values($path/../birthyear)
                    let $map := csv:edtf($n, 'when')
                    return
                        attribute {map:keys($map)} {$map(map:keys($map))},
                    distinct-values($path/../birthyear),
                    for $origin in distinct-values($path/../place_of_birth)
                    return
                        switch ($origin)
                            case 'PL0999'
                                return
                                    ()
                            case 'NULL'
                                return
                                    ()
                            case ''
                                return
                                    ()
                            default return
                                element {fn:QName('http://www.tei-c.org/ns/1.0', 'placeName')} {attribute ref {'#' || $origin}
                                }
            })
        else
            (),
        if ($path/../deathyear)
        then
            (element {fn:QName('http://www.tei-c.org/ns/1.0', 'death')} {
                let $n := distinct-values($path/../deathyear)
                let $map := csv:edtf($n, 'when')
                return
                    attribute {map:keys($map)} {$map(map:keys($map))},
                distinct-values($path/../deathyear)
            })
        else
            (),
        (: Event :)
        for $rust in $path[1]/../rustication
        let $r := $rustication//person[. = $p]
        return
            if ($rust = 1)
            then
                (element {fn:QName('http://www.tei-c.org/ns/1.0', 'event')} {
                    attribute type {'rustication'},
                    if ($r/../rustication_start)
                    then
                        (let $map := csv:edtf($r/../rustication_start, 'from')
                        return
                            attribute {map:keys($map)} {$map(map:keys($map))})
                    else
                        (),
                    
                    if ($r/../rustication_end)
                    then
                        (let $map := csv:edtf($r/../rustication_end, 'to')
                        return
                            attribute {map:keys($map)} {$map(map:keys($map))})
                    else
                        (),
                    
                    if ($r/../place_of_rust)
                    then
                        (attribute where {'#' || distinct-values($r/../place_of_rust)})
                    else
                        (),
                    element {fn:QName('http://www.tei-c.org/ns/1.0', 'label')} {'rustication'}
                })
            else
                (),
        (: state :)
        if (lower-case(distinct-values($path/../neibu_access)) eq 'yes')
        then
            (element {fn:QName('http://www.tei-c.org/ns/1.0', 'state')} {
                attribute type {'neibu'},
                element {fn:QName('http://www.tei-c.org/ns/1.0', 'label')} {'access to neibu materials'}
            })
        else
            (),
        (: social Position :)
        for $status in $path[1]/../social_position
        let $label := $social-position//soc_pos_id[. = $status]
        return
            if (starts-with($status/text(), 'S'))
            then
                (element {fn:QName('http://www.tei-c.org/ns/1.0', 'socecStatus')} {
                    attribute scheme {'#rc'},
                    attribute code {$status},
                    $label/../soc_pos_name/text()
                })
            else
                (),
        (: note :)
        if ($agent//agent_id[. = $p]/../commentary)
        then
            (element {fn:QName('http://www.tei-c.org/ns/1.0', 'note')} {$agent//agent_id[. = $p]/../commentary/string()})
        else
            (),
        (: Bibl :)
        for $src in $path[1]/../source_1
        return
            element {fn:QName('http://www.tei-c.org/ns/1.0', 'listBibl')} {
                if (starts-with($src, 'W'))
                then
                    (element {fn:QName('http://www.tei-c.org/ns/1.0', 'bibl')} {
                        attribute source {'#' || distinct-values($src/text())},
                        if ($src/../page_1)
                        then
                            (element {fn:QName('http://www.tei-c.org/ns/1.0', 'biblScope')} {
                                attribute unit {'page'},
                                distinct-values($src/../page_1/text())
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
    (: /person :)
}
(: /listPers :)
};

local:listPers($person)
