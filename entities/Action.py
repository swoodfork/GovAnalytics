from GovAnalytics.entities.Reference import *


class Action:

    def __init__(self, date, text, ref, label):
        self.date = date
        self.text = text

        self.Reference = Reference(ref, label)

    def get_args(self, bill_id):
        args = [bill_id, self.date, self.text, self.Reference.ref, self.Reference.label, None, None, None, None, None]
        return args

