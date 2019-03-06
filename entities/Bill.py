class Bill:

    BILL_TYPES = {"hconres": "House Concurrent Resolution",
                  "hjres": "House Joint Resolution",
                  "hr": "House Bill",
                  "hres": "House Simple Resolution",
                  "s": "Senate Bill",
                  "sconres": "Senate Concurrent Resolution",
                  "sjres": "Senate Joint Resolution",
                  "sres": "Senate Simple Resolution"}

    def __init__(self, session, bill_type, number, updated):
        self.session = session
        self.bill_type = bill_type
        self.number = number
        self.updated = updated

        self.state = []
        self.status = []
        self.introduced = []
        self.titles = []
        self.sponsors = []
        self.cosponsors = []
        self.actions = []
        self.committees = []
        self.related_bills = []
        self.subjects = []
        self.amendments = []
        self.summary = []
        self.committee_reports = []

    def add_state(self, value):
        self.state.append(value)

    def add_status(self, value):
        self.status.append(value)

    def add_introduced(self, value):
        self.introduced.append(value)

    def add_title(self, value):
        self.titles.append(value)

    def add_sponsor(self, value):
        self.sponsors.append(value)

    def add_cosponsor(self, value):
        self.cosponsors.append(value)

    def add_action(self, value):
        self.actions.append(value)

    def add_committee(self, value):
        self.committees.append(value)

    def add_related_bill(self, value):
        self.related_bills.append(value)

    def add_subject(self, value):
        self.subjects.append(value)

    def add_amendment(self, value):
        self.amendments.append(value)

    def add_summary(self, value):
        self.summary.append(value)

    def add_committee_report(self, value):
        self.committee_reports.append(value)
