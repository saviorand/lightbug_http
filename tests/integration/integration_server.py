from typing import Union

from fastapi import FastAPI, Response
from fastapi.responses import RedirectResponse, PlainTextResponse

app = FastAPI()


@app.get("/redirect")
async def redirect(response: Response):
    return RedirectResponse(
        url="/rd-destination", status_code=308, headers={"Location": "/rd-destination"}
    )


@app.get("/rd-destination")
async def rd_destination(response: Response):
    response.headers["Content-Type"] = "text/plain"
    return PlainTextResponse("yay you made it")


@app.get("/close-connection")
async def close_connection(response: Response):
    response.headers["Content-Type"] = "text/plain"
    response.headers["Connection"] = "close"
    return PlainTextResponse("connection closed")


@app.get("/error", status_code=500)
async def error(response: Response):
    return PlainTextResponse("Internal Server Error", status_code=500)
