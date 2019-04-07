import os
from glob import glob
import datetime
import xml.etree.ElementTree as eTree
from GovAnalytics.entities import *


def date_formatter(str_date):
    date = str_date[0:10]
    args = date.split('-')
    return datetime.datetime(int(args[0]), int(args[1].lstrip("0")), int(args[2].lstrip("0")))


class XmlProcessor:

    @staticmethod
    def get_member_directory():
        directory = {}
        tree = eTree.parse('MemberDirectory.xml')
        root = tree.getroot()

        for x in root:
            directory[x[0].text] = x[1].text

        return directory

    @staticmethod
    def get_all_bills(path):
        Sponsor.member_directory = XmlProcessor.get_member_directory()

        all_bills = []
        files = [y for x in os.walk(path) for y in glob(os.path.join(x[0], 'data.xml'))]

        for file in files:
            current = XmlProcessor.get_bill(file)
            all_bills.append(current)

        return all_bills

    @staticmethod
    def get_bill(path):
        tree = eTree.parse(path)
        root = tree.getroot()

        bill = Bill(root.attrib["session"], root.attrib["type"], root.attrib["number"],
                    date_formatter(root.attrib["updated"]))

        e_map = {}
        index = 0

        for x in root:
            if x.tag:
                e_map[x.tag] = index
                index += 1

        if e_map.__contains__("titles"):
            for x in root[e_map["titles"]]:
                title_type = x.attrib["type"]
                title_as = ""
                text = x.text
                if x.attrib.__contains__("as"):
                    title_as = x.attrib["as"]
                title = Title(title_type, title_as, text)
                bill.add_title(title)

        if e_map.__contains__("introduced"):
            x = root[e_map["introduced"]]
            introduced = Introduced(x.attrib["datetime"])
            bill.add_introduced(introduced)

        if e_map.__contains__("state"):
            x = root[e_map["state"]]
            state = State(x.text, date_formatter(x.attrib["datetime"]))
            bill.add_state(state)

        if e_map.__contains__("summary"):
            x = root[e_map["summary"]]
            summary = Summary(x.attrib["date"], x.attrib["status"], x.text)
            bill.add_summary(summary)

        if e_map.__contains__("status"):
            for x in root[e_map["status"]]:
                state = x.tag
                date = date_formatter(x.attrib["datetime"])

                status = Status(state, date)
                bill.add_status(status)

        if e_map.__contains__("subjects"):
            for x in root[e_map["subjects"]]:
                subject = Subject(x.attrib["name"])
                bill.add_subject(subject)

        if e_map.__contains__("sponsor"):
            sponsor = Sponsor(root[e_map["sponsor"]].attrib["bioguide_id"])
            bill.add_sponsor(sponsor)

        if e_map.__contains__("cosponsors"):
            for x in root[e_map["cosponsors"]]:
                bio_id = x.attrib["bioguide_id"]
                joined = date_formatter(x.attrib["joined"])
                cosponsor = Cosponsor(bio_id, joined)
                bill.add_cosponsor(cosponsor)

        if e_map.__contains__("actions"):
            for x in root[e_map["actions"]]:
                date = date_formatter(x.attrib["datetime"])
                text = ""
                ref = ""
                label = ""

                if x.tag == "action":
                    for y in x:
                        if y.text:
                            text = y.text
                        if y.attrib:
                            if y.attrib.__contains__("ref"):
                                ref = y.attrib["ref"]
                            if y.attrib.__contains__("label"):
                                label = y.attrib["label"]

                    action = Action(date, text, ref, label)

                if x.tag == "vote":
                    how = x.attrib["how"]
                    type = x.attrib["type"]
                    location = x.attrib["where"]
                    result = x.attrib["result"]
                    state = x.attrib["state"]

                    for y in x:
                        if y.text:
                            text = y.text
                        if y.attrib:
                            if y.attrib.__contains__("ref"):
                                ref = y.attrib["ref"]
                            if y.attrib.__contains__("label"):
                                label = y.attrib["label"]

                    action = Vote(date, text, ref, label, how, type, location, result, state)

                bill.actions.append(action)

        return bill
