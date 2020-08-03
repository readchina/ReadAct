xquery version "3.1";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace gexf = "http://www.gexf.net/1.3";
declare namespace viz = "http://www.gexf.net/1.3/viz";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:omit-xml-declaration "yes";

(:~ Library to produce directed graphs from ReadAct prosopography.
 : TODO generate proper vega/d3 json from gexf
 : TODO enable undirected graph output
 : @author Duncan Paterson
 : @version 1.1.0-BETA
 : @return either json or xml graph data  for visualization via vega or gephi respectively
 :)
declare variable $readact-tei := doc('../tei_header.xml');
declare variable $reading-acts := $readact-tei//tei:relation[@type = "reading-act"];

(:~
 : take gexf graph representation and return JSON for display via vega,
 : which uses D3 force layout under the hood. 
 : @param graph gexf formated graph
 :
 : @return json representation of graph
 :)
declare function local:gexf-to-vega($graph as node()) {
    let $g :=
    <map xmlns="http://www.w3.org/2005/xpath-functions">
        <array key="nodes">
            {
                for $n in $graph//gexf:node
                return
                    <map>
                        <string key="id">{data($n/@id)}</string>
                        <string key="label">{data($n/@label)}</string>
                    </map>
            }
        </array>
        <array key="links">
            {
                for $e in $graph//gexf:edge
                return
                    <map>
                        <string key="source">{data($e/@source)}</string>
                        <string key="target">{data($e/@target)}</string>
                        <number key="value">1</number>
                    </map>
            }
        </array>
    </map>
    return
        xml-to-json($g)
};


(:~ Get distinct nodes from data, 
 : expects either id or idref column of the original csv transformed into tei.
 : @see https://raw.githubusercontent.com/vega/vega/master/docs/data/miserables.json
 : @param nodes the list of items to be processed
 :
 : TODO make flexible with respect to primary entity types but based of Acts
 : @return node element
 :)
declare function local:entities-to-nodes($nodes as item()*) {
    1 + 1
};


(:~ Get distinct nodes of network
 : @param nodes the list of items to be processed typically uses some form of ID or IDREF
 :
 : @return nodes element containing distinct nodes of graph
 :)
declare function local:get-nodes($nodes as item()*) as element(gexf:nodes) {
    <gexf:nodes>
        {
            for $n in distinct-values($nodes/@active)
            let $id := substring-after($n, '#')
            let $name := $readact-tei/id($id)/tei:persName[@type = 'main'][1]/*/text()
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
                <gexf:edge id="{$count-a || '-' || $count-b}" source="{$e}" target="{substring-after($t/@ref, '#')}"/>
        
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
    <gexf:gexf>
        <gexf:meta lastmodifieddate="{current-dateTime()}">
            <gexf:creator>{$creator}</gexf:creator>
            <gexf:description>{$desc}</gexf:description>
        </gexf:meta>
        <gexf:graph>
            {
                local:get-nodes($data),
                local:get-edges-raw(local:get-nodes($data)//@id, $data)
            }
            <gexf:edges></gexf:edges>
        </gexf:graph>
    </gexf:gexf>
};

local:gexf-to-vega(local:gexf-graph($reading-acts, 'ReadAct', ''))

(:local:gexf-graph($reading-acts, 'ReadAct', ''):)

(:local:get-edges-raw(local:get-nodes($reading-acts)//@id, $reading-acts):)

(:local:get-nodes($reading-acts):)

(:data($reading-acts[@active = '#AG0002']/@ref):)
