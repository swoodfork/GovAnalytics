class Legislator:

    def __init__(self, bioguide, govtrack, thomas, icpsr, house_history, first, middle, last, birthday, gender):
        self.bioguide = bioguide
        self.thomas = thomas
        self.govtrack = govtrack
        self.icpsr = icpsr
        self.house_history = house_history
        self.first = first
        self.middle = middle
        self.last = last
        self.birthday = birthday
        self.gender = gender

        self.terms = []

    def get_args(self):
        args = [self.bioguide, self.thomas, self.govtrack, self.icpsr, self.house_history, self.first,
                self.middle, self.last, self.birthday, self.gender]
        return args

    def add_term(self, value):
        self.terms.append(value)

    def key_info(self):
        return 'Bioguide ID: {} -- Thomas ID: {} -- Govtrack ID: {}\n'\
            .format(self.bioguide, self.thomas, self.govtrack)
