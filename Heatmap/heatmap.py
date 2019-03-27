from flask import Flask, jsonify, json, request
from hashlib import blake2b
import uuid
import datetime
import pymongo
import urllib
from bson import json_util
from bson import ObjectId
from bson.code import Code
import googlemaps

app = Flask(__name__)

def print_log(obj):
    print("##################\n")
    print(obj)
    print("##################\n")
#global
date_format = '%Y-%m-%dT%H:%M:%SZ'
google_map_api = "AIzaSyC4SHSvQSRb-uIu4X5iAMxmnQHU6vNmv8k"
gmaps = googlemaps.Client(key=google_map_api)

client = pymongo.MongoClient("mongodb+srv://oudy_cc:"+ urllib.parse.quote_plus("P@ssw0rd") +"@cluster0-zswop.mongodb.net/test?retryWrites=true")
db = client.Heatmap

#helper methos
def getAddress(lat,lng):
    data = gmaps.reverse_geocode((lat, lng),["country","administrative_area_level_1","postal_code"])

    address = data[0]
    postal_code = ""
    address1 = ""
    country = ""
    for item in address["address_components"]:
        if item["types"][0] == "postal_code":
            postal_code = item["long_name"]
        elif item["types"][0] == "administrative_area_level_1":
            address1 = item["long_name"]
        elif item["types"][0] == "country":
            country = item["long_name"]




    return {"address1":address1,"country":country,"postal_code":postal_code}


def hash(input):
    h = blake2b(digest_size=20)
    h.update(str.encode(input))
    return h.hexdigest()

def select(table):
    fileName = '{}.json'.format(table)
    with open(fileName) as f:
        records = json.load(f)
    return records

def insert(table,new_record):
    fileName = '{}.json'.format(table)
    with open(fileName) as f:
        records = json.load(f)
    records.append(new_record)
    with open(fileName, 'w') as f:
        json.dump(records, f)

    return True

def response(code, message, data = ""):
    response = {
        "message" : message,
        "data" : data
    }
    return jsonify(response), code

def gen_token(user_id):
    _token = uuid.uuid4().hex

    db.Token.update_one({"user_id":user_id},{ '$set' :{
        "token" : _token,
        "user_id":user_id,
        "create_date" : datetime.datetime.utcnow(),
        "expire_date" : datetime.datetime.utcnow() + datetime.timedelta(minutes=180)
    }}, True)

    return _token

def check_token(token):
    _token = db.Token.find_one({"token":token})
    if not bool(_token):
        return { 'is_expire':True, 'message':'unauthorize' }
    else:
        expire_date = _token['expire_date']

        # expire_date = datetime.datetime.strptime(_selected_token['expire_date'], date_format)
        if expire_date < datetime.datetime.utcnow():
            return { 'is_expire':True, 'message':"token expire" }
        else:
            return { 'is_expire':False, 'message':"" , 'token': json_util.dumps(_token)}


# def query(sql):
#     mycursor = mysql.connection.cursor()
#     mycursor.execute(sql)
#     if sql.startswith( 'select' ):
#         retVal = mycursor.fetchall()
#     else:
#         retVal = mycursor.rowcount
#     end
#     mysql.connection.close()
#     return retVal




############# Heatmap ################
@app.route('/app/create_app', methods=['POST'])
def create_app():
    token = request.headers['Authorization']
    token_res = check_token(token)
    if token_res['is_expire']:
        return response(403,token_res['message'])

    _token_obj = json_util.loads(token_res['token'])
    new_record = {
        'user_id' : _token_obj['user_id'],
        'app_secret': uuid.uuid4().hex,
        'app_name' : request.json['app_name'],
        'create_date' : datetime.datetime.utcnow()
    }

    if db.Application.count_documents({"user_id":_token_obj['user_id'], "app_name":request.json['app_name']}) > 0:
        return response(500, "Application already exists.")
    else:
        response_id = db.Application.insert_one(new_record)

    if bool(response_id):
        return response(201, 'application has been created', {'app_secret':new_record['app_secret']})
    else:
        return response(500, 'cannot create application')

@app.route('/app', methods=['GET'])
def get_app():
    token = request.headers['Authorization']
    token_res = check_token(token)
    if token_res['is_expire']:
        return response(403,token_res['message'])

    _token_obj = json_util.loads(token_res['token'])
    _user_id = _token_obj['user_id']

    list = db.Application.find({"user_id":_user_id}, {"_id":1,"app_secret":1,"app_name":1,"create_date":1,})

    if bool(list):
        return response(200, 'get application success', json_util.dumps(list))
    else:
        return response(500, 'no application')

@app.route('/app/<app_id>', methods=['DELETE'])
def delete_app(app_id):
    token = request.headers['Authorization']
    token_res = check_token(token)
    if token_res['is_expire']:
        return response(403,token_res['message'])

    _token_obj = json_util.loads(token_res['token'])
    _user_id = _token_obj['user_id']

    del_result = db.Application.delete_one({"user_id":_user_id, "_id":ObjectId(app_id)})

    if del_result.deleted_count > 0:
        return response(200, 'delete success')
    else:
        return response(500, 'no application')


