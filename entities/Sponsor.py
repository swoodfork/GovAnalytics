class Sponsor:

    def __init__(self, bioguide, thomas, govtrack):
        self.bioguide = bioguide
        self.thomas = thomas
        self.govtrack = govtrack

    def get_args(self, bill_id):
        args = [bill_id, self.bioguide, self.thomas, self.govtrack]
        return args
