xquery version "3.1";
import module namespace csv = "http://exist-db.org/apps/readch/csv" at "csv.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

declare variable $social-relation := csv:csv-to-xml('../../csv/data/SocialRelation.csv') => csv:sanitize();
declare variable $membership := csv:csv-to-xml('../../csv/data/Membership.csv') => csv:sanitize();
declare variable $act := csv:csv-to-xml('../../csv/data/Act.csv') => csv:sanitize();
declare variable $act-type := csv:csv-to-xml('../../csv/data/ActType.csv') => csv:sanitize();

(:~
 : turn SocialRelation.csv and related into tei:relations
 : @param $social sanitized xml representation of original csv table for social relations
 : @param $personal sanitized xml representation of original csv table for (institutional) membership
 : @param $act sanitized xml representation of the main csv table of ReadAct
 :
 : @return listRelations
:)

declare function local:listRelation($social as node()*, $personal as node()*, $acts as node()*) as item()* {
    element {fn:QName('http://www.tei-c.org/ns/1.0', 'listRelation')} {
        element {fn:QName('http://www.tei-c.org/ns/1.0', 'listRelation')} {
            attribute type {'personal'},
            for $rel in $social//row
            let $id := $rel/soc_rel_id
                order by $id
            return
                element {fn:QName('http://www.tei-c.org/ns/1.0', 'relation')} {
                    attribute xml:id {$id},
                    attribute ana {$rel/rel_zh},
                    attribute key {$rel/relation},
                    attribute name {replace($rel/rel_en, ' ', '-')},
                    attribute type {'personal'},
                    if (starts-with($rel/source, 'http'))
                    then
                        (attribute ref {$rel/source})
                    else
                        (attribute ref {'#' || $rel/source}),
                    switch ($rel/rel_en)
                        case 'acquaintance'
                        case 'friend'
                            return
                                attribute mutual {('#' || $rel/ego, '#' || $rel/related)}
                        default return
                            (attribute active {'#' || $rel/ego}, attribute passive {'#' || $rel/related})

            }
    },
    (: Membership :)
    element {fn:QName('http://www.tei-c.org/ns/1.0', 'listRelation')} {
        attribute type {'social'},
        for $m in $personal//row
            order by $m/institution
        return
            element {fn:QName('http://www.tei-c.org/ns/1.0', 'relation')} {
                attribute name {'member'},
                attribute type {'social'},
                attribute active {'#' || $m/institution},
                attribute passive {'#' || $m/member},
                if (starts-with($m/source, 'http'))
                then
                    (attribute ref {$m/source})
                else
                    (attribute ref {'#' || $m/source})
            }
    },
    (: Act :)
    element {fn:QName('http://www.tei-c.org/ns/1.0', 'listRelation')} {
        attribute type {'reading-act'},
        for $row in $acts//row
        let $id := $row/act_id
        let $type := $act-type//action_id[. = $row/action/text()]
        let $fictionality := upper-case($row/fictionality/text())
            order by $id
        return
            element {fn:QName('http://www.tei-c.org/ns/1.0', 'relation')} {
                attribute type {'reading-act'},
                if ($fictionality eq 'F') then (attribute subtype {'fictional'}) else (),
                for $a in $row/*
                return
                    typeswitch ($a)
                        case element(act_id)
                            return
                                attribute xml:id {$a}
                        case element(agent)
                            return
                                attribute active {'#' || $a}
                        case element(action)
                            return
                                (attribute key {$a}, attribute name {replace($type/../action_name, ' ', '-')})
                        case element(start)
                            return
                                let $map := csv:edtf($a, 'from')
                                return
                                    attribute {map:keys($map)} {$map(map:keys($map))}
                        case element(end)
                            return
                                let $map := csv:edtf($a, 'to')
                                return
                                    attribute {map:keys($map)} {$map(map:keys($map))}
                                    (: TODO make sure that active passive matches verb of act type ? :)
                        case element(act_target)
                            return
                                attribute passive {'#' || $a}
                        case element(act_object)
                            return
                                attribute ref {'#' || $a}
                        case element(last_modified_by)
                            return
                                attribute resp {$a}
                        case element(last_modified)
                            return
                                attribute change {$a}
                        default
                            return
                                (),
                element {fn:QName('http://www.tei-c.org/ns/1.0', 'desc')} {
                    for $d in $row/*
                    return
                        typeswitch ($d)
                            case element(discussion)
                                return
                                    $d/text()
                            (:~ TODO: how to deal with multiple locations if they exist ~:)
                            case element(site_information)
                                return
                                    element {fn:QName('http://www.tei-c.org/ns/1.0', 'placeName')}{ attribute type {'site-of-act'},
                                        attribute ref {'#' || $d}
                                    }        
                            case element(source)
                                return
                                    element {fn:QName('http://www.tei-c.org/ns/1.0', 'bibl')} {
                                        attribute type {'source'},
                                        if (starts-with($d, 'http'))
                                        then
                                            (attribute source {$d})
                                        else
                                            (attribute source {'#' || $d}),
                                        switch ($d/../page)
                                            case 'ONLINE SOURCE'
                                                return
                                                    ()
                                            case ''
                                                return
                                                    ()
                                            default return
                                                element {fn:QName('http://www.tei-c.org/ns/1.0', 'biblScope')} {
                                                    attribute unit {'page'},
                                                    $d/../page/text()
                                                }
                                }
                        default
                            return
                                ()
            }


        }
}
}
};

local:listRelation($social-relation, $membership, $act)
