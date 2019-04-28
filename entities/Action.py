from GovAnalytics.entities.Reference import *


class Action:

    def __init__(self, date, text, ref, label, how, type, location, result, state, committee,
                 in_committee, subcommittee):
        self.date = date
        self.text = text
        self.how = how
        self.type = type
        self.location = location
        self.result = result
        self.state = state
        self.committee = committee
        self.in_committee = in_committee
        self.subcommittee = subcommittee

        self.Reference = Reference(ref, label)

    def get_args(self, bill_id):
        args = [bill_id, self.date, self.text, self.Reference.ref, self.Reference.label,
                self.how, self.type, self.location, self.result, self.state, self.committee, self.in_committee,
                self.subcommittee]
        return args

