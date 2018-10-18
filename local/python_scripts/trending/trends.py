import os
import time

os.environ["PARSE_API_ROOT"] = "https://parseapi.back4app.com/"

from pytrends.request import TrendReq
from datetime import datetime

from parse_rest.connection import SessionToken, register
from parse_rest.datatypes import Object
from parse_rest.user import User


print("----------------------------------------------")
pytrend = TrendReq()

year = datetime.utcnow().strftime('%Y')
month = datetime.utcnow().strftime('%m')
mt = int(month) - 7
sm = ""

if mt <= 9:
    sm = "0" + str(mt)
else:
    sm = str(mt)

date = year + sm

print(date)

# issue
#https://github.com/GeneralMills/pytrends/issues/269

top_games = pytrend.top_charts(cid="games", geo='US', date=date)
top_tv = pytrend.top_charts(cid="childrens_tv_programs", geo='US', date=date)
top_animals = pytrend.top_charts(cid="animals", geo='US', date=date)
top_teen_pop_artists = pytrend.top_charts(cid="teen_pop_artists", geo='US', date=date)
top_soccer_teams = pytrend.top_charts(cid="soccer_teams", geo='US', date=date)

print("-------------------------------------------------------------------")

APPLICATION_ID = '45cgsAjYqwQQRctQTluoUpVvKsHqrjCmvh72UGBx'
REST_API_KEY = 'ztAtrUlQVEacsoZWbkH2Ljk8AZew25rz2wJPPOAX'

register(APPLICATION_ID, REST_API_KEY)

u = User.login("gamvesadmin", "lo vas a lograr")

print("parse session: " + str(u.sessionToken))
print("parse session type: " + type(u.sessionToken).__name__)

with SessionToken(u.sessionToken):
    me = User.current_user()
    print("current user is...." + str(me))

print("You are logged in..." + str(u.sessionToken))

class Trends(Object):
    pass

class CategoryTrends(Object):
    pass

all_category_trends = CategoryTrends.Query.all()
for qct in all_category_trends:
    qct.delete()

all_trends = Trends.Query.all()
for qt in all_trends:
    qt.delete()

def saveCategoryTrend(name, desc):
    ctr = CategoryTrends()
    ctr.name = name
    ctr.description = desc
    ctr.save()
    print("Category: " + name)
    print("-------------------------------")
    return ctr

def saveTrend(row, iobjectId):
    title = row["title"]
    desc = row["description"]
    tr = Trends()
    tr.name = title
    tr.description = desc["description"]
    tr.trendId = iobjectId
    tr.save()
    print(title)
    return tr

def createTrend(name, desc, top):
    gameTrend = saveCategoryTrend(name, desc)
    time.sleep(1)
    relationGame = gameTrend.relation('trend')
    for index, row in top.iterrows():
        trend = saveTrend(row, gameTrend.objectId)
        time.sleep(1)
        relationGame.add(trend)
        gameTrend.save()
        time.sleep(1)


gamesDesc = "Video games " + sm + " " + year
tvDesc = "Kids' TV " + sm + " " + year
animalDesc = "Animals " + sm + " " + year
artistsDesc = "Artists " + sm + " " + year
soccerDesc = "Soccer teams " + sm + " " + year

createTrend("Games", gamesDesc, top_games)
createTrend("TV programs", tvDesc, top_tv)
createTrend("Animals", animalDesc, top_animals)
createTrend("Artists", artistsDesc, top_teen_pop_artists)
createTrend("Soccer teams", soccerDesc, top_soccer_teams)