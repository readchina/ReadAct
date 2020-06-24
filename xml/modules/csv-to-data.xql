xquery version "3.1";


(:~ This module transforms csv bliographic data into mods
 : @author Duncan Paterson
 : @version 0.6.0
:)
module namespace ctd = "http://exist-db.org/apps/readch/transform";
declare namespace test = "http://exist-db.org/xquery/xqsuite";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace map = " http://www.w3.org/2005/xpath-functions/map";

import module namespace config = "http://exist-db.org/apps/readch/config" at "config.xqm";
import module namespace csv = "http://exist-db.org/apps/readch/csv" at "csv.xql";

declare variable $ctd:secondary :=  ctd:sanitize(csv:csv-to-xml($config:SecondarySource));

(:~
 : deletes attributes with empty values
 : delete empty nodes
 : @see https://stackoverflow.com/questions/25836162/remove-empty-attributes-xquery3-0
:)
declare function ctd:sanitize($nodes as node()*) {
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
                                ctd:sanitize($child)
                        })
                        (: neither element nor attribute :)
            default
                return
                    $node
};

(:~
 : helper function for processing edtf dates when dealing with native xml date datatypes
 : return a sequence of attibute name and attribute value for further processing
:)
declare function ctd:edtf ($value as xs:string*, $att as xs:string) {
let $custo := $att || '-custom'

(: and $value ne '' :)
return

if ($value castable as xs:gYear and $value ne '' )
then (map{$att: $value})
else (map{$custo: $value})
};

(:~
 : mods helper function where details are part of main entity
 : @param 
 : @return element
:)

(:declare function ctd:mods-detail($node as node()*) as item()* {
element part { 
                    if ($node/../serial_part)
                    then (element detail { attribute type { 
                            let $d := substring($node/../serial_part, 1, 2)
                            return
                                switch ($d)
                                    case 'Vo' return 'volume'
                                    case 'No' return 'issue'
                               default return 'issue'    
                        },
                        element number {substring-after($node/../serial_part, ' ')}
                        })
                    else (),
                    if (matches($node/../pages, '^\d'))
                    then (element extent { attribute unit {'pages'},e
                        if (contains($node/../pages, '-'))
                        then (element start {substring-before(distinct-values($node/../pages), '-')}, 
                            element end {substring-after(distinct-values($node/../pages), '-')})
                        else (element total {distinct-values($node/../pages)})    
                    })
                    else ()
                })
                else ()
};:)

