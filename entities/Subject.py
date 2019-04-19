class Subject:

    def __init__(self, name):
        self.name = name

    def get_args(self, bill_id):
        args = [bill_id, self.name]
        return args
