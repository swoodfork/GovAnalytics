from GovAnalytics.processors.JsonProcessor import JsonProcessor
from GovAnalytics.processors.SqlProcessor import SqlProcessor
from GovAnalytics.PathConstants import *

processor = SqlProcessor()

all_legislators = JsonProcessor.get_all_legislators(PathConstants.LEGISLATOR_ROOT)

processor.load_counter("Legislator", len(all_legislators))

for legislator in all_legislators:
    processor.insert_legislator(legislator)

processor.report()
