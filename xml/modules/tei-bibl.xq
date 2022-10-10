xquery version "3.1";
import module namespace csv = "http://exist-db.org/apps/readch/csv" at "csv.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";


declare variable $art-form := csv:csv-to-xml('../../csv/data/ArtForm.csv') => csv:sanitize();
declare variable $art-work := csv:csv-to-xml('../../csv/data/ArtWork.csv') => csv:sanitize();
declare variable $genre := csv:csv-to-xml('../../csv/data/Genre.csv') => csv:sanitize();
declare variable $primary-source := csv:csv-to-xml('../../csv/data/PrimarySource.csv') => csv:sanitize();
declare variable $quotation := csv:csv-to-xml('../../csv/data/Quotation.csv') => csv:sanitize();
declare variable $secondary-source := csv:csv-to-xml('../../csv/data/SecondarySource.csv') => csv:sanitize();
declare variable $work := csv:csv-to-xml('../../csv/data/Work.csv') => csv:sanitize();

(:~
 : turn work.csv and related into tei:bibl
 : @param $works sanitized xml representation of original csv table
 : TODO add @level to title element
 : TODO taxonomy get rid of replace hack for genre-types, @ana could then reference taxonomy from bibl element
 : @see https://github.com/TEIC/TEI/issues/2011
 :
 : @return listBibl
:)

