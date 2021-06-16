import csv
import os
import re

import requests
import time
from wikibaseintegrator import wbi_core
from wikidataintegrator import wdi_core


def read_person_csv(filename="Person.csv"):
    """
    A function to read "Person.csv".
    :param filename: "Person.csv".
    :return: a dictionary: key: unique person_id; value: [family_name,first_name,name_lang,sex,birthyear,deathyear]
    """
    dirname = os.path.dirname(__file__)
    filename = os.path.join(dirname, "../csv/data/" + filename)
    # print(filename)
    with open(filename) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        next(csv_reader, None)
        person_dict = {}
        for row in csv_reader:
            if (row[0],row[3]) not in person_dict:
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
        print("k: ", k)
        print("v: ", v)
        if k[1] != "zh":
            name = v[0] + " " + v[1]
        else:
            name = v[0] + v[1]
        q_ids = _get_q_ids(name)
        print("q_ids:", q_ids)
    #     # if no q_ids, collect item into list, break current loop
    #     if q_ids is None:
    #         no_match_list.append({k:v})
    #     else:
    #
    #
    # if len(still_no_match_list) != 0:
    #     return still_no_match_list


def _sparql(q_ids):
    q_ids = ['Q23114', 'Q378492', 'Q28412108', 'Q45679993', 'Q24863687', 'Q45388421', 'Q45552396', 'Q45579967', 'Q45517806', 'Q45586359', 'Q2211703', 'Q45436521', 'Q45565172', 'Q45599926', 'Q45589464', 'Q45379181', 'Q45594918', 'Q45441460', 'Q50819173', 'Q45646922', 'Q45577309', 'Q45563201', 'Q45540008', 'Q45427450', 'Q45550086', 'Q45543185', 'Q45554089', 'Q45552955', 'Q45562435', 'Q45542482', 'Q45624522', 'Q45450814', 'Q45514822', 'Q45452257', 'Q45544990', 'Q65824042', 'Q103953114', 'Q65903597', 'Q65863354', 'Q45537860', 'Q45706291', 'Q65914218', 'Q45637521', 'Q45532757', 'Q65819581', 'Q474956', 'Q62888982', 'Q62885771', 'Q1142220', 'Q62882273', 'Q62880800', 'Q23170', 'Q17004219', 'Q62884472', 'Q26186343', 'Q62883649', 'Q62888098', 'Q1057710', 'Q11173165', 'Q6694923', 'Q23180', 'Q101429457', 'Q45491481', 'Q45602289', 'Q45619057', 'Q45709149', 'Q11986887', 'Q48440974', 'Q65883079', 'Q15752623', 'Q28019826', 'Q63770629']
    if q_ids is None:
        return None
    for q in q_ids:
        print("--------------")
        print("q: ", q)

        # Todo: This query has problems.
        # Can try birthyear
        # date of birth (P569)
        # date of death (P570)
        # sex or gender (P21)
        # male (Q6581097)
        # female (Q6581072)

        q = "Q23114" # Lu Xun
        query="""SELECT ?person ?personLabel WHERE{
              ?person wdt:P569 wd:Q23114;
              wdt:P570 wd:Q23114;
              wdt:P21 wd:Q23114.
              SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE]". } 
            }
            """
        print("query: ", query)

        result = wdi_core.WDItemEngine.execute_sparql_query(query, endpoint="https://query.wikidata.org/sparql")
        return result

"""
#title:counts of century of birth for P9114 people 
select ?century (count(?item) as ?count) WHERE {
  ?item wdt:P9114 ?id .
  ?item wdt:P569 ?birth .
  bind(year(?birth)-1 as ?year)
  filter(bound(?year))
  bind (floor(?year/100) as ?century)
} group by ?century order by ?century
"""




# def sparqlpandas(query, endpoint):
#     return wdi_core.WDItemEngine.execute_sparql_query(query, endpoint="https://query.wikidata.org/sparql", as_dataframe=True)


def _get_q_ids(lookup=None):
    """
    A function to search qnames in wikidata with a lookup string.
    :param lookup: a string
    :return: a list of item identifiers (all)
    """
    e = wbi_core.FunctionsEngine()
    instance = e.get_search_results(search_string=lookup,
                                    search_type='item')

    if len(instance) > 0:
        # Speed up with less accuracy, use:
        # return instance[0:10]
        return instance
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
    #
    # # try_mediawiki_api(person_dict)
    # compare(person_dict)
    _sparql(q_ids=None)
