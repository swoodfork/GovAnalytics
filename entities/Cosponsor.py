from GovAnalytics.entities.Sponsor import *


class Cosponsor(Sponsor):

    def __init__(self, bio_id, joined):
        super().__init__(bio_id)

        self.joined = joined

    def get_args(self, bill_id):
        args = [bill_id, self.name, self.party, self.state, self.joined]
        return args
