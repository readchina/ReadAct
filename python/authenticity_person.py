import csv
import os
from SPARQLWrapper import SPARQLWrapper, JSON
import requests
import time
from wikibaseintegrator import wbi_core
from wikidataintegrator import wdi_core


def read_person_csv(filename="Person.csv"):
    """
    A function to read "Person.csv".
    :param filename: "Person.csv".
    :return: a dictionary: key: unique person_id; value: [family_name,first_name,name_lang,sex,birthyear,deathyear]
    "name_lang" is used to decide if white space needs to be added into name or not.
    """
    dirname = os.path.dirname(__file__)
    filename = os.path.join(dirname, "../csv/data/" + filename)
    # print(filename)
    with open(filename) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        next(csv_reader, None)
        person_dict = {}
        for row in csv_reader:
            if (row[0], row[3]) not in person_dict:
                # key: string:  (person_id, name_lang)
                # value: list: [family_name,first_name,sex,birthyear,deathyear]
                person_dict[(row[0], row[3])] = [row[1], row[2], row[4], row[6], row[7]]
            else:
                print("Probably something wrong")

    # print(person_dict)
    return person_dict


def compare(person_dict):
    no_match_list = []
    for k, v in person_dict.items():
        print("==============")
        print("key: ", k)
        print("value: ", v)
        if k[1] != "zh":
            name = v[0] + " " + v[1]
        else:
            name = v[0] + v[1]
        print("name: ", name)
        q_ids = _get_q_ids(name)
        print("q_ids:", q_ids)
    return q_ids
    #     # if no q_ids, collect item into list, break current loop
    #     if q_ids is None:
    #         no_match_list.append({k:v})
    #     else:
    #
    #
    # if len(still_no_match_list) != 0:
    #     return still_no_match_list


def _sparql(q_ids=None):
    q_ids1 = ['Q23114', 'Q378492', 'Q28412108', 'Q45679993', 'Q24863687', 'Q45388421', 'Q45552396', 'Q45579967',
              'Q45517806', 'Q45586359']
    q_ids2 = ['Q23114', 'Q474956', 'Q62888982', 'Q62885771', 'Q1142220', 'Q62882273', 'Q62880800', 'Q23170',
              'Q17004219', 'Q5930913']
    q_ids = q_ids1
    if q_ids is None:
        return None
    for index, q in enumerate(q_ids):
        # print("--------------")
        # print("q", index, ": ", q)

        # Todo: This query has problems.
        # Can try birthyear
        # date of birth (P569)
        # date of death (P570)
        # sex or gender (P21)
        # male (Q6581097)
        # female (Q6581072)

        q = "Q23114"  # Lu Xun
        queryString = """PREFIX  schema: <http://schema.org/>
        PREFIX  bd:   <http://www.bigdata.com/rdf#>
        PREFIX  wdt:  <http://www.wikidata.org/prop/direct/>
        PREFIX  wikibase: <http://wikiba.se/ontology#>
        
        SELECT DISTINCT  ?item ?itemLabel (SAMPLE(?date_of_birth) AS ?date_of_birth) (SAMPLE(?date_of_death) AS 
        ?date_of_death) 
        (SAMPLE(?gender) AS ?gender) (SAMPLE(?article) AS ?article)
        WHERE
          { ?article  schema:about       ?item ;
                      schema:inLanguage  "en" ;
                      schema:isPartOf    <https://en.wikipedia.org/>
            FILTER ( ?item = <http://www.wikidata.org/entity/""" + q + """> )
            OPTIONAL
              { ?item  wdt:P569  ?date_of_birth }
            OPTIONAL
              { ?item  wdt:P570  ?date_of_death }
            OPTIONAL
              { ?item  wdt:P21  ?gender }
            SERVICE wikibase:label
              { bd:serviceParam wikibase:language  "en"
              }
          }
        GROUP BY ?item ?itemLabel 
        """
        # print("query: ", queryString)

        sparql = SPARQLWrapper("https://query.wikidata.org/sparql")

        sparql.setQuery(queryString)

        sparql.setReturnFormat(JSON)
        results = sparql.query().convert()
        print(results)
        break


def _get_q_ids(lookup=None):
    """
    A function to search qnames in wikidata with a lookup string.
    :param lookup: a string
    :return: a list of item identifiers (first 10)
    """
    e = wbi_core.FunctionsEngine()
    instance = e.get_search_results(search_string=lookup,
                                    search_type='item')

    if len(instance) > 0:
        return instance[0:10]
    else:
        print("Lookup not in database")
        return None


# def get_wikidata_qnumber_with_parsing_wikipedia_page(lookup=None):
#     """
#     A function to search for the wikidata id by parsing the page with request.
#     :param lookup: The entity we want to search for, like a person name or an organization name
#     :return: a string which has the pattern combined by letter "Q" and digits
#     """
#     params = {
#         'action': 'parse',
#         'page': lookup,
#         'prop': 'text',
#         'formatversion': 2
#     }
#     # Only works for English now
#     # TODO for Chinese???
#     r = requests.get("https://en.wikipedia.org/w/api.php", params=params)
#     data = r.text
#
#     # Can also use regex to search for all the urls with a certain pattern directly
#     wikidata_url = 'https://www.wikidata.org/wiki/'
#     if data.find(wikidata_url) != -1:
#         idx = data.index(wikidata_url) + 30
#         result = re.match(r'Q[0-9]+', data[idx:idx + 20]).group()
#         return result

# # Not very useful, since mostly works for English data
# def try_mediawiki_api(person_dict):
#     base_url1 = "https://en.wikipedia.org/w/api.php?action=query&prop=pageprops&titles="
#     base_url2 = "&format=json"
#     for k, v in person_dict.items():
#         print("k: ", k)
#         print("v: ", v)
#         if k[1] == "zh":
#             url = base_url1 + v[0] + v[1] + base_url2
#             print("url: ", url)
#             data = requests.get(url)
#             print(data.json())
#         else:
#             # url = base_url1 + v[0] + "_" + v[1] + base_url2
#             # data = requests.get(url)
#             # print(data.json())
#             pass


if __name__ == "__main__":
    # person_dict = read_person_csv("Person.csv")
    # # print(person_dict)
    # sample_dict = {('AG0001', 'en'): person_dict[('AG0001', 'en')], ('AG0001', 'zh'): ['鲁', '迅', 'male', '1881',
    # '1936']}
    # print("sample_dict: ", sample_dict)
    # q_ids = compare(sample_dict)

    _sparql()
