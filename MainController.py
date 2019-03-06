import xml.etree.ElementTree as eTree
from GovAnalytics.entities import *

tree = eTree.parse('Data.xml')
root = tree.getroot()

AllBills = []


print(root.tag)

current = Bill(root.attrib["session"], root.attrib["type"], root.attrib["number"], root.attrib["updated"])


e_map = {}
index = 0






for x in root:
    if x.tag:
        e_map[x.tag] = index
        index += 1
        print(x.tag)

if e_map.__contains__("actions"):
    for x in root[e_map["actions"]]:
        if x.tag == "action":
            text = ""
            ref = ""
            label = ""

            for y in x:
                if y.text:
                    text = y.text
                if y.attrib:
                    ref = y.attrib["ref"]
                    label = y.attrib["label"]

            action = Action(x.attrib["datetime"], text, ref, label)
            current.actions.append(action)
            print(x.tag)

print('\n\n')

