xquery version "3.1";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace gexf = "http://gexf.net/1.3";
declare namespace viz = "http://gexf.net/1.3/viz";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:omit-xml-declaration "yes";

(:~ Library to produce directed graphs from ReadAct prosopography.
 : TODO enable undirected graph output
 : @see http://www.scottbot.net/HIAL/index.html@p=41158.html
 : @see https://toreopsahl.com/tnet/two-mode-networks/
 :
 : @author Duncan Paterson
 : @version 1.1.0-BETA
 : @return xml graph data in gexf for use with gephi or further processing
 :)
declare variable $readact-tei := doc('../tei_header.xml');
declare variable $reading-acts := $readact-tei//tei:relation[@type = "reading-act"];

(:~ Filter id string expects either id or idref column of the original csv transformed into tei.
 : @param $entity the sequence of ids to be  filtered
 :
 : @return the id string for use in lookup-funtion
 :)
declare function local:filter-idref($entity as xs:string*) {
    if (starts-with($entity, '#'))
    then
        (substring-after($entity, '#'))
    else
        ($entity)
};

(:~ Resolve ids to get primary entities: work, person, org, place.
 : @param ref the list of ids to be processed
 :
 : TODO enable xml:lang selection
 : @return the human readable name (Latn) for a given id
 :)
declare function local:lookup-id($ref as xs:string*) {
    let $entity := $readact-tei/id($ref)
    return
        typeswitch ($entity)
            case element(tei:person)
                return
                    $entity/tei:persName[@type = 'main'][1]/*/text()
            case element(tei:org)
                return
                    $entity/tei:orgName[@type = 'main'][1]/text()
            case element(tei:bibl)
                return
                    $entity/tei:title[@type = 'main'][1]/text()
            case element(tei:place)
                return
                    $entity/tei:placeName/text()
            default
                return
                    ()
};


(:~ Get distinct nodes of network
 : @param nodes the list of items to be processed typically uses some form of ID or IDREF
 :
 : @return nodes element containing distinct nodes of graph
 :)
declare function local:get-nodes($nodes as item()*) as element(gexf:nodes) {
    <gexf:nodes>
        {
            for $n1 in distinct-values($nodes/@active)
            let $id := local:filter-idref($n1)
            let $name := local:lookup-id($id)
                order by $id
            return
                <gexf:node id="{$id}" label="{$name}"/>
        }
        {
            for $n2 in distinct-values($nodes/@ref)
            let $id := local:filter-idref($n2)
            let $name := local:lookup-id($id)
                order by $id
            return
                <gexf:node id="{$id}" label="{$name}"/>
        }
    </gexf:nodes>
};

(:~ Construct edges of network
 : @param nodes the result of a node getter function
 : @param data the relationship to construct edges
 :
 : @return edges element containing unweighted and not-unique edges
 :)
declare function local:get-edges-raw($nodes as item()*, $data as item()*) as element(gexf:edges) {
    <gexf:edges>
        {
            for $e at $count-a in $nodes
            for $t at $count-b in $data[@active = '#' || $e]
            let $value := 1
                order by $e
            return
                <gexf:edge id="{$count-a || '-' || $count-b}" source="{$e}" target="{local:filter-idref($t/@ref)}"/>

        }
    </gexf:edges>
};

(:~ Construct a full graph based on node and edge contructing function
 : @param data datasource ReadAct xml
 : @param creator name of creator for gexf:meta field
 : @param desc description for gexf:meta field
 :
 : TODO calculate edge weights, (dedupe edges)
 : TODO try-catch for edges without nodes
 :
 : @return gexf element to be stored to disk
 :)
declare function local:gexf-graph($data as item()*, $creator as xs:string, $desc as xs:string) as element(gexf:gexf) {
    <gexf:gexf version="1.3">
        <gexf:meta lastmodifieddate="{current-date()}">
            <gexf:creator>{$creator}</gexf:creator>
            <gexf:description>{$desc}</gexf:description>
        </gexf:meta>
        <gexf:graph mode="static" defaultedgetype="directed">
            {
                local:get-nodes($data),
                local:get-edges-raw(local:get-nodes($data)//@id, $data)
            }
        </gexf:graph>
    </gexf:gexf>
};

local:gexf-graph($reading-acts, 'ReadAct', 'Bipartite graph of reading act edges, connecting agent and work nodes')
