from GovAnalytics.entities.Action import Action


class Vote(Action):

    def __init__(self, date, text, ref, label, how, type, location, result, state):
        super().__init__(date, text, ref, label)

        self.how = how
        self.type = type
        self.location = location
        self.result = result
        self.state = state

    def get_args(self, bill_id):
        args = [bill_id, self.date, self.text, self.Reference.ref, self.Reference.label, self.how, self.type,
                self.location, self.result, self.state]
        return args
