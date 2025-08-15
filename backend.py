from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from pymongo import MongoClient

app = FastAPI()

#connecting to mongo
client = MongoClient("mongodb://localhost:27017/") #our url
db = client["ctf_game"]  #database name
players = db["players"]  #player collection -> username, passwd, current level

#requesting body models
class PlayerCreate(BaseModel):
    username: str
    password: str

class FlagSubmission(BaseModel):
    username: str
    submitted_flag: str

# Correct flags stored securely in backend
correct_flags = {
    0: "WLUG{1234}",
    1: "WLUG{1234}",
    2: "WLUG{1234}",
    3: "WLUG{1234}"
}

# Create a new player
@app.post("/create_player")
def create_player(data: PlayerCreate):
    if players.find_one({"username": data.username}):
        raise HTTPException(status_code=400, detail="Username already exists")

    players.insert_one({
        "username": data.username,
        "password": data.password,  # In real life, hash this!
        "current_level": 0
    })
    return {"status": "player_created", "username": data.username, "current_level": 0}


# Get current progress
@app.get("/progress/{username}")
def get_progress(username: str):
    player = players.find_one({"username": username}, {"_id": 0})
    if not player:
        raise HTTPException(status_code=404, detail="Player not found")
    return player


# Submit flag and check
@app.post("/submit_flag")
def submit_flag(data: FlagSubmission):
    player = players.find_one({"username": data.username})
    if not player:
        raise HTTPException(status_code=404, detail="Player not found")

    current_level = player["current_level"]

    # Validate flag
    if data.submitted_flag.strip() == correct_flags.get(current_level):
        players.update_one(
            {"username": data.username},
            {"$set": {"current_level": current_level + 1}}
        )
        return {"status": "correct", "next_level": current_level + 1}
    else:
        return {"status": "wrong", "current_level": current_level}
