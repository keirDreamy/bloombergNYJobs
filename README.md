#Bloomberg job

This repo has several coding example that I am providing

#1. Pulling Bloomberg jobs

This is kept in the runBloombergJobPull.py file
    run this scrip by running this command:
    runBloombergJobPull(jobs, outputFile):
        '''
        The script pulls all the jobs in the NY area from this site and converts it to a csv.
        This is page url it pulls from:url = "https://bloomberg.avature.net/careers/SearchJobs/?1845=%5B162508%2C162535%2C162483%2C162619%5D&1845_format=3996&listFilterMode=1&jobRecordsPerPage=12&jobOffset="+offset
    
        Inputs:
            jobs: Int, this should be the total number of jobs in this link  :https://bloomberg.avature.net/careers/SearchJobs/?1845=%5B162508%2C162535%2C162483%2C162619%5D&1845_format=3996&listFilterMode=1&jobRecordsPerPage=12&jobOffset="+offset
            
            outputFile: String, of the file name and file path where the csv should write to : #'/Users/keirdaniels/Downloads/Bloomberg.csv'
       
        Output:
            csv file written to path provided in outpuFile argument.
        '''
    
        Example: 
        runBloombergJobPull(122, '/Users/keirdaniels/Downloads/BloombergTest.csv')


===========
The rest of of the files are other coding examples from various projects. 
