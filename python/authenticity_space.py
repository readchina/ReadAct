"""
This is a python script to check authenticity of Named Entities in /Readact/csv/data and in SCB.
- Space.csv 11.06.2021
- Next: Person.csv
-

"""

import csv
import os
import requests
import time
from wikibaseintegrator import wbi_core
from wikidataintegrator import wdi_core


def read_space_csv(filename="Space.csv"):
    """
    A function to read "Space.csv" for now.
    :param filename: "Space.csv" for now
    :return: a dictionary of coordinate locations
    """
    dirname = os.path.dirname(__file__)
    filename = os.path.join(dirname, "../csv/data/" + filename)
    print(filename)
    with open(filename) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        next(csv_reader, None)
        geo_code_dict = {}
        for row in csv_reader:
            if row[3] != "L" and row[0] != "SP0436":
                # consider the case that if there are identical space_names in csv file
                if row[0] not in geo_code_dict:
                    # key: string: unique space_id
                    # value: list: space_name, lat, lang
                    geo_code_dict[row[0]] = [row[2], row[5], row[6]]
                else:
                    print("Space id not exist ?!")
        return geo_code_dict


def compare_to_openstreetmap(geo_code_dict):
    """
    A function to use the lat/lon from CSV file as lookup, to see if space_name is part of the returned message
    :param dictionary_value: tuple: space_name, lat, lon
    :return: None if match, a string message if not match
    """
    no_match_list = []
    for k, v in geo_code_dict.items():
        lat = v[1]
        lon = v[2]
        url = "https://nominatim.openstreetmap.org/reverse?format=xml&lat=" + lat + "&lon=" + lon + \
              "&zoom=18&addressdetails=1&format=json&accept-language=en"
        data = requests.get(url)
        # print(data.json())
        if v[0].lower() not in str(data.json()).lower():
            no_match_list.append(v)
    return no_match_list


def geo_code_compare(no_match_list):
    """
    For geo locations in Space.csv, compare latitude/longitude for matching via retrieve data from wikidata.
    :param geo_code_dict: key: unique (lat,long) tuples; value: space_name in csv
    :return: None or list of entries which can't match
    """
    still_no_match_list = []
    break_out_flag = False
    for i in no_match_list:
        print("==============")
        print("Item: ", i)
        q_ids = _get_q_ids(i[0])
        print("q_ids:", q_ids)
        # if no q_ids, collect item into list, break current loop
        if q_ids is None:
            still_no_match_list.append(i)
        else:
            coordinate_list = _get_coordinate_from_wikidata(q_ids)
            print("coordinate_list: ", coordinate_list)
            # if no coordinate_list, collect item into list, break nested loop
            if coordinate_list is None:
                still_no_match_list.append(i)
                break
            for i_wiki in coordinate_list:
                print("i_wiki: ", i_wiki)

                # If the difference are within +-0.9, consider a match, no collection, break nested loop
                if (float(i_wiki[0]) - 0.9 <= float(i[1]) <= float(i_wiki[0]) + 0.9) and \
                        (float(i_wiki[1]) - 0.9 <= float(i[2]) <= float(i_wiki[1]) + 0.9):
                    i = ""
                    break
            if len(i) > 0:
                still_no_match_list.append(i)
        print("----still_no_match_list: ", still_no_match_list)

    if len(still_no_match_list) != 0:
        return still_no_match_list


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


def _get_coordinate_from_wikidata(q_ids):
    """
    A function to extract coordinate location(if exists) of a wikidata entity
    :param qname: a list of Qname
    :return: a list with tuples, each tuple is a (lat, long) combination
    """
    coordinate_list = []
    if q_ids is None:
        return None
    for q in q_ids:
        wdi = wdi_core.WDItemEngine(wd_item_id=q)
        # to check successful installation and retrieval of the data, one can print the json representation of the item
        data = wdi.get_wd_json_representation()

        if "P625" in data["claims"]:
            # Iteration, in case one wikidata entity has several coordinate entries.
            for element in data["claims"]["P625"]:
                coordinate_value = element['mainsnak']['datavalue']['value']
                # print("===========")
                # print("q: ", q)
                # print(coordinate_value)
                coordinate_list.append((coordinate_value['latitude'], coordinate_value['longitude']))
    return coordinate_list


if __name__ == "__main__":
    # To compare the extracting coordinate location with the info in Space.csv
    geo_code_dict = read_space_csv("Space.csv")

    # To filter CSV entries with comparing to openstreetmap first
    no_match_list = compare_to_openstreetmap(geo_code_dict)

    # To compare the rest with wikidata info
    still_no_match_list = geo_code_compare(no_match_list)

    print("still_no_match_list: ", still_no_match_list)

    # still_no_match_list = [['Bolshoy Fontan', '46.482526', '30.72331'], ['Vonu', '40.141308', '19.692947'], ['Beidahuang', '45.73722', '126.692441'], ['Jinjiang (Fujian)', '24.781681', '118.552365'], ['Gobi Desert', '42.795154', '105.032363'], ['Huangbei', '29.758889', '118.534167'], ['Yizhen', '34.203246', '108.945896'], ['Xixian', '32.342792', '114.740456'], ['Shanghexi', '39.4065', '112.9054'], ['Zhongxian', '30.355948', '107.83845'], ['Suibin Nongchang', '47.523305', '131.69029'], ['Fengshan', '41.208899', '116.645932'], ['Osino-Gay', '53.037391', '42.402225'], ['Zhanhai', '29.95481', '121.70961'], ['Xiangchuan', '28.515646', '112.134533'], ['Hannibal', '36.151664', '-95.991926'], ['Groot-Zundert', '51.469834', '4.654992'], ['Zima (Siberia)', '53.922585', '102.042387'], ['Strelkovka', '55.002389', '36731'], ['Gudalovka', '49.307427', '19.937017'], ['Albany NY', '42.652579', '-73.756232'], ['Jiangxi Province', '27.285970', '116.016090'], ['Chicago', '41.8781', '87.6298'], ['Salinas', '36.6777', '121.6555'], ['Friend', '40.6536', '97.2862'], ['Marbach am Necker', '48.9396', '9.2646'], ['Milan (OH)', '41.293333', '-82.601389'], ['Chuansha Xian', '31.301395', '121.516652'], ['Sichuan Second Prison', '29.58921', '106.538559'], ['Laoting', '22.887780', '120.463560'], ['Shuiyuan county', '23.849670', '110.400830'], ['Hubei', '37.59857', '114.60758'], ['Banzai', '25.924480', '118.278990'], ['Wanzai', '22.913870', '120.335380'], ['Rugao', '22.740240', '120.490420'], ['Коsа (Kosinsky District)', '59.945370', '54.991870'], ['Pucheng (Shaanxi)', '34.957000', '109.580000'], ['Lliulin (Shanxi)', '37.430833', '110.889167'], ['Xiaxian', '35.138333', '111.220833'], ['Sora (Lazio)', '41.716670', '13.617600'], ['Jiner', '31.615300', '107.654000']]
