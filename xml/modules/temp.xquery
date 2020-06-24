declare function local:transform-pers($ppl as node()*) as item()* {
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