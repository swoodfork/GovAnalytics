import sys
import mysql.connector
from GovAnalytics.crypto.MySqlSessionInfo import MySqlSessionInfo


class SqlProcessor:

    def __init__(self):
        self.__create_database_connection()
        self.cursor = self.database.cursor()

    def __create_database_connection(self):
        self.database = mysql.connector.connect(
            host=MySqlSessionInfo.HOST,
            user=MySqlSessionInfo.USER,
            passwd=MySqlSessionInfo.PASSWORD,
            database=MySqlSessionInfo.DATABASE
        )

    def execute_procedure(self, procedure, args):
        results = []

        try:
            self.cursor.callproc(procedure, args)

            for result in self.cursor.stored_results():
                results.append(result.fetchall())

        except:
            print("Error occurred during mySQL Execution: ", sys.exc_info[0])

        if len(results) > 0:
            return results

    def insert_bill(self, bill):
        result_set = self.execute_procedure('insert_bill', bill.get_args())
        bill_id = result_set[0][0][0]

        print(bill.key_info())

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

        self.database.commit()