@app.route('/heatmap/session', methods=['POST'])
def heatmap_session():
    secret = request.headers['app_secret']
    app = db.Application.find_one({'app_secret': secret})

    if not bool(app):
        return response(500, "application not found")


    address = getAddress(request.json['latitude'], request.json['longitude'])
    new_record = {
        "app_id" : app['_id'],
    	"latitude":request.json['latitude'],
    	"longitude":request.json['longitude'],
    	"postal_code":address['postal_code'],
    	"address1":address['address1'],
    	"country":address['country'],
    	"timestamp": datetime.datetime.strptime(request.json['timestamp'], date_format)
    }

    ins_response = db.LogSession.insert_one(new_record)

    return response(201, 'create session success', {"session_id":str(ins_response.inserted_id)})


@app.route('/heatmap/log', methods=['POST'])
def heatmap_log():
    secret = request.headers['app_secret']
    app = db.Application.find_one({'app_secret': secret})

    if not bool(app):
        return response(500, "application not found")

    records = []
    session_id = request.json['session_id']
    log_array = request.json['log_array']
    for index in range(len(log_array)):
        pos = log_array[index]['position']
        screen_size = log_array[index]['screen_size']
        normalise_pos = [pos[0]/screen_size[0], pos[1]/screen_size[1]]
        new_record = {
            "session_id" : ObjectId(session_id),
        	"device":log_array[index]['device'],
        	"screen_size":screen_size,
        	"position":normalise_pos,
        	"timestamp": datetime.datetime.strptime(log_array[index]['timestamp'], date_format)
        }
        records.append(new_record)

    ins_response = db.Log.insert_many(records)

    return response(201, 'log success', len(ins_response.inserted_ids))

@app.route('/heatmap/screen', methods=['GET'])
def get_heatmap_screen():
    token = request.headers['Authorization']
    token_res = check_token(token)
    if token_res['is_expire']:
        return response(403,token_res['message'])

    _token_obj = json_util.loads(token_res['token'])
    _user_id = _token_obj['user_id']

    _device = int(request.args.get('device'))
    app_id = request.args.get('app_id')


    session_list = db.LogSession.find({"app_id":ObjectId(app_id)}, {"session_id":1})
    session_list_ids = list(map(lambda x: x['_id'], session_list))

    print_log(session_list_ids)
    log_array = db.Log.aggregate([
        {"$match": { "session_id": { "$in" : session_list_ids}, "device":_device} },
        {"$group": { "_id": "$position", "count": { "$sum": 1 } } }
    ])

    if bool(log_array):
        return response(200, 'get heatmap screen success', json_util.dumps(log_array))
    else:
        return response(500, 'data not found')

@app.route('/heatmap/map', methods=['GET'])
def get_heatmap_map():
    token = request.headers['Authorization']
    token_res = check_token(token)
    if token_res['is_expire']:
        return response(403,token_res['message'])

    _token_obj = json_util.loads(token_res['token'])
    _user_id = _token_obj['user_id']

    app_id = request.args.get('app_id')


    session_list = db.LogSession.aggregate([
        {"$match": { "app_id": ObjectId(app_id) } },
        {"$group": { "_id": { "country" : "$country" , "address1" : "$address1" }, "count": { "$sum": 1 } } }
    ])

    if bool(session_list):
        return response(200, 'get heatmap location success', json_util.dumps(session_list))
    else:
        return response(500, 'data not found')

@app.route('/heatmap/log/<app_id>', methods=['DELETE'])
def delete_heatmap(app_id):
    token = request.headers['Authorization']
    token_res = check_token(token)
    if token_res['is_expire']:
        return response(403,token_res['message'])

    _token_obj = json_util.loads(token_res['token'])
    _user_id = _token_obj['user_id']

    del_result = db.Log.delete_many({})

    if del_result.deleted_count > 0:
        return response(200, 'delete success')
    else:
        return response(500, 'cannot delete log')


############# Membership #################

@app.route('/member/regist', methods=['POST'])
def regist():
    username = request.json['username']
    password = request.json['password']

    new_record = {
        'username': username,
        'password': hash(password)
    }

    if db.Member.count_documents({"username":username}) > 0:
        return response(500, "User already exists.")
    else:
        db.Member.insert_one(new_record)
        msg = "created: /user/{}/{}".format(new_record['username'],new_record['password'])
        return response(201, msg)

@app.route('/member', methods=['DELETE'])
def delete_member():
    username = request.json['username']

    # insert('user',new_record)
    if db.Member.count_documents({"username":username}) == 0:
        return response(500, "User no longer exist.")
    else:
        db.Member.delete_one({"username":username})
        msg = "deleted {}".format(username)
        return response(200, msg)

@app.route('/member/login', methods=['POST'])
def login():
    username = request.json['username']
    password = request.json['password']
    hash_p = hash(password)

    auth_user = db.Member.find_one({"username":username, "password":hash_p})

    if not bool(auth_user):
        return jsonify({"message":"user or password incorrect"}), 200
    else:
        token = gen_token(auth_user['_id'])
        return response(201, "login success" , { "user_id":str(auth_user['_id']) , "token":token})



@app.route('/member/refresh', methods=['POST'])
def refresh():
    token = request.json['token']
    user_id = request.json['user_id']

    old_token = db.Token.find_one({ "user_id" : ObjectId(user_id), "token" : token })
    if not bool(old_token):
        return jsonify({"message":"incorrect user_id or token"}), 200
    else:
        token = gen_token(ObjectId(user_id))
        return response(201, "refresh token success" , { "token":token})


@app.route('/')
def hello():
    result = "hello heatmap"
    return result

if __name__ == '__main__':
#    app.run(debug=True)
    app.run(host='0.0.0.0', port=8080)
