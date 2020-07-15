xquery version "3.1";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace gexf = "http://www.gexf.net/1.3";
declare namespace viz = "http://www.gexf.net/1.3/viz";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

(:~ Library to produce graphs from ReadAct prosopography.
 : @author Duncan Paterson
 : @version 1.1.0-BETA
 : @return either json or xml graph data  for visualization via vega or gephi respectively
 :)
declare variable $readact-tei := doc('../tei_header.xml');
declare variable $reading-acts := $readact-tei//tei:relation[@type = "reading-act"];

(:~
 : take gexf graph representation and return JSON for display via vega,
 : whcih uses D3 force layout under the hood. 
 :
 : @return
 :)
declare function local:gexf-to-json()as map(*){
map { 'nodes': 1+1
}
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
 : @param nodes the list of items to be processed typically uses some form of ID
 :
 : TODO experiment with returning directly contructed  maps and arrays to mimick json
 : TODO get distinct
 : TODO make flexible with respect to primary entity types but based of Acts
 : @return node element
 :)
declare function local:get-nodes($nodes as item()*) as element(nodes) {
    <nodes>
        {
            for $n in distinct-values($nodes/@active)
            let $id := substring-after($n, '#')
            let $name := $readact-tei/id($id)/tei:persName[@type = 'main'][1]/*/text()
            order by $id
            return
                (<id>{$id}</id>, <name>{$name}</name>)
        }
    </nodes>
};

(:~ Construct edges of network
 : @param the result of a node getter function
 : @param the relationship to construct edges
 : @return edges element
 :)
declare function local:get-edges($nodes as item()*, $data as item()*) as element(links){
    <links>
        {
            for $e at $count in $nodes/id
            for $t at $weight in $data[@active = '#' || $e]
            let $value := 1
            order by $e
            return
                (<source>{$e/text()}</source>, <target>{substring-after($t/@ref, '#')}</target> (:, <id>{$count}</id>:))
        }
    </links>
};

(:~ Construct a full graph based on node and edge contructing function
 :@param paramater the contents of gexf:meta
 : @return gexf element to stored to disk
 :)
declare function local:gexf-graph($param as node()*) as element(gexf:gexf) {
    <gexf:gexf>
        <gexf:meta></gexf:meta>
        <gexf:graph>
            <gexf:nodes></gexf:nodes>
            <gexf:edges></gexf:edges>
        </gexf:graph>
    </gexf:gexf>
};

local:get-edges(local:get-nodes($reading-acts), $reading-acts)

(:data($reading-acts[@active = '#AG0002']/@ref):)
