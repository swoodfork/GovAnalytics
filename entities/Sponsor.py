class Sponsor:

    member_directory = {}

    def __init__(self, bio_id):

        member = Sponsor.member_directory.get(bio_id)

        x = member.split('(')
        y = x[1].split('-')
        z = y[1].replace(")", "")

        self.name = x[0].strip()
        self.party = y[0].strip()
        self.state = z.strip()

    def get_args(self, bill_id):
        args = [bill_id, self.name, self.party, self.state]
        return args
