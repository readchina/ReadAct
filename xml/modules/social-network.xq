xquery version "3.1";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace gexf = "http://www.gexf.net/1.3";
declare namespace viz = "http://www.gexf.net/1.3/viz";

declare function local:agent-work() as element(gexf:gexf) {
    <gexf:gexf>
        <gexf:meta></gexf:meta>
        <gexf:graph>
            <gexf:nodes></gexf:nodes>
            <gexf:edges></gexf:edges>
        </gexf:graph>
    </gexf:gexf>
};

local:agent-work()
