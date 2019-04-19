from GovAnalytics.processors.JsonProcessor import JsonProcessor
from GovAnalytics.processors.SqlProcessor import SqlProcessor


path = "D:\CongressData"

processor = SqlProcessor()

all_bills = JsonProcessor.get_all_bills(path)

for bill in all_bills:
    processor.insert_bill(bill)

print("Total Number of Bills Processed: " + str(len(all_bills)))
