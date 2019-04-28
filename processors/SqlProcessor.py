import mysql.connector
from GovAnalytics.crypto.MySqlSessionInfo import MySqlSessionInfo


class SqlProcessor:

    def __init__(self):
        self.__create_database_connection()
        self.cursor = self.database.cursor()

        self.object_name = ""
        self.total_objects = 0
        self.total_processed = 0

        self.total_successful = 0
        self.total_already_processed = 0
        self.total_failures = 0

    def __create_database_connection(self):
        self.database = mysql.connector.connect(
            host=MySqlSessionInfo.HOST,
            user=MySqlSessionInfo.USER,
            passwd=MySqlSessionInfo.PASSWORD,
            database=MySqlSessionInfo.DATABASE
        )

    def execute_procedure(self, procedure, args):
        results = []

        self.cursor.callproc(procedure, args)

        for result in self.cursor.stored_results():
            results.append(result.fetchall())

        if len(results) > 0:
            return results

    def insert_bill(self, bill):
        try:
            result_set = self.execute_procedure('insert_bill', bill.get_args())
            bill_id = result_set[0][0][0]

            self.print_status()

            if bill_id == -1:
                print("Bill Already Processed: " + bill.key_info())
                self.database.commit()
                self.increment(2)
                return

            if bill.state:
                for state in bill.state:
                    self.execute_procedure('insert_state', state.get_args(bill_id))

            if bill.sponsors:
                for sponsor in bill.sponsors:
                    self.execute_procedure('insert_sponsor', sponsor.get_args(bill_id))

            if bill.cosponsors:
                for cosponsor in bill.cosponsors:
                    self.execute_procedure('insert_cosponsor', cosponsor.get_args(bill_id))

            if bill.actions:
                for action in bill.actions:
                    self.execute_procedure('insert_action', action.get_args(bill_id))

            if bill.titles:
                for title in bill.titles:
                    self.execute_procedure('insert_title', title.get_args(bill_id))

            if bill.subjects:
                for subject in bill.subjects:
                    self.execute_procedure('insert_subject', subject.get_args(bill_id))

            if bill.summary:
                for summary in bill.summary:
                    self.execute_procedure('insert_summary', summary.get_args(bill_id))

            if bill.committees:
                for committee in bill.committees:
                    self.execute_procedure('insert_committee', committee.get_args(bill_id))

            self.database.commit()
            self.increment()

        except Exception as e:
            print("Error occurred during mySQL Execution: \n", str(e))
            self.database.rollback()
            bill.preserve_bill_failure()
            self.increment(3)

    def insert_legislator(self, legislator):
        result_set = self.execute_procedure('insert_legislator', legislator.get_args())
        legislator_id = result_set[0][0][0]

        self.print_status()

        if legislator.terms:
            for term in legislator.terms:
                self.execute_procedure('insert_term', term.get_args(legislator_id))

        self.database.commit()
        self.increment()

    def load_counter(self, name, total):
        self.object_name = name
        self.total_objects = total
        self.total_processed = 0
        self.total_successful = 0
        self.total_already_processed = 0
        self.total_failures = 0

    def print_status(self):
        print('Processing {} : {} / {}'.format(self.object_name, self.total_processed + 1, self.total_objects))

    def increment(self, mode=1):
        self.total_processed = self.total_processed + 1
        if mode == 1:
            self.total_successful = self.total_successful + 1
        if mode == 2:
            self.total_already_processed = self.total_already_processed + 1
        if mode == 3:
            self.total_failures = self.total_failures + 1

    def report(self):
        print("\n{} {}(s) were successfully processed. \n{} {}(s) were already processed\n{} {}(s) failed to processed"
              .format(self.total_successful, self.object_name, self.total_already_processed, self.object_name,
                      self.total_failures, self.object_name))
