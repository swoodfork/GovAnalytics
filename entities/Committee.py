class Committee:

    def __init__(self, committee, committee_id, subcommittee, subcommittee_id):
        self.committee = committee
        self.committee_id = committee_id
        self.subcommittee = subcommittee
        self.subcommittee_id = subcommittee_id

    def get_args(self, bill_id):
        args = [bill_id, self.committee, self.committee_id, self.subcommittee, self.subcommittee_id]
        return args
