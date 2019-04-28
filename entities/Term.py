class Term:

    def __init__(self, type, start, end, state, class_code, district, party):
        self.type = type
        self.start = start
        self.end = end
        self.state = state
        self.class_code = class_code
        self.district = district
        self.party = party

    def get_args(self, legislator_id):
        args = [legislator_id, self.type, self.start, self.end, self.state, self.class_code, self.district, self.party]
        return args



