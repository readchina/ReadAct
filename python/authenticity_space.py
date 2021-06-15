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


def get_wikidata_id_by_wikibaseintegrator(lookup=None):
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
        print("Not in database")
        return None


def get_coordinate_from_wikidata(qname):
    """
    A function to extract coordinate location(if exists) of a wikidata entity
    :param qname: a list of Qname
    :return: a list with tuples, each tuple is a (lat, long) combination
    """
    coordinate_list = []
    if qname is None:
        # print("qname is None")
        return coordinate_list
    for q in qname:
        wdi = wdi_core.WDItemEngine(wd_item_id=q)
        # to check successful installation and retrieval of the data, you can print the json representation of the item
        data = wdi.get_wd_json_representation()

        if "P625" in data["claims"]:
            # print(q, ":\n", data["claims"]["P625"][0]['mainsnak']['datavalue']['value'])
            coordinate_value = data["claims"]["P625"][0]['mainsnak']['datavalue']['value']
            coordinate_list.append((coordinate_value['latitude'], coordinate_value['longitude']))
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
        geo_code_dict = {}
        for row in csv_reader:
            if row[3] != "L":
                # TODO consider the case that if there are identical space_names in csv file
                geo_code_dict[row[2]] = (row[5], row[6]) # value: lat/long pairs as a tuple; key: space_name in csv
        return geo_code_dict


def geo_code_compare(geo_code_dict):
    """
    For geo locations in Space.csv, compare latitude/longitude for matching.
    :param geo_code_dict: key: unique (lat,long) tuples; value: space_name in csv
    :return: boolean: True or False
    """
    count = 0
    problematic_entries ={}
    print("----------------------")
    for key, value in geo_code_dict.items():
        # count += 1
        # if count == 3:
        #     break
        qname = get_wikidata_id_by_wikibaseintegrator(key)
        if qname is not None:
            coordinate_list = get_coordinate_from_wikidata(qname)

            print(key + "'s coordinate_list: ", coordinate_list)
            for item in coordinate_list:
                if (float(item[0])-0.9 <= float(value[0]) <= float(item[0]) + 0.9) and (float(item[1])-0.9 <= float(
                        value[1]) <= float(item[1]) + 0.9):
                    print("a success")
                    print("--", item, "\n", "--", value)
                    break
                else:
                    problematic_entries[key] = value
        else:
            print(key)
            print("Space name does not existed in wikidata")
            problematic_entries[key] = value

    if len(problematic_entries) == 0:
        print("All geo coordinates match the space name.")
        return
    else:
        print("problematic_entries: ", problematic_entries)
        return problematic_entries


if __name__ == "__main__":
    # To compare the extracting coordinate location with the info in Space.csv
    geo_code_dict = read_space_csv("Space.csv")
    # print("geo_code_dict: ", geo_code_dict)
    geo_code_compare(geo_code_dict)
    # qname = get_wikidata_id_by_wikibaseintegrator("Bolshoy Fontan")
    # print(qname)
    # print(get_coordinate_from_wikidata(qname))
