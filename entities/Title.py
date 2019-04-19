class Title:

    def __init__(self, type, title_as, text):
        self.type = type
        self.title_as = title_as
        self.text = text

    def get_args(self, bill_id):
        args = [bill_id, self.type, self.title_as, self.text]
        return args
