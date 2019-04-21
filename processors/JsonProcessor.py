import os
import datetime
import json
from glob import glob
from GovAnalytics.processors.XmlProcessor import XmlProcessor
from GovAnalytics.entities import *


def date_formatter(str_date):
    date = str_date[0:10]
    args = date.split('-')
    return datetime.datetime(int(args[0]), int(args[1].lstrip("0")), int(args[2].lstrip("0")))


class JsonProcessor:

    @staticmethod
    def get_all_bills(path):
        Sponsor.member_directory = XmlProcessor.get_member_directory()

        all_bills = []

        files = [y for x in os.walk(path) for y in glob(os.path.join(x[0], 'data.json'))]

        for file in files:
            current = JsonProcessor.get_bill(file)
            all_bills.append(current)

        return all_bills

    @staticmethod
    def get_bill(path):

        with open(path) as f:
            data = json.load(f)

        bill = Bill(data['congress'], data['bill_type'], data['number'], date_formatter(data['updated_at']), path)

        if data.__contains__('status') and data.__contains__('status_at'):
            state = State(data['status'], date_formatter(data['status_at']))
            bill.add_state(state)

        if data.__contains__('sponsor'):
            x = data['sponsor']
            if x.__contains__('bioguide_id'):
                sponsor = Sponsor(x['bioguide_id'])
                bill.add_sponsor(sponsor)

        if data.__contains__('cosponsors'):
            for x in data['cosponsors']:
                joined = ''

                if x.__contains__("sponsored_at"):
                    joined = date_formatter(x['sponsored_at'])

                if x.__contains__('bioguide_id'):
                    cosponsor = Cosponsor(bio_id=x['bioguide_id'], joined=joined)
                    bill.add_cosponsor(cosponsor)
                elif x.__contains__('thomas_id_temp'):
                    thomas_id = x['thomas_id_temp']

        if data.__contains__('subjects'):
            for x in data['subjects']:
                subject = Subject(x)
                bill.add_subject(subject)

        if data.__contains__('titles'):
            for x in data['titles']:
                type = ""
                title_as = ""
                text = ""

                if x.__contains__('title'):
                    text = x['title']
                if x.__contains__('type'):
                    type = x['type']
                if x.__contains__('as'):
                    title_as = x['as']

                title = Title(type, title_as, text)
                bill.add_title(title)

        if data.__contains__('actions'):
            for x in data['actions']:
                date = date_formatter(x["acted_at"])
                text = ""
                ref = ""
                label = ""
                if x.__contains__('text'):
                    text = x['text']
                if x.__contains__('references'):
                    if len(x['references']) > 0:
                        ref = x['references'][0]['reference']
                        label = x['references'][0]['type']

                if x['type'] != 'vote':
                    action = Action(date, text, ref, label)
                elif x['type'] == 'vote':
                    how = ''
                    type = ''
                    location = ''
                    result = ''
                    state = ''

                    if x.__contains__('how'):
                        how = x['how']
                    if x.__contains__('type'):
                        type = x['type']
                    if x.__contains__('where'):
                        location = x['where']
                    if x.__contains__('result'):
                        result = x['result']
                    if x.__contains__('status'):
                        state = x['status']

                    action = Vote(date, text, ref, label, how, type, location, result, state)

                bill.add_action(action)

        if data.__contains__('summary'):
            x = data['summary']
            if x and x['date']:
                date = date_formatter(x['date'])
                status = ''
                text = ''
                if x.__contains__('as'):
                    status = x['as']
                if x.__contains__('text'):
                    text = x['text']
                summary = Summary(date, status, text)
                bill.add_summary(summary)

        print("Extracting bill:  " + bill.key_info())

        return bill