(:~
 : turn text.csv and related into modsCollection
 :
 : BUG we need to cheat when creating the @xsi:schemaLocation attribute which should just be another namespace
 : once this is fixed the test can be adapted to include the root element in the comparison as well
 : @see https://github.com/eXist-db/exist/issues/2183
:)
declare function ctd:transform-mods($books as node()*) as item()* {
    element {fn:QName('http://www.loc.gov/mods/v3', 'modsCollection')} {
        namespace {''} {'http://www.loc.gov/mods/v3'},
        namespace {'xsi'} {'http://www.w3.org/2001/XMLSchema-instance'},
        namespace {'xlink'} {'http://www.w3.org/1999/xlink'},
        attribute xsi:schemaLocation {'http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods.xsd'},
        comment {'last update: ' || fn:current-dateTime()},

        let $distinct := distinct-values($books//prim_source_id)

        for $book in $distinct
        let $path := $books//prim_source_id[. = $book]
        let $genre := csv:csv-to-xml($config:Genre)//genre_id[. = $path/../genre_id]
        let $place := csv:csv-to-xml($config:Place)//place_ID[. = $path/../publication_place]
            order by $book

        return
            element mods {
                attribute version {'3.7'},
                attribute ID {$book},

                for $title in $path/../title
                return
                    element titleInfo {
                        attribute xml:lang {$title/../title_lang},
                        element title {$title/text()},
                        if ($title/../subtitle)
                        then
                            (element subTitle {$title/../subtitle/text()})
                        else
                            ()
                    },
                element name {
                    attribute type {
                        if (starts-with($path/../person_id, 'P'))
                        then
                            ('personal')
                        else
                            ('corporate')
                    },
                    element nameIdentifier {distinct-values($path/../person_id)},

                    element role {
                        element roleTerm {
                            attribute type {'text'},
                            'author'
                        }
                    }
                },
                if (starts-with($path/../genre_id, 'G'))
                then
                    (element genre {
                        attribute type {$genre/../genre_type},
                        if (contains($genre/../source_link, 'genreForms'))
                        then
                            (attribute authority {'lcgft'})
                        else
                            (attribute authority {'lcsh'}),
                        distinct-values($genre/../genre_name)
                    })
                else
                    (),
                if ($path/../publication_place)
                then
                    (element originInfo {
                        attribute eventType {'publication'},
                        element place {
                            element placeTerm {
                                attribute type {'text'},
                                $place/../place_name/text()
                            },
                            element placeTerm {
                                attribute type {'code'},
                                distinct-values($path/../publication_place)
                            }
                        },
                        if ($path/../publishing_house)
                        then
                            (element publisher {distinct-values($path/../publishing_house)})
                        else
                            (),

                        if ($path/../publication_date)
                        then
                            (element dateIssued {distinct-values($path/../publication_date)})
                        else
                            (),
(: TODO:  this does not yet capture some corner cases  where no pub-place is known but a first date is  :)
                        if 
                            ($path/../first_chin_edition)
                        then 
                            (element dateOther { attribute type {'first-edition'}, 
                            distinct-values($path/../first_chin_edition)})
                        else ()
                    })
                else
                    (),
                if ($path/../source_id)
                then (element relatedItem { attribute type {'host'},
                let $sid := substring(distinct-values($path/../source_id), 1, 2)
                let $rps := $books//prim_source_id[. = $path/../source_id]/../title_lang[. = 'zh']
                let $rss := $ctd:secondary//sec_source_id[. = $path/../source_id]/../title_lang[. = 'en']
                let $part := if ($path/../serial_part or $path/../pages)
                then (element part { 
                    if ($path/../serial_part)
                    then (element detail { attribute type { 
                            let $d := substring($path/../serial_part, 1, 2)
                            return
                                switch ($d)
                                    case 'Vo' return 'volume'
                                    case 'No' return 'issue'
                               default return 'issue'    
                        },
                        element number {substring-after($path/../serial_part, ' ')}
                        })
                    else (),
                    if (matches($path/../pages, '^\d'))
                    then (element extent { attribute unit {'pages'}, 
                        if (contains($path/../pages, '-'))
                        then (element start {substring-before(distinct-values($path/../pages), '-')}, 
                            element end {substring-after(distinct-values($path/../pages), '-')})
                        else (element total {distinct-values($path/../pages)})    
                    })
                    else ()
                })
                else ()
                return
                    switch ($sid)
                        case 'SS' return (element titleInfo { element title {$rss/../title/text()}}, element identifier { attribute type {'local'}, 
                            distinct-values($path/../source_id)}, $part) 
                        case 'PS' return (element titleInfo { element title {$rps/../title/text()}}, element identifier { attribute type {'local'}, 
                            distinct-values($path/../source_id)}, $part)
                        default return attribute xlink:href {distinct-values($path/../source_id)}
                })
                else (),
                 (:     These are only top-level elements when not referencing a related serial host    :)
                if ($path/../serial_part or $path/../pages and not($path/../source_id))
                then (element part { 
                    if ($path/../serial_part)
                    then (element detail { attribute type { 
                            let $d := substring($path/../serial_part, 1, 2)
                            return
                                switch ($d)
                                    case 'Vo' return 'volume'
                                    case 'No' return 'issue'
                               default return 'issue'    
                        },
                        element number {substring-after($path/../serial_part, ' ')}
                        })
                    else (),
                    if (matches($path/../pages, '^\d'))
                    then (element extent { attribute unit {'pages'}, 
                        if (contains($path/../pages, '-'))
                        then (element start {substring-before(distinct-values($path/../pages), '-')}, 
                            element end {substring-after(distinct-values($path/../pages), '-')})
                        else (element total {distinct-values($path/../pages)})    
                    })
                    else ()
                })
                else (), 
                    element language {
                    element languageTerm {
                        attribute type {'code'},
                        attribute authority {'rfc4646'},
                        'zh'
                    }
                },

                if (lower-case($path[1]/../neibu/text()) eq 'yes')
                then
                    (element note {
                        attribute type {'neibu'},
                        'originally a neibu publication'
                    }
                    )
                else
                    (),
                if ($path/../note)
                then
                    (element note {$path/../note/text()})
                else
                    (),
                (: we have multiple creation & change dates just picking the first lcsh :)
                element recordInfo {
                    element recordCreationDate {distinct-values($path/../created/text())[1]},
                    element recordChangeDate {distinct-values($path/../last_modified/text())[1]}
                }
            }
    }
};

(:~
 : turn person.csv and related into tei persons
 : TODO add edtf function
 : TODO use sanitizer for types
 :
 : @return listPerson
:)
declare function ctd:transform-pers($ppl as node()*) as item()* {
    element {fn:QName('http://www.tei-c.org/ns/1.0', 'listPerson')} {
        namespace {''} {'http://www.tei-c.org/ns/1.0'},

        let $distinct := distinct-values($ppl//person_id)

        for $human in $distinct
        let $path := $ppl//person_id[. = $human]
        let $sex := lower-case($path[1]/../sex)
            order by $human

        return
            element person {
                attribute xml:id {data($human)},
                for $nom in $path

                return
                    (: Name :)
                    element persName {
                        attribute xml:lang {$nom/../name_lang},
                        attribute type {'main'},
                        element surname {$nom/../family_name/string()},
                        element forename {$nom/../first_name/string()}
                    },
                for $nym in $path
                return
                    if ($nym/../alt_name) then
                        (element persName {
                            attribute xml:lang {$nym/../alt_name_lang},
                            attribute type {'alias'},
                            $nym/../alt_name/string()
                        })
                    else
                        (),
                (: Lifedates :)
                if ($path/../birthyear)
                then
                    (element birth {
                        let $n := distinct-values($path/../birthyear)
                        let $map := ctd:edtf($n, 'when')
                        return
                        attribute {map:keys($map)} {$map(map:keys($map))},
                        distinct-values($path/../birthyear),
                        for $origin in distinct-values($path/../place_of_birth)
                        return
                            switch ($origin)
                                case 'PL0999' return ()
                                case 'NULL' return ()
                                case '' return ()
                                default return element placeName {attribute ref {'#' || $origin}
                            }
                    })
                else
                    (),
                if ($path/../deathyear)
                then
                    (element death {
                        let $n := distinct-values($path/../deathyear)
                        let $map := ctd:edtf($n, 'when')
                        return
                        attribute {map:keys($map)} {$map(map:keys($map))},
                        distinct-values($path/../deathyear)
                    })
                else
                    (),
                element sex {
                    switch ($sex)
                        case 'male'
                            return
                                attribute value {'M'}
                        case 'female'
                            return
                                attribute value {'F'}
                        default return
                            (),
                $sex
            },
            (: Event :)
            for $rust in $path[1]/../rustication
            return
                if ($rust eq 'no' or $rust eq 'NULL')
                then
                    ()
                else
                    (element event {
                        attribute type {'rustication'},
                        if ($rust/../rustication_start)
                        then
                            (let $map := ctd:edtf($rust/../rustication_start, 'from')
                             return
                               attribute {map:keys($map)} {$map(map:keys($map))})
                        else
                            (),

                        if ($rust/../rustication_end)
                        then
                            (let $map := ctd:edtf($rust/../rustication_end, 'to')
                             return
                               attribute {map:keys($map)} {$map(map:keys($map))})
                        else
                            (),

                        if ($rust/../place_of_rust)
                        then
                            (attribute where {'#' || distinct-values($rust/../place_of_rust)})
                        else
                            (),
                        element label {'rustication'}
                    }),
            if (lower-case(distinct-values($path/../neibu_access)) eq 'yes')
            then
                (element state {
                    attribute type {'neibu'},
                    element label {'access to neibu materials'}
                })
            else
                (),
            (: social Position :)
            for $status in $path[1]/../social_position
            let $label := csv:csv-to-xml($config:SocialPosition)//soc_pos_id[. = $status]
            return
                if (starts-with($status/text(), 'S'))
                then
                    (element socecStatus {
                        attribute scheme {'#rc'},
                        attribute code {$status},
                        $label/../soc_pos_name/text()
                    })
                else
                    (),
            (: note :)
            if ($path/../commentary)
            then
                (element note {distinct-values($path/../commentary)})
            else
                (),
            (: Bibl :)              
 for $src in $path[1]/../source_id_1
                return
                    element listBibl {
                        if (starts-with($src, 'SS'))
                        then ( element bibl {
                                     attribute source {distinct-values($src/text())},
                                     element biblScope {
                                         attribute unit {'page'},
                                         distinct-values($src/../page_number_1/text())
                                     }
                                 }
                            )
                        else ( element bibl { attribute source {distinct-values($src/text())}  } )
        }
        }
}
};

(:~
 : turn Act.csv and related into tei relations
 : @param acts the Act.csv file as xml
 : outstanding validation errors
 : @see https://github.com/LenaHenningsen/ReadingData/issues/291
 :
 : @see https://github.com/TEIC/TEI/issues/327
 : @return listRelation
:)
declare function ctd:transform-acts($acts as node()*) as item()* {
    element {fn:QName('http://www.tei-c.org/ns/1.0', 'listRelation')} {
        namespace {''} {'http://www.tei-c.org/ns/1.0'},
         attribute type {'acts'},
         attribute subtype {'reading'},

        let $distinct := distinct-values($acts//act_ID)

        for $act in $acts//act_ID
        let $type := ctd:sanitize(csv:csv-to-xml($config:ActType))
        order by $act

        return
            element relation {
                for $n in $act/../*
                    where $n ne ''
                return
                    typeswitch ($n)
                        case element(act_ID)
                            return
                                attribute xml:id {normalize-space($n)}
                        case element(agent)
                            return
                                attribute active {'#' || $n}
                        case element(action)
                            return
                                attribute key {$n}
                        case element(start)
                            return
                                let $map := ctd:edtf($n, 'from')
                                return
                                    attribute {map:keys($map)} {$map(map:keys($map))}
                        case element(end)
                            return
                                let $map := ctd:edtf($n, 'to')
                                return
                                    attribute {map:keys($map)} {$map(map:keys($map))}
                        default
                            return
                                (),
                attribute passive {
                    for $p in $act/../act_target | $act/../act_object
                        return
                            normalize-space(' #' || $p)
                            },

                element desc {
                    for $el in $act/../*
                        where $el ne ''
                    return
                        typeswitch ($el)
                            case element(action)
                                return
                                    element label {normalize-space($type//action_ID[. = $el]/../action_name)}
                            case element(substantial_discussion) |  element(comment)
                                return
                                    element desc {normalize-space($el)}
                            case element(source_id)
                                return
                                    element bibl {
                                        if (starts-with($el, 'http'))
                                        then (element ref{ attribute target {$el}})
                                        else (attribute source {'#' || $el/text()},
                                            if ($el/../page_number)
                                            then
                                                (element citedRange {
                                                    attribute unit {'page'},
                                                    $el/../page_number/text()
                                                })
                                            else
                                                ()
                                            )
                                    }
                            default
                                return
                                    ()
                }
            }
    }
};

(:~
 : turn Place.csv and related into tei listPlace
 : @param $places sanitized xml representation of original csv table
 : @return listPlace
:)
declare function ctd:transform-spatial($places as node()*) as item()* {
    element {fn:QName('http://www.tei-c.org/ns/1.0', 'listPlace')} {
        namespace {''} {'http://www.tei-c.org/ns/1.0'},

        for $pl in $places//place_ID
            order by $pl
        return
            element place {
                attribute xml:id {$pl},
                element placeName {$pl/../place_name/text()},
                element location {
                    element geo {$pl/../lat/text() || ' ' || $pl/../long}
                }
            }
    }
};

(:~
 : turn institution.csv into org
 : TODO add org membership to person relations
 : TODO add edtf function
 : @return listOrg
 : inst_ID,inst_name,inst_name_lang,place_id,start,end,alt_start,alt_end,inst_alt_name,commentary,
 : note,source_id,page_number,created,created_by,last_modified,last_modified_by
:)
declare function ctd:transform-org($groups as node()*) as item()* {
    element {fn:QName('http://www.tei-c.org/ns/1.0', 'listOrg')} {
    namespace {''} {'http://www.tei-c.org/ns/1.0'},

    for $grp in distinct-values($groups//inst_ID)
        let $path := $groups//inst_ID[. = $grp]
        return
            element org {
                attribute xml:id {$grp},

                for $name in distinct-values($path/../inst_name)
                let $hit := $path/../inst_name[. = $name]

                return
                    element orgName { attribute xml:lang {distinct-values($hit/../inst_name_lang)},
                        attribute type {'main'},
                        if ($hit/../start)
                        then (attribute from {distinct-values($hit/../start)})
                        else(),
                        if ($hit/../end)
                        then (attribute to {distinct-values($hit/../end)})
                        else(),
                        $name},

                    for $al in distinct-values($path/../inst_alt_name)
                    let $hit := $path/../inst_alt_name[. = $al]
                    return
                        element orgName { attribute xml:lang {distinct-values($hit/../inst_name_lang)},
                        attribute type {'alias'},
                        if ($hit/../alt_start)
                        then (attribute from {distinct-values($hit/../alt_start)})
                        else(),
                        if ($hit/../alt_end)
                        then (attribute to {distinct-values($hit/../alt_end)})
                        else(),
                        $al},

                        (: the following requires ODD customization :)
                        for $p in distinct-values($path/../place_id)
                        return
                         element placeName {attribute ref {'#' || $p}},

                    for $com in distinct-values($path/../commentary)
                    return
                        element note {$com}
            }
    }
};

(:~
 : write transformed files into database
:)
declare function ctd:write-files() {
    let $books := ctd:sanitize(csv:csv-to-xml($config:PrimarySource))
    let $bibl := ctd:transform-mods($books)

    let $persons := ctd:sanitize(csv:csv-to-xml($config:Person))
    let $group := ctd:transform-pers($persons)

    let $activities := ctd:sanitize(csv:csv-to-xml($config:Act))
    let $deeds := ctd:transform-acts($activities)

    let $spatial := ctd:sanitize(csv:csv-to-xml($config:Place))
    let $places := ctd:transform-spatial($spatial)

    let $orgas := ctd:sanitize(csv:csv-to-xml($config:Institution))
    let $inst := ctd:transform-org($orgas)

    return

        (xmldb:store($config:tei-root, 'listPerson.xml', $group),
        xmldb:store($config:mods-root, 'modsCollection.xml', $bibl),
        xmldb:store($config:tei-root, 'listRelation.xml', $deeds),
        xmldb:store($config:tei-root, 'listPlace.xml', $places),
        xmldb:store($config:tei-root, 'listOrg.xml', $inst)
        )
};
