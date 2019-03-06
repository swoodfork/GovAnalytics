from entities.Reference import *


class Action:

    def __init__(self, date, text, ref, label):
        self.date = date
        self.text = text

        self.Reference = Reference(ref, label)
