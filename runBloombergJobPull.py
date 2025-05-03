#!/usr/bin/env python
# coding: utf-8



import requests
import math/Users/keirdaniels/Downloads/Untitled.py
from bs4 import BeautifulSoup
import re
import numpy as np
import pandas as pd






def jobListfromHtml(html_content,listOfJobLinks):
    
    html = html_content
    parsed_html = BeautifulSoup(html)


    listOfJobs = parsed_html.find_all("h3", {"class": re.compile(r'^article__header__text__title title title--')})

    for location in listOfJobs:

        #print(location.find('a')['href'])
        listOfJobLinks.append(location.find('a')['href'])
        
    #return listOfJobLinks




def CreateListofJobLinks(url, listOfJobLinks): 
#url = "https://bloomberg.avature.net/careers/SearchJobs/?1845=%5B162508%2C162535%2C162483%2C162619%5D&1845_format=3996&listFilterMode=1&jobRecordsPerPage=12&jobOffset=0"

    response = requests.get(url)

    if response.status_code == 200:
        html_content = response.text
        jobListfromHtml(html_content,listOfJobLinks)
        
    else:
        print("Failed to retrieve the webpage.")
    
    
    



def createHtml(link):
    response = requests.get(link)
    #print(listOfJobLinks[0])

    if response.status_code == 200:
        html_contentB = response.text


    else:
        print("Failed to retrieve the webpage.")

    return html_contentB





def createRecord(link,recordList=None ):
    

    parsed_htmlB = BeautifulSoup(createHtml(link))

    listOfJobs = parsed_htmlB.find(class_ = "article article--details ")

    resultList = parsed_htmlB.find_all("article")
    Desc = resultList[0].text.strip()

    subList = resultList[1].find_all(class_="article__content__view__field__value")

    location = subList[0].text.strip()
    group = subList[1].text.strip()
    ID = subList[2].text.strip()

    #print(resultList[0].text)
    #print(resultList[1])
    #print(resultList[2].text)
    #finddiv class="article__content__view__field__label




    #print(location, group, ID)

    salary = parsed_htmlB.find_all(class_="article__content__view__field field--rich-text")
    salaryStringLong = salary[0].text

    salaryStringLong.find("=")
    salaryRange = salaryStringLong[salaryStringLong.find("=")+2:salaryStringLong.find("USD")-1]
    LowEnd = salaryRange[:salaryRange.find("-")-1]
    highEnd = salaryRange[salaryRange.find("-")+1:]
    
    
    #print(Desc, location, group, ID, salaryRange, LowEnd, highEnd)
    
    
 
    return [Desc, location, group, ID, salaryRange, LowEnd, highEnd,link]

    
#print(salaryStringLong)




def parsepage(loop):

    count = 0
    listOfJobLinks = []

    while count <= loop-1:

        print(count)
        offset = str(count*12)
        url = "https://bloomberg.avature.net/careers/SearchJobs/?1845=%5B162508%2C162535%2C162483%2C162619%5D&1845_format=3996&listFilterMode=1&jobRecordsPerPage=12&jobOffset="+offset
        #print(url)
        #https://bloomberg.avature.net/careers/SearchJobs/?1845=%5B162508%2C162535%2C162483%5D&1845_format=3996&listFilterMode=1&jobRecordsPerPage=12&
        print("offset value", offset)
        CreateListofJobLinks(url, listOfJobLinks) 


        count += 1 


        recordList = None
    for value in listOfJobLinks:

        #print(value)

        if recordList:
            recordList.append(createRecord(value,recordList))


        else:

            recordList = [createRecord(value,recordList)]

    
    return recordList


    





def runBloombergJobPull(jobs, outputFile):
    '''
    The script pulls all the jobs in the NY area from this site and converts it to a csv.
    This is page url it pulls from:url = "https://bloomberg.avature.net/careers/SearchJobs/?1845=%5B162508%2C162535%2C162483%2C162619%5D&1845_format=3996&listFilterMode=1&jobRecordsPerPage=12&jobOffset="+offset

    Inputs:
        jobs: Int, this should be the total number of jobs in this link:
        outputFile: String, of the file name and file path where the csv should write to : #'/Users/keirdaniels/Downloads/Bloomberg.csv'
    Output:
        csv file written to path provided in outpuFile argument.
    '''
    

    loops = math.floor(((jobs +1)/12))
    print("loops", loop)

    try:
        parsepage(loop)
        
    except:
        print("An error occurred before writing to the file")
        
    try: 
        df = pd.DataFrame(recordList,columns=['Desc', 'location', 'group', 'ID', 'salaryRange', 'LowEnd', 'highEnd','link'])
        df.to_csv(outputFile)  
        
    
    except:
        print("An error occurred when writing to file")
        
    
    print("complete")
    
    




# exampel of what to run: runBloombergJobPull(122, '/Users/keirdaniels/Bloomberg.csv')






