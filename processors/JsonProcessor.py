import os
import datetime
import json
from glob import glob
from GovAnalytics.entities import *


def date_formatter(str_date):
    date = str_date[0:10]
    args = date.split('-')
    return datetime.datetime(int(args[0]), int(args[1].lstrip("0")), int(args[2].lstrip("0")))


class JsonProcessor:

    @staticmethod
    def get_all_bills(path):

        all_bills = []

        files = [y for x in os.walk(path) for y in glob(os.path.join(x[0], 'data.json'))]

        for file in files:
            current = JsonProcessor.get_bill(file)
            all_bills.append(current)

        return all_bills

    @staticmethod
    def get_all_legislators(path):

        all_legislators = []

        files = [y for x in os.walk(path) for y in glob(os.path.join(x[0], 'legislators.json'))]

        for file in files:
            with open(file, encoding="utf8") as f:
                data = json.load(f)

            for x in data:
                current = JsonProcessor.get_legislator(x)
                all_legislators.append(current)

        return all_legislators

    @staticmethod
    def get_bill(path):

        with open(path) as f:
            data = json.load(f)

        bill = Bill(data['congress'], data['bill_type'], data['number'], date_formatter(data['introduced_at']),
                    date_formatter(data['updated_at']), path)

        if data.__contains__('status') and data.__contains__('status_at'):
            state = State(data['status'], date_formatter(data['status_at']))
            bill.add_state(state)

        if data.__contains__('sponsor'):
            x = data['sponsor']
            if x:
                bioguide = None
                thomas = None
                govtrack = None
                if x.__contains__('bioguide_id'):
                    bioguide = x['bioguide_id']
                if x.__contains__('thomas_id'):
                    thomas = x['thomas_id']
                if x.__contains__('govtrack'):
                    govtrack = x['govtrack']

                sponsor = Sponsor(bioguide, thomas, govtrack)
                bill.add_sponsor(sponsor)

        if data.__contains__('cosponsors'):
            for x in data['cosponsors']:
                bioguide = None
                thomas = None
                govtrack = None
                joined = None

                if x.__contains__('bioguide_id'):
                    bioguide = x['bioguide_id']
                if x.__contains__('thomas_id'):
                    thomas = x['thomas_id']
                if x.__contains__('govtrack'):
                    govtrack = x['govtrack']
                if x.__contains__("sponsored_at"):
                    joined = date_formatter(x['sponsored_at'])

                cosponsor = Cosponsor(bioguide, thomas, govtrack, joined)
                bill.add_cosponsor(cosponsor)

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
                text = None
                ref = None
                label = None
                how = None
                type = None
                location = None
                result = None
                state = None
                committee = None
                in_committee = None
                subcommittee = None

                if x.__contains__('text'):
                    text = x['text']
                if x.__contains__('references'):
                    if len(x['references']) > 0:
                        ref = x['references'][0]['reference']
                        label = x['references'][0]['type']

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
                if x.__contains__('committee'):
                    committee = x['committee']
                if x.__contains__('in_committee'):
                    in_committee = x['in_committee']
                if x.__contains__('subcommittee'):
                    subcommittee = x['subcommittee']

                action = Action(date, text, ref, label, how, type, location, result, state, committee, in_committee, subcommittee)

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

        if data.__contains__('committees'):
            for x in data['committees']:
                committee = None
                committee_id = None
                subcommittee = None
                subcommittee_id = None
                if x.__contains__('committee'):
                    committee = x['committee']
                if x.__contains__('committee_id'):
                    committee_id = x['committee_id']
                if x.__contains__('subcommittee'):
                    subcommittee = x['subcommittee']
                if x.__contains__('subcommittee_id'):
                    subcommittee_id = x['subcommittee_id']
                committee = Committee(committee, committee_id, subcommittee, subcommittee_id)
                bill.add_committee(committee)

        print("Extracting bill:  " + bill.key_info())

        return bill

    @staticmethod
    def get_legislator(data):
        bioguide = None
        govtrack = None
        thomas = None
        icpsr = None
        house_history = None
        first = None
        middle = None
        last = None
        birthday = None
        gender = None

        if data.__contains__('id'):
            x = data['id']
            if x.__contains__('bioguide'):
                bioguide = x['bioguide']
            if x.__contains__('govtrack'):
                govtrack = x['govtrack']
            if x.__contains__('thomas'):
                thomas = x['thomas']
            if x.__contains__('icpsr'):
                icpsr = x['icpsr']

        if data.__contains__('name'):
            x = data['name']
            if x.__contains__('first'):
                first = x['first']
            if x.__contains__('middle'):
                middle = x['middle']
            if x.__contains__('last'):
                last = x['last']

        if data.__contains__('bio'):
            x = data['bio']
            if x.__contains__('birthday'):
                birthday = date_formatter(x['birthday'])
            if x.__contains__('gender'):
                gender = x['gender']

        legislator = Legislator(bioguide, govtrack, thomas, icpsr, house_history, first, middle, last, birthday, gender)

        if data.__contains__('terms'):
            x = data['terms']
            for y in x:
                term = JsonProcessor.get_term(y)
                legislator.add_term(term)

        return legislator

    @staticmethod
    def get_term(data):
        type = None
        start = None
        end = None
        state = None
        class_code = None
        district = None
        party = None

        if data.__contains__('type'):
            type = data['type']
        if data.__contains__('start'):
            start = date_formatter(data['start'])
        if data.__contains__('end'):
            end = date_formatter(data['end'])
        if data.__contains__('state'):
            state = data['state']
        if data.__contains__('class'):
            class_code = data['class']
        if data.__contains__('party'):
            party = data['party']

        term = Term(type, start, end, state, class_code, district, party)

        return term
