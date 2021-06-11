"""
This is a python script to check authenticity of Named Entities in /Readact/csv/data and in SCB.
- Space.csv 11.06.2021
- Next: Person.csv
-

"""
import csv
import requests
import time
from wikibaseintegrator import wbi_core
from wikidataintegrator import wdi_core


def search_wikidata_id_by_wikibaseintegrator(lookup=None):
    """
    A function to search qnames in wikidata with a lookup string.
    :param lookup: a string
    :return: a list of qname (the top 5)
    """
    e = wbi_core.FunctionsEngine()
    instance = e.get_search_results(search_string=lookup,
                                    search_type='item',
                                    max_results=5)
    if len(instance) > 1:
        return instance[0:5]
    else:
        return "Not in database"


def get_coordinate_from_wikidata(qname):
    """
    A function to extract coordinate location(if exists) of a wikidata entity
    :param qname: a list of Qname
    :return: a list with tuples, each tuple is a (lat, long) combination
    """
    coordinate_list = []
    for q in qname:
        wdi = wdi_core.WDItemEngine(wd_item_id=q)
        # to check successful installation and retrieval of the data, you can print the json representation of the item
        data = wdi.get_wd_json_representation()

        if "P625" in data["claims"]:
            print(q, ":\n", data["claims"]["P625"][0]['mainsnak']['datavalue']['value'])
            coordinate_value = data["claims"]["P625"][0]['mainsnak']['datavalue']['value']
            coordinate_list.append((coordinate_value['latitude'], coordinate_value['longitude'])) # P625 is

    return coordinate_list


def read_space_csv(filename="Space.csv"):
    """
    A function to read "Space.csv" for now.
    :param filename: "Space.csv" for now
    :return: a dictionary of coordinate locations
    """
    with open("./data/" + filename) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        next(csv_reader, None)
        geo_code = {}
        for row in csv_reader:
            if row[3] != "L":
                geo_code[(row[5], row[6])] = row[2] # key: lat/long pairs as a tuple; value: space_name in csv
        return geo_code


def geo_code_validation(geo_code_dict):
    """
    For geo locations in Space.csv, compare latitude/longitude for matching.
    :param geo_code_dict: key: unique (lat,long) tuples; value: space_name in csv
    :return: boolean: True or False
    """
    for index, key in enumerate(geo_code_dict.keys()):
        if index == 2:
            break
        pass


if __name__ == "__main__":
    qname = search_wikidata_id_by_wikibaseintegrator("China") # A list
    print(qname)
    print(get_coordinate_from_wikidata(qname))

    # To compare the extracting coordinate location with the info in Space.csv
    geo_code_dict = read_space_csv("Space.csv")
    # geo_code_validation(geo_code_dict)
