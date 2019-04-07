class State:

    def __init__(self, text, date):
        self.text = text
        self.date = date

    def get_args(self, bill_id):
        args = [bill_id, self.text, self.date]
        return args
