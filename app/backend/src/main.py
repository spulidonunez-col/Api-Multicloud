from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware
from database import engine, Base
from routes import items, health
import os

# Crear tablas
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Linktic Multi-Cloud API", version="1.0.0")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Rutas
app.include_router(health.router)
app.include_router(items.router)

# Frontend (opcional - lo añadiremos después)
# app.mount("/static", StaticFiles(directory="static"), name="static")
# templates = Jinja2Templates(directory="templates")

@app.get("/")
def root():
    return {"message": "Linktic Multi-Cloud API", "status": "running"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)