declare function local:listBibl($works as node()*) as item()* {
    element {fn:QName('http://www.tei-c.org/ns/1.0', 'listBibl')} {

        for $w in $work//work_id
        let $type := $w/../work_type
        let $note := $w/../commentary
        let $fictionality := upper-case($w/../fictionality)
        let $quote := $quotation//source[. = $w]
        let $path := switch ($type)
            case ('PS')
                return
                    $primary-source//prim_source_id[. = $w]
            case ('SS')
                return
                    $secondary-source//sec_source_id[. = $w]
            case ('AW')
                return
                    $art-work//art_work_id[. = $w]
            case ('Q')
                return
                    $quote//source[. = $w]        
            default return
               $w
        (: see https://github.com/readchina/ReadAct/pull/498/commits/2733ed0cc07745c056196f0c2fd0bf5b7888ff37 :)
        where $type ne 'Q'       
        order by $w
    return
        element {fn:QName('http://www.tei-c.org/ns/1.0', 'bibl')} {
            attribute xml:id {$w},
            attribute type {
                switch ($type)
                    case ('PS')
                    case ('SS')
                        return
                            'text'
                    case('AW') 
                        return
                            'artwork'        
                    default 
                        return
                        ()
        },
        
        if ($fictionality eq 'F') then (attribute subtype {'fictional'}) else (),

        switch (distinct-values($path/../neibu))
            case 'yes'
                return
                    attribute status {'neibu-access'}
            case 'no'
                return
                    attribute status {'open-circulation'}
            default return
                attribute status {'unspecified-access'},
    (: title :)
    for $t in $path/../title
    return
        element {fn:QName('http://www.tei-c.org/ns/1.0', 'title')} {
            attribute xml:lang {$t/../language},
            attribute type {'main'},
            $t/text(),
            if ($t/../subtitle)
            then
                (element {fn:QName('http://www.tei-c.org/ns/1.0', 'title')} {
                    attribute type {'sub'},
                    $t/../subtitle/text()
                })
            else
                ()
        },
    (: creator :)
    element {fn:QName('http://www.tei-c.org/ns/1.0', 'author')} {
        attribute ref {'#' || $w/../creator}
    },
    (: date :)
    if ($path/../publication_date)
    then
        (element {fn:QName('http://www.tei-c.org/ns/1.0', 'date')} {
            let $map := csv:edtf(distinct-values($path/../publication_date), 'when')
            return
                attribute {map:keys($map)} {$map(map:keys($map))}
        })
    else
        if ($path/../first_performance_date)
        then
            (element {fn:QName('http://www.tei-c.org/ns/1.0', 'date')} {
                let $map := csv:edtf(distinct-values($path/../first_performance_date), 'when')
                return
                    attribute {map:keys($map)} {$map(map:keys($map))}
            })
        else
            (),
    if ($path/../first_chin_edition)
    then
        (element {fn:QName('http://www.tei-c.org/ns/1.0', 'date')} {
            attribute type {'first-chinese-edition'},
            let $map := csv:edtf(distinct-values($path/../first_chin_edition), 'when')
            return
                attribute {map:keys($map)} {$map(map:keys($map))}
        })
    else
        (),
    (: place :)
    for $pp in distinct-values($path/../publication_place)
    return
        element {fn:QName('http://www.tei-c.org/ns/1.0', 'pubPlace')} {
            attribute ref {'#' || $pp}
        },
    for $ppp in distinct-values($path/../first_performance_place)
    return
        element {fn:QName('http://www.tei-c.org/ns/1.0', 'placeName')} {
            attribute type {'first-performance'},
            attribute ref {'#' || $ppp}
        },
    (: publisher :)
    for $pub in distinct-values($path/../publishing_house)
    return
        element {fn:QName('http://www.tei-c.org/ns/1.0', 'publisher')} {$pub},
    (: biblScope :)
    for $scope in distinct-values($path/../serial)
    return
        element {fn:QName('http://www.tei-c.org/ns/1.0', 'biblScope')} {
            attribute unit {'volume'},
            $scope
        },
    for $page in distinct-values($path/../page)
    return
        element {fn:QName('http://www.tei-c.org/ns/1.0', 'biblScope')} {
            attribute unit {'page'},
            $page
        },

    (: genre / notes :)
    for $g in distinct-values($path/../genre)
    let $gg := $genre//genre_id[. = $g]
    let $g-type := replace($gg/../genre_type, ' ', '-')
    let $g-name := $gg/../genre_name
    let $g-src := $gg/../source
    (: create taxonony in wrapper file TBD  
    TODO: only use LCSH for actual LCSH, not for artform etc
    :)
    let $g-idno := $g-src
    return
        element {fn:QName('http://www.tei-c.org/ns/1.0', 'note')} {
            attribute type {'genre'},
            attribute subtype {$g-type},
            $g-name/text(),
            element {fn:QName('http://www.tei-c.org/ns/1.0', 'idno')} {
                attribute type {'LCSH'},
                let $url := substring-before($g-src/text(), '.html')
                return
                    tokenize($url, '/')[last()]


            }
        },
    for $af in distinct-values($path/../art_form)
    let $aaf := $art-form//art_form_id[. = $af]
    let $af-name := $aaf/../art_form_name
    let $af-src := $aaf/../source
    let $af-idno := $af-src
    return
        element {fn:QName('http://www.tei-c.org/ns/1.0', 'note')} {
            attribute type {'art-form'},
            $af-name/text(),
            element {fn:QName('http://www.tei-c.org/ns/1.0', 'idno')} {
                attribute type {'AAT'},
                substring-after($af-src/text(), 'subjectid=')
            }
        },
    (: quotation :)
    for $q in $quote
    return
        element {fn:QName('http://www.tei-c.org/ns/1.0', 'note')} {
            attribute type {'quote'},
            element {fn:QName('http://www.tei-c.org/ns/1.0', 'cit')} {
                attribute ana {$q/../quotation_id},
                element {fn:QName('http://www.tei-c.org/ns/1.0', 'quote')} {
                    $q/../quotation/text()
                },
                if ($q/../page)
                then
                    (element {fn:QName('http://www.tei-c.org/ns/1.0', 'ptr')} {
                        attribute target {$q/../page}
                    })
                else
                    ()
            }
        },
    (: ref :)
    for $src in distinct-values($path/../source)
    return
        element {fn:QName('http://www.tei-c.org/ns/1.0', 'ref')} {
            attribute type {'src'},
            if (starts-with($src, 'http'))
            then
                (attribute target {$src})
            else
                (attribute target {'#' || $src})

        }

}
}
};

local:listBibl($work)
