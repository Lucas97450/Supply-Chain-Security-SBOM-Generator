from fastapi import FastAPI, Request

app = FastAPI()

@app.get("/hello")
def say_hello():
    return {"message": "Hello, supply chain world!"}

@app.post("/data")
async def receive_data(request: Request):
    data = await request.json()
    return {"received": data}
