xquery version "3.1";
import module namespace csv = "http://exist-db.org/apps/readch/csv" at "csv.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace map = " http://www.w3.org/2005/xpath-functions/map";


declare variable $act := csv:csv-to-xml('../../csv/data/Act.csv') => csv:sanitize();
declare variable $act-type := csv:csv-to-xml('../../csv/data/ActType.csv') => csv:sanitize();

(:~
 : turn Act.csv and related into tei:event
 : @param $reading-acts sanitized xml representation of original csv table
 : TODO event too limited probably better to slightly adjust the original listRelation typeswitch
 : @return listEvent
:)

declare function local:listEvent($reading-acts as node()*) {
    element {fn:QName('http://www.tei-c.org/ns/1.0', 'listRelation')} {
        namespace {''} {'http://www.tei-c.org/ns/1.0'},
        for $a in $reading-acts//row
        return
            element {fn:QName('http://www.tei-c.org/ns/1.0', 'relation')} {
                attribute xml:id {$a/act_id},
                attribute type {$a/action},
                
                $a
            }
    }
};

local:listEvent($act)