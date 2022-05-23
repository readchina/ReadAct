xquery version "3.1";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace gexf = "http://gexf.net/1.3";
declare namespace viz = "http://gexf.net/1.3/viz";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:omit-xml-declaration "yes";

(:~ Library to produce vega compatile json from gexf graphs for ReadAct website.
 : @see social-network.xq
 : @see https://vega.github.io/editor/#/examples/vega/force-directed-layout
 :
 : @author Duncan Paterson
 : @version 1.1.0-BETA
 : @return  json for visualization via vega
 :)

 declare variable $rActs := doc('../rActs.gexf');

 (:~
  : Take gexf graph representation and return JSON for display via vega,
  : which uses D3 force layout under the hood. However, it insists on json index as node identity
  : for constructing edges which is a pain, and needs to be xml count or position -1.
  : @see
  : @see https://raw.githubusercontent.com/vega/vega/master/docs/data/miserables.json
  : @param graph gexf formated graph
  :
  : TODO weight is not yet parsed or generated
  : @return json representation of graph
  :)
 declare function local:gexf-to-vega($graph as node()) {
     let $g :=
     <map xmlns="http://www.w3.org/2005/xpath-functions">
         <array key="nodes">
             {
                 for $n at $count in $graph//gexf:node
                 return
                     <map>
                         <string key="id">{data($n/@id)}</string>
                         <string key="name">{replace(data($n/@label), ' ', '_')}</string>
                         <number key="index">{$count - 1}</number>
                         <number key="group">{
                                 if (starts-with(data($n/@id), 'AG')) then
                                     (1)
                                 else
                                     (2)
                             }</number>
                     </map>
             }
         </array>
         <array key="links">
             {
                 for $e at $count in $graph//gexf:edge
                 let $i1 := index-of($graph//gexf:node/@id, data($e/@source))
                 let $i2 := index-of($graph//gexf:node/@id, data($e/@target))
                 return
                     <map>
                         <number key="source">{$i1 - 1}</number>
                         <number key="target">{$i2 - 1}</number>
                         <number key="value">1</number>
                         <number key="index">{$count - 1}</number>
                     </map>
             }
         </array>
     </map>
     return
         xml-to-json($g)
 };

 local:gexf-to-vega($rActs)
