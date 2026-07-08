import os
from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware
from database import engine, Base
from routes import health, items

# Crear tablas
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Demo Multi-Cloud API", version="1.0.0")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ========== FRONTEND ==========
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
static_dir = os.path.join(BASE_DIR, "static")
templates_dir = os.path.join(BASE_DIR, "templates")

app.mount("/static", StaticFiles(directory=static_dir), name="static")
templates = Jinja2Templates(directory=templates_dir)

# ========== RUTAS ==========
app.include_router(health.router)
app.include_router(items.router)

# ========== ROOT ==========
@app.get("/")
def root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})