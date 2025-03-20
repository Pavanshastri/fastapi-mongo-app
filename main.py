from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from pymongo import MongoClient
from bson import ObjectId
from typing import Optional

# Initialize FastAPI app
app = FastAPI()

# MongoDB connection
client = MongoClient("mongodb://localhost:27017")
db = client["key_value_store"]
collection = db["store"]

# Pydantic model for input validation
class StoreItem(BaseModel):
    value: str

# ===============================
# POST: Store Key-Value Pair
# ===============================
@app.post("/store/{key}")
def store_item(key: str, item: StoreItem):
    existing = collection.find_one({"key": key})
    if existing:
        raise HTTPException(status_code=400, detail="Key already exists")
    
    collection.insert_one({"key": key, "value": item.value})
    return {"message": "Stored successfully", "key": key, "value": item.value}

# ===============================
# GET: Retrieve Key-Value Pair
# ===============================
@app.get("/store/{key}")
def get_item(key: str):
    item = collection.find_one({"key": key})
    if not item:
        raise HTTPException(status_code=404, detail="Key not found")
    
    return {"key": item["key"], "value": item["value"]}

# ===============================
# DELETE: Delete Key-Value Pair
# ===============================
@app.delete("/store/{key}")
def delete_item(key: str):
    result = collection.delete_one({"key": key})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Key not found")
    
    return {"message": "Deleted successfully", "key": key}

# ===============================
# Root Endpoint
# ===============================
@app.get("/")
def root():
    return {"message": "FastAPI Key-Value Store Running"}

