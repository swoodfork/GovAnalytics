from entities.Action import *


class Vote(Action):

    def __init__(self, date, text, ref, label, how, type, where, result, state):
        super(date, text, ref, label)
        # super().__init__(date, text ,ref, label)

        self.how = how,
        self.type = type,
        self.where = where,
        self.result = result,
        self.state = state
