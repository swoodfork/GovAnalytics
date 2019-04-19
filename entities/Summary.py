class Summary:

    def __init__(self, date, status, text):
        self.date = date
        self.status = status
        self.text = text

    def get_args(self, bill_id):
        args = [bill_id, self.date, self.status, self.text]
        return args
