from GovAnalytics.entities.Sponsor import *


class Cosponsor(Sponsor):

    def __init__(self, bioguide, thomas, govtrack, joined):
        super().__init__(bioguide, thomas, govtrack)
        self.joined = joined

    def get_args(self, bill_id):
        args = [bill_id, self.bioguide, self.thomas, self.govtrack, self.joined]
        return args
