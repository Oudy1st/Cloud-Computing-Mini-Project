# Cloud-Computing-Mini-Project
# Heatmap API
* #### id   : 180778344
* #### Name : Detchat Boonpragob


# Introduction
  Heatmap are become essential information for software development and marketing statistics. Therefore, this project is focus on how to collect the user interactive data via RestfulAPI with Mobile Application. However, the demo application is only iOS Application. 

### Server Side
> **Deployment:** In **Google Cloud Platform**  deployed with **Kubernetes**  with Load balancing of 3 clusters

```sh
http://35.222.100.65
```

* Python 

### Client Side
> **iOS Project 

* swift

### Database
> **MONGO DB** deployed with Load balancing of 3 clusters in mongo DB cloud Atlas

```sh
https://www.mongodb.com/cloud/atlas
```


# Feature
Basic authentication.
Manage applications.
Collect user interactions in mobile applications. 
Get summary of application's interaction data and location-base usage data.

In order to create location-base usage data, I'm using Google's geocoding api to reverse geolocation data from devices into address information.

* Geocoding API - (https://developers.google.com/maps/documentation/geocoding/start) 

# Authentication
I create my own authentication with basic token.

# API 
| API | LINK |
| ------ | ------ |
| Users Authentication | https://documenter.getpostman.com/view/3667784/S17uu7D1#81b2bfb7-a0ca-47e6-b9ea-4d82e235a921 |
| Application | https://documenter.getpostman.com/view/3667784/S17uu7D1#ce81d0d1-c2b6-459c-b6d7-ae92fa4ddad9 |
| Heatmap | https://documenter.getpostman.com/view/3667784/S17uu7D1#da62a26f-b20a-423c-aee9-0af7390c0098 |

# Deployment

Server - GCloud
1. open your "Active cloud shell" in GCloud's console.
2. clone this project.
```sh
git clone https://github.com/Oudy1st/Cloud-Computing-Mini-Project.git
```
3. change directory to the project.
```sh
cd Cloud-Computing-Mini-Project/Heatmap
```
4. edit Google API Key and Mongo DB Connection in heatmap.py.
```sh
google_map_api = "your key here"
client = pymongo.MongoClient("your connection here")
```
5. run the shell script.
```sh
sh deploy.sh
```
* this script will create docker(heatmap:v1), upload it, create new Kubernetes with Load balancing of 3 clusters and deploy the services. So, you can edit you cluster name, docker name in this script.

Client - iOS
1. download demo application project.
2. open project in xcode.
3. edit your serverURL, token and applicationID in "HeatmapService.swift".
```sh
hostURL = "your host url"
header["Authorization"] = "your login token"
body["app_id"] = "your app id"
```
4. edit your app_secret in "HeatmapSession.swift".
```sh
let appSecret = "your app secret"
```
5. run on your device or simulator.

 
Enjoy!
