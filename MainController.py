from GovAnalytics.processors.XmlProcessor import XmlProcessor
from GovAnalytics.processors.SqlProcessor import SqlProcessor

path = "D:\CongressData\congress\data"

processor = SqlProcessor()

all_bills = XmlProcessor.get_all_bills(path)

for bill in all_bills:
    processor.insert_bill(bill)

print("Total Number of Bills Processed: " + str(len(all_bills)))
